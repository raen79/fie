require 'fie/native'

module Fie
  class Listeners
    include Fie::Native

    def initialize(cable)
      @cable = cable

      initialize_input_elements
      initialize_fie_events [:click, :submit, :scroll, :keyup, :keydown]
    end

    private
      def initialize_fie_events(event_names)
        event_names.each do |event_name|
          Element.fie_body.add_event_listener(event_name, "[fie-#{ event_name }]:not([fie-#{ event_name }=''])") do |event|
            element = Element.new(element: event.target)
            remote_function_name = element["fie-#{ event_name }"]
            function_parameters = JSON.parse(element['fie-parameters'] || {})

            @cable.call_remote_function \
              element: element,
              function_name: remote_function_name,
              event_name: event_name,
              parameters: function_parameters
          end
        end
      end

      def initialize_input_elements
        timer = Timeout.new(0) { }

        typing_input_types = ['text', 'password', 'search', 'tel', 'url']

        typing_input_selector = (['textarea'] + typing_input_types).reduce do |selector, input_type|
          selector += ", input[type=#{ input_type }]"
        end

        non_typing_input_selector = (['input'] + typing_input_types).reduce do |selector, input_type|
          selector += ":not([type=#{ input_type }])"
        end

        Element.fie_body.add_event_listener('keydown', typing_input_selector) do |event|
          timer.clear

          input_element = Element.new(element: event.target)

          timer = Timeout.new(500) do
            update_state_using_changelog(input_element)
          end
        end

        Element.fie_body.add_event_listener('change', non_typing_input_selector) do |event|
          input_element = Element.new(element: event.target)
          update_state_using_changelog(input_element)
        end
      end

      def update_state_using_changelog(input_element)
        objects_changelog = {}

        changed_object_name = Regexp.new('(?:^|])([^[\\]]+)(?:\\[|$)').match(input_element.name)[0][0..-2]
        changed_object_key_chain = input_element.name.scan(Regexp.new '(?<=\\[).+?(?=\\])')

        is_form_object = !changed_object_key_chain.nil? && !changed_object_name.nil?
        is_fie_nested_object = Util.view_variables.include? changed_object_name
        is_fie_form_object = is_form_object && is_fie_nested_object

        is_fie_non_nested_object = Util.view_variables.include? input_element.name

        if is_fie_form_object
          build_changelog(changed_object_key_chain, changed_object_name, objects_changelog, input_element)
        elsif is_fie_non_nested_object
          objects_changelog[input_element.name] = input_element.value;
        end

        @cable.call_remote_function \
          element: input_element,
          function_name: 'modify_state_using_changelog',
          event_name: 'Input Element Change',
          parameters: { objects_changelog: objects_changelog }
      end

      def build_changelog(object_key_chain, object_name, changelog, input_element)
        is_final_key = -> (key) { key == object_key_chain[-1] }
        object_final_key_value = input_element.value
        
        changelog[object_name] = {}
        changelog = changelog[object_name]

        object_key_chain.each do |key|
          if is_final_key.call(key)
            changelog[key] = object_final_key_value
          else
            changelog[key] = {}
            changelog = changelog[key]
          end
        end
      end
  end
end
