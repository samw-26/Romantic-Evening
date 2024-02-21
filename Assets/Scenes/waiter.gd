class_name Waiter
extends CharacterBody2D

#Carrying food
var food_carried: Array[String]
var carry_capacity: int = 2

#Movement
var direction: Vector2
@export var speed: int = 300

func _process(_delta: float) -> void:
	direction = Input.get_vector("left","right","up","down")
	velocity = direction * speed
	move_and_slide()

func pick_up_food(food: String):
	food_carried.append(food)

func serve_food(order: String) -> bool:
	if food_carried.size() > 0:
		var index = 0
		for food in food_carried:
			if food == order:
				food_carried.pop_at(index)
				return true
			else:
				index += 1
				continue
	return false
