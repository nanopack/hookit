module Hookit
  module Helper
    module XML
      
      def sanitize_xml_vars(vars)
        vars.inject({}) do |res, (key,value)|
          res[sanitize_xml_string(key.to_s)] = sanitize_xml_string(value.to_s)
          res
        end
      end

      protected

      def sanitize_xml_string(str)
        str = str.gsub(/&/, '&amp;')
        str = str.gsub(/</, '&lt;')
        str = str.gsub(/>/, '&gt;')
        str = str.gsub(/"/, '&quot;')
        str = str.gsub(/'/, '&apos;')
        str
      end

    end
  end
end