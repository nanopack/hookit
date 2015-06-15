module Hookit
  module Resource
    class Logrotate < Base

      field :path
      field :filesize
      field :max_size
      field :count

      actions :create
      default_action :create

      def initialize(name)
        path name unless path
        super
      end

      def run(action)
        case action
        when :create
          create!
        end
      end

      protected

      def create!
        case platform.os
        when 'sun'
          `logadm -c -w #{path} -s #{filesize ||= '10m'} -S #{max_size ||= '500m'} -C #{count ||= '10'} -N`
        else
          raise Hookit::Error::UnsupportedPlatform, "unsupported platform '#{platform.name}'"
        end
      end

    end
  end
end