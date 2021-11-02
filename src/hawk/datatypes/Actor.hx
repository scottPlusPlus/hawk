package hawk.datatypes;

import hawk.macros.Jsonize;
/*
* Represents a user performing actions.  Assumes that the user has been authenticated.
*/
abstract Actor(UUID) {
    
    private function new(id:UUID){
        this = id;
    }

    public static function fromId(id:UUID):Actor {
        return new Actor(id);
    }

    public var id(get,never):UUID;
    public function get_id():UUID{
        return this;
    }
}