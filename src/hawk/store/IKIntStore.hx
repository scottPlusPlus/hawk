package hawk.store;


import tink.CoreApi.Promise;
import tink.CoreApi.Noise;
import tink.CoreApi.Error;
import tink.CoreApi.Outcome;

interface IKIntStore<K> {

    function exists(key:K):Promise<Bool>;

    function get(key:K):Promise<Int>;

    function set(key:K, value:Int):Promise<Int>;

    function add(key:K, value:Int):Promise<Int>;

    function remove(key:K):Promise<Noise>;
    
}