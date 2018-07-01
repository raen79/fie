require 'es6-object-assign/dist/object-assign.min'

class DiffSetup
  class << self
    include Fie::Native

    def run
      $$.ObjectAssign.polyfill()

      Native \
        `diff.use(
          Object.assign(_ => {}, {
            syncTreeHook: (oldTree, newTree) => {
              if (newTree.attributes != undefined && newTree.attributes['fie-ignore'] != undefined && Object.keys(oldTree).length > 0) {
                return oldTree;
              }
            }
          })
        )`
    end
  end
end
