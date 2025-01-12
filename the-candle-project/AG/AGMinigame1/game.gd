extends Node2D

#TO ADD:
#Waves System: Add Bat, increase boulder time, nothing
#Inbetween Rounds select button: +Luck up to 8 times, +Max Health up to 8, +50 Coins

#boulder wait time = 0.9s

@onready var boulder = preload("res://AG/AGMinigame1/boulder.tscn")
@onready var coin = preload("res://AG/AGMinigame1/coin.tscn")
@onready var left_boulder_boundary: Marker2D = $Background/LeftBoulderBoundary
@onready var right_boulder_boundary: Marker2D = $Background/RightBoulderBoundary
@onready var boulder_timer: Timer = $BoulderTimer
@onready var cash_timer: Timer = $CashTimer
@onready var coin_ui: RichTextLabel = $CoinUI
@onready var h_flow_container: HFlowContainer = $BoxContainer/HFlowContainer
@onready var coin_se: AudioStreamPlayer = $coinSE
@onready var coin_streak: Timer = $coinStreak
@onready var hit_se: AudioStreamPlayer = $hitSE
@onready var coinbag_se: AudioStreamPlayer = $coinbagSE
@onready var coin_high: RichTextLabel = $CoinHigh
@onready var health_timer: Timer = $HealthTimer
@onready var health_se: AudioStreamPlayer = $healthSE
const HEART_1 = preload("res://AG/AGMinigame1/Heart1.png")
const HEART_2 = preload("res://AG/AGMinigame1/Heart2.png")
@onready var wave_buffer: Timer = $WaveBuffer
@onready var wave_ui: RichTextLabel = $WaveUI
const CAUTION = preload("res://AG/AGMinigame1/caution.tscn")
@onready var music: AudioStreamPlaybackInteractive = $Music.get_stream_playback()
@onready var choose_your_upgrade: RichTextLabel = $ChooseYourUpgrade
@onready var wave_timer: Timer = $WaveTimer
@onready var diff_timer: Timer = $DiffMessage
@onready var diff_message: RichTextLabel = $WaveUI2
const HEARTUI = preload("res://AG/AGMinigame1/heartui.tscn")
@onready var wind_timer: Timer = $windTimer
const WIND = preload("res://AG/AGMinigame1/wind.tscn")

signal coin_collect(amount:int)
signal health_change(amount:int)
signal upgrade(type:String, amount:int)
signal wave_buffer_signal()
signal wave_start()
signal bat_spawn()
var coins: int = 0
var health: int = 3
var pitchscale: float = 1
var luck: float = 0.7
var maxHealth:int = 3
var wave: int = 1
@export var waveInProgress:bool = true

var luckCost: int = 100
var healthCost: int = 250
var luckUpgraded: int = 0
var cashWait: float = 0.6
var bat_count: int = 0
var heartWait: float = 45.0

func _ready() -> void:
	coin_collect.connect(_on_coin_collect)
	health_change.connect(_on_health_change)
	wave_buffer_signal.connect(the_wave_buffer)
	upgrade.connect(_on_upgrade)
	wave_start.connect(_on_wave_start)
	bat_spawn.connect(spawn_bat)
	spawn_bat()
	choose_your_upgrade.visible=false
	diff_message.visible=false
	#_on_coin_collect(500) for playtesting

func _process(delta: float) -> void:
	pass

func _on_boulder_timer_timeout() -> void:
	var scene = boulder.instantiate()
	var leftBoundary:int = left_boulder_boundary.global_position.x
	var rightBoundary:int = right_boulder_boundary.global_position.x
	scene.global_position=Vector2(randi_range(leftBoundary,rightBoundary),left_boulder_boundary.global_position.y)
	self.add_child(scene)

func _on_cash_timer_timeout() -> void:
	var scene = coin.instantiate()
	var leftBoundary:int = left_boulder_boundary.global_position.x
	var rightBoundary:int = right_boulder_boundary.global_position.x
	scene.global_position=Vector2(randi_range(leftBoundary,rightBoundary),left_boulder_boundary.global_position.y)
	scene.luck=luck
	self.add_child(scene)
	cash_timer.wait_time=cashWait*randf_range(0.5,2)

func _on_coin_collect(amount:int) -> void:
	coins+=amount
	
	#coin streak pitch climb
	if coin_streak.is_stopped()==false:
		if pitchscale<=2:
			pitchscale+=0.05
			coin_high.visible=false
		else:
			coin_high.visible=true
			coins+=amount
	else:
		coin_high.visible=false
		coin_se.pitch_scale=1
		pitchscale=1
	
	coin_ui.text="COINS: "+str(coins)
	coin_streak.start()
	
	match amount:
		1:
			coin_se.volume_db=-8
			coin_se.pitch_scale=pitchscale
			coin_se.play()
		10:
			coinbag_se.volume_db=-8
			coinbag_se.pitch_scale=pitchscale/3+0.3
			coinbag_se.play()

func _on_health_change(amount:int) -> void:
	if(health+amount<=maxHealth):
		health+=amount
	else: 
		health_se.volume_db=-5
		health_se.play()
		return
	if amount>0:
		health_se.volume_db=-5
		health_se.play()
		h_flow_container.get_child(health-1).texture=HEART_1
	if health==0: get_tree().reload_current_scene()
	if amount<0:
		h_flow_container.get_child(health).texture=HEART_2
		coin_high.visible=false
		hit_se.volume_db=-5
		hit_se.play() 
		pitchscale=1
		coin_streak.start()

func _on_health_timer_timeout() -> void:
	var scene = coin.instantiate()
	var leftBoundary:int = left_boulder_boundary.global_position.x
	var rightBoundary:int = right_boulder_boundary.global_position.x
	scene.global_position=Vector2(randi_range(leftBoundary,rightBoundary),left_boulder_boundary.global_position.y)
	scene.type="heart"
	self.add_child(scene)
	health_timer.wait_time=heartWait+randi_range(0,heartWait/2)

func _on_coin_streak_timeout() -> void:
	coin_high.visible=false
	coin_se.pitch_scale=1
	pitchscale=1

func _on_wave_timer_timeout() -> void:
	boulder_timer.paused=true
	cash_timer.paused=true
	health_timer.paused=true
	wave_ui.text="[outline_size=8][outline_color=white][color=#1b81dc][center]WAVE "+str(wave)+" ENDED[/center][/color][/outline_color][/outline_size]"
	coin_streak.paused=true
	waveInProgress=false
	music.switch_to_clip_by_name(&"Upgrade")
	wave_buffer.start()

func _on_wave_buffer_timeout() -> void:
	wave_buffer_signal.emit()
 
func the_wave_buffer() -> void:
	choose_your_upgrade.visible=true

func spawn_bat() -> void:
	bat_count+=1
	var scene = CAUTION.instantiate()
	var leftBoundary:int = left_boulder_boundary.global_position.x
	var rightBoundary:int = right_boulder_boundary.global_position.x
	scene.global_position=Vector2(randi_range(leftBoundary,rightBoundary),randi_range(96,608))
	scene.type="bat"
	self.add_child(scene)

func _on_upgrade(type:String, amount:int):
	match type:
		"Coins":
			if pitchscale>2: _on_coin_collect(amount/2)
			else: _on_coin_collect(amount)
		"Luck":
			luckUpgraded+=1
			luck+=0.2
			cashWait*=0.94
			heartWait-=3.8
			health_timer.wait_time=heartWait
		"Health":
			var healthDiff: int = maxHealth - health
			maxHealth+=1
			health=maxHealth-healthDiff
			var instance = HEARTUI.instantiate()
			h_flow_container.add_child(instance)
			for i in h_flow_container.get_child_count():
				h_flow_container.get_child(i).texture=HEART_1
			if healthDiff>0:
					for i in healthDiff:
						h_flow_container.get_child(h_flow_container.get_child_count()-i-1).texture=HEART_2
		"HealthRefill":
			health=maxHealth
			for i in h_flow_container.get_child_count():
				h_flow_container.get_child(i).texture=HEART_1
	wave_start.emit()

func _on_wave_start() -> void:
	wave_buffer.stop()
	wave_timer.start()
	boulder_timer.paused=false
	cash_timer.paused=false
	health_timer.paused=false
	wave+=1
	wave_ui.text="[outline_size=8][outline_color=white][color=#1b81dc][center]WAVE "+str(wave)+"[/center][/color][/outline_color][/outline_size]"
	coin_streak.start()
	
	#add difficulty increase
	var difficulties = ["boulder", "bat", "time"]
	if boulder_timer.wait_time<=0.3: difficulties.erase("boulder")
	if bat_count>=10: difficulties.erase("bat")
	if wave_timer.wait_time>=55: difficulties.erase("time")
	var selection:String = "null"
	if difficulties.is_empty()==false:
		var random = randi_range(0,difficulties.size()-1)
		selection = difficulties[random]
	match selection:
		"boulder":
			diff_message.text="[outline_size=8][font_size=32][outline_color=white][color=red][center]+BOULDERS[/center][/color][/outline_color][/font_size]"
			boulder_timer.wait_time-=0.1
		"bat":
			diff_message.text="[outline_size=8][font_size=32][outline_color=white][color=red][center]+BAT[/center][/color][/outline_color][/font_size]"
			spawn_bat()
		"time":
			diff_message.text="[outline_size=8][font_size=32][outline_color=white][color=red][center]+WAVE TIME[/center][/color][/outline_color][/font_size]"
			wave_timer.wait_time+=10
		"null":
			diff_message.text="[outline_size=8][font_size=32][outline_color=white][color=red][center]NO CHANGE[/center][/color][/outline_color][/font_size]"
		_:
			diff_message.text="error"
	
	diff_message.visible=true
	diff_timer.start()
	
	choose_your_upgrade.visible=false
	waveInProgress=true
	music.switch_to_clip_by_name(&"Wave")

func _on_diff_message_timeout() -> void:
	diff_message.visible=false

func _on_wind_timer_timeout() -> void:
	var the = randi_range(0,3)
	for i in the:
		var scene = WIND.instantiate()
		self.add_child(scene)
