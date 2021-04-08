package hawk_test.datatypes;


import hawk.datatypes.Timestamp;
import utest.Assert;
import tink.core.Outcome;
import zenlog.Log;

using hawk.util.OutcomeX;

class TimestampTest extends utest.Test {

    function testMath(){
        var five = Timestamp.fromInt(5);
        var two = Timestamp.fromInt(2);
        var three = Timestamp.fromInt(3);

        Assert.isTrue(five > two);
        Assert.isTrue(two < five);
        Assert.equals(three, five - two);
        Assert.equals(five, two + three);
    }

	function testFromFormString() {

        var passCases = ["2021-04-08 12:34:56", "2021-04-08T12:34:56", "2021-04-08 12:34"];
        var failCases = ["asdf", ""];

        for (c in passCases){
            var attempt = Timestamp.fromFormString(c);
            Assert.isTrue(attempt.isSuccess());
        }
        for (c in failCases){
            var attempt = Timestamp.fromFormString(c);
            Assert.isFalse(attempt.isSuccess());
        }
    }
}
