package hawk.store;

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
}