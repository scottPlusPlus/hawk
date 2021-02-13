package hawk_test.general_tools.adapters;

import hawk.general_tools.adapters.IteratorAdapter;
import utest.Assert;

class IteratorAdapterTest extends utest.Test {
	function test() {
		var array = [1, 2, 3];
		var stringIterator = new IteratorAdapter(array.iterator(), Std.string);
		Assert.same(true, stringIterator.hasNext());
		Assert.same("1", stringIterator.next());
		Assert.same(true, stringIterator.hasNext());
		Assert.same("2", stringIterator.next());
		Assert.same(true, stringIterator.hasNext());
		Assert.same("3", stringIterator.next());
		Assert.same(false, stringIterator.hasNext());
	}
}
