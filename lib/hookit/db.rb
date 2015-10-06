require 'oj'
require 'multi_json'
require 'fileutils'

module Hookit
  class DB
    
    DEFAULT_PATH = '/var/db/hookit/db.json'

    def initialize(path=nil)
      @path = path || DEFAULT_PATH
    end

    def fetch(key)
      data[key]
    end

    def put(key, value)
      data[key] = value
      save
    end

    def load
      ::MultiJson.load(::File.read(@path), symbolize_keys: true) rescue {}
    end

    def save
      ::FileUtils.mkdir_p(File.dirname(@path))
      ::File.write(@path, ::MultiJson.dump(data))
    end

    def data
      @data ||= load
    end

  end
end