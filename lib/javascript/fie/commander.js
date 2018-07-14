import { Channel } from './action_cable/channel';
import { Util } from './util';
import { innerHTML } from 'diffhtml';

export class Commander extends Channel {
  connected() {
    super.connected();
    this.cable.callRemoteFunction(document.body, 'initialize_state', 'Upload State', { view_variables: Util.viewVariables });
  }

  received(data) {
    this.processCommand(data.command, data.parameters);
  }

  processCommand(command, parameters = {}) {
    switch(command) {
      case 'refresh_view':
        innerHTML(document.querySelector('[fie-body=true]'), parameters.html);
        document.dispatchEvent(new Event(this.eventName));
        break;
      case 'subscribe_to_pools':
        parameters.subjects.forEach(subject => this.cable.subscribeToPool(subject));
        break;
      case 'publish_to_pool': {
        const subject = parameters.subject;
        const object = parameters.object;
        const senderUUID = parameters.sender_uuid;

        this.perform(`pool_${ subject }_callback`, { object: object, sender_uuid: senderUUID });
      } break;
      case 'publish_to_pool_lazy': {
        const subject = parameters.subject;
        const object = parameters.object;
        const senderUUID = parameters.sender_uuid;

        this.perform(`pool_${ subject }_callback`, { object: object, sender_uuid: senderUUID, lazy: true });
      } break;
      case 'execute_function':
        Util.execJS(parameters.name, parameters.arguments);
        break;
      default:
        console.log(`Command: ${ command }, Parameters: ${ parameters }`);
        break;
    }
  }
}
