aptly_repo:
  pkgrepo.managed:
    - humanname: Aptly PPA
{% if not salt['pillar.get']('aptly:install_nightly', False) %}
    - name: deb http://repo.aptly.info/ squeeze main
    - dist: squeeze
{% else %}
    - name: deb http://repo.aptly.info/ nightly main
    - dist: nightly
{% endif %}
    - file: /etc/apt/sources.list.d/aptly.list
    - keyid: 2A194991
    - keyserver: keys.gnupg.net
    - require_in:
      - pkg: aptly

aptly:
  pkg.latest:
    - name: aptly
    - refresh: True

# dependency for publishing
bzip2:
  pkg.installed

aptly_user:
  user.present:
    - name: aptly
    - shell: /bin/bash
    - home: {{ salt['pillar.get']('aptly:homedir', '/var/lib/aptly') }}
    - require:
      - pkg: aptly
