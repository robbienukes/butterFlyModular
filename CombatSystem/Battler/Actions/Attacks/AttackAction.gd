# Concrete class for damaging attacks. Inflicts zero or more direct damage to 
# one or more targets. It can also apply status effects.
class_name AttackAction
extends Action

# We calculate and store hits in an array to consume later, in sync with the
# animation.
var _hits := []


# We must override the constructor to use it.
# Notice how _init() uses a unique notation to call the parent's constructor.
func _init(data: AttackActionData, actor, targets: Array) -> void:
	print("AttackAction._init called with data:", data)
	super._init(data, actor, targets)
	_data = data
	pass


# Returns the damage dealt by this action. We will update this function
# when we implement status effects.
func calculate_potential_physical_damage_for(target) -> int:
	return Formulas.calculate_base_physical_damage(_data, _actor, target)

func calculate_potential_magical_damage_for(target) -> int:
	return Formulas.calculate_base_magical_damage(_data, _actor, target)
	

func apply_async() -> bool:
	print("apply_async called for action by:", _actor.name)

	var anim = _actor.battler_anim
	for target in _targets:
		print("Processing target:", target.name)

		var hit_chance = Formulas.calculate_hit_chance(_data, _actor, target)
		var damage: int = 0  # Default to zero

		# Handle healing (treated as negative damage)
		if _data.is_heal:
			damage = -abs(_data.power)

		# Handle damage only if flagged
		elif _data.does_damage:
			var physical_damage = calculate_potential_physical_damage_for(target)
			var magical_damage = calculate_potential_magical_damage_for(target)
			damage = physical_damage + magical_damage

		# Create status effect, if defined
		var status: StatusEffect = StatusEffectBuilder.create_status_effect(
			target, _data.status_effect
		)

		var hit = Hit.new(damage, hit_chance, status, _actor)

		print("Hitting ", target)
		target.take_hit(hit, self)

		# Animation control
		if _data.is_heal:
			anim.play("heal")
		elif _data.does_damage:
			anim.play("attack")
		else:
			anim.play("idle")  # Optional: use a no-op or casting animation

		await _actor.animation_finished

	return true

	
	
func _on_BattlerAnim_triggered(target, hit: Hit) -> void:
	# On each animation trigger, we apply the corresponding hit.

	#target.take_hit(hit, self)
	pass

