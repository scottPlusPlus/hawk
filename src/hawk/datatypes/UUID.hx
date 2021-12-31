package hawk.datatypes;

import yaku_core.CommonSorters;
import hawk.general_tools.adapters.Adapter;
import uuid.*;

abstract UUID(String) {

    private function new(str:String){
        this = str; 
    }

    @:from
    static public function fromString(s:String) {
      return new UUID(s);
    }
  
    @:to
    public function toString() {
      return this;
    }

    public static inline function gen():UUID {
        var nano = Uuid.nanoId();
        return new UUID(nano);
    }

    public static function stringAdapter():Adapter<UUID,String> {
      var toStr = function(x:UUID):String {
        return x.toString();
      }
      return new Adapter<UUID,String>(toStr, UUID.fromString);
    }

    public static inline function castArrayIn(v:Array<UUID>):Array<String>{
      var res:Array<String> = cast v;
      return res;
      
      // return v.map(function(x):String{
      //   return x.toString();
      // });
    }

    public static inline function castArrayOut(v:Array<String>):Array<UUID>{
      var res:Array<UUID> = cast v;
      return res;
      //return v.map(fromString);
    }

    public static function sortAscending(a:UUID, b:UUID):Int {
      return CommonSorters.stringsAscending(a, b);
    }
    
}