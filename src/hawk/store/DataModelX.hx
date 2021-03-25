package hawk.store;

class DataModelX {

    public static function stringAdapter<T>(model:DataModel<T>):Adapter<T,String>{
		var toStr = function(obj:T):String {
			var imap = model.adapter.toB(obj);
			var m = new Map<String,String>();
			IMapX.copyTo(imap, m);
			return Json.write().fromMapOfStringString(m);
		}

		var toObj = function(str:String):T {
			var m = Json.read().toMapOfStringString(str);
			return model.adapter.toA(m);
		}

		return new Adapter(toStr, toOBj);
	}
}