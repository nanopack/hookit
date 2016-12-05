require 'shellwords'

module Hookit
  module Resource
    class Directory < Base

      field :path
      field :recursive
      field :mode
      field :owner
      field :group
      
      actions :create, :delete
      default_action :create

      def initialize(name)
        path name unless path
        super
      end

      def run(action)
        case action
        when :create
          create!
          chown!
          chmod!
        when :delete
          delete!
        end
      end

      protected

      def create!
        return if ::File.exists? path
        run_command! "mkdir #{"-p " if recursive}#{Shellwords.escape(path)}"
      end

      def delete!
        return if not ::File.exists? path
        run_command! "rm -rf #{Shellwords.escape(path)}"
      end

      def chown!
        return unless owner or group
        if ::File.exists? path
          cmd = "chown #{(group.nil?) ? owner : "#{owner}:#{group}"} #{Shellwords.escape(path)}"
          run_command! "chown #{(group.nil?) ? owner : "#{owner}:#{group}"} #{Shellwords.escape(path)}"
        end
      end

      def chmod!
        if ::File.exists? path and mode
          begin
            ::File.chmod(mode, path)
          rescue Exception => e
            unexpected_failure("chmod file", e.message)
          end
        end
      end

      def unexpected_failure(message, reason)
        print_error(message, {
          path: path,
          reason: reason
        })
      end

    end
  end
end
