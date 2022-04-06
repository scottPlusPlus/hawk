package hawk.webserver;

import tink.CoreApi;
import hawk.webserver.ExpressRouter.ExpressRes;
import hawk.webserver.ExpressRouter.ExpressReq;
import hawk.store.IDataStore;

class RequestLogMiddleWare {

    var store:IDataStore<RequestLog>;

    public function new(store:IDataStore<RequestLog>){
        this.store = store;
    }  

    public function handle(req:ExpressReq, res:ExpressRes):Promise<Noise> {
        var route = req.originalUrl;
        var ip = req.ip;
        var log = new RequestLog(route, ip);
        return store.create(log).noise();
    }
}