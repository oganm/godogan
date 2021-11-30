extends GDScript
# functions meant to deal with arrays

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

# check if all is true in an array
func all(array:Array)->bool:
	var out = true
	for x in array:
		if !x:
			out = false
	return out

func any(array:Array)->bool:
	var out = false
	for x in array:
		if x:
			out = true
	return out

func sum(array:Array)->int:
	var out:int = 0
	for x in array:
		if x:
			out +=1
	return out

func array_in_array(array:Array,target:Array)->Array:
	var out:Array
	for i in range(array.size()):
		out.append(target.find(array[i]) != -1)
	return out

func which_in_array(array:Array,target:Array)->Array:
	var out:Array
	for i in range(array.size()):
		if target.find(array[i]) != -1:
			out.append(i)
	return out

func which(array:Array)->Array:
	var out:Array
	for i in range(array.size()):
		if array[i]:
			out.append(i)
	return out

func array_not(array:Array)->Array:
	var out:Array
	for x in array:
		out.append(not x)
	return out

func array_subset(array:Array, indices:Array)->Array:
	var out:Array
	for i in indices:
		out.append(array[i])
	return out

func sample(array:Array,n:int,replace:bool = true)->Array:
	var out:Array = []
	if not replace and n>array.size():
		push_error('Cannot take a sample larger than the population when replace = false')
		return out
	
	for i in range(n):
		var samp = rng.randi_range(0,array.size()-1)
		out.append(array[samp])
		if not replace:
			array.remove(samp)
		
	
	
	return out

func tests():
	print('testing logic functions')
	var true_true = [true,true]
	var true_false = [true,false]
	var false_false = [false,false]
	
	assert(sum(true_true) == 2,"bad sum")
	assert(sum(true_false) == 1,"bad sum")
	assert(sum(false_false) == 0, 'bad sum')
	assert(any(true_false),'bad any')
	assert(all(true_true),'bad all')
	assert(!all(true_false),'bad all')
	assert(any(array_in_array(true_false,true_true)),'bad array_in_array')
	assert(!all(array_in_array(true_false,true_true)),'bad array_in_array')
