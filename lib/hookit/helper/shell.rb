module Hookit
  module Helper
    module Shell
      
      def sanitize_shell_vars(vars)
        vars.inject({}) do |res, (key,value)|
          res[escape_shell_string(key.to_s)] = escape_shell_string(value.to_s)
          res
        end
      end

      # strategy:
      # 1- escape the escapes
      # 2- escape quotes
      # 3- escape backticks
      # 4- escape semicolons
      # 5- escape ampersands
      # 6- escape pipes
      # 7- escape dollar signs
      # 8- escape spaces
      def escape_shell_string(str)
        str = str.gsub(/\\/, "\\\\\\")
        str = str.gsub(/"/, "\\\"")
        str = str.gsub(/`/, "\\`")
        str = str.gsub(/;/, "\\;")
        str = str.gsub(/&/, "\\&")
        str = str.gsub(/\|/, "\\|")
        str = str.gsub(/\$/, "\\$")
        str = str.gsub(/ /, "\\ ")
        str
      end

    end
  end
end