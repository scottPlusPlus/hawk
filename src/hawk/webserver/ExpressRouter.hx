package hawk.webserver;

import hawk.weberror.WebErrorLog;
import tink.CoreApi;
import haxe.Exception;
import haxe.http.HttpMethod;
import zenlog.Log;

using hawk.weberror.WebErrorX;
using yaku_core.IteratorX;
using yaku_core.PromiseX;

class ExpressRouter {
	public final DEFAULT_ROUTE = "/*";

	var routes:Map<String, Dynamic->Promise<Dynamic>>;
	var middleWare:Array<ExpressMiddleware> = [];

	public var express:Dynamic;
	public var reqCount:UInt = 0;

	public function new(express:Dynamic) {
		this.routes = new Map();
		this.express = express;
	}

	/*
		Registers a new route to the ExpressRouter.  By default the result of the handler you pass in
		is served via res.json
	 */
	public function registerJsonRoute(route:String, method:HttpMethod, handler:ExpressReq->Promise<String>) {
		if (routes.exists(route)) {
			var err = 'Route $route already registered to this Express Adapter';
			Log.error(err);
			throw(new Exception(err));
		}
		Log.debug('registerring route: $route');

		try {
			var expressHandler = buildDebugJsonHandler(handler);
			switch (method) {
				case HttpMethod.Get:
					express.get(route, expressHandler);
				case HttpMethod.Post:
					express.post(route, expressHandler);
				default:
					throw(new Exception('not currently handling method $method'));
			}
		} catch (e:Exception) {
			Log.error('Expection registerring route $route:  $e');
			throw(e);
			return;
		}

		routes.set(route, handler);
	}

	public function addMiddleware(mw:ExpressMiddleware){
		middleWare.push(mw);
	}

	public function debugData():Dynamic {
		var r = routes.keys().collect();
		var buildTime = CompileTime.buildDateString();
		return {
			build: buildTime,
			routes: r,
		}
	}

	private inline function buildDebugJsonHandler(handler:ExpressReq->Promise<String>):ExpressReq->ExpressRes->Void {
		var expressHandler = function(req:ExpressReq, res:ExpressRes) {
			var reqId = reqCount++;
			var contextMsg = 'REQUEST $reqId:  ${req.originalUrl}:  ${req.body}';
			Log.info('REQUEST $reqId:  ${req.originalUrl}:  ${req.body}');

			var mwP = Promise.resolve(Noise);
			for(mw in middleWare){
				mwP = mwP.next(function(_){
					Log.debug('running some middleware...');
					return mw(req, res);
				});
			}
			var p = mwP.next(function(_){
				return handler(req);
			});

			try {
				p.enhanceErr(contextMsg, 'Unknown Error').flatMap(function(o:Outcome<String, Error>) {
					switch (o) {
						case Success(data):
							var data_res = data;
							if (data_res.length > 256){
								data_res = data.substring(0, 256) + "...";
							}
							Log.info('REQUEST $reqId:  res:  $data_res');
							res.set('Content-Type', 'application/json');
							res.send(data);
						case Failure(err):
							Log.error(err);
							var webErr = WebErrorX.asWebErr(err);
							var wel = WebErrorLog.fromWebError(webErr);
							var msg = 'REQUEST $reqId:\nuid:${wel.uid}\n ${wel.message}\n ${wel.context}';
							Log.error(msg);
							res.status(webErr.code);
							res.send(webErr.print());
					}
					return Noise;
				}).eager();
			} catch (e:Exception){
				Log.error('REQUEST $reqId threw exception:');
				Log.error(e.message);
				Log.error(e.stack.toString());
				res.status(500);
				res.send('Something broke with $reqId');
			}
		}
		return expressHandler;
	}
}


typedef ExpressReq = Dynamic;
typedef ExpressRes = Dynamic;

typedef ExpressMiddleware = ExpressReq->ExpressRes->Promise<Noise>;