extends Node3D

const CHARACTER_MODEL = preload("res://assets/characters/quaternius_superhero_male.glb")

func _ready() -> void:
	var model := CHARACTER_MODEL.instantiate()
	model.name = "QuaterniusDealerModel"
	add_child(model)

	var dark_material := StandardMaterial3D.new()
	dark_material.albedo_color = Color(0.045, 0.052, 0.065)
	dark_material.roughness = 0.82
	dark_material.metallic = 0.12
	for node in model.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := node as MeshInstance3D
		mesh_instance.material_override = dark_material

	_add_eye(Vector3(-0.034, 1.715, 0.105))
	_add_eye(Vector3(0.034, 1.715, 0.105))

func _add_eye(eye_position: Vector3) -> void:
	var eye := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.018
	sphere.height = 0.036
	eye.mesh = sphere
	eye.position = eye_position
	var glow := StandardMaterial3D.new()
	glow.albedo_color = Color(0.72, 0.025, 0.035)
	glow.emission_enabled = true
	glow.emission = Color(0.65, 0.015, 0.025)
	glow.emission_energy_multiplier = 1.4
	eye.material_override = glow
	add_child(eye)
