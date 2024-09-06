@tool
class_name TeleportComponent
extends Area3D

signal teleported()

@export var radius : float = 1 :
	set(value):
		radius = value
		if collision_shape:
			(collision_shape.shape as SphereShape3D).radius = radius

@export var parent_to_teleport : Node3D

var collision_shape : CollisionShape3D

var portal_in_contact : Portal

var in_front : bool = false

func _ready():
	collision_shape = CollisionShape3D.new()
	add_child(collision_shape)
	collision_shape.shape = SphereShape3D.new()
	(collision_shape.shape as SphereShape3D).radius = radius
	collision_mask = 1 << 9
	collision_layer = 1 << 9
	body_entered.connect(on_portal_body_entered)
	body_exited.connect(on_portal_body_exited)

func _process(delta: float) -> void:
	
	if !portal_in_contact:
		return
	
	var current_in_front : bool = get_in_front(portal_in_contact)
	
	if current_in_front != in_front:
		teleport()

func get_in_front(portal : Portal) -> bool:
	var portal_transform : Transform3D = portal.global_transform
	var offset : Vector3 = global_position - portal_transform.origin
	return !(portal_transform.basis.z.dot(offset) < 0)

func on_portal_body_entered(body : Node3D):
	print("teleport entered portal")
	portal_in_contact = body.owner
	in_front = get_in_front(portal_in_contact)

func on_portal_body_exited(body : Node3D):
	print("teleport exited portal")
	portal_in_contact = null

func teleport():
	print("teleport teleporting")
	var temp_portal_in_contact : Portal = portal_in_contact
	portal_in_contact = null
	var teleport_transform : Transform3D = temp_portal_in_contact.other_portal.global_transform * temp_portal_in_contact.global_transform.affine_inverse() 
	parent_to_teleport.global_transform = teleport_transform * parent_to_teleport.global_transform
	if parent_to_teleport is RigidBody3D:
		parent_to_teleport.linear_velocity = teleport_transform.basis * parent_to_teleport.linear_velocity
		parent_to_teleport.angular_velocity = teleport_transform.basis * parent_to_teleport.angular_velocity
	teleported.emit(temp_portal_in_contact.other_portal)
