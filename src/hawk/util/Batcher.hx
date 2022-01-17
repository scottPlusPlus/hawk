package hawk.util;

import hawk.store.ArrayKV;
import haxe.ds.Map;
import tink.CoreApi;

using yaku_core.PromiseX;
using yaku_core.NullX;

class Batcher<T> {
	private var _batchTimer:OpBatcher;
	private var _batchRequest:Array<String>->Promise<ArrayKV<String, T>>;

	private var _activeRequest:Promise<Noise>;

	private var _queuedKeys:Array<String>;
	private var _queuedPromises:Map<String, PromiseTrigger<T>>;
	private var _pendingPromises:Map<String, PromiseTrigger<T>>;

	public function new(batchRequest:Array<String>->Promise<ArrayKV<String, T>>, delayMS:UInt) {
		_batchRequest = batchRequest;
		_batchTimer = new OpBatcher(delayMS);
		_batchTimer.signal.handle(onTimerReady);
		_queuedPromises = new Map<String, PromiseTrigger<T>>();
		_queuedKeys = new Array<String>();
	}

	public function request(key:String):Promise<Null<T>> {
		_batchTimer.trigger();
		_queuedKeys.push(key);
		var promise = new PromiseTrigger<T>();
		_queuedPromises.set(key, promise);
		return promise.asPromise();
	}

	private function makeBatchRequest() {
		_pendingPromises = _queuedPromises.copy();
		_queuedPromises.clear();
		var vals = _queuedKeys.copy();
		_queuedKeys.resize(0);
		var p:Promise<Noise> = _batchRequest(vals).map(handleOutcome).noise();
		_activeRequest = p.recoverWith(Noise).eager();
	}

	private function handleOutcome(o:Outcome<ArrayKV<String, T>, Error>) {
		switch o {
			case Success(res):
				for (kv in res) {
					var pt:PromiseTrigger<T> = _pendingPromises.get(kv.key).nullThrows('no pending promise for ${kv.key}');
					pt.resolve(kv.value);
				}
			case Failure(err):
				for (p in _pendingPromises.iterator()) {
					p.reject(err);
				}
		}
		_activeRequest = null;
	}

	private function onTimerReady() {
		if (_activeRequest == null) {
			makeBatchRequest();
			return;
		}
		_activeRequest.next(function(_) {
			makeBatchRequest();
			return Noise;
		}).eager();
	}
}
