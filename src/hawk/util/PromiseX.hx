package hawk.util;

import haxe.Timer;
import tink.core.Error;
import tink.CoreApi;
using hawk.util.OutcomeX;

class PromiseX {

	public static inline function wrapErr<T>(p:Promise<T>, ?code:ErrorCode = InternalError, message:String, ?pos:Pos):Promise<T> {
		return p.mapError(function(err:Error){
			return ErrorX.wrap(err, code, message, pos);
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

	// public static function then<T1, T2>(p1:Promise<T1>, handler:Outcome<T1,Error>->Promise<T2>):Promise<T2> {
	// 	var res = new PromiseTrigger<T2>();
	// 	p1.handle(function(o1:Outcome<T1,Error>) {
    //         var prom = handler(o1.sure());
    //         prom.handle(function(o2:Outcome<T2,Error>){
    //             res.trigger(o2);
    //         });
	// 	});
	// 	return res.asPromise();
	// }

}