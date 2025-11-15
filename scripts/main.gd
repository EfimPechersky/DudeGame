extends Node2D


@onready var boxanim=get_node("Box/BoxBody/AnimationPlayer")
@onready var blob = get_node("KillableBlob")
@onready var hud = get_node("HUD")
@onready var audio:AudioStreamPlayer = get_node("AudioStreamPlayer")
@onready var menu = get_node("Menu")
#@onready var blob_anim = get_node("Blob/AnimationPlayer")

func _ready()->void:
	audio.stream=load("res://audio/background.ogg")
	audio.volume_db=linear_to_db(0.1)
	hud.update_health()
	audio.play()
	#blob_anim.play("appear_blob")
	#blob_anim.animation_finished.connect(_on_appear)
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if menu.visible:
			Globals.resume()
			menu.hide()
		else:
			Globals.pause()
			menu.show()
func _on_appear(name):
	pass
	#if name == "appear_blob":
	#	blob_anim.play("explosion")


func _on_character_body_2d_bonk() -> void:
	boxanim.play("bonk")


func _on_character_body_2d_kill(blob: Variant) -> void:
	blob.death()
