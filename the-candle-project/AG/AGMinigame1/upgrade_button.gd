extends StaticBody2D


@export var type: String
#TEXT FIRST PASS:
#Luck: "+Luck: More gold bags and hearts spawn. Costs 100 gold"
#HP: "+Max HP. Costs 250 gold"
#Gold: "+100 Gold"

const PROJECT_15V_2 = preload("res://AG/AGMinigame1/Project_15V2.mp3")
const PROJECT_20V_3 = preload("res://AG/AGMinigame1/Project_20V3.mp3")

@onready var rich_text: RichTextLabel = $RichTextLabel
const UPGRADE_1 = preload("res://AG/AGMinigame1/Upgrade1.png")
const UPGRADE_2 = preload("res://AG/AGMinigame1/Upgrade2.png")
const UPGRADE_3 = preload("res://AG/AGMinigame1/Upgrade3.png")
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var press_action: RichTextLabel = $PressAction
@onready var area_2d: Area2D = $Area2D
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var text_change: Timer = $text_change

var random:int
var coinReward: int
var player_in: bool = false

func _ready() -> void:
	self.visible=false
	get_parent().wave_start.connect(_on_wave_start)
	press_action.visible=false
	get_parent().wave_buffer_signal.connect(wave_buffer_signal)
	collision_shape_2d.set_disabled(true)
	


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("shoot")==true&&player_in==true:
		buy()


func buy() -> void:
	if self.visible==true:
		if type=="Luck":
			if get_parent().coins>=get_parent().luckCost&&get_parent().luckUpgraded<8:
				get_parent().upgrade.emit("Luck",1)
				if get_parent().pitchscale>2: get_parent()._on_coin_collect((-1*get_parent().luckCost)/2)
				else: get_parent()._on_coin_collect((-1*get_parent().luckCost))
				get_parent().luckCost*=1.5
			else:
				if !get_parent().coins>=get_parent().luckCost:
					press_action.text="[center]NOT ENOUGH COINS[/center]"
					text_change.start()
				return
		elif type=="Health":
			#account for if max hp is 8, account for if player doesn't have money.
			if get_parent().coins>=get_parent().healthCost :
				if get_parent().maxHealth<9:
					get_parent().upgrade.emit("Health",1)
					if get_parent().pitchscale>2: get_parent()._on_coin_collect((-1*get_parent().healthCost)/2)
					else: get_parent()._on_coin_collect((-1*get_parent().healthCost))
					get_parent().healthCost*=1.5
				else:
					get_parent().upgrade.emit("HealthRefill",1)
					if get_parent().pitchscale>2: get_parent()._on_coin_collect((-1*get_parent().healthCost)/2)
					else: get_parent()._on_coin_collect((-1*get_parent().healthCost))
					get_parent().healthCost*=1.5
			else:
				if !get_parent().coins>=get_parent().healthCost:
					press_action.text="[center]NOT ENOUGH COINS[/center]"
					text_change.start()
				return
		elif type=="Coins":
			get_parent().upgrade.emit("Coins",coinReward)
		self.visible=false
		collision_shape_2d.set_disabled(true)
		set_visuals()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player && self.visible==true:
		press_action.visible=true
		player_in=true
 
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		press_action.visible=false
		player_in=false

func wave_buffer_signal() -> void:
	collision_shape_2d.set_disabled(false)
	random = randi_range(0,100)*(get_parent().luck*0.7)
	set_visuals()
	self.visible=true

func set_visuals():
	match type:
		"Luck":
			sprite_2d.texture=UPGRADE_1
			if get_parent().luckUpgraded<8:
				rich_text.text="[font_size=16][center]+LUCK:\n[font_size=8]Various changes such as more coins, bags, and hearts. Costs " + str(get_parent().luckCost) + " gold."
			else:
				rich_text.text="[font_size=12][center]NO MORE AVAILABLE UPGRADES FOR LUCK"
			press_action.text="[center]Press action button to buy[/center]"
		"Health":
			sprite_2d.texture=UPGRADE_2
			if get_parent().maxHealth<9:
				rich_text.text="[font_size=16][center]+MaxHP:\n[font_size=8]Costs " + str(get_parent().healthCost) + " gold."
			else:
				rich_text.text="[font_size=16][center]Refill HP:\n[font_size=8]Costs " + str(get_parent().healthCost) + " gold."
			press_action.text="[center]Press action button to buy[/center]"
		"Coins":
			sprite_2d.texture=UPGRADE_3
			if random<=0:
				coinReward=10
			elif random<=15:
				coinReward=15
			elif random<=65:
				coinReward=30
			elif random<=85:
				coinReward=50
			elif random<=95:
				coinReward=75
			elif random<=99:
				coinReward=90
			elif random<=105:
				coinReward=150
			else:
				coinReward=200
			rich_text.text="[font_size=16][center]+" + str(coinReward) + " coins."
			press_action.text = "[center]Press action button to receive[/center]"

func _on_text_change_timeout() -> void:
	set_visuals()

func _on_wave_start() -> void:
	self.visible=false
	press_action.visible=false
	collision_shape_2d.set_disabled(true)
