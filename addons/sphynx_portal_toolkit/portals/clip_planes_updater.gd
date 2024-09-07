extends Node

func _process(delta: float) -> void:
	Portal.clip_planes_texture.update(Portal.clip_planes_image)
