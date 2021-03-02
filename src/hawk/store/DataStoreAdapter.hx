package hawk.store;

import tink.CoreApi;
import hawk.async_iterator.AsyncIterator;
import hawk.async_iterator.AsyncIteratorAdapter;
import hawk.general_tools.adapters.Adapter;

class DataStoreAdapter<A,B> implements IDataStore<A> {

    private var _adapter:Adapter<A,B>;
    private var _store:IDataStore<B>;

    private var _dataItemAdapter:Adapter<IDataItem<A>,IDataItem<B>>;

    public function new (adapter:Adapter<A,B>, store:IDataStore<B>){
        _adapter = adapter;
        _store = store;

        var diA_toB = function(diA:IDataItem<A>):IDataItem<B> {
            return new DataItemAdapter(_adapter.invert(), diA);
        }
        var diB_toA = function(diB:IDataItem<B>):IDataItem<A> {
            return new DataItemAdapter(_adapter, diB);
        }
        _dataItemAdapter = new Adapter(diA_toB, diB_toA);
    }

    public function create(data:A):Promise<IDataItem<A>>{
        var dataB = _adapter.toB(data);
        return _store.create(dataB).next(function(diB){
            var diA:IDataItem<A> = new DataItemAdapter(_adapter, diB);
            return diA;
        });
    }

    public function getIndexByColName(colName:String):IDataStoreIndex<String, A>{
        var indexB = _store.getIndexByColName(colName);
        var indexA = new DataStoreIndexAdapter(_dataItemAdapter, indexB);
        return indexA;
    }

    public function iterator():AsyncIterator<IDataItem<A>> {
        var iteratorB = _store.iterator();
        return new AsyncIteratorAdapter(_dataItemAdapter, iteratorB);
    }

}