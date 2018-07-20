# frozen_string_literal: true

# Class to manage the different queues
# Eventually it could have types of distinctions:
#   mmr, clans, etc.
class QueuesManager
  def initialize
    @queues = queues
    @bot = bot
    load_help_message i18n, queues_names
    Commands.queues_manager = self
  end

  def add_user_to_queue(queue_name, user)
    return false if !queues[queue_name] || queues[queue_name].user_in_queue?(user)
    queue = queues[queue_name]
    queue.add_user user
    handle_full_queue(queue) if queue.full?
    true
  end

  def remove_user_from_queue(queue_name, user)
    return false if !queues[queue_name] || !queues[queue_name].user_in_queue?(user)
    queues[queue_name].remove_user user
    true
  end

  def handle_full_queue(queue)
    bot.notify_queue_is_full queue
    queue.empty!
  end

  def queue_exists?(queue_name)
    queues[queue_name]
  end

  def i18n
    @i18n ||= $i18n
  end

  def bot
    @bot ||= MatchMakingBot.new('.')
  end

  def execute
    bot.run
  end

  def queues_names
    ans = {}
    queues.map { |name, queue| ans = ans.merge(name => queue.description) }
    ans
  end

  def queues
    @queues ||= load_queues
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
    user_queues = queues.select { |_name, queue| queue.user_in_queue? user }
    user_queues.map { |_name, queue| queue }
  end

  attr_reader :match_size

  attr_reader :name
end
