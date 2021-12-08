package hawk.datatypes;

import yaku_beta.valid.Validation;
import hawk.general_tools.adapters.Adapter;
import tink.CoreApi;

using yaku_beta.valid.StringValidation;

abstract Password(String) to String {
	public function new(str:String) {
		this = str;
	}

	@:from
	static public function fromString(s:String) {
		return new Password(s);
	}

	@:to
	public function toString() {
		return this;
	}

	public static function stringAdapter():Adapter<Password, String> {
		var toStr = function(p:Password):String {
			return p.toString();
		}
		return new Adapter<Password, String>(toStr, Password.fromString);
	}

	public static function validation(password:Password, name:String = "Password"):Validation<String>{
		var v = new Validation<String>(password, name);
		v.minLength(8);
		v.maxLength(128);
		return v;
	}

}
