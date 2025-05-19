# Stores and manages the battler's base stats like health, energy, and base
# damage.
extends Stats
class_name BattlerStats

signal health_depleted
signal health_changed(old_value, new_value)
signal energy_changed(old_value, new_value)

@export var max_health := 100
@export var max_energy := 6

@export var base_physical_attack := 10.0: set = set_base_physical_attack
@export var base_physical_defense := 10.0: set = set_base_physical_defense
@export var base_magical_attack := 10.0: set = set_base_magical_attack
@export var base_magical_defense := 10.0: set = set_base_magical_defense
@export var base_speed := 70.0: set = set_base_speed
@export var base_hit_chance := 100.0: set = set_base_hit_chance
@export var base_evasion := 0.0: set = set_base_evasion

@export var weaknesses := []
@export var affinity: int = Types.Elements.NONE


var health := max_health: set = set_health
var energy := 0: set = set_energy

var physical_attack := base_physical_attack
var magical_attack := base_magical_attack
var physical_defense := base_physical_defense
var magical_defense := base_magical_defense
var speed := base_speed
var hit_chance := base_hit_chance
var evasion := base_evasion



func _init() -> void:
	super()


func set_health(value: float) -> void:
	var old_value = health
	health = clamp(value, 0.0, get_stat("max_health"))
	if health != old_value:
		emit_signal("health_changed", old_value, health)
	if is_equal_approx(health, 0.0):
		emit_signal("health_depleted")
	_update("health")


func set_energy(value: float) -> void:
	var old_value = energy
	energy = clamp(value, 0.0, get_stat("max_energy"))
	if energy != old_value:
		emit_signal("energy_changed", old_value, energy)
	_update("energy")

func get_energy() -> float:
	return energy

func get_max_health() -> float:
	return get_stat("max_health")

func get_max_energy() -> float:
	return get_stat("max_energy")

func get_base_physical_attack() -> float:
	return get_stat("physical_attack")
	
func get_base_magical_attack() -> float:
	return get_stat("magical_attack")

func get_base_physical_defense() -> float:
	return get_stat("physical_defense")
	
func get_base_magical_defense() -> float:
	return get_stat("magical_defense")

func get_base_speed() -> float:
	return get_stat("speed")

func get_base_hit_chance() -> float:
	return get_stat("hit_chance")

func get_base_evasion() -> float:
	return get_stat("evasion")

func set_base_physical_attack(value: float) -> void:
	base_physical_attack = value
	_update("physical_attack")
	
func set_base_magical_attack(value: float) -> void:
	base_magical_attack = value
	_update("magical_attack")


func set_base_physical_defense(value: float) -> void:
	base_physical_defense = value
	_update("physical_defense")
	
func set_base_magical_defense(value: float) -> void:
	base_magical_defense = value
	_update("magical_defense")


func set_base_speed(value: float) -> void:
	base_speed = value
	_update("speed")

func set_base_hit_chance(value: float) -> void:
	base_hit_chance = value
	_update("hit_chance")


func set_base_evasion(value: float) -> void:
	base_evasion = value
	_update("evasion")
