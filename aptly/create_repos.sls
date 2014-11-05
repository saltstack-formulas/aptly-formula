# Set up our trusty repos

include:
  - aptly
  - aptly.aptly_config

{% for repo, opts in salt['pillar.get']('aptly:repos').items() %}
create-{{ repo }}-repo:
  cmd.run:
    - name: aptly repo create -distribution="{{ opts['distribution'] }}" -comment="{{ opts['comment'] }}" {{ repo }}
    - unless: aptly repo show {{ repo }}
    - user: aptly
    - require:
      - sls: aptly.aptly_config

  {% if opts['pkgdir'] %}
add-{{ repo }}-pkgs:
  cmd.run:
    - name: aptly repo add {{ repo }} {{ opts['pkgdir'] }}
    - user: aptly
    - require:
      - cmd: create-{{ repo }}-repo
  {% endif %}

{% endfor %}