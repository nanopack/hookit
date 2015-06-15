module Hookit
  module Helper
    module Cron
      
      MINUTES = 59
      HOURS   = 23
      DAYS    = 31
      MONTHS  = 12
      WEEKDAY = 7
      
      def sanitize_cron(cron)
      
        time = cron.split(' ')
        
        time[0] = compatible_cron(time[0],MINUTES)
        time[1] = compatible_cron(time[1],HOURS)
        time[2] = compatible_cron(time[2],DAYS, 1)
        time[3] = compatible_cron(time[3],MONTHS, 1)
        time[4] = compatible_cron(time[4],WEEKDAY)
      
        time.join(' ')
      end
      
      protected

      # converts */x cron format into solaris compatible format
      def compatible_cron(time, limit, start = 0)
        if time =~ /\//
          increment = time.split('/')[1].to_i
          x, y      = start, []
          for i in 0..limit/increment
            y[i] = x
            x    +=increment
          end
          time = y.join(',')
        end
        time
      end

    end
  end
end
