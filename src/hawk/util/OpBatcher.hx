package hawk.util;

import zenlog.Log;
import tink.core.Noise;
import tink.core.Promise;
import tink.core.Signal;
import tink.core.Outcome;

import yaku_core.PromiseX;

class OpBatcher {
	public var limitMS(default, null):UInt; // only trigger once every this many millis
	public var signal(get, never):Signal<OpBatcher>;
	public var idle(get, never):Bool;

	public function get_signal():Signal<OpBatcher> {
		return _signalTrigger.asSignal();
	}

	public function get_idle():Bool {
		return _next == null;
	}

	private var _signalTrigger:SignalTrigger<OpBatcher>;
	private var _next:Promise<Noise>;

	public function trigger() {
		if (_next != null) {
			return;
		}
		_next = PromiseX.waitPromise(limitMS);
		_next.next(function(_) {
			_next = null;
			_signalTrigger.trigger(this);
			return Success(Noise);
		}).eager();
	}

	public function force(){
		_signalTrigger.trigger(this);
	}

	public function new(limitMS:UInt) {
		this.limitMS = limitMS;
		_signalTrigger = new SignalTrigger();
	}
}
