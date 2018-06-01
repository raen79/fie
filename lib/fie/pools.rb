module Fie
  class Pools < ActionCable::Channel::Base
    def subscribed
      stream_from Pools.pool_name(params[:identifier])
    end

    class << self
      def pool_name(subject)
        "pool_#{subject}"
      end

      def publish(subject, object)
        ActionCable.server.broadcast \
          pool_name(subject),
          command: 'publish_to_pool',
          parameters: {
            subject: subject,
            object: Marshal.dump(object)
          }
      end
    end
  end
end
