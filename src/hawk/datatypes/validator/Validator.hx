package hawk.datatypes.validator;

class Validator<T> {

    private var _rules:Array<ValidationRule<T>> = [];

    public function new(){}

    public function errors(x:T):Array<String> {
        var errs = new Array<String>();
        for (rule in _rules){
            var res = rule(x);
            switch (res){
                case Pass:
                case Fail(errors):
                    errs = errs.concat(errors);
                case FailAndExit(errors):
                    errs = errs.concat(errors);
                    break;
            }
        }
        return errs;
    }

    public static function outcomeFromArray(v:Array<String>):ValidationOutcome {
        if (v.length > 0){
            return Fail(v);
        }
        return Pass;
    }

    public function addRule(r:ValidationRule<T>):Validator<T> {
        _rules.push(r);
        return this;
    }

    public function addSubValidator<X>(mapper:T->X, subValidator:Validator<X>):Validator<T> {
        var rule = function(t:T):ValidationOutcome {
            var x = mapper(t);
            var errs = subValidator.errors(x);
            return outcomeFromArray(errs);
        }
        return this.addRule(rule);
    }
}