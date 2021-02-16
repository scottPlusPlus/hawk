package hawk.store;

import zenlog.Log;
import tink.CoreApi;

class PostgresStringStringStore implements IKVStore<String,String> {

    private var _postgresClient:Dynamic;
    private var _tableName:String;

    public function new(postgresClient:Dynamic, tableName){
        _postgresClient = postgresClient;
        _tableName = tableName;

        // var query = '
        // CREATE TABLE ${_tableName} (
        //     key varchar,
        //     val varchar
        // );
        // ';

        // _postgresClient.query(query, function(err:Dynamic, res:Dynamic){
        //     if (err != null) {
        //         Log.error('error creating table ${_tableName} in postgres:  ${err}');
        //         return;
        //     }
        //     Log.debug('successfully created table ${_tableName} in db');
        //     _postgresClient.end();
        // });
    }

	public function exists(key:String):Promise<Bool>{
        return _postgresClient.foo();
    }

	public function get(key:String):Promise<Null<String>>{
        var query = 'SELECT * FROM ${_tableName} WHERE key = $1';
        var p = new PromiseTrigger<String>();
        _postgresClient.query(query, key, function(err:Dynamic, res:Dynamic) {
            if (err != null) {
                var e = new Error('error creating table ${_tableName} in postgres:  ${err}');
                Log.error(e);
                p.reject(e);
            }
            Log.debug('postgres get success for ${key}');
            var str = Std.string(res.rows);
            _postgresClient.end();
            p.resolve(str);
        });
        return p;
    }

	public function getSure(key:String):Promise<String>{
        return "";
    }

	public function set(key:String, value:String):Promise<String>{
        var query = 'INSERT INTO ${_tableName} (key, val) VALUES ("${key}", "${value}")';
        var p = new PromiseTrigger<String>();
        _postgresClient.query(query,  function(err:Dynamic, res:Dynamic) {
            if (err != null) {
                var e = new Error('error creating table ${_tableName} in postgres:  ${err}');
                Log.error(e);
                p.reject(e);
            }
            Log.debug('postgres set success for ${key}  ${value}');
            _postgresClient.end();
            p.resolve(value);
        });
        return p;
    }

	public function remove(key:String):Promise<Bool>{
        return false;
    }

}