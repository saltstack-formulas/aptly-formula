# Set up our Aptly repos

include:
  - aptly
  - aptly.aptly_config

{% for repo, opts in salt['pillar.get']('aptly:repos').items() %}
  {% set homedir = salt['pillar.get']('aptly:homedir', '/var/lib/aptly') %}

create_{{ repo }}_repo:
  cmd.run:
    - name: aptly repo create -distribution="{{ opts['distribution'] }}" -comment="{{ opts['comment'] }}" {{ repo }}
    - unless: aptly repo show {{ repo }}
    - user: aptly
    - env:
      - HOME: {{ homedir }}
    - require:
      - sls: aptly.aptly_config

  {% if opts['pkgdir'] %}
    {% set numcurrentpkgs = salt['cmd.run']('aptly repo show ' ~ repo ~ ' | tail -n1 | cut -f4 -d" "', user='aptly', env="[{\'HOME\':\'' ~ homedir ~ '\'}]") %}
    {% set pkgsinpkgdir = salt['file.find']('/srv/dist/dist/repo', type='f', iregex='.*(deb|udeb|dsc)$')|count %}
    {% if numcurrentpkgs != pkgsinpkgdir %}
      {# we dont  have all the packages loaded, add all packages in homedir #}
add_{{ repo }}_pkgs:
  cmd.run:
    - name: aptly repo add {{ repo }} {{ opts['pkgdir'] }}
    - user: aptly
    - env:
      - HOME: {{ homedir }}
    - require:
      - cmd: create_{{ repo }}_repo
    {% endif %}
  {% endif %}

{% endfor %}
