class_name Portal
extends MeshInstance3D

const portal_material : Material = preload("res://addons/sphynx_portal_toolkit/portals/portal_material.tres")

static var all_portals : Dictionary

static var clip_planes_image : Image = Image.create(1000, 1, false, Image.FORMAT_RGBAF)

static var clip_planes_texture : ImageTexture:
	get:
		if !clip_planes_texture:
			clip_planes_texture = ImageTexture.create_from_image(clip_planes_image)
		return clip_planes_texture

@export var portal_viewport : SubViewport

@export var portal_camera : Camera3D

@export_range(0, 10) var recursions : int = 0

@export var show_debug : bool = false

@export var debug_color : Color

@export var portal_chroma_key : MeshInstance3D

@export var other_portal : Portal :
	set(value):
		other_portal = value
		if !other_portal:
			return
		
		layers = (1 << 1)
		portal_chroma_key.layers = (1 << 2)
		portal_camera.cull_mask = ~((1 << 1) | (1 << 3))
		for camera in all_cameras:
			camera.cull_mask = portal_camera.cull_mask
		other_portal.layers = (1 << 1)
		other_portal.portal_chroma_key.layers = (1 << 3)
		other_portal.portal_camera.cull_mask = ~((1 << 1) | (1 << 2))
		for camera in other_portal.all_cameras:
			camera.cull_mask = other_portal.portal_camera.cull_mask

var all_subviewports : Array[SubViewport]

var all_cameras : Array[Camera3D]

func _ready() -> void:
	portal_viewport.size = get_window().size
	portal_camera
	set_surface_override_material(0, portal_material.duplicate())
	get_surface_override_material(0).set_shader_parameter("viewport_texture", portal_viewport.get_texture())
	get_surface_override_material(0).set_shader_parameter("debug_color", debug_color)
	get_surface_override_material(0).set_shader_parameter("show_debug", 1 if show_debug else 0)
	generate_subviewports()

func clear_subviewports():
	for subviewport in all_subviewports:
		subviewport.queue_free()
	
	all_subviewports.clear()
	all_cameras.clear()

func generate_subviewports():
	clear_subviewports()
	
	var all_inner_textures : Array[ViewportTexture]
	var all_viewport_indexes : Array[int]
	for i in recursions:
		var new_viewport : SubViewport = SubViewport.new()
		add_child(new_viewport)
		var new_camera : Camera3D = Camera3D.new()
		new_viewport.add_child(new_camera)
		new_viewport.size = get_window().size
		new_camera.cull_mask = portal_camera.cull_mask
		all_subviewports.append(new_viewport)
		all_cameras.append(new_camera)
		all_inner_textures.append(new_viewport.get_texture())
	get_surface_override_material(0).set_shader_parameter("inner_textures", all_inner_textures)

func _process(delta: float) -> void:
	var teleport_transform : Transform3D = other_portal.global_transform * global_transform.affine_inverse()
	var current_iter_transform : Transform3D = teleport_transform * get_viewport().get_camera_3d().global_transform
	portal_camera.global_transform = current_iter_transform
	portal_camera.fov = get_viewport().get_camera_3d().fov
	for camera in all_cameras:
		current_iter_transform = teleport_transform * current_iter_transform
		camera.global_transform = current_iter_transform
		camera.fov = get_viewport().get_camera_3d().fov

static func subscribe_portal(portal : Portal):
	pass

static func unsubscribe_portal(portal : Portal):
	pass
