include:
  - nginx
  - nginx.config

aptly_site:
  file:
    - managed
    - name: /etc/nginx/sites-enabled/aptly
    - source: salt://aptly/files/aptly.jinja
    - mode: 644
    - user: root
    - group: root
    - watch_in:
      - service: nginx
