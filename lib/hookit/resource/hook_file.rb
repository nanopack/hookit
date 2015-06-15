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
        ::File.write path, render
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
        `chown #{(group.nil?) ? owner : "#{owner}:#{group}"} #{path}`
      end

      def chmod!
        ::File.chmod(mode, path) if mode
      end

      def touch!
        `touch -c #{path}`
      end

      def render
        ::File.read("#{file_dir}/#{source}")
      end

      def file_dir
        "#{module_root}/files"
      end

      def module_root
        dict[:module_root]
      end

    end
  end
end