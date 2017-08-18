# coding ; utf-8

require "twitter"

module TimelineMonitor
  class TLStreamer
    def initialize
      config = {
        consumer_key:        ENV["TWITTER_CONSUMER_KEY"],
        consumer_secret:     ENV["TWITTER_CONSUMER_SECRET"],
        access_token:        ENV["TWITTER_TOKEN"],
        access_token_secret: ENV["TWITTER_TOKEN_SECRET"]
      }
      @client = generate_client(config)
    end



    private
    def generate_client(keys)
      client = Twitter::Streaming::Client.new(keys)
    end
  end
end
