package hawk.requestlog;

import hawk.util.OpBatcher;
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

    final store:IDataStore<RequestLog>;
    final timeToLiveMs:UInt;
    final timeToCheck:UInt = 1000 * 3600;
    final pruner:OpBatcher;

    public function new(store:IDataStore<RequestLog>, ?timeToLiveMs:UInt){
        this.store = store;
        if(timeToLiveMs == null){
            timeToLiveMs = Timestamp.DAY * 7;
        }
        this.timeToLiveMs = timeToLiveMs;
        this.pruner = new OpBatcher(timeToCheck);
        pruner.signal.handle(function(_){
            prune().eager();
        });
        pruner.force();
    }  

    public function middlewareHandle(req:ExpressReq, res:ExpressRes):Promise<Noise> {
        pruner.trigger();
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

    private function prune():Promise<Noise> {
        Log.debug("request log pruner triggered");
        var timeToKill = Timestamp.now() - timeToLiveMs;
        var it = store.iterator();
        var count = 0;
        var killed = 0;
        return AsyncIteratorX.forEach(it, function(log:RequestLog){
            count++;
            if (log.time < timeToKill){
                killed++;
                return store.delete(log).noise();
            }
            return Noise;
        }).next(function(_){
            Log.debug('Request Log checked $count logs and killed $killed');
            return Noise;
        });
    }
}