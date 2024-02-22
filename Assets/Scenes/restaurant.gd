extends Node2D

var couple_scene: PackedScene = preload("res://Assets/Scenes/couple.tscn")

func _ready() -> void:
	Global.chairs = get_tree().get_nodes_in_group("chair")
	Global.plates = get_tree().get_nodes_in_group("plates")
	for i in range(0,Global.chairs.size()/2):
		Global.available_chairs.append(Global.chairs[i*2])
	await get_tree().create_timer(2).timeout #Wait before starting spawning
	spawn_couple()
	$SpawnTimer.start()
	Global.waiter = %Waiter
	Global.tip_label = %Tips
	Global.quota_label = %Quota
	Global.game_started = true

func _on_spawn_timer_timeout() -> void:
	if Global.couple_count < Global.max_couples:
		spawn_couple()

func spawn_couple() -> void:
	var couple = couple_scene.instantiate()
	couple.global_position = $SpawnPoint.global_position
	$Couples.add_child(couple)
	Global.couple_count += 1
