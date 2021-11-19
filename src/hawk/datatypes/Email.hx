package hawk.datatypes;

import hawk.general_tools.adapters.Adapter;
import tink.CoreApi;
import yaku_beta.valid.*;

using yaku_core.OutcomeX;

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
		return validator().errors(this);
	}

	public function validOutcome():Outcome<Email,Error> {
		return validator().validOutcome(this).adapt(stringAdapter().toA);
	}

	private static function validator():StringValidator{
		return new StringValidator("Email")
		.maxLength(128)
		.isTrim()
		.regex(_regex, "Invalid email address");
	}
}
