import uuid from 'uuid/v4';
import { Pool } from './pool';
import { Commander } from './commander';
import { camelize } from 'humps';

export class Cable {
  constructor() {
    const connectionUUID = uuid();
    let commanderName = `${ camelize(this._controllerName) }Commander`;
    commanderName = commanderName.charAt(0).toUpperCase() + commanderName.slice(1);

    this.commander = new Commander(commanderName, connectionUUID, this);
    this.pools = {};
  }

  callRemoteFunction(element, functionName, eventName, parameters) {
    this._logEvent(element, eventName, functionName, parameters);

    const functionParameters = {
      caller: {
        id: element.id,
        class: element.className,
        value: element.value
      },
      controller_name: this._controllerName,
      action_name: this._actionName,
      ...parameters
    };

    this.commander.perform(functionName, functionParameters);
  }

  subscribeToPool(subject) {
    this.pools[subject] = new Pool('Fie::Pools', subject, this);
  }

  _logEvent(element, eventName, functionName, parameters) {
    console.log(`Event ${ eventName } triggered by element ${ this._elementDescriptor(element) } is calling function ${ functionName } with parameters ${ JSON.stringify(parameters) }`);
  }

  _elementDescriptor(element) {
    const descriptor = element.tagName;

    const idIsBlank =
      element.id == '' || element.id == null || element.id == undefined;

    const classNameIsBlank =
      element.className == '' || element.className == null || element.className == undefined;

    if (!idIsBlank) {
      return `${ descriptor }#${ element.id }`;
    }
    else if (!classNameIsBlank) {
      return `${ descriptor }.${ element.className }`;
    }
    else {
      return descriptor;
    }
  }

  get _actionName() {
    return this._viewNameElement.getAttribute('fie-action');
  }

  get _controllerName() {
    return this._viewNameElement.getAttribute('fie-controller');
  }

  get _viewNameElement() {
    return document.querySelector('[fie-controller]:not([fie-controller=""])');
  }
}