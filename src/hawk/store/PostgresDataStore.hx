package hawk.store;

import haxe.Constraints.IMap;
import hawk.async_iterator.PagedAsyncIterator;
import hawk.async_iterator.AsyncIterator;
import thx.AnonymousMap;
import tink.CoreApi;
import zenlog.Log;

class PostgresDataStore<T> implements IDataStore<T> {
	private var _postgresClient:Dynamic;
	private var _tableName:String;
	private var _model:DataModel<T>;
	private var _primaryKeyFieldName:String;

	public function new(postgresClient:Dynamic, tableName:String, model:DataModel<T>) {
		if (tableName.toLowerCase() != tableName) {
			throw('table name should be lowercase');
		}
		if (StringTools.trim(tableName) != tableName) {
			throw('table name should be trimmed...');
		}

		_postgresClient = postgresClient;
		_tableName = tableName;
		_model = model;
		_primaryKeyFieldName = _model.fields[0].name;
	}

	public function init():Promise<PostgresDataStore<T>> {

        var modelErrs = _model.validationErrors();
        if (modelErrs.length != 0){
            var errStr = modelErrs.join("..  ");
            return new Error('Invalid Data Model:  ${errStr}');
        }


		var fields = "";
		for (f in _model.fields) {
			fields += f.name + " VARCHAR";
			if (f.type == DataFieldType.Primary){
				fields += " PRIMARY KEY";
			} else if (f.type == DataFieldType.Unique){
				fields += " UNIQUE";
			}
			fields += ", ";
		}
		fields = fields.substr(0, -2);

		var query = '
        CREATE TABLE IF NOT EXISTS ${_tableName} (
            ${fields}
          );
        ';

		return makeQuery(query).next(function(_) {
			return this;
		});
	}

	public function dropTable():Promise<Noise> {
		var query = "DROP TABLE IF EXISTS $0";
		query = StringTools.replace(query, "$0", _tableName);
		return makeQuery(query).noise();
	}

	public function create(obj:T):Promise<T> {
		var data = _model.adapter.toB(obj);
		var query = "INSERT INTO _table_ (_fields_)
        VALUES(_vals_) RETURNING *";

		query = StringTools.replace(query, "_table_", _tableName);
		query = StringTools.replace(query, "_fields_", fieldsCSV());
		query = StringTools.replace(query, "_vals_", valsCSV(data));

		return makeQuery(query).next(itemsFromRes).next(function(res) {
            if (res.length != 1){
                Log.warn('INSERT returnd ${res.length}:');
                for (r in res){
                    Log.warn(r);
                }
            }
            return res[0];
        });
	}

	public function delete(obj:T):Promise<Bool> {
		var data = _model.adapter.toB(obj);
		var pk = primaryKey(data);
		return deleteByPK(pk);
	}

	public function update(obj:T):Promise<T> {
		var data = _model.adapter.toB(obj);
		var pk = primaryKey(data); 
		return setByPK(pk, data).next(function(_){
			return obj;
		});
	}

	private function fieldsCSV():String {
		var str = "";
		for (f in _model.fields) {
			str += f.name + ", ";
		}
		return str.substr(0, -2);
	}

	private function settersCSV(data:IMap<String,String>):String {
		var str = "";
		for (f in _model.fields){
			if (f.type == DataFieldType.Primary){
				continue;
			}
			str += f.name + " = '" + data.get(f.name) + "', ";
		}
		return str.substr(0, -2);
	}

	private function valsCSV(data:IMap<String,String>):String {
		var str = "";
		for (f in _model.fields) {
			str += "'" + data.get(f.name) + "', ";
		}
		return str.substr(0, -2);
	}


	private function setByPK(primaryKey:String, data:IMap<String,String>):Promise<Noise> {
		var query = " UPDATE _table_
        SET _setters_
        WHERE _pkField_ = '_pk_'";

		query = StringTools.replace(query, "_table_", _tableName);
		query = StringTools.replace(query, "_pkField_", _primaryKeyFieldName);
		query = StringTools.replace(query, "_setters_", settersCSV(data));
		query = StringTools.replace(query, "_pk_", Std.string(primaryKey));

		return makeQuery(query).noise();
	}

	private function deleteByPK(pk:String):Promise<Bool> {
		var query = "DELETE FROM _table_ WHERE _pkField_ = _pk_";
		query = StringTools.replace(query, "_pkField_", _primaryKeyFieldName);
		query = StringTools.replace(query, "_table_", _tableName);
		query = StringTools.replace(query, "_pk_", pk);

		return makeQuery(query).next(function(res) {
			return true;
		});
	}


	private function selectByPK(pk:Int):Promise<Null<T>> {
		var query = "SELECT * FROM _table_ WHERE _pkField_ = '_pk_'";
		query = StringTools.replace(query, "_pkField_", _primaryKeyFieldName);
		query = StringTools.replace(query, "_table_", _tableName);
		query = StringTools.replace(query, "_pk_", Std.string(pk));

		return makeQuery(query).next(itemsFromRes).next(function(res) {
			if (res.length == 0) {
				return Promise.resolve(null);
			}
			if (res.length != 1) {
				Log.warn('SELECT found ${res.length} results');
			}
			return Promise.resolve(res[0]);
		});
	}

	private function primaryKey(data:IMap<String,String>):String {
		return data.get(_primaryKeyFieldName);
	}


	public function iterator():AsyncIterator<T> {
		var postgresPager = new DatabasePager(25, getPage);
		var pagedIterator = new PagedAsyncIterator(postgresPager.loadNext);
		return pagedIterator;
	}

	public function getPage(limit:UInt, offset:UInt):Promise<Array<T>> {
		var query = "SELECT * FROM $0 ORDER BY _pkField_ ASC LIMIT $2 OFFSET $3";
		query = StringTools.replace(query, "$0", _tableName);
		query = StringTools.replace(query, "_pkField_", _primaryKeyFieldName);
		query = StringTools.replace(query, "$2", Std.string(limit));
		query = StringTools.replace(query, "$3", Std.string(offset));

		return makeQuery(query).next(itemsFromRes);
	}

	public function getIndexByColName(colName:String):IDataStoreIndex<String, T> {
		var getFunc = function(k:String):Promise<Null<T>> {
			Log.debug('get by col ${colName}:  ${k}');
			return selectWhere(colName, k);
		}
		return new DataStoreIndex(getFunc);
	}

	private function selectWhere(colName:String, value:String):Promise<Null<T>> {
		var query = "SELECT * FROM _table_ WHERE _colName_ = '_value_'";
		query = StringTools.replace(query, "_table_", _tableName);
		query = StringTools.replace(query, "_colName_", colName);
		query = StringTools.replace(query, "_value_", value);

		return makeQuery(query).next(itemsFromRes).next(function(res) {
			var p = new PromiseTrigger<Null<T>>();
			if (res.length == 0) {
				p.resolve(null);
				return p.asPromise();
			}
			if (res.length > 1) {
				Log.warn('SELECT found ${res.length} results');
			}
			p.resolve(res[0]);
			return p.asPromise();
		});
	}

	private function itemsFromRes(dbRes:Dynamic):Array<T> {
		var rows:Array<Dynamic> = dbRes.rows;
		var arr = new Array<T>();
		for (r in rows) {
			var item = rowToItem(r);
			arr.push(item);
		}
		return arr;
	}

	private inline function rowToItem(row:Dynamic): T {
		Log.debug('try convert DB row:  ${Std.string(row)}');
		var anonMap = new AnonymousMap<String>(row);
		Log.debug('- - got anonMap:  ${anonMap}');
		return _model.adapter.toA(anonMap);
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
