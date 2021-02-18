package hawk.store;

import zenlog.Log;
import tink.CoreApi;

class PostgresStringStringStore implements IKVStore<String,String> {

    private var _postgresClient:Dynamic;
    private var _tableName:String;

    public function new(postgresClient:Dynamic, tableName:String){
        if (tableName.toLowerCase() != tableName){
            throw('table name should be lowercase');
        }
        if (StringTools.trim(tableName) != tableName){
            throw('table name should be trimmed...');
        }

        _postgresClient = postgresClient;
        _tableName = tableName;
    }

    public function init():Promise<PostgresStringStringStore>{
        var p = new PromiseTrigger<PostgresStringStringStore>();

        var query = '
        CREATE TABLE IF NOT EXISTS ${_tableName} (
            id SERIAL PRIMARY KEY,
            key VARCHAR UNIQUE,
            val VARCHAR 
          );
        ';

        logQuery(query);
        _postgresClient.query(query, function(err:Dynamic, res:Dynamic){
            if (err != null) {
                var e = queryErr('Create Table ${_tableName}:  ${err}');
                Log.error(e);
                p.reject(e);
                return;
            }
            //Log.info('successfully created table ${_tableName} in db');
            p.resolve(this);
        });
        return p;
    }

	public function exists(key:String):Promise<Bool>{
        return false;
    }

	public function get(key:String):Promise<Null<String>>{
        var query = "SELECT * FROM $0 WHERE key = '$1'";
        query = StringTools.replace(query, "$0", _tableName);
        query = StringTools.replace(query, "$1", key);
        logQuery(query);

        var p = new PromiseTrigger<String>();
        _postgresClient.query(query, function(err:Dynamic, res:Dynamic) {
            if (err != null) {
                var e = queryErr('GET ${key}:  ${err}');
                Log.error(e);
                p.reject(e);
            }
            // Log.debug('postgres get success for ${key}');
            // Log.debug(Std.string(res));

            var rows:Array<PostgresRow> = res.rows;

            if (rows == null){
                //Log.debug("rows is null");
                p.resolve(null);
                return;
            }

            if (rows.length == 0){
                //Log.debug("rows is empty");
                p.resolve(null);
                return;
            }

            if (rows.length != 1){
                Log.warn("got more rows than expected... " + rows.length);
            }
            p.resolve(rows[0].val);
        });
        return p;
    }

	public function getSure(key:String):Promise<String>{
        return get(key).next(function(str:Null<String>){
            if (str == null){
                return Failure(new Error('no value for ${key}'));
            }
            return Success(str);
        });
    }

	public function set(key:String, value:String):Promise<String>{
        var query = "INSERT INTO $0 (key, val)
        VALUES('$1', '$2')
        ON CONFLICT (key) 
        DO UPDATE SET val = '$2'";

        query = StringTools.replace(query, "$0", _tableName);
        query = StringTools.replace(query, "$1", key);
        query = StringTools.replace(query, "$2", value);

        logQuery(query);
        var p = new PromiseTrigger<String>();
        _postgresClient.query(query, function(err:Dynamic, res:Dynamic) {
            if (err != null) {
                var e = queryErr('SET  ${key}  ${value}:  ${err}');
                Log.error(e);
                p.reject(e);
                return;
            }
            p.resolve(value);
        });
        return p;
    }

	public function remove(key:String):Promise<Bool>{
        var query = "DELETE FROM $0 WHERE key = '$1'";
        query = StringTools.replace(query, "$0", _tableName);
        query = StringTools.replace(query, "$1", key);

        logQuery(query);
        var p = new PromiseTrigger<Bool>();
        _postgresClient.query(query, function(err:Dynamic, res:Dynamic) {
            if (err != null) {
                var e = queryErr('remove ${key}:  ${err}');
                Log.error(e);
                p.resolve(false);
            }
            p.resolve(true);
        });
        return false;
    }

    public function clear():Promise<Noise> {
        var query = "DROP TABLE $0";
        query = StringTools.replace(query, "$0", _tableName);

        logQuery(query);
        var p = new PromiseTrigger<Noise>();
        _postgresClient.query(query, function(err:Dynamic, res:Dynamic) {
            if (err != null) {
                var e = queryErr('clear:  ${err}');
                Log.error(e);
                p.resolve(Noise);
            }
            p.resolve(Noise);
        });
        return p;
    }

    public function toMap():Promise<Map<String,String>> {
        var query = "SELECT * FROM $0";
        query = StringTools.replace(query, "$0", _tableName);
        logQuery(query);

        var p = new PromiseTrigger<Map<String,String>>();
        _postgresClient.query(query, function(err:Dynamic, res:Dynamic) {
            if (err != null) {
                var e = queryErr('toMap:  ${err}');
                Log.error(e);
                p.reject(e);
            }
            var rows:Array<PostgresRow> = res.rows;

            var m = new Map<String,String>();
            for (r in rows){
                m.set(r.key, r.val);
            }
            p.resolve(m);
        });
        return p;
    }

    private inline function logQuery(query:String){
        Log.debug("postgres query:  " + query);
    }

    private inline function queryErr(err:String):Error{
        return new Error('postgres error:  ${err}');
    }
}

typedef PostgresRow = {
    id:Int,
    key:String,
    val:String
}