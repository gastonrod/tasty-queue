# frozen_string_literal: true

# Add the queues manager to the commands module
module Commands
  ADD_USER_ENUM = { added: 0, already_in_queue: 1, filled_up_queue: 2, cant_join_any: 3 }.freeze
  def self.queues_manager=(queues_manager)
    @queues_manager = queues_manager
  end

  def self.queues_manager
    @queues_manager
  end
end
