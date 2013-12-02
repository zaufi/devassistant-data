[Desktop Entry]
Type=Service
ServiceTypes=Kate/PythonPlugin
X-KDE-Library={{ output }}
Name={{ name }}
Comment=Longer description for {{ name }}
{% if python2_compat or python2_only %}
X-Python-2-Compatible=true
{% endif %}
{% if python2_only %}
X-Python-2-Only=true
{% endif %}
