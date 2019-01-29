{% from "aptly/map.jinja" import aptly with context %}

{% if aptly.use_aptly_repo %}
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

{% if aptly.install_packages %}
aptly_packages:
  pkg.installed:
    - pkgs:
      {% for pkg in aptly.pkgs %}
      - {{ pkg }}
      {% endfor %}
    - refresh: True
{% endif %}

{% if aptly.create_user %}
aptly_user:
  group.present:
    - name: aptly
    {% if aptly.user.gid %}
    - gid: {{ aptly.user.gid }}
    {% endif %} 
  user.present:
    - name: aptly
    - shell: /bin/bash
    - home: {{ aptly.homedir }}
    {% if aptly.install_packages %}
    - require:
      - pkg: aptly_packages
    {% endif %}
    {% if aptly.user.uid %}
    - uid: {{ aptly.user.uid }}
    {% endif %}
    {% if aptly.user.gid %}
    - gid: {{ aptly.user.gid }}
    - gid_from_name: True
    {% endif %}
{% endif %}
