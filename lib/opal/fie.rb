require 'opal/base'
require 'opal/mini'

require 'corelib/io'
require 'corelib/dir'
require 'corelib/file'

require 'corelib/unsupported'

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
