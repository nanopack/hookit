module Hookit
  module Resource
    class Rsync < Base

      field :source
      field :destination
      field :wrapper
      field :archive
      field :recursive
      field :checksum
      field :compress

      actions :sync
      default_action :sync

      def initialize(name)
        source name unless source
        super
      end

      def run(action)
        case action
        when :sync
          sync!
        end
      end

      def sync!
        run_command! "rsync -q#{archive!}#{recursive!}#{checksum!}#{compress!} #{wrapper!} #{source} #{destination}"
      end

      def archive!
        (return "a") if archive
        ""
      end

      def recursive!
        (return "r") if archive
        ""
      end

      def checksum!
        (return "c") if archive
        ""
      end

      def compress!
        (return "z") if archive
        ""
      end

      def wrapper!
        (return "-e '#{wrapper}'") if wrapper
        ""
      end
    end
  end
end
