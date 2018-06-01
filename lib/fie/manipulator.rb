require 'fie/commander_closed'

module Fie
  class Manipulator
    class << self
      def state(connection_uuid)
        commander_name = Commander.commander_name(connection_uuid)

        if commander_exists?
          Marshal.load redis.get(commander_name)
        else
          raise Fie::CommanderClosed, commander_name
        end
      end

      private
        def redis
          $redis ||= Redis.new
        end
    end
  end
end
