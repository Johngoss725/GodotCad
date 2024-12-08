extends Camera3D

@export var movement_amount=1.0
@export var rotate_amout=10.0

@onready var curr_state=""
@onready var next_state="normal"
@onready var prev_state=""



func _physics_process(delta):
	allow_clicking()
	allow_movement()
	allow_roatation()

func allow_clicking():
	if Input.is_action_just_pressed("left_mouse"):
		var mousePos = get_viewport().get_mouse_position()
		var raylength = 1000
		var from = project_ray_origin(mousePos) 
		var to = from + project_ray_normal(mousePos) * raylength
		var space = get_world_3d().direct_space_state
		var rayQuery = PhysicsRayQueryParameters3D.new()
		rayQuery.from = from
		rayQuery.to = to 
		rayQuery.collide_with_areas = true
		var result = space.intersect_ray(rayQuery)
		#print("Results: ", result)
		get_parent().location_clicked_from_camera(result)

func allow_movement():
#for movement
	if Input.is_action_pressed("up"):
		position.z-=movement_amount
	if Input.is_action_pressed("down"):
		position.z+=movement_amount
	if Input.is_action_pressed("left"):
		position.x-=movement_amount
	if Input.is_action_pressed("right"):
		position.x+=movement_amount
	if Input.is_action_pressed("move_in"):
		position.y-=movement_amount
	if Input.is_action_pressed("move_out"):
		position.y+=movement_amount

func allow_roatation():
#for rotation
	if Input.is_action_just_released("rotate_up"):
		rotation_degrees.x-=rotate_amout
	if Input.is_action_just_released("rotate_down"):
		rotation_degrees.x+=rotate_amout
