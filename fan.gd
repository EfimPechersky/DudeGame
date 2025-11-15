extends StaticBody2D

@onready var anim = get_node("AnimationPlayer")
@onready var flow = get_node("Flow/CollisionShape2D")
@onready var particles:GPUParticles2D = get_node("GPUParticles2D")
@onready var audio:AudioStreamPlayer2D = get_node("FanPlayer")
func _ready()->void:
	turn_off()
	audio.volume_db=linear_to_db(10)
	
func turn_on():
	anim.play("work")
	audio.play()
	flow.disabled=false
	particles.emitting=true
	
	

func turn_off():
	anim.play("idle")
	audio.stop()
	flow.disabled=true
	particles.emitting=false
	
