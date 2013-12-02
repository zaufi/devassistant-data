# -*- coding: utf-8 -*-
#
# Sample Kate/Pâté plugin
#

import kate

# NOTE All functions below are not mandatory. Remove any if you don't need it...

@kate.action
def sample_action():
    # ATTENTION Function name must be the same as the
    # `name' attribute of an `Action' element in the sample_ui.rc file!
    #
    pass


@kate.init
def on_plugin_load():
    # Here you may access global or per session configuration data storage
    # via kate.configuration dict or kate.sessionConfiguration correspondingly,
    # create a toolview, or initialize some globals...
    #
    # At this point kate.mainWindow() can also be acceessed, but activeDocument()
    # and/or activeView() still undefined (None)...
    #
    pass


@kate.unload
def on_plugin_unload():
    # Do any required deinitialize work here...
    pass


# NOTE You can define document/view event handlers using corresonding decorators
# Example:
# @kate.view.textInserted
# def on_text_inserted_into_view(view, text):
#   pass
