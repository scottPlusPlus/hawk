package hawk.authservice;

import hawk.authservice.EvNewUser;
import zenlog.Log;
import hawk.util.FutureX;
import hawk.util.Poller;
import hawk.messaging.*;
import hawk.datatypes.Password;
import hawk.store.IKVStore;
import jwt.JWT;
import tink.CoreApi.Promise;
import tink.core.Noise;
import tink.core.Error;
import hawk.core.UUID;
import tink.CoreApi.Outcome;
import hawk.util.ErrorX;
import hawk.datatypes.Email;

using hawk.util.OutcomeX;
using hawk.util.ErrorX;
using hawk.util.PromiseX;

class AuthService {
	private var _tokenSecret:Void->String;
	private var _tokenIssuer:String;
	private var _authUserStore:IKVStore<Email, AuthUser>;
	private var _newUserPub:IPublisher<EvNewUser>;
	private var _newUserSub:ISubscriber<EvNewUser>;
	private var _pendingRegistrations:Map<String, Noise>;

	public function new() {}

	public function init(deps:AuthServiceDeps):AuthService {
		_tokenIssuer = deps.tokenIssuer;
		_tokenSecret = deps.tokenSecret;
		_authUserStore = deps.userStore;
		_newUserPub = deps.newUserPub;
		_newUserSub = deps.newUserSub;

		_newUserSub.subscribe(handleNewUser);
		_pendingRegistrations = new Map();
		return this;
	}

	public function register(email:Email, password:Password):Promise<AuthResponse> {
		var validateEmail = email.isValid();
		if (validateEmail.isFailure()) {
			return Failure(validateEmail.failure());
		}
		var validatePassword = password.isValid();
		if (validatePassword.isFailure()) {
			return Failure(validatePassword.failure());
		}

		var user:AuthUser;
		var emailTakenErr = new Error(ErrorCode.Conflict, 'User for ${email} already exists');

		return _authUserStore.exists(email).next(function(exists) {
			Log.debug('${email} exists in store?  ${exists}');
			if (exists) {
				return Failure(emailTakenErr);
			};
			return Success(Noise);
		}).next(function(_) {
			var isPending = _pendingRegistrations.exists(email);
			Log.debug('${email} exists in pending?  ${isPending}');
			if (isPending) {
				return Failure(emailTakenErr);
			}
			_pendingRegistrations.set(email, Noise);

			var salt = UUID.gen();
			user = new AuthUser({
				id: UUID.gen(),
				email: email,
				salt: salt,
				passHash: hashPass(password, salt)
			});
			var event = new EvNewUser({
				timestamp: Date.now().getUTCSeconds(),
				user: user
			});
			return _newUserPub.publish(event).wrapErr('infra error with AuthService.register');
		}).next(function(_) {
			return Success({
				id: user.id,
				token: genToken(user.id)
			});
		});
	}

	private function waitForNewlyCreatedUser(email:Email):Promise<AuthUser> {
		return Poller.waitUntil(function() {
			return _authUserStore.exists(email);
		}, 100, 5000).next(function(_:Noise) {
			return _authUserStore.get(email);
		}).eager();
	}

	private function handleNewUser(event:EvNewUser):Promise<Noise> {
		var user = event.user;
		var email = user.email;
		return _authUserStore.set(email, user).next(function(_) {
			_pendingRegistrations.remove(email);
			return Noise;
		}).wrapErr('infra err with AuthService.handleNewUser');
	}

	// should return an authToken
	public function signIn(email:Email, pass:Password):Promise<AuthResponse> {
		Log.debug("AuthService.login");
		return _authUserStore.exists(email).next(function(exists:Bool) {
			if (!exists) {
				return Failure(new Error(BAD_LOGIN_CODE, BAD_LOGIN_MSG));
			}
			return _authUserStore.get(email);
		}).next(function(authUser:AuthUser) {
			Log.debug("AuthService.login have user");
			var hashed = hashPass(pass, authUser.salt);
			if (hashed != authUser.passHash) {
				return Failure(new Error(BAD_LOGIN_CODE, BAD_LOGIN_MSG));
			}
			var token = genToken(authUser.id);
			var res = {
				id: authUser.id,
				token: token
			};
			return Success(res);
		});
	}

	private static inline function hashPass(pass:String, salt:String):String {
		return PBKDF2.encode(pass, salt, 100, 256);
	}

	public function actorFromToken(token:Token):Outcome<UUID, Error> {
		var result:JWTResult<TPayload> = JWT.verify(token, _tokenSecret());
		switch (result) {
			case Valid(payload):
				{
					return Success(payload.hawkUserID);
				}
			case Invalid(_):
				{
					return Failure(new Error('invalid token'));
				}
			case Malformed:
				{
					return Failure(new Error('token is malformed'));
				}
		}
	}

	public function genToken(user:UUID):Token {
		var token:String = JWT.sign({iss: _tokenIssuer, hawkUserID: user}, _tokenSecret());
		return new Token(token);
	}

	private final BAD_LOGIN_MSG = 'invalid email / password';
	private final BAD_LOGIN_CODE = ErrorCode.Unauthorized;
}

typedef AuthResponse = {
	id:UUID,
	token:Token
}

typedef AuthServiceDeps = {
	tokenSecret:Void->String,
	tokenIssuer:String,
	userStore:IKVStore<Email, AuthUser>,
	newUserPub:IPublisher<EvNewUser>,
	newUserSub:ISubscriber<EvNewUser>,
}

typedef TPayload = {
	> jwt.JWTPayloadBase,
	var ?hawkAdmin:Bool;
	var hawkUserID:String;
}
