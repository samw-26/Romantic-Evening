extends StaticBody2D

var in_range: bool = false
var trash: Array[String]
var waiter: Waiter

func _ready():
	waiter = get_node("/root/Restaurant/%Waiter")
	
func _process(_delta: float) -> void:
	if !trash.is_empty() and !Global.extra_food.is_empty():
		for t in trash:
			if Global.extra_food.has(t):
				Global.extra_food.pop_at(Global.extra_food.find(t))

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Waiter:
		in_range = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Waiter:
		in_range = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("trash") and in_range:
		var food = waiter.trash_food()
		if food != "":
			trash.append(food)
			

	elif event.is_action_pressed("take") and in_range:
		if waiter.carrying < waiter.carry_capacity and !trash.is_empty():
			waiter.pick_up_food(trash.pop_back())
