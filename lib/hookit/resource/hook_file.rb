require 'shellwords'
      
module Hookit
  module Resource
    class HookFile < Base
      
      field :path
      field :source
      field :mode
      field :owner
      field :group

      actions :create, :create_if_missing, :delete, :touch
      default_action :create

      def initialize(name)
        path name unless path
        source ::File.basename(name)
        super
      end

      def run(action)
        case action
        when :create
          create!
          chown!
          chmod!            
        when :create_if_missing
          create_if_missing!
          chown!
          chmod!
        when :delete
          delete!
        when :touch
          touch!
        end
      end

      protected

      def create!
        begin
          ::File.write path, render
        rescue Exception => e
          unexpected_failure("create file", e.message)
        end
      end

      def create_if_missing!
        if not ::File.exists? path
          create!
        end
      end

      def delete!
        begin
          ::File.delete path
        rescue Exception => e
          unexpected_failure("delete file", e.message)
        end
      end

      def chown!
        return unless owner or group
        if ::File.exists? path
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

      def touch!
        run_command! "touch -c #{Shellwords.escape(path)}"
      end

      def render
        begin
          ::File.read("#{file_dir}/#{source}")
        rescue Exception => e
          print_error("read hook_file", {
            path: "#{file_dir}/#{source}",
            reason: e.message
          })
        end
      end

      def file_dir
        "#{module_root}/files"
      end

      def module_root
        dict[:module_root]
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
