package hawk.messaging;

import zenlog.Log;

class LocalStringChannel<T> extends LocalChannel<T> {

    public function new(key:String, toString:T->String, fromString:String->T){
        var toMsg = function(x:T):Message {
            return Message.fromString(toString(x));
        }
        var fromMsg = function(m:Message):T {
            var msgString = m.toString();
            var obj = fromString(msgString);
            if (obj == null){
                Log.error("Failed to deserialize message from:  "  + msgString);
            }
            return obj;
        }
        super(key, toMsg, fromMsg);
    }
}