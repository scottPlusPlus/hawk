package hawk_test.datatypes;

import utest.Assert;
import hawk.datatypes.Url;

class UrlTest extends utest.Test {
	function testTrim() {
		var bad = "  http://www.test.com  ";
		var expected = StringTools.trim(bad);

		var urlExplicit = new Url(bad);
		var urlImplicit:Url = bad;

		Assert.same(expected, urlExplicit.toString());
		Assert.same(expected, urlImplicit.toString());
	}
}
