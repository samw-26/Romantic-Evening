extends StaticBody2D

var in_range: bool = false
var trash: Array[String]
var waiter: Waiter

func _ready():
	waiter = get_node("/root/Restaurant/%Waiter")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Waiter:
		in_range = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Waiter:
		in_range = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("trash"):
		var food = waiter.trash_food()
		if food != "":
			trash.append(food)

	elif event.is_action_pressed("take"):
		if waiter.carrying < waiter.carry_capacity and !trash.is_empty():
			waiter.pick_up_food(trash.pop_back())
