package hawk_test.webserver;

import haxe.http.HttpMethod;
import utest.Assert;
import hawk.webserver.ExpressRouter;

class ExpressRouterTest  extends utest.Test {

	function testExists() {
        var er = new ExpressRouter(123);
        er.registerJsonRoute("/foo", HttpMethod.Get, function(req){
            return "some response?";
        });
        Assert.pass();
    }

}

