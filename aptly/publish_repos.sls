include:
  - aptly.create_repos

{% set gpgid = salt['pillar.get']('aptly:gpg_keypair_id', '') %}
{% set gpgpassphrase = salt['pillar.get']('aptly:gpg_passphrase', '') %}

{% for repo, opts in salt['pillar.get']('aptly:repos', {}).items() %}
publish_{{ repo }}_repo:
  cmd.run:
  {% if not salt['pillar.get']('aptly:install_nightly', False) %}
    - name: aptly publish repo -gpg-key='{{ gpgid }}' -passphrase='{{ gpgpassphrase }}' {{ repo }}
    - unless: aptly publish update -gpg-key='{{ gpgid }}' -passphrase='{{ gpgpassphrase }}' {{ opts['distribution'] }}
  {% else %}
    - name: aptly -batch=true publish repo -gpg-key='{{ gpgid }}' -passphrase='{{ gpgpassphrase }}' {{ repo }}
    - unless: aptly -batch=true publish update -gpg-key='{{ gpgid }}' -passphrase='{{ gpgpassphrase }}' {{ opts['distribution'] }}
  {% endif %}
    - user: aptly
{% endfor %}
