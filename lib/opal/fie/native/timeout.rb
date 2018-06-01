module Fie
  module Native
    class Timeout
      def initialize(time = 0, &block)
        @timeout = `setTimeout(#{block}, time)`
      end

      def clear
        `clearTimeout(#{@timeout})`
      end
    end
  end
end
