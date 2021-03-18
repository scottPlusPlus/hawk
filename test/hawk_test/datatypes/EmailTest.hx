package hawk_test.datatypes;

import hawk.datatypes.Email;
import utest.Assert;

class EmailTest extends utest.Test {
	function testValidates() {
        var attempt = Email.validOrErr("mymail@gmail.com");
        Assert.isTrue(attempt.isSuccess());

        attempt = Email.validOrErr("gibberish");
        Assert.isFalse(attempt.isSuccess());
    }
}
