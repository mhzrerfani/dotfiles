local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local config = require("configuration.config")

local item = require("configuration.widgets.client_menu.item")

local instance = nil
local client_menu = {
  mt = {}
}

function client_menu:toggle(args)
  if self._private.visible then
    self:hide()
  else
    self:show(args)
  end
end

function client_menu:show(args)
  local wp = self._private
  if wp.visible then
    return
  end

  if not args.client then
    return
  end

  wp.client = args.client
  local s = args.client.screen

  wp.visible = true
  wp.backdrop.screen = s
  wp.backdrop.x = args.client.screen.geometry.x
  wp.backdrop.y = args.client.screen.geometry.y
  wp.backdrop.width = args.client.screen.geometry.width
  wp.backdrop.height = args.client.screen.geometry.height
  wp.backdrop.visible = true

  local x = args.coords.x
  local y = args.coords.y
  local max_x = s.geometry.x + s.geometry.width
  local max_y = s.geometry.y + s.geometry.height

  wp.popup.x = x
  wp.popup.y = y
  if wp.popup.width + x > max_x then
    wp.popup.x = x - wp.popup.width
  end
  if wp.popup.height + y > max_y then
    wp.popup.y = y - wp.popup.height
  end

  wp.actions["sticky"].value = wp.client.sticky
  wp.actions["fullscreen"].value = wp.client.fullscreen
  wp.actions["ontop"].value = wp.client.ontop
  wp.actions["minimized"].value = wp.client.minimized
  wp.actions["maximized"].value = wp.client.maximized

  wp.popup.screen = s
  wp.popup.visible = true
end

function client_menu:hide()
  if not self._private.visible then
    return
  end
  self._private.visible = false
  self._private.backdrop.visible = false
  self._private.popup.visible = false
end

local function new_action(self, id, title)
  return wibox.widget {
    widget = item,
    checkbox = true,
    id = id,
    on_release = function(_, _, _, checked)
      self._private.client[id] = checked
    end,
    {
      widget = wibox.widget.textbox,
      markup = "<span font='Inter Regular 11'>" .. title .. "</span>"
    }
  }
end

local function new(args)
  if instance then
    return instance
  end

  args = args or {}

  local ret = {}
  ret._private = {}
  ret._private.client = nil

  gears.table.crush(ret, args)
  gears.table.crush(ret, client_menu)

  ret._private.actions = {
    sticky = new_action(ret, "sticky", "Sticky"),
    fullscreen = new_action(ret, "fullscreen", "Fullscreen"),
    ontop = new_action(ret, "ontop", "Ontop"),
    maximized = new_action(ret, "maximized", "Maximized"),
    minimized = new_action(ret, "minimized", "Minimized")
  }

  ret._private.widget =
    wibox.widget {
    widget = wibox.container.constraint,
    width = config.dpi(250),
    strategy = "exact",
    {
      layout = wibox.layout.fixed.vertical,
      spacing_widget = wibox.widget {
        widget = wibox.widget.separator,
        orientation = "horizontal",
        forced_height = config.dpi(1),
        opacity = 1,
        color = "#000000ff"
      },
      ret._private.actions.sticky,
      ret._private.actions.fullscreen,
      ret._private.actions.ontop,
      ret._private.actions.maximized,
      ret._private.actions.minimized,
      {
        widget = item,
        on_release = function()
          ret._private.client:kill()
        end,
        {
          widget = wibox.widget.textbox,
          markup = "<span font='Inter Regular 11'>Close</span>"
        }
      }
    }
  }

  ret._private.backdrop =
    wibox {
    ontop = true,
    bg = "#ffffff00",
    type = "utility"
  }

  ret._private.backdrop:buttons(
    awful.util.table.join(
      awful.button(
        {},
        1,
        function()
          ret:hide()
        end
      )
    )
  )

  ret._private.popup =
    awful.popup {
    widget = ret._private.widget,
    visible = false,
    ontop = true,
    type = "utility",
    shape = gears.shape.rounded_rect
  }

  instance = ret
  return ret
end

function client_menu.mt:__call(...)
  return new(...)
end

return setmetatable(client_menu, client_menu.mt)
