package hawk.datatypes;

import hawk.general_tools.adapters.StringTAdapter;

abstract Url(String) to String {

	private function new(str:String) {
		this = str;
	}

	@:from
	static public function fromString(s:String) {
		//TODO - ensure it's an actual url
		return new Url(s);
	}

	@:to
	public function toString():String {
		return this;
	}

	public static function fromJson(j:String):Url {
		return new Url(j);
	}

	public static function toJson(x:Url):String {
		return x;
	}

	public static final jsonAdapter = new StringTAdapter(Url.fromJson, Url.toJson);
}