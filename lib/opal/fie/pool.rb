require 'fie/native'

module Fie
  class Pool < Fie::Native::ActionCableChannel
    def received(data)
      @cable.commander.process_command(data['command'], data['parameters'])
    end
  end
end
