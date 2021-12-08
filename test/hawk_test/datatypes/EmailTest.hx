package hawk_test.datatypes;

import hawk.datatypes.Email;
import utest.Assert;

class EmailTest extends utest.Test {
	function testValidates() {
        var attempt = Email.validation("mymail@gmail.com").asOutcome();
        Assert.isTrue(attempt.isSuccess());

        attempt = Email.validation("gibberish").asOutcome();
        Assert.isFalse(attempt.isSuccess());
    }
}
