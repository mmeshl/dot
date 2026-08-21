-- TODO: Split into multiple files
-- TODO: Animations

local fmt = function(str)
  return function (...)
    return string.format(str, ...)
  end
end

local let = function (var)
  return function (fn)
    fn(var)
  end
end

local dsp       = hl.dsp
local exec      = dsp.exec_cmd
local win       = dsp.window
local layoutmsg = dsp.layout
local nop       = dsp.no_op
local dodsp     = hl.dispatch
local execnow   = hl.exec_cmd

local brightnessctl = {
  inc  = 10,
  up   = function (self) return exec(fmt 'brightnessctl set %d%%+' (self.inc)) end,
  down = function (self) return exec(fmt 'brightnessctl set %d%%-' (self.inc)) end,
}

local volumectl = {
  inc       = 5,
  repeating = true,
  up        = function (self) return exec(fmt 'wpctl set-volume @DEFAULT_SINK@ %d%%+' (self.inc)) end,
  down      = function (self) return exec(fmt 'wpctl set-volume @DEFAULT_SINK@ %d%%-' (self.inc)) end,
  mute      = function (_)    return exec 'wpctl set-mute @DEFAULT_SINK@ toggle'                  end,
}

local env = {
  __index = function (_, name)
    return os.getenv(string.upper(name))
  end,

  __newindex = function (_, name, val)
    hl.env(string.upper(name), val)
  end,

  __call = function (self, envs)
    for name, val in pairs(envs) do
      self[name] = val
    end
  end,
}
setmetatable(env, env)

local event = {
  __newindex = function (_, ev, action)
    hl.on(ev, action)
  end
}
setmetatable(event, event)

local config = {
  __mkproxy = function (self, path)
    path = path or {}

    return setmetatable({}, {
      __index = function (_, name)
	local newpath = { table.unpack(path) }
	table.insert(newpath, name)

	return self:__mkproxy(newpath)
      end,

      __newindex = function (_, finalname, val)
	local finalpath = { table.unpack(path) }

	local tbl    = {}
	local cursor = tbl
	for _, name in ipairs(finalpath) do
	  cursor[name] = {}
	  cursor       = cursor[name]
	end

	cursor[finalname] = val
	hl.config(tbl)
      end
    })
  end,

  __index = function (self, name)
    return self:__mkproxy { name }
  end,

  __newindex = function (_, name, val)
    hl.config({ [name] = val })
  end,

  __call = function (_, tbl)
    hl.config(tbl)
  end
}
setmetatable(config, config)

local monitor = {
  __newindex = function (_, output, opts)
    if output == 'default' then output = '' end
    opts.output = output
    hl.monitor(opts)
  end
}
setmetatable(monitor, monitor)

local bind = function (flags)
  local set = function (self, keys, info)
    local action, title = nil, self.flags.description

    if type(info) == 'table' then
      local desc
      action, desc = table.unpack(info)

      if title ~= nil then
	self.flags.description = fmt '%s: %s' (title, desc)
      else
	self.flags.description = desc
      end
    else
      action = info
    end

    hl.bind(keys, action, self.flags)
    self.flags.description = title
  end

  return setmetatable({ set = set, flags = flags }, {
    __newindex = function (self, keys, info)
      self:set(keys, info)
    end,

    __call = function (self, binds)
      for keys, info in pairs(binds) do
	self:set(keys, info)
      end
    end
  })
end

local submap = function (name, ...)
  hl.define_submap(name, ...)
  return dsp.submap(name)
end

local winrule = {
  __index = function (_, name)
    return function (match)
      return function (rules)
	rules.name  = name
	rules.match = match

	return hl.window_rule(rules)
      end
    end
  end
}
setmetatable(winrule, winrule)

env {
  xdg_current_desktop = 'Hyprland',
  xdg_session_type    = 'wayland',
  xdg_session_desktop = 'Hyprland',
}

env {
  gdk_backend     = 'wayland,x11,*',
  qt_qpa_platform = 'wayland;xcb',
  sdl_videodriver = 'wayland',
  clutter_backend = 'wayland',
}

env {
  qt_auto_screen_scale_factor = '1',
  qt_qpa_platformtheme        = 'qt5ct:qt6ct',
}

env {
  hyprcursor_theme = 'rose-pine-hyprcursor',
  hyprcursor_size  = '32',
  xcursor_size     = '32',
}

env.xdg_data_dirs
  = env.home .. '/.local/share/flatpak/exports/share:'
  .. '/var/lib/flatpak/exports/share:'
  .. env.xdg_data_dirs

event['hyprland.start'] = function ()
  execnow 'dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP'
end

event['hyprland.start'] = function ()
  execnow '/usr/libexec/hyprpolkitagent'
end

config.general = {
  border_size = 5,
  gaps_in     = 4,
  gaps_out    = 18,
  float_gaps  = 18,
}

config.general.col = {
  inactive_border = 0xff21202e,
  active_border   = 0xff524f67,
}

config.general.allow_tearing = true

config.decoration = {
  rounding         = 12,
  active_opacity   = 0.95,
  inactive_opacity = 0.85,
}

config.decoration.blur = {
  size   = 16,
  passes = 2,
  xray   = true,
  noise  = 0.05,
  popups = true,
}

config.decoration.shadow = {
  range        = 36,
  render_power = 2,
  color        = 0x601a1a1a
}

config.animations.enabled = false

config.dwindle.preserve_split = true
config.master.new_status      = 'master'

config.input = {
  numlock_by_default = true,
  accel_profile      = 'flat',
  repeat_rate        = 35,
  repeat_delay       = 350,
}

monitor.default = {
  mode     = 'preferred',
  position = 'auto',
  scale    = 'auto',
}

bind { submap_universal = true, locked = true, repeating = true, description = 'Brightness' } {
  ['XF86MonBrightnessUp']   = { brightnessctl:up(),   'Up'   },
  ['XF86MonBrightnessDown'] = { brightnessctl:down(), 'Down' },
}

bind { submap_universal = true, locked = true, repeating = volumectl.repeating, description = 'Volume' } {
  ['XF86AudioRaiseVolume'] = { volumectl:up(),   'Up'   },
  ['XF86AudioLowerVolume'] = { volumectl:down(), 'Down' },
}

bind { submap_universal = true, locked = true, description = 'Volume' }
['Xf86AudioMute'] = { volumectl:mute(), 'Toggle mute' }

bind { submap_universal = true, description = 'Focus workspace' } {
  ['SUPER + 1'] = { dsp.focus { workspace = '1' }, 'Main'      },
  ['SUPER + 2'] = { dsp.focus { workspace = '2' }, 'Secondary' },
  ['SUPER + 3'] = { dsp.focus { workspace = '3' }, 'Tertiary'  },
  ['SUPER + 4'] = { dsp.focus { workspace = '4' }, 'Extra'     },
  ['SUPER + G'] = { dsp.focus { workspace = '5' }, 'Gaming'    },
  ['SUPER + C'] = { dsp.focus { workspace = '6' }, 'Coding'    },
}

bind { submap_universal = true, description = 'Move window to workspace' } {
  ['SUPER + ALT + 1'] = { win.move { workspace = '1' }, 'Main'      },
  ['SUPER + ALT + 2'] = { win.move { workspace = '2' }, 'Secondary' },
  ['SUPER + ALT + 3'] = { win.move { workspace = '3' }, 'Tertiary'  },
  ['SUPER + ALT + 4'] = { win.move { workspace = '4' }, 'Extra'     },
  ['SUPER + ALT + G'] = { win.move { workspace = '5' }, 'Gaming'    },
  ['SUPER + ALT + C'] = { win.move { workspace = '6' }, 'Coding'    },
}

bind { submap_universal = true, description = 'Silently move window to workspace' } {
  ['SUPER + SHIFT + 1'] = { win.move { workspace = '1', follow = false }, 'Main'      },
  ['SUPER + SHIFT + 2'] = { win.move { workspace = '2', follow = false }, 'Secondary' },
  ['SUPER + SHIFT + 3'] = { win.move { workspace = '3', follow = false }, 'Tertiary'  },
  ['SUPER + SHIFT + 4'] = { win.move { workspace = '4', follow = false }, 'Extra'     },
  ['SUPER + SHIFT + G'] = { win.move { workspace = '5', follow = false }, 'Gaming'    },
  ['SUPER + SHIFT + C'] = { win.move { workspace = '6', follow = false }, 'Coding'    },
}

bind { submap_universal = true, description = 'Window operations' } {
  ['SUPER + F']         = { win.float      { action = 'toggle' },                      'Float'      },
  ['SUPER + SHIFT + F'] = { win.fullscreen { action = 'toggle', mode = 'fullscreen' }, 'Fullscreen' },
  ['SUPER + ALT + F']   = { win.fullscreen { action = 'toggle', mode = 'maximized'  }, 'Maximize'   },

  ['SUPER + W'] = { win.close(), 'Close' },
  ['SUPER + P'] = { win.pin(),   'Pin'   },
}

bind { submap_universal = true, description = 'Apps' } {
  ['SUPER + SPACE']        = { exec 'hyprlauncher', 'Launcher' },
  ['SUPER + RETURN']       = { exec 'ghostty',      'Terminal' },
  ['SUPER + ALT + RETURN'] = {
    exec('ghostty', {
      size  = { '(monitor_x * 0.5)', '(monitor_y * 0.5)' },
      float = true
    }),
    'Floating terminal'
  },

  ['SUPER + ALT + SPACE'] = {
    submap('launchApp', 'reset', function () bind { description = 'Launch app' } {
      ['B'] = { exec 'zen',                                                   'Browser'          },
      ['C'] = { exec('qalculate-gtk', { size = { 800, 600 }, float = true }), 'Calculator'       },
      ['F'] = { exec 'pcmanfm',                                               'File manager'     },
      ['P'] = { exec 'keepassxc',                                             'Password manager' },
      ['V'] = { exec 'virt-manager',                                          'VM manager'       },
      ['A'] = { exec 'hyprpwcenter',                                          'Audio manager'    },

      ['catchall'] = dsp.submap 'reset'
    } end),
    'Launch app'
  },
}

let (function (layouts)
    return function ()
      local layout = hl.get_config 'general.layout'

      if layouts[layout] ~= nil then
	dodsp(layouts[layout]())
      elseif layouts.default ~= nil then
	dodsp(layouts.default())
      else
	dodsp(nop())
      end
    end
end)
(function (layoutcond)
  let (function (dir)
      return layoutcond {
	scrolling = function () return layoutmsg(fmt 'focus %s' (dir)) end,
	default   = function () return dsp.focus { direction = dir }             end,
      }
  end)
  (function (focus)
    bind { description = 'Focus window' } {
      ['SUPER + H'] = { focus 'left',   'Left'  },
      ['SUPER + J'] = { focus 'down',   'Down'  },
      ['SUPER + K'] = { focus 'up',     'Up'    },
      ['SUPER + L'] = { focus 'right',  'Right' },
    }

    bind { description = 'Master layout' }
    ['SUPER + M'] = {
      layoutcond { master = function () return layoutmsg 'focusmaster' end },
      'Focus master'
    }
  end)

  let (function (args)
      return layoutcond {
	scrolling = function ()
	  return layoutmsg(fmt 'coloresize %s' (args.scrolling))
	end,
	default = function ()
	  return win.resize { x = args.normal.x, y = args.normal.y, relative = true }
	end
      }
  end)
  (function (resize)
    bind { repeating = true, description = 'Resize window' } {
      ['SUPER + ALT + H'] = { resize { scrolling = '-0.1', normal = { x = -20, y =   0 } }, 'Left'  },
      ['SUPER + ALT + J'] = { resize { scrolling = '0.7',  normal = { x =   0, y =  20 } }, 'Down'  },
      ['SUPER + ALT + K'] = { resize { scrolling = '1',    normal = { x =   0, y = -20 } }, 'Up'    },
      ['SUPER + ALT + L'] = { resize { scrolling = '+0.1', normal = { x =  20, y =   0 } }, 'Right' },
    }
  end)

  bind { description = 'Move window' } {
    ['SUPER + SHIFT + H'] = { win.move { direction = 'left'  }, 'Left'  },
    ['SUPER + SHIFT + J'] = { win.move { direction = 'down'  }, 'Down'  },
    ['SUPER + SHIFT + K'] = { win.move { direction = 'up'    }, 'Up'    },
    ['SUPER + SHIFT + L'] = { win.move { direction = 'right' }, 'Right' },
  }
end)

bind { mouse = true, description = 'Window operations (mouse)' } {
  ['SUPER + mouse:272']         = { win.drag(),   'Move'   },
  ['SUPER + SHIFT + mouse:272'] = { win.resize(), 'Resize' },
}

winrule.suppressMaximize { class = '.*' } {
  suppress_event = 'maximize'
}

winrule.fixXwaylandDragging {
  class      = '^$',
  title      = '^$',
  xwayland   = true,
  float      = true,
  fullscreen = false,
  pin        = false
}
{
  no_focus = true
}

winrule.games { class = '((steam_app_)(.+)|gamescope|osu!)' } {
  workspace  = '5',
  immediate  = true,
  rounding   = 0,
  no_anim    = true,
  no_blur    = true,
  no_shadow  = true,
  opaque     = true,
  fullscreen = true,
}

winrule.steamSubwindows { class = 'steam' } {
  workspace = '3 silent',
  float     = true,
}

winrule.steamMainwindow { title = 'Steam' } {
  tile = true
}

winrule.discord { initial_title = 'Discord' } {
  workspace = '2 silent'
}

winrule.spotify { class = 'spotify' } {
  workspace = '2 silent'
}
