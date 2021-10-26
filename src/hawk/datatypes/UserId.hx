package hawk.datatypes;

import hawk.general_tools.adapters.Adapter;

/*
* A UUID to reprsent a UserId
*/
abstract UserId(UUID) to UUID from UUID {

    public function new(id:UUID){
        this = id;
    }

    @:from
    static public function fromString(s:String) {
      return new UserId(s);
    }
  
    @:to
    public function toString() {
      return this;
    }

    public static function stringAdapter():Adapter<UserId,String> {
        var toStr = function(x:UserId):String {
          return x.toString();
        }
        return new Adapter<UserId,String>(toStr, UUID.fromString);
      }
}