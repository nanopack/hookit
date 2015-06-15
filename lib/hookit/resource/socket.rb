module Hookit
  module Resource
    class Socket < Base

      field :port
      field :interface
      field :service
      field :max_checks

      actions :listening, :no_connections, :reset
      default_action :listening

      def initialize(name)
        service name unless service
        max_checks 3 unless max_checks
        super
      end

      def run(action)
        case action
        when :listening
          check_listening!
        when :no_connections
          check_no_connections!
        when :reset
          reset!
        end
      end

      protected

      def check_listening!
        # increment check
        registry("#{service}.listening", registry("#{service}.listening").to_i + 1)

        if `netstat -an | grep '\*\.#{port}' | grep LISTEN`.empty?
          count = registry("#{service}.listening").to_i
          if count <= max_checks
            exit(count + 10)
          else
            $stderr.puts "ERROR: timed out waiting for #{service} to listen"
            exit(Hookit::Exit::ERROR)
          end
        end

      end

      def check_no_connections!
        # increment check
        registry("#{service}.no_connections", registry("#{service}.no_connections").to_i + 1)

        unless `netstat -an | grep 'ESTABLISHED' | awk '{ print $1 }' | grep "$(ifconfig #{interface} | grep inet | awk '{ print $2 }')\.#{port}"`.empty?
          count = registry("#{service}.no_connections").to_i
          if count <= max_checks
            exit(count + 10)
          end
        end
      end

      def reset!
        registry("#{service}.listening", 0)
        registry("#{service}.no_connections", 0)
      end

    end
  end
end