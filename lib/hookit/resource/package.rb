module Hookit
  module Resource
    class Package < Base

      field :package_name
      field :source
      field :version
      field :scope

      actions :install, :update
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
        when :update
          update!
        end
      end

      def install!
        run_command! "#{pkgin} -y in #{package}"
      end
      
      def update!
        run_command! `#{pkgin} -y up`
      end

      protected

      def package
        if version
          "#{package_name}-#{version}"
        else
          package_name
        end
      end

      def pkgin
        case scope
        when :default
          "/opt/local/bin/pkgin"
        when :gopagoda
          "/opt/gopagoda/bin/pkgin"
        when :gonano
          "/opt/gonano/bin/pkgin"
        end
      end

    end
  end
end
