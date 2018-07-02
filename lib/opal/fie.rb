require 'opal'

module Fie
    require_tree './fie'

    include Fie::Native

    DiffSetup.run

    Element.document.add_event_listener('DOMContentLoaded') do
      cable = Cable.new

      ExposeMethods.run

      Listeners.new(cable)
    end
end
