package hawk.store;

import haxe.Constraints.IMap;
import tink.CoreApi;
import tink.core.Error;

class KVCX {
    public static function collapseNulls<K,V>(arr:Array<KVC<K,Null<V>>>):Outcome<Array<KVC<K,V>>,Error>{
		for (i in 0...arr.length){
			var kv = arr[i];
			if (kv.value == null){
				return Failure(new Error('value for ${kv.key} is null'));
			}
		}
		return Success(arr);
	}

	public static function toMap<K,V>(arr:Array<KVC<K,Null<V>>>, emptyMap:IMap<K,V>):IMap<K,V> {
		for (kvc in arr){
			emptyMap.set(kvc.key, kvc.value);
		}
		return emptyMap;
	}
}