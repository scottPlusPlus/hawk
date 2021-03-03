package hawk.store;

import tink.CoreApi;


class DatabasePager<T> {

    private var _limit:UInt;
    private var _offset:UInt;
    private var _next:UInt->UInt->Promise<Array<T>>;

    public function new(limit:UInt, next:UInt->UInt->Promise<Array<T>>){
        _limit = limit;
        _offset = 0;
        _next = next;
    }

    public function loadNext():Promise<Array<T>> {
        return _next(_limit, _offset).next(function(v){
            _offset += _limit;
            return v;
        });
    }
}