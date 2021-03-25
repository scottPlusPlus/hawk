package hawk.authservice;

import hawk.datatypes.Timestamp;
import hawk.messaging.Message;
import hawk.general_tools.adapters.Adapter;

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

    public static function toJson(ev:EvNewUser):String {
        var writer = new json2object.JsonWriter<EvNewUser>();
        return writer.write(ev);
    }

    public static function testExample():EvNewUser {
        return new EvNewUser({
            timestamp:  Timestamp.now(),
            user: AuthUser.testExample()
        });
    }

    public static function toMessage(ev:EvNewUser):Message {
        var str = toJson(ev);
        var msg = Message.fromString(str);
        return msg;
    }

    public static function fromMessage(msg:Message):EvNewUser {
        var str = msg.toString();
        var ev = fromJson(str);
        return ev;
    }

    public static function stringAdapter():Adapter<EvNewUser,String> {
        return new Adapter<EvNewUser,String>(toJson, fromJson);
    }
}