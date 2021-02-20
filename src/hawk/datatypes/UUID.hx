package hawk.datatypes;

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
    
}