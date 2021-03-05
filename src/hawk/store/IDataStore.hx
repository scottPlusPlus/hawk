package hawk.store;

import hawk.async_iterator.AsyncIterator;
import tink.CoreApi;

interface IDataStore<T> {
    function create(obj:T):Promise<T>;
    function update(obj:T):Promise<T>;
    function delete(obj:T):Promise<Bool>;
    function getIndexByColName(colName:String):IDataStoreIndex<String, T>;
    function iterator():AsyncIterator<T>;
} 