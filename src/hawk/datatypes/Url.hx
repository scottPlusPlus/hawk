package hawk.datatypes;

import tink.Url;
import hawk.general_tools.adapters.StringTAdapter;

abstract Url(String) to String {
    
	public function new(str:String) {
		var tu:tink.Url = str;
        var s2 = tu.toString();
		this = s2;
	}

	@:from static function fromString(s:String):Url {
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
