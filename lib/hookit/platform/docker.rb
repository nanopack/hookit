module Hookit
  module Platform
    class Docker < Base
      
      def detect?
        ! `cat /proc/self/cgroup 2>/dev/null | grep docker`.empty? 
      end

      def name
        'docker'
      end

      def os
        'linux'
      end

    end
  end
end