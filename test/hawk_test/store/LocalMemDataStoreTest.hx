package hawk_test.store;

import test_utils.ExampleTable;
import test_utils.ExampleUser;
import zenlog.Log;
import tink.CoreApi;
import utest.Assert;
import utest.Async;

using yaku_core.PromiseX;
using yaku_core.test_utils.PromiseTestUtils;

class LocalMemDataStoreTest extends utest.Test {
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
			return indexByName.get(_userX.name).next(function(foundUser) {
				Assert.same(_userX, foundUser);
				foundUser.score = 5;
				return table.update(foundUser);
			});
		}).next(function(_) {
			return indexByName.get(_userX.name).next(function(resUser) {
				Assert.same(5, resUser.score);
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
				.next(function(foundUser) {
					foundUser.name = _userY.name;
					return table.update(foundUser);
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
			return indexByName.get(_userX.name).errOnNull().next(function(foundUser) {
				Assert.same(_userX, foundUser);
				foundUser.name = "NOT" + foundUser.name;
				return table.update(foundUser);
			});
		}).next(function(_) {
			// Create new user with userX old name
			var conflictingUser = new ExampleUser(_userX.name, "asdf@mail.com");
			return table.create(conflictingUser);
		}).closeTestChain(async);
	}

	public function testCreateGetRemove(async:utest.Async) {
		var table = new ExampleTable();
		var indexByName = table.indexByName();
		table.create(_userX).next(function(_) {
			// get and delete userX
			return indexByName.get(_userX.name).next(function(foundUser) {
				return table.delete(foundUser);
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
			var getRes = new Map<String, ExampleUser>();
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
				Assert.same(_userX, actual);
				actual = getRes.get(_userY.name);
				Assert.same(_userY, actual);
				return Noise;
			});
		}).closeTestChain(async);
	}
}
