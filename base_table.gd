extends Node3D

@onready var main_file_dialog: FileDialog=$Camera3D/Control/Settings/FileDialog
@onready var IM_mesh:ImmediateMesh = ImmediateMesh.new()
@onready var base_mesh=$Line_drawer
func _ready() -> void:
	add_child(temp_mesh)
	#draw_circle(2.0, 16, Vector3(0,0,0))

func _on_file_dialog_file_selected(path: String) -> void:
	print("lets grab that file: ", path)

func draw_circle(radius: float, segments: int, center:Vector3):
	var circle_mesh:MeshInstance3D=MeshInstance3D.new()
	var immediate_circle_mesh:ImmediateMesh=ImmediateMesh.new()
	var material:StandardMaterial3D=StandardMaterial3D.new()
	add_child(circle_mesh)
	material.albedo_color=Color(0.0,0.0,1.0)
	circle_mesh.mesh=immediate_circle_mesh
	
	immediate_circle_mesh.clear_surfaces()  # Clear any existing geometry
	immediate_circle_mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP, material)
	# Calculate points around the circle
	for i in range(segments):
		var angle = 2.0 * PI * i / segments
		var x = center.x + radius * cos(angle)
		var z = center.z + radius * sin(angle)
		var y = center.y  # Use the center's y-coordinate
		immediate_circle_mesh.surface_add_vertex(Vector3(x, 0, z))
		
	immediate_circle_mesh.surface_end()

var temp_geometry=null
@onready var ShapeDropdown:OptionButton = $Camera3D/Control/VBoxContainer2/ShapeSelect
func _on_make_shape_pressed() -> void:
	print("Here is the shape: ", ShapeDropdown.get_selected_id())
	match ShapeDropdown.get_selected_id():
		0:#square
			pass
		1:#circle
			print("we are doing it")
			temp_geometry="Circle"
			next_state="draw_temp_geometry"
		2:#Pionts
			pass
		3:#line
			pass
		_:
			print("we have an issue")

var continuing_line:bool = false
var current_shape_index:int = 0
#we will make a simple dot at each location and at the 
#end we will connect everythin with a immediate geometry
func location_clicked_from_camera(location):
	#print("here is my location: ", location["position"])
	#check if the user has activated the line feature
	if location=={}:
		print("emptydict")
		return
	if line_active==true: 
		#check that we are still cotinueing the same shape line. 
		if continuing_line==true:
			#we add the current point to the 
			shape_array[current_shape_index].append(location["position"])
			print("new PIONT added to the array at index ",current_shape_index)
			make_marking_shpere(location["position"])
		else:
			continuing_line=true
			#we will make a new shape and add it to the shape array.
			var shape: Array[Vector3] = [location["position"]] #our shape is just a collection of point for now we have no curves as of yet.
			shape_array.append(shape)
			current_shape_index = len(shape_array)-1
			print("new SHAPE created in the array at index: ",current_shape_index)
			make_marking_shpere(location["position"])
		#print("CURRENT_SHAPE: ", shape_array[current_shape_index])
		#print("shape array: ", shape_array)
	else:
		print("line tool not active")
	
#we will add these points to the array for this object
var shape_dict = {}
	#"shape1":{
	#	"pionts":[],
	#	"Meshinstance3d":MeshInstance3D,
	#	"ImmediateMesh":ImmediateMesh,
	#	"Material":StandardMaterial3D,
	#	"TriangleArray": [], 
	#	"Notes":"nothing to report"}
	#	}
var shape_array = []
var line_active=false
var use_shader:Shader=preload("res://Shaders/DottedLineShader.tres")


func create_shape(Name:String, M3d:MeshInstance3D, IM:ImmediateMesh, Mat:StandardMaterial3D, Pionts:Array, TriangleArray:Array, Notes:String ):
	shape_dict[Name] = {
		"Pionts":Pionts,
		"Meshinstance3d":M3d, 
		"ImmediateMesh":IM,
		"Material":Mat, 
		"TriangleArray":TriangleArray,
		"Notes":Notes}

func make_marking_shpere(shpere_location)-> void:
	var shpere_mesh = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius=0.25
	sphere.height=0.5
	shpere_mesh.mesh = sphere
	var material = ORMMaterial3D.new()
	material.emission_enabled=true
	material.albedo_color=Color(1.0,0,0)
	material.emission=Color(1.0,0,0)
	material.emission_energy_multiplier=20.0
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

	sphere.surface_set_material(0,material)
	#surface_material_override= use_shader#material
	add_child(shpere_mesh)
	var offset=Vector3(0,2,0)
	shpere_mesh.position=shpere_location+offset

func _on_start_line_pressed() -> void:
	line_active=true

@onready var confrimation_dialog = $Camera3D/Control/ConfirmationDialog
func _on_end_line_pressed() -> void:
	continuing_line=false
	line_active=false
	confrimation_dialog.popup()
	#print("full shape created!")
	#we need a popup to ask if the last and first point should be linked
	#link_shape_pionts()

func link_shape_pionts():
	$Line_drawer.mesh = IM_mesh
	var material= StandardMaterial3D.new()
	material.albedo_color=Color(0.5, 0.5, 0)
	var override_material = ShaderMaterial.new()
	override_material.shader=use_shader
	IM_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP, material)#override_material)#material)
	#IM_mesh.surface_set_material(0,override_material)
	var use_array = []
	
	for pionts in range(len(shape_array[current_shape_index])-1):
		#print(pionts)
		use_array.append(shape_array[current_shape_index][pionts]) 
		use_array.append(shape_array[current_shape_index][pionts + 1])
	
	var triangle_array = generate_line_triangles(use_array, 0.5)
	var use_name="test"
	create_shape(use_name, $Line_drawer,IM_mesh,material,use_array,triangle_array,"lets do it" )
	add_shape_to_menu(shape_dict[use_name],use_name)
	#print("current_shape: ", shape_array[current_shape_index])
	#print("Use_array:", use_array)
	for pionts in triangle_array:
		#print("here are the points: ", pionts)
		IM_mesh.surface_add_vertex(pionts+Vector3(0,2,0))
	IM_mesh.surface_end()

func generate_line_triangles(points: Array, width: float) -> Array:
	var vertices = []
	if points.size() < 2:
		return vertices  # Need at least two points to form a line
	var half_width = width / 2.0
	for i in range(points.size() - 1):
		var p1 = points[i]
		var p2 = points[i + 1]
		# Calculate the direction vector for the line segment
		var direction = (p2 - p1).normalized()
		# Find the perpendicular vector
		var perpendicular = Vector3(-direction.z, 0, direction.x).normalized()
		# Calculate the rectangle corners
		var p1_left = p1 - perpendicular * half_width
		var p1_right = p1 + perpendicular * half_width
		var p2_left = p2 - perpendicular * half_width
		var p2_right = p2 + perpendicular * half_width
		# Add two triangles for the rectangle
		vertices.append(p1_left)
		vertices.append(p1_right)
		vertices.append(p2_right)
		
		vertices.append(p1_left)
		vertices.append(p2_right)
		vertices.append(p2_left)
		
	return vertices

@onready var shapeList=$Camera3D/Control/ShapesMenu/ShapeList
func add_shape_to_menu(shape,Name):
	print("shape: ", shape)
	shapeList.add_item(Name)
	#we save the shape as the items metadata 
	shapeList.set_item_metadata(shapeList.item_count-1, shape)

func _on_confirmation_dialog_confirmed() -> void:
	#if we only have two points thers no need to redraw them to "close the shape"
	if len(shape_array[current_shape_index])>2:
	#if we are linkin all the verts then we add the first vert to the end of the array
		shape_array[current_shape_index].append(shape_array[current_shape_index][0])
	link_shape_pionts()
	#remeber we can always check if the shape is closed by us by checking the first and last verts for being the same!!!
	

func _on_confirmation_dialog_canceled() -> void:
	link_shape_pionts()
	#add_shape_to_menu(shape_array[current_shape_index])

var prev_state:String=""
var next_state:String="idle"
var curr_state:String=""
var temp_mesh:MeshInstance3D=MeshInstance3D.new()
var temp_immediate_mesh:ImmediateMesh=ImmediateMesh.new()
var temp_material:StandardMaterial3D=StandardMaterial3D.new()

func _process(delta: float) -> void:
	prev_state=curr_state
	curr_state=next_state
	match curr_state:
		"idle":
			pass
		"draw_temp_geometry":
			if curr_state!=prev_state:
				pass
			if Input.is_action_just_pressed("left_mouse"):
				var mousePos = get_viewport().get_mouse_position()
				var raylength = 1000
				var from = $Camera3D.project_ray_origin(mousePos) 
				var to = from + $Camera3D.project_ray_normal(mousePos) * raylength
				var space = get_world_3d().direct_space_state
				var rayQuery = PhysicsRayQueryParameters3D.new()
				rayQuery.from = from
				rayQuery.to = to 
				rayQuery.collide_with_areas = true
				var result = space.intersect_ray(rayQuery)
				if result!={}: 
					draw_shape_circle( temp_mesh, temp_immediate_mesh, result["position"])
					
				
			if temp_geometry=="Circle":
				var mousePos = get_viewport().get_mouse_position()
				var raylength = 1000
				var from = $Camera3D.project_ray_origin(mousePos) 
				var to = from + $Camera3D.project_ray_normal(mousePos) * raylength
				var space = get_world_3d().direct_space_state
				var rayQuery = PhysicsRayQueryParameters3D.new()
				rayQuery.from = from
				rayQuery.to = to 
				rayQuery.collide_with_areas = true
				var result = space.intersect_ray(rayQuery)
				#print(result)
				if result!={}: 
					draw_temp_circle( temp_mesh, temp_immediate_mesh, result["position"])
		"enact_temp_geometry":
			if curr_state!=prev_state:
				pass
#each "shape" should be a dictionary that has all the info 
#info like the shapes meshinstance 3d its immediate mesh and its location points we will need all this for export as an svg

func draw_shape_circle(circle_mesh:MeshInstance3D,immediate_circle_mesh:ImmediateMesh, center:Vector3):
	temp_material.albedo_color=Color(0.0,0.0,1.0)
	circle_mesh.mesh=immediate_circle_mesh
	immediate_circle_mesh.clear_surfaces()  # Clear any existing geometry
	immediate_circle_mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP, temp_material)
	# Calculate points around the circle
	var circle_shape=[]
	for i in range(temp_circle_segments):
		var angle = 2.0 * PI * i / temp_circle_segments
		var x = center.x + temp_circle_radius * cos(angle)
		var z = center.z + temp_circle_radius * sin(angle)
		var y = center.y # Use the center's y-coordinate
		circle_shape.append(Vector3(x, 0.2, z))
		immediate_circle_mesh.surface_add_vertex(Vector3(x, 0.2, z))
	print("This is the shape:", circle_shape)
	immediate_circle_mesh.surface_add_vertex(circle_shape[0])
	immediate_circle_mesh.surface_end()

func draw_temp_circle(circle_mesh:MeshInstance3D,immediate_circle_mesh:ImmediateMesh, center:Vector3):
	temp_material.albedo_color=Color(0.0,0.0,1.0)
	circle_mesh.mesh=immediate_circle_mesh
	immediate_circle_mesh.clear_surfaces()  # Clear any existing geometry
	immediate_circle_mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP, temp_material)
	# Calculate points around the circle
	var circle_shape=[]
	for i in range(temp_circle_segments):
		var angle = 2.0 * PI * i / temp_circle_segments
		var x = center.x + temp_circle_radius * cos(angle)
		var z = center.z + temp_circle_radius * sin(angle)
		var y = center.y # Use the center's y-coordinate
		circle_shape.append(Vector3(x, 0.2, z))
		immediate_circle_mesh.surface_add_vertex(Vector3(x, 0.2, z))
	print("This is the shape:", circle_shape)
	immediate_circle_mesh.surface_add_vertex(circle_shape[0])
	immediate_circle_mesh.surface_end()

func _on_machine_menu_pressed() -> void:
	$Camera3D/Control/MachineMenu.visible=true
	$Camera3D/Control/FileMenu.visible=false
	$Camera3D/Control/ShapesMenu.visible=false

func _on_shape_menu_pressed() -> void:
	$Camera3D/Control/MachineMenu.visible=false
	$Camera3D/Control/FileMenu.visible=false
	$Camera3D/Control/ShapesMenu.visible=true

func _on_file_menu_pressed() -> void:
	$Camera3D/Control/MachineMenu.visible=false
	$Camera3D/Control/FileMenu.visible=true
	$Camera3D/Control/ShapesMenu.visible=false

@onready var temp_circle_segments:int=32
@onready var temp_circle_radius:float=0.2

func _on_radius_slider_drag_ended(value_changed: bool) -> void:
	$Camera3D/Control/VBoxContainer2/Control/Radius.text= "Radius: "+str($Camera3D/Control/VBoxContainer2/Control/RadiusSlider.value)
	temp_circle_radius=$Camera3D/Control/VBoxContainer2/Control/RadiusSlider.value

func _on_segment_slider_drag_ended(value_changed: bool) -> void:
	$Camera3D/Control/VBoxContainer2/Control/Segments.text= "Segments: "+str($Camera3D/Control/VBoxContainer2/Control/SegmentSlider.value)
	temp_circle_segments=$Camera3D/Control/VBoxContainer2/Control/SegmentSlider.value
