extends CharacterBody3D

@export var camera : Camera3D

func _process(delta: float) -> void:
	var movement_input : Vector2 = Input.get_vector("A", "D", "W", "S")
	
	var movement_3D_input : Vector3 = Vector3(movement_input.x, Input.get_vector("Q", "E", "A", "D").x, movement_input.y) * 2;
	
	velocity = Basis(camera.global_basis.x, Vector3(0, 1, 0), camera.global_basis.x.cross(Vector3(0, 1, 0))) * movement_3D_input
	
	move_and_slide()