extends Node2D



func _on_game_reset_game(old_game) -> void:
	old_game.queue_free()
	const GAME = preload("res://FUZ/FuzMinigame2/game.tscn")
	var game = GAME.instantiate()
	game.reset_game.connect(_on_game_reset_game)
	call_deferred("add_child", game)
