require 'native'

module Fie
  module Native
    class Element
      include Native

      def initialize(element: nil, selector: nil)
        if selector.nil?
          @element = element
        elsif element.nil?
          if selector == 'document'
            @element = $$.document
          else
            @element = $$.document.querySelector(selector)
          end        
        end
      end

      def [](name)
        @element.getAttribute(name)
      end

      def []=(name, value)
        @element.getAttribute(name, value)
      end

      def add_event_listener(event_name, selector = nil, &block)
        @element.addEventListener(event_name) do |event|
          event = Native(`#{ event }`)

          if selector.nil?
            block.call(event)
          else
            if event.target.matches(selector)
              block.call(event)
            end            
          end
        end
      end

      def query_selector(selector)
        Element.new(element: @element.querySelector(selector))
      end

      def query_selector_all(selector)
        entries = Native(`Array.prototype.slice.call(document.querySelectorAll(#{ selector }))`)

        entries.map do |element|
          Element.new(element: element)
        end
      end

      def name
        @element.name
      end

      def id
        @element.id
      end

      def class_name
        @element.className
      end

      def descriptor
        descriptor = @element.tagName
        
        id_is_blank =
          id.nil? || id == ''

        class_name_is_blank =
          class_name.nil? || class_name == ''

        if !id_is_blank
          descriptor + "##{ id }" 
        elsif !class_name_is_blank
          descriptor + ".#{ class_name }"
        else
          descriptor
        end
      end

      def value
        @element.value || @element.innerText
      end

      def unwrapped_element
        @element
      end

      private
        def node_list_to_array(node_list)
          $$.Array.prototype.slice.call(node_list)
        end

      class << self
        def document
          Element.new(selector: 'document')
        end

        def body
          Element.new(selector: 'body')
        end

        def fie_body
          Element.new(selector: '[fie-body=true]')
        end
      end
    end
  end
end
