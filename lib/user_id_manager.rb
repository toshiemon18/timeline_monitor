# coding : utf-8

require "sequel"
require "pg"
require "logger"
require "./db_define.rb"

module TimelineMonitor
  class UserIdManager
    TABLE_NAME = :twitter_users

    def initialize
      TABLE_NAME.freeze
      user = ENV["PSQL_USER"]
      host = ENV["PSQL_HOST"]
      pass = ENV["PSQL_PASS"]
      name = ENV["PSQL_DB"]
      @db_url = "postgres://#{user}:#{pass}@#{host}:5432/#{name}"
      DBDefine.define_table(@db_url)
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
    def add_user(screen_name, uid)
      table = fetch_table
      table.insert(screen_name: screen_name.to_s, uid: uid.to_s)
    end

    private
    def fetch_db
      db = Sequel.connect(@db_url, logger: Logger.new("./logs/db.log"))
      db
    end

    def fetch_table
      db = fetch_db
      table = db[TABLE_NAME]
      db.disconnect
      table
    end
  end
end
