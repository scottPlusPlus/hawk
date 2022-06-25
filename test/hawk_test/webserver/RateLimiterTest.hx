package hawk_test.webserver;

import zenlog.Log;
import utest.Assert;
import hawk.datatypes.Timestamp;
import hawk.webserver.RateLimiter;
import hawk.webserver.RateLimiter.RequestTracker;

using tink.CoreApi;


class RateLimiterTest  extends utest.Test {

    private var _fakeTime:Timestamp;
    private function returnFakeTime():Timestamp {
        Log.debug("returning fake time " + _fakeTime.toUInt());
        return _fakeTime;
    }

    public function setup(){
        _fakeTime = 0;
    }

 
    public function test3p1s(){
        var ip = "ip";
        var tracker5p1s = new RequestTracker(1000, 3);
        tracker5p1s._currentTime = returnFakeTime;

        var rateLimiter = new RateLimiter([tracker5p1s]);

        Assert.equals(true, rateLimiter.newReq(ip));
        Assert.equals(true, rateLimiter.newReq(ip));
        Assert.equals(true, rateLimiter.newReq(ip));  //3 of 3

        Assert.equals(false, rateLimiter.newReq(ip)); //4 of 3

        _fakeTime = 500; // 4 - 1.5 = 2.5 of 3
        Assert.equals(false, rateLimiter.newReq(ip)); //3.5 of 3 
        
        _fakeTime = 1000; // 3.5 - 1.5 = 2 of 3
        Assert.equals(true, rateLimiter.newReq(ip)); //3 of 3
        Assert.equals(false, rateLimiter.newReq(ip));
    }
}