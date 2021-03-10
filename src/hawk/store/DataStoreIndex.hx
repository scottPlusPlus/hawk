package hawk.store;

import zenlog.Log;
import hawk.store.ArrayKV;
import hawk.store.KVC;
import haxe.Constraints.IMap;
import tink.CoreApi;

using hawk.util.ErrorX;

@:generic
class DataStoreIndex<K,V> implements IDataStoreIndex<K,V> {

    private var _get:K->Promise<Null<V>>;

    public function get(key:K): Promise<Null<V>> {
        var nv = _get(key);
        if (nv == null){
            Log.debug('DSI: got null...');
        }
        return nv;
    }

    public function getMany(keys:Array<K>): Promise<ArrayKV<K,Null<V>>> {
        var res = new ArrayKV<K,Null<V>>();
        var promises = new Array<Promise<Noise>>();
        for (k in keys){
            var p = _get(k).next(function(v){
                if (v == null){
                    res.push(new KVC(k, null));
                } else {
                    res.push(new KVC(k, v));
                }
                return Noise;
            });
            promises.push(p);
        }
        return Promise.inSequence(promises).next(function(_){
            return res;
        });
    }

    public function new(getFunction:K->Promise<V>){
        _get = getFunction;
    }
}