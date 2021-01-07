package hawk_test.util;

import tink.core.Option;
import utest.Assert;
import utest.Async;

using hawk.util.OptionX;

class OptionXTest extends utest.Test {
	function testSure() {
		var expected = 42;
		var optionSome = option(expected);
		var actual = optionSome.sure();
		Assert.equals(expected, actual);
	}

	function option(?val:Int):Option<Int> {
		if (val == null) {
			return None;
		}
		return Some(val);
	}
}
