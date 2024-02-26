class_name Table
extends StaticBody2D
## Controls dollar animation when customer leaves and also plate display

var couple: Couple
var original_couple: Couple

var current_foods: Array = [null,null]

func _ready() -> void:
	%DollarSign.hide()

func _process(_delta: float) -> void:
	if original_couple != null:
		if (
				original_couple.give_tip and original_couple.tip > 0
				and !original_couple.has_triggered_animation
			):
			play_tip_animation()
			original_couple.has_triggered_animation = true


## Plays tip animation
func play_tip_animation() -> void:
	%DollarSign.text = "$" + str(original_couple.tip)
	%AnimationPlayer.play("TipAnimation")


## Displays food on table based on couple order
func display_food(man_order: String, woman_order: String) -> void:
	if man_order != "":
		if !Global.no_plates.has(man_order):
			get_node("%ManFood/Plate").show()

		current_foods[0] = get_node("%ManFood/"+man_order)
		current_foods[0].show()
	
	if woman_order != "":
		if !Global.no_plates.has(woman_order):
			get_node("%WomanFood/Plate").show()

		current_foods[1] = get_node("%WomanFood/"+woman_order)
		current_foods[1].show()

## Hides food and plate
func hide_food() -> void:
	%ManFood/Plate.hide()
	if current_foods[0] != null:
		current_foods[0].hide()
	
	%WomanFood/Plate.hide()
	if current_foods[1] != null:
		current_foods[1].hide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Couple:
		couple = body
		if original_couple == null:
			original_couple = couple
			original_couple.current_table = self


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == original_couple:
		original_couple = null
