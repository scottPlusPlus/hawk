package hawk_test.datatypes;

import hawk.datatypes.UserId;
import hawk.datatypes.UUID;
import utest.Assert;

class UserIdTest extends utest.Test {
	function testCompares() {
        var u1 = UUID.gen();
        var u2 = UUID.gen();

        var userId1:UserId = u1;
        var userId2:UserId = u2;

        Assert.isFalse(userId1 == userId2);

        var copy =  UserId.fromString(userId1.toString());
        Assert.isTrue(userId1 == copy);
    }

    function testAdapter(){
        var user:UserId = UUID.gen();
        var adapter = UUID.jsonAdapter;
        var str = adapter.toString(user);
        var user2 = adapter.fromString(str);
        Assert.isTrue(user == user2);
    }
}
