package hawk.authservice;

import hawk.store.IDataItem;
import hawk.authservice.EvNewUser;
import zenlog.Log;
import hawk.messaging.*;
import hawk.datatypes.Password;
import jwt.JWT;
import tink.CoreApi.Promise;
import tink.core.Noise;
import tink.core.Error;
import hawk.datatypes.UUID;
import tink.CoreApi.Outcome;
import hawk.datatypes.Email;

using hawk.util.OutcomeX;
using hawk.util.ErrorX;
using hawk.util.PromiseX;

class AuthService {
	private final BAD_LOGIN_MSG = 'invalid email / password';
	private final BAD_LOGIN_CODE = ErrorCode.Unauthorized;

	private var _tokenSecret:Void->String;
	private var _tokenIssuer:String;
	private var _authUserStore:AuthUserStore;
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

		var indexByEmail = _authUserStore.indexByEmail();

		return indexByEmail.get(email).next(function(res){
			if (res != null){
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

			user = new AuthUser();
			user.id = UUID.gen();
			user.email = email;
			user.displayName = email;
			user.salt = UUID.gen();
			user.passHash = hashPass(password, user.salt);

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

	// TODO - used this before _pendingRegistrations.  Can probably kill
	// private function waitForNewlyCreatedUser(email:Email):Promise<AuthUser> {
	// 	return Poller.waitUntil(function() {
	// 		return _authUserStore.exists(email);
	// 	}, 100, 5000).next(function(_:Noise) {
	// 		return _authUserStore.get(email);
	// 	}).eager();
	// }

	private function handleNewUser(event:EvNewUser):Promise<Noise> {
		var user = event.user;
		var email = user.email;
		return _authUserStore.create(user).next(function(_) {
			_pendingRegistrations.remove(email);
			return Noise;
		}).wrapErr('infra err with AuthService.handleNewUser');
	}

	// should return an authToken
	public function signIn(email:Email, pass:Password):Promise<AuthResponse> {
		Log.debug("AuthService.login");
		var indexByEmail = _authUserStore.indexByEmail();
		return indexByEmail.get(email).next(function(res:Null<IDataItem<AuthUser>>) {
			if (res == null) {
				return Failure(new Error(BAD_LOGIN_CODE, BAD_LOGIN_MSG));
			}
			var user = res.value();
			Log.debug("AuthService.login have user");
			var hashed = hashPass(pass, user.salt);
			if (hashed != user.passHash) {
				return Failure(new Error(BAD_LOGIN_CODE, BAD_LOGIN_MSG));
			}
			var token = genToken(user.id);
			var res = {
				id: user.id,
				token: token
			};
			return Success(res);
		});
	}

	// public function displayNames(ids:Array<UUID>):Promise<Array<KV<UUID,String>>>{

	// 	return ErrorX.notYetImplemented();
	// }

	private static function hashPass(pass:String, salt:String):String {
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
}

typedef AuthResponse = {
	id:UUID,
	token:Token
}

typedef AuthServiceDeps = {
	tokenSecret:Void->String,
	tokenIssuer:String,
	userStore: AuthUserStore,
	newUserPub:IPublisher<EvNewUser>,
	newUserSub:ISubscriber<EvNewUser>,
}

typedef TPayload = {
	> jwt.JWTPayloadBase,
	var ?hawkAdmin:Bool;
	var hawkUserID:String;
}
