package hawk.async_iterator;

import utest.Async;
import tink.CoreApi;
import hawk.general_tools.adapters.Adapter;

class AsyncIteratorAdapter<A,B> {

    private var _adapter:Adapter<A,B>;
    private var _iterator:AsyncIterator<B>;

    public function new(adapter:Adapter<A,B>, iterator:AsyncIterator<B>){
        _adapter = adapter;
        _iterator = iterator;
    }

    public function next():Promise<A> {
        return _iterator.next().next(_adapter.toA);
    }

	public function hasNext():Promise<Bool>{
        return _iterator.hasNext();
    }
}