module Hookit
  module Error
    class MissingConfiguration < StandardError; end
    class UnexpectedExit < StandardError; end
    class UnknownAction < StandardError; end
    class UnsupportedPlatform < StandardError; end
    class UnsupportedOption < StandardError; end
  end
end