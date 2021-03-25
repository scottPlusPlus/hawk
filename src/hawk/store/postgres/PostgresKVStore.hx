package hawk.store.postgres;

import hawk.async_iterator.PagedAsyncIterator;
import hawk.async_iterator.AsyncIterator;
import zenlog.Log;
import tink.CoreApi;

class PostgresKVStore implements IKVStore<String, String> {
	private var _postgresClient:Dynamic;
	private var _tableName:String;

	public function new(postgresClient:Dynamic, tableName:String) {
		if (tableName.toLowerCase() != tableName) {
			throw('table name should be lowercase:  ${tableName}');
		}
		if (StringTools.trim(tableName) != tableName) {
			throw('table name should be trimmed:  ${tableName}');
		}

		_postgresClient = postgresClient;
		_tableName = tableName;
	}

	public function init():Promise<PostgresKVStore> {
		var query = '
        CREATE TABLE IF NOT EXISTS ${_tableName} (
            id SERIAL PRIMARY KEY,
            key VARCHAR UNIQUE,
            val VARCHAR 
          );
        ';

		return makeQuery(query).next(function(res) {
			return this;
		});
	}

	public function exists(key:String):Promise<Bool> {
		return false;
	}

	public function get(key:String):Promise<Null<String>> {
		var query = "SELECT * FROM $0 WHERE key = '$1'";
		query = StringTools.replace(query, "$0", _tableName);
		query = StringTools.replace(query, "$1", key);

		return makeQuery(query).next(function(res) {
			var rows:Array<PostgresRow> = res.rows;

			if (rows == null) {
				// Log.debug("rows is null");
				return Success(null);
			}

			if (rows.length == 0) {
				// Log.debug("rows is empty");
				return Success(null);
			}

			if (rows.length != 1) {
				Log.warn("got more rows than expected... " + rows.length);
			}
			return Success(rows[0].val);
		});
	}

	public function getMany(keys:Array<String>):Promise<Array<KV<String, Null<String>>>> {
		var getPromises = new Array<Promise<KV<String, Null<String>>>>();
		for (k in keys) {
			var p = get(k).next(function(ns):KV<String, Null<String>> {
				return new KVC(k, ns);
			});
			getPromises.push(p);
		}
		var res = Promise.inSequence(getPromises);
		return res;
	}

	public function set(key:String, value:String):Promise<String> {
		var query = "INSERT INTO $0 (key, val)
        VALUES('$1', '$2')
        ON CONFLICT (key) 
        DO UPDATE SET val = '$2'";

		query = StringTools.replace(query, "$0", _tableName);
		query = StringTools.replace(query, "$1", key);
		query = StringTools.replace(query, "$2", value);

		return makeQuery(query).next(function(res) {
			return value;
		});
	}

	public function remove(key:String):Promise<Bool> {
		var query = "DELETE FROM $0 WHERE key = '$1'";
		query = StringTools.replace(query, "$0", _tableName);
		query = StringTools.replace(query, "$1", key);

		return makeQuery(query).next(function(res) {
			return true;
		});
	}

	public function keyValueIterator():AsyncIterator<KV<String, String>> {
        var pager = new DatabasePager(25, getPage);
		var pagedIterator = new PagedAsyncIterator(pager.loadNext);
		return pagedIterator;
	}

	public function getPage(limit:UInt, offset:UInt):Promise<Array<KV<String, String>>> {
		var query = "SELECT * FROM $0 ORDER BY key ASC LIMIT $2 OFFSET $3";
		query = StringTools.replace(query, "$0", _tableName);
		query = StringTools.replace(query, "$2", Std.string(limit));
		query = StringTools.replace(query, "$3", Std.string(offset));

		return makeQuery(query).next(function(res) {
			var rows:Array<PostgresRow> = res.rows;
			var arr = new Array<KV<String, String>>();
			for (r in rows) {
				var kv = new KVC(r.key, r.val);
				arr.push(kv);
			}
			return arr;
		});
	}

	public function clear():Promise<Noise> {
		var query = "DROP TABLE $0";
		query = StringTools.replace(query, "$0", _tableName);

		return makeQuery(query).noise();
	}

	public function toMap():Promise<Map<String, String>> {
		var query = "SELECT * FROM $0";
		query = StringTools.replace(query, "$0", _tableName);

		return makeQuery(query).next(function(res) {
			var rows:Array<PostgresRow> = res.rows;

			var m = new Map<String, String>();
			for (r in rows) {
				m.set(r.key, r.val);
			}
			return m;
		});
	}

	private var _queryID:Int = 0;

	private inline function makeQuery(query:String):Promise<Dynamic> {
		var qid = _queryID++;
		Log.debug('postgres query ${qid}:  ${query}');
		var p = new PromiseTrigger<Dynamic>();
		_postgresClient.query(query, function(err:Dynamic, res:Dynamic) {
			if (err != null) {
				var e = new Error('err with postgres query ${qid}:  ${err}');
				Log.error(e);
				p.reject(e);
			}
			p.resolve(res);
		});
		return p;
	}
}

typedef PostgresRow = {
	id:Int,
	key:String,
	val:String
}
