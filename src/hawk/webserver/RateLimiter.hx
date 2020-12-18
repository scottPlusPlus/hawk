package hawk.webserver;

import tink.core.Error.ErrorCode;
import hawk.util.OpBatcher;
import tink.CoreApi;
import tink.core.Noise;
import tink.CoreApi.Outcome;
import hawk.datatypes.Timestamp;

class RateLimiter {

    private var _trigger:OpBatcher;
    private var _trackers:Array<RequestTracker>;


    public function newReq(ip:String):Outcome<Noise,Error>{
        _trigger.trigger();
        for(tracker in _trackers){
            var pass = tracker.newReq(ip);
            if (!pass){
                return Failure(new Error(ErrorCode.BandwidthLimitExceeded, "you have exceeded your rate limit"));
            }
        }
        return Success(Noise);
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
    private var _requests:Map<String,RT>;

    public function new(durationMS:UInt, requestLimit:UInt){
        this.durationMS = durationMS;
        this.requestLimit = requestLimit;
        _msPerReq = durationMS / requestLimit;
        _requests = new Map();
    }


    public function newReq(ip:String):Bool {
        var tracker = _requests[ip];
        if (tracker == null){
            tracker = new RT();
            _requests[ip] = tracker;
        }
        var now = Timestamp.now();
        var timePassed = now - tracker.last;
        tracker.count -= timePassed * _msPerReq;
        if (tracker.count < 0){
            tracker.count = 0;
        }
        tracker.last = now;
        tracker.count++;
        return tracker.count < requestLimit;
    }

    public function prune(count:UInt):UInt {
        var toRemove = new Array<String>();
        var timeToPrune = Timestamp.now() - durationMS;
        for (kv in _requests.keyValueIterator()){
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
            _requests.remove(k);
        }
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