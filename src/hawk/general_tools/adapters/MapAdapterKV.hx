package hawk.general_tools.adapters;

import haxe.Constraints.IMap;

class MapAdapterKV<K1,K2,V1,V2> implements IMap<K1, V1> {
	private var _data:Map<K2, V2>;
	private var _keyAdapter:Adapter<K1,K2>;
	private var _valAdapter:Adapter<V1,V2>;

	public function new(k1_k2_Adapter:Adapter<K1,K2>, v1_v2_adapter:Adapter<V1,V2>, data:Map<K2, V2>) {
		_data = data;
		_keyAdapter = k1_k2_Adapter;
		_valAdapter = v1_v2_adapter;
	}

	public function get(k:K1):Null<V1> {
		var k2 = _keyAdapter.toB(k);
		var nv = _data.get(k2);
		if (nv == null) {
			return null;
		}
		return _valAdapter.toA(nv);
	}

	public function set(k:K1, v:V1):Void {
		var k2 = _keyAdapter.toB(k);
		var v2 = _valAdapter.toB(v);
		return _data.set(k2, v2);
	}

	public function exists(k:K1):Bool {
		return _data.exists(_keyAdapter.toB(k));
	}

	public function remove(k:K1):Bool {
		return _data.remove(_keyAdapter.toB(k));
	}

	public function keys():Iterator<K1> {
		var i = _data.keys();
		var ti = new IteratorAdapter(i, _keyAdapter.toA);
		return ti;
	}

	public function iterator():Iterator<V1> {
		var i = _data.iterator();
		var ti = new IteratorAdapter(i, _valAdapter.toA);
		return ti;
	}

	public function keyValueIterator():KeyValueIterator<K1, V1> {
		var i = _data.keyValueIterator();
		var ti = new IteratorAdapter(i, keyValueTransform);
		return ti;
	}

	private function keyValueTransform(kv:{key:K2, value:V2}) {
		return {
			key: _keyAdapter.toA(kv.key),
			value: _valAdapter.toA(kv.value)
		};
	}

	public function copy():IMap<K1, V1> {
		return new MapAdapterKV<K1,K2,V1,V2>(_keyAdapter, _valAdapter, _data.copy());
	}

	public function toString():String {
		return _data.toString();
	}

	public function clear():Void {
		return _data.clear();
	}
}
