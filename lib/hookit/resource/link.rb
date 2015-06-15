module Hookit
  module Resource
    class Link < Base

      field :owner
      field :group
      field :link_type
      field :target_file
      field :to

      actions :create, :delete
      default_action :create

      def initialize(name)
        target_file name unless target_file
        link_type :symbolic
        super
      end

      def run(action)
        case action
        when :create
          create!
          chown!
        when :delete
          delete!
        end
      end

      protected

      def create!
        args = ['f']
        args << 'sn' if link_type == :symbolic
        cmd = "ln -#{args.join} #{to} #{target_file}"
        `#{cmd}`
        code = $?.exitstatus
        if code != 0
          raise Hookit::Error::UnexpectedExit, "#{cmd} failed with exit code '#{code}'"
        end
      end

      def delete!
        cmd = "rm -f #{target_file}"
        `#{cmd}`
        code = $?.exitstatus
        if code != 0
          raise Hookit::Error::UnexpectedExit, "#{cmd} failed with exit code '#{code}'"
        end
      end

      def chown!
        return unless owner or group
        if ::File.exists? target_file
          `chown #{(group.nil?) ? owner : "#{owner}:#{group}"} #{target_file}`
        end
      end

    end
  end
end