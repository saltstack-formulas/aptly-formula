# Set up our Aptly mirrors

include:
  - aptly
  - aptly.aptly_config

{% for mirror, opts in salt['pillar.get']('aptly:mirrors').items() %}
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
    - user: aptly
    - env:
      - HOME: {{ homedir }}
    - require:
      - sls: aptly.aptly_config
      - cmd: add_{{ mirror }}_gpg_key

  {% if opts['keyid'] is defined %}
add_{{ mirror }}_gpg_key:
  cmd.run:
    - name: gpg --no-default-keyring --keyring {{ keyring }} --keyserver {{ opts['keyserver']|default('keys.gnupg.net') }} --recv-keys {{ opts['keyid'] }}
    - user: aptly
  {% elif opts['key_url'] is defined %}
add_{{ mirror }}_gpg_key:
  cmd.run:
    - name: gpg --no-default-keyring --keyring {{ keyring }} --fetch-keys {{ opts['key_url'] }}
    - user: aptly
  {% endif %}
{% endfor %}
