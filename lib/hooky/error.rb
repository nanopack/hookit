module Hooky
  module Error
    class UnexpectedExit < StandardError; end
    class UnknownAction < StandardError; end
    class UnsupportedPlatform < StandardError; end
  end
end