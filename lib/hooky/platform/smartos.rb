module Hooky
  module Platform
    class Smartos < Base
      
      def detect?
        ! `cat /etc/release 2>/dev/null | grep -i SmartOS`.empty? 
      end

      def name
        'smartos'
      end

      def os
        'sun'
      end

    end
  end
end