module Hookit
  module Resource
    class Cron < Execute

      def initialize(name)
        super
        timeout 60
        cwd '/data'
      end

      protected

      def run!
        begin
          Timeout::timeout(timeout) do
            f = IO.popen("#{cmd} || exit 0", :err=>[:child, :out])
            puts f.readline while true
          end
        rescue Timeout::Error
          print_error(name, {
            command: cmd,
            failure: "failed to return within #{timeout} seconds"
          })
        end
      end
      
    end
  end
end
