extends "res://ActionButton.gd"

signal finished(succeeded)

const Slash = preload("res://Battle/Battle/Slash.tscn")

var Bash = PackedScene.new()
var success = false
var bashSucceeded = false

func _on_pressed():
	var enemy = BattleUnits.Enemy
	var playerStats = BattleUnits.PlayerStats
	
	if enemy != null and playerStats != null:
		handle_attack(enemy, playerStats)

func handle_attack(enemy, playerStats):
	var position = enemy.global_position
	var slash = Slash.instance() # Create a new instance of the Slash scene
	var battleNode = get_tree().current_scene # Child of the "Main" scene, not enemy
	if !"type" in battleNode or battleNode.type != "Battle":
		for nodeChild in get_tree().current_scene.get_children():
			if "type" in nodeChild and nodeChild.type == "Battle":
				battleNode = nodeChild # Find the battle node in the tree
	
	var miniGamePosition = battleNode.miniGamePosition
	
	var bash = Bash.instance()
	miniGamePosition.add_child(bash)
	yield(bash, "finished")
	bashSucceeded = bash.success
	bash.queue_free()
	
	if bashSucceeded:
		battleNode.add_child(slash) # Add the instance to the scene
		slash.global_position = position
		enemy.take_damage(4)
		playerStats.mp += 2
	
	playerStats.ap -= 1
	
	emit_signal("finished", success)

