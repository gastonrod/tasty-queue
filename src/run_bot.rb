# frozen_string_literal: true

require 'bundler/setup'
require 'set'
require 'yaml'
load 'queues_manager.rb'
load 'internazionalization.rb'
load 'match_making_bot.rb'
load 'group_queue.rb'

Bundler.require
Dotenv.load('../.env')

$i18n = load_esp_i18n
queues_manager = QueuesManager.new

queues_manager.execute
