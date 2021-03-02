package hawk.authservice;

import hawk.datatypes.Timestamp;
import hawk.messaging.Message;

class EvNewUser implements DataClass {

    public final timestamp: Timestamp;
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
            timestamp:  Timestamp.now(),
            user: AuthUser.testExample()
        });
    }

    public static function toMessage(ev:EvNewUser):Message {
        var str = ev.toJson();
        var msg = Message.fromString(str);
        return msg;
    }

    public static function fromMessage(msg:Message):EvNewUser {
        var str = msg.toString();
        var ev = fromJson(str);
        return ev;
    }
}