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
        Tilt.new("#{template_dir}/#{source}").render(self, variables)
      end

      def template_dir
        "#{module_root}/templates"
      end

      def module_root
        dict[:module_root]
      end

    end
  end
end