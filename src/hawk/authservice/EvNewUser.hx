package hawk.authservice;

class EvNewUser implements DataClass {

    public final timestamp: Int;
    public final user:AuthUser;

    public function key():String {
        return "NewUser";
    }

    public static function fromJson(str:String): EvNewUser {
        var parser = new json2object.JsonParser<EvNewUser>();
        return parser.fromJson(str);
    }

    public function toJson():String {
        var writer = new json2object.JsonWriter<EvNewUser>();
        return writer.write(this);
    }

    public static function testExample():EvNewUser {
        return new EvNewUser({
            timestamp:  Date.now().getUTCSeconds(),
            user: AuthUser.testExample()
        });
    }
}