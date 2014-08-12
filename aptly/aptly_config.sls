include:
  - aptly

include:
  - aptly

aptly_homedir:
  file:
    - directory
    - name: {{ salt['pillar.get']('aptly:homedir', '/var/lib/aptly') }}
    - user: aptly
    - group: aptly
    - mode: 755
    - require:
      - user: aptly_user

aptly_rootdir:
  file:
    - directory
    - name: {{ salt['pillar.get']('aptly:rootdir', '/var/lib/aptly/.aptly') }}
    - user: aptly
    - group: aptly
    - mode: 755
    - require:
      - file: aptly_homedir

aptly_conf:
  file:
    - managed
    - name: {{ salt['pillar.get']('aptly:homedir', '/var/lib/aptly') }}/.aptly.conf
    - source: salt://aptly/files/.aptly.conf
    - template: jinja
    - user: aptly
    - group: aptly
    - mode: 664
    - require:
      - file: aptly_homedir

aptly_gpg_key_dir:
  file:
    - directory
    - name: {{ salt['pillar.get']('aptly:homedir', '/var/lib/aptly') }}/.gnupg
    - user: aptly
    - group: aptly
    - mode: 700
    - require:
      - file: aptly_homedir

#import_gpg_pub_key:
#  cmd:
#    - run
#    - name: gpg --import {key.key}
#    - unless: 'key_name' in gpg --list-keys
#    - require:
#      - file: aptly_gpg_key_dir

#import_gpg_priv_key:
#  cmd:
#    - run
#    - name: gpg --allow-secret-key-import --import {private.key}
#    - unless: 'key_name' in gpg --list-keys
#    - require:
#      - file: aptly_gpg_key_dir
