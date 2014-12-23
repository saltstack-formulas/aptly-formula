include:
  - aptly.create_repos

{% set gpgid = salt['pillar.get']('aptly:gpg_keypair_id', '') %}
{% set gpgpassphrase = salt['pillar.get']('aptly:gpg_passphrase', '') %}

{% for repo, opts in salt['pillar.get']('aptly:repos').items() %}
publish_{{ repo }}_repo:
  cmd:
    - run
    - name: aptly publish repo -gpg-key='{{ gpgid }}' -passphrase='{{ gpgpassphrase }}' {{ repo }}
    - user: aptly
    - unless: aptly publish update -gpg-key='{{ gpgid }}' -passphrase='{{ gpgpassphrase }}' {{ opts['distribution'] }}
{% endfor %}
