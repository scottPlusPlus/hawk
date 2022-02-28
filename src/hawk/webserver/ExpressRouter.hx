package hawk.webserver;

import hawk.weberror.WebErrorLog;
import tink.CoreApi;
import haxe.Exception;
import zenlog.Log;

import tink.http.Method;

using hawk.weberror.WebErrorX;

class ExpressRouter {

    var routes:Map<String,Dynamic->Promise<String>>;
    public var express:Dynamic;
    public var reqCount:UInt = 0;

    public function new(express:Dynamic){
        this.routes = new Map();
        this.express = express;
    }

    public function registerRoute(route:String, method:Method, handler:Dynamic->Promise<String>){
        if (routes.exists(route)){
            var err = 'Route $route already registered to this Express Adapter';
            Log.error(err);
            throw (new Exception(err));
        }

        try {
            var expressHandler = buildDebugHandler(handler);
            switch (method){
                case GET:
                    express.get(route, expressHandler);
                case POST:
                    express.post(route, expressHandler);
                default:
                    throw(new Exception('not currently handling method $method'));
            }
        } catch (e:Exception){
            Log.error('Expection registerring route $route:  $e');
            throw (e);
            return;
        }
        
        routes.set(route, handler);
    }

    private inline function buildDebugHandler(handler:Dynamic->Promise<String>):Dynamic->Dynamic->Void {
        var expressHandler = function(req:Dynamic, res:Dynamic){
            var reqId = reqCount++;
            var contextMsg = 'REQUEST $reqId:  ${req.originalUrl}:  ${req.body}';
            Log.info('REQUEST $reqId:  ${req.originalUrl}:  ${req.body}');
            var p = handler(req);
            p.enhanceErr(contextMsg, 'Unknown Error').flatMap( function(o:Outcome<String,Error>){
                switch(o){
                    case Success(data):
                        Log.info('REQUEST $reqId:  res:  $data');
                        res.send(data);
                    case Failure(err):
                        var webErr = WebErrorX.asWebErr(err);
                        var wel = WebErrorLog.fromWebError(webErr);
                        var msg = 'REQUEST $reqId:\nuid:${wel.uid}\n ${wel.message}\n ${wel.context}';
                        Log.error(msg);
                        res.send(webErr.print());
                }
                return Noise;
            }).eager();
        }
        return expressHandler;
    }
}
