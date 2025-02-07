extends CharacterBody2D

var direction = Vector2.RIGHT
@onready var ledgeCheckRight: = $right
@onready var ledgeCheckLeft: = $left
@onready var sprite: = $AnimatedSprite2D
@onready var player: CharacterBody2D = $"../player"
@onready var player_detection = $player_detection
@onready var player_detection2 = $player_detection2


var health = 100
var damage_output = 10
var is_dead: bool = false
var is_damaged: bool = false
var is_chasing = false
var dashed_through = false
var loop_once = false
var in_view = false

@export var speed: float = 50.0
@export var chase_speed: float = 100.0 # Speed when chasing the player
@export var stop_distance: float = 63.0 # Distance to stop when near the player

func _ready() -> void:
	velocity = Vector2.ZERO

func _physics_process(delta):
	# Apply gravity if not on the floor
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if dashed_through == true:
		if loop_once == false:
			loop_once = true
			await get_tree().create_timer(1.0).timeout
			dashed_through = false
			loop_once = false
	
	# Handle enemy death
	if health <= 0 and not is_dead:
		is_dead = true
		queue_free()
		$ProgressBar.visible = false
	
	# Check if damaged and apply knockback
	if is_damaged:
		dashed_through = false
		var knockback_dir = global_position.direction_to(player.global_position)
		velocity = knockback_dir * -250
	elif dashed_through == false:
		if is_chasing:
			chase_player()
		else:
			patrol()

	move_and_slide()
	## Calculate the direction to the player
	#var direction_to_player = (player.global_position - global_position).normalized()
	## Update the direction based on the normalized direction_to_player
	#player_detection.rotation = direction_to_player.angle()
	if player_detection.is_colliding() and player_detection.get_collider().name == "player" or player_detection2.is_colliding() and player_detection2.get_collider().name == "player":
		is_chasing = true
	elif !ledgeCheckRight.is_colliding() or !ledgeCheckLeft.is_colliding():
		is_chasing = true
	elif not in_view:
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

func stun_logic():
	velocity = Vector2(0,0)


#func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	#on_screen = true
#
#
#func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	#is_chasing = false
	#on_screen = false


func _on_vision_zones_body_entered(body: Node2D) -> void:
	if body.name == "player":
		in_view = true


func _on_vision_zones_body_exited(body: Node2D) -> void:
	if body.name == "player":
		in_view = false
