package hawk.counters;

import hawk.datatypes.Timestamp;
import json2object.JsonParser;
import json2object.JsonWriter;

using hawk.util.NullX;

class LeakyBucketCounters {
	public var durationMS(default, null):UInt; // 60 seconds
	public var limit(default, null):UInt;
	public var leakPerMS(default, null):Float;

	private var _counters:Map<String, Counter>;

	@:jignored
	private var _getTime:Void->Timestamp;

	public function new(limit:UInt, durationMS:UInt, ?getTime:Void->Timestamp) {
		this.durationMS = durationMS;
		this.limit = limit;
		leakPerMS = limit / durationMS;
		_counters = new Map();
	}

	public function init(?getTime:Void->Timestamp):LeakyBucketCounters {
		if (getTime == null) {
			getTime = Timestamp.now;
		}
		_getTime = getTime;
		return this;
	}

	public function add(key:String, val:UInt = 1):Float {
		var c = _counters.get(key);
		if (c == null) {
			c = new Counter();
			_counters[key] = c;
		}
		var counter = c.nullSure();
		var now = _getTime();
		var timePassed = now - counter.last;
		counter.count -= timePassed * leakPerMS;
		if (counter.count < 0) {
			counter.count = 0;
		}
		counter.last = now;
		counter.count += val;
		return counter.count;
	}

	// todo: max int
	public function pruneEmpty(pruneLimit:UInt = 99999):UInt {
		var toRemove = new Array<String>();
		var timeToPrune = Timestamp.now() - durationMS;
		for (kv in _counters.keyValueIterator()) {
			var counter = kv.value;
			if (counter.last < timeToPrune) {
				toRemove.push(kv.key);
				pruneLimit--;
			}
			if (pruneLimit <= 0) {
				break;
			}
		}
		for (k in toRemove) {
			_counters.remove(k);
		}
		return toRemove.length;
	}

	public static function fromJson(str:String):LeakyBucketCounters {
		var parser = new json2object.JsonParser<LeakyBucketCounters>();
		return parser.fromJson(str);
	}

	public function toJson():String {
		var writer = new json2object.JsonWriter<LeakyBucketCounters>();
		return writer.write(this);
	}
}

class Counter {
	public function new() {}

	public var count:Float;
	public var last:Timestamp;
}
