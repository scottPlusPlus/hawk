package hawk.util;

import haxe.Constraints.IMap;
import thx.AnonymousMap;

class Json {

    private static var _writers:CommonJsonWriters;
    private static var _readers:CommonJsonReaders;

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

    public static function jsonToAnonMap(json:String):IMap<String,String> {
        var obj = haxe.Json.parse(json);
        return new AnonymousMap(obj);
    }

    public static function read():CommonJsonReaders {
        if (_readers == null){
            _readers = new CommonJsonReaders();
        }
        return _readers;
    }

    public static function write():CommonJsonWriters {
        if (_writers == null){
            _writers = new CommonJsonWriters();
        }
        return _writers;
    }
}


class CommonJsonWriters {

    public function new(){}

    public function fromArrayOfString(x:Array<String>):String {
        var writer = new json2object.JsonWriter<Array<String>>();
        return writer.write(x);
    }

    public function fromArrayOfInt(x:Array<Int>):String {
        var writer = new json2object.JsonWriter<Array<Int>>();
        return writer.write(x);
    }

    public function fromMapOfStringString(x:Map<String,String>):String {
        var writer = new json2object.JsonWriter<Map<String,String>>();
        return writer.write(x);
    }
}

class CommonJsonReaders {

    public function new(){}

    public function toArrayOfString(json:String):Array<String>{
        var parser = new json2object.JsonParser<Array<String>>();
        return parser.fromJson(json);
    }

    public function toArrayOfInt(json:String):Array<Int>{
        var parser = new json2object.JsonParser<Array<Int>>();
        return parser.fromJson(json);
    }

    public function toMapOfStringString(json:String):Map<String,String> {
        var parser = new json2object.JsonParser<Map<String,String>>();
        return parser.fromJson(json);
    }
}