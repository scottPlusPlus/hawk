package hawk.webserver;

import hawk.weberror.WebErrorLog;
import tink.CoreApi;
import haxe.Exception;
import haxe.http.HttpMethod;
import zenlog.Log;

using hawk.weberror.WebErrorX;
using yaku_core.IteratorX;

class ExpressRouter {
	public final DEFAULT_ROUTE = "/*";

	var routes:Map<String, Dynamic->Promise<Dynamic>>;

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
	public function registerJsonRoute(route:String, method:HttpMethod, handler:Dynamic->Promise<Dynamic>) {
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

	public function debugData():Dynamic {
		var r = routes.keys().collect();
		var buildTime = CompileTime.buildDateString();
		return {
			build: buildTime,
			routes: r,
		}
	}

	private inline function buildDebugJsonHandler(handler:Dynamic->Promise<Dynamic>):Dynamic->Dynamic->Void {
		var expressHandler = function(req:Dynamic, res:Dynamic) {
			var reqId = reqCount++;
			var contextMsg = 'REQUEST $reqId:  ${req.originalUrl}:  ${req.body}';
			Log.info('REQUEST $reqId:  ${req.originalUrl}:  ${req.body}');
			var p = handler(req);
			try {
				p = p.mapError(function(err) {
					return err;
				});
			} catch (e:Exception) {
				Log.error('REQUEST $reqId:  seems handler did not return a Promise');
                Log.error(e.message);
			}
			p.enhanceErr(contextMsg, 'Unknown Error').flatMap(function(o:Outcome<Dynamic, Error>) {
				switch (o) {
					case Success(data):
						Log.info('REQUEST $reqId:  res:  $data');
						res.json(data);
					case Failure(err):
						Log.error(err);
						var webErr = WebErrorX.asWebErr(err);
						var wel = WebErrorLog.fromWebError(webErr);
						var msg = 'REQUEST $reqId:\nuid:${wel.uid}\n ${wel.message}\n ${wel.context}';
						Log.error(msg);
						res.json(webErr.print());
				}
				return Noise;
			}).eager();
		}
		return expressHandler;
	}
}
