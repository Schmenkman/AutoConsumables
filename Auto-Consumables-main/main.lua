local menu = require("menu")
local options = require("data.consumable_options")

local last_potion_use_time = 0
local potion_cooldown = 0.2

local function check_for_player_buff(buffs, option)
  local count = 0
  for _, buff in ipairs(buffs) do
    if buff:name() == option then
      count = count + 1
    end
  end
  return count
end

local function execute_with_cooldown(item)
  local current_time = get_time_since_inject()
  if current_time - last_potion_use_time >= potion_cooldown then
    use_item(item)
    last_potion_use_time = current_time
  end
end

local function check_consumables(item_options, chosen_index, toggle, buffs, consumable_items)
  if toggle then
    local item_name = item_options[chosen_index + 1]
    local buff_name = item_name
    
    -- Special handling for opals
    if string.find(item_name, "Opal") then
      buff_name = "Opal of Power"  -- Change this to match the actual buff name for opals
    end
    
    print("Checking for buff: " .. buff_name)  -- Debug print
    
    if check_for_player_buff(buffs, buff_name) < 1 then
      print("Buff not found, trying to use item: " .. item_name)  -- Debug print
      for _, item in ipairs(consumable_items) do
        if item:get_name() == item_name then
          execute_with_cooldown(item)
          print("Used item: " .. item_name)  -- Debug print
          break
        end
      end
    else
      print("Buff already active: " .. buff_name)  -- Debug print
    end
  end
end

local function check_inventory(inventory)
  for _, item in ipairs(inventory) do
    if string.find(string.lower(item:get_name()), "temper") then
      use_item(item)
    end
  end
end

on_update(function()
  local local_player = get_local_player()

  if local_player then
    local player_position = get_player_position()
    local buffs = local_player:get_buffs()
    local consumable_items = local_player:get_consumable_items()
    local inventory_items = local_player:get_inventory_items()

    check_inventory(inventory_items)

    local closest_target = target_selector.get_target_closer(player_position, 10)

    local chosen_opal = menu.elements.opal_combo:get()
    local chosen_high_elixir = menu.elements.high_elixir_combo:get()
    local chosen_low_elixir = menu.elements.low_elixir_combo:get()

    local chosen_high_incense = menu.elements.high_incense_combo:get()
    local chosen_medium_incense = menu.elements.medium_incense_combo:get()
    local chosen_low_incense = menu.elements.low_incense_combo:get()

    local opal_toggle = menu.elements.opal_toggle:get()
    local high_elixir_toggle = menu.elements.high_elixir_toggle:get()
    local low_elixir_toggle = menu.elements.low_elixir_toggle:get()

    local high_incense_toggle = menu.elements.high_incense_toggle:get()
    local medium_incense_toggle = menu.elements.medium_incense_toggle:get()
    local low_incense_toggle = menu.elements.low_incense_toggle:get()

    if closest_target then
      if opal_toggle then
        check_consumables(options.opal_options, chosen_opal, opal_toggle, buffs, consumable_items)
      end
      if high_elixir_toggle then
        check_consumables(options.high_elixir_options, chosen_high_elixir, high_elixir_toggle, buffs, consumable_items)
      end
      if low_elixir_toggle then
        check_consumables(options.low_elixir_options, chosen_low_elixir, low_elixir_toggle, buffs, consumable_items)
      end

      if high_incense_toggle then
        check_consumables(options.high_incense_options, chosen_high_incense, high_incense_toggle, buffs, consumable_items)
      end
      if medium_incense_toggle then
        check_consumables(options.medium_incense_options, chosen_medium_incense, medium_incense_toggle, buffs, consumable_items)
      end
      if low_incense_toggle then
        check_consumables(options.low_incense_options, chosen_low_incense, low_incense_toggle, buffs, consumable_items)
      end
    end
  end
end)

on_render_menu(menu.render)
