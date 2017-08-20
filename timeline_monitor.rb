# coding ; utf-8

require "slack-ruby-client"
require "logger"
require "./lib/db_define"
require "./lib/twitter"
require "./lib/user_id_manager"

inlcude TimelineMonitor

CHANNEL_ID = "#{ENV["CHANNEL_ID"]}".freeze
CHANNEL_NAME = "#timeline_monitor"

Slack.configure do |config|
  config.token = ENV["SLACK_TOKEN"]
  config.logger = Logger.new("./logs/app.log")
  config.logger.level = Logger::INFO
  fail "Missing environment variable : SLACK_TOKEN" unless config.token
end

client = Slack::RealTime::Client.new

streaming_proc = Proc.new do
  uid_manager = UserIdManager.new
  uid_list = uid_manager.fetch_uids
  twitter_client = TwitteStreamer.new

  twitter_client.monitor_user(uid_list) do |tweethash|
    text = "#{screen_name}\n#{text}\n#{url}"
    begin
      result = client.web_client.chat_postMessage(channel: CHANNEL_NAME,
                                                  as_user: false,
                                                  text: text)
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
end

client.start_async
streaming_thread.join

loop do
  Thread.pass
end
