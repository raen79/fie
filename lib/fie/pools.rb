module Fie
  class Pools < ActionCable::Channel::Base
    def subscribed
      stream_from Fie::Pools.pool_name(params[:identifier])
    end

    class << self
      def pool_name(subject)
        "pool_#{ subject }"
      end

      def publish_lazy(subject, object, sender_uuid)
        ActionCable.server.broadcast \
          Fie::Commander.commander_name(sender_uuid),
          command: 'publish_to_pool_lazy',
          parameters: {
            subject: subject,
            object: Marshal.dump(object).force_encoding(Encoding::UTF_8)
          }
      end

      def publish(subject, object, sender_uuid: nil)
        ActionCable.server.broadcast \
          pool_name(subject),
          command: 'publish_to_pool',
          parameters: {
            subject: subject,
            object: Marshal.dump(object).force_encoding(Encoding::UTF_8),
            sender_uuid: sender_uuid
          }
      end
    end
  end
end
