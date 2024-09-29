extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.005


@onready var camera = $Camera3D
@onready var slicer = $Camera3D/Slicer

var meshSlicer = MeshSlicer.new()

var cross_section_material = preload("res://addons/concave mesh slicer/Example/cross_section_material.tres")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	# The Node need to be in a tree for it to worked.
	add_child(meshSlicer)

func _physics_process(delta):
	# Add the gravity player.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("A", "D", "W", "S")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	
	#push rigidbody
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		for j in collision.get_collision_count():
			var obj = collision.get_collider(j)
			if obj is RigidBody3D:
				print("COLLIDE ",direction)
				obj.apply_force(direction*10,collision.get_position(j)-obj.position)


		
	#slice rigidbody
	if Input.is_action_just_pressed("left_mouse"):
		#var bodies = $Camera3D/Slicer/Area3D.get_overlapping_bodies().duplicate()
		for body in $Camera3D/Slicer/Area3D.get_overlapping_bodies().duplicate():
			if body is RigidBody3D:
				
				
				#The plane transform at the rigidbody local transform
				var meshinstance = body.get_node("MeshInstance3D")
				var Transform = Transform3D.IDENTITY
				Transform.origin = meshinstance.to_local((slicer.global_transform.origin))
				Transform.basis.x = meshinstance.to_local((slicer.global_transform.basis.x+body.global_position))
				Transform.basis.y = meshinstance.to_local((slicer.global_transform.basis.y+body.global_position))
				Transform.basis.z = meshinstance.to_local((slicer.global_transform.basis.z+body.global_position))

				

				var collision = body.get_node("CollisionShape3D")
				
				
				#Slice the mesh
				var meshes = meshSlicer.slice_mesh(Transform,meshinstance.mesh,cross_section_material)

				meshinstance.mesh = meshes[0]
				
				#generate collision
				if len(meshes[0].get_faces()) > 2:
					collision.shape = meshes[0].create_convex_shape()




				
				#adjust the rigidbody center of mass
				body.center_of_mass_mode = 1
				body.center_of_mass = body.to_local(meshinstance.to_global(calculate_center_of_mass(meshes[0])))


				#recalculate mass
				var volume1 = calculate_mesh_volume(meshes[0])
				var volume2 = calculate_mesh_volume(meshes[1])
				var total_volume = volume1 + volume2

				var mass1 = body.mass * (volume1 / total_volume)
				var mass2 = body.mass * (volume2 / total_volume)

				body.mass = mass1
				
				
				#second half of the mesh
				var body2 = body.duplicate()
				$"../RigidBodys".add_child(body2)
				meshinstance = body2.get_node("MeshInstance3D")
				collision = body2.get_node("CollisionShape3D")
				meshinstance.mesh = meshes[1]
				body2.mass = mass2
				
				#generate collision
				if len(meshes[1].get_faces()) > 2:
					collision.shape = meshes[1].create_convex_shape()

				#get mesh size
				var aabb = meshes[0].get_aabb()
				var aabb2 = meshes[1].get_aabb()
				#queue_free() if the mesh is too small
				if aabb2.size.length() < 0.3:
					body2.queue_free()
				if aabb.size.length() < 0.3:
					body.queue_free()
					
				#adjust the rigidbody center of mass
				body2.center_of_mass = body2.to_local(meshinstance.to_global(calculate_center_of_mass(meshes[1])))


func _input(event):
	#rotate camera
	if Input.is_action_pressed("right_mouse"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x*MOUSE_SENSITIVITY)
			camera.rotate_x(-event.relative.y*MOUSE_SENSITIVITY)
			camera.rotation.x = clamp(camera.rotation.x,-PI/2, PI/2)
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	
	#rotate slicer plane
	if Input.is_action_pressed("scroll_up"):
		slicer.rotate_z(0.1)
	if Input.is_action_pressed("scroll_down"):
		slicer.rotate_z(-0.1)	

				
func calculate_center_of_mass(mesh:ArrayMesh):
	#Not sure how well this work
	var meshVolume = 0
	var temp = Vector3(0,0,0)
	for i in range(len(mesh.get_faces())/3):
		var v1 = mesh.get_faces()[i]
		var v2 = mesh.get_faces()[i+1]
		var v3 = mesh.get_faces()[i+2]
		var center = (v1 + v2 + v3) / 3
		var volume = (Geometry3D.get_closest_point_to_segment_uncapped(v3,v1,v2).distance_to(v3)*v1.distance_to(v2))/2
		meshVolume += volume
		temp += center * volume
	
	if meshVolume == 0:
		return Vector3.ZERO
	return temp / meshVolume

func calculate_mesh_volume(mesh: ArrayMesh) -> float:
	var volume = 0.0
	for surface in range(mesh.get_surface_count()):
		var arrays = mesh.surface_get_arrays(surface)
		var vertices = arrays[Mesh.ARRAY_VERTEX]
		for i in range(0, vertices.size(), 3):
			var v1 = vertices[i]
			var v2 = vertices[i + 1]
			var v3 = vertices[i + 2]
			volume += abs(v1.dot(v2.cross(v3))) / 6.0
	return volume
