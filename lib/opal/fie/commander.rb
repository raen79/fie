require 'fie/native'
require 'diffhtml.min'

module Fie
  class Commander < Fie::Native::ActionCableChannel
    include Fie::Native

    def connected
      super

      @cable.call_remote_function \
        element: Element.body,
        function_name: 'initialize_state',
        event_name: 'Upload State',
        parameters: { view_variables: Util.view_variables }
    end

    def received(data)
      process_command(data['command'], data['parameters'])
    end

    def process_command(command, parameters = {})
      case command
      when 'refresh_view'
        $$.diff.innerHTML(Element.fie_body.unwrapped_element, parameters['html'])
        @event.dispatch
      when 'subscribe_to_pools'
        parameters['subjects'].each do |subject|
          @cable.subscribe_to_pool(subject)
        end
      when 'publish_to_pool'
        subject = parameters['subject']
        object = parameters['object']
        sender_uuid = parameters['sender_uuid']

        perform("pool_#{ subject }_callback", { object: object, sender_uuid: sender_uuid })
      when 'publish_to_pool_lazy'
        subject = parameters['subject']
        object = parameters['object']
        sender_uuid = parameters['sender_uuid']

        perform("pool_#{ subject }_callback", { object: object, sender_uuid: sender_uuid, lazy: true })
      when 'execute_function'
        Util.exec_js(parameters['name'], parameters['arguments'])
      else
        puts "Command: #{ command }, Parameters: #{ parameters }"
      end
    end
  end
end
