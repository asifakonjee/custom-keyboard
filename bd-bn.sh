#!/bin/bash

# Define variables
XKB_LAYOUT_FILE="bn"
XKB_LAYOUT_NAME="bn"
SHORT_DESCRIPTION="bd-bn"
DESCRIPTION="Bangla (bengali)"
ISO3166ID="BD"
ISO639ID="ben"

# Copy the custom XKB layout file to the appropriate directory
echo "Copying the custom XKB layout file to /usr/share/X11/xkb/symbols/..."
sudo cp $XKB_LAYOUT_FILE /usr/share/X11/xkb/symbols/

# Check if the file was copied successfully
if [[ $? -ne 0 ]]; then
    echo "Failed to copy the custom XKB layout file. Exiting."
    exit 1
fi

# Edit the evdev.xml file to include the new layout
EVDEV_XML="/usr/share/X11/xkb/rules/evdev.xml"

echo "Editing $EVDEV_XML to include the new layout..."
sudo sed -i "/<\/layoutList>/i \
  <layout>\n\
    <configItem>\n\
      <name>$XKB_LAYOUT_NAME</name>\n\
      <!-- Keyboard indicator for Bangla layouts -->\n\
      <shortDescription>$SHORT_DESCRIPTION</shortDescription>\n\
      <description>$DESCRIPTION</description>\n\
      <countryList>\n\
        <iso3166Id>$ISO3166ID</iso3166Id>\n\
      </countryList>\n\
      <languageList>\n\
        <iso639Id>$ISO639ID</iso639Id>\n\
      </languageList>\n\
    </configItem>  \n\
  </layout>" $EVDEV_XML

# Check if the evdev.xml file was edited successfully
if [[ $? -ne 0 ]]; then
    echo "Failed to edit $EVDEV_XML. Exiting."
    exit 1
fi

# Create or edit the Xorg configuration file to make the new layout persistent
XORG_CONF="/etc/X11/xorg.conf.d/00-keyboard.conf"

echo "Creating or editing $XORG_CONF to make the new layout persistent..."
sudo mkdir -p /etc/X11/xorg.conf.d
echo 'Section "InputClass"
    Identifier "system-keyboard"
    MatchIsKeyboard "on"
    Option "XkbLayout" "'$XKB_LAYOUT_NAME'"
EndSection' | sudo tee $XORG_CONF

# Check if the Xorg configuration file was created or edited successfully
if [[ $? -ne 0 ]]; then
    echo "Failed to create or edit $XORG_CONF. Exiting."
    exit 1
fi

echo "The custom XKB layout has been integrated successfully."
echo "You can set the layout temporarily using: setxkbmap $XKB_LAYOUT_NAME"
echo "Reboot your system or restart your Xorg session to apply the changes."
