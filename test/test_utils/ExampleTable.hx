package test_utils;

import hawk.store.IDataStoreIndex;
import hawk.store.DataModel;
import hawk.store.DataField;
import hawk.general_tools.adapters.Adapter;
import zenlog.Log;
import hawk.store.DataRow;
import hawk.store.LocalDataStore;

class ExampleTable extends LocalDataStore<ExampleUser> {
	public function new() {
		Log.debug("try create new table");
		var toRow = function(u:ExampleUser):DataRow {
			return [u.id, u.name, u.email, Std.string(u.score)];
		};
		var toUser = function(r:DataRow):ExampleUser {
			var arr = r.toArray();
			var u = new ExampleUser(arr[1], arr[2]);
			u.id = arr[0];
			u.score = Std.parseInt(arr[3]);
			return u;
		};
		Log.debug("create new table 2");
		var adapter = new Adapter<ExampleUser, DataRow>(toRow, toUser);
		var fields = new Array<DataField>();
		fields.push(new DataField("idx", true));
		fields.push(new DataField("name", true));
		fields.push(new DataField("email", false));
		fields.push(new DataField("score", false));

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
