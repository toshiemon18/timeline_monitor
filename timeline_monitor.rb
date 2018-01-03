# coding ; utf-8

$:.unshift(File.join(File.dirname(__FILE__)))

require "slack-ruby-client"
require "logger"
require "./lib/db_define"
require "./lib/twitter_utils"

include TimelineMonitor

CHANNEL_ID = "#{ENV["CHANNEL_ID"]}".freeze
CHANNEL_NAME = "#timeline_monitor"

Slack.configure do |config|
  config.token = ENV["SLACK_TOKEN"]
  config.logger = Logger.new("./logs/app.log")
  config.logger.level = Logger::WARN
  raise "Missing environment variable : SLACK_TOKEN" unless config.token
end

slack_client = Slack::RealTime::Client.new
twitter_utils = TwitterUltils.new
twitter_client = twitter_utils.client

streaming_proc = Proc.new do
  uid_list = "580785994" << UserIdManager.new.fetch_uids
  puts "[#{Time.now}][Success] Successfully connect to Twitter streaming API."
  twitter_utils.monitor_user(uid_list) do |twh|
    puts "[#{Time.now}] Tweet received by #{twh[:screen_name]}"
    text = "#{twh[:screen_name]}\n#{twh[:text]}\n#{twh[:url]}"
    begin
      slack_client.typing channel: CHANNEL_NAME
      result = slack_client.web_client.chat_postMessage(channel: CHANNEL_NAME,
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
slack_client.on :hello do
  puts "[#{Time.now}][Success] Successfully connect to Slack RealTime API."
end

slack_client.on :clos do
  puts "[#{Time.now}] Disconnect."
end

slack_client.on :message do |data|
  puts data.text
  case data.text
  # Botのヘルプ表示
  # いるか..？
  when "help" then
    slack_client.message(channel: data.channel,
                   text: "監視したいユーザのScreen Nameのみをpostしてください.")
  # ヘルプ以外であればTwitterのSNとして扱う
  else
    begin
      # ツイートがSpace区切りであればreject, 再送を要求
      if data.text.split(" ").size > 1
        slack_client.message(channel: data.channel,
                       text: "Screen nameのみを送ってください")
      # それ以外であればTwitterのユーザを検索
      else
        # ユーザIDの登録とstreamingスレッドの再起動
        uid = twitter_client.user(data.text).id
        UserIdManager.new.add_user(data.text, uid)
        puts "[#{Time.now}][Success] Register new account"
        streaming_thread.kill
        streaming_thread = Thread.new { streaming_proc.call }
      end
    rescue => e
      # ユーザが存在しない場合の処理
      if e.class == Twitter::Error::NotFound
        slack_client.message(channel: data.channel,
                             text: "#{data.text}というユーザは存在しないようです.")
      # 上記以外は怪しいのでslackにtraceを投げる
      else
        slack_client.message(channel: data.channel,
                             text: "[#{Time.now}] System error : #{e.message}")
        puts "[#{Time.now}] System error : #{e.message}"
      end
    end
  end
end

slack_client.start_async
streaming_thread.join

loop do
  Thread.pass
end
