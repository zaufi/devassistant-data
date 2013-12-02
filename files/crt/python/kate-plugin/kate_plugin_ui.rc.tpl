<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE kpartgui>
<gui name="{{ output }}"
     version="1"
     xmlns="http://www.kde.org/standards/kxmlgui/1.0"
     xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
     xsi:schemaLocation="http://www.kde.org/standards/kxmlgui/1.0
                         http://www.kde.org/standards/kxmlgui/1.0/kxmlgui.xsd">
    <MenuBar>
        <Menu name="pate"><text>&amp;Pate</text>
            <!-- NOTE Also consider to add (some of) the following attributes:
                'shortcut', 'icon', 'whatsThis', 'toolTip', 'iconText', 'priority'
                -->
            <Action name="{{ action }}"
                    text="{{ action | title }}"
                    group="bottom_tools_operations" />
        </Menu>
    </MenuBar>
</gui>
<!-- kate: indent-width 4; -->
