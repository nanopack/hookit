module Hooky
  class Logger
    
    def log(level, message)

      if not message
        message = level
        level   = :error
      end

      if level_to_int(level) =< level_to_int(log_level)
        send(level, message)
      end

    end

    def error(message)
      log! "[error]: #{message}\n"
    end

    def warn(message)
      log! "[warn]: #{message}\n"
    end

    def info(message)
      log! "[info]: #{message}\n"
    end

    def debug(message)
      log! "[debug]: #{message}\n"
    end

    protected

    def log!(message)
      File.open logfile, 'a'  do |f| 
        f.write message
      end
    end

    def logfile
      dict[:logfile] || '/var/log/hooky/hooky.log'
    end

    def level_to_int(level)
      case level
      when :error then 1
      when :warn  then 2
      when :info  then 3
      when :debug then 4
      end
    end

    def log_level
      dict[:log_level] || :error
    end

  end
end