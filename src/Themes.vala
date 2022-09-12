/*
* Copyright 2020 elementary, Inc. (https://elementary.io)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License version 3, as published by the Free Software Foundation.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/

public class Terminal.Themes {
    public const string DARK = "dark";
    public const string HIGH_CONTRAST = "high-contrast";
    public const string LIGHT = "solarized-light";
    public const string CUSTOM = "custom";
    public const int PALETTE_SIZE = 19;

    static construct {
        Application.settings.changed["theme"].connect (() => {
            switch (Application.settings.get_string ("theme")) {
                case (HIGH_CONTRAST):
                    Application.settings.set_boolean ("prefer-dark-style", false);
                    break;
                case (LIGHT):
                    Application.settings.set_boolean ("prefer-dark-style", false);
                    break;
                case (DARK):
                    Application.settings.set_boolean ("prefer-dark-style", true);
                    break;
            }
        });
    }

    // format is color01:color02:...:color16:background:foreground:cursor
    public static Gdk.RGBA[] get_rgba_palette (string theme) {
        var string_palette = get_string_palette (theme);
        bool settings_valid = string_palette.length == PALETTE_SIZE;

        var rgba_palette = new Gdk.RGBA[PALETTE_SIZE];
        for (int i = 0; i < PALETTE_SIZE; i++) {
            var new_color = Gdk.RGBA ();
            // If custom palette invalid use a fallback one
            if (!new_color.parse (string_palette[i])) {
                critical ("Color %i '%s' is not valid - replacing with default", i, string_palette[i]);
                settings_valid = false;

                var fallback_palette = get_string_palette (
                    Application.settings.get_boolean ("prefer-dark-style") ? DARK : LIGHT
                );
                string_palette[i] = fallback_palette[i];
                new_color.parse (fallback_palette[i]);
            }

            rgba_palette[i] = new_color;
        }

        if (!settings_valid) {
            /* Remove invalid colors from setting */
            Application.settings.set_string ("palette", string.joinv (":", string_palette));
        }

        return rgba_palette;
    }

    private static string[] get_string_palette (string theme) {
        var string_palette = new string[PALETTE_SIZE];
        switch (theme) {
            case (HIGH_CONTRAST):
                string_palette = {
                    "#EEE8D5", "#DC322F", "#859900", "#B58900", "#268BD2", "#D33682", "#2AA198", "#073642",
                    "#93A1A1", "#CB4B16", "#93A1A1", "#839496", "#657B83", "#6C71C4", "#586E75", "#002B36",
                    "#FFFFFF", "#333333", "#839496"
                };
                break;
            case (LIGHT):
                string_palette = {
                    "#EEE8D5", "#DC322F", "#859900", "#B58900", "#268BD2", "#D33682", "#2AA198", "#073642",
                    "#93A1A1", "#CB4B16", "#93A1A1", "#839496", "#657B83", "#6C71C4", "#586E75", "#002B36",
                    "#FDF6E3", "#657B83", "#839496"
                };
                break;
            case (DARK):
                string_palette = {
                    "#073642", "#DC322F", "#859900", "#B58900", "#268BD2", "#D33682", "#2AA198", "#EEE8D5",
                    "#586E75", "#CB4B16", "#93A1A1", "#839496", "#657B83", "#6C71C4", "#586E75", "#FDF6E3",
                    "#002B36", "#839496", "#839496"
                };
                break;
            case (CUSTOM):
                string_palette = Application.settings.get_string ("palette").split (":");
                string_palette += Application.settings.get_string ("background");
                string_palette += Application.settings.get_string ("foreground");
                string_palette += Application.settings.get_string ("cursor-color");
                break;
        }

        return string_palette;
    }
}
