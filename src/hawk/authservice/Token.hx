package hawk.authservice;

abstract Token(String) {
    
    public function new(str:String) {
        this = str;
    }

    @:from
    static public function fromString(s:String) {
      return new Token(s);
    }
  
    @:to
    public function toString() {
      return this;
    }
}