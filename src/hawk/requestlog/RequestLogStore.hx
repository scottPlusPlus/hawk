package hawk.requestlog;

import hawk.datatypes.Timestamp;
import hawk.general_tools.adapters.Adapter;
import hawk.store.*;
import hawk.requestlog.RequestLog;
import hawk.async_iterator.AsyncIterator;
import tink.CoreApi;
import haxe.Constraints.IMap;

using yaku_core.NullX;

abstract RequestLogStore(IDataStore<RequestLog>) {
	private static final fid = "uid";
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
			x.id = data.get(fid).nullThrows("requestLog id was null");
			x.ip = data.get(fip).nullThrows("requestLog ip was null");
			x.route = data.get(froute).nullThrows("requestLog route was null");
			x.time = Timestamp.fromString(data.get(ftime).orFallback("s"));
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
