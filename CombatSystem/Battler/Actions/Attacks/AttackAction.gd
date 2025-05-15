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
	print("🧪 ANIMATION in _init:", data.animation)
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
	print("🧪 play_attacker_animation =", _data.play_attacker_animation)

	var anim = _actor.battler_anim
	var attack_data := _data as AttackActionData  # ✅ Moved outside the loop

	for target in _targets:
		print("Processing target:", target.name)

		var hit_chance = Formulas.calculate_hit_chance(_data, _actor, target)
		var damage: int = 0  # Default to zero

		# Handle healing (treated as negative damage)
		if _data.is_heal:
			damage = -abs(_data.power)
		elif _data.does_damage:
			var physical_damage = calculate_potential_physical_damage_for(target)
			var magical_damage = calculate_potential_magical_damage_for(target)
			damage = physical_damage + magical_damage

		# 🛡️ Check reflect before applying hit
		var should_reflect = false
		if target.has_method("has_status_effect"):
			should_reflect = target.has_status_effect("reflect") and attack_data.is_magical

		if should_reflect:
			print("🛡️ Original hit detected due to reflect — redirecting...")
			# Trigger the signal manually so the reflect logic runs
			target.hit_taken.emit(null, self)
			continue

		
		# ✅ Apply reaction-based multipliers BEFORE creating the Hit
		if target.has_method("has_status_effect") and target.has_status_effect("wet") and _data.animation == "lightning":
			var reactions = ReactionData.get_reactions()
			if reactions.has("wet") and reactions["wet"].has("lightning"):
				var multiplier = reactions["wet"]["lightning"]["multiplier"]
				print("💥 Applying reaction multiplier:", multiplier)
				damage = int(damage * multiplier)
	
		# Create and apply hit
		var status: StatusEffect = StatusEffectBuilder.create_status_effect(
			target, _data.status_effect
		)
		var hit = Hit.new(damage, hit_chance, status, _actor)
		
		hit.show_label = damage !=0 or _data.label in ["heal"]
		
		print("Hitting ", target)
		
		
		# ✅ Play lightning only for this specific case
		if not _data.play_attacker_animation and _data.animation == "lightning":
			if target.has_method("get_battler_anim"):
				var target_anim = target.get_battler_anim()
				if target_anim:
					print("⚡ Playing lightning animation on:", target.name)
					target_anim.block_damage_animation = true
					print("setting block_damage_animation on:", target_anim.get_instance_id())
					target_anim.play("lightning")
					await target_anim.animation_finished
					target_anim.block_damage_animation = false
				else:
					push_warning("⚠️ Target has no animation named '%s'" % _data.animation)
			else:
				push_warning("⚠️ Target %s has no get_battler_anim() method" % target.name)

		
		target.take_hit(hit, self)
		
	
		# small delay
		await get_tree().create_timer(0.2).timeout
	
		# 1. Apply reaction logic — only if this attack was 'lightning'
		if _data.animation == "lightning" and target.has_method("react_to"):
		# Avoid reacting if we just applied the wet status as part of this same hit
		# We want to ensure 'wet' was present *before* this action
			if target.has_status_effect("wet"):
				target.react_to("lightning")

		# Play hit confirm or miss sound
		var sfx := AudioStreamPlayer.new()
		if hit.does_hit():
			if attack_data.hit_confirm_sound:
				print("✅ Sound is still present at play time:", attack_data.hit_confirm_sound)
				play_sound(attack_data.hit_confirm_sound)
			else:
				push_warning("⚠️ hit_confirm_sound is null at play time — skipping sound.")

		else:
			if attack_data.miss_sound:
				sfx.stream = attack_data.miss_sound

		if sfx.stream:
			_actor.add_child(sfx)
			sfx.play()
		
		if attack_data and attack_data.hit_sound:
			play_sound(attack_data.hit_sound)  # Optional: pass delay if needed
		
		
		# 2. Then, depending on whether it landed or missed, play the appropriate confirmation sound
		if hit.does_hit():
			if attack_data and attack_data.hit_confirm_sound:
				play_sound(attack_data.hit_confirm_sound, 0.15)  # optional delay
		else:
			if attack_data and attack_data.miss_sound:
				play_sound(attack_data.miss_sound, 0.1)  # optional delay

	# 🌀 Animation handling
	if _data.play_attacker_animation:
		if _data.animation != "":
			if anim.has_animation(_data.animation):
				print("🎬 Attempting to play animation:", _data.animation)
				anim.play(_data.animation)
				await _actor.animation_finished
			else:
				push_warning("Animation '%s' not found!" % _data.animation)
		elif _data.is_heal:
			anim.play("heal")
			await _actor.animation_finished
		elif _data.does_damage:
			anim.play("attack")
			await _actor.animation_finished

		else:
			print("⚠️ No animation to play, skipping wait.")
			var tree := get_tree()
			if tree == null:
				push_error("🌲 get_tree() returned null. This node must be added to the scene tree!")
			else:
				await tree.create_timer(0.3).timeout

	return true

	
	
func _on_BattlerAnim_triggered(target, hit: Hit) -> void:
	# On each animation trigger, we apply the corresponding hit.

	#target.take_hit(hit, self)
	pass

