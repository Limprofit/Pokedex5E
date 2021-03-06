local profiles = require "pokedex.profiles"
local defsave = require "defsave.defsave"
local utils = require "utils.utils"
local M = {}

local trainer

local _trainer = {ab=0, dmg=0, evo=0, all_stab=0,
	tm_stab={Normal=0, Fire=0, Water=0, Electric=0, Grass=0, Ice=0, Fighting=0, Poison=0, Ground=0, Flying=0, Psychic=0, Bug=0, Rock=0, Ghost=0, Dragon=0, Dark=0, Steel=0, Fairy=0},
	stab  = {Normal=0, Fire=0, Water=0, Electric=0, Grass=0, Ice=0, Fighting=0, Poison=0, Ground=0, Flying=0, Psychic=0, Bug=0, Rock=0, Ghost=0, Dragon=0, Dark=0, Steel=0, Fairy=0},
	attributes = {STR=0, DEX=0, CON=0, WIS=0, INT=0, CHA=0}
}


function M.get_attack_roll()
	return trainer.ab
end

function M.get_damage()
	return trainer.dmg
end

function M.get_evolution_level()
	return trainer.evo
end

function M.get_all_levels_STAB()
	return trainer.all_stab
end

function M.get_type_master_STAB(_type)
	return trainer.tm_stab[_type] or 0
end

function M.get_STAB(_type)
	return trainer.stab[_type] or 0
end

function M.get_attribute(attribute)
	return trainer.attributes[attribute] or 0
end

function M.get_attributes()
	return trainer.attributes
end

function M.set_attack_roll(value)
	trainer.ab = value
end

function M.set_damage(value)
	trainer.dmg = value
end

function M.set_evolution_level(value)
	trainer.evo = value
end

function M.set_all_levels_STAB(value)
	trainer.all_stab = value
end

function M.set_type_master_STAB(_type, value)
	trainer.tm_stab[_type] = value
end

function M.set_STAB(_type, value)
	trainer.stab[_type] = value
end

function M.set_attribute(attribute, value)
	trainer.attributes[attribute] = value
end

function M.load(_profile)
	local profile = _profile
	local file_name
	if profile == nil then
		file_name = profiles.get_active_file_name()
	else
		file_name = _profile.file_name
	end
	if not defsave.is_loaded(file_name) then
		local loaded = defsave.load(file_name)
	end
	trainer = defsave.get(file_name, "trainer")
	trainer = next(trainer) == nil and utils.deep_copy(_trainer) or trainer
end

function M.save()
	if profiles.get_active_slot() then
		local profile = profiles.get_active_file_name()
		defsave.set(profile, "trainer", trainer)
	end
end

return M