package hawk.authservice;

import hawk.general_tools.adapters.Adapter;
import zenlog.Log;
import hawk.async_iterator.AsyncIterator;
import hawk.store.*;
import tink.CoreApi;


abstract AuthUserStore(IDataStore<AuthUser>) {
    
    public function new(store:IDataStore<AuthUser>){
        this = store;
    }

    public inline function create(data:AuthUser):Promise<IDataItem<AuthUser>>{
        return this.create(data);
    }

    public inline function indexByID():IDataStoreIndex<String, AuthUser> {
        return this.getIndexByColName("uid");
    }

    public inline function indexByName():IDataStoreIndex<String, AuthUser> {
        return this.getIndexByColName("name");
    }

    public inline function indexByEmail():IDataStoreIndex<String, AuthUser> {
        return this.getIndexByColName("email");
    }
    
    public inline function iterator():AsyncIterator<IDataItem<AuthUser>>{
        return this.iterator();
    };

    public static function model(): DataModel<AuthUser> {
        var toRow = function(u:AuthUser):DataRow {
			return [u.id, u.email, u.displayName, u.salt, u.passHash];
		};
		var toUser = function(r:DataRow):AuthUser {
			var arr = r.toArray();
			var u = new AuthUser();
			u.id = arr[0];
            u.email = arr[1];
            u.displayName = arr[2];
            u.salt = arr[3];
            u.passHash = arr[4];
			return u;
		};
		Log.debug("create new table 2");
		var adapter = new Adapter<AuthUser, DataRow>(toRow, toUser);
		var fields = new Array<DataField>();
		fields.push(new DataField("uid", true));
        fields.push(new DataField("email", true));
		fields.push(new DataField("name", true));
        fields.push(new DataField("salt", false));
        fields.push(new DataField("passhash", false));

		var model = new DataModel<AuthUser>();
		model.adapter = adapter;
		model.fields = fields;
        model.example = AuthUser.testExample();

        return model;
    }

}