package hawk.util;

import haxe.Timer;
import tink.core.Noise;
import tink.core.Future;
import tink.CoreApi.FutureTrigger;

class FutureX {
	public static function wait(ms:UInt):Future<Noise> {
		var trigger = new FutureTrigger<Noise>();
		Timer.delay(function() {
			trigger.trigger(Noise);
		}, ms);
		return trigger.asFuture();
    }

    public static function thenWait<T>(f:Future<T>, ms:UInt):Future<Noise> {
        var res = new FutureTrigger<Noise>();
		f.handle(function(_) {
            Timer.delay(function() {
                res.trigger(Noise);
            }, ms);    
        });
		return res.asFuture();
    }
    
    public static inline function resolvedFuture<T>(val:T):Future<T> {
         var trig = new FutureTrigger<T>();
         trig.trigger(val);
         return trig.asFuture();
    }

	public static function then<T1, T2>(f1:Future<T1>, f2:T1->Future<T2>):Future<T2> {
		var res = new FutureTrigger<T2>();

		f1.handle(function(val1:T1) {
			var fut = f2(val1);
			fut.handle(function(val2:T2) {
				res.trigger(val2);
			});
		});

		return res.asFuture();
	}
}
