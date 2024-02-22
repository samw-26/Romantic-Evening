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
var in_range: bool = false

#Find table
var table: Node2D
var table_destination: Vector2
var direction: Vector2 = Vector2.ZERO

#Ordering/Dining
var order_options: Array = ["Steak","Spaghetti","Salad"]
var man_order: String
var woman_order: String
var man_bubble: Sprite2D
var woman_bubble: Sprite2D
var man_question: Sprite2D
var woman_question: Sprite2D
var man_food: Sprite2D
var woman_food: Sprite2D

#Eating
var meal_timer: Timer
var eating: bool = false
var finished: bool = false

#Tip
var tip: int = 0
var give_tip: bool = false

#Moods
var moods: Array = ["Hungry", "Unromantic", "Bored", "Grumpy", "Awkward"]

func _ready() -> void:
	#Choose orders and set meal duration
	man_order = order_options.pick_random()
	woman_order = order_options.pick_random()
	meal_timer = %MealTimer as Timer
	#Nodes
	man_bubble = get_node("%ManOrder")
	man_question = %ManOrder/Question
	man_food = get_node("%ManOrder/"+man_order)
	woman_bubble = get_node("%WomanOrder")
	woman_question = %WomanOrder/Question
	woman_food = get_node("%WomanOrder/"+woman_order)
	#Setup
	man_bubble.hide()
	man_question.show()
	woman_bubble.hide()
	woman_question.show()

	#Randomize woman
	var random_eye_color = [Color.BLUE,Color.DARK_GREEN,Color.SADDLE_BROWN,Color.BLACK].pick_random()
	var random_dress_color = [Color.BLUE,Color.DARK_VIOLET,Color.RED,Color.WEB_GREEN,Color.CORAL,Color.DARK_ORANGE,Color.DIM_GRAY,Color.WEB_PURPLE, Color.GRAY,Color.CRIMSON,Color.ORANGE,Color.ORANGE_RED].pick_random()
	%Dress.set_modulate(random_dress_color)
	%Eyes.set_modulate(random_eye_color)
	
	#Get random table
	table = Global.request_table()
	table_destination = table.position
	


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
		elif ready_to_order and !eating:
			order()
		#Eating 
		elif eating:
			if meal_timer.is_stopped():
				meal_timer.start()
	#Finished
	if finished:
		exit_restaurant()

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

#Ordering
func order() -> void:
	#Start getting hungy
	if !hunger_started:
		%StatusTimer.start()
		hunger_started = true
	#Man and woman show question mark bubbles
	if !has_ordered and !man_bubble.visible and !woman_bubble.visible:
		man_bubble.show()
		woman_bubble.show()
	
	#Take order if in range
	if in_range:
		#Show food when in range and have not ordered
		if !has_ordered:
			has_ordered = true
			man_question.hide()
			woman_question.hide()
			man_food.show()
			woman_food.show()
			Global.take_order(man_order,woman_order)
		#Attempt to serve food if has ordered
		elif has_ordered:
			if !order1_received:
				order1_received = Global.waiter.serve_food(man_order)
				if order1_received:
					man_food.hide()
					man_bubble.hide()
			if !order2_received:
				order2_received = Global.waiter.serve_food(woman_order)
				if order2_received:
					woman_food.hide()
					woman_bubble.hide()

	#Stop timers, commence eating
	if order1_received and order2_received:
		eating = true
		tip += 10
		%StatusTimer.stop()
		%ExitTimer.stop()

#Exit Restaurant
func exit_restaurant() -> void:
	at_table = false
	if !give_tip:
		Global.tip += tip
		Global.tip_label.text = "Tips: $" + str(Global.tip)
		give_tip = true
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

#Take Order
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Waiter:
		in_range = true
		
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Waiter:
		in_range = false

func _on_status_timer_timeout() -> void:
	#Hunger status
	if !eating:
		if !order1_received or !order2_received:
			%ExitTimer.start()
		if !order1_received and !order2_received:
			%FlickerTimerMan.start()
			%FlickerTimerWoman.start()
		elif !order1_received:
			%FlickerTimerMan.start()
		elif !order2_received:
			%FlickerTimerWoman.start()

func _on_flicker_timer_man_timeout() -> void:
	#Hunger
	if !eating:
		if !has_ordered:
			man_question.visible = !man_question.visible
		elif has_ordered and !order1_received:
			man_food.visible = !man_food.visible
	#Next mood
	
	else:
		%FlickerTimerMan.stop()

func _on_flicker_timer_woman_timeout() -> void:
	#Hunger
	if !eating:
		if !has_ordered:
			woman_question.visible = !woman_question.visible
		elif has_ordered and !order2_received:
			woman_food.visible = !woman_food.visible
	#Next mood
	
	else:
		%FlickerTimerWoman.stop()

#Exit when unsatisfied
func _on_exit_timer_timeout() -> void:
	unsatisfied = true
	$Area2D.monitoring = false

func _on_meal_timer_timeout() -> void:
	finished = true
