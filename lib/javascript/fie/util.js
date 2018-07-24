import { object } from 'underscore';

export class Util {
  static addEventListener(eventName, selector, callback) {
    document.querySelector('[fie-body=true]').addEventListener(eventName, event => {
      if (event.target.matches(selector)) {
        callback(event);
      }
    });
  }

  static execJS(functionName, args = []) {
    eval(functionName)(...args);
  }

  static get viewVariables() {
    const variableElements = document.querySelectorAll('[fie-variable]:not([fie-variable=""])');
    
    return object(Array.from(variableElements).map(variableElement => {
      const variableName = variableElement.getAttribute('fie-variable');
      const variableValue = variableElement.getAttribute('fie-value');
      return [variableName, variableValue];
    }));
  }
}