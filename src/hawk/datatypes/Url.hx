package hawk.datatypes;

import tink.Url;
import hawk.general_tools.adapters.StringTAdapter;
import yaku_beta.valid.Validation;

using yaku_beta.valid.StringValidation;

abstract Url(String) to String {
	// https://ihateregex.io/expr/url/  ¯\_(ツ)_/¯
	static final _regex = ~/https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()!@:%_\+.~#?&\/\/=]*)/i;

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
		return x.normalize();
	}

	public function normalize():Url {
		return new Url(this);
	}

	public static final jsonAdapter = new StringTAdapter(Url.fromJson, Url.toJson);

	public static function validation(x:Url, name:String = "Url"):Validation<Url> {
		var vu = new Validation<Url>(x, name);
		if (x != x.normalize()) {
			vu.addError("is not normal");
		}
		vu.validateObject(x.toString(), name).regex(_regex, "failed url regex");
		return vu;
	}
}
