extends Node2D

@onready var Item: Sprite2D = $Sprite2D
@export var Item_Skin: Texture
var disapear_timer_active = false


func _process(delta: float) -> void:
	if Item_Skin != null:
		Item.texture = Item_Skin
	
	if self.name == "PlayerDeathItems":
		if Global.player_death_position == Vector2(0,0):
			visible = false
			queue_free()
		else:
			visible = true
			position = Global.player_death_position


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player":
		if Item_Skin.resource_path == "res://assets/double jump.png":
			Global.can_double_jump = true
		elif Item_Skin.resource_path == "res://assets/charged dash.png":
			Global.can_charge_dash = true
		elif Item_Skin.resource_path == "res://assets/wall jump.png":
			Global.can_wall_jump = true
		elif Item_Skin.resource_path == "res://assets/second wind.png":
			Global.can_second_wind = true
		elif Item_Skin.resource_path == "res://assets/coin.png" and visible:
			Global.coins = Global.dead_coins
			Global.dead_coins = 0
			Global.player_death_position = Vector2(0, 0)
		queue_free()


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	if self.name == "PlayerDeathItems":
		# Adds a timer if the player dies and does not use second wind
		if not disapear_timer_active and not Global.shadow_man_appears:
			disapear_timer_active = true
			await get_tree().create_timer(10.0).timeout
			Global.dead_coins = 0
			Global.player_death_position = Vector2(0, 0)
			queue_free()
