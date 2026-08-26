extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_node("../Instructions").visible = false
	get_node("../close instructions").visible = false



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_pressed() -> void:
	get_node("../Instructions").visible = true
	get_node("../close instructions").visible = true
