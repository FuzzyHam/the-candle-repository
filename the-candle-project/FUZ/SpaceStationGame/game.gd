extends Node2D

@onready var tile_map: TileMap = $TileMap
@onready var health_marker: Marker2D = $Health
@onready var game_area: Area2D = $GameArea
@onready var asteriod_spawn: Timer = $AsteriodSpawn
@onready var spike_life: Timer = $SpikeLife
@onready var spikes: Node = $Spikes
@onready var event_warning: Marker2D = $EventWarning
@onready var event_timer: Timer = $EventTimer
@onready var lasers: Node = $Lasers
@onready var laser_life: Timer = $LaserLife
@onready var progress_label: Label = $ProgressLabel
@onready var win_label: Label = $WinLabel
@onready var bug_timer: Timer = $BugTimer
@onready var vents: Node = $Vents
@onready var hurt_sfx: AudioStreamPlayer2D = $HurtSFX
@onready var overheat_sfx: AudioStreamPlayer2D = $OverheatSFX
@onready var cooldown_sfx: AudioStreamPlayer2D = $CooldownSFX
@onready var life_sfx: AudioStreamPlayer2D = $LifeSFX
@onready var laser_sfx: AudioStreamPlayer2D = $LaserSFX
@onready var spike_sfx: AudioStreamPlayer2D = $SpikeSFX
@onready var load_player: Node2D = $LoadPlayer


var generators
var health = 6
var previous_heated_generators = []
var asteriod_direction = Vector2.UP

var directions = [Vector2.UP, Vector2.DOWN, Vector2.RIGHT, Vector2.LEFT]
var events = ["Asteriods", "Spikes", "Lasers", "Bugs"]
var upcoming_events = []
var difficulty = 1
var progress = 0
var progress_life_spawn = 10

func _ready():
	shuffle_spike_tiles()
	generators = [get_node("Generator"), get_node("Generator2"), get_node("Generator3"), get_node("Generator4")]
	health_marker.display_hearts(health)
	_on_event_timer_timeout()
	for g in generators:
		g.overheat.connect(_on_generator_overheat)
		g.cool_generator.connect(_on_generator_cool_down)
	for l in lasers.get_children():
		l.laser_hit.connect(_on_laser_hit)
	lasers.get_children()[0].laser_fire.connect(_on_laser_fire)
	progress_life_spawn = round(randf() * 5) + 8
	
	load_player._on_load_character() 
	
func _process(delta: float) -> void:
	event_warning.get_node("Label").text = str(event_warning.get_node("Alert").speed_scale)
	event_warning.get_node("Alert").speed_scale = (((event_timer.wait_time - event_timer.time_left) / event_timer.wait_time) * 1.5) ** 4 + 1
	pass

func spawn_life():
	const LIFE = preload("res://FUZ/SpaceStationGame/extra_life.tscn")
	var new_life = LIFE.instantiate()
	new_life.global_position = Vector2(0, 356)
	add_child(new_life)
	new_life.add_life.connect(_on_add_life)

func shuffle_spike_tiles():
	var cells = tile_map.get_used_cells(0)
	var ground_cells = []
	for c in cells:
		var data = tile_map.get_cell_tile_data(0, c)
		if data:
			if data.get_custom_data("spike_tile") == true:
				tile_map.set_cell(0, c, 0, Vector2i(0, 0))
				data = tile_map.get_cell_tile_data(0, c)
			if data.get_custom_data("ground_tile") == true:
				ground_cells.append(c)
	var viable = ground_cells.map(func(cell): return cell)
	for a in round(((ground_cells.size() - 1) / 2) - 1):
		var r = round(randf() * (viable.size() - 1))
		tile_map.set_cell(0, viable[r], 0, Vector2i(2, 0))
		viable.pop_at(r)

func change_health(amount):
	health += amount
	health_marker.display_hearts(health)
	if health <= 0:
		get_tree().reload_current_scene()
		
func spawn_asteriod():
	const ASTERIOD = preload("res://FUZ/SpaceStationGame/asteriod.tscn")
	var new_asteriod = ASTERIOD.instantiate()
	var rect = get_node("GameArea/CollisionShape2D").shape.get_rect()
	var r_scale = round(randf() * 2)
	new_asteriod.apply_scale(Vector2(r_scale + 1, r_scale + 1))
	var r_xpos = round(randf() * rect.size.x)
	var r_ypos = round(randf() * rect.size.y)
	if asteriod_direction == Vector2.DOWN:
		new_asteriod.global_position = Vector2(rect.position.x + r_xpos, rect.position.y)
	if asteriod_direction == Vector2.UP:
		new_asteriod.global_position = Vector2(rect.position.x + r_xpos, rect.end.y)
	if asteriod_direction == Vector2.RIGHT:
		new_asteriod.global_position = Vector2(rect.position.x, rect.position.y + r_ypos)
	if asteriod_direction == Vector2.LEFT:
		new_asteriod.global_position = Vector2(rect.end.x, rect.position.y + r_ypos)
	new_asteriod.direction = asteriod_direction
	new_asteriod.speed = 200
	new_asteriod.asteriod_hit.connect(_on_asteriod_hit)
	add_child(new_asteriod)

func check_heating_up(generator):
	return generator.heating_up
	
func spawn_spikes():
	var cells = tile_map.get_used_cells(0)
	const SPIKE = preload("res://FUZ/SpaceStationGame/spike.tscn")
	_on_spike_life_timeout()
	for c in cells:
		var data = tile_map.get_cell_tile_data(0, c)
		if data:
			if data.get_custom_data("spike_tile") == true:
				var new_spike = SPIKE.instantiate()
				new_spike.position = tile_map.map_to_local(c)
				new_spike.position.y -= 64
				spikes.add_child(new_spike)
	spike_life.start()
	spike_sfx.play()
	shuffle_spike_tiles()

func display_events():
	var event_boxes = event_warning.get_node("Warnings").get_children()
	const OFFSET = 150
	var times = 1
	for e in event_boxes:
		e.visible = false
		if upcoming_events.has(e.name):
			e.visible = true
			e.global_position.y = event_warning.position.y
			e.global_position.x = event_warning.position.x - OFFSET * times
			times += 1

func _on_laser_hit():
	change_health(-1)
	hurt_sfx.play()
	
func _on_laser_fire():
	laser_sfx.play()
	
func _on_add_life(amount):
	change_health(amount)
	life_sfx.play()

func _on_timer_timeout() -> void:
	var r = round(randf() * (generators.size() - 1))
	if previous_heated_generators.size() == round(generators.size() * 0.75):
		previous_heated_generators.pop_front()
	var viable = generators.filter(func(g): return !g.heating_up && !previous_heated_generators.has(generators.find(g)))
	if viable.size() == 0:
		return
	r = round(randf() * (viable.size() - 1))
	previous_heated_generators.append(generators.find(viable[r]))
	viable[r].heat_up()

func _on_generator_overheat() -> void:
	change_health(-2)
	overheat_sfx.play()
	
func _on_generator_cool_down():
	cooldown_sfx.play()

func _on_game_area_area_exited(area: Area2D) -> void:
	area.queue_free()

func _on_asteriod_spawn_timeout() -> void:
	spawn_asteriod()

func choose_valid_event(event):
	return true

func _on_event_timer_timeout() -> void:
	asteriod_spawn.stop()
	bug_timer.stop()
	progress += 1
	
	progress_label.text = str(progress) + " / 15"
	
	if progress == progress_life_spawn:
		spawn_life()
	
	if progress == 5:
		difficulty = 2
		
	if progress == 10:
		difficulty = 3
		
	if progress == 16:
		print("YOU WIN!!")
		win_label.visible = true
	
	if upcoming_events.has("Asteriods"):
		var r = round(randf() * 3)
		asteriod_direction = directions[r]
		asteriod_spawn.start()
	if upcoming_events.has("Spikes"):
		spawn_spikes()
	if upcoming_events.has("Lasers"):
		for l in lasers.get_children():
			if l.get_node("Reload").is_stopped():
				l.get_node("Reload").start()
		laser_life.start()
	if upcoming_events.has("Bugs"):
		bug_timer.start()
	upcoming_events.clear()
	var valid_events = events.filter(choose_valid_event)
	for d in difficulty:
		if valid_events.size() == 0 || valid_events.all(func(event): return upcoming_events.has(event)):
			break
		var r = round(randf() * (valid_events.size() - 1))
		upcoming_events.append(valid_events[r])
		var event_to_remove = valid_events[r]
		valid_events = valid_events.filter(func(event): return event != event_to_remove)
	display_events()

func _on_spike_life_timeout() -> void:
	var spikes_to_remove = spikes.get_children()
	for s in spikes_to_remove:
		s.queue_free()
		
func _on_asteriod_hit():
	change_health(-1)
	hurt_sfx.play()


func _on_player_hurt(by) -> void:
	if spikes.get_children().has(by):
		change_health(-1)
		hurt_sfx.play()
		
		
	if by.is_in_group("Bugs"):
		change_health(-1)
		hurt_sfx.play()


func _on_laser_life_timeout() -> void:
	for l in lasers.get_children():
		l.get_node("Reload").stop()


func _on_bug_timer_timeout() -> void:
	const BUG = preload("res://FUZ/SpaceStationGame/bug.tscn")
	var bug = BUG.instantiate()
	var r = round(round(randf() * (vents.get_children().size() - 1)))
	bug.global_position = vents.get_children()[r].global_position
	if vents.get_children()[r].is_in_group("LeftVent"):
		bug.direction = -1
	if vents.get_children()[r].is_in_group("RightVent"):
		bug.direction = 1
	add_child(bug)
