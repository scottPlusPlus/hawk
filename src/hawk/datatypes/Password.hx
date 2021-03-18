package hawk.datatypes;

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
		var errs = new Array<String>();

		if (this != StringTools.trim(this)) {
			errs.push('password should be trim');
		}
		if (this.length < 8) {
			errs.push('password should be at least 8 characters');
		}
		if (this.length > 128) {
			errs.push('password must be less than 128 chars');
		}
		return errs;
	}

	public static function validOrErr(password:Password):Outcome<Password, Error> {
		var errs = password.validationErrs();
		if (errs.length > 0) {
			return Failure(new Error('Invalid Password: ${errs.join(', ')}'));
		}
		return Success(password);
	}
}
