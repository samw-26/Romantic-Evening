extends Control

func _ready() -> void:
	hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and !Global.in_menu and !get_tree().paused:
		get_tree().paused = true
		show()
	elif event.is_action_pressed("pause") and !Global.in_menu and get_tree().paused:
		hide()
		get_tree().paused = false

func _on_quit_pressed() -> void:
	get_tree().quit()
