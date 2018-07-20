# frozen_string_literal: true

module Commands
  # description: 'Join a queue.'
  # useage: 'q!join queue_name',
  module Join
    extend Discordrb::Commands::CommandContainer
    command(
      :join,
      description: 'Join a queue.',
      useage: 'q!join queue_name',
      help_available: true
    ) do |event, queue_name|
      queues_manager = Commands.queues_manager
      i18n = $i18n
      return event.user.pm i18n[:queue_doesnt_exist] % queue_name unless
        queues_manager.queue_exists? queue_name
      added_user = queues_manager.add_user_to_queue queue_name, event.user

      message = added_user ? i18n[:registered_user] : i18n[:already_in_queue]
      puts message
      puts added_user

      event.user.pm(message)
    end
  end
end
