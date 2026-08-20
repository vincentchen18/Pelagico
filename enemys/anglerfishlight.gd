extends PointLight2D
var t = 0
var g := 0.0
func _physics_process(delta):
	t += delta
	g = (sin(t) + 0.5 * sin(t * 2.1 + 1.5) + 0.25 * sin(t * 4.3 + 2.7) + 0.125 * sin(t * 8.5))
	scale = Vector2(g,g)
