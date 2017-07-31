local player_to_id_text = {} -- Storage of players so the mod knows what huds to update
local player_to_id_image = {}

minetest.register_globalstep(function(dtime) -- This will run every tick, so around 20 times/second
    for _, player in ipairs(minetest:get_connected_players()) do -- Do everything below for each player in-game
        local lookat = get_looking_node(player) -- Get the node they're looking at

        if lookat then
            player:hud_change(player_to_id_text[player], "text", describe_node(lookat)) -- If they are looking at something, display that
            local node_object = minetest.registered_nodes[lookat.name]
            player:hud_change(player_to_id_image[player], "text", handle_tiles(node_object))
        else
            player:hud_change(player_to_id_text[player], "text", "") -- If they are not looking at anything, do not display the text
            player:hud_change(player_to_id_image[player], "text", "")            
        end
    end
end)

minetest.register_on_joinplayer(function(player) -- Add the hud to all players
    player_to_id_text[player] = player:hud_add({
        hud_elem_type = "text",
        text = "test",
        number = 0xffffff,
        position = {x = 0.5, y = 0.1},
    })
    player_to_id_image[player] = player:hud_add({
        hud_elem_type = "image",
        text = "",
        scale = {x = 1, y = 1},
        alignment = 0,
        position = {x = 0.4, y = 0.1},        
        offset = {x = 0, y = 0}
    })
end)

function get_looking_node(player) -- Return the node the given player is looking at or nil
    local lookat
    for i = 0, 10 do -- 10 is the maximum distance you can point to things in creative mode by default
        local lookvector = -- This variable will store what node we might be looking at
            vector.add( -- This add function corrects for the players approximate height
                vector.add( -- This add function applies the camera's position to the look vector
                    vector.multiply( -- This multiply function adjusts the distance from the camera by the iteration of the loop we're in
                        player:get_look_dir(), 
                        i -- Goes from 0 to 10
                    ), 
                    player:get_pos()
                ),
                vector.new(0, 1.5, 0)
            )
        lookat = minetest.get_node_or_nil( -- This actually gets the node we might be looking at
            lookvector
        ) or lookat
        if lookat ~= nil and lookat.name ~= "air" and lookat.name ~= "walking_light:light" then break else lookat = nil end -- If we *are* looking at something, stop the loop and continue
    end
    return lookat
end

function describe_node(node) -- Return a string that describes the node and mod
    local mod, nodename = minetest.registered_nodes[node.name].mod_origin, minetest.registered_nodes[node.name].description
    if nodename == "" then
        nodename = node.name
    end
    mod = remove_unneeded(capitalize(mod))
    nodename = remove_unneeded(capitalize(nodename))
    return
        "Name: " .. nodename .. "\n" ..
        "Mod: " .. mod .. "\n"
end

function remove_unneeded(str) -- Remove characters like '-' and '_' to make the string look better
    return str:gsub("[_-]", " ")
end

function capitalize(str) -- Capitalize every word in a string, looks good for node names
    return string.gsub(" "..str, "%W%l", string.upper):sub(2)
end

function handle_tiles(node)
    local tiles = node.tiles

    if tiles then
        for i,v in pairs(tiles) do
            if type(v) == "table" then
                if tiles[i].name then
                    tiles[i] = tiles[i].name
                else
                    return ""
                end
            end
        end

        if node.drawtype == "normal" or node.drawtype == "allfaces" or node.drawtype == "allfaces_optional" or node.drawtype == "glasslike" or node.drawtype == "glasslike_framed" or node.drawtype == "glasslike_framed_optional" then
            if #tiles == 1 then
                return minetest.inventorycube(tiles[1], tiles[1], tiles[1])
            elseif #tiles == 3 then
                return minetest.inventorycube(tiles[1], tiles[3], tiles[3])
            elseif #tiles == 6 then
                return minetest.inventorycube(tiles[1], tiles[6], tiles[5])
            end
        end
    end

    return ""
end