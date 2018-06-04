require 'fie/commander_closed'
require 'redis'

module Fie
  module Manipulator
    def state
      commander_name = Commander.commander_name(@fie_connection_uuid)

      if commander_exists?(commander_name)
        Marshal.load redis.get(commander_name)
      else
        raise Fie::CommanderClosed, commander_name
      end
    end

    def execute_js_function(name, *arguments)
      commander_name = Commander.commander_name(@fie_connection_uuid)

      if commander_exists?(commander_name)
        ActionCable.server.broadcast \
          commander_name,
          command: 'execute_function',
          parameters: {
            name: name,
            arguments: arguments
          }
      end
    end

    private
      def commander_exists?(commander_name)
        !redis.get(commander_name).nil?
      end
      
      def redis
        $redis ||= Redis.new
      end
  end
end
