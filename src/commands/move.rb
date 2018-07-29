# frozen_string_literal: true

module Commands
  # description: 'Leave a queue.'
  # useage: 'q!leave queue_name',
  module Move
    extend Discordrb::Commands::CommandContainer
    command(
      :move,
      description: 'move.',
      useage: 'q!move',
      help_available: false
    ) do |event|
      if !event.server.nil?
	server = event.server
	jurio = server.channels.select { |c| c.id == 468530420879720468 }[0]
	puts jurio.name
	puts event.user.name
        event.server.move(event.user, jurio)
      end
    end
  end
end
