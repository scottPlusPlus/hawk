package hawk.store;

import tink.CoreApi;
import hawk.store.IKVStoreReader;

class CustomKVReader<K,V> implements IKVStoreReader<K,V> {

    public var getImpl:K->Promise<Null<V>>;
    public var getManyImpl:Array<K>->Promise<GetManyRes<K,V>>;

    public function new(getImpl:K->Promise<Null<V>>, getManyImpl:Array<K>->Promise<GetManyRes<K,V>>){
        this.getImpl = getImpl;
        this.getManyImpl = getManyImpl;
    }

	public function get(key:K):Promise<Null<V>> {
        return getImpl(key);
    }
	public function getMany(keys:Array<K>):Promise<GetManyRes<K,V>> {
        return getManyImpl(keys);
    }
}