package hawk.webserver;

class LeakyBucketCounter {

    public var limit(default,null):UInt; //10 reqs
    public var msPerLeak(default,null):UInt;
    public var count(default,null):Float;
    public var last(default,null):Timestamp;

    public function new(limit:UInt, msPerLeak:UInt){
        this.limit = limit;
        this.msPerLeak = msPerLeak;
    }

    public function add(val:Int = 1) {
        var now = Timestamp.now();
        var timePassed = now - last;
        count -= timePassed * msPerLeak;
        if (count < 0){
            count = 0;
        }
        last = now;
        count += val;
        return tracker.count < requestLimit;
    }

    public function overflows():Bool {
        return count > limit;
    }

    public static function fromJson(str:String): LeakyBucketCounter {
        var parser = new json2object.JsonParser<LeakyBucketCounter>();
        return parser.fromJson(str);
    }

    public function toJson():String {
        var writer = new json2object.JsonWriter<LeakyBucketCounter>();
        return writer.write(this);
    }
}
