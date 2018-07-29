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
      add_user_and_respond(event.user, queue_name, i18n, queues_manager)
    end

    def self.add_user_and_respond(user, queue_name, i18n, queues_manager)
      added_user = queues_manager.add_user_to_queue queue_name, user
      add_user_enum = Commands::ADD_USER_ENUM
      message = ''
      case added_user
        when add_user_enum[:filled_up_queue]
          return
        when add_user_enum[:added]
          message =  i18n[:registered_user] % queues_manager.get_queue_description(queue_name)
        when add_user_enum[:already_in_queue]
          message = i18n[:already_in_queue]
        when add_user_enum[:cant_join_any]
          message = i18n[:cant_join_any] 
      end
      puts message
      user.pm(message)
    end
  end
end
