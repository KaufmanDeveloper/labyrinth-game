extends Node

const BattleUnits = preload("res://BattleUnits.tres")

export(Array, PackedScene) var enemies = []
export(PackedScene) var Bash = PackedScene.new()
export(PackedScene) var Heal = PackedScene.new()

onready var battleActionButtons = $UI/BattleActionButtons
onready var bashActionButton = $UI/BattleActionButtons/BashActionButton
onready var healActionButton = $UI/BattleActionButtons/HealActionButton
onready var animationPlayer = $AnimationPlayer
onready var nextRoomButton = $UI/CenterContainer/NextRoomButton
onready var enemyPosition = $EnemyPosition
onready var miniGamePosition = $MiniGamePosition
onready var battleTextPanel = $UI/BattleTextPanel
onready var battleTextbox = $UI/BattleTextPanel/BattleTextbox

var enemyIsAttacking = false

func _ready():
	bashActionButton.Bash = Bash
	healActionButton.Heal = Heal
	randomize()
	start_player_turn()
	var enemy = BattleUnits.Enemy
	if enemy != null:
		enemy.connect("died", self, "_on_Enemy_died") # Dynamic signal connect

func start_player_turn():
	enemyIsAttacking = false
	battleActionButtons.show()
	var playerStats = BattleUnits.PlayerStats
	playerStats.ap = playerStats.max_ap
	
	yield(playerStats, "end_turn") # wait for the end turn signal to continue
	start_enemy_turn()

func start_enemy_turn():
	enemyIsAttacking = true
	battleActionButtons.hide()
	var enemy = BattleUnits.Enemy
	if enemy != null and not enemy.is_queued_for_deletion():
		enemy.attack()
		yield(enemy, "end_turn")
	start_player_turn()

func create_new_enemy():
	enemies.shuffle()
	var Enemy = enemies.front() # Scene itself, capitalize
	var enemy = Enemy.instance() # Instance of scene, lowercase
	enemyPosition.add_child(enemy)
	enemy.connect("died", self, "_on_Enemy_died")

func _on_Enemy_died():
	nextRoomButton.show()
	battleActionButtons.hide()

func _on_NextRoomButton_pressed():
	nextRoomButton.hide()
	animationPlayer.play("FadeToNewRoom")
	yield(animationPlayer, "animation_finished")
	
	var playerStats = BattleUnits.PlayerStats
	playerStats.ap = playerStats.max_ap
	battleActionButtons.show()
	create_new_enemy()

func _on_BashActionButton_pressed():
	battleActionButtons.hide()
	
	yield(bashActionButton, "finished")
	
	if (!enemyIsAttacking):
		battleActionButtons.show()

func _on_HealActionButton_pressed():
	var playerStats = BattleUnits.PlayerStats
	battleActionButtons.hide()
	
	if (playerStats.mp < 8):
		battleTextbox.bbcode_text = "[center]You need 8 MP to cast heal.[/center]"
		battleTextPanel.visible = true
		yield(get_tree().create_timer(2.0), "timeout")
		battleTextPanel.visible = false
	else:
		yield(healActionButton, "finished")
	
	if (!enemyIsAttacking):
		battleActionButtons.show()
