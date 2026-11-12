extends Node3D

const CHARACTER_MODEL = preload("res://assets/characters/quaternius_superhero_male.glb")

var body_material: StandardMaterial3D
var eye_materials: Array[StandardMaterial3D] = []

func _ready() -> void:
	var model := CHARACTER_MODEL.instantiate()
	model.name = "QuaterniusDealerModel"
	add_child(model)

	body_material = StandardMaterial3D.new()
	body_material.albedo_color = Color(0.045, 0.052, 0.065)
	body_material.roughness = 0.82
	body_material.metallic = 0.12
	for node in model.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := node as MeshInstance3D
		mesh_instance.material_override = body_material

	_add_eye(Vector3(-0.034, 1.715, 0.105))
	_add_eye(Vector3(0.034, 1.715, 0.105))
	set_personality("NIGHT_DEALER")

func set_personality(profile_id: String) -> void:
	if body_material == null:
		return
	var eye_color := Color(0.72, 0.025, 0.035)
	var eye_emission := Color(0.65, 0.015, 0.025)
	match profile_id:
		"COLLECTOR":
			body_material.albedo_color = Color(0.035, 0.095, 0.085)
			body_material.metallic = 0.3
			eye_color = Color(0.04, 0.82, 0.62)
			eye_emission = Color(0.02, 0.75, 0.52)
		"HOUSE":
			body_material.albedo_color = Color(0.12, 0.085, 0.025)
			body_material.metallic = 0.58
			eye_color = Color(1.0, 0.68, 0.12)
			eye_emission = Color(1.0, 0.48, 0.06)
		_:
			body_material.albedo_color = Color(0.045, 0.052, 0.065)
			body_material.metallic = 0.12
			eye_color = Color(0.72, 0.025, 0.035)
			eye_emission = Color(0.65, 0.015, 0.025)
	for material in eye_materials:
		material.albedo_color = eye_color
		material.emission = eye_emission

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
	eye_materials.append(glow)
	add_child(eye)
