extends Node2D

var couple_scene: PackedScene = preload("res://Assets/Scenes/couple.tscn")

func _ready() -> void:
	#Volume
	
	#Setup
	%Closing.hide()
	%Quota.text = "Quota: $"+str(Global.quota)
	Global.chairs = get_tree().get_nodes_in_group("chair")
	Global.available_chairs = []
	Global.plates = get_tree().get_nodes_in_group("plates")
	for i in range(0,Global.chairs.size()/2):
		Global.available_chairs.append(Global.chairs[i*2])
	Global.waiter = %Waiter
	Global.tip_label = %Tips
	Global.quota_label = %Quota
	Global.clock_label = %ClockLabel
	Global.clock_timer = %Clock
	#End game nodes
	Global.closing_node = %Closing
	Global.quota_end = %QuotaResult
	Global.tip_end = %TipsResult
	Global.final_label = %FinalResult
	#Start game
	Global.game_started = true
	#Wait before starting spawning
	await get_tree().create_timer(5,false).timeout 
	spawn_couple()
	$SpawnTimer.start()

func _on_spawn_timer_timeout() -> void:
	if Global.couple_count < Global.max_couples:
		spawn_couple()

func spawn_couple() -> void:
	var couple = couple_scene.instantiate()
	couple.global_position = $SpawnPoint.global_position
	$Couples.add_child(couple)
	Global.couple_count += 1

#End day
func _on_clock_timeout() -> void:
	Global.closing = true
	Global.clock_label.text = "10:00pm"
	%SpawnTimer.stop()

func _on_play_again_pressed() -> void:
	if Global.tip >= Global.quota:
		Global.quota += 200
	Global.closing = false
	Global.in_menu = false
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	get_tree().quit()
