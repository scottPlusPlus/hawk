package hawk.requestlog;

import hawk.util.Json;
import yaku_core.CommonSorters;
import zenlog.Log;
import hawk.datatypes.Timestamp;
import tink.CoreApi;
import hawk.webserver.ExpressRouter.ExpressRes;
import hawk.webserver.ExpressRouter.ExpressReq;
import hawk.store.IDataStore;
import hawk.async_iterator.AsyncIteratorX;

class RequestLogService {

    var store:IDataStore<RequestLog>;

    public function new(store:IDataStore<RequestLog>){
        this.store = store;
    }  

    public function middlewareHandle(req:ExpressReq, res:ExpressRes):Promise<Noise> {
        var route = req.originalUrl;
        var ip = req.ip;
        var log = new RequestLog(route, ip);
        return store.create(log).noise();
    }

    public function printLogs(req:ExpressReq):Promise<String> {
        var allLogs = [];
        var it = store.iterator();

        return AsyncIteratorX.forEach(it, function(log:RequestLog){
            Log.debug('processing log for ${log.route}');
            allLogs.push(log);
            return Noise;
        }).next(function(_){
            Log.debug('finished async iterator with ${allLogs.length} logs');
            allLogs.sort(function(a, b){
                return CommonSorters.intsDescending(a.time.toInt(), b.time.toInt());
            });
            var res =  allLogs.map(function(log):String{
                var time = log.time.toDate().toString();
                return '${time}:  ${log.route}   ip:${log.ip}';
            });
            return Json.write().fromArrayOfString(res);
        });
    }
}