extends StaticBody2D

var couple: Couple
var original_couple: Couple

func _ready() -> void:
	%DollarSign.hide()

func _process(_delta: float) -> void:
	if original_couple != null:
		if original_couple.give_tip and original_couple.tip > 0 and !original_couple.has_triggered_animation:
			%DollarSign.text = "$" + str(original_couple.tip)
			%AnimationPlayer.play("TipAnimation")
			original_couple.has_triggered_animation = true
	

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Couple:
		couple = body
		if original_couple == null:
			original_couple = couple

	

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == original_couple:
		original_couple = null
