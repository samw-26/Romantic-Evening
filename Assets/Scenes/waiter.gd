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
var last_direction: Vector2
@export var speed: int = 300
#Animation
var anim: AnimatedSprite2D

func _ready() -> void:
	anim = %AnimatedSprite2D
	%Left.hide()
	%Right.hide()

func _process(_delta: float) -> void:
	if !Global.closing:
		direction = Input.get_vector("left","right","up","down")
		#Animations
		Global.animate(anim,direction)
		if anim.animation == "walk_back":
			%Left.hide()
			%Right.hide()
		elif !food_carrying["Left"].is_empty():
			%Left.show()
		elif !food_carrying["Right"].is_empty():
			%Right.show()
		velocity = direction * speed
		move_and_slide()
	else:
		anim.play("idle")
func pick_up_food(food: String):
	if food_carrying["Left"].is_empty():
		food_carrying["Left"] = food
		carrying += 1
		%Left.show()
		if Global.no_plates.has(food):
			%Left/Plate.hide()
		else:
			%Left/Plate.show()
		get_node("%Left/"+food).show()
	else:
		food_carrying["Right"] = food
		carrying += 1
		%Right.show()
		if Global.no_plates.has(food):
			%Right/Plate.hide()
		else:
			%Right/Plate.show()
		get_node("%Right/"+food).show()

func trash_food() -> String:
	var food = ""
	if food_carrying["Right"] != "":
		food = food_carrying["Right"]
		food_carrying["Right"] = ""
		carrying -= 1
		get_node("%Right/"+food).hide()
		%Right.hide()
	elif food_carrying["Left"] != "":
		food = food_carrying["Left"]
		food_carrying["Left"] = ""
		carrying -= 1
		get_node("%Left/"+food).hide()
		%Left.hide()
	return food

func serve_food(order: String) -> bool:
	if carrying > 0:
		if food_carrying["Left"] == order:
			var food = food_carrying["Left"]
			food_carrying["Left"] = ""
			carrying -= 1
			get_node("%Left/"+food).hide()
			%Left.hide()
			return true
		elif food_carrying["Right"] == order:
			var food = food_carrying["Right"]
			food_carrying["Right"] = ""
			carrying -= 1
			get_node("%Right/"+food).hide()
			%Right.hide()
			return true
	return false
