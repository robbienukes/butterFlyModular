class_name RevolverAction
extends Action

# We calculate and store hits in an array to consume later, in sync with the animation.
var _hits := []
var _key_timer: Timer
var _is_listening_for_key: bool = false
var _key_press_count: int = 0

# We must override the constructor to use it.
# Notice how _init() uses a unique notation to call the parent's constructor.
func _init(data: AttackActionData, actor, targets: Array) -> void:
	super._init(data, actor, targets)
	_key_timer = Timer.new()
	_key_timer.set_wait_time(5.0)  # Set the desired time window for key presses
	_key_timer.timeout.connect(_on_key_timer_timeout)
	_actor.add_child(_key_timer)

# Returns the damage dealt by this action. We will update this function
# when we implement status effects.
func calculate_potential_damage_for(target) -> int:
	return Formulas.calculate_base_damage(_data, _actor, target)

func apply_async() -> bool:
	_is_listening_for_key = true
	_key_press_count = 0
	_key_timer.start()
	_actor.connect("input_event", self, "_on_input_event")
	await _key_timer.timeout
	return true

func _on_input_event(event: InputEvent) -> void:
	if _is_listening_for_key and event is InputEventKey and event.pressed and event.scancode == KEY_S:
		_key_press_count += 1
		var anim = _actor.battler_anim
		for target in _targets:
			var hit_chance = Formulas.calculate_hit_chance(_data, _actor, target)
			var damage = calculate_potential_damage_for(target)
			var status: StatusEffect = StatusEffectBuilder.create_status_effect(
				target, _data.status_effect
			)
			
			var hit = Hit.new(damage, hit_chance, status)
			
			var callable = Callable(self, "_on_BattlerAnim_triggered").bind(target, hit)
			anim.connect("triggered", callable)
			
			anim.play("attack")
			await _actor.animation_finished.completed
			target.take_hit(hit)

func _on_BattlerAnim_triggered(target, hit: Hit) -> void:
	target.take_hit(hit)

func _on_key_timer_timeout() -> void:
	_is_listening_for_key = false
	_actor.disconnect("input_event", self, "_on_input_event")
	emit_signal("finished")
