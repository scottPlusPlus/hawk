package hawk.store;

import tink.CoreApi;
import tink.core.Error;

class KVX {
    
	public static function collapseNulls<K,V>(arr:Array<KV<K,Null<V>>>):Outcome<Array<KV<K,V>>,Error>{
		for (i in 0...arr.length){
			var kv = arr[i];
			if (kv.value == null){
				return Failure(new Error('value for ${kv.key} is null'));
			}
		}
		return Success(arr);
	}

    public static inline function compareStringKeys(a:KV<String, Dynamic>, b:KV<String, Dynamic>) {
		return if (a.key < b.key) -1 else if (a.key > b.key) 1 else 0;
	}

	public static inline function compareIntKeys(a:KV<Int, Dynamic>, b:KV<Int, Dynamic>) {
		return if (a.key < b.key) -1 else if (a.key > b.key) 1 else 0;
	}
}