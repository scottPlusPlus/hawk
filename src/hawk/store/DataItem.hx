package hawk.store;

import zenlog.Log;
import tink.CoreApi;
import hawk.general_tools.adapters.Adapter;

class DataItem<T> implements IDataItem<T> {

    private var _adapter:Adapter<T,DataRow>;
    private var _save:Int->DataRow->Promise<Noise>;
    private var _delete:Int->Promise<Bool>;

    private var _id:Int;
    private var _data:Array<String>;


    public function new(deps:DataItemDeps<T>, id:Int, data:DataRow){
        _adapter = deps.adapter;
        _save = deps.save;
        _delete = deps.delete;

        _id = id;
        _data = data;
        Log.debug('new DataItem with id ${id}');
    }

    public function value():T {
        return _adapter.toA(_data);
    }

    public function mutate(data:T):Promise<T>{
        var tmpData = _adapter.toB(data);
        return _save(_id, tmpData).next(function(_){
            Log.debug("done saving...");
            _data = tmpData;
            return value();
        });
    }

    public function delete():Promise<Noise>{
        return _delete(_id).noise();
    }

}

typedef DataItemDeps<T> = {
    adapter:Adapter<T,DataRow>,
    save:Int->DataRow->Promise<Noise>,
    delete:Int->Promise<Bool>
} 