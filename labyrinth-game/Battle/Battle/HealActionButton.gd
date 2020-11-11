extends "res://ActionButton.gd"

signal finished()

var Heal = PackedScene.new()

var healSuccesses = 0

func _on_pressed():
	var playerStats = BattleUnits.PlayerStats
	if playerStats != null:
		if playerStats.mp >= 8:
			handle_heal_mini_game(playerStats)

func handle_heal_mini_game(playerStats):
	var battleNode = get_tree().current_scene # Child of the "Main" scene, not enemy
	if !"type" in battleNode or battleNode.type != "Battle":
		for nodeChild in get_tree().current_scene.get_children():
			if "type" in nodeChild and nodeChild.type == "Battle":
				battleNode = nodeChild # Find the battle node in the tree
	
	var miniGamePosition = battleNode.miniGamePosition
	
	var heal = Heal.instance()
	miniGamePosition.add_child(heal)
	yield(heal, "finished")
	healSuccesses = heal.successes
	heal.queue_free()
	
	playerStats.hp = playerStats.hp +  (2 * healSuccesses)
	playerStats.mp -= 8
	playerStats.ap -= 1
	healSuccesses = 0
	
	emit_signal("finished")
