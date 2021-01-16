package hawk.util;

import haxe.Constraints.IMap;
import thx.AnonymousMap;
import tink.http.Fetch.CompleteResponse;

class Json {

    public static function mapToJson(map:IMap<String,String>):String {
        var res = '{';
        for (kv in map.keyValueIterator()){
            res += '"${kv.key}":"${kv.value}",';
        }
        res = res.substr(0, res.length -1); //removing last ,
        res += '}';
        return res;
    }

    public static function anonToJson(obj:Dynamic):String {
        var map = new AnonymousMap<String>(obj);
        return mapToJson(map);
    }

    public static function jsonResponseToMap(res: tink.http.CompleteResponse):IMap<String,String> {
        var obj = haxe.Json.parse(res.body);
        return new AnonymousMap(obj);
    }
}