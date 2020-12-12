package test.hawk.datatypes;

import hawk.datatypes.Email;
import utest.Assert;

class EmailTest extends utest.Test {
	function testValidates() {
        var attempt = Email.createValid("mymail@gmail.com");
        Assert.isTrue(attempt.isSuccess());

        attempt = Email.createValid("gibberish");
        Assert.isFalse(attempt.isSuccess());
    }
}
