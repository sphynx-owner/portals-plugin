extends Node

@export var mesh_to_split : MeshInstance3D

@export var mesh_collision : Area3D

var mesh_copy : MeshInstance3D

var portal_in_contact : Portal

var in_front : bool = false

func _ready() -> void:
	mesh_copy = mesh_to_split.duplicate()
	mesh_to_split.top_level = true
	mesh_collision.collision_mask = 1 << 9
	mesh_collision.collision_layer = 1 << 9
	mesh_collision.body_entered.connect(on_portal_body_entered)
	mesh_collision.body_exited.connect(on_portal_body_exited)

func _process(delta: float) -> void:
	if !portal_in_contact:
		return
	

func get_in_front(portal : Portal) -> bool:
	var portal_transform : Transform3D = portal.global_transform
	var offset : Vector3 = mesh_to_split.global_position - portal_transform.origin
	return !(portal_transform.basis.z.dot(offset) < 0)

func on_portal_body_entered(body : Node3D):
	print("entered portal")
	portal_in_contact = body.owner
	in_front = get_in_front(portal_in_contact)

func on_portal_body_exited(body : Node3D):
	print("exited portal")
	if body.owner == portal_in_contact:
		portal_in_contact = null
