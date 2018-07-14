import { Channel } from './action_cable/channel'

export class Pool extends Channel {
  received(data) {
    this.cable.commander.processCommand(data.command, data.parameters);
  }
}
