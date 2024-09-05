extends CollisionShape3D

@export var spring_arm : SpringArm3D

func _process(delta: float) -> void:
	var cylinder : CylinderShape3D = shape as CylinderShape3D
	
	cylinder.height = spring_arm.spring_length
	global_rotation = spring_arm.global_rotation + Vector3(PI / 2, 0, 0)
	global_position = spring_arm.global_position + spring_arm.global_basis.z * spring_arm.spring_length / 2
