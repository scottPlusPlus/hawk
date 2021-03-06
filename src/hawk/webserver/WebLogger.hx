package hawk.webserver;

import hawk.StoredLogger;
import zenlog.*;

class WebLogger {
	public static var filter:FilteredLogger;
    public static var store:StoredLogger;

	public static function init() {

        store = new StoredLogger(new TraceLogger());
		filter = new FilteredLogger(store);
		filter.enableDebug = true;
        zenlog.Log.Logger = filter;
        
        Log.info("initting weblog for build " + CompileTime.buildDateString());

	}

	public static function setDebug(val:Bool) {
		filter.enableDebug = val;
    }
    
    public static function dump():Array<String> {
        return store.logs.copy();
    }
}
