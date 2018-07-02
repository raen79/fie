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
              if (newTree.nodeName === 'input') {
                let oldElement = document.querySelector('[name="' + newTree.attributes.name + '"]');

                if (oldElement != undefined && oldElement.attributes['fie-ignore'] != undefined) {
                  newTree.nodeValue = oldElement.value;
                  newTree.attributes.value = oldElement.value;
                  newTree.attributes.autofocus = '';
                  newTree.attributes['fie-ignore'] = oldElement.attributes['fie-ignore'];
                }

                return newTree;
              }
            }
          })
        )`
    end
  end
end
