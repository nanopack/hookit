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
          run_command! "sv start #{service_name}"
        else
          Hookit::Error::UnsupportedOption, "Unsupported init schema '#{init}'"
        end
      end

      def disable!
        case init
        when :smf
          run_command! "svcadm disable -s #{service_name}"
        when :runit
          run_command! "sv stop #{service_name}"
        else
          Hookit::Error::UnsupportedOption, "Unsupported init schema '#{init}'"
        end
      end

      def restart!
        case init
        when :smf
          run_command! "svcadm restart #{service_name}"
        when :runit
          disable!; enable!
        else
          Hookit::Error::UnsupportedOption, "Unsupported init schema '#{init}'"
        end
      end

      def reload!
        case init
        when :smf
          run_command! "svcadm refresh #{service_name}"
        else
          Hookit::Error::UnsupportedOption, "Unsupported init schema '#{init}'"
        end
      end

    end
  end
end