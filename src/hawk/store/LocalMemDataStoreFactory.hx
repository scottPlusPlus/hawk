package hawk.store;

import hawk.store.IDataStore;
import tink.CoreApi;
import hawk.store.DataModel;
import hawk.store.LocalMemDataStore;

class LocalMemDataStoreFactory implements IDataStoreFactory {

    public function new(){}

    public function get<T>(name:String, model:DataModel<T>):Promise<IDataStore<T>> {
        var store = new LocalMemDataStore(model);
        var iface:IDataStore<T> = store;
        return iface;
    }

}