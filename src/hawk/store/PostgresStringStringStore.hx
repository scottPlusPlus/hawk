package hawk.store;

import hawk.async_iterator.PagedAsyncIterator;
import hawk.async_iterator.AsyncIterator;
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

    public function getMany(keys:Array<String>):Promise<Array<KV<String,Null<String>>>> {
        var getPromises = new Array<Promise<KV<String,Null<String>>>>();
        for (k in keys){
            var p = get(k).next(function(ns):KV<String,Null<String>>{
                return new KVX(k, ns);
            });
            getPromises.push(p);
        }
        var res = Promise.inSequence(getPromises);
        return res;
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

    public function keyValueIterator():AsyncIterator<KV<String,String>> {
        var postgresPager = new PostgresPager(25, getPage);
        var pagedIterator = new PagedAsyncIterator(postgresPager.loadNext);
        return pagedIterator;
    }

    public function getPage(limit:UInt, offset:UInt):Promise<Array<KV<String,String>>>{
        var query = "SELECT * FROM $0 ORDER BY key ASC LIMIT $2 OFFSET $3";
        query = StringTools.replace(query, "$0", _tableName);
        query = StringTools.replace(query, "$2", Std.string(limit));
        query = StringTools.replace(query, "$3", Std.string(offset));
        logQuery(query);
        
        var p = new PromiseTrigger<Array<KV<String,String>>>();
        _postgresClient.query(query, function(err:Dynamic, res:Dynamic) {
            if (err != null) {
                var e = queryErr('GET PAGE ${limit} ${offset}:  ${err}');
                Log.error(e);
                p.reject(e);
            }

            var rows:Array<PostgresRow> = res.rows;
            var arr = new Array<KV<String,String>>();
            for (r in rows){
                var kv = new KVX(r.key, r.val);
                arr.push(kv);
            }
            p.resolve(arr);
        });
        return p;
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

class PostgresPager {

    private var _limit:UInt;
    private var _offset:UInt;
    private var _next:UInt->UInt->Promise<Array<KV<String,String>>>;

    public function new(limit:UInt, next:UInt->UInt->Promise<Array<KV<String,String>>>){
        _limit = limit;
        _offset = 0;
        _next = next;
    }

    public function loadNext():Promise<Array<KV<String,String>>> {
        return _next(_limit, _offset).next(function(v){
            _offset += _limit;
            return v;
        });
    }
}

typedef PostgresRow = {
    id:Int,
    key:String,
    val:String
}