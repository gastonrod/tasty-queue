# frozen_string_literal: true

module Commands
  # description: 'List all the available queues.',
  module Queues
    extend Discordrb::Commands::CommandContainer
    command(
      :queues,
      description: 'List all the available queues.',
      useage: 'q!queues',
      help_available: true
    ) do |event|
      event.user.pm($i18n[:available_queues])
    end
  end
end
