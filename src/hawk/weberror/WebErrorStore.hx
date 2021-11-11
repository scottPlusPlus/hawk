package hawk.weberror;

import haxe.Constraints.IMap;
import hawk.general_tools.adapters.Adapter;
import zenlog.Log;
import hawk.async_iterator.AsyncIterator;
import hawk.store.*;
import hawk.datatypes.UUID;
import hawk.datatypes.Timestamp;

abstract WebErrorStore(IDataStore<WebErrorLog>) {
    
    final fCode = "code";
    final fMessage = "message";
    final fPos = "pos";
    final fPublicMsg = "publicMsg";
    final fTime = "time";
    final fUid = "uid";

    public function new(store:IDataStore<WebErrorLog>){
        this = store;
    }

    public inline function create(data:WebErrorLog):Promise<WebErrorLog>{
        return this.create(data);
    }

    public inline function indexByID():IDataStoreIndex<String, WebErrorLog> {
        return this.getIndexByColName(fUid);
    }

    public inline function indexByTime():IDataStoreIndex<String, WebErrorLog> {
        return this.getIndexByColName(fTime);
    }

    public inline function iterator():AsyncIterator<WebErrorLog>{
        return this.iterator();
    };

    public static function model(): DataModel<WebErrorLog> {
        var toMap = function(x:WebErrorLog):IMap<String,String> {
            var m = new Map<String,String>();
            m.set(fCode, x.code);
            m.set(fMessage, x.message);
            m.set(fPos, x.pos);
            m.set(fPublicMsg, x.publicMsg);
            m.set(fTime, x.time);
            m.set(fUid, x.uid);
			return m;
		};
		var toX = function(data:IMap<String,String>):WebErrorLog {
			var x = new WebErrorLog();
			x.code = Std.parseInt(data.get(fCode));
            x.message = data.get(fMessage);
            x.pos = data.get(fPos);
            x.publicMsg = data.get(fPublicMsg);
            x.time = data.get(fTime);
            x.uid = data.get(fUid);
			return u;
		};

		var adapter = new Adapter<WebErrorLog, IMap<String,String>>(toMap, toX);
		var fields = new Array<DataField>();
		fields.push(new DataField(fUid, DataFieldType.Primary));
        fields.push(new DataField(fCode));
        fields.push(new DataField(fMessage));
        fields.push(new DataField(fPos));
        fields.push(new DataField(fPublicMsg));
        fields.push(new DataField(fTime));

		var model = new DataModel<WebErrorLog>();
		model.adapter = adapter;
		model.fields = fields;
        model.example = WebErrorLog.testExample();

        return model;
    }

}