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
var combo = 0
var damage_output = 0
var health = 100


func _ready() -> void:
	$AnimatedSprite2D.play("default")


func _physics_process(delta: float) -> void:
	$CanvasLayer/ProgressBar.value = health
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Handle dash.
	if Input.is_action_just_pressed("dash") and can_dash:
		dashing = true
		can_dash = false
		$dashing.start()
		$can_dash.start()
	
	attack_handler()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		if dashing:
			velocity.x = direction * DASH_SPEED
		else:
			velocity.x = direction * SPEED
		
		if Input.is_action_pressed("left"):
			facing_position = "left"
			$AnimatedSprite2D.flip_h = true
		elif Input.is_action_pressed("right"):
			facing_position = "right"
			$AnimatedSprite2D.flip_h = false
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
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


func _on_dashing_timeout() -> void:
	dashing = false


func _on_can_dash_timeout() -> void:
	can_dash = true


func _on_attack_range_body_entered(body: Node2D) -> void:
	if body.name == "enemy":
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
	if body.name == "enemy" and dashing == true:
		print("makes weak enemies stun")
	
	elif body.name == "mid_enemy" and dashing == true or body.name == "big_enemy" and dashing == true or body.name == "boss" and dashing == true:
		pass
	
	elif body.name == "enemy" or body.name == "mid_enemy" or body.name == "big_enemy" or body.name == "boss":
		health -= body.damage_output
		#var get_direction = global_position.direction_to(body.global_position)
		#velocity = get_direction
		#velocity.y = JUMP_VELOCITY
