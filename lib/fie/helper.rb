module Fie
  module Helper
    def redis
      @redis ||= if ENV['REDIS_URL']
        Redis.new
      else
        ActionCable.server.pubsub.redis_connection_for_subscriptions.dup
      end
    end
  end
end
