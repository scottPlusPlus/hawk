package test.hawk.authservice;

import hawk.testutils.TestLogger;
import hawk.datatypes.Password;
import hawk.authservice.Token;
import tink.CoreApi.Outcome;
import tink.core.Noise;
import tink.core.Error;
import hawk.messaging.ISubscriber;
import hawk.messaging.IPublisher;
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

		service.logIn("some@email.com", "anypassword").flatMap(function(o:Outcome<Token, Error>) {
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
			.flatMap(function(o:Outcome<NewUserToken, Error>) {
				Assert.isTrue(o.isFailure());
				return service.register("good@email.com", "bp");
			})
			.flatMap(function(o:Outcome<NewUserToken, Error>) {
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
		var nut:NewUserToken;

		service.register(mail, pass)
			.next(function(nt:NewUserToken) {
				nut = nt;
				return Noise;
			})
			.thenWait(100)
			.next(function(_) {
				return service.logIn(mail, pass);
			})
			.next(function(t:Token) {
				Assert.isTrue(t.toString().length > 0);
				var actor = service.actorFromToken(t).sure();
				Assert.equals(nut.id, actor);
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
				return service.logIn(mail, pass + "bad");
			})
			.flatMap(function(o:Outcome<Token, Error>) {
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

	function authServiceTester():AuthService {
		var storedeps = {
			keyToStr: Std.string,
			valToStr: function(val:AuthUser):String {
				return val.toJson();
			},
			valFromStr: AuthUser.fromJson
		};
		var store = new InMemoryKVPStore<Email, AuthUser>(storedeps);
		var channel = new LocalChannel("authNewUser");

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
