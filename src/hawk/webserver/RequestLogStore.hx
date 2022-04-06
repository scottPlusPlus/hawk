package hawk.webserver;

import hawk.datatypes.Timestamp;
import hawk.store.DataModel;
import hawk.store.DataFieldType;
import hawk.store.DataField;
import hawk.general_tools.adapters.Adapter;
import hawk.store.IDataStore;
import hawk.webserver.RequestLog;

abstract RequestLogStore(IDataStore<RequestLog>) {
	private static final fid = "id";
	private static final fip = "fip";
	private static final ftime = "time";
	private static final froute = "route";

	public function new(store:IDataStore<RequestLog>) {
		this = store;
	}

	public inline function create(data:RequestLog):Promise<RequestLog> {
		return this.create(data);
	}

	public inline function indexByID():IDataStoreIndex<String, RequestLog> {
		return this.getIndexByColName(fid);
	}

	public inline function iterator():AsyncIterator<RequestLog> {
		return this.iterator();
	};

	public static function model():DataModel<RequestLog> {
		var toMap = function(d:RequestLog):IMap<String, String> {
			var m = new Map<String, String>();
			m.set(fid, Std.string(d.id));
			m.set(fip, d.ip);
			m.set(ftime, Timestamp.toString(d.time));
			m.set(froute, d.route);
			return m;
		};
		var toX = function(data:IMap<String, String>):RequestLog {
			var x = new RequestLog("", "");
			x.id = data.get(fid);
			x.ip = data.get(fip);
			x.route = data.get(froute);
			x.time = Timestamp.fromString(data.get(ftime));
			return x;
		};
		var adapter = new Adapter<RequestLog, IMap<String, String>>(toMap, toX);
		var fields = new Array<DataField>();
		fields.push(new DataField(fid, DataFieldType.Primary));
		fields.push(new DataField(fip));
		fields.push(new DataField(froute));
		fields.push(new DataField(ftime));

		var model = new DataModel<RequestLog>();
		model.adapter = adapter;
		model.fields = fields;
		model.example = RequestLog.testExample();

		return model;
	}
}
