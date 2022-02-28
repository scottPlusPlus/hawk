package hawk_test.webserver;

import utest.Assert;
import hawk.webserver.ExpressRouter;

class ExpressRouterTest  extends utest.Test {

	function testExists() {
        var er = new ExpressRouter(123);
        Assert.pass();
    }

}

