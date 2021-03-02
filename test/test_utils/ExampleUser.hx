package test_utils;

import hawk.datatypes.Email;
import hawk.datatypes.UUID;

class ExampleUser {
	public var id:UUID;
	public var name:String;
	public var email:Email;
	public var score:Int;

	public function new(name:String, email:String) {
		id = UUID.gen();
		this.name = name;
		this.email = email;
		score = 0;
	}

	public static function toJson(x:ExampleUser):String {
		var writer = new json2object.JsonWriter<ExampleUser>();
		return writer.write(x);
	}

	public static function fromJson(x:String):ExampleUser {
		var parser = new json2object.JsonParser<ExampleUser>();
		return parser.fromJson(x);
	}
}