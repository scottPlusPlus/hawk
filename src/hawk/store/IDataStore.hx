package hawk.store;

import hawk.async_iterator.AsyncIterator;
import tink.CoreApi;

interface IDataStore<T> {
    function create(data:T):Promise<IDataItem<T>>;
    function getIndexByColName(colName:String):IDataStoreIndex<String, T>;
    function iterator():AsyncIterator<IDataItem<T>>;
}