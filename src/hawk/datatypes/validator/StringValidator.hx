package hawk.datatypes.validator;

import hawk.datatypes.validator.ValidationOutcome;

class StringValidator extends Validator<String> {

    private var _fieldName:String = "Field";

    public function new(fieldName:String){
        super();
        _fieldName = fieldName;
    }

    public function minChar(v:UInt):StringValidator {
        var f = function(str:String):ValidationOutcome {
            if (str.length < v){
                return Fail(['${_fieldName} must be at least ${v} chars.']);
            }
            return Pass;
        }
        _rules.push(f);
        return this;
    }

    public function maxChar(v:UInt):StringValidator {
        var f = function(str:String):ValidationOutcome {
            if (str.length > v){
                return Fail(['${_fieldName} must be less than ${v} chars.']);
            }
            return Pass;
        }
        _rules.push(f);
        return this;
    }

    public function regex(regex:EReg, err:String):StringValidator {
        var f = function(str:String):ValidationOutcome {
            if (!regex.match(str)){
                return Fail([err]);
            }
            return Pass;
        }
        _rules.push(f);
        return this;
    }

    public function trim():StringValidator {
        var f = function(str:String):ValidationOutcome {
            if (StringTools.trim(str) != str){
                return Fail(['${_fieldName} must not have any extra spaces.']);
            }
            return Pass;
        }
        _rules.push(f);
        return this;
    }

    public function contains(needle:String):StringValidator {
        var f = function(str:String):ValidationOutcome {
            if (!StringTools.contains(str, needle)){
                return Fail(['${_fieldName} must contain ${needle}.']);
            }
            return Pass;
        }
        _rules.push(f);
        return this;
    }

    public function nonNull():StringValidator {
        var f = function(str:String):ValidationOutcome {
            if (str == null){
                return FailAndExit(['${_fieldName} cannot be null.']);
            }
            return Pass;
        }
        _rules.push(f);
        return this;
    }

    public override function addRule(r:ValidationRule<String>): StringValidator {
        _rules.push(r);
        return this;
    }
}