Package Cross Compilation
=========================
Debian packages must be built on a Debian system that is running the target
architecture, and has satisfied the Build-Deps of the source package. The
unfortunately consequence is that there is no easy way to cross-compile a
package. However, in this document we will discuss some tools we can use
that will allow us to address this problem.

pbuilder and chroot
-------------------
In order to satisfy build dependencies, it is necessary to install all the
packages listed by the `Build-Deps` directive in the `debian/control` file.
To avoid the installation of undesired packages on a developer machine, it
is recommended to create a `chroot` for the purpose of building the package.

`chroot` is a tool that allows the user to create and contain child process
within a different root directory. For the purpose of packaging we can create
a clean Debian operating system in a new directory, and use the new operating
system for the building of our package, and then discard it when complete,
without ever making changes to the host operating system. The advantage is
that it isolates the package build environment from the developer's host
system.

`pbuilder` is a tool that automates the process of creating new root
filesystems and `chroot`-ing into them for package building. You can create
a clean `chroot` with `pbuilder` as follows:
```
sudo pbuilder --create
```

You can use this base distribution to build packages without needing to
modify your host operating system by using `pdebuild` in place of `debuild`
as follows:

```
pdebuild --debbuildopts -b
```

cowbuilder - Mooooo
-------------------
`pbulder` works by creating tarballs of the pristine build environment that can
be extracted, modified and discard on each build. This tends to be inefficient,
and has a lot of overhead. The solution to this is a more modern tool known as
`cowbuilder`, which takes advantage of copy-on-write filesystem features to
eliminate this overhead and dramatically improve build times.

You can create a `chroot` located at `/var/cache/pbuilder/base-jessie-armel.cow`
with `cowbuilder` as follows:

```
sudo cowbuilder --create --distribution jessie \
    --mirror http://ftp.debian.org/debian/ \
    --basepath /var/cache/pbuilder/base-jessie-armel.cow \
    --debootstrapopts --arch --debootstrapopts armel
```

Using this new `chroot` can be acheived by adding a few arguments to `pdebuild`
as follows:
```
pdebuild --debbuildopts -b --pbuilder cowbuilder -- --basepath /var/cache/pbuilder/base-jessie-armel.cow
```

While `cowbuilder` allows us to change the architecture and distrubition that
we want to build packages for, we must still do this on a machine that is capable
of executing the desired architecture. For example, this allows an `amd64` machine
to build `i386` packages or an `armhf` machine to build `armel` packages. It will
fail if we attempt to build an `armel` package on an `amd64` machine. Fortunately,
`qemu-user-static` can come to the rescue by emulating the correct build system.

On Ubuntu, the `ubuntu-dev-tools` package provides a handy wrapper script,
`cowbuilder-dist`, that allows us to produce a foreign chroot and emulate it if 
required. The following command will create a chroot of Debian 8/jessie for the
armel architecture, and store the result in `~/pbuilder/jessie-armel-base.cow`:

```
MIRRORSITE=http://ftp.debian.org/debian/ cowbuilder-dist jessie armel create --updates-only
```

Once you have created a foreign chroot this way, it can be used by `cowbuilder`
as usual:

```
pdebuild --debbuildopts -b --pbuilder cowbuilder -- --basepath ~/pbuilder/jessie-armel-base.cow
```

A modern x86 class machine can do a reasonable job of emulating an ARM system via
`qemu`, and the performance difference between the two options isn't as drastic
as you might expect. For example, a build of the `chronos-cli` repository completes
in about 6 minutes on our Tegra-TK1 build server, and takes about 9 minutes on an
Intel i7-8650U laptop.

Care and feeding of your pet chroot
-----------------------------------
During your packaging travels, you may often encounter packages that aren't able to
build independently of one another. You might also find yourself needing to download
updates from the package repository. Here are some common solutions to these issues.

To update your chroot and keep it in sync with the latest and greatest packages in
the repository you can use the `--update` flag. This will login to the chroot and run
an `apt-get update && apt-get upgrade`:
```
sudo cowbuilder --update --distribution jessie \
    --basepath /var/cache/pbuilder/base-jessie-armel.cow
```

Sometimes you might want to make a **permanent** change to the chroot, such as the
addition of extra packages, repositories or configuration that are part of your target
system. This can be done with the `--login` and `--save` flags. For example, to install
the Krontech signing key in this chroot, you can do the following:
```
user@example.com:~$ wget http://debian.krontech.ca/apt/debian/pool/main/k/krontech-archive-keyring/krontech-archive-keyring_0.4.0_all.deb
user@example.com:~$ sudo cp krontech-archive-keyring_0.4.0_all.deb /var/cache/pbuilder/base-jessie-armel.cow
user@example.com:~$ sudo cowbuilder --login --save --distribution jessie \
    --basepath /var/cache/pbuilder/base-jessie-armel.cow 
root@example.com:/# dpkg -i krontech-archive-keyring_0.4.0_all.deb
root@example.com:/# rm krontech-archive-keyring_0.4.0_all.deb
root@example.com:/# exit
```

Such permanent changes are not recommended to resolve build dependencies between
packages that need to be built together (I am looking at **you** Qt). In this
situation, you likely don't want to upload the intermediate builds results to
the public repository until after testing them, but they still need to be
installed during build to resolve dependencies. You can resolve the problem by
creating a local package repository in which the intermediate packages can be
found, and adding this repository to the build environemnt with hook scripts.

```
user@example.com:~$ cat ~/cowbuilder-hooks/D05interm-repo
#!/bin/bash
## Install dependencies from local package repositories.
DEPSBASE=/home/user/cowbuilder-packages/
if [ -d "$DEPSBASE" ] ; then
	echo "deb [trusted=yes] file://$DEPSBASE ./" >> /etc/apt/sources.list
	apt-get update
fi
user@example.com:~$ mkdir cowbuilder-packages
user@example.com:~$ cp some-interim-package_1.2.3_all.deb cowbuilder-packages
user@example.com:~$ (cd cowbuilder-package && apt-ftparchive packages . > Packages)
user@example.com:~$ cd some-complex-package
user@example.com:~/some-complex-packages$ HOOKDIR=~/cowbuilder-hooks pdebuild --debbuildopts -b \
    --pbuilder cowbuilder -- --basepath /var/cache/pbuilder/base-jessie-armel.cow
```

And finally, if you find that many of these options start to become tedious to
type in correctly every time, you can store configuration into a `~/.pbuilderrc`
file so that they are set automatically.

As a note towards build automation, `pbuilder` normally requires `sudo` to gain
super-user privledges necessary to enter and create chroot environments. You can
permit an automated build system, such as Jenkins, to generate packages without a
root login by adding a sudoers configuration file: 
```
user@example.com:~$ cat /etc/sudoers.d/pbuilder
jenkins ALL=(ALL) SETENV:NOPASSWD:/usr/sbin/pbuilder, /usr/sbin/cowbuilder
```

git-buildpackage
----------------
Most packages produces by our build systems are actually done using `git-buildpackage`,
or `gbp` for short. This tool combines the `git` version control system with Debian
packaging, and allows us to maintain the version history of our packages as well. This
tool integrates nicely with `pbuilder` and handles the creation of the source tarball
and `.dsc` files directly from the git repository.

From a git checkout of a project that contains a `debian` directory, the syntax to
build a package is as follows:
```
gbp buildpackage --git-pbuilder --git-dist=jessie --git-arch=armel
```

This command will set `PBUILDER_DIST` to `jessie` and `PBUILDER_ARCH` to `armel` and
then rely on  the `~/.pbuilderrc` file to correctly set the `BASEPATH` and any other
options necessary to find your chroot.

Backporting
-----------
One frequent use case for `git-buildpackage` is to handle backporting of packages from
newer releases. For example, we might import and attempt to build the newer package
as follows:
```
user@example.com:~$ wget http://http.debian.net/debian/pool/main/e/example/example_version.dsc
user@example.com:~$ wget http://http.debian.net/debian/pool/main/e/example/example_version.orig.tar.xz
user@example.com:~$ wget http://http.debian.net/debian/pool/main/e/example/example_version.debian.tar.xz
user@example.com:~$ gbp import-dsc --pristine-tar example_version.dsc
user@example.com:~$ cd example
user@example.com:~/example$ gbp buildpackage --git-pbuilder --git-dist=jessie --git-arch=armel
```

If the backported package fails to build, or requires some changes for this distribution
we can simply make our changes, update the changelog and commit the result to git.
```
user@example.com:~/example$ dch -i
user@example.com:~/example$ git add some/file/changes.c
user@example.com:~/example$ git commit -m "Fix a bug for jessie-backports"
```

It is customary when backporting packages to add a suffix of `~bpoMAJOR+REV` to the
`debian_version` string to denote that this is a backported package, with `MAJOR` being
the Debian release number (8, for the case of jessie) and `REV` being incremented for
each change made for backporting. This ensures that when upgrading to a new release, the
official version of this package will still take precedence over the backported version
due to the special sorting of the `~` character.
