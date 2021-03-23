package hawk.testutils;

import zenlog.*;

class TestLog {
	
	public static var tLogger:TestLogger;

	public static function init() {
		tLogger = new TestLogger(new TraceLogger());
		zenlog.Log.Logger = tLogger;
	}

	public static function debugForTest(){
		tLogger.enableDebug();
	}

	public static function startTest(name:String = ""){
		tLogger.beginTest(name);
	}

	public static function finishTest(){
		tLogger.finishTest();
	}

	public static function ageWarning():Void {
		var buildTime = CompileTime.buildDate();
		var now = Date.now();
		var dur = now.getTime() - buildTime.getTime();
		var seconds = Math.floor(dur / 1000);

		var minutes = Math.floor(seconds / 60);
		if (minutes > 1) {
			Log.warn('WARN! \n\nBuild is  ${minutes} minutes old\n\n WARN tlog');
		}
	}

}
