package hawk.datatypes.validator;

enum ValidationOutcome {
	Pass();
	Fail(errors:Array<String>);
	FailAndExit(errors:Array<String>);
}