package hawk.requestlog;

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
        var res = [];
        var it = store.iterator();

        return AsyncIteratorX.forEach(it, function(log:RequestLog){
            var str = '${Timestamp.toString(log.time)}:  ${log.route}   ${log.ip}';
            res.push(str);
            return Noise;
        }).next(function(_){
            return res.toString();
        });
    }
}