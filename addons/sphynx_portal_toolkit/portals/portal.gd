class_name Portal
extends MeshInstance3D

const portal_material : Material = preload("res://addons/sphynx_portal_toolkit/portals/portal_material.tres")

@export var portal_viewport : SubViewport

@export var portal_camera : Camera3D

@export var other_portal : Portal :
	set(value):
		other_portal = value
		if !other_portal:
			return
		
		other_portal.layers = 1 << 2
		other_portal.portal_camera.cull_mask = ~(1 << 1)
		layers = 1 << 1
		portal_camera.cull_mask = ~(1 << 2)

@export var recursions : int = 0

@export var show_debug : bool = false

@export var debug_color : Color

func _ready() -> void:
	portal_viewport.size = get_window().size
	set_surface_override_material(0, portal_material.duplicate())
	get_surface_override_material(0).set_shader_parameter("viewport_texture", portal_viewport.get_texture())
	get_surface_override_material(0).set_shader_parameter("debug_color", debug_color)
	get_surface_override_material(0).set_shader_parameter("show_debug", 1 if show_debug else 0)
	portal_viewport

func _process(delta: float) -> void:
	var teleport_transform : Transform3D = other_portal.global_transform * global_transform.affine_inverse()
	portal_camera.global_transform =  teleport_transform * get_viewport().get_camera_3d().global_transform
