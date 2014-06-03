module Hooky
  module DSL

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
      @logger ||= Hooky::Logger.new
    end

    def method_missing(method_symbol, *args, &block)
      resource_klass = Hooky.resources.get(method_symbol)
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