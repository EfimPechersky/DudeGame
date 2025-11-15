extends Node2D


@export var health_texture: Texture2D

func update_health():
	var container:HBoxContainer = get_node("Panel/HBoxContainer")
	if container:
		for child in container.get_children():
			child.queue_free()
	
		for i in Globals.max_health:
			var health = TextureRect.new()
			health.texture=health_texture
			health.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT
			container.add_child(health)
			
