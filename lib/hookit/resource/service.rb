module Hookit
  module Resource
    class Service < Base

      field :recursive
      field :service_name
      field :init

      actions :enable, :disable, :start, :stop, :restart, :reload
      default_action :enable

      def initialize(name)
        service_name(name) unless service_name

        # if init scheme is not provided, try to set reasonable defaults
        if not init
          case platform.name
          when 'smartos'
            init(:smf)
          when 'ubuntu'
            init(:upstart)
          when 'docker'
            init(:runit)
          end
        end
      end

      def run(action)
        case action
        when :enable
          enable!
        when :disable
          disable!
        when :start
          enable!
        when :stop
          disable!
        when :restart
          restart!
        when :reload
          reload!
        end
      end

      protected

      def enable!
        case init
        when :smf
          run_command! "svcadm enable -s #{"-r" if recursive} #{service_name}"
        when :runit
          # register and potentially start the service
          run_command! "sv start #{service_name}", false

          # runit can take up to 5 seconds to register the service before the
          # service starts to run. We'll keep checking the status for up to 
          # 6 seconds, after which time we'll raise an exception.
          registered = false

          6.times do
            # check the status
            `sv status #{service_name}`
            if $?.exitstatus == 0
              registered = true
              break
            end

            sleep 1
          end

          if registered
            # just in case the service is registered but not started, try
            # to start the service one more time
            run_command! "sv start #{service_name}"
          end
        end
      end

      def disable!
        case init
        when :smf
          run_command! "svcadm disable -s #{service_name}"
        when :runit
          run_command! "sv stop #{service_name}"
        end
      end

      def restart!
        case init
        when :smf
          run_command! "svcadm restart #{service_name}"
        when :runit
          disable!; enable!
        end
      end

      def reload!
        case init
        when :smf
          run_command! "svcadm refresh #{service_name}"
        end
      end

    end
  end
end
