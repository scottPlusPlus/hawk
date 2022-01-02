package hawk.datatypes;

import hawk.general_tools.adapters.StringTAdapter;
/*
* Represents a user performing actions.  Assumes that the user has been authenticated.
*/

abstract Actor(UUID) to UUID {
    
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

	public static function fromJson(j:String):Actor {
		return new Actor(UUID.fromString(j));
	}

	public static function toJson(x:Actor):String {
		return x.id.toString();
	}

	public static final jsonAdapter = new StringTAdapter(Actor.fromJson, Actor.toJson);
}