package hawk.store;

import tink.CoreApi;
import hawk.async_iterator.AsyncIterator;
import hawk.async_iterator.AsyncIteratorAdapter;
import hawk.general_tools.adapters.Adapter;

class DataStoreAdapter<A,B> implements IDataStore<A> {

    private var _adapter:Adapter<A,B>;
    private var _store:IDataStore<B>;

    public function new (adapter:Adapter<A,B>, store:IDataStore<B>){
        _adapter = adapter;
        _store = store;

        var diA_toB = function(diA:IDataItem<A>):IDataItem<B> {
            return new DataItemAdapter(_adapter.invert(), diA);
        }
        var diB_toA = function(diB:IDataItem<B>):IDataItem<A> {
            return new DataItemAdapter(_adapter, diB);
        }
    }

    public function create(obj:A):Promise<A>{
        var inB = _adapter.toB(obj);
        return _store.create(inB).next(function(outB){
            return _adapter.toA(outB);
        });
    }

    public function update(obj:A):Promise<A>{
        var inB = _adapter.toB(obj);
        return _store.update(inB).next(function(outB){
            return _adapter.toA(outB);
        });
    }

    public function delete(obj:A):Promise<Bool>{
        var inB = _adapter.toB(obj);
        return _store.delete(inB);
    }

    public function getIndexByColName(colName:String):IDataStoreIndex<String, A>{
        var indexB = _store.getIndexByColName(colName);
        var indexA = new DataStoreIndexAdapter(_adapter, indexB);
        return indexA;
    }

    public function iterator():AsyncIterator<A> {
        var iteratorB = _store.iterator();
        return new AsyncIteratorAdapter(_adapter, iteratorB);
    }

}