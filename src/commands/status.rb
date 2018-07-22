
module Commands
  # description: 'Check the status of the queues you are signed up to'
  # useage: 'q!status',
  # Tells you every user per queue, and its %
  module Status
    extend Discordrb::Commands::CommandContainer
    command(
      :status,
      description: 'Check the status of the queues you are signed up to',
      useage: 'q!status',
      help_available: true
    ) do |event|
      queues_manager = Commands.queues_manager
      user = event.user
      queues = queues_manager.queues_this_user_is_in user
      i18n = $i18n

      message = i18n[:queue_status]
      return user.pm(i18n[:not_signed_up_in_any_queue]) if queues.nil? || queues.empty?
      queues.each do |queue|
        other_users = queue.users
        users_mentions = ''
        other_users.each { |u| users_mentions << ' ' << u.mention }
        message = message + "\n" + format(i18n[:for_this_queue], queue.description) + users_mentions +
          " [#{queue.users.size}/#{queue.group_size}]"
      end
      puts message
      user.pm(message)
    end
  end
end
