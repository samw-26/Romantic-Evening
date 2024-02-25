extends Control

func _ready() -> void:
	hide()
	%PauseMenu.show()
	%SettingsMenu.hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and !Global.in_menu and !get_tree().paused:
		get_tree().paused = true
		show()
	elif event.is_action_pressed("pause") and !Global.in_menu and get_tree().paused:
		hide()
		%Tutorial.hide()
		get_tree().paused = false

func _on_settings_pressed() -> void:
	%PauseMenu.hide()
	%SettingsMenu.show()
	
func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_back_pressed() -> void:
	%SettingsMenu.hide()
	%PauseMenu.show()

func _on_tutorial_pressed() -> void:
	%Pause.hide()
	%Tutorial.show()
