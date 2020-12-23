package hawk.messaging;

import tink.CoreApi.Promise;
import zenlog.Log;
import haxe.Timer;
import tink.CoreApi.Error;
import tink.CoreApi.Noise;
import tink.CoreApi.Outcome;

using hawk.util.OutcomeX;

class LocalChannel<T> implements IPublisher<T> implements ISubscriber<T> {
	public final key:String;
	public var delayMS:Int = 100;
	public var onError:Error->Void;
	public var pending:UInt = 0;

	private var _handlers:Array<MsgHandler<T>>;
	private var _toMsg:T->Message;
	private var _fromMsg:Message->T;

	public function new(key:String, toMessage:T->Message, fromMessage:Message->T) {
		this.key = key;
		_handlers = [];
		_toMsg = toMessage;
		_fromMsg = fromMessage;
	}

	public function publish(m:T):Promise<Noise> {
		var msg = _toMsg(m);
		Log.debug('LocalChannel publish: ${msg.body().toString()}');
		pending++;
		Timer.delay(function() {
			pushToSubscribers(msg);
		}, delayMS);
		pending--;
		return Success(Noise);
	}

	private function pushToSubscribers(msg:Message) {
		Log.debug('pushToSubscribers with ${_handlers.length} handlers');
		var obj = _fromMsg(msg);
		for (handler in _handlers) {
			var tryHandle = handler(obj);
			tryHandle.handle(function(o){
				if (o.isFailure()){
					var err = o.failure();
					Log.error('handler failed for PubSub Channel ${key}');
					Log.error(err.message);
					if (onError != null){
						onError(err);
					}
				} else {
					Log.debug('handler for Channel ${key} success');
				}
			});
		}
	}

	public function subscribe(handler:MsgHandler<T>):Void {
		for (h in _handlers) {
			if (h == handler) {
				return;
			}
		}
		_handlers.push(handler);
	}

}
