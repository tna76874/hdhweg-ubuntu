# Ansible role for podman

Manage services and containers with podman

[![CircleCI](https://img.shields.io/circleci/build/github/chasinglogic/ansible-role-podman/master?style=flat-square)](https://circleci.com/gh/chasinglogic/ansible-role-podman)

Usage
-----

On Ubuntu (22.04 / 24.04) the role installs:

* the Ubuntu podman packages (`podman_tools`) plus `uidmap nftables curl fuse3` as a base
  (helpers, AppArmor profile, default config),
* the current [podman-static](https://github.com/mgoltzsche/podman-static) release to
  `/usr/local` (`podman_static_version: latest` or a fixed tag). The bundled
  `fusermount3` is **not** installed, so `/usr/bin/fusermount3` (setuid) keeps working
  for FUSE apps like Cryptomator.

**Repairing the old state:** Earlier versions of this role used the Kubic/libcontainers
repository (packages with epoch `100:`). If such a state is detected (repo files or
epoch-100 packages), the role purges the packages, removes repo/key/pin files,
`/etc/containers`, old `/usr/local` podman binaries and, with
`podman_legacy_reset_storage: true` (default), **all podman containers, images and
volumes** of root and of the users in `podman_users` (empty = all regular users).
Afterwards it installs as above. On a clean system none of this runs.

Rootless setup: subuid/subgid ranges are added for those users if missing, and the
AppArmor `podman` profile is extended to `/usr/local/bin/podman`.

Additionally, it can deploy and configure podman containers as SystemD services.

Example Playbook
----------------

```yaml
- hosts: all
  roles:
    - role: podman
```


Automatic Service Deployment
----------------------------

Podman containers meant to run as services are relatively
homogeneous. For this reason this role provides a variable which can
be used to deploy and configure containers as SystemD services. More
complex use cases like configure multiple containers as a pod are not
yet supported. To use this feature for your host define a variable
`podman_services` which is a list of maps that have the following
structure:

```yaml
podman_services:
    ## Podman Variables
    #
    # Required: The image name to download
  - image_name: nginx
    # Optional: The tag to download. This often corresponds to
    # version, defaults to 'latest'
    image_tag: mainline
    # Optional: Description that will be added to the SystemD service file
    description: Web host
    # Optional: List of ports to publish. Takes the same form as the
    # podman CLI that is to say: host-port:container-port. This is
    # just piped directly to the '--publish' flag so binding IPs work
    # as well (ex. '127.0.0.1:8080:80'). Defaults to none.
    publish:
      - '80:80'
    # Optional: String name of the network to be passed as the --network flag.
    # If the network does not exist it will be created. This can be used to allow
    # multiple services to network with each other. See Networking for caveats
    network: somenetwork
    # Optional: List of volumes to mount. Takes the same form as the
    # podman CLI host-directory:container-directory and as shown below
    # mount options are allowed.
    volumes:
      - '/tmp:/usr/share/nginx/html:ro'
    # Optional: Define a hostname for podman's hostname flag. Set's
    # the containers hostname, default is none.
    hostname: chasinglogic.io
    # Optional: A list of secrets to mount. Secrets will not be created
    # automatically. The only required field if used is name. The other
    # values have defaults as specified in podman documentation
    # https://docs.podman.io/en/v4.6.0/markdown/options/secret.html
    secrets:
      - name: secret
        type: mount
        target: /run/secrets/secret
        uid: 0
        gid: 0
        mode: 0
    # Optional: A list of environment variables to add to the
    # container.  Default is none.
    env_vars:
      - SOME_VAR=SOME_VALUE
    # Optional: A list of arbitrary arguments as strings which will be added before the image name.
    flags:
      - '--cap-add=NET_ADMIN'

    ## SystemD Variables
    #
    # Optional: Define the restart policy for this service. Default is always
    restart: always
    # Optional: Define the time to wait between restarts of this service in seconds. Default is 30
    restart_sec: 30
    # Optional: Define the actual name used for the SystemD
    # service. {{ Defaults to image_name + '-podman' }}
    service_name: nginx
    # Optional: Define the targets / services this SystemD service
    # must start after. This is a YAML list not a string.
    after:
      - network.target
    # Optional: Define the timeout for starting this SystemD
    # service. For valid values see 'man systemd.service'. Defaults to
    # 5 minutes.
    timeout_start_sec: 5m
    # Optional: Define an install section for the SystemD
    # service. Currently only wanted_by is supported. See 'man
    # systemd.unit' for a description of this section. Default is none
    # and most users should not need this.
    install:
      wanted_by:
        - multi-user.target
    # Optional: define the user and group for the service
    # file. Default is omission which is equivalent to root on most
    # systems.
    user: root
    group: root
```

### Networking

At this time Ansible does not provide a podman networking module analogous to
`docker_network`. If you are using the network option on your container you'll
need to ensure the network exists before this role runs. In the future when
podman networking support is added to Ansible this role will ensure it's
created.

Development
-----------

When developing it is best to use the converge and verify stages like so:

```
make converge verify
```



License
-------

[MIT](LICENSE)
