# Data container to define new status effects.
class_name StatusEffectData
extends Resource

# Text id for the effect type. See StatusEffectBuilder for more information.
@export var effect := ""
# Duration of the effect in seconds.
@export var duration_seconds := 20.0
# Modifier amount that the effect applies or removes to a character's stat.
@export var effect_power := 20
# Rate of the effect, if, for instance, it is percentage-based.
@export var effect_rate := 0.5

# icon 
@export var icon: Texture

# If `true`, the effect applies once every `ticking_interval`
@export var is_ticking : bool = false
# Duration between ticks in seconds.
@export var ticking_interval : float = 4.0
# Damage inflicted by the effect every tick.
@export var ticking_damage : int = 3

# Flag to determine if the effect was just applied
@export var effect_just_applied : bool = true


# Returns the total theoretical damage the effect will inflict over time. For ticking effects.
func calculate_total_damage() -> int:
	var damage := 0
	if is_ticking:
		damage += int(duration_seconds / ticking_interval * ticking_damage)
	return damage
