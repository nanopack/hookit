require 'oj'
require 'multi_json'

module Hooky
  module Hook

    def payload
      @payload ||= parse_payload
    end

    def parse_payload
      if not ARGV.empty?
        MultiJson.load ARGV.first, symbolize_keys: true
      else
        {}          
      end
    end

    def converge(map, list)
      Converginator.new(map, list).converge!
    end

    def registry(key, value=nil)
      unless value.nil?
        db.put(key, value)
      else
        db.fetch(key)
      end
    end

    def db
      @db ||= Hooky::DB.new
    end

  end
end