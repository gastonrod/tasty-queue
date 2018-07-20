# frozen_string_literal: true

# Add the queues manager to the commands module
module Commands
  def self.queues_manager=(queues_manager)
    @queues_manager = queues_manager
  end

  def self.queues_manager
    @queues_manager
  end
end
