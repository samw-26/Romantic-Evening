class_name Couple
extends CharacterBody2D

var center: int = 722
var row_diff: int = 80
var off_screen: int = 960
var speed: int = 200

#Booleans
var at_table: bool = false
var ready_to_order: bool = false
var has_ordered: bool = false
var order1_received: bool = false
var order2_received: bool = false
var hunger_started: bool = false
var unsatisfied: bool = false
var freed_table: bool = false

#Find table
var table: Node2D
var table_destination: Vector2
var direction: Vector2 = Vector2.ZERO

#Ordering
var order_options: Array = ["Steak","Spaghetti","Salad"]
var man_order: String
var woman_order: String
var man_food: Sprite2D
var woman_food: Sprite2D

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
	table = Global.request_table()
	table_destination = table.position
	
	#Choose orders
	man_order = order_options.pick_random()
	woman_order = order_options.pick_random()
	
	#Food node
	man_food = get_node("%ManOrder/"+man_order)
	woman_food = get_node("%WomanOrder/"+woman_order)

func _process(_delta: float) -> void:
	#Go to table
	if(!at_table and !unsatisfied):
		go_to_table()
	#Dining
	if(at_table):
		#Ordering, wait for customers to decide
		if !ready_to_order:
			await get_tree().create_timer(2).timeout
			ready_to_order = true
		if !order1_received or !order2_received:
			order()
	#Unsatisfied customer(Exiting)
	if unsatisfied:
		exit_restaurant()

	#Movement
	velocity = direction * speed
	move_and_slide()

#Go to table
func go_to_table() -> void:
	if(global_position.y > table_destination.y + row_diff):
		direction = Vector2.UP
	elif(abs(global_position.x - table_destination.x) > 5):
		if(global_position.x > table_destination.x + 5):
			direction = Vector2.LEFT
		else:
			direction = Vector2.RIGHT
	elif(global_position.y > table_destination.y + 15):
			direction = Vector2.UP
	else:
		direction = Vector2.ZERO
		at_table = true

#Exit Restaurant
func exit_restaurant() -> void:
	if(!freed_table):
		Global.available_chairs.append(table)
		%ManOrder.hide()
		%WomanOrder.hide()
		freed_table = true
	if (global_position.y < table_destination.y + row_diff):
		direction = Vector2.DOWN
	elif abs(global_position.x - center) > 2:
		if global_position.x < center:
			direction = Vector2.RIGHT
		elif global_position.x > center:
			direction = Vector2.LEFT
	elif abs(global_position.y - off_screen) > 5:
		direction = Vector2.DOWN
	else:
		Global.couple_count -= 1
		queue_free()
#Ordering
func order() -> void:
	#Start getting hungy
	if !hunger_started:
		%HungerTimer.start()
		hunger_started = true
	#Man
	if !order1_received:
		%ManOrder.show()
	else:
		%ManOrder.hide()
	#Woman
	if !order2_received:
		%WomanOrder.show()
	else:
		%WomanOrder.hide()

#Take Order
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Waiter:
		body = body as Waiter
		if !has_ordered and ready_to_order:
			has_ordered = true
			%ManOrder/Question.hide()
			%WomanOrder/Question.hide()
			man_food.show()
			woman_food.show()
			Global.take_order(man_order,woman_order)
		elif has_ordered:
			if !order1_received:
				order1_received = body.serve_food(man_order)
			if !order2_received:
				order2_received = body.serve_food(woman_order)


func _on_hunger_timer_timeout() -> void:
	%ExitTimer.start()
	if !order1_received and !order2_received:
		%FlickerTimerMan.start()
		%FlickerTimerWoman.start()
	elif !order1_received:
		%FlickerTimerMan.start()
	elif !order2_received:
		%FlickerTimerWoman.start()

func _on_flicker_timer_man_timeout() -> void:
	var question = %ManOrder/Question
	if !has_ordered:
		question.visible = !question.visible
	elif has_ordered and !order1_received:
		man_food.visible = !man_food.visible
	else:
		%FlickerTimerMan.stop()

func _on_flicker_timer_woman_timeout() -> void:
	var question = %WomanOrder/Question
	if !has_ordered:
		question.visible = !question.visible
	elif has_ordered and !order2_received:
		woman_food.visible = !woman_food.visible
	else:
		%FlickerTimerWoman.stop()

#Exit when unsatisfied
func _on_exit_timer_timeout() -> void:
	unsatisfied = true
	$Area2D.monitoring = false
	at_table = false
