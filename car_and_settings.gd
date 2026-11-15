extends VehicleBody3D

@export var max_steer = 0.45
@export var base_engine_power = 350.0
@export var brake_power = 12.0

@onready var models = $CarModels.get_children()
@onready var camera = $CameraPivot/Camera3D
var current_model_index = 0

# Settings variables
var max_accel_setting = 1.0  # Multiplier from settings
var drift_mode_enabled = true
var master_volume = 1.0      # Sound slider value (0.0 to 1.0)
var camera_view_mode = 1     # 1: Chase (External), 2: Driver Cockpit (Inside), 3: Hood / Bumper Cam

# Touch input flags
var touch_steer = 0.0
var touch_gas = 0.0
var touch_brake = 0.0

func _ready():
	update_car_model()
	update_camera_position()

func _physics_process(delta):
	var gas_input = Input.get_action_strength("ui_up") + touch_gas
	var brake_input = Input.get_action_strength("ui_down") + touch_brake
	var steer_input = Input.get_axis("ui_right", "ui_left") + touch_steer

	steering = move_toward(steering, clamp(steer_input, -1.0, 1.0) * max_steer, delta * 3.5)
	
	# Apply max acceleration setting multiplier
	engine_force = clamp(gas_input, 0.0, 1.0) * base_engine_power * max_accel_setting
	brake = clamp(brake_input, 0.0, 1.0) * brake_power

	# Handle drift toggle physics modification (reduce rear tire friction if drift enabled)
	if drift_mode_enabled:
		# Arcade drift feel boost
		center_of_mass_mode = VehicleBody3D.CENTER_OF_MASS_MODE_AUTO
	else:
		center_of_mass_mode = VehicleBody3D.CENTER_OF_MASS_MODE_CUSTOM

func swap_to_next_car():
	current_model_index = (current_model_index + 1) % models.size()
	update_car_model()

func update_car_model():
	for i in range(models.size()):
		models[i].visible = (i == current_model_index)
	
	match current_model_index:
		0: base_engine_power = 420.0
		1: base_engine_power = 460.0
		2: base_engine_power = 550.0
		3: base_engine_power = 400.0
		4: base_engine_power = 440.0

func cycle_camera_view():
	camera_view_mode = (camera_view_mode % 3) + 1
	update_camera_position()

func update_camera_position():
	match camera_view_mode:
		1: # External Chase View
			camera.position = Vector3(0.0, 3.5, -6.0)
			camera.rotation_degrees = Vector3(-15.0, 0.0, 0.0)
		2: # Inside Driver Cockpit View
			camera.position = Vector3(0.0, 1.2, 0.3)
			camera.rotation_degrees = Vector3(-5.0, 0.0, 0.0)
		3: # Hood / Bumper View
			camera.position = Vector3(0.0, 0.8, 1.5)
			camera.rotation_degrees = Vector3(-2.0, 0.0, 0.0)

# Settings update hooks triggered from UI sliders/toggles
func set_max_acceleration(val: float):
	max_accel_setting = val

func set_drift_toggle(enabled: bool):
	drift_mode_enabled = enabled

func set_sound_volume(val: float):
	master_volume = val
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_volume))
