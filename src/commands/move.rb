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
      unless event.server.nil?
        server = event.server
        jurio = server.channels.select { |c| c.id == 468_530_420_879_720_468 }[0]
        puts jurio.name
        puts event.user.name
        event.server.move(event.user, jurio)
      end
    end
  end
end
