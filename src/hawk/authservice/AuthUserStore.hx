package hawk.authservice;

import haxe.Constraints.IMap;
import hawk.general_tools.adapters.Adapter;
import zenlog.Log;
import hawk.async_iterator.AsyncIterator;
import hawk.store.*;
import tink.CoreApi;


abstract AuthUserStore(IDataStore<AuthUser>) {
    
    public function new(store:IDataStore<AuthUser>){
        this = store;
    }

    public inline function create(data:AuthUser):Promise<AuthUser>{
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
    
    public inline function iterator():AsyncIterator<AuthUser>{
        return this.iterator();
    };

    public static function model(): DataModel<AuthUser> {
        var toMap = function(u:AuthUser):IMap<String,String> {
            var m = new Map<String,String>();
            m.set("uid", u.id);
            m.set("email", u.email);
            m.set("name", u.displayName);
            m.set("salt", u.salt);
            m.set("pass", u.passHash);
			return m;
		};
		var toUser = function(data:IMap<String,String>):AuthUser {
			var u = new AuthUser();
			u.id = data.get("uid");
            u.email = data.get("email");
            u.displayName = data.get("name");
            u.salt = data.get("salt");
            u.passHash = data.get("pass");
			return u;
		};
		Log.debug("create new table 2");
		var adapter = new Adapter<AuthUser, IMap<String,String>>(toMap, toUser);
		var fields = new Array<DataField>();
		fields.push(new DataField("uid", DataFieldType.Primary));
        fields.push(new DataField("email", DataFieldType.Unique));
		fields.push(new DataField("name", DataFieldType.Unique));
        fields.push(new DataField("salt"));
        fields.push(new DataField("pass"));

		var model = new DataModel<AuthUser>();
		model.adapter = adapter;
		model.fields = fields;
        model.example = AuthUser.testExample();

        return model;
    }

}