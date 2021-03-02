package hawk.store;

import tink.CoreApi;
import hawk.general_tools.adapters.Adapter;

class DataItemAdapter<A,B> implements IDataItem<A> {

    private var _adapter:Adapter<A,B>;
    private var _item:IDataItem<B>;

    public function new (adapter:Adapter<A,B>, item:IDataItem<B>){
        _adapter = adapter;
        _item = item;
    }

    public function value():A {
        var valB = _item.value();
        var valA = _adapter.toA(valB);
        return valA;
    }

    public function mutate(data:A):Promise<A>{
        var dataB = _adapter.toB(data);
        return _item.mutate(dataB).next(function(resB){
            var resA = _adapter.toA(resB);
            return resA;
        });
    }

    public function delete():Promise<Noise> {
        return _item.delete();
    }

}