package hawk.weberror;

import hawk.datatypes.Timestamp;
import hawk.datatypes.UUID;

class Data  {
    public var publicMsg:String;
    public var context:Array<String> = [];
    public var uid:UUID;
    public var time:Timestamp;
    public function new(){
        uid = UUID.gen();
        time = Timestamp.now();
    }
}