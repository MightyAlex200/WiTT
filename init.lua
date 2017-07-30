local player_to_id_text = {}

minetest.register_globalstep(function(dtime)
    for _, player in ipairs(minetest:get_connected_players()) do
        -- local player = minetest.get_player_by_name(name) 
        -- if not player then return end
        local lookat = get_looking_node(player)

        if lookat then
            player:hud_change(player_to_id_text[player], "text", describe_node(lookat))
        else
            player:hud_change(player_to_id_text[player], "text", "")
        end
    end
end)

minetest.register_on_joinplayer(function(player)
    player_to_id_text[player] = player:hud_add({
        hud_elem_type = "text",
        text = "test",
        number = 0xffffff,
        direction = 2,
        position = {x = 0.5, y = 0.1},
        alignment = {x = -0.5, y = 0}
    })
end)

function get_looking_node(player) 
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

function describe_node(node)
    local mod, nodename = minetest.registered_nodes[node.name].mod_origin, minetest.registered_nodes[node.name].description
    mod = remove_unneeded(capitalize(mod))
    nodename = remove_unneeded(capitalize(nodename))
    return
        "Name: " .. nodename .. "\n" ..
        "Mod: " .. mod .. "\n"
end

function remove_unneeded(str)
    return str:gsub("[_-]", " ")
end

function capitalize(str) 
    return string.gsub(" "..str, "%W%l", string.upper):sub(2)
end