extends Node2D
@onready var stone_blocks: Node = $StoneBlocks
@onready var player: CharacterBody2D = $Player
@onready var boundary: StaticBody2D = $GameCenter/Boundary
@onready var game_area: Area2D = $GameCenter/GameArea
@onready var money_label: Label = $MoneyLabel
@onready var moving_objects: Node = $MovingObjects
@onready var crawlers: Node = $Crawlers
@onready var health_marker: Marker2D = $HealthMarker
@onready var music_1: AudioStreamPlayer2D = $Music1
@onready var music_2: AudioStreamPlayer2D = $Music2
@onready var gold_rush_time: Timer = $GoldRushTime
@onready var combo_label: Label = $ComboLabel
@onready var combo_bonus_label: Label = $ComboBonusLabel
@onready var bounty_time: Timer = $BountyTime
@onready var bounty_icon: Sprite2D = $BountyIcon
@onready var background: Node2D = $Background
@onready var laser_sfx: AudioStreamPlayer2D = $SFX/LaserSFX
@onready var ore_gain_sfx: AudioStreamPlayer2D = $SFX/OreGainSFX
@onready var hurt_sfx: AudioStreamPlayer2D = $SFX/HurtSFX
@onready var explosion_sfx: AudioStreamPlayer2D = $SFX/ExplosionSFX
@onready var power_up_sfx: AudioStreamPlayer2D = $SFX/PowerUpSFX
@onready var load_player: Node2D = $LoadPlayer
@onready var level_label: Label = $LevelLabel
@onready var moving_labels: Node = $MovingLabels
@onready var goal_label: Label = $GoalLabel


var scroll_speed = 1
var game_width = 0
var game_height = 0
var bodies_chunk
var money = 0
var health = 5
var block_ready_count = -1

var ore_rarity = [1, 0.30, 0.1, 0.01, 0.001]
var ore_rarity_increase = []
var base_ore_amount = 25
var base_magma_amount = 10
var chunk_count = 0
var level = 0
var gold_rush_active = false
var combo = 0
var bounty_active = false
var beam_timeout = 0
var last_gradient_flipped = false
var chunk_bottom = 3000

signal reset_game

func _ready() -> void:
	var rect = game_area.get_node("CollisionShape2D").shape.get_rect()
	game_width = abs(rect.position.x - rect.end.x)
	game_height = abs(rect.position.y - rect.end.y)
	boundary.get_node("Top").position.y = rect.position.y
	boundary.get_node("Bottom").position.y = rect.end.y
	boundary.get_node("Left").position.x = rect.position.x
	boundary.get_node("Right").position.x = rect.end.x

	display_health()
	
	for i in 13:
		ore_rarity_increase.append([])
	
	#ore_rarity_increase[0] = [0, 0.02, 0.003, 0.00025, 0.0001]
	#ore_rarity_increase[1] = [0, 0.03, 0.007, 0.0005, 0.0002]
	#ore_rarity_increase[2] = [0, 0.03, 0.008, 0.004, 0.0003]
	#ore_rarity_increase[3] = [0, 0.02, 0.01, 0.008, 0.0004]
	#ore_rarity_increase[4] = [0, 0, 0.01, 0.008, 0.0005]
	#ore_rarity_increase[5] = [0, 0, 0.01, 0.008, 0.001]
	#ore_rarity_increase[5] = [0, 0, 0.01, 0.008, 0.003]
	#ore_rarity_increase[6] = [0, 0, 0.01, 0.008, 0.003]
	#ore_rarity_increase[7] = [0, 0, 0.005, 0.005, 0.002]
	#ore_rarity_increase[8] = [0, 0, 0.005, 0.003, 0.001]

	
	ore_rarity_increase[0] = [0, 0.02, 0.005, 0.001, 0.0003]
	ore_rarity_increase[1] = [0, 0.03, 0.01, 0.005, 0.0004]
	ore_rarity_increase[2] = [0, 0.03, 0.03, 0.005, 0.0005]
	ore_rarity_increase[3] = [0, 0.02, 0.02, 0.007, 0.0006]
	ore_rarity_increase[4] = [0, 0, 0.02, 0.008, 0.001]
	ore_rarity_increase[5] = [0, 0, 0.005, 0.007, 0.001]
	ore_rarity_increase[5] = [0, 0, 0.005, 0.005, 0.001]
	ore_rarity_increase[6] = [0, 0, 0.005, 0.002, 0.001]
	ore_rarity_increase[7] = [0, 0, 0.005, 0.002, 0.001]
	ore_rarity_increase[8] = [0, 0, 0.005, 0.002, 0.001]
	ore_rarity_increase[9] = [0, 0, 0.003, 0.002, 0.001]
	ore_rarity_increase[10] = [0, 0, 0.001, 0.001, 0.001]
	ore_rarity_increase[11] = [0, 0, 0.001, 0.001, 0.001]
	ore_rarity_increase[12] = [0, 0, 0, 0, 0]

	
	generate_chunk(0)
	
	music_1.play()
	
	load_player._on_load_character()
	

func _physics_process(delta: float) -> void:
	var final_scroll_speed = scroll_speed
	if gold_rush_active:
		final_scroll_speed = scroll_speed * 2
	chunk_bottom -= final_scroll_speed
	for b in stone_blocks.get_children():
		if bodies_chunk:
			var rect = game_area.get_node("CollisionShape2D").shape.get_rect()
			if chunk_bottom - final_scroll_speed <= rect.end.y:
				generate_chunk((chunk_bottom - final_scroll_speed + 1) - rect.end.y)
		b.global_position.y -= final_scroll_speed
	for sb in moving_objects.get_children():	
		sb.global_position.y -= final_scroll_speed
	for bg in background.get_children():
		bg.global_position.y -= final_scroll_speed
	for ml in moving_labels.get_children():
		ml.global_position.y -= final_scroll_speed
		
	if block_ready_count < 180 && bodies_chunk:
		check_raycast_ready()
	
	magma_drip()
	
	if beam_timeout > 0:
		beam_timeout -= 1
		if beam_timeout == 0:
			player.beam.visible = false
			player.cpu_particles.emitting = false
			
	if beam_timeout > 0:
		if player.gun_ray_cast.is_colliding():
			player.beam.remove_point(1)
			var body = player.gun_ray_cast.get_collider()
			var both_distances = abs(player.gun_ray_cast.get_collision_point() - player.global_position)
			var dis = sqrt(pow(both_distances[0], 2) + pow(both_distances[1], 2))
			player.beam.add_point(Vector2(dis, 0))
			player.target.position = Vector2(dis, 0)
		if !player.gun_ray_cast.is_colliding():
			player.beam.remove_point(1)
			player.beam.add_point(Vector2(player.gun_ray_cast.target_position[0], 0))
			player.target.position = Vector2(player.gun_ray_cast.target_position[0], 0)
	
func display_health():	
	for c in health_marker.get_children():
		c.queue_free()
	
	const HEART = preload("res://FUZ/FuzMinigame3/health_point.tscn")
	
	const OFFSET = 50
	if health > 0:
		for a in health:
			var new_heart = HEART.instantiate()
			health_marker.add_child(new_heart)
			new_heart.position = Vector2(OFFSET*a, 0)
		
func check_raycast_ready():
	for yy in 10:
		for xx in 18:
			var block = bodies_chunk[yy][xx]
			if (block.ray_cast_2d.is_colliding() || block.at_bottom) && !block.ray_cast_is_ready:
				block.ray_cast_is_ready = true
				block_ready_count += 1

func magma_drip():
	for b in stone_blocks.get_children():
		if b.block_type == "MAGMA" && !b.ray_cast_2d.is_colliding():
			if b.at_bottom:
				continue
			if block_ready_count != 180:
				continue
			if b.lava_drip_time <= 0:
				const DROP = preload("res://FUZ/FuzMinigame3/lava_drop.tscn")
				var new_drop = DROP.instantiate()
				new_drop.global_position = b.global_position
				new_drop.magma_origin = b
				add_child(new_drop)
				#lava_drop_sfx.play()
				b.lava_drip_time = 100
			b.lava_drip_time -= 1
	
func find_block_chunk_position(block):
	if !bodies_chunk:
		return null
	for yy in 10:
		for xx in 18:
			if bodies_chunk[yy][xx] == block:
				return [yy, xx]
	return null
	
func _on_create_crawler(burrowing_crawler):
	
	const CRAWLER = preload("res://FUZ/FuzMinigame3/crawler.tscn")
	var crawler = CRAWLER.instantiate()
	crawler.crawler_die.connect(_on_crawler_die)
	crawler.check_crawler_raycast.connect(_on_check_crawler_raycast)
	crawler.global_position = burrowing_crawler.global_position
	crawler.direction = burrowing_crawler.side
	
	crawlers.add_child(crawler)
	moving_objects.remove_child(burrowing_crawler)
	burrowing_crawler.queue_free()
	
func _on_crawler_die(crawler):
	crawlers.remove_child(crawler)
	crawler.queue_free()
		
func _on_check_crawler_raycast(crawler, collider):
		if stone_blocks.get_children().has(collider):
			if collider.get_collision_layer_value(3):	
				crawler.crawler_die.emit(crawler)
	
func rarity_percent(rarity_index):
	var sum = 0.0
	var offset = 0.0
	for r in ore_rarity.size():
		sum += ore_rarity[r]
		if r < rarity_index:
			offset += ore_rarity[r]
	return (offset + ore_rarity[rarity_index]) / sum
	
func fit_range(viable, block_range):
	var too_big = true
	var sections = get_sections(viable)
	var new_range = block_range
	while too_big && new_range > 0:
		for s in sections:
			if s.size() >= new_range*2 + 1:
				too_big = false
		if too_big:
			new_range -= 1
	return new_range
			
			
func remove_blocks_from_viable(viable, block_viable):
	var copied_viable = viable.filter(func(v): return v)
	var new_viable = viable.filter(func(v): return v)
	if block_viable:
		for v in copied_viable:
			if !block_viable.has(v):
				new_viable.pop_at(viable.find(v))
	return new_viable
	
func get_sections(viable):
	var sections = []
	sections.append([])
	var section_num = 0
	var current_row = 0
	for v in viable.size():
		if viable[v][0] > current_row:
			sections.append([])
			section_num += 1
			current_row += 1
		if !sections[section_num].is_empty():
			if viable[v][1] - sections[section_num].back()[1] > 1:
				sections.append([])
				section_num += 1
		sections[section_num].append(viable[v])
	return sections
	
func cut_object_from_viable(viable, spot, block_range):
	var remove_start = -1
	var new_viable = viable.filter(func(v): return v)
	for v in viable.size():
		if viable[v][0] == spot[0] && viable[v][1] == spot[1]:
			remove_start = v - block_range
	
	for r in block_range*2 + 1:
		new_viable.pop_at(remove_start)
	return new_viable
	
func find_viable_spot(viable, block_range):
	var sections = get_sections(viable)

	var viable_sections = []
	for s in sections:
		if s.size() >= block_range*2 + 1:
			viable_sections.append(s)
	if viable_sections.size() == 0:
		return null
	var r_section = round(randf() * (viable_sections.size() - 1))
	var final_viable = []
	for v in viable_sections[r_section].size():
		if v >= block_range && v <= viable_sections[r_section].size() - 1 - block_range:
			final_viable.append(viable_sections[r_section][v])
	
	var r_place = round(randf() * (final_viable.size() - 1))
		
	return final_viable[r_place]
	
func generate_chunk(yoffset):
	#18, 10. 180 blocks
	
	##Create chunk 2D array starting with only stone
	var chunk = []
	for yy in 10:
		var row = []
		for xx in 18:
			row.append("STONE")
		chunk.append(row)
		
	##Viable represents an array of viable spots ([y, x]) to put new hazards and powerups in. 
	## Newly created moving objects will have their position and positions covered by their range removed from viable so future objects do not overlap.
	var viable = []
	for yy in 10:
		var row = []
		for xx in 18:
			row.append([yy, xx])
		viable.append_array(row)
		
	##Create background objects
	var rect = game_area.get_node("CollisionShape2D").shape.get_rect()
	
	var bg_viable = viable.filter(func(v): return v[0] > 2 && v[0] < 7 && v[1] > 2 && v[1] < 15)
	var rbg = round(randf() * (bg_viable.size() - 1))
	const BGELEMENT = preload("res://FUZ/FuzMinigame3/bg_element.tscn")
	var new_bg =  BGELEMENT.instantiate()
	var rbg_sprite = round(randf() * (new_bg.get_node("Sprites").get_children().size() - 1))
	new_bg.get_node("Sprites").get_children()[rbg_sprite].visible = true
	new_bg.global_position.x = rect.position.x + (64 * bg_viable[rbg][1]) + 32
	new_bg.global_position.y = rect.end.y + (64 * bg_viable[rbg][0]) + 32 + yoffset
	background.add_child(new_bg)
	
	
	##Create background gradient
	const GRADIENT = preload("res://FUZ/FuzMinigame3/gradient.tscn")
	var gradient =  GRADIENT.instantiate()
	gradient.global_position.x = 0
	gradient.global_position.y = rect.end.y + 648/2 + yoffset
	if last_gradient_flipped:
		last_gradient_flipped = false
	else:
		last_gradient_flipped = true
	gradient.get_node("TextureRect").flip_v = last_gradient_flipped
	background.add_child(gradient)
	
	
	##Fill random spots in chunk 2D array with strings representing ores
	for t in 25:
		var r = round(randf() * (viable.size() - 1))
		
		var ore_roll = randf()
		if ore_roll <= rarity_percent(0):
			chunk[viable[r][0]][viable[r][1]] = "TOPAZ"
		if ore_roll > rarity_percent(0) && ore_roll <= rarity_percent(1):
			chunk[viable[r][0]][viable[r][1]] = "SAPPHIRE"
		if ore_roll > rarity_percent(1) && ore_roll <= rarity_percent(2):
			chunk[viable[r][0]][viable[r][1]] = "EMERALD"
		if ore_roll > rarity_percent(2) && ore_roll <= rarity_percent(3):
			chunk[viable[r][0]][viable[r][1]] = "RUBY"
		if ore_roll > rarity_percent(3) && ore_roll <= rarity_percent(4):
			chunk[viable[r][0]][viable[r][1]] = "DIAMOND"
			
	##Increase rarity of ore
	for r in ore_rarity.size():	
		ore_rarity[r] += ore_rarity_increase[level][r]
	print("###ORE RARITY###")
	print(ore_rarity)
	print("################")
	
	##Fill random spots left in chunk 2D array with magma and nitro blocks
	for t in 10 + level:
		var r = round(randf() * (viable.size() - 1))
		chunk[viable[r][0]][viable[r][1]] = "MAGMA"
		viable.pop_at(r)
	
	for n in 1 + floor(level*0.25):
		var r_spawn = randf()
		if r_spawn > 0.5:
			var r = round(randf() * (viable.size() - 1))
			chunk[viable[r][0]][viable[r][1]] = "NITRO"
			viable.pop_at(r)
	
	##Make the bottom blocks know they can drip magma now
	for b in stone_blocks.get_children():
		b.at_bottom = false
		b.old_chunk = true

	block_ready_count = 0
	
	##viable = remove_blocks_from_viable(viable, block_viable)
		
	##Create data for moving hazards
	var moving = []
	for sb in 1 + floor(0.35*level):
		var r_select = round(randf())
		if r_select == 0:
			moving.append("sawblade")
		if r_select == 1:
			moving.append("crawler")
	
	##Create data for the powerup
	var random_powerup = randf()
	if random_powerup <= 0.2:
		moving.append("apple")
	if random_powerup > 0.2 && random_powerup <= 0.4:
		moving.append("gold_rush")
	if random_powerup > 0.4 && random_powerup <= 0.6:
		moving.append("bounty")
		
	##Create actual instances of the moving hazards and powerups
	for moving_obj in moving:
		var block_range = fit_range(viable, round(randf() * 3) + 1)
		if moving_obj == "apple" || moving_obj == "gold_rush" || moving_obj == "bounty":
			block_range = 0
		
		var spot = find_viable_spot(viable, block_range)
		viable = cut_object_from_viable(viable, spot, block_range)
		
		var moving_object = null
		if moving_obj == "sawblade":
			const SAWBLADE = preload("res://FUZ/FuzMinigame3/sawblade.tscn")
			moving_object = SAWBLADE.instantiate()
		if moving_obj == "crawler":
			const CRAWLER = preload("res://FUZ/FuzMinigame3/crawler_burrowing.tscn")
			moving_object = CRAWLER.instantiate()
			moving_object.create_crawler.connect(_on_create_crawler)
		if moving_obj == "apple":
			const POWERUP = preload("res://FUZ/FuzMinigame3/power_up.tscn")
			moving_object = POWERUP.instantiate()
			moving_object.powerup_get.connect(_on_apple_get)
		if moving_obj == "gold_rush":
			const POWERUP = preload("res://FUZ/FuzMinigame3/power_up.tscn")
			moving_object = POWERUP.instantiate()
			moving_object.powerup_get.connect(_on_gold_rush_get)
			moving_object.get_node("Apple").visible = false
			moving_object.get_node("GoldRush").visible = true
		if moving_obj == "bounty":
			const POWERUP = preload("res://FUZ/FuzMinigame3/power_up.tscn")
			moving_object = POWERUP.instantiate()
			moving_object.powerup_get.connect(_on_bounty_get)
			moving_object.get_node("Apple").visible = false
			moving_object.get_node("Bounty").visible = true
		moving_object.global_position.x = rect.position.x + (64 * spot[1]) + 32
		moving_object.global_position.y = rect.end.y + (64 * spot[0]) + 32 + yoffset
		if block_range != 0:
			moving_object.range = 64 * block_range
		moving_objects.add_child(moving_object)
	
	##Create actual instances of blocks from the chunk 2D array data
	bodies_chunk = []
	chunk_bottom = rect.end.y + (64 * 9) + 64 + yoffset
	for yy in 10:
		bodies_chunk.append([])
		for xx in 18:
			const BLOCK = preload("res://FUZ/FuzMinigame3/stone_block.tscn")
			var new_block =  BLOCK.instantiate()
			new_block.global_position.x = rect.position.x + (64 * xx) + 32
			new_block.global_position.y = rect.end.y + (64 * yy) + 32 + yoffset
			
			if chunk[yy][xx] == "TOPAZ":
				new_block.get_node("StoneBlock").visible = false
				new_block.get_node("TopazBlock").visible = true
				new_block.block_type = "ORE"
				new_block.ore_type = "TOPAZ"
				
			if chunk[yy][xx] == "SAPPHIRE":
				new_block.get_node("StoneBlock").visible = false
				new_block.get_node("SapphireBlock").visible = true
				new_block.block_type = "ORE"
				new_block.ore_type = "SAPPHIRE"
				
			if chunk[yy][xx] == "EMERALD":
				new_block.get_node("StoneBlock").visible = false
				new_block.get_node("EmeraldBlock").visible = true
				new_block.block_type = "ORE"
				new_block.ore_type = "EMERALD"
				
			if chunk[yy][xx] == "RUBY":
				new_block.get_node("StoneBlock").visible = false
				new_block.get_node("RubyBlock").visible = true
				new_block.block_type = "ORE"
				new_block.ore_type = "RUBY"
				
			if chunk[yy][xx] == "DIAMOND":
				new_block.get_node("StoneBlock").visible = false
				new_block.get_node("DiamondBlock").visible = true
				new_block.block_type = "ORE"
				new_block.ore_type = "DIAMOND"
			
			if chunk[yy][xx] == "MAGMA":
				new_block.get_node("StoneBlock").visible = false
				new_block.get_node("MagmaBlock").visible = true
				new_block.set_collision_layer_value(3, true)
				new_block.block_type = "MAGMA"
				new_block.get_node("CollisionShape2D").scale.x = 0.9
				new_block.get_node("CollisionShape2D").scale.y = 0.9
				new_block.get_node("MagmaBlock").scale.x = 0.9
				new_block.get_node("MagmaBlock").scale.y = 0.9
				
			if chunk[yy][xx] == "NITRO":
				new_block.get_node("StoneBlock").visible = false
				new_block.get_node("NitroBlock").visible = true
				new_block.block_type = "NITRO"
				
			if yy == 9:
				new_block.at_bottom = true
	
			bodies_chunk[yy].append(new_block)
			
			stone_blocks.add_child(new_block)
	
	##Progress the level
	chunk_count += 1
	if chunk_count == 3 && level < 12:
		level += 1
		chunk_count = 0
		level_label.text = "Level " + str(level)
		
func _on_apple_get(apple):
	power_up_sfx.play()
	_on_player_hurt(1)
	apple.queue_free()
	
func _on_gold_rush_get(gold_rush):
	power_up_sfx.play()
	gold_rush_active = true
	gold_rush_time.start()
	gold_rush.queue_free()

func _on_bounty_get(bounty):
	power_up_sfx.play()
	bounty_active = true
	bounty_time.start()
	bounty_icon.visible = true
	bounty.queue_free()
	
func _on_nitro_explode(block):
	explosion_sfx.play()
	block.nitro_activated = true
	var overlapping = block.nitro_radius.get_overlapping_bodies()
	var overlapping_areas = block.nitro_radius.get_overlapping_areas()
	const EXPLOSION = preload("res://FUZ/FuzMinigame3/nitro_explosion.tscn")
	var explosion =  EXPLOSION.instantiate()
	explosion.global_position = block.global_position
	explosion.get_node("CPUParticles2D").emitting = true
	add_child(explosion)
	for a in overlapping_areas:
		a.queue_free()
	for b in overlapping:
		if stone_blocks.get_children().has(b):
			if b.block_type == "ORE":
				_on_ore_gain(b)
			if b.block_type == "NITRO" && b != block && !b.nitro_activated:
				_on_nitro_explode(b)
			delete_block(b)
		if crawlers.get_children().has(b):
			b.queue_free()
			crawlers.remove_child(b)
			
func get_combo_multiplier():
	var combo_multiplier = 1
	var combo_split_amount = floor(combo/50.0) + 1
	var par_score = 100.0
	for a in combo_split_amount:
		var combo_slice = 50.0
		if a == combo_split_amount - 1:
			combo_slice = combo - a*50
		combo_multiplier += 0.5*(combo_slice/par_score)
		par_score += 75
	return combo_multiplier

func _on_ore_gain(block):
	ore_gain_sfx.play()
	var base_money = 0.0
	if block.ore_type == "TOPAZ":
		base_money = 10.0
	if block.ore_type == "SAPPHIRE":
		base_money = 25.0
	if block.ore_type == "EMERALD":
		base_money = 75.0
	if block.ore_type == "RUBY":
		base_money = 150.0
	if block.ore_type == "DIAMOND":
		base_money = 500.0
	if bounty_active:
		base_money += 20
		combo += 1
	combo += 1
	print("+$" + str(base_money*get_combo_multiplier() - base_money))	
	base_money = round(base_money*get_combo_multiplier())
	combo_label.text = str(combo)
	combo_bonus_label.text = "x" + str(get_combo_multiplier()).substr(0, 4)
	#base_money += round(base_money*(0.5*(float(combo)/25.0)))
	if gold_rush_active:
		base_money *= 3.0
	money += base_money
	money_label.text = str(money)
	
	const MONEYGAIN = preload("res://FUZ/FuzMinigame3/money_gain.tscn")
	var new_money_gain = MONEYGAIN.instantiate()
	new_money_gain.global_position.x = block.global_position.x
	new_money_gain.global_position.y = block.global_position.y - 32
	new_money_gain.get_node("MoneyGainLabel").text = "+" + str(base_money)
	moving_labels.add_child(new_money_gain)
	
	if money >= 10000 && !player.get_node("Crown").visible:
		player.get_node("Crown").visible = true
		goal_label.add_theme_color_override("font_color", Color(0, 1, 0))

func _on_player_crush_check() -> void:
	var bottom
	if player.down_cast_right.is_colliding():
		bottom = player.down_cast_right.get_collision_point().y
	if player.down_cast_left.is_colliding():
		bottom = player.down_cast_left.get_collision_point().y
	var top = player.up_cast.get_collision_point().y
	
	if (bottom - scroll_speed) - top <= 32:
		get_tree().reload_current_scene()
		#reset_game.emit()

func delete_block(body):
	body.queue_free()
	stone_blocks.remove_child(body)

func _on_player_shoot() -> void:
	#const BULLET = preload("res://FUZ/FuzMinigame3/mine_bullet.tscn")
	#var new_bullet = BULLET.instantiate()
	#new_bullet.global_position = player.global_position
	#new_bullet.look_at(get_global_mouse_position())
	#new_bullet.ore_gain.connect(_on_ore_gain)
	#new_bullet.delete_block.connect(delete_block)
	#new_bullet.nitro_explode.connect(_on_nitro_explode)
	#add_child(new_bullet)
	laser_sfx.play()
	player.beam.visible = true
	beam_timeout = 20
	if player.gun_ray_cast.is_colliding():
		var body = player.gun_ray_cast.get_collider()
		var both_distances = abs(player.gun_ray_cast.get_collision_point() - player.global_position)
		var dis = sqrt(pow(both_distances[0], 2) + pow(both_distances[1], 2))
		player.beam.remove_point(1)
		player.beam.add_point(Vector2(dis, 0))
		if body.block_type != "MAGMA":
			if body.block_type == "ORE":
				_on_ore_gain(body)
			if body.block_type == "NITRO":
				_on_nitro_explode(body)
			delete_block(body)
		player.target.position = Vector2(dis, 0)
	if !player.gun_ray_cast.is_colliding():
		player.beam.remove_point(1)
		player.beam.add_point(Vector2(player.gun_ray_cast.target_position[0], 0))
		player.target.position = Vector2(player.gun_ray_cast.target_position[0], 0)
	player.cpu_particles.emitting = true


func _on_game_area_area_exited(area: Area2D) -> void:
	area.queue_free()
	


func _on_game_area_body_exited(body: Node2D) -> void:
	if stone_blocks.get_children().has(body):
		stone_blocks.remove_child(body)
	body.queue_free()


func _on_player_hurt(amount) -> void:
	health += amount
	display_health()
	if amount < 0:
		hurt_sfx.play()
		combo = 0
		combo_label.text = "x" + str(combo)
		combo_bonus_label.text = "x" + str(get_combo_multiplier()).substr(0, 4)
	if health <= 0:
		get_tree().reload_current_scene()
		#reset_game.emit()


func _on_music_1_finished() -> void:
	music_2.play()


func _on_music_2_finished() -> void:
	music_1.play()


func _on_gold_rush_time_timeout() -> void:
	gold_rush_active = false


func _on_bounty_time_timeout() -> void:
	bounty_active = false
	bounty_icon.visible = false
