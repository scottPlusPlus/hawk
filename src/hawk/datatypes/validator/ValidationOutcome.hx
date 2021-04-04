package hawk.datatypes.validator;

enum ValidationOutcome {
	Pass();
	Fail(msg:String);
	FailAndExit(msg:String);
}
