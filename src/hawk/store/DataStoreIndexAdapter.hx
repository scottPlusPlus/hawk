package hawk.store;

import tink.CoreApi;
import hawk.general_tools.adapters.Adapter;

class DataStoreIndexAdapter<K,A,B> implements IDataStoreIndex<K,A> {


    private var _adapter:Adapter<A,B>;
    private var _index:IDataStoreIndex<K,B>;

    public function new (adapter:Adapter<A,B>, index:IDataStoreIndex<K,B>){
        _adapter = adapter;
        _index = index;
    }

    public function get(key:K): Promise<Null<A>> {
        return _index.get(key).next(function(resB){
            if (resB == null){
                return Promise.resolve(null);
            }
            var resA = _adapter.toA(resB);
            return resA;
        });
    }   

    public function getMany(keys:Array<K>): Promise<ArrayKV<K,Null<A>>>{
        return _index.getMany(keys).next(function(resB){
            var mappedArray = new ArrayKV<K,Null<A>>();
            mappedArray.resize(resB.length);
            for (i in 0...mappedArray.length){
                var kvB = resB[i];
                if (kvB.value == null){
                    mappedArray[i] = new KVX(kvB.key, null);
                } else {
                    var valA = _adapter.toA(kvB.value);
                    mappedArray[i] = new KVX(kvB.key, valA);
                }
            }
            return mappedArray;
        });
    }


}