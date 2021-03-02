package hawk.store;

import hawk.general_tools.adapters.Adapter;

class DataModel<T> {
    public var fields:Array<DataField>;
    public var adapter:Adapter<T,DataRow>;
    public function new(){}
}