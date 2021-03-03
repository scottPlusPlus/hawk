package hawk_test.store;

import test_utils.ExampleTable;
import test_utils.ExampleUser;
import hawk.store.IDataItem;
import hawk.store.KV;
import zenlog.Log;
import hawk.testutils.TestLogger;
import tink.CoreApi;
import hawk.store.IDataStoreIndex;
import hawk.datatypes.UUID;
import hawk.datatypes.Email;
import hawk.store.DataField;
import hawk.general_tools.adapters.Adapter;
import hawk.store.DataItem;
import hawk.store.DataRow;
import hawk.store.DataModel;
import hawk.store.LocalDataStore;
import utest.Assert;
import utest.Async;

using hawk.testutils.PromiseTestUtils;
using hawk.util.PromiseX;

class LocalDataStoreTest extends utest.Test {
	private var _userX:ExampleUser;
	private var _userY:ExampleUser;
	private var _userZ:ExampleUser;

	public function setup() {
		_userX = new ExampleUser("userX", "some@email.com");
		_userY = new ExampleUser("userY", "another@email.com");
		_userZ = new ExampleUser("userZ", "fooo@email.com");
	}

	public function testCreateGetSave(async:utest.Async) {
		var table = new ExampleTable();
		var indexByName = table.indexByName();
		table.create(_userX).next(function(_) {
			return indexByName.get(_userX.name).next(function(dr) {
				var foundUser = dr.value();
				Assert.same(_userX, foundUser);
				foundUser.score = 5;
				return dr.mutate(foundUser);
			});
		}).next(function(_) {
			return indexByName.get(_userX.name).next(function(dr) {
				var foundUser = dr.value();
				Assert.same(5, foundUser.score);
				return Noise;
			});
		}).closeTestChain(async);
	}

	public function testProtectConflictsOnNew(async:utest.Async) {
		var table = new ExampleTable();
		var conflictingUser = new ExampleUser(_userX.name, "asdf@mail.com");

		table.create(_userX)
			.next(function(_) {
				return table.create(conflictingUser);
			})
			.assertErrAndContinue('expected err, conflicting name')
			.closeTestChain(async);
		Assert.isTrue(true); // surpress "no assertions" warning
	}

	public function testProtectConflictsOnChange(async:utest.Async) {
		var table = new ExampleTable();
		Promise.NOISE.next(function(_) {
			// create userX, userY
			return table.create(_userX).next(function(_) {
				return table.create(_userY);
			});
		}).next(function(_) {
			// assert cannot change userX name to userY
			return table.indexByName()
				.get(_userX.name)
				.errOnNull()
				.next(function(di) {
					var user = di.value();
					user.name = _userY.name;
					return di.mutate(user);
				})
				.assertErrAndContinue('expected err, conflicting name');
		}).closeTestChain(async);
		Assert.isTrue(true); // surpress "no assertions" warning
	}

	public function testChangingDataFreesConflict(async:utest.Async) {
		var table = new ExampleTable();
		var indexByName = table.indexByName();
		// TODO - finish rest of the tests, cleanly...
		Promise.NOISE.next(function(_) {
			// create userX
			return table.create(_userX);
		}).next(function(_) {
			// change userX name
			return indexByName.get(_userX.name).errOnNull().next(function(di) {
				var foundUser = di.value();
				Assert.same(_userX, foundUser);
				foundUser.name = "NOT" + foundUser.name;
				return di.mutate(foundUser);
			});
		}).next(function(_) {
			// Create new user with userX old name
			var conflictingUser = new ExampleUser(_userX.name, "asdf@mail.com");
			return table.create(conflictingUser);
		}).closeTestChain(async);
	}

	public function testCreateGetRemove(async:utest.Async) {
		// TestLogger.filter.enableDebug = true;
		var table = new ExampleTable();
		var indexByName = table.indexByName();
		table.create(_userX).next(function(_) {
			// get and delete userX
			return indexByName.get(_userX.name).next(function(di) {
				var foundUser = di.value();
				Assert.same(_userX, foundUser);
				return di.delete();
			});
		}).next(function(_) {
			// check userX is now null
			return indexByName.get(_userX.name).next(function(my_di) {
				Assert.isNull(my_di);
				return Noise;
			});
		}).closeTestChain(async);
	}

	public function testGetMany(async:utest.Async) {
		//TestLogger.setDebug(true);
		TestLogger.resetIdent();
		var table = new ExampleTable();
		var indexByName = table.indexByName();

		Promise.NOISE.next(function(_) {
			return table.create(_userX).next(function(_) {
				return table.create(_userY);
			}).next(function(_) {
				return table.create(_userZ);
			});
		}).next(function(_) {
			var fakeName = "fakeNAme";
			var keys = [_userX.name, _userY.name, fakeName];
			var getRes = new Map<String, IDataItem<ExampleUser>>();
			return indexByName.getMany(keys).next(function(res) {
				var items = 0;
				for (kv in res) {
					Log.debug("got kv with " + kv.key);
					items++;
					getRes.set(kv.key, kv.value);
				}
				Assert.equals(3, items);
				var actual = getRes.get(fakeName);
				Assert.isNull(actual);
				actual = getRes.get(_userX.name);
				Assert.same(_userX, actual.value());
				actual = getRes.get(_userY.name);
				Assert.same(_userY, actual.value());
				return Noise;
			});
		}).closeTestChain(async);
	}
}