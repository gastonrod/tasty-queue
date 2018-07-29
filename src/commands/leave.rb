# frozen_string_literal: true

module Commands
  # description: 'Leave a queue.'
  # useage: 'q!leave queue_name',
  module Leave
    extend Discordrb::Commands::CommandContainer
    command(
      :leave,
      description: 'Leave a queue.',
      useage: 'q!leave queue_name',
      help_available: true
    ) do |event, queue_name|
      queues_manager = Commands.queues_manager
      i18n = $i18n
      return event.user.pm i18n[:queue_doesnt_exist] % queue_name if 
        !queues_manager.queue_exists?(queue_name) && queue_name != 'all'
      removed_user = queues_manager.remove_user_from_queue queue_name, event.user

      message = removed_user ? i18n[:removed_user] : i18n[:not_in_queue]
      puts message

      event.user.pm(message)
    end
  end
end
