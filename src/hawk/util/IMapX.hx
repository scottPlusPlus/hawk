package hawk.util;

import haxe.Constraints.IMap;

class IMapX {
    public static function copyTo<K,V>(from:IMap<K,V>, to:IMap<K,V>) {
        for (kv in from.keyValueIterator()){
            to.set(kv.key, kv.value);
        }
    }
}