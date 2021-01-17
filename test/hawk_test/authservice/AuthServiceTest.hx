package hawk_test.authservice;

import hawk.authservice.EvNewUser;
import hawk.testutils.TestLogger;
import hawk.datatypes.Password;
import tink.CoreApi.Outcome;
import tink.core.Noise;
import tink.core.Error;
import hawk.messaging.LocalChannel;
import hawk.authservice.AuthUser;
import hawk.datatypes.Email;
import hawk.store.InMemoryKVStore.InMemoryKVPStore;
import zenlog.Log;
import hawk.authservice.AuthService;
import hawk.core.UUID;
import utest.Assert;


using hawk.util.OutcomeX;
using hawk.util.PromiseX;
using hawk.util.NullX;

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

		service.signIn("some@email.com", "anypassword").map(function(o:Outcome<SignInResponse, Error>) {
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
			.flatMap(function(o:Outcome<RegisterResponse, Error>) {
				Assert.isTrue(o.isFailure());
				return service.register("good@email.com", "bp");
			})
			.flatMap(function(o:Outcome<RegisterResponse, Error>) {
				Assert.isTrue(o.isFailure());
				async.done();
				TestLogger.setDebug(false);
				return Noise;
			})
			.eager();
	}

	function testGoodRegisterLogin(async:utest.Async) {
		Log.debug('testGoodRegisterLogin');
		var service = authServiceTester();

		var mail:Email = "some@email.com";
		var pass:Password = "anypassword";
		var res:RegisterResponse;

		service.register(mail, pass)
			.next(function(r:RegisterResponse) {
				res = r;
				return Noise;
			})
			.thenWait(100)
			.next(function(_) {
				return service.signIn(mail, pass);
			})
			.next(function(r:SignInResponse) {
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
		Log.debug('testGoodRegisterLogin');
		var service = authServiceTester();

		var mail:Email = "some@email.com";
		var pass:Password = "anypassword";

		service.register(mail, pass)
			.thenWait(100)
			.next(function(_) {
				return service.signIn(mail, pass + "bad");
			})
			.flatMap(function(o:Outcome<SignInResponse, Error>) {
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
			.map(function(o:Outcome<RegisterResponse,Error>){
				Assert.isTrue(o.isSuccess());
				return Noise;
			})
			.next(function(_) {
				return service.register(mail, pass);
			})
			.map(function(o:Outcome<RegisterResponse,Error>){
				Assert.isTrue(o.isFailure());
				async.done();
				return Noise;
			}).eager();
	}

	function authServiceTester():AuthService {
		var storedeps = {
			keyToStr: Std.string,
			valToStr: function(val:AuthUser):String {
				return val.toJson();
			},
			valFromStr: AuthUser.fromJson
		};
		var store = new InMemoryKVPStore<Email, AuthUser>(storedeps);

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
