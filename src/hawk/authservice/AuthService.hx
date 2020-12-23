package hawk.authservice;

import hawk.authservice.EvNewUser;
import zenlog.Log;
import hawk.util.FutureX;
import hawk.messaging.Message;
import hawk.datatypes.Password;
import hawk.messaging.ISubscriber;
import hawk.messaging.IPublisher;
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
	private var _userPassStore:IKVStore<Email, AuthUser>;
	private var _newUserPub:IPublisher<EvNewUser>;
	private var _newUserSub:ISubscriber<EvNewUser>;

	public function new() {}

	public function init(deps:AuthServiceDeps):AuthService {
		_tokenIssuer = deps.tokenIssuer;
		_tokenSecret = deps.tokenSecret;
		_userPassStore = deps.userStore;
		_newUserPub = deps.newUserPub;
		_newUserSub = deps.newUserSub;

		_newUserSub.subscribe(handleNewUser);

		return this;
	}

	public function register(email:Email, password:String):Promise<NewUserToken> {
		var validateMail = Email.createValid(email);
		if (validateMail.isFailure()) {
			return Failure(validateMail.failure());
		}
		var validatePassword = Password.createValid(password);
		if (validatePassword.isFailure()) {
			return Failure(validatePassword.failure());
		}

		var salt = UUID.gen();
		var user = new AuthUser({
			id: UUID.gen(),
			email: email,
			salt: salt,
			passHash: hashPass(password, salt)
		});

		var event = new EvNewUser({
			timestamp: Date.now().getUTCSeconds(),
			user: user
		});

		return _newUserPub.publish(event).wrapErr('infra error with AuthService.register').next(function(_:Noise) {
			return Success({
				id: user.id,
				token: genToken(user.id)
			});
		});
	}

	private function handleNewUser(event:EvNewUser):Promise<Noise> {
		var user = event.user;
		return _userPassStore.set(user.email, user).wrapErr('infra err with AuthService.handleNewUser');
	}

	// should return an authToken
	public function logIn(email:Email, pass:Password):Promise<Token> {
		Log.debug("AuthService.login");
		return _userPassStore.get(email).next(function(authUser:Null<AuthUser>) {
			Log.debug("AuthService.login have user");
			if (authUser == null) {
				return Failure(new Error(BAD_LOGIN_CODE, BAD_LOGIN_MSG));
			}
			var hashed = hashPass(pass, authUser.salt);
			if (hashed != authUser.passHash) {
				return Failure(new Error(BAD_LOGIN_CODE, BAD_LOGIN_MSG));
			}
			var token = genToken(authUser.id);
			return Success(token);
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

typedef NewUserToken = {
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
