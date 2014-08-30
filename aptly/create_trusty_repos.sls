# Set up our trusty repos

include:
  - aptly
  - aptly.aptly_config

create_edge_trusty_repo:
  cmd:
    - run
    - name: aptly repo create -distribution="trusty-edge" {{ salt['pillar.get']('aptly:organization', 'company' }}-edge-trusty
    - unless: aptly repo show {{ salt['pillar.get']('aptly:organization', 'company' }}-edge-trusty
    - user: aptly
    - require:
      - sls: aptly.aptly_config

create_test_trusty_repo:
  cmd:
    - run
    - name: aptly repo create -distribution="trusty-test" {{ salt['pillar.get']('aptly:organization', 'company' }}-test-trusty
    - unless: aptly repo show {{ salt['pillar.get']('aptly:organization', 'company' }}-test-trusty
    - user: aptly
    - require:
      - sls: aptly.aptly_config

create_prod_trusty_repo:
  cmd:
    - run
    - name: aptly repo create -distribution="trusty-prod" {{ salt['pillar.get']('aptly:organization', 'company' }}-prod-trusty
    - unless: aptly repo show {{ salt['pillar.get']('aptly:organization', 'company' }}-prod-trusty
    - user: aptly
    - require:
      - sls: aptly.aptly_config
