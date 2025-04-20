extends Action
class_name RevolverAction

# Uses existing inherited properties:
# - _data (ActionData)
# - _actor (Battler)
# - _targets (Array)

var _attack_data: AttackActionData

func _init(data: AttackActionData, actor, targets: Array) -> void:
	super._init(data, actor, targets)
	_attack_data = data

@export var input_action := "ui_accept"  # You can change this if needed

var _start_time := 0.0
var _firing := false
var _time_backup := 1.0

func apply_async() -> bool:
	print("Revolver action by", _actor.name)

	# Save original time scale and slow down
	_time_backup = Engine.time_scale
	Engine.time_scale = 0.2
	
	_attack_data = _data as AttackActionData

	_start_time = Time.get_ticks_msec() / 1000.0
	_firing = true
	set_process_input(true)

	# Optional actor animation
	if _actor.has_method("get_anim"):
		_actor.get_anim().play("attack")

	# Run for the duration of _data.readiness_saved (used as duration)
	while Time.get_ticks_msec() / 1000.0 - _start_time < _attack_data.readiness_saved:
		await get_tree().process_frame
		if not _firing:
			break

	# Clean up
	Engine.time_scale = _time_backup
	set_process_input(false)
	_firing = false
	emit_signal("finished")
	return true


func _input(event):
	if _firing and event.is_action_pressed(input_action):
		_fire_hit()


func _fire_hit():
	var target = _targets[0]
	if not target:
		return

	var status: StatusEffect = null
	if _attack_data.status_effect:
		status = StatusEffectBuilder.create_status_effect(target, _attack_data.status_effect)

	var hit := Hit.new(_attack_data.power, _attack_data.hit_chance, status, _actor)
	target.take_hit(hit, self)

	# 🔥 Force visuals + signal
	target.damage_taken.emit(_attack_data.power)
	target.battler_anim.play("damage")

	print("🎯 Hit delivered to:", target.name)
	print("💥 Revolver damage being applied:", _attack_data.power)

