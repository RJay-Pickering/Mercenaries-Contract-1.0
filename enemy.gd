extends CharacterBody2D

var direction = Vector2.RIGHT
@onready var ledgeCheckRight: = $right
@onready var ledgeCheckLeft: = $left
@onready var sprite: = $AnimatedSprite2D
@onready var player: CharacterBody2D = $"../player"
@onready var player_detection = $player_detection

var health = 100
var damage_output = 10
var is_dead: bool = false
var is_damaged: bool = false
var is_chasing = false

@export var speed: float = 50.0
@export var chase_speed: float = 100.0 # Speed when chasing the player
@export var stop_distance: float = 64.5 # Distance to stop when near the player

func _ready() -> void:
	velocity = Vector2.ZERO

func _physics_process(delta):
	# Apply gravity if not on the floor
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Handle enemy death
	if health <= 0 and not is_dead:
		is_dead = true
		queue_free()
		$ProgressBar.visible = false
	
	# Check if damaged and apply knockback
	if is_damaged:
		var knockback_dir = global_position.direction_to(player.global_position)
		velocity = knockback_dir * -250
	else:
		if is_chasing:
			chase_player()
		else:
			patrol()

	move_and_slide()
	# Calculate the direction to the player
	var direction_to_player = (player.global_position - global_position).normalized()
	# Update the direction based on the normalized direction_to_player
	player_detection.rotation = direction_to_player.angle()
	print(player_detection.get_collider())
	if player_detection.is_colliding() and player_detection.get_collider().name == "player":
		is_chasing = true
	else:
		is_chasing = false

# Patrol behavior: move side-to-side until hitting a wall or ledge
func patrol():
	var found_wall = is_on_wall()
	var right_ledge_check = ledgeCheckRight.is_colliding() and not ledgeCheckRight.get_collider().name == "floor"
	var left_ledge_check = ledgeCheckLeft.is_colliding() and not ledgeCheckLeft.get_collider().name == "floor"
	
	if found_wall or right_ledge_check or left_ledge_check:
		direction *= -1
	elif !ledgeCheckRight.is_colliding() or !ledgeCheckLeft.is_colliding():
		direction *= -1
	
	if direction.x > 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	
	velocity.x = direction.x * speed

# Chase the player with smarter behavior
func chase_player():
	var distance_to_player = position.distance_to(player.position)
	
	if distance_to_player > stop_distance:
		var chase_direction = (player.position - position).normalized()
		velocity.x = chase_direction.x * chase_speed
	else:
		velocity.x = 0

# Handle taking damage
func take_damage(amount: int) -> void:
	if not is_damaged:
		is_damaged = true
		health -= amount
		if health < 0:
			health = 0
		$ProgressBar.value = health
		damage_cooldown()

# Damage cooldown handling
func damage_cooldown() -> void:
	await get_tree().create_timer(0.4).timeout
	is_damaged = false
