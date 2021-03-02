package hawk_test.store;

import tink.CoreApi;
import test_utils.ExampleUser;
import hawk.store.DataStoreAdapter;
import hawk.general_tools.adapters.Adapter;
import test_utils.ExampleTable;
import utest.Assert;
import hawk.store.DebugDataStoreAccess;

using hawk.testutils.PromiseTestUtils;
using hawk.util.PromiseX;

class DebugDataStoreAccessTest extends utest.Test {
	private var _debugStore:DebugDataStoreAccess;
	private var _userStore:ExampleTable;
	private final _storeName = "exampleUsers";

	private var _userX:ExampleUser;
	private var _userY:ExampleUser;
	private var _userZ:ExampleUser;

	public function setup() {
		_userStore = new ExampleTable();
		var adapter = new Adapter(ExampleUser.fromJson, ExampleUser.toJson);
		var strStore = new DataStoreAdapter(adapter, _userStore);

		_userX = new ExampleUser("userX", "userX@mail.com");
		_userY = new ExampleUser("userY", "userY@mail.com");
		_userZ = new ExampleUser("userZ", "userZ@mail.com");

		_debugStore = new DebugDataStoreAccess();
		_debugStore.register(_storeName, strStore);
	}

	public function testGet(async:utest.Async) {
		_userStore.create(_userX).next(function(_) {
			return _debugStore.query("get", _storeName, "name", _userX.name).next(function(res) {
				var expected = ExampleUser.toJson(_userX);
				Assert.same(expected, res);
				return Noise;
			});
		}).closeTestChain(async);
	}

	public function testCreate(async:utest.Async) {
		var val = ExampleUser.toJson(_userX);
		return _debugStore.query("create", _storeName, "", "", val)
			.next(function(res) {
				Assert.same(val, res);
				return Noise;
			})
			.next(function(_) {
				return _debugStore.query("get", _storeName, "name", _userX.name).next(function(res) {
					Assert.same(val, res);
					return Noise;
				});
			})
			.closeTestChain(async);
	}

	public function testPrint(async:utest.Async) {
		_userStore.create(_userX).next(function(_) {
			return _userStore.create(_userY).next(function(_) {
				return _userStore.create(_userZ);
			});
		}).next(function(_) {
			return _debugStore.query("print", _storeName).next(function(res) {
				for (v in [_userX.name, _userY.name, _userZ.name]) {
					Assert.stringContains(v, res);
				}
				return Noise;
			});
		}).closeTestChain(async);
	}
}
