module Hooky
  module Resource
    class Service < Base

      field :recursive
      field :service_name

      actions :enable, :disable, :start, :stop, :restart, :reload
      default_action :enable

      def initialize(name)
        service_name(name) unless service_name
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
        run_command! "svcadm enable #{"-r" if recursive} #{service_name}"
      end

      def disable!
        run_command! "svcadm disable #{service_name}"
      end

      def restart!
        run_command! "svcadm restart #{service_name}"
      end

      def reload!
        run_command! "svcadm refresh #{service_name}"
      end

      def run_command!(cmd, expect_code=0)
        `#{cmd}`
        code = $?.exitstatus
        if code != expect_code
          raise Hooky::Error::UnexpectedExit, "#{cmd} failed with exit code '#{code}'"
        end
      end

    end
  end
end