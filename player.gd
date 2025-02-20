extends CharacterBody2D

@onready var status = $Label
@onready var second_wind_menu = $CanvasLayer/SecondWindMenu
@onready var coins_display = $CanvasLayer/ProgressBar/coins
const SPEED = 450.0
const DASH_SPEED = 900.0
const JUMP_VELOCITY = -500.0
var facing_position = "right"
var attacking_position = "right"
var is_attacking = false
var dashing = false
var can_dash = true
var charge_dash = false
var hold_dash_count = 0
var combo = 0
var damage_output = 0
var health = 100
var is_damaged = false
var is_stunned = false
var loop_once = false
var jump_count = 0
var has_jumped = false
var jump_released = false
var is_wall_sliding = false
var current_wall = ""
var off_ground = false
var wall_fall = 0
var is_revived = false


func _ready() -> void:
	$AnimatedSprite2D.play("default")


func _physics_process(delta: float) -> void:
	$CanvasLayer/ProgressBar.value = health
	coins_display.text = "Coins: " + str(Global.coins)
	if is_revived:
		if get_tree().get_node_count_in_group("enemy") > 0:
			health -= 0.05
		else:
			health = 100
			is_revived = false
	if Global.can_second_wind and health <= 0 and not is_revived:
		second_wind_handle()
	elif health <= 0:
		Global.death_punishment(position, is_revived)
		var main_menu = ResourceLoader.load("res://main_menu.tscn")
		get_tree().change_scene_to_packed(main_menu)
	# Add the gravity.
	if not is_on_floor():
		# handles gravity going up
		if velocity.y < 0:
			velocity += get_gravity() * delta
		# handles gravity going down by giving it more gravity to make jumping feel good
		else:
			velocity.y += 2500 * delta
	else:
		jump_count = 0
		has_jumped = false
		jump_released = false
	
	if !is_damaged and !is_stunned and health > 0:
		if Global.can_double_jump: # handles double jumps
			if Input.is_action_just_pressed("jump") and jump_count < 2 and not has_jumped:
				jump_count += 1
				if jump_count == 2:
					has_jumped = true
				velocity.y = JUMP_VELOCITY
			elif Input.is_action_just_released("jump") and velocity.y < 0 and not jump_released: # handles small jumps
				if velocity.y < (JUMP_VELOCITY / 2):
					velocity.y = JUMP_VELOCITY / 2
					jump_released = true
		else: # handles big jumps and single jumps
			if Input.is_action_just_pressed("jump") and is_on_floor():
				velocity.y = JUMP_VELOCITY
				has_jumped = true
			elif Input.is_action_just_pressed("jump") and not has_jumped:
				velocity.y = JUMP_VELOCITY
				has_jumped = true
			elif Input.is_action_just_released("jump") and velocity.y < 0 and not jump_released: # handles small jumps
				if velocity.y < (JUMP_VELOCITY / 2):
					velocity.y = JUMP_VELOCITY / 2
					jump_released = true
		
		attack_handler()
		
		# Get the input direction and handle the movement/deceleration.
		var direction := Input.get_axis("left", "right")
		if direction:
			# resets damage output when moving
			damage_output = 0
			if not is_wall_sliding:
				velocity.x = direction * SPEED
			
			if Input.is_action_pressed("left"):
				facing_position = "left"
				$AnimatedSprite2D.flip_h = true
			elif Input.is_action_pressed("right"):
				facing_position = "right"
				$AnimatedSprite2D.flip_h = false
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		
		# Pressing dash
		if dashing and not charge_dash:
			if facing_position == "right":
				velocity.x = 1 * DASH_SPEED
			elif facing_position == "left":
				velocity.x = -1 * DASH_SPEED
		# holding dash
		elif dashing and charge_dash:
			if facing_position == "right":
				velocity.x = 1 * (DASH_SPEED * 2)
			elif facing_position == "left":
				velocity.x = -1 * (DASH_SPEED * 2)
	
	# Handle dash.
	if Global.can_charge_dash:
		if Input.is_action_pressed("dash") and can_dash:
			hold_dash_count += 0.5
		
		elif Input.is_action_just_released("dash") and can_dash:
			if hold_dash_count < 5:
				dashing = true
				can_dash = false
				charge_dash = false
				$dashing.start()
				$can_dash.start()
			else:
				dashing = true
				can_dash = false
				charge_dash = true
				$dashing.start()
				$can_dash.start()
			hold_dash_count = 0
		
		if charge_dash:
			player_collision_handler(true)
		else:
			player_collision_handler(false)
	else:
		if Input.is_action_just_pressed("dash") and can_dash:
			dashing = true
			can_dash = false
			charge_dash = false
			$dashing.start()
			$can_dash.start()
	
	if Global.can_wall_jump:
		if is_on_floor():
			is_wall_sliding = false
			current_wall = ""
			off_ground = false
		else:
			 # When pressing down key, proceed to fall 
			if Input.is_action_pressed("down_attack"):
				is_wall_sliding = false
			else:
				# Handling wall slide and jump with cooldown
				if $left.is_colliding() and current_wall == "right":
					is_wall_sliding = true
					velocity.y = min(velocity.y, 100)
					jump_count = 2
					if Input.is_action_pressed("right") and Input.is_action_pressed("jump"):
						velocity.y = JUMP_VELOCITY
						velocity.x = 250
						current_wall = "left"
					elif Input.is_action_pressed("right"):
						wall_fall += 0.5
						if wall_fall >= 1:
							is_wall_sliding = false
							off_ground = false
				elif $right.is_colliding() and current_wall == "left":
					is_wall_sliding = true
					velocity.y = min(velocity.y, 100)
					jump_count = 2
					if Input.is_action_pressed("left") and Input.is_action_pressed("jump"):
						current_wall = "right"
						velocity.y = JUMP_VELOCITY
						velocity.x = -250
					elif Input.is_action_pressed("left"):
						wall_fall += 0.5
						if wall_fall >= 1.5:
							is_wall_sliding = false
							off_ground = false
				else:
					wall_fall = 0
					if $left.is_colliding() and not off_ground:
						current_wall = "right"
						off_ground = true
					elif $right.is_colliding() and not off_ground:
						current_wall = "left"
						off_ground = true
					else:
						is_wall_sliding = false
	
	if is_stunned == true and health > 0:
		if loop_once == false:
			loop_once = true
			await get_tree().create_timer(0.6).timeout
			is_stunned = false
			loop_once = false
	
	if combo > 1:
		status.text = "Combo:\nX" + str(combo)
	else:
		status.text = ""
	
	move_and_slide()


func second_wind_handle():
	second_wind_menu.visible = true
	player_collision_handler(true)
	velocity = Vector2(0,0)
	if second_wind_menu.status == "alive":
		health = 100
		second_wind_menu.visible = false
		if get_tree().get_node_count_in_group("enemy") > 0:
			is_revived = true
		await get_tree().create_timer(0.7).timeout
		player_collision_handler(false)


func player_collision_handler(change: bool):
	if change:
		set_collision_layer_value(1, false)
		set_collision_mask_value(1, false)
		set_collision_layer_value(3, true)
		set_collision_mask_value(3, true)
	else:
		set_collision_layer_value(1, true)
		set_collision_mask_value(1, true)
		set_collision_layer_value(3, false)
		set_collision_mask_value(3, false)


func attack_handler():
	if !is_attacking:
		if Input.is_action_pressed("attack") and Input.is_action_pressed("up_attack"):
			damage_output = 5
			attacking_position = "up"
			$AnimatedSprite2D.play("attack_up")
			is_attacking = true
			$attack_range/attack_up.disabled = false
			await get_tree().create_timer(0.25).timeout
			$attack_range/attack_up.disabled = true
			$AnimatedSprite2D.play("default")
			await get_tree().create_timer(0.15).timeout
			is_attacking = false
		
		elif Input.is_action_pressed("attack") and Input.is_action_pressed("down_attack"):
			damage_output = 5
			attacking_position = "down"
			$AnimatedSprite2D.play("attack_down")
			is_attacking = true
			$attack_range/attack_down.disabled = false
			await get_tree().create_timer(0.25).timeout
			$attack_range/attack_down.disabled = true
			$AnimatedSprite2D.play("default")
			await get_tree().create_timer(0.15).timeout
			is_attacking = false
		
		elif Input.is_action_pressed("attack"):
			damage_output += 0.5
		
		elif Input.is_action_just_released("attack"):
			if damage_output < 5:
				damage_output = 5
			elif damage_output > 20:
				damage_output = 20
			$AnimatedSprite2D.play("attack")
			is_attacking = true
			if facing_position == "left":
				attacking_position = "left"
				$attack_range/attack_left.disabled = false
				await get_tree().create_timer(0.25).timeout
				$attack_range/attack_left.disabled = true
				$AnimatedSprite2D.play("default")
				await get_tree().create_timer(0.25).timeout
				is_attacking = false
				damage_output = 0
				
			else:
				attacking_position = "right"
				$attack_range/attack_right.disabled = false
				await get_tree().create_timer(0.25).timeout
				$attack_range/attack_right.disabled = true
				$AnimatedSprite2D.play("default")
				await get_tree().create_timer(0.25).timeout
				is_attacking = false
				damage_output = 0


# Handle taking damage
func take_damage(amount: int) -> void:
	if not is_damaged:
		is_damaged = true
		health -= amount
		if health < 0:
			health = 0
		damage_cooldown()


# Damage cooldown handling
func damage_cooldown() -> void:
	await get_tree().create_timer(0.4).timeout
	is_damaged = false


func _on_dashing_timeout() -> void:
	dashing = false
	charge_dash = false


func _on_can_dash_timeout() -> void:
	can_dash = true


func _on_attack_range_body_entered(body: Node2D) -> void:
	if body.name == "enemy" or body.name == "mid_enemy":
		if combo < 3:
			combo += 1
		$combo_timer.stop()
		$combo_timer.start()
		if attacking_position == "down":
			if facing_position == "left":
				velocity = Vector2(0, -500)
			elif facing_position == "left":
				velocity = Vector2(0, -500)
			body.down_attacked = true
		
		if damage_output > 10:
			var half_combo = roundf(combo / 2)
			body.take_damage(roundf(damage_output) * combo)
		else:
			body.take_damage(roundf(damage_output) * combo)
		damage_output = 0


func _on_combo_timer_timeout() -> void:
	combo = 0


func _on_body_detection_body_entered(body: Node2D) -> void:
	if body.name == "enemy" and dashing == true and body.dashed_through == false:
		body.dashed_through = true
		body.loop_once = false
		body.stun_logic()
	
	elif body.name == "mid_enemy" and charge_dash == true or body.name == "big_enemy" and charge_dash == true:
		body.dashed_through = true
		body.loop_once = false
		body.stun_logic()
	
	elif body.name == "mid_enemy" and dashing == true or body.name == "big_enemy" and dashing == true or body.name == "boss" and dashing == true:
		is_stunned = true
		var knockback_dir = global_position.direction_to(body.global_position)
		
		if $left.is_colliding() and $left.get_collider().name == "floor" or $right.is_colliding() and $right.get_collider().name == "floor":
			if knockback_dir.y > 0:
				velocity.y = knockback_dir.y * -300
			else:
				velocity.y = knockback_dir.y + -300
			velocity.x = -knockback_dir.x * -400
		else:
			if knockback_dir.y > 0:
				velocity.y = knockback_dir.y * -300
			else:
				velocity.y = knockback_dir.y + -300
			velocity.x = knockback_dir.x * -300
			damage_output = 0
		body.dashed_through = true
		await get_tree().create_timer(0.5).timeout
		body.dashed_through = false
	
	elif body.name == "enemy" or body.name == "mid_enemy" or body.name == "big_enemy" or body.name == "boss":
		is_stunned = true
		var knockback_dir = global_position.direction_to(body.global_position)
		
		if $left.is_colliding() and $left.get_collider().name == "floor" or $right.is_colliding() and $right.get_collider().name == "floor":
			if knockback_dir.y > 0:
				velocity.y = knockback_dir.y * -300
			else:
				velocity.y = knockback_dir.y + -300
			velocity.x = -knockback_dir.x * -400
		else:
			if knockback_dir.y > 0:
				velocity.y = knockback_dir.y * -300
			else:
				velocity.y = knockback_dir.y + -300
			velocity.x = knockback_dir.x * -300
			damage_output = 0
		take_damage(body.damage_output)
		body.dashed_through = true
		await get_tree().create_timer(0.5).timeout
		body.dashed_through = false
