# coding : utf-8

require "sequel"
require "pg"

module TimelineMonitor
  module DBDefine
    def self.define_table(db_url)
      db = Sequel.connect(db_url, logger: Logger.new("./logs/db.log"))
      db.create_table? :twitter_users do
        primary_key :id
        String      :screen_name
        String      :uid
      end
      db.disconnect
    end
  end
end
