package hawk.webserver;

import zenlog.Log;
import tink.core.Error.ErrorCode;
import hawk.util.OpBatcher;
import tink.CoreApi;
import tink.core.Noise;
import tink.CoreApi.Outcome;
import hawk.datatypes.Timestamp;

class RateLimiter {

    private var _trigger:OpBatcher;
    private var _trackers:Array<RequestTracker>;

    public static var rateLimitErr = new Error(ErrorCode.BandwidthLimitExceeded, "you have exceeded your rate limit"); 

    public function new(trackers:Array<RequestTracker>, timeToPruneMs:UInt = 5000){
        this._trackers = trackers;
        this._trigger = new OpBatcher(5000);
        this._trigger.signal.handle(function(_){
            pruneAndSave();
        });
    }

    public function newReq(ip:String):Bool{
        _trigger.trigger();
        Log.debug("done with trigger");
        for(tracker in _trackers){
            var pass = tracker.newReq(ip);
            if (!pass){
                Log.debug("would be false");
                return false;
            }
        }
        Log.debug("yay pass");
        return true;
    }

    private function pruneAndSave(){
        for(tracker in _trackers){
            var removed = tracker.prune(10);
            if (removed > 0){
                _trigger.trigger();
            }
        }
    }
}

class RequestTracker {

    public var durationMS(default,null):UInt; //60 seconds
    public var requestLimit(default,null):UInt; //10 reqs

    private var _msPerReq:Float; // = duration / requestLimit;
    private var _ips:Map<String,RT>;

    //TODO - make private
    @:jignored public var _currentTime:Void->Timestamp = Timestamp.now;

    public function new(durationMS:UInt, requestLimit:UInt){
        this.durationMS = durationMS;
        this.requestLimit = requestLimit;
        _msPerReq = requestLimit / durationMS;
        _ips = new Map();
    }

    public function newReq(ip:String):Bool {
        var tracker = _ips[ip];
        if (tracker == null){
            tracker = new RT();
            _ips[ip] = tracker;
        }
        var now = _currentTime();
        var timePassed = now - tracker.last;
        //Log.debug('timePassed = ${timePassed.toUInt()} so minus ${timePassed * _msPerReq}');
        tracker.count -= timePassed.toUInt() * _msPerReq;
        if (tracker.count < 0){
            tracker.count = 0;
        }
        tracker.last = now;
        tracker.count++;
       // Log.debug('new request. count now = ${tracker.count} of ${requestLimit}');
        return tracker.count <= requestLimit;
    }

    public function prune(count:UInt):UInt {
        //Log.debug("tracker.PRune");
        var toRemove = new Array<String>();
        var timeToPrune = _currentTime() - durationMS;
        for (kv in _ips.keyValueIterator()){
            var tracker = kv.value;
            if (tracker.last < timeToPrune){
                toRemove.push(kv.key);
                count--;
            }
            if (count <= 0){
                break;
            }
        }
        for (k in toRemove){
            _ips.remove(k);
        }
        Log.debug("done pruning: " + toRemove.length);
        return toRemove.length;
    }

    public static function fromJson(str:String): RequestTracker {
        var parser = new json2object.JsonParser<RequestTracker>();
        return parser.fromJson(str);
    }

    public function toJson():String {
        var writer = new json2object.JsonWriter<RequestTracker>();
        return writer.write(this);
    }

}

class RT {
    public function new(){}
    public var count:Float;
    public var last:Timestamp;
}