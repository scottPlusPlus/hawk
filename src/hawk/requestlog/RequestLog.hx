package hawk.requestlog;

import hawk.datatypes.UUID;
import hawk.datatypes.Timestamp;
import hawk.general_tools.adapters.StringTAdapter;

@:build(hawk.macros.Jsonize.process())
class RequestLog {
    
    public var route:String;
    public var time:Timestamp;
    public var ip:String;
    public var id:UUID;

    public function new(route:String, ip:String){
        this.route = route;
        this.ip = ip;
        this.time = Timestamp.now();
        this.id = UUID.gen();
    }

    public static function testExample():RequestLog {
        return new RequestLog("/api/test", "123.456.789");
    }

	public static final jsonAdapter = new StringTAdapter(RequestLog.fromJson, RequestLog.toJson);
}