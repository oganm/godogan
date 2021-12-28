extends GDScript
class_name string_manip


static func str_extract(string:String,pattern:String):
	var regex = RegEx.new()
	regex.compile(pattern)
	var result:RegExMatch = regex.search(string)
	if result == null:
		return null
	else:
		return  result.get_string()

static func str_extract_all(string:String,pattern:String)->Array:
	var regex = RegEx.new()
	var out:Array
	regex.compile(pattern)
	for x in regex.search_all(string):
		out.append(x.get_string())
	return(out)

static func str_detect(string:String, pattern:String)-> bool:
	var regex = RegEx.new()
	var out:bool
	regex.compile(pattern)
	var result:RegExMatch = regex.search(string)
	return result != null


# vectorized over an array of strings to return indexes of matching
static func strs_detect(strings:Array,pattern:String)->Array:
	var out:Array
	for i in range(strings.size()):
		if str_detect(strings[i],pattern):
			out.append(i)
	
	return out
