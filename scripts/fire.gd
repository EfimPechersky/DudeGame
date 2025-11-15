extends Area2D


func _physics_process(delta: float) -> void:
	for body in get_overlapping_bodies():
		if body is CharacterBody2D:
			var nor=body.velocity.normalized()
			if nor == Vector2(0,0):
				nor = Vector2(1,1)
			nor.y=0
			body.velocity -= nor*1000
			body.damage()
