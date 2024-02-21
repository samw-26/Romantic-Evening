class_name Couple
extends CharacterBody2D

#Booleans
var at_table: bool = false
var has_ordered: bool = false
var received_food: bool = false

#Find table
var table_destination: Vector2
var direction: Vector2 = Vector2.ZERO
var speed: int = 500

#Ordering
var order_options: Array = ["Steak","Spaghetti","Salad"]
var man_order: String
var woman_order: String

#Moods
var moods: Array = ["Hungry", "Awkward", "Unromantic"]

func _ready() -> void:
	#Setup
	%ManOrder.hide()
	%ManOrder/Question.show()
	%WomanOrder.hide()
	%WomanOrder/Question.show()
	#Randomize woman
	var random_eye_color = [Color.BLUE,Color.DARK_GREEN,Color.SADDLE_BROWN,Color.BLACK].pick_random()
	var random_dress_color = [Color.BLUE,Color.DARK_VIOLET,Color.RED,Color.WEB_GREEN,Color.CORAL,Color.DARK_ORANGE,Color.DIM_GRAY,Color.WEB_PURPLE, Color.GRAY,Color.CRIMSON,Color.ORANGE,Color.ORANGE_RED].pick_random()
	%Dress.set_modulate(random_dress_color)
	%Eyes.set_modulate(random_eye_color)
	
	#Get random table
	table_destination = Restaurant.request_table()
	
	#Choose orders
	man_order = order_options.pick_random()
	woman_order = order_options.pick_random()

func _physics_process(_delta: float) -> void:
	#Go to table
	if(!at_table):
		if(global_position.y > table_destination.y + 10):
			direction = Vector2.UP
		elif(abs(global_position.x - table_destination.x) > 5):
			if(global_position.x > table_destination.x + 5):
				direction = Vector2.LEFT
			else:
				direction = Vector2.RIGHT
		else:
			direction = Vector2.ZERO
			at_table = true
	
	#Dining
	if(at_table):
		#Ordering, wait for customers to decide
		await get_tree().create_timer(2).timeout
		#Man
		%ManOrder.show()
		#Woman
		%WomanOrder.show()
		#Start hunger timer
		%HungerTimer.start()
		
		#Receiving Food
		
	
	#Movement
	velocity = direction * speed
	move_and_slide()

#Take Order
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Waiter and !has_ordered:
		has_ordered = true
		%ManOrder/Question.hide()
		%WomanOrder/Question.hide()
		get_node("%ManOrder/"+man_order).show()
		get_node("%WomanOrder/"+woman_order).show()
		Restaurant.take_order(man_order,woman_order)
	elif body is Waiter and has_ordered:
		pass
