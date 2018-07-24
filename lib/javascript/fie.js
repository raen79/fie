import { Cable } from './fie/cable';
import { Listeners } from './fie/listeners';
import { Util } from './fie/util';
import { use } from 'diffhtml';
import { polyfill } from 'es6-object-assign';

export class Fie {
  constructor() {
    this._diffSetup();

    document.addEventListener('DOMContentLoaded', _ => {
      this.cable = new Cable();
      new Listeners(this.cable);
    });
  }

  executeCommanderMethod(functionName, parameters = {}) {
    this.cable.callRemoteFunction(document.body, functionName, 'calling remote function', JSON.parse(JSON.stringify(parameters)));
  }

  addEventListener(eventName, selector, callback) {
    Util.addEventListener(eventName, selector, callback);
  }

  _diffSetup() {
    polyfill();

    use(
      Object.assign(_ => {}, {
        syncTreeHook: (oldTree, newTree) => {
          if (newTree.nodeName === 'input') {
            const oldElement = document.querySelector('[name="' + newTree.attributes['name'] + '"]');

            if (oldElement != undefined && oldElement.attributes['fie-ignore'] != undefined) {
              newTree.nodeValue = oldElement.value;
              newTree.attributes['value'] = oldElement.value;
              newTree.attributes['autofocus'] = '';
              newTree.attributes['fie-ignore'] = oldElement.attributes['fie-ignore'];
            }

            return newTree;
          }
        }
      })
    )
  }
}

window.Fie = new Fie();