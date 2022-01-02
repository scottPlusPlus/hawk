package hawk.datatypes;

import yaku_beta.valid.Validation;
import hawk.general_tools.adapters.StringTAdapter;

using yaku_beta.valid.StringValidation;

//@:build(hawk.macros.Jsonize.process())
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

	public static function fromJson(j:String):Password {
		return new Password(j);
	}

	public static function toJson(x:Password):String {
		return x;
	}

	public static final jsonAdapter = new StringTAdapter(Password.fromJson, Password.toJson);

	public static function validation(password:Password, name:String = "Password"):Validation<String>{
		var v = new Validation<String>(password, name);
		v.minLength(8);
		v.maxLength(128);
		return v;
	}

}
