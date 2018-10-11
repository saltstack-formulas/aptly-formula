{% set use_aptly_repo   = salt['pillar.get']('aptly:use_aptly_repo', True) %}
{% set install_packages = salt['pillar.get']('aptly:install_packages', True) %}
{% set create_user      = salt['pillar.get']('aptly:create_user', True) %}

{% if use_aptly_repo %}
aptly_repo:
  pkgrepo.managed:
    - humanname: Aptly PPA
    - name: deb http://repo.aptly.info/ squeeze main
    - dist: squeeze
    - file: /etc/apt/sources.list.d/aptly.list
    - keyid: ED75B5A4483DA07C
    - keyserver: keys.gnupg.net
    - require_in:
      - pkg: aptly_packages
{% endif %}

{% if install_packages %}
aptly_packages:
  pkg.installed:
    pkgs:
      - aptly
      - bzip2
      - gnupg1
      - gpgv1
    - refresh: True
{% endif %}

{% if create_user %}
aptly_user:
  user.present:
    - name: aptly
    - shell: /bin/bash
    - home: {{ salt['pillar.get']('aptly:homedir', '/var/lib/aptly') }}
    {% if install_packages %}
    - require:
      - pkg: aptly_packages
    {% endif %}
    {% if salt['pillar.get']('aptly:user:uid', 0) %}
    - uid: {{ salt['pillar.get']('aptly:user:uid') }}
    {% endif %}
    {% if salt['pillar.get']('aptly:user:gid', 0) %}
    - gid: {{ salt['pillar.get']('aptly:user:gid') }}
    - gid_from_name: True
    {% endif %}
{% endif %}
