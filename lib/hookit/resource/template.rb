require 'tilt'
require 'erubis'
require 'erb'
require 'oj'
require 'multi_json'

module Hookit
  module Resource
    class Template < Base
      
      field :path
      field :source
      field :variables
      field :mode
      field :owner
      field :group

      actions :create, :create_if_missing, :delete, :touch
      default_action :create

      def initialize(name)
        path name unless path
        source "#{::File.basename(name)}.erb"
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
          run_command! "chown #{(group.nil?) ? owner : "#{owner}:#{group}"} #{path}"
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
        run_command! "touch -c #{path}"
      end

      def render
        begin
          Tilt.new("#{template_dir}/#{source}").render(self, variables)
        rescue Exception => e
          unexpected_failure("render template", e.message)
        end
      end

      def template_dir
        "#{module_root}/templates"
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
