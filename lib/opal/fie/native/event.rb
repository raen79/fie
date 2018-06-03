require 'native'

module Fie
  module Native
    class Event
      include Native

      def initialize(event_name)
        @event_name = event_name
      end

      def dispatch
        Native(`document.dispatchEvent(new Event(#{ @event_name }))`)
      end
    end
  end
end
