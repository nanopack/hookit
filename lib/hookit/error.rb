module Hookit
  module Error
    class UnexpectedExit < StandardError; end
    class UnknownAction < StandardError; end
    class UnsupportedPlatform < StandardError; end
    class UnsupportedOption < StandardError; end
  end
end