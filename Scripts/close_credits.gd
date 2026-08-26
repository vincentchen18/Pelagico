extends Button

func _ready() -> void:
	get_node("../Credits").visible = false
	get_node("../close credits").visible = false
func _process(_delta: float) -> void:
	pass

func _on_pressed() -> void:
	get_node("../Credits").visible = false
	get_node("../close credits").visible = false
