package hawk.testutils;

import zenlog.*;

class TestLogger {
	public static var filter:FilteredLogger;

	public static function init() {
		filter = new FilteredLogger(new TraceLogger());
		filter.calibrateIndentStart();
		filter.enableDebug = false;
		zenlog.Log.Logger = filter;
	}

	public static function setDebug(val:Bool) {
		filter.enableDebug = val;
	}

	public static function resetIdent(){
		filter.calibrateIndentStart();
	}
}
