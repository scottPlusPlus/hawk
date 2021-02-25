package hawk.async_iterator;

import tink.CoreApi;

class AsyncIteratorWrapper<T> {

    private var _iterator:Iterator<T>;

    public function new(iterator:Iterator<T>){
        _iterator = iterator;
    }

    public function next():Promise<T> {
        return _iterator.next();
    }
	
    public function hasNext():Promise<Bool>{
        return _iterator.hasNext();
    }
}