package hawk.store;

import tink.CoreApi;

interface IStringStore {
    function load():Promise<String>;
    function save(data:String):Promise<Noise>;
}