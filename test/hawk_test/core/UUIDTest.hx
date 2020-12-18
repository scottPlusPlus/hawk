package hawk_test.core;

import zenlog.Log;
import hawk.core.UUID;
import utest.Assert;

class UUIDTest extends utest.Test {
	function testCompares() {
        var u1 = UUID.gen();
        var u2 = UUID.gen();

        Assert.isFalse(u1 == u2);

        var copy =  UUID.fromString(u1.toString());
        Assert.isTrue(u1 == copy);
    }

    function testTimestamps(){
        var now = Date.now();

        Log.info("time now = " + now);
        now.getTime();
        Log.info("now float = " + now.getTime());
        Log.info ("now seconds = " + now.getUTCSeconds());
        Assert.isTrue(true);
    }
}
