package hawk.store;

import zenlog.Log;
import hawk.store.ArrayKV;
import hawk.store.KVX;
import haxe.Constraints.IMap;
import tink.CoreApi;

using hawk.util.ErrorX;

@:generic
class DataStoreIndex<K,V> implements IDataStoreIndex<K,V> {

    private var _get:K->Promise<Null<IDataItem<V>>>;

    public function get(key:K): Promise<Null<IDataItem<V>>> {
        var nv = _get(key);
        if (nv == null){
            Log.debug('DSI: got null...');
        }
        return nv;
    }

    public function getMany(keys:Array<K>): Promise<ArrayKV<K,Null<IDataItem<V>>>> {
        var res = new ArrayKV<K,Null<IDataItem<V>>>();
        var promises = new Array<Promise<Noise>>();
        for (k in keys){
            var p = _get(k).next(function(v){
                if (v == null){
                    res.push(new KVX(k, null));
                } else {
                    res.push(new KVX(k, v));
                }
                return Noise;
            });
            promises.push(p);
        }
        return Promise.inSequence(promises).next(function(_){
            return res;
        });
    }

    public function new(getFunction:K->Promise<IDataItem<V>>){
        _get = getFunction;
    }
}