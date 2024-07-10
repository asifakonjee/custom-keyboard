#!/bin/bash

# Define variables
XKB_LAYOUT_FILE="bn"
XKB_LAYOUT_NAME="bn"
SHORT_DESCRIPTION="bd-bn"
DESCRIPTION="Bangla (bengali)"
ISO3166ID="BD"
ISO639ID="ben"

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Copy the custom XKB layout file to the appropriate directory
echo -e "${YELLOW}Copying the custom XKB layout file to /usr/share/X11/xkb/symbols/...${NC}"
sudo cp $XKB_LAYOUT_FILE /usr/share/X11/xkb/symbols/

# Check if the file was copied successfully
if [[ $? -ne 0 ]]; then
    echo -e "${RED}Failed to copy the custom XKB layout file. Exiting.${NC}"
    exit 1
fi

# Edit the evdev.xml file to include the new layout
EVDEV_XML="/usr/share/X11/xkb/rules/evdev.xml"

echo -e "${YELLOW}Editing $EVDEV_XML to include the new layout...${NC}"
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
    echo -e "${RED}Failed to edit $EVDEV_XML. Exiting.${NC}"
    exit 1
fi

# Prompt user for creating or editing the Xorg configuration file
echo -e "${RED}Do you want to create or edit the Xorg configuration file to make the new layout persistent by default? (y/n): ${NC}"
read choice
case "$choice" in 
  y|Y|yes|Yes|YES )
    # Create or edit the Xorg configuration file to make the new layout persistent
    XORG_CONF="/etc/X11/xorg.conf.d/00-keyboard.conf"
    echo -e "${YELLOW}Creating or editing $XORG_CONF to make the new layout persistent...${NC}"
    if [ ! -d /etc/X11/xorg.conf.d ]; then
        sudo mkdir -p /etc/X11/xorg.conf.d
    fi

    # Append the new configuration to the Xorg configuration file
    cat <<EOL | sudo tee -a $XORG_CONF
Section "InputClass"
    Identifier "system-keyboard"
    MatchIsKeyboard "on"
    Option "XkbLayout" "$XKB_LAYOUT_NAME"
EndSection
EOL

    # Check if the Xorg configuration file was created or edited successfully
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Failed to create or edit $XORG_CONF. Exiting.${NC}"
        exit 1
    fi

    echo -e "${GREEN}The custom XKB layout has been integrated successfully.${NC}"
    echo -e "${YELLOW}You can set the layout temporarily using: setxkbmap $XKB_LAYOUT_NAME${NC}"
    echo -e "${YELLOW}Reboot your system or restart your Xorg session to apply the changes.${NC}"
    ;;
  n|N|no|No|NO )
    echo -e "${YELLOW}Skipping the creation or editing of the Xorg configuration file.${NC}"
    ;;
  * )
    echo -e "${RED}Invalid choice. Please run the script again and choose 'y' or 'n'.${NC}"
    exit 1
    ;;
esac
