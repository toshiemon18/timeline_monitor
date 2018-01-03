# coding ; utf-8

$:.unshift(File.join(File.dirname(__FILE__)))

require "slack-ruby-client"
require "logger"
require "./lib/db_define"
require "./lib/twitter"

include TimelineMonitor

CHANNEL_ID = "#{ENV["CHANNEL_ID"]}".freeze
CHANNEL_NAME = "#timeline_monitor"

Slack.configure do |config|
  config.token = ENV["SLACK_TOKEN"]
  config.logger = Logger.new("./logs/app.log")
  config.logger.level = Logger::WARN
  raise "Missing environment variable : SLACK_TOKEN" unless config.token
end

client = Slack::RealTime::Client.new

streaming_proc = Proc.new do
  uid_list = "580785994"#  << UserIdManager.new.fetch_uids
  twitter_client = TwitterStreamer.new
  twitter_client.monitor_user(uid_list) do |twh|
    puts "[#{Time.now}] Tweet received by #{twh[:screen_name]}"
    text = "#{twh[:screen_name]}\n#{twh[:text]}\n#{twh[:url]}"
    begin
      client.typing channel: CHANNEL_NAME
      result = client.web_client.chat_postMessage(channel: CHANNEL_NAME,
                                                  text: text,
                                                  as_user: true)
      puts "[#{Time.now}] Send message to Slack#{CHANNEL_NAME}"
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
end

client.start_async
streaming_thread.join

loop do
  Thread.pass
end
