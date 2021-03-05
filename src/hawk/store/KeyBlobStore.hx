package hawk.store;

import hawk.general_tools.adapters.Adapter;
import haxe.Constraints.IMap;
import zenlog.Log;
import tink.CoreApi;

class KeyBlobStore {
	private static final KEY_FIELD = "key";
	
	private var _store:IDataStore<KVX<String, String>>;
	private var _built:Map<String, UInt> = [];
	private var _index:IDataStoreIndex<String, KVX<String, String>>;

	

	public function new(store:IDataStore<KVX<String, String>>) {
		_store = store;
		_index = _store.getIndexByColName(KEY_FIELD);
	}

	public function buildStringStore(key:String):Promise<KeyBlobStringStore> {
		if (_built.exists(key)) {
			Log.error('StringStore for key ${key} has already been created.  If you need to access that store from multiple places, best to pass it around.');
		}
		_built.set(key, 0);
		var get = function() {
			return _index.get(key).next(function(kvx) {
				if (kvx == null) {
					return "";
				}
				return kvx.value;
			});
		};
		var set = function(data:String) {
			var kvx = new KVX(key, data);
			return _store.update(kvx).noise();
		};

		var ss = new KeyBlobStringStore(get, set);

		return _index.get(key).next(function(res) {
			if (res == null) {
				var kvx = new KVX(key, "");
				return _store.create(kvx);
			}
			return res;
		}).next(function(_) {
			return ss;
		});
	}

	public static function model():DataModel<KVX<String, String>> {
		var example = new KVX("myKey", "myVal");

		var toMap = function(item:KVX<String, String>):IMap<String, String> {
			var m = new Map<String, String>();
			m.set(KEY_FIELD, item.key);
			m.set("value", item.value);
			return m;
		};

		var toKVX = function(data:IMap<String, String>):KVX<String, String> {
			var k = data.get(KEY_FIELD);
			var v = data.get("value");
			return new KVX(k, v);
		};
		var adapter = new Adapter(toMap, toKVX);
		var fields = new Array<DataField>();
		fields.push(new DataField(KEY_FIELD, DataFieldType.Primary));
		fields.push(new DataField("value"));

		var model = new DataModel<KVX<String, String>>();
		model.adapter = adapter;
		model.fields = fields;
		model.example = example;

		return model;
	}
}

class KeyBlobStringStore implements IStringStore {
	private var _get:Void->Promise<String>;
	private var _set:String->Promise<Noise>;

	public function new(get:Void->Promise<String>, set:String->Promise<Noise>) {
		_get = get;
		_set = set;
	}

	public function load():Promise<String> {
		return _get();
	}

	public function save(data:String):Promise<String> {
		return _set(data).next(function(_) {
			return data;
		});
	}
}
