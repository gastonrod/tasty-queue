# frozen_string_literal: true

# Class to manage the bot's functions
class MatchMakingBot
  # Start the bot
  # @param bot_killer_char [String] Ultra-secret char that stops the bot gracefully.
  # Obviously this should be a command for someone with high privileges, but this is
  # easier for now.
  def initialize(bot_killer_char)
    @bot_killer_char = bot_killer_char
    listeners
  end

  # Let all the users in a queue know that their queue is full and they are ready to play!
  # @param queue [GroupQueue] Queue that has filled up.
  def notify_queue_is_full(queue)
    users = queue.users
    message = format(i18n[:queue_full], users.length, queue.description)
    users.each { |user| message << "\n#{user.mention}" }
    message << "\n#{format(i18n[:join_this_voice_channel], queue.description)}"
    users.each { |user| user.pm message }
  end

  # Start the bot.
  def run
    bot.run
  end
  
  private

  # Load all the bot's commands and set up it's killer char listener.
  def listeners
    load_commands
    killer_char
  end

  # Load all the commands. There has to be a better way to do this.
  def load_commands
    Dir['commands/*.rb'].each { |file| require_relative file }
    bot.include! Commands::Join
    bot.include! Commands::Queues
    bot.include! Commands::Status
    bot.include! Commands::Leave
    bot.include! Commands::Move
  end

  # Set up the listener to kill the bot when the bot killer char is received.
  def killer_char
    bot.message(content: bot_killer_char) do |event|
      puts i18n[:bot_killed] % bot_killer_char
      event.user.pm(i18n[:bot_killed] % bot_killer_char)
      bot.stop
    end
  end

  # Instantiate the CommandBot
  def bot
    @bot ||= Discordrb::Commands::CommandBot.new token: ENV['BOT_TOKEN'],
                                                 client_id: ENV['CLIENT_ID'], prefix: 'q!'
  end

  def i18n
    @i18n ||= $i18n
  end

  attr_reader :bot_killer_char
end
