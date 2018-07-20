# frozen_string_literal: true

# Class to manage the bot's functions
class MatchMakingBot
  def initialize(bot_killer_char)
    @bot_killer_char = bot_killer_char
    listeners
  end

  def notify_queue_is_full(queue)
    users = queue.users
    message = format(i18n[:queue_full], users.length, queue.name)
    users.each { |user| message << "\n#{user.mention}" }
    message << "\n#{format(i18n[:join_this_voice_channel], queue.description)}"
    users.each { |user| user.pm message }
  end

  def listeners
    load_commands
    killer_char
  end

  def load_commands
    Dir['commands/*.rb'].each { |file| require_relative file }
    bot.include! Commands::Join
    bot.include! Commands::Queues
    bot.include! Commands::Status
    bot.include! Commands::Leave
  end

  def killer_char
    bot.message(content: bot_killer_char) do |event|
      puts i18n[:bot_killed] % bot_killer_char
      event.user.pm(i18n[:bot_killed] % bot_killer_char)
      bot.stop
    end
  end

  def run
    bot.run
  end

  def bot
    @bot ||= Discordrb::Commands::CommandBot.new token: ENV['BOT_TOKEN'],
                                                 client_id: ENV['CLIENT_ID'], prefix: 'q!'
  end

  def i18n
    @i18n ||= $i18n
  end

  attr_reader :bot_killer_char

  def queues_manager
    @queues_manager ||= $queues_manager
  end
end
