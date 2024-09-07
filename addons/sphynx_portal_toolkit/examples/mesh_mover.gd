extends RigidBody3D

func _process(delta: float) -> void:
	linear_velocity = Vector3(0, 0, sin(float(Time.get_ticks_msec()) / 1000.0) * 100 * delta)
