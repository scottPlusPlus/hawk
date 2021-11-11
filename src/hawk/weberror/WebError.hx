package hawk.weberror;

import tink.core.Error.ErrorCode;
import tink.core.Error.Pos;
import tink.CoreApi.Error;
import hawk.weberror.Data;

@:forward(message, code, data, pos, printPos)
abstract WebError(tink.core.Error.TypedError<Data>) {

    public function new(code:ErrorCode, message:String, publicMsg:String = "An error occurred", ?pos:Pos){
        var data = new Data();
        data.publicMsg = publicMsg;
        this = Error.typed(code, message, data, pos);
    }

    public var publicMsg(get,set):String;
    public function get_publicMsg():String {
        var d = this.data;
        return '${d.publicMsg} (${d.uid})';
    }
    public function set_publicMsg(value:String){
        this.data.publicMsg = value;
        return this.data.publicMsg;
    }

    public var context(get,set):Array<String>;
    public function get_context():Array<String> {
        return this.data.context;
    }
    public function set_context(value:Array<String>){
        this.data.context = value;
        return this.data.context;
    }

    public inline function addContext(msg:String){
        this.data.context.push(msg);
    }
}
