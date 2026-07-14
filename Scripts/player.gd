extends CharacterBody2D

@export var speed := 300.0
@export var acceleration := 4.0  
@export var deceleration := 2.0          

@onready var sprite: Node2D = $Sprite2D

func _physics_process(delta):
	var dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if dir.x != 0:
		sprite.flip_h = dir.x > 0

	if dir != Vector2.ZERO:
		velocity = velocity.lerp(dir * speed, acceleration * delta)
	else:
		velocity = velocity.lerp(Vector2.ZERO, deceleration * delta)

	move_and_slide()
