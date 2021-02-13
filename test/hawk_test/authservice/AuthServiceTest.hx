package hawk_test.authservice;

import hawk.general_tools.adapters.Adapter;
import hawk.store.InMemoryKVStore;
import hawk.authservice.EvNewUser;
import hawk.testutils.TestLogger;
import hawk.datatypes.Password;
import tink.CoreApi.Outcome;
import tink.core.Noise;
import tink.core.Error;
import hawk.messaging.LocalChannel;
import hawk.authservice.AuthUser;
import hawk.datatypes.Email;
import zenlog.Log;
import hawk.authservice.AuthService;
import hawk.core.UUID;
import utest.Assert;


using hawk.util.OutcomeX;
using hawk.util.PromiseX;
using hawk.util.NullX;
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
			var err = o.failure().nullSure();
			Assert.equals(ErrorCode.Unauthorized, err.code);
			async.done();
			TestLogger.setDebug(false);
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
				TestLogger.setDebug(false);
				return Noise;
			})
			.eager();
	}

	function testGoodRegisterLogin(async:utest.Async) {
		TestLogger.setDebug(true);
		Log.debug('testGoodRegisterLogin');
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
				TestLogger.setDebug(false);
				return Noise;
			})
			.eager();
	}

	function testGoodRegisterBadLoginFails(async:utest.Async) {
		Log.debug('testGoodRegisterBadLoginFails');
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
				var err = o.failure().nullSure();
				Assert.equals(ErrorCode.Unauthorized, err.code);
				async.done();
				TestLogger.setDebug(false);
				return Noise;
			})
			.eager();
	}

	function testDoubleRegisterFails(async:utest.Async){
		TestLogger.setDebug(true);
		Log.debug('testDoubleRegisterFails');
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

	function authServiceTester():AuthService {
		var authUserAdapter = new Adapter<AuthUser,String>(AuthUser.toJson, AuthUser.fromJson);
		var store = new InMemoryKVStore<Email, AuthUser>(Email.stringAdapter(), authUserAdapter);

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
