class_name Waiter
extends CharacterBody2D

#Carrying food
var carrying: int = 0
var food_carrying: Dictionary = {"Left":"", "Right":""}
var carry_capacity: int = 2
var first_plate: Sprite2D
var second_plate: Sprite2D
#Movement
var direction: Vector2
@export var speed: int = 300

func _ready() -> void:
	%Plate1.hide()
	%Plate2.hide()

func _process(_delta: float) -> void:
	if !Global.closing:
		direction = Input.get_vector("left","right","up","down")
		velocity = direction * speed
		move_and_slide()

func pick_up_food(food: String):
	if food_carrying["Left"].is_empty():
		food_carrying["Left"] = food
		carrying += 1
		%Plate1.show()
		get_node("%Plate1/"+food).show()
	else:
		food_carrying["Right"] = food
		carrying += 1
		%Plate2.show()
		get_node("%Plate2/"+food).show()

func trash_food() -> String:
	var food = ""
	if food_carrying["Right"] != "":
		food = food_carrying["Right"]
		food_carrying["Right"] = ""
		carrying -= 1
		get_node("%Plate2/"+food).hide()
		%Plate2.hide()
	elif food_carrying["Left"] != "":
		food = food_carrying["Left"]
		food_carrying["Left"] = ""
		carrying -= 1
		get_node("%Plate1/"+food).hide()
		%Plate1.hide()
	return food

func serve_food(order: String) -> bool:
	if carrying > 0:
		if food_carrying["Left"] == order:
			var food = food_carrying["Left"]
			food_carrying["Left"] = ""
			carrying -= 1
			get_node("%Plate1/"+food).hide()
			%Plate1.hide()
			return true
		elif food_carrying["Right"] == order:
			var food = food_carrying["Right"]
			food_carrying["Right"] = ""
			carrying -= 1
			get_node("%Plate2/"+food).hide()
			%Plate2.hide()
			return true
	return false
