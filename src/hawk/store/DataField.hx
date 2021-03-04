package hawk.store;

import tink.core.Error;

class DataField {

    //TODO - somehow uppercase chars passes?
    private static final _regex = ~/^[a-z]*$/i;

    public var name:String;
    public var unique:Bool;
    public function new(name:String, unique:Bool = false){
        this.name = name;
        this.unique = unique;
    }

    public function validationErrors():Array<String>{
        var arr = new Array<String>();
          if (name.length < 3 || name.length > 32){
              arr.push('field  ${name}  must be between 3 and 32 chars');
          }
          if (!_regex.match(name)){
            arr.push('field  ${name}  must contain only lowercase chars a-z');
          } else {
            if (name.toLowerCase() != name){
              arr.push('field  ${name}  must contain only lowercase chars a-z');
            }
          }
        return arr;
    }
}