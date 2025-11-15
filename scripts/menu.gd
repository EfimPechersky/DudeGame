extends Node2D

func resume():
	Globals.resume()
	hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if visible:
			resume()

func exit():
	get_tree().quit()

func _volume_changed(value:float):
	var bus = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_linear(bus, value)
