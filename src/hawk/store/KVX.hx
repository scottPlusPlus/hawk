package hawk.store;

class KVX<K, V> {
	public function new(key:K, value:V) {
		this.key = key;
		this.value = value;
	}

	public var key:K;
	public var value:V;


	public static inline function compareStringKeys(a:KV<String,Dynamic>, b:KV<String,Dynamic>){
		return if (a.key < b.key) -1 else if (a.key > b.key) 1 else 0;
	}

	public static inline function compareIntKeys(a:KV<Int,Dynamic>, b:KV<Int,Dynamic>){
		return if (a.key < b.key) -1 else if (a.key > b.key) 1 else 0;
	}

}
