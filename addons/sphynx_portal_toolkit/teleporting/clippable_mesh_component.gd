class_name ClippableMeshComponent
extends Node

@export var clippable_mesh : MeshInstance3D

func _ready():
	for material in clippable_mesh.get_surface_override_material_count():
		clippable_mesh.get_surface_override_material(material).set_shader_parameter("clip_planes_texture", Portal.clip_planes_texture)
