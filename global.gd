extends Node

# Can only double jump if the user picks up the item. The item is changing this value.
var can_double_jump = false
# Can only charge dash if the user picks up the item. The item is changing this value.
var can_charge_dash = false
# Can only wall jump if the user picks up the item. The item is changing this value.
var can_wall_jump = false
# Can only use second wind if the user picks up the item. The item is changing this value.
var can_second_wind = false
# Collects coins when killing enemies or obtaining lost gold. The player and enemy is changing this value.
var coins = 0
# Gets the users location that was killed at to place the lost gold. This file and player is changing this value.
var player_death_position: Vector2
# Stores the coins before death to a item for the player to pick up soon. This file is changing this value.
var dead_coins = 0
# Shows if the shadow man will apear or not based on if they fail on their second wind. This file is changing this value.
var shadow_man_appears = false

func death_punishment(position, failed_second_wind):
	# shadow man appears and there is no timer
	if failed_second_wind:
		shadow_man_appears = true
	# shadow man does not appear and there is a timer
	else:
		shadow_man_appears = false
	dead_coins = coins
	coins = 0
	player_death_position = position
	
	#if coins > 0:
		#player_death_position = position
		#dead_coins = coins 
		#coins = 0
	#elif not can_second_wind:
		#player_death_position = Vector2(0,0)
		#dead_coins = 0
	#elif coins <= 0 and can_second_wind:
		#player_death_position = position
		#dead_coins = 0 
		#coins = 0
