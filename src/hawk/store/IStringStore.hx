package hawk.store;

import tink.CoreApi;

interface IStringStore {
    function save():Promise<String>;
    function load(data:String):Promise<Noise>;
}