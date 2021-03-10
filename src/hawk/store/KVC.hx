package hawk.store;

import haxe.macro.Expr.Error;


class KVC<K, V> {
	public function new(key:K, value:V) {
		this.key = key;
		this.value = value;
	}

	public var key:K;
	public var value:V;
}
