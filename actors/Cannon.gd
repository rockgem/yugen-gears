extends Node2D



func shoot():
	Sfx.play_sound('Shoot')
	
	$AnimationPlayer.play("fire")
	
	var bullet = load("res://actors/Bullet.tscn").instantiate()
	bullet.direction = global_position.direction_to($Node2D.global_position)
	
	ManagerGame.main_ref.spawn_obj(bullet, global_position)
