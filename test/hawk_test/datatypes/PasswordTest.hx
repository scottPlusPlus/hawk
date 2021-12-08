package hawk_test.datatypes;


import hawk.datatypes.Password;
import utest.Assert;

using hawk.util.OutcomeX;

class PasswordTest extends utest.Test {

	function testValidates() {

        var attempt = Password.validation("short").asOutcome(); //too short
        Assert.isTrue(attempt.isFailure());

        var longPass = "1234567890";
        while (longPass.length < 128){
            longPass += longPass;
        }

        attempt = Password.validation(longPass).asOutcome();
        Assert.isTrue(attempt.isFailure());

        attempt = Password.validation("some_fair_password").asOutcome();
        Assert.isTrue(attempt.isSuccess());
    }
}
