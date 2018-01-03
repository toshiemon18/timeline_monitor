# coding : utf-8

require "rubygems"
require "twitter"
require "./lib/user_id_manager"

module TimelineMonitor
  class TwitterUltils
    attr_accessor :client, :streaming_client
    def initialize
      config = {
        consumer_key: ENV["TWITTER_CONSUMER_KEY"],
        consumer_secret: ENV["TWITTER_CONSUMER_SECRET"],
        access_token: ENV["TWITTER_TOKEN"],
        access_token_secret: ENV["TWITTER_TOKEN_SECRET"]
      }
      generate_client(config)
    end

    def monitor_user(uid_list, &block)
      @streaming_client.filter(follow: uid_list) do |tweet|
        tweet_info = {
          text: tweet.text,
          screen_name: tweet.user.screen_name,
          url: tweet.url.to_s
        }
        yield tweet_info
      end
    end

    private
    def generate_client(keys)
      @streaming_client = Twitter::Streaming::Client.new(keys)
      @client = Twitter::REST::Client.new(keys)
    end
  end
end
