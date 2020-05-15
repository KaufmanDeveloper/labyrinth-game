extends "res://ActionButton.gd"

signal finished()

var Heal = PackedScene.new()

var healSuccesses = 0

func _on_pressed():
	var playerStats = BattleUnits.PlayerStats
	if playerStats != null:
		if playerStats.mp >= 8:
			handle_heal_mini_game()
			
			playerStats.hp += 5
			playerStats.mp -= 8
			playerStats.ap -= 1

func handle_heal_mini_game():
	var main = get_tree().current_scene # Child of the "Main" scene, not enemy
	var miniGamePosition = main.miniGamePosition
	
	var heal = Heal.instance()
	miniGamePosition.add_child(heal)
	yield(heal, "finished")
	healSuccesses = heal.successes
	heal.queue_free()
	emit_signal("finished")
