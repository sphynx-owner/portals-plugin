class_name SplittableComponent
extends Node

@export var mesh_to_split : MeshInstance3D

@export var mesh_collision : Area3D

@export var teleport_component : TeleportComponent

var mesh_copy : MeshInstance3D

var portal_in_contact : Portal

var in_front : bool = false

func _ready() -> void:
	mesh_copy = mesh_to_split.duplicate()
	mesh_copy.top_level = true
	mesh_copy.visible = false
	for material in mesh_copy.get_surface_override_material_count():
		mesh_copy.set_surface_override_material(material, mesh_copy.get_surface_override_material(material).duplicate())
		mesh_copy.get_surface_override_material(material).set_shader_parameter("active_split", true)
	get_tree().root.add_child.call_deferred(mesh_copy)
	mesh_collision.collision_mask = 1 << 9
	mesh_collision.collision_layer = 1 << 9
	mesh_collision.body_entered.connect(on_portal_body_entered)
	mesh_collision.body_exited.connect(on_portal_body_exited)

func _process(delta: float) -> void:
	if !portal_in_contact:
		return
	
	var teleport_transform : Transform3D = portal_in_contact.other_portal.global_transform * portal_in_contact.global_transform.affine_inverse() 
	
	var portal_origin : Vector3 = portal_in_contact.global_position
	var portal_normal : Vector3 = portal_in_contact.global_basis.z.normalized()
	var copy_portal_origin : Vector3 = portal_in_contact.other_portal.global_position
	var copy_portal_normal : Vector3 = portal_in_contact.other_portal.global_basis.z.normalized()
	
	mesh_copy.global_transform = teleport_transform * mesh_to_split.global_transform
	for material in mesh_copy.get_surface_override_material_count():
		mesh_to_split.get_surface_override_material(material).set_shader_parameter("split_plane_origin", portal_origin)
		mesh_to_split.get_surface_override_material(material).set_shader_parameter("split_plane_normal", portal_normal * (1 if teleport_component.get_in_front(portal_in_contact) else -1))
		mesh_copy.get_surface_override_material(material).set_shader_parameter("split_plane_origin", copy_portal_origin)
		mesh_copy.get_surface_override_material(material).set_shader_parameter("split_plane_normal", -copy_portal_normal * (1 if teleport_component.get_in_front(portal_in_contact) else -1))

func get_in_front(portal : Portal) -> bool:
	var portal_transform : Transform3D = portal.global_transform
	var offset : Vector3 = mesh_to_split.global_position - portal_transform.origin
	return !(portal_transform.basis.z.dot(offset) < 0)

func on_portal_body_entered(body : Node3D):
	print("entered portal")
	portal_in_contact = body.owner
	in_front = get_in_front(portal_in_contact)
	mesh_copy.visible = true
	mesh_to_split.get_surface_override_material(0).set_shader_parameter("active_split", true)

func on_portal_body_exited(body : Node3D):
	print("exited portal")
	if body.owner == portal_in_contact:
		portal_in_contact = null
		mesh_copy.visible = false
	mesh_to_split.get_surface_override_material(0).set_shader_parameter("active_split", false)
