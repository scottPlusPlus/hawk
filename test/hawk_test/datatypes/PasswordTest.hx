package hawk_test.datatypes;


import hawk.datatypes.Password;
import utest.Assert;

using hawk.util.OutcomeX;

class PasswordTest extends utest.Test {

	function testValidates() {

        var attempt = Password.validOrErr("short"); //too short
        Assert.isTrue(attempt.isFailure());

        var longPass = "1234567890";
        while (longPass.length < 128){
            longPass += longPass;
        }

        attempt = Password.validOrErr(longPass);
        Assert.isTrue(attempt.isFailure());

        attempt = Password.validOrErr("some_fair_password");
        Assert.isTrue(attempt.isSuccess());
    }
}
