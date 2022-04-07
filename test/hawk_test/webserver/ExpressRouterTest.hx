package hawk_test.webserver;

import haxe.http.HttpMethod;
import utest.Assert;
import hawk.webserver.ExpressRouter;

class ExpressRouterTest  extends utest.Test {

	function testExists() {
        
        var dummyExpress = {
            get:function(r:String, h:ExpressReq->ExpressRes->Void){

            },
            post:function(r:String, h:ExpressReq->ExpressRes->Void){
                
            }
        }

        var er = new ExpressRouter(dummyExpress);
        er.registerJsonRoute("/foo", HttpMethod.Get, function(req){
            return "some response?";
        });
        Assert.pass();
    }

}

