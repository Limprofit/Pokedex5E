local utils = require "utils.utils"
local pokedex = require "pokedex.pokedex"
local natures = require "pokedex.natures"
local storage = require "pokedex.storage"
local M = {}


local function add_tables(T1, T2)
	local copy = utils.shallow_copy(T1)
	for k,v in pairs(T2) do
		if copy[k] then
			copy[k] = copy[k] + v
		end
	end
	return copy
end

function M.get_attributes(pokemon)
	local b = pokedex.get_base_attributes(M.get_caught_species(pokemon))
	local a = M.get_increased_attributes(pokemon) or {}
	local n = natures.get_nature_attributes(M.get_nature(pokemon)) or {}
	return add_tables(add_tables(b, n), a)
end

function M.get_max_attributes(pokemon)
	local m = {STR= 20,DEX= 20,CON= 20,INT= 20,WIS= 20,CHA= 20}
	local n = natures.get_nature_attributes(M.get_nature(pokemon)) or {}
	local t = add_tables(m, n)
	for key, value in pairs(t) do
		t[key] = value > 20 and value or 20 
	end
	return t
end

function M.get_increased_attributes(pokemon)
	return pokemon.attributes.increased
end

function M.update_increased_attributes(pokemon, increased)
	local b = M.get_increased_attributes(pokemon)
	local n = add_tables(b, increased)
	pokemon.attributes.increased = n
end

function M.save(pokemon)
	return storage.update_pokemon(pokemon)
end

function M.get_speed_of_type(pokemon)
	local species = M.get_current_species(pokemon)
	local type = pokedex.get_pokemon_type(species)[1]
	if type == "Flying" then
		return pokedex.get_flying_speed(species), "Flying"
	elseif type == "Water" then
		return pokedex.get_swimming_speed(species), "Swimming"
	else
		return pokedex.get_walking_speed(species), "Walking"
	end
end

function M.get_all_speed(pokemon)
	local species = M.get_current_species(pokemon)
	return {Walking=pokedex.get_walking_speed(species), Swimming=pokedex.get_swimming_speed(species), 
			Flying=pokedex.get_flying_speed(species), Climbing=pokedex.get_climbing_speed(species)}
end

function M.set_current_hp(pokemon, hp)
	pokemon.hp.current = hp
	storage.set_pokemon_current_hp(M.get_id(pokemon), hp)
end

function M.get_current_hp(pokemon)
	return pokemon.hp.current
end

function M.set_max_hp(pokemon, hp)
	pokemon.hp.max = hp
	storage.set_pokemon_max_hp(M.get_id(pokemon), hp)
end

function M.get_max_hp(pokemon)
	return pokemon.hp.max
end

function M.get_current_species(pokemon)
	return pokemon.species.current
end

function M.set_species(pokemon, species)
	pokemon.species.current = species
end

function M.get_caught_species(pokemon)
	return pokemon.species.caught
end

function M.get_current_level(pokemon)
	return pokemon.level.current
end

function M.get_caught_level(pokemon)
	return pokemon.level.caught
end

function M.set_move(pokemon, new_move, index)
	local pp = pokedex.get_move_pp(new_move)
	for name, move in pairs(M.get_moves(pokemon)) do
		if move.index == index then
			pokemon.moves[name] = nil
			pokemon.moves[new_move] = {pp=pp, index=index}
			return
		end
	end
	pokemon.moves[new_move] = {pp=pp, index=index}
end

function M.get_moves(pokemon)
	return pokemon.moves
end

function M.get_nature(pokemon)
	return pokemon.nature
end

function M.get_id(pokemon)
	return pokemon.id
end

function M.get_type(pokemon)
	return pokedex.get_pokemon_type(M.get_current_species(pokemon))
end

function M.get_STAB_bonus(pokemon)
	return pokedex.level_data(M.get_current_level(pokemon)).STAB
end

function M.get_proficency_bonus(pokemon)
	return pokedex.level_data(M.get_current_level(pokemon)).prof
end

function M.get_abilities(pokemon)
	return pokedex.get_pokemon_abilities(M.get_current_species(pokemon)) or {}
end

function M.get_skills(pokemon)
	return pokedex.get_pokemon_skills(M.get_current_species(pokemon)) or {}
end

function M.get_move_pp(pokemon, move)
	return pokemon.moves[move].pp
end

function M.get_move_index(pokemon, move)
	return pokemon.moves[move].index
end

function M.reset(pokemon)
	M.set_current_hp(pokemon, M.get_max_hp(pokemon))
	for name, move in pairs(M.get_moves(pokemon)) do
		M.reset_move_pp(pokemon, name)
	end
end

function M.get_vulnerabilities(pokemon)
	return pokedex.get_pokemon_vulnerabilities(M.get_current_species(pokemon))
end

function M.get_immunities(pokemon)
	return pokedex.get_pokemon_immunities(M.get_current_species(pokemon))
end

function M.get_resistances(pokemon)
	return pokedex.get_pokemon_resistances(M.get_current_species(pokemon))
end

function M.decrease_move_pp(pokemon, move)
	local pp = math.max(M.get_move_pp(pokemon, move) - 1, 0)
	storage.set_pokemon_move_pp(M.get_id(pokemon), move, pp)
	pokemon.moves[move].pp = pp
end

function M.increase_move_pp(pokemon, move)
	local max_pp = pokedex.get_move_pp(move)
	local pp = math.min(M.get_move_pp(pokemon, move) + 1, max_pp)
	storage.set_pokemon_move_pp(M.get_id(pokemon), move, pp)
	pokemon.moves[move].pp = pp
end


function M.reset_move_pp(pokemon, move)
	local pp = pokedex.get_move_pp(move)
	storage.set_pokemon_move_pp(M.get_id(pokemon), move, pp)
	pokemon.moves[move].pp = pp
end

function M.set_evolutuion_at_level(pokemon, level)
	pokemon.level.evolved = level
	storage.set_evolutuion_at_level(M.get_id(pokemon), level)
end

function M.get_saving_throw_attributes(pokemon)
	local prof = M.get_proficency_bonus(pokemon)
	local b  = M.get_attributes(pokemon)
	local st = pokedex.get_saving_throw_proficiencies(M.get_current_species(pokemon)) or {}
	for _, st in pairs(st) do
		b[st] = b[st] + prof
	end
	return b
end

function M.get_AC(pokemon)
	return pokedex.get_pokemon_AC(M.get_current_species(pokemon)) + natures.get_AC(M.get_nature(pokemon))
end

function M.get_index_number(pokemon)
	return pokedex.get_index_number(M.get_current_species(pokemon))
end

function M.get_max_hp_at_level(pokemon, level)
	local current_species = M.get_current_species(pokemon)
	local caught_level = M.get_caught_level(pokemon)
	local current_level = M.get_current_level(pokemon) 
	local evolution_level = M.get_evolution_level(pokemon)
	
	local base_con_mod = math.floor((pokedex.get_base_attributes(current_species).CON - 10) / 2)
	local base_hp = pokedex.get_base_hp(current_species) - base_con_mod
	local extra_hp_from_evolution = (caught_level - evolution_level) * 2
	local hit_dice = pokedex.get_pokemon_hit_dice(current_species)
	local con = M.get_attributes(pokemon).CON
	local con_mod = math.floor((con - 10) / 2)
	local levels_gained = current_level - caught_level
	return extra_hp_from_evolution + base_hp + ((math.ceil(hit_dice / 2)  + con_mod) * levels_gained)
end

function M.get_evolution_level(pokemon)
	return pokemon.level.evolved or 0
end

function M.get_sprite(pokemon)
	local pokemon_index = M.get_index_number(pokemon)
	local texture = "pokemon" .. math.floor(pokemon_index/256)
	local pokemon_sprite = pokemon_index .. M.get_current_species(pokemon)
	if pokemon_index == 32 or pokemon_index == 29 then
		pokemon_sprite = pokemon_sprite:sub(1, -5)
	end
	
	return pokemon_sprite, texture
end

local function level_index(level)
	if level > 17 then
		return "17"
	elseif level > 10 then
		return "10"
	elseif level > 5 then
		return "5"
	else
		return "1"
	end
end

local function get_damage_mod_stab(pokemon, move)
	local modifier = 0
	local damage
	local ab
	local stab = false
	local stab_damage = 0
	local total = M.get_total_attribute

	-- Pick the highest of the moves power
	local total = M.get_attributes(pokemon)
	for _, mod in pairs(move["Move Power"]) do
		if total[mod] then
			modifier = total[mod] > modifier and total[mod] or modifier
		end
	end
	modifier = math.floor((modifier - 10) / 2)

	for _, t in pairs(M.get_type(pokemon)) do
		if move.type == t and move.Damage then
			stab_damage = M.get_STAB_bonus(pokemon)
			stab = true
		end
	end
	local index = level_index(M.get_current_level(pokemon))
	
	local move_damage = move.Damage
	if move_damage then
		damage = move_damage[index].amount .. "d" .. move_damage[index].dice_max
		if move_damage[index].move then
			damage = damage .. "+" .. (modifier+stab_damage)
		end
		ab = modifier + M.get_proficency_bonus(pokemon)
	end
	return damage, modifier, stab
end	

function M.get_move_data(pokemon, move_name)
	local move = pokedex.get_move_data(move_name)
	dmg, mod, stab = get_damage_mod_stab(pokemon, move)
	
	local move_data = {}
	move_data.damage = dmg
	move_data.stab = stab
	move_data.name = move_name
	move_data.type = move.Type
	move_data.PP = move.PP
	move_data.duration = move.Duration
	move_data.range = move.Range
	move_data.description = move.Description
	move_data.power = move["Move Power"]
	move_data.save = move.Save
	move_data.time = move["Move Time"]
	
	if move_data.damage then
		move_data.AB = mod + M.get_proficency_bonus(pokemon)
	end
	if move_data.save then
		move_data.save_dc = 8 + mod + M.get_proficency_bonus(pokemon)
	end

	return move_data
end

function M.new(data)
	local this = {}
	this.species = {}
	this.species.caught = data.species
	this.species.current = data.species

	this.hp = {}
	this.hp.current = pokedex.get_base_hp(this.species.caught)
	this.hp.max = this.hp.current
	this.hp.edited = false

	this.level = {}
	this.level.caught = pokedex.get_minimum_wild_level(this.species.caught)
	this.level.current = this.level.caught
	this.level.evolved = 0

	this.attributes = {}
	this.attributes.increased = data.attributes or {}

	this.moves = data.moves
	return this
end



return M