# Set up our Aptly repos

include:
  - aptly
  - aptly.aptly_config

{% for repo, opts in salt['pillar.get']('aptly:repos').items() %}
  {% set homedir = salt['pillar.get']('aptly:homedir', '/var/lib/aptly') %}
  {% for distribution in opts['distributions'] %}
    {% for component in opts['components'] %}
      {% set repo_name = repo + '_' + distribution + '_' + component %}
create_{{ repo_name }}_repo:
  cmd.run:
    - name: aptly repo create -distribution="{{ distribution }}" -comment="{{ opts['comment'] }}" -component="{{ component }}" {{ repo_name }}
    - unless: aptly repo show {{ repo_name }}
    - runas: aptly
    - env:
      - HOME: {{ homedir }}
    - require:
      - sls: aptly.aptly_config

      {% if opts.get('pkgdir', false) %}
{{ opts['pkgdir'] }}/{{ distribution }}/{{ component }}:
  file.directory:
    - user: root
    - group: root
    - mode: 777
    - makedirs: True
        {% set numcurrentpkgs = salt['cmd.run']('aptly repo show ' ~ repo_name ~ ' | tail -n1 | cut -f4 -d" "', user='aptly', env="[{\'HOME\':\'' ~ homedir ~ '\'}]") %}
        {% set pkgsinpkgdir = salt['file.find']('/srv/dist/dist/repo', type='f', iregex='.*(deb|udeb|dsc)$')|count %}
        {% if numcurrentpkgs != pkgsinpkgdir %}
          {# we dont  have all the packages loaded, add all packages in opts['pkgdir'] #}
add_{{ repo_name }}_pkgs:
  cmd.run:
    - name: aptly repo add -force-replace=true -remove-files=true {{ repo_name }} {{ opts['pkgdir'] }}/{{ distribution }}/{{ component }}
    - runas: aptly
    - env:
      - HOME: {{ homedir }}
    - onlyif:
      - find {{ opts['pkgdir'] }}/{{ distribution }}/{{ component }} -type f -mindepth 1 -print -quit | grep -q .
    - require:
      - cmd: create_{{ repo_name }}_repo
        {% endif %}
      {% endif %}
    {% endfor %}
  {% endfor %}
{% endfor %}
