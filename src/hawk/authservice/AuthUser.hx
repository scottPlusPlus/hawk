package hawk.authservice;

import hawk.datatypes.Email;
import hawk.core.UUID;

class AuthUser implements DataClass {
    public final id:UUID;
    public final email:Email;
    public final salt:UUID;
    public final passHash:String;

    public static function fromJson(str:String): AuthUser {
        var parser = new json2object.JsonParser<AuthUser>();
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

        return new AuthUser({
            id: UUID.gen(),
            email: "test@test.com",
            salt: salt,
            passHash: passHash
        });
    }
}


