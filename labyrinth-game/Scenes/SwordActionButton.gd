extends "res://ActionButton.gd"

const Slash = preload("res://Scenes/Slash.tscn")

func _on_pressed():
	var enemy = BattleUnits.Enemy
	var playerStats = BattleUnits.PlayerStats
	
	if enemy != null and playerStats != null:
		create_slash(enemy.global_position)
		enemy.take_damage(4)
		playerStats.mp += 2
		playerStats.ap -= 1

func create_slash(position):
	var slash = Slash.instance() # Create a new instance of the Slash scene
	var main = get_tree().current_scene # Child of the "Main" scene, not enemy
	main.add_child(slash) # Add the instance to the scene
	slash.global_position = position
