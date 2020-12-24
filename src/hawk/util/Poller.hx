package hawk.util;

import zenlog.Log;
import hawk.datatypes.Timestamp;
import haxe.Timer;
import tink.CoreApi;

using hawk.util.OutcomeX;

class Poller {

	public static function waitUntil(f:Void->Promise<Bool>, intervalMS:UInt = 100, maxMS:UInt = 5000):Promise<Noise> {
		var p = new PromiseTrigger<Noise>();
		var endTime = Timer.stamp() + (maxMS / 1000);
		internalWaitUntil(f, intervalMS, endTime, p);
        return p;
    }
    
    private static function internalWaitUntil(f:Void->Promise<Bool>, intervalMS:UInt, endTime:Float, p:PromiseTrigger<Noise>){
        var now = Timer.stamp();
        if (now >= endTime){
            p.reject(new Error('exceeded max poll time'));
            return;
        }

        var once = function() {
            var passProm = f();
            passProm.map(function(o:Outcome<Bool,Error>){
                if (o.isFailure()){
                    p.reject(o.failure());
                    return;
                }
                var pass = o.sure();
                if (pass) {
                    p.resolve(Noise);
                    return;
                }
                internalWaitUntil(f, intervalMS, endTime, p);
            }).eager();
        }
        
        Timer.delay(once, intervalMS);
    }
}
