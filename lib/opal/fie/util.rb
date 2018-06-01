require 'fie/native'

module Fie
  class Util
    class << self
      include Fie::Native
      
      def exec_js(name, arguments = [])
        Native(`eval(#{ name })(#{ arguments.join(' ') })`)
      end

      def view_variables
        variable_elements = Element.document.query_selector_all('[fie-variable]:not([fie-variable=""])')

        variable_elements.map do |variable_element|
          variable_name = variable_element['fie-variable']
          variable_value = variable_element['fie-value']
          [variable_name, variable_value]
        end.to_h
      end
    end
  end
end
