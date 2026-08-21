local dsp       = hl.dsp
local exec      = dsp.exec_cmd
local win       = dsp.window
local layoutmsg = dsp.layout
local ws        = require('hyprland.workspaces').ws

bind { submap_universal = true, locked = true, repeating = true }
:set {
  -- Brightness Controls
  ['XF86MonBrightnessUp']   = exec 'brightnessctl set 10%+',
  ['XF86MonBrightnessDown'] = exec 'brightnessctl set 10%-',

  -- Audio Controls
  ['XF86AudioRaiseVolume'] = exec 'wpctl set-volume @DEFAULT_SINK@ 5%+',
  ['XF86AudioLowerVolume'] = exec 'wpctl set-volume @DEFAULT_SINK@ 5%-',
}

bind { submap_universal = true, locked = true }
:set {
  -- Mute
  ['XF86AudioMute'] = exec 'wpctl set-mute @DEFAULT_SINK@ toggle',

  -- Media Controls
  ['XF86AudioNext']                = exec 'playerctl next',
  ['XF86AudioPrev']                = exec 'playerctl prev',
  ['XF86AudioPlay&XF86AudioPause'] = exec 'playerctl play-pause',
}

bind { submap_universal = true }
:set {
  -- Switch to Workspace
  ['SUPER + 1'] = dsp.focus { workspace = '1' },
  ['SUPER + 2'] = dsp.focus { workspace = '2' },
  ['SUPER + 3'] = dsp.focus { workspace = '3' },
  ['SUPER + 4'] = dsp.focus { workspace = '4' },
  ['SUPER + G'] = dsp.focus { workspace = '5' },
  ['SUPER + C'] = dsp.focus { workspace = '6' },

  -- Move Window to Workspace (Silent)
  ['SUPER + SHIFT + 1'] = win.move { workspace = '1', follow = false },
  ['SUPER + SHIFT + 2'] = win.move { workspace = '2', follow = false },
  ['SUPER + SHIFT + 3'] = win.move { workspace = '3', follow = false },
  ['SUPER + SHIFT + 4'] = win.move { workspace = '4', follow = false },
  ['SUPER + SHIFT + G'] = win.move { workspace = '5', follow = false },
  ['SUPER + SHIFT + C'] = win.move { workspace = '6', follow = false },

  -- Move Window to Workspace
  ['SUPER + ALT + 1'] = win.move { workspace = '1', follow = true },
  ['SUPER + ALT + 2'] = win.move { workspace = '2', follow = true },
  ['SUPER + ALT + 3'] = win.move { workspace = '3', follow = true },
  ['SUPER + ALT + 4'] = win.move { workspace = '4', follow = true },
  ['SUPER + ALT + G'] = win.move { workspace = '5', follow = true },
  ['SUPER + ALT + C'] = win.move { workspace = '6', follow = true },

  -- Floating & Fullscreen Toggles
  ['SUPER + F']         = win.float      { action = 'toggle' },
  ['SUPER + SHIFT + F'] = win.fullscreen { action = 'toggle', mode = 'fullscreen' },
  ['SUPER + ALT + F']   = win.fullscreen { action = 'toggle', mode = 'maximized' },

  ['SUPER + W'] = win.kill(), -- Close Window
  ['SUPER + P'] = win.pin(),  -- Pin Window

  -- Apps
  ['SUPER + SPACE']        = exec 'rofi -show drun',
  ['SUPER + RETURN']       = exec 'kitty',
  ['SUPER + ALT + RETURN'] = exec('kitty', {
    size  = { '(monitor_x * 0.5)', '(monitor_y * 0.5)' },
    float = true
  }),

  ['SUPER + ALT + SPACE'] = dsp.submap 'launchApp'
}

-- Apps Submap
hl.define_submap('launchApp', 'reset', function ()
  bind():set {
    ['B']        = exec 'zen-browser',
    ['C']        = exec('qalculate-gtk', { size = { 800, 600 }, float = true }),
    ['F']        = exec 'pcmanfm',
    ['P']        = exec 'keepassxc',
    ['V']        = exec 'virt-manager',
    ['A']        = exec 'pavucontrol',
    ['O']        = exec('osu-lazer', { workspace = '5' }),
    ['catchall'] = dsp.submap 'reset',
  }
end)

do
  local layoutcond = function (layouts)
    return function ()
      local layout = hl.get_config 'general.layout'

      if layouts[layout] ~= nil then
        layouts[layout]()
      elseif layouts.default ~= nil then
        layouts.default()
      else
        dsp.no_op()
      end
    end
  end

  do
    local focus = function (dir)
      return layoutcond {
        scrolling = function () layoutmsg(string.format('focus %s', dir)) end,
        default   = function () dsp.focus { direction = dir } end,
      }
    end

    -- Focus Windows
    bind():set {
      ['SUPER + H'] = focus 'l',
      ['SUPER + J'] = focus 'd',
      ['SUPER + K'] = focus 'u',
      ['SUPER + L'] = focus 'r',
      ['SUPER + M'] = layoutcond { master = function () layoutmsg 'focusmaster' end },
    }
  end

  do
    local resize = function (args)
      return layoutcond {
        scrolling = function ()
          layoutmsg(string.format('colresize %s', args.scrolling))
        end,
        default = function ()
          win.resize { x = args.normal.x, y = args.normal.y, relative = true }
        end
      }
    end

    -- Resize Windows
    bind { repeating = true }
    :set {
      ['SUPER + ALT + H'] = resize { scrolling = '-0.1', normal = { x = -20, y =   0 } },
      ['SUPER + ALT + J'] = resize { scrolling = '0.7',  normal = { x =   0, y =  20 } },
      ['SUPER + ALT + K'] = resize { scrolling = '1',    normal = { x =   0, y = -20 } },
      ['SUPER + ALT + L'] = resize { scrolling = '+0.1', normal = { x =  20, y =   0 } },
    }
  end

  -- Move Windows
  bind():set {
    ['SUPER + SHIFT + H'] = win.move { direction = 'l' },
    ['SUPER + SHIFT + J'] = win.move { direction = 'd' },
    ['SUPER + SHIFT + K'] = win.move { direction = 'u' },
    ['SUPER + SHIFT + L'] = win.move { direction = 'l' },
    ['SUPER + SHIFT + P'] = layoutcond { scrolling = function () layoutmsg 'promote'    end },
    ['SUPER + SHIFT + R'] = layoutcond { dwindle   = function () layoutmsg 'movetoroot' end },
    ['SUPER + SHIFT + M'] = layoutcond {
      master = function () layoutmsg 'swapwithmaster master' end
    },
    ['SUPER + SHIFT + comma'] = layoutcond {
      scrolling = function () layoutmsg 'swapcol l' end,
      master    = function () layoutmsg 'rollprev'  end,
    },
    ['SUPER + SHIFT + period'] = layoutcond {
      scrolling = function () layoutmsg 'swapcol r' end,
      master    = function () layoutmsg 'rollnext'  end,
    },
  }

  -- Move Viewport in Scrolling Layout
  bind():set {
    ['MOD + comma']  = layoutcond { scrolling = function () layoutmsg 'move -col' end },
    ['MOD + period'] = layoutcond { scrolling = function () layoutmsg 'move +col' end },
  }
end

-- Mouse Window Controls
bind { mouse = true }
:set {
  ['SUPER + SHIFT + mouse:272'] = win.resize(), -- Resize with Mouse
  ['SUPER + mouse:272']         = win.drag(),   -- Move with Mouse
}

bind { submap_universal = true }
['SUPER + grave'] = dsp.submap 'ctl'

do
  local chlayout = function (layout)
    return function ()
      hl.config { general = { layout = layout } }
    end
  end

  hl.define_submap('ctl', 'reset', function ()
    bind():set {
      ['S']        = chlayout 'scrolling',
      ['M']        = chlayout 'master',
      ['D']        = chlayout 'dwindle',
      ['P']        = dsp.submap 'power',
      ['catchall'] = dsp.submap 'reset',
    }
  end)
end

hl.define_submap('power', 'reset', function ()
  bind():set {
    ['S']        = exec 'systemctl suspend',
    ['R']        = exec 'systemctl reboot',
    ['P']        = exec 'systemctl poweroff',
    ['catchall'] = dsp.submap 'reset',
  }
end)
