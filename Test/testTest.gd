extends Node3D

func _ready() -> void:
	do_it()
const ICON = preload("uid://dnrx8ktupoxb8")
@onready var collision_shape_3d: CollisionShape3D = $StaticBody3D/CollisionShape3D
@onready var mesh_instance_3d: MeshInstance3D = $StaticBody3D/MeshInstance3D
const PORTAL_RED_MATERIAL = preload("uid://di7k1hu1ix4gf")

func do_it():
	var mesh:ArrayMesh = mesh_instance_3d.mesh as ArrayMesh
	var heightmap_image:Image = ICON.get_image()
	heightmap_image.decompress()
	heightmap_image.convert(Image.FORMAT_RF)

	var height_min = 0.0
	var height_max = 10.0
	var shape:HeightMapShape3D = collision_shape_3d.shape as HeightMapShape3D
	shape.update_map_data_from_image(heightmap_image, height_min, height_max)
	var float32array:PackedFloat32Array = shape.map_data
	var v_three_array:PackedVector3Array
	
	#mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, [v_three_array])
	
	var vertices = PackedVector3Array()
	vertices.push_back(Vector3(0, 5, 0))
	vertices.push_back(Vector3(5, 0, 0))
	vertices.push_back(Vector3(0, 0, 5))
	vertices.push_back(Vector3(0, 0, 10))
	vertices.push_back(Vector3(0, 10, 0))
	vertices.push_back(Vector3(10, 0, 0))
	

	# Initialize the ArrayMesh.
	var arr_mesh = ArrayMesh.new()
	var arrays:Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	
	for j in shape.map_depth:
		for i in shape.map_width:
			if i == shape.map_width - 1: continue # Skip Right Col
			if j == shape.map_depth - 1: continue # SKip last row
			v_three_array.push_back(Vector3(j,float32array[i+j*shape.map_width],i))
			v_three_array.push_back(Vector3(j,float32array[(i+1)+j*shape.map_width],i+1))
			v_three_array.push_back(Vector3(j+1,float32array[i+((j+1)*shape.map_width)],i))
			v_three_array.push_back(Vector3(j+1,float32array[i+((j+1)*shape.map_width)],i))
			v_three_array.push_back(Vector3(j,float32array[(i+1)+j*shape.map_width],i+1))
			v_three_array.push_back(Vector3(j+1,float32array[(i+1)+((j+1)*shape.map_width)],i+1))
	
	
	arrays[Mesh.ARRAY_VERTEX] = v_three_array
	# Create the Mesh.
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh_instance_3d.mesh = arr_mesh
	mesh_instance_3d.mesh.surface_set_material(0,PORTAL_RED_MATERIAL)
