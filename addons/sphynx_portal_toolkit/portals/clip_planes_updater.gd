extends Node

func _ready() -> void:
	process_priority = 1

func _process(delta: float) -> void:
	Portal.clip_planes_texture.update(Portal.clip_planes_image)
