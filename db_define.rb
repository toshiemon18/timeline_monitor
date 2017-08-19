# coding : utf-8

require "sequel"
require "pg"

module TimelineMonitor
  module DBDefine
    def run
      define if db_exists?
    end

    def db_exists?
      db_exists = File.exists?("./db/twitter_users.db")
    end

    def define
      db = Sequel.
    end
  end
end
