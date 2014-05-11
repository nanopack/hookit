module Hooky
  module Resource
    class Scp < Base

      field :source
      field :destination
      field :port
      field :recursive
      field :config
      field :cipher
      field :identity
      field :ssh_options
      field :compression
      field :preserve

      actions :copy
      default_action :copy

      def initialize(name)
        source(name) unless source
        preserve(true) unless preserve
        recursive(true) unless recursive
        super
      end

      def run(action)
        case action
        when :copy
          copy!
        end
      end

      def copy!
        run_command!("scp -q#{preserve!}#{recursive!}B#{compression!} #{config!} #{port!} #{cipher!} #{identity!} #{ssh_options!} #{source} #{destination}")
      end

      def cipher!
        (return "-c #{cipher}") if cipher
        ""
      end

      def compression!
        (return "C") if compression
        ""
      end

      def config!
        (return "-F #{config}") if config
        ""
      end

      def identity!
        (return "-i #{identity}") if identity
        ""
      end

      def port!
        (return "-P #{port}") if port
        ""
      end

      def preserve!
        (return "p") if preserve
        ""
      end

      def recursive!
        (return "r") if recursive
        ""
      end

      def ssh_options!
        (return "-o #{ssh_options}") if ssh_options
        ""
      end

      def run_command!(cmd, expect_code=0)
        `#{cmd}`
        code = $?.exitstatus
        if code != expect_code
          raise Hooky::Error::UnexpectedExit, "#{cmd} failed with exit code '#{code}'"
        end
      end

    end
  end
end
