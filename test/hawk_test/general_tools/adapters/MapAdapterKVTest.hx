package hawk_test.general_tools.adapters;

import hawk.general_tools.adapters.Adapter;
import hawk.general_tools.adapters.MapAdapterKV;
import haxe.Constraints.IMap;
import utest.Assert;

class MapAdapterKVTest extends utest.Test {
	private var imap:IMap<Int, Int>;

	public function setup() {
		var adapter = new Adapter<Int,String>(Std.string,  function(val:String):Int {
			return Std.parseInt(val);
		});

		var map = new MapAdapterKV<Int,String,Int,String>(adapter, adapter, new Map<String,String>());
		imap = map;
		imap.set(1, 10); 
		imap.set(2, 20);
		imap.set(3, 30);
	}

	function testGet() {
		Assert.equals(10, imap.get(1));
		Assert.equals(20, imap.get(2));
		Assert.equals(30, imap.get(3));
	}

	function testExists() {
		Assert.equals(true, imap.exists(1));
		Assert.equals(false, imap.exists(42));
	}

	function testRemove() {
		Assert.equals(true, imap.exists(1));
		Assert.equals(true, imap.remove(1));
		Assert.equals(false, imap.exists(1));
		Assert.equals(false, imap.remove(1));
	}

	function testKeys() {
		var keys = imap.keys();
		var actual = collectIterator(keys);
		actual.sort((a, b) -> a - b);
		Assert.same([1, 2, 3], actual);
	}

	function testIterator() {
		var it = imap.iterator();
		var actual = collectIterator(it);
		actual.sort((a, b) -> a - b);
		Assert.same([10, 20, 30], actual);
	}

	function testKeyValueIterator() {
		var it = imap.keyValueIterator();
		var actual = collectIterator(it);
		actual.sort((a, b) -> a.key - b.key);
		var expected = [{key: 1, value: 10}, {key: 2, value: 20}, {key: 3, value: 30}];
		Assert.same(expected, actual);
	}

	function testCopy() {
		var copy = imap.copy();
		Assert.equals(10, copy.get(1));
		copy.set(1, 42);
		Assert.equals(42, copy.get(1));
		Assert.equals(10, imap.get(1));
	}

	function collectIterator<T>(i:Iterator<T>):Array<T> {
		var array = new Array<T>();
		while (i.hasNext()) {
			array.push(i.next());
		}
		return array;
	}
}
