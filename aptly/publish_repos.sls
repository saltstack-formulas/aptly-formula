include:
  - aptly.create_repos

{% set gpgid = salt['pillar.get']('aptly:gpg_keypair_id', '') %}
{% set gpgpassphrase = salt['pillar.get']('aptly:gpg_passphrase', '') %}
{% for repo, opts in salt['pillar.get']('aptly:repos').items() %}
  {% set components_list = opts['components']|join(',') %}
  {% for distribution in opts['distributions'] %}
    {% set repo_list = [] %}
    {% for component in opts['components'] %}
      {% if repo_list.append(repo + '_' + distribution + '_' + component) %} {% endif %}
    {% endfor %}
publish_{{ repo }}_{{ distribution }}_repo:
  cmd.run:
    # NOTE: You may have to run this command manually the first time. The next
    # version of aptly is supposed to have a -batch option to pass -no-tty to
    # the gpg calls.
    - name: aptly -batch=true publish repo -distribution="{{ distribution }}" -component="{{ components_list }}" -gpg-key='{{ gpgid }}' -passphrase='{{ gpgpassphrase }}' {{ repo_list|join(' ') }}
    - user: aptly
    - env:
      - HOME: {{ salt['pillar.get']('aptly:homedir', '/var/lib/aptly') }}
    # unless is 2014.7 only, on 2014.1 it doesn't run and you just get an error
    # saying the repo has already been published
    - unless: aptly -batch=true publish update -gpg-key='{{ gpgid }}' -passphrase='{{ gpgpassphrase }}' {{ distribution }}
  {% endfor %}
{% endfor %}
