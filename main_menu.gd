extends Control

@onready var main_scene = ResourceLoader.load("res://world.tscn")
@onready var main_menu = ResourceLoader.load("res://main_menu.tscn")
var status = "dead"


# --------------------------------- Main Menu ---------------------------------
func _on_play_pressed() -> void:
	get_tree().change_scene_to_packed(main_scene)
# -----------------------------------------------------------------------------


# -------------------------------- Second Wind --------------------------------
func _on_yes_second_wind_pressed() -> void:
	status = "alive"


func _on_no_second_wind_pressed() -> void:
	get_tree().change_scene_to_packed(main_menu)
# -----------------------------------------------------------------------------
