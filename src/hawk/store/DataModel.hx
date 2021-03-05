package hawk.store;

import haxe.Constraints.IMap;
import hawk.general_tools.adapters.Adapter;

class DataModel<T> {
    public var fields:Array<DataField>;
    public var adapter:Adapter<T,IMap<String,String>>;
    public var example:T;
    public function new(){}

    public function validationErrors():Array<String>{
        var errs = new Array<String>();
        if (example == null){
            errs.push('example cannot be null');
        } else {
            var exampleMap = adapter.toB(example);
            for (f in fields){
                var val = exampleMap.get(f.name);
                if (val == null || val.length == 0){
                    errs.push('expected FieldMap to have value for ${f.name}');
                }
            }
        }
        for (i in 0...fields.length){
            var f = fields[i];
            if (i == 0){
                if (f.type !=  DataFieldType.Primary){
                    errs.push('First field type should be Primary Index');
                }
            } else {
                if (f.type ==  DataFieldType.Primary){
                    errs.push('ONLY the first field type should be Primary');
                }
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