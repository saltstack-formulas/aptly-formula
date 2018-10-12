# Set up our Aptly mirrors

{% from "aptly/map.jinja" import aptly with context %}

include:
  - aptly
  - aptly.aptly_config

{% if salt['pillar.get']('aptly:mirrors') %}
{% for mirror, opts in salt['pillar.get']('aptly:mirrors').items() %}
  {% set mirrorloop = mirror %}
  {%- if opts['url'] is defined -%}
    {# if we have a url parameter #}
    {%- set create_mirror_cmd = "aptly mirror create -architectures='" ~ opts['architectures']|default([])|join(',') ~ "' " ~ mirror ~ " " ~ opts['url'] ~ " " ~ opts['distribution']|default('') ~ " " ~ opts['components']|default([])|join(' ') -%}
  {% elif opts['ppa'] is defined %}
    {# otherwise, if we have a ppa parameter  #}
    {%- set create_mirror_cmd = "aptly mirror create -architectures='" ~ opts['architectures']|default([])|join(',') ~ "' " ~ mirror ~ " ppa:" ~ opts['ppa'] -%}
  {% endif %}

create_{{ mirror }}_mirror:
  cmd.run:
    - name: {{ create_mirror_cmd }}
    - unless: aptly mirror show {{ mirror }}
    - runas: aptly
    - env:
      - HOME: {{ aptly.homedir }}
    - require:
      - sls: aptly.aptly_config
{% if opts['keyids'] is defined %}
{% for keyid in opts['keyids'] %}
      - cmd: add_{{ mirrorloop }}_{{ keyid }}_gpg_key
{% endfor %}

{% for keyid in opts['keyids'] %}
add_{{ mirrorloop }}_{{keyid}}_gpg_key:
  cmd.run:
    - name: {{ aptly.gpg_command }} --no-default-keyring --keyring {{ aptly.gpg_keyring }} --keyserver {{ opts['keyserver']|default('keys.gnupg.net') }} --recv-keys {{keyid}}
    - runas: aptly
    - unless: {{ aptly.gpg_command }} --list-keys --keyring {{ aptly.gpg_keyring }}  | grep {{keyid}}
{% endfor %}
  {% elif opts['keyid'] is defined %}
      - cmd: add_{{ mirror }}_gpg_key

add_{{ mirror }}_gpg_key:
  cmd.run:
    - name: {{ aptly.gpg_command }} --no-default-keyring --keyring {{ aptly.gpg_keyring }} --keyserver {{ opts['keyserver']|default('keys.gnupg.net') }} --recv-keys {{ opts['keyid'] }}
    - runas: aptly
    - unless: {{ aptly.gpg_command }} --list-keys --keyring {{ aptly.gpg_keyring }}  | grep {{ opts['keyid'] }}
  {% elif opts['key_url'] is defined %}
      - cmd: add_{{ mirror }}_gpg_key

add_{{ mirror }}_gpg_key:
  cmd.run:
    - name: {{ aptly.gpg_command }} --no-default-keyring --keyring {{ aptly.gpg_keyring }} --fetch-keys {{ opts['key_url'] }}
    - runas: aptly
    - unless: {{ aptly.gpg_command }} --list-keys --keyring {{ aptly.gpg_keyring }}  | grep {{keyid}}
  {% endif %}
{% endfor %}
{% endif %}
