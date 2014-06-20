module Hooky
  module Resource
    class Package < Base

      field :package_name
      field :source
      field :version
      field :scope

      actions :install
      default_action :install

      def initialize(name)
        package_name(name) unless source
        scope :default unless scope
        super
      end

      def run(action)
        case action
        when :install
          install!
        end
      end

      def install!
        begin
          install_package
        rescue Hooky::Error::UnexpectedExit
          if not registry("pkgsrc.#{scope}.updated")
            update_pkg_db
            registry("pkgsrc.#{scope}.updated", true)
            retry
          else
            raise
          end
        end
      end

      protected

      def install_package
        `#{pkgin} -y in #{package}`

        code = $?.exitstatus
        if not code == 0
          raise Hooky::Error::UnexpectedExit, "pkgin in #{package} failed with exit code '#{code}'"
        end
      end

      def update_pkg_db
        `#{pkgin} -y up`
      end

      def package
        "#{package_name}#{if (version) ? "-#{version}" : '' }"
      end

      def pkgin
        case scope
        when :default
          "/opt/local/bin/pkgin"
        when :gopagoda
          "/opt/gopagoda/bin/pkgin"
        end
      end

    end
  end
end