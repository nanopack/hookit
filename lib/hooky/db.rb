require 'oj'
require 'multi_json'
require 'fileutils'

module Hooky
  class DB
    
    DEFAULT_PATH = '/var/db/hooky/db.json'

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
      ::MultiJson.load(::File.read(@path)) rescue {}
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