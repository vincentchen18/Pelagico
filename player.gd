extends CharacterBody2D

@export var speed := 200.0
@onready var sprite: Node2D = $Sprite2D

func _physics_process(_delta):
	var dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if dir.x != 0:
		sprite.flip_h = dir.x > 0
	velocity = dir * speed
	move_and_slide()
