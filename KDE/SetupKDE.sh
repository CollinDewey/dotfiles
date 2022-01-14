#!/usr/bin/env bash

pushd /tmp

### Install dependencies

git clone https://github.com/KDE/plasma-desktop.git
git checkout afb390d #TEMPORARY FOR OLDER PLASMA VERSIONS (Version with .desktop)
sed -i 's/Layout.fillWidth: true/Layout.fillWidth: false/g' plasma-desktop/applets/taskmanager/package/contents/ui/main.qml
plasmapkg2 -i plasma-desktop/applets/taskmanager/package
rm -rf plasma-desktop

# Clone repo
git clone https://github.com/psifidotos/applet-latte-separator.git
# Install Latte Separator
plasmapkg2 -i applet-latte-separator
# Cleanup
rm -rf applet-latte-separator

# Clone repo
git clone https://github.com/L4ki/Bonny-Plasma-Themes.git
# Install BonnyDarkColor
mkdir $HOME/.local/share/color-schemes
mv "Bonny-Plasma-Themes/Bonny Dark Colorscheme/BonnyDarkColor.colors" $HOME/.local/share/color-schemes/Bonny-Dark-Color.colors
# Install Bonny-Kvantum
mkdir $HOME/.config/Kvantum
mv "Bonny-Plasma-Themes/Bonny Kvantum Themes/Bonny-Kvantum" $HOME/.config/Kvantum/Bonny-Kvantum
# Cleanup
rm -rf Bonny-Plasma-Themes

### Configure Theme

kwriteconfig5 --file "kdeglobals" --group "KDE" --key "widgetStyle" "kvantum"
#These don't seem to work correctly, but plasma-apply seems to work
#kwriteconfig5 --file "kcminputrc" --group "Mouse" --key "cursorTheme" "Breeze_Snow"
#kwriteconfig5 --file "kdeglobals" --group "General" --key "ColorScheme" "Bonny-Dark-Color"
plasma-apply-cursortheme Breeze_Snow
plasma-apply-colorscheme Bonny-Dark-Color
kwriteconfig5 --file "kdeglobals" --group "Icons" --key "Theme" "Papirus-Dark"
kvantummanager --set Bonny-Kvantum

### Configure KDE

# Turn off Launch Feedback
kwriteconfig5 --file "klaunchrc" --group "FeedbackStyle" --key "BusyCursor" false
# Change default browser to Firefox
#kwriteconfig5 --file "kdeglobals" --group "General" --key "BrowserApplication" "firefox.desktop"
# Change single click to false
kwriteconfig5 --file "kdeglobals" --group "KDE" --key "SingleClick" false
# Force Font DPI because X11 is funny
kwriteconfig5 --file "kcmfonts" --group "General" --key "forceFontDPI" 96
# Disable special corners
kwriteconfig5 --file "kwinrc" --group "Effect-PresentWindows" --key "BorderActivateAll" 9
kwriteconfig5 --file "kwinrc" --group "TabBox" --key "BorderActivate" 9
# Configure locking
kwriteconfig5 --file "kscreenlockerrc" --group "Daemon" --key "LockOnResume" false
kwriteconfig5 --file "kscreenlockerrc" --group "Daemon" --key "Autolock" false
# Wobbly Windows
kwriteconfig5 --file "kwinrc" --group "Plugins" --key "wobblywindowsEnabled" true
# Setup 4 desktops
kwriteconfig5 --file "kwinrc" --group "Desktops" --key "Number" 4
kwriteconfig5 --file "kwinrc" --group "Desktops" --key "Rows" 2
# Change Titlebar Buttons
kwriteconfig5 --file "kwinrc" --group "org.kde.kdecoration2" --key "ButtonsOnLeft" ""
kwriteconfig5 --file "kwinrc" --group "org.kde.kdecoration2" --key "ButtonsOnRight" "SBFIAX"
# Change moving window to Alt
kwriteconfig5 --file "kwinrc" --group "MouseBindings" --key "CommandAllKey" "Alt"

git clone https://github.com/LegitMagic/dotfiles.git dotfiles
kpackagetool5 -t Plasma/LayoutTemplate --install dotfiles/KDE/LegitMagicPanel
rm -rf dotfiles

popd

echo "Logout and back in"

#To maybe remove all widgets and add the LegitMagicPanel?
#https://unix.stackexchange.com/questions/141634/how-can-i-run-a-kde-plasma-script-from-command-line-without-gui
