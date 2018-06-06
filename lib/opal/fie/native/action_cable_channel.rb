require 'fie/native'

module Fie
  module Native
    class ActionCableChannel
      def initialize(channel_name:, identifier:, cable:)
        @channel_name = channel_name
        @identifier = identifier
        @cable = cable
        @event = Event.new('fieChanged')

        @subscription = $$.App.cable.subscriptions.create(
          { channel: @channel_name, identifier: @identifier },
          {
            connected: -> { connected },
            received: -> (data) { received Native(`#{data}`) }
          }
        )
      end

      def responds_to?(t)
        true
      end

      def connected
        perform('initialize_pools')
        puts "Connected to #{ @channel_name } with identifier #{ @identifier }"
      end

      def perform(function_name, parameters = {})
        @subscription.perform(function_name, parameters);
      end
    end
  end
end
