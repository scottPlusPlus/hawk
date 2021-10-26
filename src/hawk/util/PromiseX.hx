package hawk.util;

import zenlog.Log;
import haxe.Timer;
import tink.core.Error;
import tink.CoreApi;

using hawk.util.OutcomeX;
using hawk.util.NullX;

class PromiseX {
	public static inline function wrapErr<T>(p:Promise<T>, ?code:ErrorCode = InternalError, message:String, ?pos:Pos):Promise<T> {
		return p.mapError(function(err:Error) {
			return ErrorX.wrap(err, code, message, pos);
		});
	}

	public static inline function logErr<T>(p:Promise<T>):Promise<T> {
		return p.mapError(function(err:Error) {
			Log.error(err);
			return err;
		});
	}

	public static function waitPromise(ms:UInt):Promise<Noise> {
		var pt = new PromiseTrigger<Noise>();
		Timer.delay(function() {
			pt.resolve(Noise);
		}, ms);
		return pt.asPromise();
	}

	public static function thenWait<T>(p:Promise<T>, ms:UInt):Promise<T> {
		var pt = new PromiseTrigger<T>();

		p.handle(function(o:Outcome<T, Error>) {
			if (o.isFailure()) {
				pt.reject(o.failure());
			} else {
				Timer.delay(function() {
					pt.resolve(o.sure());
				}, ms);
			}
		});
		return pt.asPromise();
	}

	public static function errOnNull<T>(p:Promise<Null<T>>, ?err:Error):Promise<T> {
		if (err == null) {
			err = new Error('value was null');
		}
		return p.next(function(v) {
			if (v == null) {
				return Promise.reject(err);
			}
			return Promise.resolve(v);
		});
	}

	public static function nullFallback<T>(p:Promise<Null<T>>, fallback:T):Promise<T> {
		return p.next(function(maybe) {
			if (maybe == null) {
				return Success(fallback);
			}
			var sure = maybe.nullThrows();
			return Success(sure);
		});
	}

	public static function recoverWith<T>(p:Promise<T>, fallback:T):Promise<T> {
		return p.recover(function(err:Error):T {
			return fallback;
		});
	}

	/**
	 * Returns the result of the Promise. (synchronously)  
	 * WARN: Will return ERROR if the Promise has not yet resolved
	 */
	public static function result<T>(p:Promise<T>):Outcome<T, Error> {
		switch (p.status) {
			case Ready(result):
				return result;
			default:
				return Failure(new Error('This Promise has not resolved yet'));
		}
	}

	/**
	 * Pushes the Promise to the passed array. Returns the original Promise.
	 */
	public static function pushTo<T>(p:Promise<T>, arr:Array<Promise<T>>):Promise<T> {
		arr.push(p);
		return p;
	}

	/**
	 * Pushes the Promise.noise() to the passed array. Returns the original Promise.
	 */
	public static function pushNoiseTo<T>(p:Promise<T>, arr:Array<Promise<Noise>>):Promise<T> {
		arr.push(p.noise());
		return p;
	}

	
	/**
	 * Wraps the passed f in a try/catch.  If an exception is thrown,  
	 * it is caught and returned as an Error
	 */
	public static function tryOrErr<T>(f:Void->Promise<T>):Promise<T> {
		var trigger = new PromiseTrigger<T>();
		try {
			f().eager().handle(function(o){
				switch (o){
					case Failure(err):
						trigger.reject(err);
					case Success(data):
						trigger.resolve(data);
				}
			});
		} catch (ex) {
			var err = new Error(ex.message);
			trigger.reject(err);
		}
		return trigger.asPromise();
	}

	public static function withTimeout<T>(p:Promise<T>, timeoutMS:UInt):Promise<T> {
		var trigger = new PromiseTrigger<T>();
		p.handle(function(o){
			passResultIfWaitng(trigger, o);
		});

		PromiseX.waitPromise(timeoutMS).eager().handle(function(_){
			var err = new Error('Promise timed out after ${timeoutMS}');
			var o = Failure(err);
			passResultIfWaitng(trigger, o);
		});

		return trigger.asPromise();
	}

	public static function passResultIfWaitng<T>(pt:PromiseTrigger<T>, outcome:Outcome<T,Error>){
		var status = pt.getStatus();
		switch (status){
			case Awaited:
				passResult(pt, outcome);
			case EagerlyAwaited:
				passResult(pt, outcome);
				
			case Ready(_):
				Log.debug('Have result, but next Promise status == Raeady, so ignoring');
			default:
				Log.debug('Have result, but next Promise status == ${status}, so ignoring');
		}
	}

	public static function passResult<T>(pt:PromiseTrigger<T>, outcome:Outcome<T,Error>){
		switch (outcome){
			case Success(data):
				pt.resolve(data);
			case Failure(failure):
				pt.reject(failure);
		}
	}
}
