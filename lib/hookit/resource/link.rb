require 'shellwords'

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
        run_command! "ln -#{args.join} #{Shellwords.escape(to)} #{Shellwords.escape(target_file)}"
      end

      def delete!
        run_command! "rm -f #{Shellwords.escape(target_file)}"
      end

      def chown!
        return unless owner or group
        if ::File.exists? target_file
          run_command! "chown #{(group.nil?) ? owner : "#{owner}:#{group}"} #{Shellwords.escape(target_file)}"
        end
      end
    end
  end
end
