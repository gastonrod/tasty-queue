# frozen_string_literal: true

# Class to manage the different queues
# Eventually it could have types of distinctions:
#   mmr, clans, etc.
class QueuesManager

  # Initialize the queues manager. So far this is the main class that manages
  #   the whole program.
  def initialize
    @queues = queues
    @bot = bot
    @users_queue_map = {}
    load_help_message i18n, queues_names
    Commands.queues_manager = self
  end

  # All the queues the user is subscribed to.
  # @return [Array[GroupQueue]] All the queues he is in.
  def queues_this_user_is_in(user)
    users_queue_map[user]
  end

  # Get a [String]=>[String] hash that tells you the queue's identification name,
  # with it's pretty description.
  def queues_names
    ans = {}
    queues.map { |name, queue| ans = ans.merge(name => queue.description) }
    ans
  end

  # Checks if a user is in a queue or not
  # @param queue_name [String] String by which the queue is identified.
  # @param user [Discordrb::User] User that will join the queue.
  # @returns [Boolean] if the user is in the specified queue, or if it is in the 'any' queue.
  def user_in_queue?(queue_name, user)
    queues[queue_name].user_in_queue?(user) || queues['any'].user_in_queue?(user)
  end

  # Adds a user to the specified queue.
  # @param queue_name [String] String by which the queue is identified.
  # @param user [Discordrb::User] User that will join the queue.
  # @return [ADD_USER_ENUM value] The value according to each situation.
  def add_user_to_queue(queue_name, user)
    return Commands::ADD_USER_ENUM[:already_in_queue] if !queues[queue_name] || 
      user_in_queue?(queue_name, user)
    queue = queues[queue_name]
    return add_to_any(user) if queue_name == 'any'
    add_queue_to_users_map queue, user
    queue.add_user user
    if queue_is_full? queue
      handle_full_queue(queue) if queue_is_full? queue
      Commands::ADD_USER_ENUM[:filled_up_queue]
    else
      Commands::ADD_USER_ENUM[:added]
    end
  end


  # Removes a user from the specified queue
  # @param queue_name [String] The name by which the GroupQueue is identified.
  # @param user [Discordrb::User] The user that will be removed.
  def remove_user_from_queue(queue_name, user)
    return false if queue_name != 'all' && (!queues[queue_name] || !queues[queue_name].user_in_queue?(user))
    (queue_name == 'all') ? (users_queue_map[user].each { |queue| queue.remove_user user }):(queues[queue_name].remove_user user)
    remove_queue_from_users_map(queue_name, user)
    true
  end

  # Check if a determined queue exists.
  # @param queue_name [String] The name by which the GroupQueue is identified.
  def queue_exists?(queue_name)
    queues[queue_name]
  end

  # Start the bot
  def execute
    bot.run
  end

  # Called when there are enough players to play in a queue. 
  # @param queue [GroupQueue] The queue that has filled up or it has enough 
  #                           players with people who joined the default queue).
  def handle_full_queue(queue)
    if !queues['any'].empty?
      queue.add_users queues['any'].users
      queues['any'].empty!
    end
    bot.notify_queue_is_full queue
    queue.users.each { |u| users_queue_map[u] = nil }
    queue.empty!
  end

  def get_queue_description(queue_name)
    queues[queue_name].description                      
  end

  private

  # Adds a user to the map that maps a user to it's current queues.
  # @param queue [GroupQueue] The queue to which the user has joined.
  # @param user [Discordrb::User] The user that has joined the queue.
  def add_queue_to_users_map(queue, user)
    return users_queue_map[user] = queues.values if queue.name == 'any'
    return users_queue_map[user] = [queue] if users_queue_map[user].nil?
    users_queue_map[user].push queue
  end

  # Removes a user from the map that maps a user to it's current queues.
  # @param queue_name [String] The queue from which the user will be removed.
  # @param user [Discordrb::User] The user to be removed from the queue.
  def remove_queue_from_users_map(queue_name, user)
    return users_queue_map[user] = nil if queue_name == 'any' || queue_name == 'all'
    users_queue_map[user].delete queues[queue_name]
  end

  # Load all the queues from the queues_definition yaml file
  def load_queues
    queues_hash = YAML.safe_load(File.read('../config/queues_definition.yml'))

    # Separate the any queue to load it after.
    any_queue_params = queues_hash['any']
    queues_hash.delete('any')

    # Load queues hash and get the minimum group_size
    queues, minimum_amount = create_queues(queues_hash, 2**32 - 1)

    any_queue = { 'any' => GroupQueue.new('any', any_queue_params.merge(
                                                   'group_size' => minimum_amount
                                                 )) }
    queues.merge(any_queue)
  end

  # Receives a [String]=>[Hash] hash, and with it creates the GroupQueue's objects.
  def create_queues(queues_hash, minimum_amount)
    queues = {}
    queues_hash.each do |name, values|
      minimum_amount = values['group_size'] if minimum_amount > values['group_size']
      queues = queues.merge(name => GroupQueue.new(name, values))
    end
    [queues, minimum_amount]
  end



  # Adds an user to the 'any' queue. 
  # @param user [Discordrb::User] User that will join the queue.
  # @return [ADD_USER_ENUM value] The value according to each situation.
  def add_to_any(user)
    return Commands::ADD_USER_ENUM[:cant_join_any] if !users_queue_map[user].nil? && !users_queue_map[user].empty?
    queues['any'].add_user(user)
    add_queue_to_users_map queues['any'], user
    any_full_queues, full_queue = any_full_queues?
    handle_full_queue(full_queue) if any_full_queues
    (any_full_queues)?(Commands::ADD_USER_ENUM[:filled_up_queue]):(Commands::ADD_USER_ENUM[:added])
  end

  # Checks whether the given queue is full or if it can be filled up with players from the 'any'
  #   queue.
  def queue_is_full?(queue)
    queue.full? || queue.size + queues['any'].size == queue.group_size
  end

  # Checks whether there is any queue that can be filled up with the users in the 'any' queue.
  # Thought of a nicer way to do this maybe with an external variable, or passing the queue as
  #   parameter and have it modify it? This method seems rather ugly but I don't want to go through
  #   the queues twice (one to get the boolean and a 2nd time to get the full queue).
  # @return [[Boolean, GroupQueue]] whether there are any full queues, and if the boolean is true,
  #   the full queue will be returned in the second position. If not, it'll be nil.
  def any_full_queues?
    full_queue = nil
    queues.values.each do |queue|
      next if queue.size + queues['any'].size < queue.group_size || queue.name == 'any'
      full_queue = queue
      break
    end
    return [false, full_queue] if full_queue.nil?
    [true, full_queue]
  end

  # The good ol' bot
  def bot
    @bot ||= MatchMakingBot.new('.')
  end

  # i18n's hash
  def i18n
    @i18n ||= $i18n
  end

  # HashMap<String, GroupQueue> queues
  # Key: Queue's name (as loaded in the .yml)
  # GoupQueue: The queue object, with it's name, description, etc..
  def queues
    @queues ||= load_queues
  end

  # HashMap<User, GroupQueue> users_queue_map
  # A hashmap to quickly locate a user's queues.
  attr_reader :users_queue_map
end
