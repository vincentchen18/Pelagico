extends CharacterBody2D

@export var speed := 300.0
@export var acceleration := 4.0
@export var drag := 2.0
@export var turn_speed := 3.0   # radians/sec when turning

@onready var sprite: Node2D = $Sprite2D

func _physics_process(delta):
	# turning
	var turn = Input.get_axis("left", "right")
	rotation += turn * turn_speed * delta

	# fwd/bkwd
	var thrust = Input.get_axis("backward", "forward") 
	if thrust != 0:
		# go in the curr direction
		var forward = Vector2.RIGHT.rotated(rotation)
		velocity = velocity.lerp(forward * speed * thrust, acceleration * delta)
	else:
		velocity = velocity.lerp(Vector2.ZERO, drag * delta)

	move_and_slide()
