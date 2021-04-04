package hawk.datatypes.validator;

class Validator<T> {

    private var _rules:Array<ValidationRule<T>> = [];

    public function new(){}

    public function errors(x:T):Array<String>{
        var errs = new Array<String>();
        for (rule in _rules){
            var res = rule(x);
            switch (res){
                case Pass:
                case Fail(msg):
                    errs.push(msg);
                case FailAndExit(msg):
                    errs.push(msg);
                    break;
            }
        }
        return errs;
    }

    public function addRule(r:ValidationRule<T>){
        _rules.push(r);
    }

    public function rejectNull():Validator<T> {
        return this;
    }

}