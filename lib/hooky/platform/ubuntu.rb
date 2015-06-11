module Hooky
  module Platform
    class Ubuntu < Base
      
      def detect?
        ! `[ -x /usr/bin/lsb_release ] && /usr/bin/lsb_release -i 2>/dev/null | grep Ubuntu`.empty?
      end

      def name
        'ubuntu'
      end

      def os
        'linux'
      end
      
    end
  end
end