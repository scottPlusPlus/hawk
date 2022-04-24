package hawk.datatypes;

import yaku_beta.valid.Validation;
import hawk.general_tools.adapters.StringTAdapter;

using yaku_core.OutcomeX;
using yaku_beta.valid.StringValidation;

abstract Email(String) to String {
	// see also: http://emailregex.com/
	static final _regex = ~/[A-Z0-9._%-]+@[A-Z0-9.-]+.[A-Z][A-Z][A-Z]?/i;

	private function new(str:String) {
		this = StringTools.trim(str);
	}

	@:from
	public static function fromString(s:String) {
		return new Email(s);
	}

	@:to
	public function toString() {
		return this;
	}

	public static function fromJson(j:String):Email {
		return new Email(j);
	}

	public static function toJson(x:Email):String {
		return x;
	}

	public static final jsonAdapter = new StringTAdapter(Email.fromJson, Email.toJson);

	public function normalize():Email {
		return new Email(this);
	}

	public static function validation(email:Email, name:String = "Email"):Validation<Email>{
		var ve = new Validation(email, name);
		if (email != email.normalize()){
			ve.addError("Needs to be normalied");
		}

		var v = ve.validateObject(email.toString(), name);
		v.maxLength(128);
		v.regex(_regex, "Invalid email address");
		return ve;
	}
}
