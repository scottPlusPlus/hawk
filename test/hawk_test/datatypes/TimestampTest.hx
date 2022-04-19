package hawk_test.datatypes;

import thx.Time;
import hawk.datatypes.Timestamp;
import utest.Assert;
import tink.core.Outcome;
import zenlog.Log;

using yaku_core.OutcomeX;

class TimestampTest extends utest.Test {
	function testMath() {
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

		for (c in passCases) {
			var attempt = Timestamp.fromFormString(c);
			Assert.isTrue(attempt.isSuccess());
		}
		for (c in failCases) {
			var attempt = Timestamp.fromFormString(c);
			Assert.isFalse(attempt.isSuccess());
		}
	}

	function testJson() {
		var ts1 = Timestamp.now();
		var j = Timestamp.toJson(ts1);
		var ts2 = Timestamp.fromJson(j);
		Assert.same(ts1.toInt(), ts2.toInt());
	}

	function testToString() {
		var now = Timestamp.now();
		Log.debug(now);
        Log.debug('something like ${now} this');
		Assert.pass();
	}
}
