import { Util } from './util';
import { Timer } from './timer';
import uuid from 'uuid/v4';

export class Listeners {
  constructor(cable) {
    this.cable = cable;
    this.timer = new Timer(_ => {});

    this._initializeInputElements();
    this._initializeFieEvents(['click', 'submit', 'scroll', 'keyup', 'keydown', 'enter', 'change']);
  }

  _initializeFieEvents(eventNames) {
    eventNames.forEach(fieEventName => {
      const selector = `[fie-${ fieEventName }]:not([fie-${ fieEventName }=''])`;
      let eventName = fieEventName;
      
      if (eventName == 'enter') {
        eventName = 'keydown';
      }

      Util.addEventListener(eventName, selector, event => {
        this._handleFieEvent(fieEventName, eventName, event);
      });
    });
  }

  _handleFieEvent(fieEventName, eventName, event) {
    const eventIsValid = (fieEventName == 'enter' && event.keyCode == 13) || fieEventName != 'enter';

    if (eventIsValid) {
      const remoteFunctionName = event.target.getAttribute(`fie-${ fieEventName }`);
      const functionParameters = JSON.parse(event.target.getAttribute('fie-parameters')) || {};
      
      this.timer.fastForward();
      this.cable.callRemoteFunction(event.target, remoteFunctionName, eventName, functionParameters);
    }
  }

  _initializeInputElements() {
    const typingInputTypes = ['text', 'password', 'search', 'tel', 'url'];
    
    const typingInputSelector = ['textarea', ...typingInputTypes].reduce((selector, inputType) => {
      return selector += `, input[type=${ inputType }]`;
    });

    const nonTypingInputSelector = ['input', ...typingInputTypes].reduce((selector, inputType) => {
      return selector += `:not([type=${ inputType }])`;
    });

    Util.addEventListener('keydown', typingInputSelector, event => {
      if (event.keyCode == 13) {
        event.target.blur();
      }
      else {
        this.timer.clear();
        this.timer = new Timer(_ => this._updateStateUsingChangelog(event.target), 300);
      }
    });

    Util.addEventListener('focusin', typingInputSelector, event => {
      event.target.setAttribute('fie-ignore', uuid());
    });

    Util.addEventListener('focusout', typingInputSelector, event => {
      event.target.removeAttribute('fie-ignore');
    });

    Util.addEventListener('change', nonTypingInputSelector, event => {
      this._updateStateUsingChangelog(event.target);
    });
  }

  _updateStateUsingChangelog(inputElement) {
    const objectsChangelog = {};

    const changedObjectName = inputElement.name.split('[')[0];
    const changedObjectKeyChain = inputElement.name.match(/[^\[]+(?=\])/g);

    const isFormObject = changedObjectKeyChain != null && changedObjectKeyChain.length > 0;
    const isFieNestedObject = Object.keys(Util.viewVariables).includes(changedObjectName);
    const isFieFormObject = isFormObject && isFieNestedObject;

    const isFieNonNestedObject = Object.keys(Util.viewVariables).includes(inputElement.name);

    if (isFieFormObject) {
      this._buildChangelog(changedObjectKeyChain, changedObjectName, objectsChangelog, inputElement);
    }
    else if (isFieNonNestedObject) {
      objectsChangelog[inputElement.name] = inputElement.value;
    }
    else {
      console.log(changedObjectKeyChain);
    }

    this.cable.callRemoteFunction(inputElement, 'modify_state_using_changelog', 'Input Element Change', { objects_changelog: objectsChangelog });
  }

  _buildChangelog(objectKeyChain, objectName, changelog, inputElement) {
    const isFinalKey = key => key == objectKeyChain[objectKeyChain.length - 1];
    const objectFinalKeyValue = inputElement.value;

    changelog[objectName] = {}
    changelog = changelog[objectName];

    objectKeyChain.forEach(key => {
      if (isFinalKey(key)) {
        changelog[key] = objectFinalKeyValue;
      }
      else {
        changelog[key] = {};
        changelog = changelog[key];
      }
    });
  }
}