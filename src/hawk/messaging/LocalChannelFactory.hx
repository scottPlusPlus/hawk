package hawk.messaging;

import hawk.general_tools.adapters.Adapter;
import hawk.messaging.*;
import tink.CoreApi;

using yaku_core.NullX;

class LocalChannelFactory implements IChannelFactory<String> {

    private var _channels:Map<String,LocalChannel<String>> = [];

    public function new(){}

    public function getPub<T>(name:String, adapter:Adapter<T,String>):Promise<IPublisher<T>>{
        createChannelIfNotExists(name);
        var channel = _channels.get(name).nullThrows();
        var pubAdapter = new PubAdapter(channel, adapter);
        var iface:IPublisher<T> = pubAdapter;
        return iface;
    }

    public function getSub<T>(name:String, adapter:Adapter<T,String>):Promise<ISubscriber<T>>{
        createChannelIfNotExists(name);
        var channel = _channels.get(name).nullThrows();
        var subAdapter = new SubAdapter(channel, adapter);
        var iface:ISubscriber<T> = subAdapter;
        return iface;
    }

    private function createChannelIfNotExists(name:String){
        if (_channels.exists(name)){
            return;
        }
        var ch = new LocalChannel<String>(name, msgFromString, msgToString);
        _channels.set(name, ch);
    }

    private static inline function msgToString(msg:Message):String {
        return msg.toString();
    }

    private static inline function msgFromString(str:String):Message{
        return Message.fromString(str);
    }
}