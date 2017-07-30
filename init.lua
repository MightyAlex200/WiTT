minetest.register_chatcommand("witt", {
    params = "" ,
    description = "What is this thing: Get information about the thing you're looking at.",
    func = function() 
        local lookat = get_looking_node()

        if lookat then
            minetest.display_chat_message(describe_node(lookat))
        else
            minetest.display_chat_message("Unable to identify a node, try getting closer.")
        end
    end
})

function get_looking_node() 
    local lookat
    for i = 0, 10 do -- 10 is the maximum distance you can point to things in creative mode by default
        local lookvector = -- This variable will store what node we might be looking at
            vector.add( -- This add function corrects for the players approximate height
                vector.add( -- This add function applies the camera's position to the look vector
                    vector.multiply( -- This multiply function adjusts the distance from the camera by the iteration of the loop we're in
                        minetest.camera:get_look_dir(), 
                        i -- Goes from 0 to 10
                    ), 
                    minetest.localplayer:get_pos()
                ),
                vector.new(0, 1.5, 0)
            )
        lookat = minetest.get_node_or_nil( -- This actually gets the node we might be looking at
            lookvector
        ) or lookat
        if lookat ~= nil and lookat.name ~= "air" then break else lookat = nil end -- If we *are* looking at something, stop the loop and continue
    end
    return lookat
end

function describe_node(node)
    local mod, nodename = string.match(node.name, "(.*):(.*)")
    mod = mod or "?"
    nodename = nodename or "?"
    return
        "Name: " .. nodename .. "\n" ..
        "Mod: " .. mod .. "\n" 
        -- "Description: " .. node.description
end