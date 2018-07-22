# frozen_string_literal: true

# Class to manage the different queues
# Eventually it could have types of distinctions:
#   mmr, clans, etc.
class QueuesManager
  def initialize
    @queues = queues
    @bot = bot
    @users_queue_map = {}
    load_help_message i18n, queues_names
    Commands.queues_manager = self
  end

  def add_user_to_queue(queue_name, user)
    return false if !queues[queue_name] || queues[queue_name].user_in_queue?(user)
    queue = queues[queue_name]
    queue.add_user user
    add_queue_to_users_map queue, user
    handle_full_queue(queue) if queue.full?
    true
  end

  def handle_full_queue(queue)
    bot.notify_queue_is_full queue
    queue.users.each { |u| users_queue_map[u].delete(queue)}
    queue.empty!
  end

  def add_queue_to_users_map(queue, user)
    return users_queue_map[user] = [queue] if users_queue_map[user].nil?
    users_queue_map[user].push queue
  end

  def remove_user_from_queue(queue_name, user)
    return false if !queues[queue_name] || !queues[queue_name].user_in_queue?(user)
    users_queue_map[user].delete queues[queue_name]
    queues[queue_name].remove_user user
    true
  end

  def queue_exists?(queue_name)
    queues[queue_name]
  end

  def execute
    bot.run
  end

  def queues_names
    ans = {}
    queues.map { |name, queue| ans = ans.merge(name => queue.description) }
    ans
  end


  def load_queues
    queues_hash = YAML.safe_load(File.read('../config/queues_definition.yml'))
    queues = {}
    queues_hash.each do |name, values|
      queues = queues.merge(name => GroupQueue.new(name, values))
    end
    queues
  end

  def queues_this_user_is_in(user)
    users_queue_map[user]
  end

  def bot
    @bot ||= MatchMakingBot.new('.')
  end

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
