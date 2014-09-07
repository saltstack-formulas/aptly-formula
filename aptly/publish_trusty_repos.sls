include:
  - aptly.create_trusty_repos

publish_edge:
  cmd:
    - run
    - name: aptly publish repo {{ salt['pillar.get']('aptly:organization', 'company' }}-edge-trusty
    - user: aptly
    - unless: aptly publish update trusty-edge

publish_test:
  cmd:
    - run
    - name: aptly publish repo {{ salt['pillar.get']('aptly:organization', 'company' }}-test-trusty
    - user: aptly
    - unless: aptly publish update trusty-test

publish_prod:
  cmd:
    - run
    - name: aptly publish repo {{ salt['pillar.get']('aptly:organization', 'company' }}-prod-trusty
    - user: aptly
    - unless: aptly publish update trusty-prod
