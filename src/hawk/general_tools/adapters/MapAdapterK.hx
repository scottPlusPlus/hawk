package hawk.general_tools.adapters;

import haxe.Constraints.IMap;

class MapAdapterK<K1,K2,V> implements IMap<K1, V> {
	private var _data:Map<K2, V>;
	private var _keyAdapter:Adapter<K1,K2>;

	public function new(k1_k2_Adapter:Adapter<K1,K2>, data:Map<K2, V>) {
		_data = data;
		_keyAdapter = k1_k2_Adapter;
	}

	public function get(k:K1):Null<V> {
		var k2 = _keyAdapter.toB(k);
		return _data.get(k2);
	}

	public function set(k:K1, v:V):Void {
		var k2 = _keyAdapter.toB(k);
		return _data.set(k2, v);
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

	public function iterator():Iterator<V> {
		return _data.iterator();
	}

	public function keyValueIterator():KeyValueIterator<K1, V> {
		var i = _data.keyValueIterator();
		var ti = new IteratorAdapter(i, keyValueTransform);
		return ti;
	}

	private function keyValueTransform(kv:{key:K2, value:V}) {
		return {
			key: _keyAdapter.toA(kv.key),
			value: kv.value
		};
	}

	public function copy():IMap<K1, V> {
		return new MapAdapterK<K1,K2,V>(_keyAdapter,  _data.copy());
	}

	public function toString():String {
		return _data.toString();
	}

	public function clear():Void {
		return _data.clear();
	}
}
