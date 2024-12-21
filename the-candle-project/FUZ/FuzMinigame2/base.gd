extends Node2D



func _on_game_reset_game(old_game) -> void:
	var games = get_children().filter(func(c): return c)
	for g in games:
		remove_child(g)
		g.queue_free()
	if get_children().size() == 0:
		const GAME = preload("res://FUZ/FuzMinigame2/game.tscn")
		var game = GAME.instantiate()
		game.reset_game.connect(_on_game_reset_game)
		call_deferred("add_child", game)
