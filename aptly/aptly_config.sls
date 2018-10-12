{% set gpg_command = salt['pillar.get']('aptly:gpg_command', 'gpg') %}

include:
  - aptly

aptly_homedir:
  file.directory:
    - name: {{ salt['pillar.get']('aptly:homedir', '/var/lib/aptly') }}
    - user: aptly
    - group: aptly
    - mode: 755
    - require:
      - user: aptly_user

aptly_rootdir:
  file.directory:
    - name: {{ salt['pillar.get']('aptly:rootdir', '/var/lib/aptly/.aptly') }}
    - user: aptly
    - group: aptly
    - mode: 755
    - makedirs: True
    - require:
      - file: aptly_homedir

aptly_conf:
  file.managed:
    - name: {{ salt['pillar.get']('aptly:homedir', '/var/lib/aptly') }}/.aptly.conf
    - source: salt://aptly/files/.aptly.conf.jinja
    - template: jinja
    - user: aptly
    - group: aptly
    - mode: 664
    - require:
      - file: aptly_homedir

{% if salt['pillar.get']('aptly:secure') %}
aptly_gpg_key_dir:
  file.directory:
    - name: {{ salt['pillar.get']('aptly:homedir', '/var/lib/aptly') }}/.gnupg
    - user: aptly
    - group: aptly
    - mode: 700
    - require:
      - file: aptly_homedir

{% set gpgprivfile = '{}/.gnupg/secret.gpg'.format(salt['pillar.get']('aptly:homedir', '/var/lib/aptly')) %}
# goes in a different path so it's fetchable by the pkgrepo module
{% set gpgpubfile = '{}/public/public.gpg'.format(salt['pillar.get']('aptly:rootdir', '/var/lib/aptly/.aptly')) %}
{% set gpgid = salt['pillar.get']('aptly:gpg_keypair_id', '') %}

aptly_pubdir:
  file.directory:
    - name: {{ salt['pillar.get']('aptly:rootdir', '/var/lib/aptly/.aptly') }}/public
    - user: aptly
    - group: aptly

gpg_priv_key:
  file.managed:
    - name: {{ gpgprivfile }}
    - contents_pillar: aptly:gpg_priv_key
    - user: aptly
    - group: aptly
    - mode: 700
    - require:
      - file: aptly_gpg_key_dir

gpg_pub_key:
  file.managed:
    - name: {{ gpgpubfile }}
    - contents_pillar: aptly:gpg_pub_key
    - user: aptly
    - group: aptly
    - mode: 755
    - require:
      - file: aptly_gpg_key_dir

import_gpg_pub_key:
  cmd.run:
    - name: { gpg_command }} --no-tty --import {{ gpgpubfile }}
    - runas: aptly
    - unless: { gpg_command }} --no-tty --list-keys | grep '{{ gpgid }}'
    - env:
      - HOME: {{ salt['pillar.get']('aptly:homedir', '/var/lib/aptly') }}
    - require:
      - file: aptly_gpg_key_dir

import_gpg_priv_key:
  cmd.run:
    - name: { gpg_command }} --no-tty --allow-secret-key-import --import {{ gpgprivfile }}
    - runas: aptly
    - unless: { gpg_command }} --no-tty --list-secret-keys | grep '{{ gpgid }}'
    - env:
      - HOME: {{ salt['pillar.get']('aptly:homedir', '/var/lib/aptly') }}
    - require:
      - file: aptly_gpg_key_dir
{% endif %}
