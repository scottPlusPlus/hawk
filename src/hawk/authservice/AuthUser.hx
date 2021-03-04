package hawk.authservice;

import zenlog.Log;
import hawk.datatypes.Email;
import hawk.datatypes.UUID;

class AuthUser {
    public var id:UUID;
    public var email:Email;
    public var displayName:String;
    public var salt:UUID;
    public var passHash:String;

    public function new(){}
    
    public static function fromJson(str:String): AuthUser {
        var parser = new json2object.JsonParser<AuthUser>();
        var user = parser.fromJson(str);
        if (user == null){
            Log.error('failed to parse AuthUser from:  ${str}');
            for (e in parser.errors){
                Log.error('-- ' + e);
            }
        }
        return parser.fromJson(str);
    }

    public static function toJson(user:AuthUser):String {
        var writer = new json2object.JsonWriter<AuthUser>();
        return writer.write(user);
    }

    @:access(hawk.authservice.AuthService.hashPass)
    public static function testExample():AuthUser {
        var salt = UUID.gen();
        var passHash = AuthService.hashPass("password", salt);

        var user = new AuthUser();
        user.id = UUID.gen();
        user.email = "test@test.com";
        user.salt = salt;
        user.passHash = passHash;
        user.displayName = "testUser";

        return user;
    }
}


