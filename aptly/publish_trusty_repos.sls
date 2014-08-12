include:
  - aptly.create_trusty_repos

publish_edge:
  cmd:
    - run
    - name: aptly publish repo company-edge-trusty
    - user: aptly
    - unless: aptly publish update trusty-edge
