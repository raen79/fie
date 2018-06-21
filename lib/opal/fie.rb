require 'opal'

module Fie
    require_tree './fie'

    include Fie::Native

    Native(`window.Fie = {}`)
    Native \
      `window.Fie.addEventListener =
          #{
            -> (event_name, selector, block) do
              Element.fie_body.add_event_listener(event_name, selector, &block)
            end
          }`

    Element.document.add_event_listener('DOMContentLoaded') do
      cable = Cable.new

      Native \
        `window.Fie.executeCommanderMethod =
          #{
            -> (function_name, parameters = {}) do
              cable.call_remote_function \
                element: Element.body, 
                event_name: 'calling remote function', 
                function_name: function_name,
                parameters: Hash.new(parameters)
            end
          }`

      Listeners.new(cable)
    end
end
