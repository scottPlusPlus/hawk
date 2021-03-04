package hawk.store;

import haxe.iterators.ArrayIterator;

abstract DataRow (Array<String>) {
    private function new(a:Array<String>) {
		this = a;
	}

	public inline function length():Int {
		return this.length;
	}

	public inline function iterator():ArrayIterator<String> {
		return this.iterator();
	}

	@:from
	static public function fromArray(a:Array<String>) {
		return new DataRow(a);
	}

	@:to
	public function toArray():Array<String> {
		return this;
	}

    @:from
	static public function fromString(str:String) {
		return new DataRow([str]);
	}

    //modifies the data-row in-place
    public function overwrite(new_data:DataRow){
		var arr = new_data.toArray();
        if (this.length != arr.length){
            throw("cannot overwrite DataRow with row of different length");
        }
        for(i in 0...this.length-1){
            this[i] = arr[i];
        }
    }
}