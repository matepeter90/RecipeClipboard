  require 'defines'
  ingredients = {}
  item = ""
  debug = false
  defaultInserterLimit = 5
  defaultIngredientRatio = 2
  function dbg(s)
    if debug then game.player.print(game.tick .. ": " .. s) end
  end
  function getBtn(n)
    return game.player.gui.left[n]
  end
  function createButton(c, n)
    game.player.gui.left.add{type = 'button', caption = c, name = n}
  end
  function listSlots(es)
    for k,v in pairs(es) do
      if(type(v) == 'table') then
        listSlots(v)
      elseif type(v) == 'userdata' then
        dbg(k .. " : " .. serpent.block(v))
      else
        dbg(k .. " : " .. v)
      end
   end
  end

  script.on_event(defines.events.on_tick,
  function(e)
    if game.player.opened then
      if pcall(function() return game.player.opened.recipe end) then
        if not getBtn('copyButton') then
          dbg('+ Copy button')
          createButton('Copy Build Requirements', 'copyButton')
        end
      elseif game.player.opened.name == 'logistic-chest-requester' then
        if not getBtn('pasteButton') then
          dbg(' + Paste Button')
           createButton('Paste Build Requirements', 'pasteButton')
        end
      elseif game.player.opened.type == 'inserter' then
        if not getBtn('pasteButton') then
          if string.find(game.player.opened.name, "smart") then
            createButton('Paste Build Requirements', 'pasteButton')
          end
        end
      end
    else
      if getBtn('copyButton') then
        dbg(' - Copy Button')
        getBtn('copyButton').destroy()
      end
      if getBtn('pasteButton')  then
        dbg(' - Paste Button')
          getBtn('pasteButton').destroy()
      end
    end
  end)

  script.on_event(defines.events.on_gui_click, function(event)
    if (event.element.name == 'copyButton') then
      pcall(function()
        local i = 0
        ingredients = {}
        item = game.player.opened.recipe.name
        for _,x in pairs(game.player.opened.recipe.ingredients) do
          listSlots(x)
          if x['type'] then
            if x['type'] == 'item' then
              ingredients[x['name']] = {name = x['name'], count = x['amount']* defaultIngredientRatio}
              dbg('Added [' .. serpent.block(x) .. ']')
            end
          end
        end
      end)
    end
    if (event.element.name == 'pasteButton') then
      pcall(function()
        if game.player.opened.type == 'inserter' then
          if string.find(game.player.opened.name, "smart") then
            game.player.opened.set_circuit_condition {circuit = defines.circuitconnector.logistic, name = item, count = defaultInserterLimit, operator = "<"}
          end
        else
          local s = 0
          for _,_ in pairs(ingredients) do s = s + 1 end
          listSlots(ingredients)
          for i=1,10 do
            local slot = game.player.opened.get_request_slot(i)
            if slot ~= nil then
              local n = slot['name']
              if ingredients[n] ~= nil then
                dbg('Updating item count [' .. n .. '] ' .. serpent.block(slot))
                ingredients[n]['count'] = ingredients[n]['count'] + slot['count']
              else
                ingredients[n] = slot
              end
            end
          end
          listSlots(ingredients)
          local i = 1
          for _,e in pairs(ingredients) do
            game.player.opened.set_request_slot(e,i)
            i = i + 1
            if i > 10 then
              break
            end
          end
        end
      end)
    end 
  end)
