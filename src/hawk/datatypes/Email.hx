package hawk.datatypes;

import hawk.general_tools.adapters.Adapter;
import tink.CoreApi;
import js.html.audio.BiquadFilterNode;

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

	public function validationErrs():Array<String> {
		var errs = new Array<String>();

		if (this != StringTools.trim(this)) {
			errs.push('email should be trim');
		}
		if (this.length > 128) {
			errs.push('email must be less than 128 chars');
		}
		if (!_regex.match(this)) {
			errs.push('invalid email address');
		}
		return errs;
	}

	public static function validOrErr(email:Email):Outcome<Email, Error> {
		var errs = email.validationErrs();
		if (errs.length > 0) {
			return Failure(new Error('Invalid Email: ${errs.join(', ')}'));
		}
		return Success(email);
	}
}
