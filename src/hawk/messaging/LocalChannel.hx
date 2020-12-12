package hawk.messaging;

import tink.CoreApi.Promise;
import zenlog.Log;
import haxe.Timer;
import tink.CoreApi.Error;
import tink.CoreApi.Noise;
import tink.CoreApi.Outcome;

using hawk.util.OutcomeX;

class LocalChannel implements IPublisher implements ISubscriber {
	public final key:String;
	public var delayMS:Int = 100;
	public var onError:Error->Void;
	public var pending:UInt = 0;

	private var _handlers:Array<MsgHandler>;

	public function new(key:String) {
		this.key = key;
		_handlers = [];
	}

	public function publish(msg:Message):Promise<Noise> {
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
		for (h in _handlers) {
			var tryHandle = h(msg);
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

	public function subscribe(handler:MsgHandler):Void {
		for (h in _handlers) {
			if (h == handler) {
				return;
			}
		}
		_handlers.push(handler);
	}

}
