package hawk.store;

class DataField {
    public var name:String;
    public var unique:Bool;
    public function new(name:String, unique:Bool = false){
        this.name = name;
        this.unique = unique;
    }
}