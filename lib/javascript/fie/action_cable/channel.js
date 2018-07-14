export class Channel {
  constructor(channelName, identifier, cable) {
    this.channelName = channelName;
    this.identifier = identifier;
    this.cable = cable;
    this.eventName = 'fieChanged';
    
    this.subscription = App.cable.subscriptions.create(
      { channel: channelName, identifier: identifier },
      {
        connected: _ => { this.connected() },
        received: data => this.received(data)
      }
    );
  }

  connected() {
    this.perform('initialize_pools');
    console.log(`Connected to ${ this.channelName } with identifier ${ this.identifier }`);
  }

  perform(functionName, parameters = {}) {
    this.subscription.perform(functionName, parameters);
  }
}