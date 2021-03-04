package hawk.store;

import hawk.async_iterator.PagedAsyncIterator;
import hawk.async_iterator.AsyncIterator;
import thx.AnonymousMap;
import tink.CoreApi;
import zenlog.Log;

class PostgresDataStore<T> implements IDataStore<T> {
	private var _postgresClient:Dynamic;
	private var _tableName:String;
	private var _model:DataModel<T>;

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
			if (f.unique) {
				fields += " UNIQUE";
			}
			fields += ", ";
		}
		fields = fields.substr(0, -2);

		var query = '
        CREATE TABLE IF NOT EXISTS ${_tableName} (
            pk SERIAL PRIMARY KEY,
            ${fields}
          );
        ';

		return dropTable().next(function(_) {
			return makeQuery(query).next(function(_) {
				return this;
			});
		});
	}

	public function dropTable():Promise<Noise> {
		var query = "DROP TABLE IF EXISTS $0";
		query = StringTools.replace(query, "$0", _tableName);
		return makeQuery(query).noise();
	}

	public function create(data:T):Promise<IDataItem<T>> {
		var row = _model.adapter.toB(data);
		var query = "INSERT INTO _table_ (_fields_)
        VALUES(_vals_) RETURNING *";

		query = StringTools.replace(query, "_table_", _tableName);
		query = StringTools.replace(query, "_fields_", fieldsCSV());
		query = StringTools.replace(query, "_vals_", valsCSV(row));

		return makeQuery(query).next(dataItemsFromRes).next(function(res) {
            if (res.length != 1){
                Log.warn('INSERT returnd ${res.length}:');
                for (r in res){
                    Log.warn(r);
                }
            }
            return res[0];
        });
	}

	private function fieldsCSV():String {
		var str = "";
		for (f in _model.fields) {
			str += f.name + ", ";
		}
		return str.substr(0, -2);
	}

	private function settersCSV(v:Array<String>):String {
		var str = "";
		for (i in 0...v.length) {
			str += _model.fields[i].name + " = " + v[i] + ", ";
		}
		return str.substr(0, -2);
	}

	private function valsCSV(v:Array<String>):String {
		var str = "";
		for (i in 0...v.length) {
			str += "'" + v[i] + "', ";
		}
		return str.substr(0, -2);
	}

	private function createDataItem(primaryKey:Int, data:DataRow):IDataItem<T> {
		var deps = {
			adapter: _model.adapter,
			save: setByPK,
			delete: deleteByPK
		};
		var dataItem = new DataItem<T>(deps, primaryKey, data);
		return dataItem;
	}

	private function setByPK(primaryKey:Int, row:DataRow):Promise<Noise> {
		var query = " UPDATE _table_
        SET _setters_
        WHERE pk = _pk_";

		query = StringTools.replace(query, "_table_", _tableName);
		query = StringTools.replace(query, "_setters_", settersCSV(row));
		query = StringTools.replace(query, "_pk_", Std.string(primaryKey));

		return makeQuery(query).noise();
	}

	private function deleteByPK(pk:Int):Promise<Bool> {
		var query = "DELETE FROM _table_ WHERE pk = _pk_";
		query = StringTools.replace(query, "_table_", _tableName);
		query = StringTools.replace(query, "_pk_", Std.string(pk));

		return makeQuery(query).next(function(res) {
			return true;
		});
	}

	private function selectByPK(pk:Int):Promise<Null<IDataItem<T>>> {
		var query = "SELECT FROM _table_ WHERE pk = _pk_";
		query = StringTools.replace(query, "_table_", _tableName);
		query = StringTools.replace(query, "_pk_", Std.string(pk));

		return makeQuery(query).next(dataItemsFromRes).next(function(res) {
			if (res.length == 0) {
				return Promise.resolve(null);
			}
			if (res.length != 1) {
				Log.warn('SELECT found ${res.length} results');
			}
			return Promise.resolve(res[0]);
		});
	}

	private function rowToDataRow(row:Dynamic):DataRow {
		Log.debug('try convert DB row:  ${Std.string(row)}');
		var map = new AnonymousMap<String>(row);
		Log.debug('- - got anonMap:  ${map}');
		var res = new Array<String>();
		for (f in _model.fields) {
			res.push(map.get(f.name));
		}
		return res;
	}

	public function iterator():AsyncIterator<IDataItem<T>> {
		var postgresPager = new DatabasePager(25, getPage);
		var pagedIterator = new PagedAsyncIterator(postgresPager.loadNext);
		return pagedIterator;
	}

	public function getPage(limit:UInt, offset:UInt):Promise<Array<IDataItem<T>>> {
		var query = "SELECT * FROM $0 ORDER BY pk ASC LIMIT $2 OFFSET $3";
		query = StringTools.replace(query, "$0", _tableName);
		query = StringTools.replace(query, "$2", Std.string(limit));
		query = StringTools.replace(query, "$3", Std.string(offset));
		logQuery(query);

		return makeQuery(query).next(dataItemsFromRes);
	}

	public function getIndexByColName(colName:String):IDataStoreIndex<String, T> {
		var getFunc = function(k:String):Promise<Null<IDataItem<T>>> {
			Log.debug('get by col ${colName}:  ${k}');
			return selectWhere(colName, k);
		}
		return new DataStoreIndex(getFunc);
	}

	private function selectWhere(colName:String, value:String):Promise<Null<IDataItem<T>>> {
		var query = "SELECT FROM _table_ WHERE _colName_ = _value_";
		query = StringTools.replace(query, "_table_", _tableName);
		query = StringTools.replace(query, "_colName_", colName);
		query = StringTools.replace(query, "_value_", value);

		return makeQuery(query).next(dataItemsFromRes).next(function(res) {
			var p = new PromiseTrigger<Null<IDataItem<T>>>();
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

	private function dataItemsFromRes(dbRes:Dynamic):Array<IDataItem<T>> {
		var rows:Array<Dynamic> = dbRes.rows;
		var arr = new Array<IDataItem<T>>();
		for (r in rows) {
			var dataRow = rowToDataRow(r);
			var dataItem = createDataItem(r.pk, dataRow);
			arr.push(dataItem);
		}
		return arr;
	}

	private inline function logQuery(query:String) {
		Log.debug("postgres query:  " + query);
	}

	private inline function queryErr(err:String):Error {
		return new Error('postgres error:  ${err}');
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
