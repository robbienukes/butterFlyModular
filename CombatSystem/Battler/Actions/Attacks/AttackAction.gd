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
	super._init(data, actor, targets)
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
		var physical_damage = calculate_potential_physical_damage_for(target)
		var magical_damage = calculate_potential_magical_damage_for(target)
		var damage = physical_damage + magical_damage
		# We use the `StatusEffectBuilder` to instantiate the right effect.
		var status: StatusEffect = StatusEffectBuilder.create_status_effect(
			target, _data.status_effect
		)
		
		var hit = Hit.new(damage, hit_chance, status, _actor)
		
		# Create and connect a callable for the method with parameters
		#var callable = Callable(self, "_on_BattlerAnim_triggered").bind(target, hit)
		#anim.connect("triggered", callable)
		#print("Connecting ", callable, "to ", anim)
		
		# Directly apply the hit without using signals for now
		#_on_BattlerAnim_triggered(target, hit)
		print("Hitting ", target)
		target.take_hit(hit, self)
		
		anim.play("attack")
		await _actor.animation_finished
	return true
	
	
func _on_BattlerAnim_triggered(target, hit: Hit) -> void:
	# On each animation trigger, we apply the corresponding hit.

	#target.take_hit(hit, self)
	pass

