package hawk.core;

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
    
}