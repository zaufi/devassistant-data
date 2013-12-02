{%- macro render_event_handler(tgt, n, p) -%}{% if tgt == 'view' and n in view_handlers or tgt == 'document' and n in doc_handlers %}
@kate.{{ tgt }}.{{ n }}
def _{{ n }}({{ p|join(', ') }}):
    pass


{% endif %}{%- endmacro -%}
