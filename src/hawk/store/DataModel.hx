package hawk.store;

import tink.core.Error;
import hawk.general_tools.adapters.Adapter;

class DataModel<T> {
    public var fields:Array<DataField>;
    public var adapter:Adapter<T,DataRow>;
    public var example:T;
    public function new(){}

    public function validationErrors():Array<String>{
        var errs = new Array<String>();
        if (example == null){
            errs.push('example cannot be null');
        } else {
            var exampleRows = adapter.toB(example);
            if (exampleRows.length() != fields.length){
                errs.push ('DataRow should have same number of DataFields');
            }
        }
        for (f in fields){
            var ferrs = f.validationErrors();
            if (ferrs.length != 0){
                errs = errs.concat(ferrs);
            }
        }
        return errs;
    }
}