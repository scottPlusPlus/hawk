package hawk.store;

class CommonSerializers {
	public static function string() {
		var res = {
			toString: function(str:String):String {
				return str;
			},
			fromString: function(str:String):String {
				return str;
			}
		};
		return res;
	}
}
