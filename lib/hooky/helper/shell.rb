module Hooky
  module Helper
    module Shell
      
      def sanitize_shell_vars(vars)
        vars.inject({}) do |res, (key,value)|
          res[escape_shell_string(key.to_s)] = escape_shell_string(value.to_s)
          res
        end
      end

      protected

      # strategy:
      # 1- escape the escapes
      # 2- escape quotes
      # 3- escape dollar signs
      def escape_shell_string(str)
        cmd.gsub!(/\\/, "\\\\\\")
        cmd.gsub!(/"/, "\\\"")
        cmd.gsub!(/`/, "\\`")
        cmd.gsub!(/\$/, "\\$")
        cmd
      end

    end
  end
end