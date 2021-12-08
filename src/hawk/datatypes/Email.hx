package hawk.datatypes;

import yaku_beta.valid.Validation;
import hawk.general_tools.adapters.Adapter;
import tink.CoreApi;

using yaku_core.OutcomeX;
using yaku_beta.valid.StringValidation;

abstract Email(String) {
	// see also: http://emailregex.com/
	static final _regex = ~/[A-Z0-9._%-]+@[A-Z0-9.-]+.[A-Z][A-Z][A-Z]?/i;

	private function new(str:String) {
		this = str;
	}

	@:from
	static public function fromString(s:String) {
		return new Email(s);
	}

	@:to
	public function toString() {
		return this;
	}

	public static function stringAdapter():Adapter<Email, String> {
		var toStr = function(e:Email):String {
			return e.toString();
		}
		return new Adapter<Email, String>(toStr, Email.fromString);
	}

	public static function validation(email:Email, name:String = "Email"):Validation<String>{
		var v = new Validation<String>(email, name);
		v.maxLength(128);
		v.regex(_regex, "Invalid email address");
		return v;
	}
}
