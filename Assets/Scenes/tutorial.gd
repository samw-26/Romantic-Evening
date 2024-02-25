extends ColorRect

func _ready() -> void:
	hide()

func _on_back_pressed() -> void:
	hide()
	if Global.in_title:
		%MainContainer.show()
	else:
		%Pause.show()
