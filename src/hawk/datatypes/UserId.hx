package hawk.datatypes;

import hawk.general_tools.adapters.StringTAdapter;

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

    public static function fromJson(j:String):UserId {
      return new UserId(UUID.fromString(j));
    }
  
    public static function toJson(x:UserId):String {
      return x.toString();
    }
  
    public static final jsonAdapter = new StringTAdapter(UserId.fromJson, UserId.toJson);
}