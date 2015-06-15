module Hookit
  module Resource
    class File < Base

      field :path
      field :content
      field :mode
      field :owner
      field :group

      actions :create, :create_if_missing, :delete, :touch
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
        ::File.write path, (content || "")
      end

      def create_if_missing!
        if not ::File.exists? path
          create!
        end
      end

      def delete!
        ::File.delete path
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

      def touch!
        `touch -c #{path}`
      end

    end
  end
end