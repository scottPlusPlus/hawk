package hawk.store;

import tink.CoreApi;

class InMemoryStringStore implements IStringStore {

    public function new(){}

    private var _data:String = "";

    public function load():Promise<String> {
        return Success(_data);
    }

    public function save(data:String):Promise<String> {
        _data = data;
        return Success(data);
    }
}