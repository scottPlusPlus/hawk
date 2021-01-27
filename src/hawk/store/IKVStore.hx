package hawk.store;


import tink.CoreApi.Promise;
import tink.CoreApi.Noise;
import tink.CoreApi.Error;
import tink.CoreApi.Outcome;

interface IKVStore<K,V> {

    function exists(key:K):Promise<Bool>;

    function get(key:K):Promise<V>;

    function set(key:K, value:V):Promise<Noise>;

    function remove(key:K):Promise<Noise>;
    
}