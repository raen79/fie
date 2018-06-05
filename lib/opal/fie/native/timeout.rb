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

        begin
          @proc.call
        rescue Exception => exception
          puts exception.message
        end
      end
    end
  end
end
