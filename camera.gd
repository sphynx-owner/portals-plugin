extends Camera3D



func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		global_rotation += Vector3(rad_to_deg(-event.relative.y), rad_to_deg(-event.relative.x), 0) / 10000
		#draw_process()
