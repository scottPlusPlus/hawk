package hawk.messaging;

class LocalStringChannel<T> extends LocalChannel<T> {

    public function new(key:String, toString:T->String, fromString:String->T){
        var toMsg = function(x:T):Message {
            return Message.fromString(toString(x));
        }
        var fromMsg = function(m:Message):T {
            return fromString(m.toString());
        }
        super(key, toMsg, fromMsg);
    }
}