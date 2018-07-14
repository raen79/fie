export class Timer {
  constructor(callback, time = 0) {
    this.callback = callback;
    this.timeout = setTimeout(callback, time);
  }

  clear() {
    clearTimeout(this.timeout);
  }

  fastForward() {
    clearTimeout(this.timeout);
    this.callback();
  }
}
