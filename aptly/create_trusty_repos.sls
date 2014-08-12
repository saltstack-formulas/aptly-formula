# Set up our trusty repos

include:
  - aptly
  - aptly.aptly_config

create_edge_trusty_repo:
  cmd:
    - run
    - name: aptly repo create -distribution="trusty-edge" company-edge-trusty
    - unless: aptly repo show company-edge-trusty
    - user: aptly
    - require:
      - sls: aptly.aptly_config

create_test_trusty_repo:
  cmd:
    - run
    - name: aptly repo create -distribution="trusty-test" company-test-trusty
    - unless: aptly repo show company-test-trusty
    - user: aptly
    - require:
      - sls: aptly.aptly_config

create_prod_trusty_repo:
  cmd:
    - run
    - name: aptly repo create -distribution="trusty-prod" company-prod-trusty
    - unless: aptly repo show company-prod-trusty
    - user: aptly
    - require:
      - sls: aptly.aptly_config
