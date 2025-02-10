extends CharacterBody2D

@onready var status = $Label
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


func _ready() -> void:
	$AnimatedSprite2D.play("default")


func _physics_process(delta: float) -> void:
	$CanvasLayer/ProgressBar.value = health
	if health <= 0:
		get_tree().reload_current_scene()
	# Add the gravity.
	if not is_on_floor():
		# handles gravity going up
		if velocity.y < 0:
			velocity += get_gravity() * delta
		# handles gravity going down by giving it more gravity to make jumping feel good
		else:
			velocity.y += 1500 * delta
	else:
		jump_count = 0
		has_jumped = false
	if !is_damaged and !is_stunned:
		# Handle jump and if jump is big or small.
		if Input.is_action_just_released("jump") and velocity.y < 0: # handles small jumps
			velocity. y = JUMP_VELOCITY / 4
		if Global.can_double_jump: # handles big jumps and double jumps
			if Input.is_action_just_pressed("jump") and jump_count < 2 and not has_jumped:
				jump_count += 1
				if jump_count == 2:
					has_jumped = true
				velocity.y = JUMP_VELOCITY
		else: # handles big jumps and single jumps
			if Input.is_action_just_pressed("jump") and is_on_floor():
				velocity.y = JUMP_VELOCITY
				has_jumped = true
			elif Input.is_action_just_pressed("jump") and not has_jumped:
				velocity.y = JUMP_VELOCITY
				has_jumped = true
		
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
		else:
			if Input.is_action_just_pressed("dash") and can_dash:
				dashing = true
				can_dash = false
				charge_dash = false
				$dashing.start()
				$can_dash.start()
		
		attack_handler()
		
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction := Input.get_axis("left", "right")
		if direction:
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
	
	if is_stunned == true and health > 0:
		if loop_once == false:
			loop_once = true
			await get_tree().create_timer(1.0).timeout
			is_stunned = false
			loop_once = false
	
	if combo > 1:
		status.text = "X" + str(combo)
	else:
		status.text = ""
	move_and_slide()


func attack_handler():
	if !is_attacking:
		if Input.is_action_pressed("attack") and Input.is_action_pressed("up_attack"):
			damage_output = 1
			attacking_position = "up"
			$AnimatedSprite2D.play("default")
			is_attacking = true
			$attack_range/attack_up.disabled = false
			await get_tree().create_timer(0.25).timeout
			$attack_range/attack_up.disabled = true
			$AnimatedSprite2D.play("default")
			await get_tree().create_timer(0.15).timeout
			is_attacking = false
		
		elif Input.is_action_pressed("attack") and Input.is_action_pressed("down_attack"):
			damage_output = 1
			attacking_position = "down"
			$AnimatedSprite2D.play("default")
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
				damage_output = 1
			elif damage_output > 30:
				damage_output = 30
			$AnimatedSprite2D.play("attack")
			is_attacking = true
			if facing_position == "left":
				attacking_position = "left"
				$attack_range/attack_left.disabled = false
				await get_tree().create_timer(0.25).timeout
				$attack_range/attack_left.disabled = true
				$AnimatedSprite2D.play("default")
				await get_tree().create_timer(0.15).timeout
				is_attacking = false
			else:
				attacking_position = "right"
				$attack_range/attack_right.disabled = false
				await get_tree().create_timer(0.25).timeout
				$attack_range/attack_right.disabled = true
				$AnimatedSprite2D.play("default")
				await get_tree().create_timer(0.15).timeout
				is_attacking = false


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
		combo += 1
		$combo_timer.stop()
		$combo_timer.start()
		if attacking_position == "down":
			velocity = Vector2(0, -700)
		
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
		await get_tree().create_timer(0.5).timeout
	
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
