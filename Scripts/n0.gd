extends Node2D
@export var target_y := 210.0
@export var rise_time := 1.5
@export var hold_time := 2.0

func _ready() -> void:
	$AnimatedSprite2D.play("default")
	$AnimatedSprite2D.animation_finished.connect(_start_text)

func _start_text() -> void:
	var tw = create_tween()
	tw.tween_property($Label, "position:y", target_y, rise_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_interval(hold_time)
	tw.tween_callback(_go_to_menu)

func _go_to_menu() -> void:
	get_tree().change_scene_to_file("res://menu.tscn")
