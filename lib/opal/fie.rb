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
      Listeners.new(cable)
    end
end
