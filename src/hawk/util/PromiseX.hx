package hawk.util;

import zenlog.Log;
import haxe.Timer;
import tink.core.Error;
import tink.CoreApi;
using hawk.util.OutcomeX;
using hawk.util.NullX;

class PromiseX {

	public static inline function wrapErr<T>(p:Promise<T>, ?code:ErrorCode = InternalError, message:String, ?pos:Pos):Promise<T> {
		return p.mapError(function(err:Error){
			return ErrorX.wrap(err, code, message, pos);
		});
	}

	public static inline function logErr<T>(p:Promise<T>):Promise<T> {
		return p.mapError(function(err:Error){
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

		p.handle(function(o:Outcome<T,Error>) {
			if (o.isFailure()){
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
		if (err == null){
			err = new Error('value was null');
		}
		return p.next(function(v){
			if (v == null){
				return Promise.reject(err);
			}
			return Promise.resolve(v);
		});
	}

	public static function nullFallback<T>(p:Promise<Null<T>>, fallback:T):Promise<T> {
		return p.next(function(maybe){
			if (maybe == null){
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


}