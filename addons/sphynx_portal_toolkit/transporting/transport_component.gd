class_name TransportComponent
extends Node

@export var pivot_node : Node3D

@export var radius : float = 1

var portal_in_contact : Portal

func _ready():
	var new_area : Area3D = Area3D.new()
	pivot_node.add_child(new_area)
	var new_collision_shape : CollisionShape3D = CollisionShape3D.new()
	new_area.add_child(new_collision_shape)
	new_collision_shape.shape = SphereShape3D.new()
	(new_collision_shape.shape as SphereShape3D).radius = radius
	new_area.collision_mask = 1 << 9
	new_area.collision_layer = 1 << 9
	new_area.body_entered.connect(on_portal_body_entered)
	new_area.body_exited.connect(on_portal_body_exited)

func on_portal_body_entered(body : Node3D):
	portal_in_contact = body.owner

func on_portal_body_exited(body : Node3D):
	if body.owner == portal_in_contact:
		portal_in_contact = null
