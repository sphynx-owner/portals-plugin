class_name Portal
extends MeshInstance3D

const portal_material : Material = preload("res://addons/sphynx_portal_toolkit/portals/portal_material.tres")

@export var portal_viewport : SubViewport

@export var portal_camera : Camera3D

@export var other_portal : Portal

func _ready() -> void:
	portal_viewport.size = get_window().size
	set_surface_override_material(0, portal_material.duplicate())
	get_surface_override_material(0).set_shader_parameter("viewport_texture", portal_viewport.get_texture())

func _process(delta: float) -> void:
	portal_camera.global_transform = global_transform * (other_portal.global_transform.inverse() * get_viewport().get_camera_3d().global_transform)
