# Set up our Aptly repos

include:
  - aptly
  - aptly.aptly_config

{% for repo, opts in salt['pillar.get']('aptly:repos').items() %}
create_{{ repo }}_repo:
  cmd.run:
    - name: aptly -batch=true repo create -distribution="{{ opts['distribution'] }}" -comment="{{ opts['comment'] }}" {{ repo }}
    - unless: aptly -batch=true repo show {{ repo }}
    - user: aptly
    - env:
      - HOME: {{ salt['pillar.get']('aptly:homedir', '/var/lib/aptly') }}
    - require:
      - sls: aptly.aptly_config

  {% if opts['pkgdir'] %}
add_{{ repo }}_pkgs:
  cmd.run:
    - name: aptly -batch=true repo add {{ repo }} {{ opts['pkgdir'] }}
    - user: aptly
    - env:
      - HOME: {{ salt['pillar.get']('aptly:homedir', '/var/lib/aptly') }}
    - require:
      - cmd: create_{{ repo }}_repo
  {% endif %}

{% endfor %}
