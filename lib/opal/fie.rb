require 'opal'

module Fie
    require_tree './fie'

    include Fie::Native

    Element.document.add_event_listener('DOMContentLoaded') do
      cable = Cable.new

      DiffSetup.run
      ExposeMethods.run

      Listeners.new(cable)
    end
end
