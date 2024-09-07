extends Node

func _process(delta: float) -> void:
	get_parent().global_rotation.y += delta / 10
