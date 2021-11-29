extends GDScript


var sm = preload('string_manip.gd').new()
var regex := RegEx.new()

func dice_parser(dice_string:String)->Dictionary:
	var rolling_rules: Dictionary
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
	var result = sm.str_extract(dice_string,'^[0-9]*?(?=d)',regex)
	assert(result!=null,'Malformed dice string')
	if result == '':
		rolling_rules['dice_count'] = 1
	elif result.is_valid_integer():
		rolling_rules['dice_count'] = int(result)
	
	# tokenize the rest of the rolling rules. a token character, followed by the
	# next valid token character or end of string. while processing, remove
	# all processed tokens and check for anything leftower at the end
		
	var tokens = sm.str_extract_all(dice_string,
	valid_tokens + '.*?((?=' + valid_tokens + ')|$)',
	regex)
	
	var dice_side = sm.str_extract(tokens[0],'(?<=d)[0-9]+',regex)
	assert(dice_side != null, "Malformed dice string")
	rolling_rules['dice_side'] = int(dice_side)
	# remove dice side token to make sure it's not confused with the drop rule
	tokens.remove(0)
	
	# check for sort rule, if s exists, sort the results
	var sort_rule = tokens.find('s')
	rolling_rules['sort'] = sort_rule != -1
	if sort_rule != -1:
		tokens.remove(sort_rule)
	
	# check for drop rules, there can only be one 
	var drop_rules = sm.strs_detect(tokens,'^(d|k)(h|l)?[0-9]+$',regex)
	assert(drop_rules.size() <= 1,"Malformed dice string: Can't include more than one drop rule")
	if drop_rules.size() == 0:
		rolling_rules['drop_dice'] = 0
		rolling_rules['drop_lowest'] = true
	else:
		var drop_count = sm.str_extract(tokens[drop_rules[0]], '[0-9]+$',regex)
		assert(drop_count!= null, 'Malformed dice string')
		var drop_rule = tokens[drop_rules[0]]
		match drop_rule.substr(0,1):
			'd':
				rolling_rules['drop_dice'] = drop_count
			'k':
				rolling_rules['drop_dice'] = rolling_rules['dice_count']-drop_count	
		rolling_rules['drop_lowest'] = !sm.str_detect(drop_rule,'dh',regex) or sm.str_detect(drop_rule,'kl',regex)
		tokens.remove(drop_rules[0])
	
	# reroll rules
	
	# explode rules
	
	print(tokens)
	return rolling_rules
