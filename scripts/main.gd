extends Node2D


@onready var boxanim=get_node("Box/BoxBody/AnimationPlayer")
@onready var blob = get_node("KillableBlob")
#@onready var blob_anim = get_node("Blob/AnimationPlayer")

func _ready()->void:
	pass
	#blob_anim.play("appear_blob")
	#blob_anim.animation_finished.connect(_on_appear)

func _on_appear(name):
	pass
	#if name == "appear_blob":
	#	blob_anim.play("explosion")


func _on_character_body_2d_bonk() -> void:
	boxanim.play("bonk")


func _on_character_body_2d_kill(blob: Variant) -> void:
	blob.death()
