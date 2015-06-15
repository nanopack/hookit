require 'oj'
require 'multi_json'

module Hookit
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
      @db ||= Hookit::DB.new
    end

    def dict
      @dict ||= {}
    end
    
    def set(key, value)
      dict[key] = value
    end

    def get(key)
      dict[key]
    end

    def log(level, message)
      logger.log level, message
    end

    def logger
      @logger ||= Hookit::Logger.new(get(:logfile), get(:log_level))
    end

    def logvac
      @logvac ||= Hookit::Logvac.new({
        app:    payload[:app][:id],
        token:  payload[:app][:logvac_token],
        deploy: payload[:deploy][:id]
      })
    end

    def platform
      @platform ||= detect_platform
    end

    def detect_platform
      Hookit.platforms.each do |key, value|
        platform = value.new
        if platform.detect?
          return platform
        end
      end
      false
    end

    # awesome resource-backed dsl
    def method_missing(method_symbol, *args, &block)
      resource_klass = Hookit.resources.get(method_symbol)
      if resource_klass
        resource = resource_klass.new(*args)
        resource.dict = dict
        resource.instance_eval(&block) if block_given?
        if resource.can_run?
          actions = resource.action
          if actions.length > 1
            res = {}
            actions.each do |action|
              res[action] = resource.run action
            end
            res
          else
            resource.run actions.first
          end
        end
      else
        super
      end
    end

  end
end