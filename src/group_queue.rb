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

  def add_user(user)
    return false if user_in_queue? user
    users.add(user)
    print_add_user_to_queue user
    true
  end

  def remove_user(user)
    return false if !user_in_queue? user
    users.delete(user)
    true
  end

  def user_in_queue?(user)
    users.include? user
  end

  def full?
    users.size == group_size
  end

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
