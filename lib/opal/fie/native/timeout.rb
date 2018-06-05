module Fie
  module Native
    class Timeout
      def initialize(time = 0, &block)
        @proc = block
        @timeout = `setTimeout(#{block}, time)`
      end

      def clear
        `clearTimeout(#{@timeout})`
      end

      def fast_forward
        `clearTimeout(#{@timeout})`
        @proc.call
      end
    end
  end
end
