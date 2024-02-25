extends Control

func _ready() -> void:
	show_main_screen()


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scenes/restaurant.tscn")

func _on_tutorial_pressed() -> void:
	pass # Replace with function body.

func _on_options_pressed() -> void:
	%MainContainer.hide()
	%OptionsContainer.show()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_back_pressed() -> void:
	show_main_screen()
	
func show_main_screen() -> void:
	%MainContainer.show()
	%OptionsContainer.hide()
