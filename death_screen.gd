extends CanvasLayer

@onready var player = get_node("/root/ocean/Player")

func _ready() -> void:
	visible = false
	$VBoxContainer/RespawnButton.pressed.connect(_on_respawn)
	$VBoxContainer/MainMenuButton.pressed.connect(_on_menu_pressed)
	$ConfirmationDialog.confirmed.connect(_do_menu)

func show_death() -> void:
	visible = true
	get_tree().paused = true
func _on_menu_pressed() -> void:
	$ConfirmationDialog.popup_centered(Vector2(400, 80))
func _on_respawn() -> void:
	get_tree().paused = false
	visible = false
	player.respawn()
func _do_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://menu.tscn")
