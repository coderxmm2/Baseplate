extends Control

@onready var car_node = get_node("../ActiveCar")
@onready var accel_slider = $Panel/VBoxContainer/AccelSlider
@onready var drift_toggle = $Panel/VBoxContainer/DriftToggle
@onready var sound_slider = $Panel/VBoxContainer/SoundSlider

func _on_accel_slider_value_changed(value):
	if car_node:
		car_node.set_max_acceleration(value)

func _on_drift_toggle_toggled(toggled_on):
	if car_node:
		car_node.set_drift_toggle(toggled_on)

func _on_sound_slider_value_changed(value):
	if car_node:
		car_node.set_sound_volume(value)
