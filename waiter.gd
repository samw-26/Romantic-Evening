class_name Waiter
extends CharacterBody2D

#Carrying food
var food_carried: Array
var carrying: int = 0
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
	carrying += 1

func serve_food():
	if carrying > 0:
		carrying -= 1

