package hawk.store;

import tink.CoreApi;

class InMemoryStringStore implements IStringStore {

    public function new(){}

    private var _data:String = "";

    public function save():Promise<String> {
        return Success(_data);
    }

    public function load(data:String):Promise<Noise> {
        _data = data;
        return Success(Noise);
    }
}