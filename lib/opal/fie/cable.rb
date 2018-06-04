require 'securerandom'
require 'fie/native'
require 'json'

module Fie
  class Cable
    include Fie::Native

    def initialize
      connection_uuid = SecureRandom.uuid
      commander_name = "#{ camelize(controller_name) }Commander"

      @commander = Commander.new(channel_name: commander_name, identifier: connection_uuid, cable: self)
      @pools = {}
    end

    def call_remote_function(element:, event_name:, function_name:, parameters:)
      log_event(element: element, event_name: event_name, function_name: function_name, parameters: parameters)

      function_parameters = {
        caller: {
          id: element.id,
          class: element.class_name,
          value: element.value
        },
        controller_name: controller_name,
        action_name: action_name
      }.merge(parameters)

      @commander.perform(function_name, function_parameters)
    end

    def subscribe_to_pool(subject)
      @pools['subject'] = Pool.new(channel_name: 'Fie::Pools', identifier: subject, cable: self)
    end

    def commander
      @commander
    end

    private
      def log_event(element:, event_name:, function_name:, parameters:)
        parameters = parameters.to_json
        puts "Event #{ event_name } triggered by element #{ element.descriptor } is calling function #{ function_name } with parameters #{ parameters }"
      end

      def action_name
        view_name_element['fie-action']
      end

      def controller_name
        view_name_element['fie-controller']
      end

      def view_name_element
        Element.body.query_selector('[fie-controller]:not([fie-controller=""])');
      end

      def camelize(string)
        string.split('_').collect(&:capitalize).join
      end
  end
end
