extends GDScript


var sm = preload('string_manip.gd').new()
var al = preload('array_logic.gd').new()
var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

func dice_parser(dice_string:String)->Dictionary:
	var rolling_rules: Dictionary = {}
	var valid_tokens = '[dksr!]'
	
	dice_string = dice_string.to_lower()
	
	
	# if its an integer just add a number
	if dice_string.is_valid_integer():
		rolling_rules['add'] = int(dice_string)
		rolling_rules['dice_count'] = 0
		rolling_rules['dice_side'] = 0
		rolling_rules['sort'] = false
		rolling_rules['explode'] = 0
		return rolling_rules
	
	
	# get the dice count or default to 1 if we just start with d.
	var result = sm.str_extract(dice_string,'^[0-9]*?(?=d)')
	assert_error(result!=null,'Malformed dice string')
	if result == '':
		rolling_rules['dice_count'] = 1
	elif result.is_valid_integer():
		rolling_rules['dice_count'] = int(result)
	
	# tokenize the rest of the rolling rules. a token character, followed by the
	# next valid token character or end of string. while processing, remove
	# all processed tokens and check for anything leftower at the end
		
	var tokens = sm.str_extract_all(dice_string,
	valid_tokens + '.*?((?=' + valid_tokens + ')|$)')
	
	var dice_side = sm.str_extract(tokens[0],'(?<=d)[0-9]+')
	assert_error(dice_side != null, "Malformed dice string")
	rolling_rules['dice_side'] = int(dice_side)
	# remove dice side token to make sure it's not confused with the drop rule
	tokens.remove(0)
	
	# check for sort rule, if s exists, sort the results
	var sort_rule = tokens.find('s')
	rolling_rules['sort'] = sort_rule != -1
	if sort_rule != -1:
		tokens.remove(sort_rule)
	
	# check for drop rules, there can only be one 
	var drop_rules = sm.strs_detect(tokens,'^(d|k)(h|l)?[0-9]+$')
	assert_error(drop_rules.size() <= 1,"Malformed dice string: Can't include more than one drop rule")
	if drop_rules.size() == 0:
		rolling_rules['drop_dice'] = 0
		rolling_rules['drop_lowest'] = true
	else:
		var drop_count = sm.str_extract(tokens[drop_rules[0]], '[0-9]+$')
		assert(drop_count!= null, 'Malformed dice string')
		var drop_rule = tokens[drop_rules[0]]
		match drop_rule.substr(0,1):
			'd':
				rolling_rules['drop_dice'] = drop_count
			'k':
				rolling_rules['drop_dice'] = rolling_rules['dice_count']-drop_count	
		rolling_rules['drop_lowest'] = !sm.str_detect(drop_rule,'dh') or sm.str_detect(drop_rule,'kl')
		tokens.remove(drop_rules[0])
	
	# reroll rules
	var reroll_rules = sm.strs_detect(tokens,'r(?!o)')
	var reroll:Array = []
	for i in reroll_rules:
		reroll.append_array(reroll_determine(tokens[i], rolling_rules['dice_side']))
	var dicePossibilities = range(1,rolling_rules['dice_side']+1)
	if al.all(al.array_in_array(dicePossibilities,reroll)):
		push_error('Malformed dice string: rerolling all results')
		rolling_rules['reroll'] = []
	else:
		rolling_rules['reroll'] = reroll
	# remove reroll rules
	reroll_rules.invert()
	for i in reroll_rules:
		tokens.remove(i)
	
	# reroll once
	reroll_rules = sm.strs_detect(tokens,'ro')
	var reroll_once:Array = []
	for i in reroll_rules:
		reroll_once.append_array(reroll_determine(tokens[i], rolling_rules['dice_side']))
	rolling_rules['reroll_once'] = reroll_once
	
	reroll_rules.invert()
	for i in reroll_rules:
		tokens.remove(i)
	
	
	# explode rules
	var explode_rules = al.which(al.array_in_array(tokens,['!']))
	if explode_rules.size()>2:
		push_error("Malformed dice string: Can't have more than 2 !s for exploding dice")
		rolling_rules['explode'] = 0
	else:
		rolling_rules['explode'] = explode_rules.size()
	explode_rules.invert()
	for i in explode_rules:
		tokens.remove(i)
	
	if tokens.size()>0:
		push_error('Malformed dice string: Unprocessed tokens')
	
	return rolling_rules

func reroll_determine(token:String,dice_side:int)->Array:
	var out:Array = []
	var number = sm.str_extract(token, '[0-9]*$')
	assert_error(!(sm.str_detect(token,'<|>') and number ==''),'Malformed dice string: Rerolling with "<" or ">" identifiers requires an integer')
	assert_error(!(sm.str_detect(token,'<') and sm.str_detect(token,'>')),'Malformed dice string: Single rerolling clause can only have one of "<" or ">"')
	if !sm.str_detect('<|>',token) and number == '':
		out.append(1)
	elif number != '' and !sm.str_detect(token, '<|>'):
		out.append(int(number))
	elif sm.str_detect(token, '<') and number != '':
		out.append_array(range(1,int(number)+1))
	elif sm.str_detect(token, '>') and number != '':
		out.append_array(range(int(number),dice_side+1))
	
	return out

func assert_error(condition:bool,message:String):
	if(!condition):
		push_error(message)


func roll_param(rolling_rules)->Dictionary:
	print(rolling_rules)
	var out:Dictionary = {}
	var possible_dice = range(1,rolling_rules.dice_side+1)
	possible_dice = al.array_subset(possible_dice,al.which(al.array_not(al.array_in_array(possible_dice, rolling_rules.reroll))))
	print(possible_dice)
	
	
	
	return out
