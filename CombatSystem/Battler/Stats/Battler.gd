extends Node2D
class_name Battler

# Resource that manages both the base and final stats for this battler.
@export var stats:= BattlerStats.new()
# If the battler has an `ai_scene`, we will instantiate it and let the AI make decisions.
# If not, the player controls this battler. The system should allow for ally AIs.
@export var ai_scene: PackedScene
# Each action's data stored in this array represents an action the battler can perform.
# These can be anything: attacks, healing spells, etc.
@export var actions: Array

@export var is_party_member: bool = false

@export var ui_data: Resource

@onready var battler_anim: BattlerAnim = $BattlerAnim



# Create status effect container
var _status_effect_container := StatusEffectContainer.new()

# store last incoming action
var last_incoming_action: Action = null

# The turn queue will change this property when another battler is acting.
var time_scale := 1.0:
	set = set_time_scale
# When this value reaches `100.0`, the battler is ready to take their turn.
var _readiness := 0.0:
	set = _set_readiness
	
var is_active: bool = true:
	set = set_is_active
	
# If `true`, the battler is selected, which makes it move forward.
var is_selected: bool = false:
	set = set_is_selected
# If `false`, the battler cannot be targeted by any action.
var is_selectable: bool = true:
	set = set_is_selectable
	
var _ai_instance: BattlerAI = null

# Create status effect container
	
signal ready_to_act(battler)
signal readiness_changed(new_value)
signal selection_toggled(value)
signal damage_taken(amount)
signal hit_missed
signal hit_taken(hit)
signal action_finished
signal animation_finished(anim_name)

@onready var animation_player: AnimationPlayer = $BattlerAnim/Pivot/AnimationPlayer

# Allows the AI brain to get a reference to all battlers on the field.
func setup(battlers: Array) -> void:
	animation_player.animation_finished.connect(func _on_animation_finished(anim_name):
		animation_finished.emit(anim_name)
		)
	if ai_scene:
		# We instance the `ai_scene` and store a reference to it.
		_ai_instance = ai_scene.instantiate()
		# `BattlerAI.setup()` takes the actor and all battlers in the encounter.
		_ai_instance.setup(self, battlers)
		# Adding the instance as a child to trigger its `_ready()` callback.
		add_child(_ai_instance)

# Returns the `BattlerAI` instance attached to this battler.
# We wrap it in a method because our property is pseudo-private: we want it to be read-only.
func get_ai() -> Node:
	return _ai_instance

func _process(delta: float) -> void:
	var speed_stat := stats.get_stat("speed")
	# Increments the `_readiness`. 
	_set_readiness(_readiness + speed_stat  * delta * time_scale)
	

# We will later need to propagate the time scale to status effects, which is why we use a
# setter function.
func set_time_scale(value) -> void:
	time_scale = value
	_status_effect_container.time_scale = time_scale


func get_status_effects() -> Array:
	return _status_effect_container.get_active_effects()


# Setter for the `_readiness` variable. Emits signals when the value changes and when the battler
# is ready to act.
func _set_readiness(value: float) -> void:
	_readiness = value
	readiness_changed.emit(_readiness)

	if _readiness >= 100.0:
		ready_to_act.emit()
		#print("ready to act")
		# When the battler is ready to act, we pause the process loop. Doing so prevents _process from triggering another call to this function.
		set_process(false)
		
		
func set_is_active(value) -> void:
	is_active = value
	set_process(is_active)
	_status_effect_container.is_active = value

	
func set_is_selected(value) -> void:
	# This defensive check helps us ensure we don't attempt to change `is_selected` if the battler isn't selectable.
	if value:
		assert(is_selectable)

	is_selected = value
	if is_selected:
		battler_anim.move_forward()
	selection_toggled.emit(is_selected)


func set_is_selectable(value) -> void:
	is_selectable = value
	if not is_selectable:
		set_is_selected(false)
		
# Returns `true` if the battler is controlled by the player.
func is_player_controlled() -> bool:
	print("battler: ", get_parent(), " ai_scene", self.ai_scene)
	return self.ai_scene == null
	
# We connect to the stats' `health_depleted` signal to react to the health reaching `0`.
func _ready() -> void:
	assert(stats is BattlerStats)
	stats = stats.duplicate()
	stats.initialize()
	stats.stat_changed.connect(_on_stat_changed)
	stats.health_depleted.connect(_on_BattlerStats_health_depleted)
	add_child(_status_effect_container)
	_status_effect_container.name = "_status_effect_container"
	_status_effect_container.status_effect_added.connect(_on_status_effect_added)
	_status_effect_container.status_effect_removed.connect(_on_status_effect_removed)
	var reactions = Reactions.new()
	reactions.name = "Reactions"
	reactions.setup(self)
	add_child(reactions)
	
func react_to(element: String) -> void:
	var reactions_node = get_node_or_null("Reactions")
	if reactions_node:
		reactions_node.on_reacted_to(element)
	else:
		push_warning("⚠️ Reactions node not found on %s" % name)


	
func add_status_effect(effect: StatusEffect) -> void:
	_status_effect_container.add(effect)

func remove_status_effect(effect: StatusEffect) -> void:
	_status_effect_container.remove_type(effect.id)

func _on_status_effect_added(effect: StatusEffect) -> void:
	# Additional logic if needed
	pass

func _on_status_effect_removed(effect: StatusEffect) -> void:
	# Additional logic if needed
	pass



func _on_stat_changed(stat: String, old_value: float, new_value: float) -> void:
	#print("%s changed from %f to %f" % [stat, old_value, new_value])
	pass

	
	
func _on_BattlerStats_health_depleted() -> void:
	# When the health depletes, we turn off processing for this battler.
	set_is_active(false)
	# Then, if it's an opponent, we mark it as unselectable. For party members,
	# you still want to be able to select them to revive them.
	if not is_party_member:
		set_is_selectable(false)
		battler_anim.queue_animation("die")

func get_battler_anim() -> BattlerAnim:
	return battler_anim

# Applies a hit object to the battler, dealing damage or status effects.
func take_hit(hit: Hit, action: Action) -> void:
	print("🔻 take_hit() called. Hit damage:", hit.damage, "Target:", name)
	# Store the action that caused the hit
	#receive_action(action)
	hit_taken.emit(hit, action)
	
	if action.is_reflected:
		print("Original hit blocked due to reflection.")
		return
	print("battler_anim instance id:", battler_anim.get_instance_id())
	print("block_damage_animation?", battler_anim.block_damage_animation)

	
	# We encapsulated the hit chance in the hit. The hit object tells us if
	# we should take damage.
	if hit.does_hit():
		print("✔️ Hit landed. Applying damage:", hit.damage)
		
		# Only apply damage and show label if its non-zero
		if hit.damage != 0:
			_take_damage(hit.damage)
			damage_taken.emit(hit.damage)
			print("💥 Showing damage label for %s amount: %d" % [name, hit.damage])
		else:
			print("🟡 No damage dealt — skipping damage label")

		
		damage_taken.emit(hit.damage)
		if hit.effect:
			if is_instance_valid(hit.effect):
				print("Preparing to apply effect: %s" % [hit.effect])
				_apply_status_effect(hit.effect)
			else:
				print("Effect is invalid and cannot be applied.")
		else:
			print("No effect to apply.")
	else:
		hit_missed.emit()
		
# This function applies the status effect to the battler.
# Effect is of type `StatusEffect`.
func _apply_status_effect(effect: StatusEffect) -> void:
	if effect == null:
		push_error("Attempted to apply a null status effect")
		return
	if not is_instance_valid(effect):
		push_error("Attempted to apply an invalid status effect")
		return
	_status_effect_container.add(effect)
	print("Applying effect %s to %s" % [effect.id, name])

func has_status_effect(effect_id: String) -> bool:
	if _status_effect_container:
		for effect in _status_effect_container.get_children():
			if effect.id == effect_id:
				return true
	return false


# Applies damage to the battler's stats.
# Later, it should also trigger a damage animation.
func _take_damage(amount: int) -> void:
	print("Incoming amount to _take_damage:", amount)
	print("📉", name, "HP before:", stats.health, "Taking:", amount)
	if amount < 0:
		var heal_amount = abs(amount)
		stats.health = min(stats.health + heal_amount, stats.max_health)
		print(name, "healed", heal_amount, "HP")
		battler_anim.play("heal")
	else:
		stats.health -= amount
		print(name, "took", amount, "damage")
		if stats.health > 0:
			if not battler_anim.block_damage_animation:
				battler_anim.play("damage")
				print("🔥 Called _take_damage — block:", battler_anim.block_damage_animation)

		else:
			print("⚡ Suppressing 'damage' animation due to lightning")


	print("New health for", name, ":", stats.health)
		
	# 🔥 Emit damage_taken only if it's non-zero
	if amount != 0:
		damage_taken.emit(amount)
	

# We can't specify the `action`'s type hint here due to cyclic dependency errors
# in Godot 3.2.
# But it should be of type `Action` or derived, like `AttackAction`.
func act(action) -> void:
	# If the action costs energy, we subtract it.
	stats.energy -= action.get_energy_cost()
	# We wait for the action to apply. It's a coroutine, that is to say, an
	# asynchronous function, so we need to use yield.
	# The "completed" function signal is built-in, more on that below.
	await action.apply_async()
	battler_anim.move_back()

	# We reset the `_readiness`. The value can be greater than zero, depending
	# on the action.
	_set_readiness(action.get_readiness_saved())
	# We shouldn't set process back to `true` if the battler isn't active, so its readiness doesn't update.
	# That can be the case if we code a "stop" or "petrify" status effect, or
	# during an animation that interrupts the normal flow of battle.
	if is_active:
		set_process(true)
	# We emit our new signal, indicating the end of a turn for a
	# player-controlled character.
	action_finished.emit()

func is_fallen() -> bool:
	return stats.health == 0
	
func receive_action(action: Action) -> void:
	last_incoming_action = action
	
	
