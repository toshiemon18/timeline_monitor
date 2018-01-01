# coding ; utf-8

require "slack-ruby-client"
require "logger"
require "./lib/db_define"
require "./lib/twitter"

inlcude TimelineMonitor

CHANNEL_ID = "#{ENV["CHANNEL_ID"]}".freeze
CHANNEL_NAME = "#timeline_monitor"

Slack.configure do |config|
  config.token = ENV["SLACK_TOKEN"]
  config.logger = Logger.new("./logs/app.log")
  config.logger.level = Logger::INFO
  raise "Missing environment variable : SLACK_TOKEN" unless config.token
end

client = Slack::RealTime::Client.new

streaming_proc = Proc.new do
  uid_list = UserIdManager.new.fetch_uids
  twitter_client = TwitteStreamer.new

  twitter_client.monitor_user(uid_list) do |twh|
    text = "#{twh[:screen_name]}\n#{twh[:text]}\n#{twh[:url]}"
    begin
      result = client.message(channel: CHANNEL_NAME, text: text)
    rescue => e
      puts "[#{Time.now}] [Sending message error] #{e.message}"
    end
  end
end
# ツイートを受信/slackへ送信するスレッド
streaming_thread = Thread.new { streaming_proc.call }

# 起動時の処理
client.on :hello do
  puts "[#{Time.now}][Success] Successfully connection."
end

client.on :message do |data|
  #TODO : Implementation!!!!!
  message = data.text.split(" ")
  if message.size < 2
  else
    command = message[0]
    argument = message[1]
  end
end

client.start_async
streaming_thread.join

loop do
  Thread.pass
end
