package hawk.store;

import hawk.store.IDataStore;
import hawk.store.DataModel;
import tink.CoreApi;

interface IDataStoreFactory {
    function get<T>(name:String, model:DataModel<T>):Promise<IDataStore<T>>;
}