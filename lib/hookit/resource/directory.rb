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
        cmd = "mkdir #{"-p " if recursive}#{path}"
        `#{cmd}`
        code = $?.exitstatus
        if code != 0
          raise Hookit::Error::UnexpectedExit, "#{cmd} failed with exit code '#{code}'"
        end
      end

      def delete!
        return if not ::File.exists? path
        cmd = "rm -rf #{path}"
        `#{cmd}`
        code = $?.exitstatus
        if code != 0
          raise Hookit::Error::UnexpectedExit, "#{cmd} failed with exit code '#{code}'"
        end
      end

      def chown!
        return unless owner or group
        if ::File.exists? path
          `chown #{(group.nil?) ? owner : "#{owner}:#{group}"} #{path}`
        end
      end

      def chmod!
        if ::File.exists? path and mode
          ::File.chmod(mode, path)
        end
      end

    end
  end
end