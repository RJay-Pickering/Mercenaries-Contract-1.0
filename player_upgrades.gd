extends Node2D

@onready var Item: Sprite2D = $Sprite2D
@export var Item_Skin: Texture


func _process(delta: float) -> void:
	if Item_Skin != null:
		Item.texture = Item_Skin


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player":
		if Item_Skin.resource_path == "res://assets/double jump.png":
			Global.can_double_jump = true
		if Item_Skin.resource_path == "res://assets/charged dash.png":
			Global.can_charge_dash = true
		queue_free()
