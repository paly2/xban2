function xban.get_whitelist_entry(player) --> bool, index
	for index, e in ipairs(db.whitelist) do
		if e.name == player or e.ip == player then
			return true, index
		end
	end
	return false
end

function xban.whitelist_player(player, source) --> bool, err
	local in_whitelist, index = xban.get_whitelist_entry(player)
	if in_whitelist then
		return false, "Player is already in the whitelist."
	end
	local entry, index = xban.find_entry(player)
	if entry then
		table.remove(db, index)
	end
	local e = { name = player }
	local ip = minetest.get_player_ip(player)
	if ip then
		e.ip = ip
	end
	table.insert(db.whitelist, e)
	ACTION("%s adds %s to the whitelist.", source, player)
	return true
end

function xban.unwhitelist_player(player, source) --> bool, err
	local in_whitelist, index =  xban.get_whitelist_entry(player)
	if not in_whitelist then
		return false, "Player is not in the whitelist."
	end
	table.remove(db.whitelist, index)
	ACTION("%s removes %s from the whitelist.", source, player)
	return true
end

minetest.register_chatcommand("xban_ignore", {
	description = "Add a player to the ban whitelist",
	params = "<player_or_ip>",
	privs = { ban=true },
	func = function(name, params)
		local plname = params:match("%S+")
		if not plname then
			return false, "Usage: /xban_ignore <player_or_ip>"
		end
		local ok, e = xban.whitelist_player(plname, name)
		return ok, ok  and ("Player %s is now in the whitelist."):format(plname) or e
	end
})

minetest.register_chatcommand("xban_unignore", {
	description = "Remove a player from the ban whitelist",
	params = "<player_or_ip>",
	privs = { ban=true },
	func = function(name, params)
		local plname = params:match("%S+")
		if not plname then
			return false, "Usage: /xban_ignore <player_or_ip>"
		end
		local ok, e = xban.unwhitelist_player(plname, name)
		return ok, ok  and ("Player %s is no longer in the whitelist."):format(plname) or e
	end
})
