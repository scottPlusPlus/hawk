package hawk.datatypes;

import yaku_beta.valid.StringValidator;
import hawk.general_tools.adapters.Adapter;
import tink.CoreApi;

abstract Password(String) {
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

	public function validationErrs():Array<String> {
		// var validator = new Validator<String>(("Password"))
		// .minLength(8)
		// .maxLength(128)
		// .isTrim();
		// return validator.errors(this);
		return [];
	}

	public static function validOrErr(password:Password):Outcome<Password, Error> {
		var errs = password.validationErrs();
		if (errs.length > 0) {
			return Failure(new Error('Invalid Password: ${errs.join(', ')}'));
		}
		return Success(password);
	}
}
