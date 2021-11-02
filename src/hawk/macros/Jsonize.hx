package hawk.macros;

import hawk.general_tools.adapters.TStringAdapter;

#if macro
import haxe.macro.Type.ClassField;
import haxe.macro.ComplexTypeTools;
import haxe.macro.Type.ClassType;
import haxe.macro.TypeTools;
import haxe.macro.ExprTools;
import haxe.macro.Context;
import haxe.macro.Expr;

using tink.MacroApi;
#end

class Jsonize {
	// TODO - better check for overrides...
	#if !macro 
	public static function process(){}
	#end
	#if macro
	macro public static function process():Array<Field> {
		var fields = Context.getBuildFields();

		//TypeTools.toComplexType(Context.getLocalType())

		// get existing fields from the context from where build() is called
		// var xClass = Context.getLocalClass().get();
		var xType = TypeTools.toComplexType(Context.getLocalType());
		var cType = TypeTools.toComplexType(Context.getLocalType());
		// trace('Jsonize ${xType.getName()} ... ${xType}  ${xType.toString()}');

		var xClass = Context.getLocalClass().get();
		trace('Jsonize ${xClass.name}');

		var fields = Context.getBuildFields();

		if (!exists(fields, 'toJson')) {
			fields.push(buildToJson(xClass, cType));
		}

		if (!exists(fields, 'fromJson')) {
			fields.push(buildfromJson(xClass, cType));
		}

		// if (!exists(fields, 'jsonAdapter')) {
		// 	fields.push(buildAdapter(xClass, cType));
		// }

		trace('--- done with ${xClass.name} ---');
		return fields;
	}

	private static function buildToJson(xType:ClassType, cType:ComplexType):Field {

		var name = xType.name;

		var code = '{
			var writer = new json2object.JsonWriter<$name>();
			return writer.write(obj);
		}';

		var funcBody = Context.parse(code, Context.currentPos());

		var funcDef:Function = {
			expr: funcBody,
			ret: macro:String,
			args: [
				{
					name: 'obj',
					type: cType
				}
			]
		};

		var field = {
			access: [APublic, AStatic],
			kind: FFun(funcDef),
			name: 'toJson',
			pos: Context.currentPos()
		}
		return field;
	}

	private static function buildfromJson(xType:ClassType, cType:ComplexType):Field {

		var name = xType.name;

		var code = '{
			var parser = new json2object.JsonParser<$name>();
			return parser.fromJson(json);
		}';

		var funcBody = Context.parse(code, Context.currentPos());

		var funcDef:Function = {
			expr: funcBody,
			ret: cType,
			args: [
				{
					name: 'json',
					type: macro:String
				}
			]
		};

		var field = {
			access: [APublic, AStatic],
			kind: FFun(funcDef),
			name: 'fromJson',
			pos: Context.currentPos()
		}
		return field;
	}

	// private static function buildAdapter(xType:ClassType, cType:ComplexType):Field {

	// 	var name = xType.name;

	// 	// var expr = Context.parse('TStringAdapter<$name>', Context.currentPos());

	// 	// var fuck = TPath()

	// 	// public static function jsonAdapter():TStringAdapter<CreateGalleryCommand> {
	// 	// 	return new TStringAdapter(toJson, fromJson);
	// 	// }

	// 	Context.defineType()

	// 	var fuck = Context.getType('TStringAdapter<$name>').toComplex();

	// 	var code = '{
	// 		return new TStringAdapter(toJson, fromJson);
	// 	}';

	// 	var funcBody = Context.parse(code, Context.currentPos());

	// 	var funcDef:Function = {
	// 		expr: funcBody,
	// 		ret: fuck,
	// 		args: []
	// 	};

	// 	var field = {
	// 		access: [APublic, AStatic],
	// 		kind: FFun(funcDef),
	// 		name: 'jsonAdapter',
	// 		pos: Context.currentPos()
	// 	}
	// 	return field;
	// }

	private static function exists(fields:Array<Field>, needle:String):Bool {
		for (f in fields) {
			if (f.name == needle) {
				return true;
			}
		}
		return false;
	}
	#end
}

