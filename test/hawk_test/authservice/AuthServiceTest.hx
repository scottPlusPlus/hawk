package hawk_test.authservice;

import hawk.authservice.AuthUserStore;
import hawk.store.LocalMemDataStore;
import hawk.authservice.EvNewUser;
import hawk.datatypes.Password;
import tink.CoreApi.Outcome;
import tink.core.Noise;
import tink.core.Error;
import hawk.messaging.LocalChannel;
import hawk.datatypes.Email;
import zenlog.Log;
import hawk.authservice.AuthService;
import hawk.datatypes.UUID;
import utest.Assert;


using yaku_core.OutcomeX;
using yaku_core.PromiseX;
using yaku_core.NullX;
using hawk.testutils.PromiseTestUtils;

class AuthServiceTest extends utest.Test {
	// @:timeout(600)
	function testSanity() {
		var service = authServiceTester();
		Assert.notNull(service);

		var user = UUID.gen();
		var tok:String = service.genToken(user);
		Assert.isTrue(tok.length > 0);
		Log.info("token:");
		Log.info(tok);
	}

	function testBadLoginFails(async:utest.Async) {
		Log.debug('testBadLoginFails');
		var service = authServiceTester();

		service.signIn("some@email.com", "anypassword").map(function(o:Outcome<AuthResponse, Error>) {
			Log.debug('testBadLoginFails handle outcome');
			Assert.isTrue(o.isFailure());
			var err = o.failure().nullThrows();
			Assert.equals(ErrorCode.Unauthorized, err.code);
			async.done();
			//TestLog.setDebug(false);
			return Noise;
		}).eager();
	}

	function testRegisterRejectsBadEmailPass(async:utest.Async) {
		Log.debug('testRegisterRejectsBadEmailPass');
		var service = authServiceTester();

		service.register("bademail", "anypassword")
			.flatMap(function(o:Outcome<AuthResponse, Error>) {
				Assert.isTrue(o.isFailure());
				return service.register("good@email.com", "bp");
			})
			.flatMap(function(o:Outcome<AuthResponse, Error>) {
				Assert.isTrue(o.isFailure());
				async.done();
				//TestLog.setDebug(false);
				return Noise;
			})
			.eager();
	}

	function testGoodRegisterLogin(async:utest.Async) {
		var service = authServiceTester();

		var mail:Email = "some@email.com";
		var pass:Password = "anypassword";
		var res:AuthResponse;

		service.register(mail, pass).logOutcome()
			.next(function(r:AuthResponse) {
				res = r;
				return Noise;
			})
			.thenWait(100)
			.next(function(_) {
				return service.signIn(mail, pass);
			})
			.next(function(r:AuthResponse) {
				Assert.isTrue(r.token.toString().length > 0);
				var actor = service.actorFromToken(r.token).sure();
				Assert.equals(res.id, actor);
				async.done();
				//TestLog.setDebug(false);
				return Noise;
			})
			.eager();
	}

	function testGoodRegisterBadLoginFails(async:utest.Async) {
		var service = authServiceTester();

		var mail:Email = "some@email.com";
		var pass:Password = "anypassword";

		service.register(mail, pass)
			.thenWait(100)
			.next(function(_) {
				return service.signIn(mail, pass + "bad");
			})
			.flatMap(function(o:Outcome<AuthResponse, Error>) {
				Log.debug('testBadLoginFails handle outcome');
				Assert.isTrue(o.isFailure());
				var err = o.failure().nullThrows();
				Assert.equals(ErrorCode.Unauthorized, err.code);
				async.done();
				//TestLog.setDebug(false);
				return Noise;
			})
			.eager();
	}

	function testDoubleRegisterFails(async:utest.Async){
		var service = authServiceTester();

		var mail:Email = "some@email.com";
		var pass:Password = "anypassword";

		service.register(mail, pass)
			.map(function(o:Outcome<AuthResponse,Error>){
				Assert.isTrue(o.isSuccess());
				return Noise;
			})
			.next(function(_) {
				return service.register(mail, pass);
			})
			.map(function(o:Outcome<AuthResponse,Error>){
				Assert.isTrue(o.isFailure());
				async.done();
				return Noise;
			}).eager();
	}

	function testDisplayNames(async:utest.Async){
		var service = authServiceTester();

		var pass:Password = "somepass";
		var mail1:Email = "some@mail.com";
		var mail2:Email = "another@mail.com";

		var user1ID:UUID;
		var user2ID:UUID;

		service.register(mail1, pass).next(function(res){
			Log.debug("finished first register");
			user1ID = res.id;
			return service.register(mail2, pass).next(function(res2){
				user2ID = res2.id;
				Log.debug('got both user ids... ${user2ID}  ');
				return Noise;
			});
		}).thenWait(100).next(function(_){
			Log.debug('CALL get displayNames...');
			return service.displayNames([user1ID, user2ID]).assertNoErr().next(function(res){
				var map = new Map<UUID,String>();
				for (kv in res){
					map.set(kv.key, kv.value);
				};
				Assert.equals(2, res.length);
				Assert.same(mail1, map.get(user1ID));
				Assert.same(mail2, map.get(user2ID));
				return Noise;
			});
		}).closeTestChain(async);
	}

	function authServiceTester():AuthService {
		var localStore = new LocalMemDataStore(AuthUserStore.model());
		var store = new AuthUserStore(localStore);

		var channel = new LocalChannel("authNewUser", EvNewUser.toMessage, EvNewUser.fromMessage);

		// specify the type of the deps to force using interface
		var deps:AuthServiceDeps = {
			tokenSecret: function() {
				return "super duper secret";
			},
			tokenIssuer: "hawk auth service",
			userStore: store,
			newUserPub: channel,
			newUserSub: channel,
		};

		return new AuthService().init(deps);
	}
}
