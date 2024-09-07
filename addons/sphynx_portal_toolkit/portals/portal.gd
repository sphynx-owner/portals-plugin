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
	subscribe_portal(self)
	portal_viewport.size = get_window().size
	sync_camera_index(portal_camera, self)
	set_surface_override_material(0, portal_material.duplicate())
	get_surface_override_material(0).set_shader_parameter("viewport_texture", portal_viewport.get_texture())
	get_surface_override_material(0).set_shader_parameter("debug_color", debug_color)
	get_surface_override_material(0).set_shader_parameter("show_debug", 1 if show_debug else 0)
	generate_subviewports()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		unsubscribe_portal(self)

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
		sync_camera_index(new_camera, self)
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
	
	var clip_plane_origin : Vector3 = other_portal.global_position
	var clip_plane_normal : Vector3 = other_portal.global_basis.z.normalized()
	
	if global_basis.z.normalized().dot(get_viewport().get_camera_3d().global_position - global_position) > 0:
		clip_plane_normal = -clip_plane_normal
	
	Portal.clip_planes_image.set_pixelv(Vector2(all_portals[self] * 2, 0), Color(clip_plane_origin.x, clip_plane_origin.y, clip_plane_origin.z, 1))
	Portal.clip_planes_image.set_pixelv(Vector2(all_portals[self] * 2 + 1, 0), Color(clip_plane_normal.x, clip_plane_normal.y, clip_plane_normal.z, 1))

static func subscribe_portal(in_portal : Portal):
	if all_portals.has(in_portal):
		return
	
	all_portals[in_portal] = 0
	
	refresh_portal_indexes()

static func unsubscribe_portal(in_portal : Portal):
	if !all_portals.has(in_portal):
		return
	
	all_portals.erase(in_portal)

static func refresh_portal_indexes():
	var index : int = 0
	for portal in all_portals.keys():
		all_portals[portal] = index
		index += 1
		var current_portal : Portal = portal as Portal
		sync_camera_index(current_portal.portal_camera, current_portal)
		for camera in current_portal.all_cameras:
			sync_camera_index(camera, current_portal)

static func sync_camera_index(in_camera : Camera3D, in_portal : Portal):
	in_camera.near = 0.2
	in_camera.far = 500 + all_portals[in_portal]
