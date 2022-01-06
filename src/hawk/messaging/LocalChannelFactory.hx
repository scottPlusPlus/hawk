package hawk.messaging;

import hawk.messaging.*;
import tink.CoreApi;

using yaku_core.NullX;

class LocalChannelFactory implements IChannelFactory<String> {

    private var _channels:Map<String,LocalChannel<String>> = [];

    public function new(){}

    public function getPub(name:String):Promise<IPublisher<String>>{
        createChannelIfNotExists(name);
        var channel = _channels.get(name).nullThrows();
        var iface:IPublisher<String> = channel;
        return iface;
    }

    public function getSub(name:String):Promise<ISubscriber<String>>{
        createChannelIfNotExists(name);
        var channel = _channels.get(name).nullThrows();
        var iface:ISubscriber<String> = channel;
        return iface;
    }

    private function createChannelIfNotExists(name:String){
        if (_channels.exists(name)){
            return;
        }
        var ch = new LocalChannel<String>(name, msgFromString, msgToString);
        _channels.set(name, ch);
    }

    private function msgToString(msg:Message):String {
        return msg.toString();
    }

    private function msgFromString(str:String):Message{
        return Message.fromString(str);
    }
}