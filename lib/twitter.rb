# coding : utf-8

require "twitter"
require "./lib/user_id_manager"

module TimelineMonitor
  class TwitterStreamer
    def initialize
      config = {
        consumer_key: ENV["TWITTER_CONSUMER_KEY"],
        consumer_secret: ENV["TWITTER_CONSUMER_SECRET"],
        access_token: ENV["TWITTER_TOKEN"],
        access_token_secret: ENV["TWITTER_TOKEN_SECRET"]
      }
      @client = generate_client(config)
    end

    def monitor_user(uid_list, &block)
      @client.filter(follow: uid_list) do |tweet|
        tweet_info = {
          text: tweet.text.text,
          screen_name: tweet.user_screen_name,
          url: tweet.url.to_s
        }
        yield tweet_info
      end
    end

    private
    def generate_client(keys)
      client = Twitter::Streaming::Client.new(keys)
    end
  end
end
