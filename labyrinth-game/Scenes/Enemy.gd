extends Node2D

const BattleUnits = preload("res://BattleUnits.tres")

var hp = 25 setget set_hp
var target = null

onready var hpLabel = $HPLabel
onready var animationPlayer = $AnimationPlayer

# Custom signal
signal died
signal end_turn

func set_hp(new_hp):
	hp = new_hp
	hpLabel.text = str(hp) + "hp"

func _ready():
	BattleUnits.Enemy = self

func _exit_tree():
	BattleUnits.Enemy = null

func attack() -> void:
	yield(get_tree().create_timer(0.4), "timeout")
	animationPlayer.play("Attack")
	yield(animationPlayer, "animation_finished")
	emit_signal("end_turn")

func deal_damage():
	BattleUnits.PlayerStats.hp -= 4

func take_damage(amount):
	self.hp -= amount
	if is_dead():
		emit_signal("died")
		queue_free()
	else:
		animationPlayer.play("Shake")

func is_dead():
	return hp <= 0
