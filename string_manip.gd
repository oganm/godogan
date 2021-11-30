extends GDScript

var regex = RegEx.new()

func str_extract(string:String,pattern:String):
	regex.compile(pattern)
	var result:RegExMatch = regex.search(string)
	if result == null:
		return null
	else:
		return  result.get_string()

func str_extract_all(string:String,pattern:String)->Array:
	var out:Array
	regex.compile(pattern)
	for x in regex.search_all(string):
		out.append(x.get_string())
	return(out)

func str_detect(string:String, pattern:String)-> bool:
	var out:bool
	regex.compile(pattern)
	var result:RegExMatch = regex.search(string)
	return result != null


# vectorized over an array of strings to return indexes of matching
func strs_detect(strings:Array,pattern:String)->Array:
	var out:Array
	for i in range(strings.size()):
		if str_detect(strings[i],pattern):
			out.append(i)
	
	return out
