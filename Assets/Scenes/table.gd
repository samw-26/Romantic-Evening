extends StaticBody2D

var couple: Couple
var original_couple: Couple
var animation_played: bool = false

func _ready() -> void:
	%DollarSign.hide()

func _process(_delta: float) -> void:
	if original_couple != null and !animation_played:
		if original_couple.give_tip and original_couple.tip > 0:
			%DollarSign.text = "$" + str(original_couple.tip)
			%AnimationPlayer.play("TipAnimation")
			animation_played = true
	elif original_couple == null:
		animation_played = false
	

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Couple:
		couple = body
		if original_couple == null:
			original_couple = couple

	

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == original_couple:
		original_couple = null
