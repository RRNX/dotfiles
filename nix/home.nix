{ config, pkgs, ... }:
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
in
{
  imports = [
    (import "${home-manager}/nixos")
  ];

  fonts.fontconfig.enable = true;

  home-manager.users.hannes = {
    home.stateVersion = "23.11";
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting # Disable greeting
        zoxide init fish | source
        alias cd=z
        alias htop=btm
        alias bottom=btm
      '';
      plugins = [
        { name = "grc"; src = pkgs.fishPlugins.grc.src; }
        { name = "fzf"; src = pkgs.fishPlugins.fzf.src; }
        { name = "pure"; src = pkgs.fishPlugins.pure.src; }
        { name = "colored-man-pages"; src = pkgs.fishPlugins.colored-man-pages.src; }
      ];
    };

    home.pointerCursor = 
    let 
      getFrom = url: hash: name: {
          gtk.enable = true;
          x11.enable = true;
          name = name;
          size = 28;
          package = 
            pkgs.runCommand "moveUp" {} ''
              mkdir -p $out/share/icons
              ln -s ${pkgs.fetchzip {
                url = url;
                hash = hash;
              }} $out/share/icons/${name}
          '';
        };
    in
      getFrom 
        "https://github.com/RRNX/dotfiles/raw/master/volantes-cursors.tar.gz"
        "sha256-YawzGg5YwpeTsR5+haqM2cVPrX84fJ8Xn4e9Tk50Xo0="
        "Volantes-Cursors";


    gtk = {
      enable = true;
      theme = {
        name = "adw-gtk3";
        package = pkgs.adw-gtk3;
      };
    };

    home.sessionPath = [
      "$HOME/.rd/bin"
    ];

    home.file."firefox-gnome-theme" = {
      target = ".mozilla/firefox/default/chrome/firefox-gnome-theme";
      source = (fetchTarball "https://github.com/rafaelmardojai/firefox-gnome-theme/archive/master.tar.gz");
    };

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    programs.firefox = {
      enable = true;
      profiles.default = {
        name = "Default";
        settings = {
          "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";

          # For Firefox GNOME theme:
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "browser.tabs.drawInTitlebar" = true;
          "svg.context-properties.content.enabled" = true;
        };
        userChrome = ''
          @import "firefox-gnome-theme/userChrome.css";
          @import "firefox-gnome-theme/theme/colors/dark.css"; 
        '';
        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          privacy-badger
          bitwarden
          canvasblocker
          clearurls
          darkreader
          enhanced-github
          link-cleaner
          no-pdf-download
          qr-code-address-bar
          ublock-origin
          unpaywall
          wappalyzer
        ];
      };
    };

    nixpkgs.config.allowUnfree = true;
    programs.vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
        bbenoist.nix
        ms-python.python
        ms-azuretools.vscode-docker
        ms-vscode-remote.remote-ssh
        ms-vscode.cpptools
        vscodevim.vim
        catppuccin.catppuccin-vsc
        matangover.mypy
      ];
      userSettings = {
        "window.titleBarStyle" = "custom";
        "editor.fontFamily" = "GeistMono Nerd Font";
      };
    };

    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        "$mod" = "ALT";
        bind = [
          "$mod, Q, killactive"
          "$mod, Return, exec, kitty"
          "$mod, M, exit"
          "$mod, E, exec, firefox"
          "$mod, I, togglefloating"
          "$mod, F, fullscreen"
          "$mod, SPACE, exec, pkill rofi -show drun -show-icons || rofi -show drun -show-icons"
          "$mod, V, togglesplit"
          #""mod SHIFT, D, exec, grim -g "$(slurp)" - | swappy -f -  -o - | wl-copy"
          "$mod, h, movefocus, l"
          "$mod, l, movefocus, r"
          "$mod, k, movefocus, u"
          "$mod, j, movefocus, d"
        ]
        ++ (
          builtins.concatLists (builtins.genList (
            x: let
              ws = let
                c = (x + 1) / 10;
              in
                builtins.toString (x + 1 - (c * 10));
            in [
              "$mod, ${ws}, workspace, ${toString (x + 1)}"
              "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
            ]
          )
          10)
        );
        binde = [
          ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
          ", XF86MonBrightnessDown, exec, brightnessctl set 5-%"
          ", XF86AudioRaiserVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
          ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ];
        bindm = [
          "$mod, mouse:272, movewindow" 
          "$mod, mouse:273, resizewindow" 
        ];
        monitor = [
          "eDP-1,1920x1080@60,0x0,1"
          "desc:AOC 2460G4 0x0000C956,1920x1080@144,-1920x0,1"
          ",preferred,auto,1"
        ];
        input = {
          "kb_layout" = "de";
          touchpad = {
            "natural_scroll" = "no";
          };
        };
        general = {
          "gaps_in" = "3";
          "gaps_out" = "3";
          "border_size" = "3";
          "col.active_border" = "rgb(f5e0dc)";
          "col.inactive_border" = "rgb(0f0f0f)";
          "layout" = "dwindle";
        };
        decoration = {
          "rounding" = "3";
          
          "drop_shadow" = "no";
          "shadow_range" = "10";
          "shadow_render_power" = "30";
          "col.shadow" = "rgba(1a1a1aee)";
        };
        animations = {
          "enabled" = "yes";
          "bezier" = "myBezier, 0.05, 0.9, 0.1, 1.00";
          animation = [
            "windows, 1, 7, myBezier"
            "windowsOut, 1, 7, default, popin 80%"
            "border, 0, 10, default"
            "fade, 1, 7, default"
            "workspaces, 1, 3, default"
          ];
        };
        dwindle = {
          "pseudotile" = "yes";
          "preserve_split" = "yes";
          "no_gaps_when_only" = "true";
        };
        gestures = { "workspace_swipe" = "off"; };
        exec-once = [
          "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
          "gammastep -l 52.504575130169165:13.395872421222853"
          "waybar -b mainBar"
          "hyprcursor setcursor pointer 28"
          "hyprpaper -c /home/hannes/.config/hypr/hyprpaper.conf"
          "dunst"
        ];
        windowrule = [ "rounding 10,^(org.gnome.Nautilus)$" ];
        blurls = [ "gtk-layer-shell" ];
        env = [ "HYPRCURSOR_THEME, Volantes-Cursors" ];
        misc = {
          "layers_hog_keyboard_focus" = "true";
        };
      };
    };
    programs.waybar = {
      enable = true;
      style = ''
        * {
            font-family: "DroidSansMono Nerd Font", Cantarell, sans-serif;
            font-size: 16px;
        }

        #window {
            padding: 0 10px;
        }

        window#waybar {
            border: none;
            border-radius: 0;
            box-shadow: none;
            text-shadow: none;
            transition-duration: 0s;
            color: rgba(217, 216, 216, 1);
            background: #1a1b26; 
        } 

        #workspaces {
            margin: 0 5px;
        }

        #workspaces button {
            padding: 0 8px;
            color: #565f89;
            border: 3px solid rgba(9, 85, 225, 0);
            border-radius: 10px;
            min-width: 33px;
        }

        #workspaces button.visible {
            color: #a9b1d6;
        }

        #workspaces button.focused {
            border-top: 3px solid #7aa2f7;
            border-bottom: 3px solid #7aa2f7;
        }

        #workspaces button.urgent {
            background-color: #a96d1f;
            color: white;
        }

        #workspaces button:hover {
            box-shadow: inherit;
            border-color: #bb9af7;
            color: #bb9af7;
        }

        /* Repeat style here to ensure properties are overwritten as there's no !important and button:hover above resets the colour */

        #workspaces button.focused {
            color: #7aa2f7;
        }
        #workspaces button.focused:hover {
            color: #bb9af7;
        }

        #pulseaudio {
            /* font-size: 26px; */
        }

        #custom-recorder {
          font-size: 18px;
          margin: 2px 7px 0px 7px;
          color:#ee2e24;
        }

        #tray,
        #mode,
        #battery,
        #temperature,
        #cpu,
        #memory,
        #network,
        #pulseaudio,
        #idle_inhibitor,
        #sway-language,
        #backlight,
        #custom-storage,
        #custom-cpu_speed,
        #custom-powermenu,
        #custom-spotify,
        #custom-weather,
        #custom-mail,
        #custom-media {
            margin: 0px 0px 0px 10px;
            padding: 0 5px;
            /* border-top: 3px solid rgba(217, 216, 216, 0.5); */
        }

        /* #clock {
            margin:     0px 16px 0px 10px;
            min-width:  140px;
        } */

        #battery.warning {
            color: rgba(255, 210, 4, 1);
        }

        #battery.critical {
            color: rgba(238, 46, 36, 1);
        }

        #battery.charging {
            color: rgba(217, 216, 216, 1);
        }

        #custom-storage.warning {
            color: rgba(255, 210, 4, 1);
        }

        #custom-storage.critical {
            color: rgba(238, 46, 36, 1);
        }

        @keyframes blink {
            to {
                background-color: #ffffff;
                color: black;
            }
        }
      '';
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 40;
          modules-left = [ "hyprland/workspaces" "hyprland/mode" "hyprland/window" ];
          modules-center = [ "clock" ];
          modules-right = [ "backlight" "temperature" "cpu" "memory" "battery" "network" ];
          "hyprland/mode" = {
            format = " {}";
          };
          "hyprland/workspaces" = {
            disable-scroll = "true";
            all-outputs = "false";
            disable-markup = "false";
            format = "{icon}";
            format-icons = {
              "1" = "1 <span font='DroidSansMono Nerd Font'></span>";
              "2" = "2 <span font='DroidSansMono Nerd Font'></span>";
              "3" = "3 <span font='DroidSansMono Nerd Font'></span>";
              "4" = "4 <span font='DroidSansMono Nerd Font'></span>";
              "5" = "5 <span font='DroidSansMono Nerd Font'></span>";
              "6" = "6 <span font='DroidSansMono Nerd Font'></span>";
              "7" = "7 <span font='DroidSansMono Nerd Font'></span>";
              "8" = "8 <span font='DroidSansMono Nerd Font'></span>";
              "9" = "9 <span font='DroidSansMono Nerd Font'></span>";
              "10" = "0 <span font='DroidSansMono Nerd Font'></span>";
              };
            };
          tray = {
            icon-size = "20";
            spacing = "8";
          };
          "hyprland/window" = {
            max-length = "60";
            tooltip = "false";
          };
          clock = {
            format = "{:%a %d %b - %H:%M}";
          };
          "cpu" = {
            interval = "5";
            format = "     {}%";
            max-length = "10";
          };
          memory = {
            interval = "15";
            format = "<span font='DroidSansMono Nerd Font'></span> {used:0.1f}G/{total:0.1f}G";
          };
          battery = {
            format = "<span font='DroidSansMono Nerd Font'>{icon}</span> {capacity}%{time}";
            format-icons = [" " " " " " " " " "];
            format-time = " ({H}h{M}m)";
            format-charging = "<span font='DroidSansMono Nerd Font'></span> <span font='DroidSansMono Nerd Font'>{icon} </span>  {capacity}% - {time}";
            format-full = "<span font='DroidSansMono Nerd Font'></span> <span font='DroidSansMono Nerd Font'>{icon} </span>  Charged";
            interval = "15";
            states = {
              warning = "25";
              critical = "10";
            };
            tooltip = "false";
          };
          network = {
            format = "{icon}";
            format-alt = "<span font='DroidSansMono Nerd Font'>︁ </span> ︁{ipaddr}/{cidr} {icon}";
            format-alt-click = "click-left";
            format-wifi = "<span font='DroidSansMono Nerd Font'> </span> {essid} ({signalStrength}%)";
            format-ethernet = "<span font='DroidSansMono Nerd Font'>󰈀</span> {ifname}";
            format-disconnected = "⚠ Disconnected";
            tooltip = "false";
          };
          backlight = {
            format = "{icon} {percent}%";
            format-alt = "{icon}";
            format-alt-click = "click-left";
            format-icons = [ "" "" ];
          };
          temperature = {
            hwmon-path = "/sys/class/hwmon/hwmon4/temp1_input";
            critical-threshold = "75";
            interval = "5";
            format = "{icon} {temperatureC}°";
            tooltip = "false";
            format-icons = [
                "" # Icon: temperature-empty
                "" # Icon: temperature-quarter
                "" # Icon: temperature-half
                "" # Icon: temperature-three-quarters
                "" # Icon: temperature-full
            ];
          };
        };
      };
    };
    
    programs.zoxide.enable = true;

    home.file.".config/hypr/hyprpaper.conf".text = ''
      preload = /home/hannes/.config/wallpaper/wallpaper.png
      wallpaper = ,/home/hannes/.config/wallpaper/wallpaper.png
      splash = false
    '';

    home.file.".config/hypr/hypridle.conf".text = ''
      listener = {
        timeout = 300
        on-timeout = hyprctl dispatch dpms off
        on-resume = hyprctl dispatch dpms on
      }

      listener = {
        timeout = 1800
        on-timeout = systemctl suspend
      }
    '';

    home.file.".config/rofi/config.rasi".text = ''
      * {
          bg0:    #212121F2;
          bg1:    #2A2A2A;
          bg2:    #3D3D3D80;
          bg3:    #616161F2;
          fg0:    #E6E6E6;
          fg1:    #FFFFFF;
          fg2:    #969696;
          fg3:    #3D3D3D;

          font:   "Roboto 12";

          background-color:   transparent;
          text-color:         @fg0;

          margin:     0px;
          padding:    0px;
          spacing:    0px;
      }

      window {
          location:       center;
          width:          480;
          border-radius:  24px;
          
          background-color:   @bg0;
      }

      mainbox {
          padding:    12px;
      }

      inputbar {
          background-color:   @bg1;
          border-color:       @bg3;

          border:         2px;
          border-radius:  16px;

          padding:    8px 16px;
          spacing:    8px;
          children:   [ prompt, entry ];
      }

      prompt {
          text-color: @fg2;
      }

      entry {
          placeholder:        "Search";
          placeholder-color:  @fg3;
      }

      message {
          margin:             12px 0 0;
          border-radius:      16px;
          border-color:       @bg2;
          background-color:   @bg2;
      }

      textbox {
          padding:    8px 24px;
      }

      listview {
          background-color:   transparent;

          margin:     12px 0 0;
          lines:      8;
          columns:    1;

          fixed-height: false;
      }

      element {
          padding:        8px 16px;
          spacing:        8px;
          border-radius:  16px;
      }

      element normal active {
          text-color: @bg3;
      }

      element selected normal, element selected active {
          background-color:   @bg3;
      }

      element-icon {
          size:           1em;
          vertical-align: 0.5;
      }

      element-text {
          text-color: inherit;
      }
 
    '';
  };
}
