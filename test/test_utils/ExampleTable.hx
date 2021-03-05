package test_utils;

import haxe.Constraints.IMap;
import hawk.store.DataFieldType;
import hawk.store.IDataStoreIndex;
import hawk.store.DataModel;
import hawk.store.DataField;
import hawk.general_tools.adapters.Adapter;
import zenlog.Log;
import hawk.store.LocalDataStore;

class ExampleTable extends LocalDataStore<ExampleUser> {
	public function new() {
		Log.debug("try create new table");
		var toMap = function(u:ExampleUser):IMap<String,String> {
			var m = new Map<String,String>();
			m.set("idx", u.id);
			m.set("name", u.name);
			m.set("email", u.email);
			m.set("score", Std.string(u.score));
			return m;
		};
		var toUser = function(m:IMap<String,String>):ExampleUser {
			var u = new ExampleUser(m.get("name"), m.get("email"));
			u.id = m.get("idx");
			u.score = Std.parseInt(m.get("score"));
			return u;
		};
		Log.debug("create new table 2");
		var adapter = new Adapter<ExampleUser, IMap<String,String>>(toMap, toUser);
		var fields = new Array<DataField>();
		fields.push(new DataField("idx", DataFieldType.Primary));
		fields.push(new DataField("name",  DataFieldType.Unique));
		fields.push(new DataField("email"));
		fields.push(new DataField("score"));

		var model = new DataModel<ExampleUser>();
		model.adapter = adapter;
		model.fields = fields;
		model.example = ExampleUser.example();
		super(model);
	}

	public function indexByName():IDataStoreIndex<String, ExampleUser> {
		return getIndexByColName("name");
	}

	public function indexByID():IDataStoreIndex<String, ExampleUser> {
		return getIndexByColName("idx");
	}
}
