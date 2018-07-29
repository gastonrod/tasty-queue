# frozen_string_literal: true

# Class that implements the queue.
# Keeps track of users, its name, etc.
class GroupQueue
  def initialize(name, params)
    @name = name
    @group_size = params['group_size']
    @description = params['description']
    @users = Set[]
  end

  # Add user to this queue.
  # @param [Discordrb::User] The user to add.
  # @return [Boolean] Whether the user was added or not.
  def add_user(user)
    return false if user_in_queue? user
    users.add(user)
    print_add_user_to_queue user
    true
  end


  # Add a set of users to this queue.
  # @param [Set<Discordrb::User>] The users to add.
  # @return [Boolean] Whether every user was added or not.
  def add_users(users_to_add)
    return false if users.size != (users - users_to_add).size
    users.add(users_to_add).flatten!
    puts users
    true
  end

  # Remove a user from this queue.
  # @param [Discordrb::User] The user to remove.
  # @return [Boolean] Whether the user was removed or not.
  def remove_user(user)
    return false unless user_in_queue? user
    users.delete(user)
    true
  end

  # Check if the user is in this queue or not.
  def user_in_queue?(user)
    users.include? user
  end

  # Get the amount of users subscribed to this queue.
  def size
    users.size
  end

  # Check if the queue has filled up.
  def full?
    users.size == group_size
  end

  # Check if the queue is empty
  def empty?
    users.empty?
  end

  # Empty out the queue.
  def empty!
    print_full_queue
    users.clear
  end

  def print_full_queue
    puts "Se lleno la cola '#{name}', avisandoles a todos y flusheando."
  end

  def print_add_user_to_queue(user)
    puts 'Recibi un mensaje del usuario ' + user.username
    puts 'Por ahora vamos: '
    users.map { |u| puts "  #{u.username}" }
  end

  def i18n
    @i18n ||= $i18n
  end

  attr_reader :name

  attr_reader :group_size

  attr_reader :users

  attr_reader :description
end
