# coding : utf-8

require "sequel"
require "pg"
require "logger"

module TimelineMonitor
  class UserIdManeger
    def initialize
      user = ENV["PSQL_USER"]
      host = ENV["PSQL_HOST"]
      pass = ENV["PSQL_PASS"]
      name = ENV["PSQL_DB"]
      @db_url = "postgres://#{user}:#{pass}@#{host}:5432/#{name}"
    end

    # fetch_uids
    # @return [String] 対象となるユーザのidをカンマ区切りにした文字列
    def fetch_uids
      table = fetch_table
      uids = []
      table.select(:uid).each {|row| uids.push row[:uid] }
      uids.join(",")
    end

    # add_uid
    # @param [String] screen_name 追加するユーザのスクリーンネーム
    # @params [String,Integer] uid 追加するユーザのuid
    def add_uid(screen_name, uid)
      table = fetch_table
      table.insert(screen_name: screen_name.to_s, uid: uid.to_s)
    end

    private
    def fetch_db
      db = Sequel.connect(@db_url, logger: Logger.new("./logs/db.log"))
      db
    end

    def fetch_table(table_name=:twitter_users)
      db = fetch_db
      table = db[table_name]
      db.disconnect
      table
    end
  end
end
