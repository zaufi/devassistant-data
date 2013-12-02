# -*- coding: utf-8 -*-
#
# Kate/Pâté plugin: {{ name }}
#
# NOTE Name of this python module must be specified as X-KDE-Library property
# of katepate_{{ output }}.desktop file!
#

import kate

{% if action %}
@kate.action
def {{ action }}():
    # ATTENTION Function name must be the same as the
    # `name' attribute of an `Action' element in the {{ output }}_ui.rc file!
    pass


{% endif -%}
{%- from 'render_handler.py.tpl' import render_event_handler with context -%}
{{ render_event_handler('view', 'contextMenuAboutToShow', ['view', 'menu']) }}
{{ render_event_handler('view', 'cursorPositionChanged', ['view', 'cursor']) }}
{{ render_event_handler('view', 'focusIn', ['view']) }}
{{ render_event_handler('view', 'focusOut', ['view']) }}
{{ render_event_handler('view', 'horizontalScrollPositionChanged', ['view']) }}
{{ render_event_handler('view', 'informationMessage', ['view', 'text']) }}
{{ render_event_handler('view', 'mousePositionChanged', ['view', 'cursor']) }}
{{ render_event_handler('view', 'selectionChanged', ['view']) }}
{{ render_event_handler('view', 'textInserted', ['view', 'cursor', 'text']) }}
{{ render_event_handler('view', 'verticalScrollPositionChanged', ['view', 'cursor']) }}
{{ render_event_handler('view', 'viewEditModeChanged', ['view', 'mode']) }}
{{ render_event_handler('view', 'viewModeChanged', ['view']) }}
{{ render_event_handler('document', 'aboutToClose', ['doc']) }}
{{ render_event_handler('document', 'aboutToReload', ['doc']) }}
{{ render_event_handler('document', 'documentNameChanged', ['doc']) }}
{{ render_event_handler('document', 'documentSavedOrUploaded', ['doc', 'flag']) }}
{{ render_event_handler('document', 'documentUrlChanged', ['doc']) }}
{{ render_event_handler('document', 'exclusiveEditEnd', ['doc']) }}
{{ render_event_handler('document', 'exclusiveEditStart', ['doc']) }}
{{ render_event_handler('document', 'highlightingModeChanged', ['doc']) }}
{{ render_event_handler('document', 'modeChanged', ['doc']) }}
{{ render_event_handler('document', 'modifiedChanged', ['doc']) }}
{{ render_event_handler('document', 'reloaded', ['doc']) }}
{{ render_event_handler('document', 'textChanged', ['doc', 'old_range', 'old_text', 'new_range']) }}
{{ render_event_handler('document', 'textInserted', ['doc', 'rng']) }}
{{ render_event_handler('document', 'textRemoved', ['doc', 'rng', 'text']) }}
{{ render_event_handler('document', 'viewCreated', ['doc', 'view']) }}

{%- if load %}
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


{% endif %}
{#
 # kate: hl python;
 #}
