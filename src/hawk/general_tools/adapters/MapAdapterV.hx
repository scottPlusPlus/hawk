package hawk.general_tools.adapters;

import haxe.Constraints.IMap;

class MapAdapterV<K,V1,V2> implements IMap<K, V1> {
	private var _data:Map<K, V2>;
	private var _valAdapter:Adapter<V1,V2>;

	public function new(v1_v2_adapter:Adapter<V1,V2>, data:Map<K, V2>) {
		_data = data;
		_valAdapter = v1_v2_adapter;
	}

	public function get(k:K):Null<V1> {
		var nv = _data.get(k);
		if (nv == null) {
			return null;
		}
		return _valAdapter.toA(nv);
	}

	public function set(k:K, v:V1):Void {
		var v2 = _valAdapter.toB(v);
		return _data.set(k, v2);
	}

	public function exists(k:K):Bool {
		return _data.exists(k);
	}

	public function remove(k:K):Bool {
		return _data.remove(k);
	}

	public function keys():Iterator<K> {
		return _data.keys();
	}

	public function iterator():Iterator<V1> {
		var i = _data.iterator();
		var ia = new IteratorAdapter(i, _valAdapter.toA);
		return ia;
	}

	public function keyValueIterator():KeyValueIterator<K, V1> {
		var i = _data.keyValueIterator();
		var ia = new IteratorAdapter(i, keyValueTransform);
		return ia;
	}

	private function keyValueTransform(kv:{key:K, value:V2}) {
		return {
			key: kv.key,
			value: _valAdapter.toA(kv.value)
		};
	}

	public function copy():IMap<K, V1> {
		return new MapAdapterV<K,V1,V2>(_valAdapter, _data.copy());
	}

	public function toString():String {
		return _data.toString();
	}

	public function clear():Void {
		return _data.clear();
	}
}
