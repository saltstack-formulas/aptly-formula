# Set up our Aptly mirrors

{% set gpg_command = salt['pillar.get']('aptly:gpg_command', 'gpg') %}

include:
  - aptly
  - aptly.aptly_config

{% if salt['pillar.get']('aptly:mirrors') %}
{% for mirror, opts in salt['pillar.get']('aptly:mirrors').items() %}
  {% set mirrorloop = mirror %}
  {%- set homedir = salt['pillar.get']('aptly:homedir', '/var/lib/aptly') -%}
  {%- set keyring = salt['pillar.get']('aptly:keyring', 'trustedkeys.gpg') -%}
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
      - HOME: {{ homedir }}
    - require:
      - sls: aptly.aptly_config
{% if opts['keyids'] is defined %}
{% for keyid in opts['keyids'] %}
      - cmd: add_{{ mirrorloop }}_{{ keyid }}_gpg_key
{% endfor %}

{% for keyid in opts['keyids'] %}
add_{{ mirrorloop }}_{{keyid}}_gpg_key:
  cmd.run:
    - name: { gpg_command }} --no-default-keyring --keyring {{ keyring }} --keyserver {{ opts['keyserver']|default('keys.gnupg.net') }} --recv-keys {{keyid}}
    - runas: aptly
    - unless: { gpg_command }} --list-keys --keyring {{ keyring }}  | grep {{keyid}}
{% endfor %}
  {% elif opts['keyid'] is defined %}
      - cmd: add_{{ mirror }}_gpg_key

add_{{ mirror }}_gpg_key:
  cmd.run:
    - name: { gpg_command }} --no-default-keyring --keyring {{ keyring }} --keyserver {{ opts['keyserver']|default('keys.gnupg.net') }} --recv-keys {{ opts['keyid'] }}
    - runas: aptly
    - unless: { gpg_command }} --list-keys --keyring {{ keyring }}  | grep {{ opts['keyid'] }}
  {% elif opts['key_url'] is defined %}
      - cmd: add_{{ mirror }}_gpg_key

add_{{ mirror }}_gpg_key:
  cmd.run:
    - name: { gpg_command }} --no-default-keyring --keyring {{ keyring }} --fetch-keys {{ opts['key_url'] }}
    - runas: aptly
    - unless: { gpg_command }} --list-keys --keyring {{ keyring }}  | grep {{keyid}}
  {% endif %}
{% endfor %}
{% endif %}
