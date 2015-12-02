=====
aptly
=====

Formula to install and configure aptly.


.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/topics/development/conventions/formulas.html>`_.

Available states
================

.. contents::
    :local:

``aptly``
---------

Setup the Aptly repo, install the Aptly and bzip2 packages, and create the Aptly user.

``aptly.aptly_config``
----------

Set up the directories and files required for Aptly, and import the gpg keys.

``aptly.create_repos``
----------

Create the repos specified in Pillar.

``aptly.create_mirrors``
----------

Create the mirrors specified in Pillar.

``aptly.nginx``
----------

Create the sites-enabled file for Nginx.

``aptly.publish_repos``
----------

Publish the repositories.

Dependencies:

* `Nginx <https://github.com/saltstack-formulas/nginx-formula>`_
