import zenlog.Log;
import haxe.Json;
import utest.ui.Report;
import utest.Assert;
import utest.Async;
import utest.Runner;
import hawk.testutils.TestLog;

class MyTests {
	public static function main() {
		TestLog.init();

		var runner = new Runner();
		runner.addCases(hawk_test);
		runner.onTestStart.add(function(x) {
			TestLog.startTest(x.fixture.method);
		});
		runner.onTestComplete.add(function(x) {
			for (assert in x.results) {
				switch (assert) {
					case Failure(msg, pos):
						TestLog.debugForTest();
						break;
					case Error(e, stack):
						TestLog.debugForTest();
						break;
					default:
				}
			}
			TestLog.finishTest();
		});


		Report.create(runner);
		TestLog.ageWarning();
		runner.run();
	}
}
