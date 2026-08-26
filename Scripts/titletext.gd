extends RichTextLabel
@onready var startpos: Vector2 = global_position
@export var dropdistance: int
@export var duration: float
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dropdistance = 200
	global_position.y -= dropdistance
	_textanim()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _textanim() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "position", startpos, duration).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
