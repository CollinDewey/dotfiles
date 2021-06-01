//Create Panel
var panel = new Panel;
var panelScreen = panel.screen;

//Set position and size
panel.location = "top";
panel.height = 26;
panel.width = screenGeometry(panelScreen).width;

//Application Menu
var kicker = panel.addWidget("org.kde.plasma.kicker");
kicker.currentConfigGroup = ["General"];
kicker.writeConfig("useCustomButtonImage", "true");
kicker.writeConfig("customButtonImage", "/home/collin/.icons/plasma-logo-monochrome.svg");
kicker.writeConfig("favoriteSystemActions", "");

//Global Menu, Spacer, Separator
panel.addWidget("org.kde.plasma.appmenu");
panel.addWidget("org.kde.plasma.panelspacer");
panel.addWidget("org.kde.latte.separator");

//Icons-Only Task Manager
var iconTasks = panel.addWidget("org.kde.plasma.icontasks");
iconTasks.currentConfigGroup = ["General"];
iconTasks.writeConfig("launchers", "");

//Separator
panel.addWidget("org.kde.latte.separator");

//System Tray + Hide Applications
var systemTray = panel.addWidget("org.kde.plasma.systemtray");
systemTrayPrivID = systemTray.readConfig("SystrayContainmentId");
const systemTrayPriv = desktopById(systemTrayPrivID);
systemTrayPriv.currentConfigGroup = ["General"];
const extraItems = systemTrayPriv.readConfig("extraItems").split(",");
const hiddenItems = systemTrayPriv.readConfig("hiddenItems").split(",");
extraItems.push("PreMiD1");
hiddenItems.push("PreMiD1");
extraItems.push("flameshot");
hiddenItems.push("flameshot");
systemTrayPriv.writeConfig("extraItems", extraItems);
systemTrayPriv.writeConfig("hiddenItems", hiddenItems);

//Digital Clock
var digitalClock = panel.addWidget("org.kde.plasma.digitalclock");
digitalClock.currentConfigGroup = ["Appearance"];
digitalClock.writeConfig("showDate", "false");
