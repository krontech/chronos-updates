Developer's Guide
=================
This document attempts to explain some of the justification and designs
behind the use of Debian on the Chronos Camera. Then we will conclude
with some examples on how to produce new Debian packages for the Chronos
camera.

What is Debian?
===============
Debian is a GNU/Linux distribution that provides software in the form of packages
that can be assembled into a complete bootable operating system. Packages are
distributed in the form of `.deb` files, and are typically downloaded from online
repositories.

Every package that is provided in a Debian operating system is denoted by a uniqe
name, and a strictly ordered version number. Packages may depend on one another,
creating a dependency tree of software that is required to create a working system.

Debootstrap
-----------
Bootstrapping a working Debian operating system from scratch is accomplished using
the `debootstrap` tool, or one of its many derivatives. This tool takes a desired
architecture and release, then downloads and installs the minimal set of packages
necessary to produce a bootable operating system.

For the Chronos camera, we use a tool known as `multistrap` to generate the root
filesystem image. This tool extends `debootstrap` by sourcing packages from
multiple repositories, allowing us to combine Chronos-specific packages with those
provided by the official Debian release.

More information on how to Debootstrap a filesystem for the Chronos camera, please
see the [Getting Started with Debian](https://github.com/krontech/chronos-updates/blob/master/doc/DEBIAN.md#creating-debian-images)
guide.

Official Documentation
----------------------
The best source of information on Debian packaging can be found in the
[Debian New Maintaiers' Guide](https://www.debian.org/doc/manuals/maint-guide/). This
document will cover nearly any technical question you might encounter about how to
package and maintain your software.

This guide will also frequently refer you to the [Debian Policy Manual](https://www.debian.org/doc/debian-policy/index.html)
for specific details.

Packaging Basics
================
There are a selection of files which must be provided for any Debian package, each of
which serves a particular purpose in controlling how packages are built and installed
into a system. These files are all located in the `debian` directory of your source
tree, and are summarized as follows:

| Filename    | Description
|-------------|-------------
| `changelog` | Defines the version, summary of changes and authorship of the Debian package.
| `compat`    | Defines the comatibility level to which the Debian build tools should adhere.
| `control`   | Defines package metadata and dependencies for build and installation.
| `copyright` | Specifies the copyright of the Debian packaging files, and the upstream sources.
| `rules`     | Makefile used to build the Debian package.

Other files may be provided for additional features and services that may be provided by
your package.

Package Versioning
------------------
The package version is controlled by the `debian/changelog` file, and must start with the name
of the source package and its version. The format of such a file might look something like
the following:

```
example-sources (1.2.3~beta55) unstable; urgency=medium

  * Some changes were made.
  * Some bugs were fixed.

 -- Joe Developer <joe@example.com>  Wed, 12 Feb 2020 19:09:09 -0900
```

Version numbers are defined in the form of `[epoch:]upstream_version[-debian_revision]`.
The `upstream_version` is the version of software as released by the upstream developers,
and may contain only alphanumerics and the `.` `+` `-` and `~` characters. The `debian_revision`
allows the Debian packaging changes to be versioned in addition to the upstream software.

The `epoch` exists only really to fix packaging errors when an older upstream version
needs to be installed in preference to a newer on that has already been packaged. Use of
the `epoch` is strongly discouraged.

Special consideration also needs to be given to the `~` character in the upstream version.
This character is always sorted early than any other character (or even the absence of a
character). This is intended to be used in pre-release tags such as alpha and beta software
that should be replaced by the final software. Likewise the `+` character can be used for
post-release tags such as patches and hotfixes that should take precedence over the
official release.

For example, the following package version comparisons should all be true:
 * `1.2.3~beta55 < 1.2.3`: Tilde character sorts lower than an empty string.
 * `1.2.3 < 1.2.3+hotfix1`: Plus character sorts higher than an empty string.
 * `1.2.3 < 2:1.0.0`: Epochs allow a reversion to older software.
 * `1.2.3 == 1.2.3.0`: Empty numbers are assumed to be zero.

A handy tool to update the changelog of a Debian package is `dch -i` which adds a new
changelog entry and increments the version number.

Package Control
---------------
A minimal package control file might look something like the following:
```
Source: example-sources
Priority: optional
Maintainer: Joe Developer <joe@example.com>
Build-Depends: debhelper (>=9)
Standards-Version: 3.9.7
Homepage: http://example.com/

Package: example-package
Architecture: all
Pre-Depends: ${misc:Pre-Depends}
Depends: ${misc:Depends}, example-dependency
Description: An example Software Package
 Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt
 ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation
 ullamco laboris nisi ut aliquip ex ea commodo consequat.
```

In this example, the first block defines metadata information about the source package
from which the software is build. Most important in this section is the `Build-Depends`
directive, which declares all the packages which must be installed on a system in order
to be able to build the package. For example, you might need `gcc` in order to compile
an executable, but the end user of your software doesn't need to install `gcc` in order
to run your executable.

The second block defines the metadata for a specific package that is built from these
sources. This blick must at least specify the name of the package that is to be built
as well as a description, and any packages that must be installed on the system in
order to run the desired software. You may specify more than one package to be built
from a single source package.

Build Rules
-----------
The building of packages is handled by the `debian/rules` file. This file uses GNU Make
for its syntax but it is used in a way that is probably unlike any Makefile you have
seen before. A minimal example is as follows:

```
#!/usr/bin/make -f
# See debhelper(7) (uncomment to enable)
# output every command that modifies files on the build system.
#export DH_VERBOSE = 1

%:
    dh $@
```

When invokes as part of the build process, the Debian packaging tools will attempt to
invoke the top level Makefile of your source project, and it will expect the standard
targets of `make clean`, `make all` and `make install` to build and install your
software onto the target system. If your Makefile follows the GNU [Makefile Conventions](https://www.gnu.org/prep/standards/html_node/Makefile-Conventions.html) then it should all just magically work, otherwise, you may
need to augment the build behavior by overriding some of the built-in rules that
are provided by [debhelper](https://manpages.debian.org/testing/debhelper/debhelper.7.en.html).

Example - dh_make
=================
`dh_make` is a handy tool that can be used to produce an empty template of the `debian`
directory when preparing to package new software. This tool relies on your shell
environment to fill in as many of the details as possible for these files. This tool
can be used as follows:

```
user@example:~$ export DEBFULLNAME="Joe Developer"
user@example:~$ export DEBEMAIL=joe@example.com
user@example:~$ cd example-sources
user@example:~/example-sources$ dh_make --native -p example-sources_1.2.3~beta55
Type of package: (single, indep, library, python)
[s/i/l/p]?
Email-Address       : joe@example.com
License             : gpl3
Package Name        : example-sources
Maintainer Name     : Joe Developer
Version             : 1.2.3~beta55
Package Type        : single
Date                : Tue, 17 Mar 2020 16:04:24 -0700
Are the details correct? [Y/n/q]
Done. Please edit the files in the debian/ subdirectory now.
```

The `--native` flag is used here to specify that the package and its debian packaging
files are maintained together in the same software release. When packaging software
that is maintained by upstream developers, you may omit this flag to keep the Debian
packaging changes separate from the unmodified sources.

Example - debuild
=================
The simplest package is one that doesn't need to build anything, and simply copies files
onto the target system. An example of software that is packaged this way is the
[chronos-http](https://github.com/krontech/chronos-http) repository. This simply defines
some dependencies, then installs some scripts and static HTML content.

Since there is no Makefile in this project, we must inform `debhelper` of the files and
directories to be installed, and where to put them on the target system. This is done
using the `debian/install` file to define the files, and the `debian/dirs` file to create
directores:

```
user@example:~/chronos-http$ cat debian/dirs
usr/share/chronos-http
usr/share/chronos-http/apidoc
usr/share/chronos-http/css
usr/share/chronos-http/js
user@example:~/chronos-http$ cat debian/install
src/* usr/share/chronos-http
scripts/99-chronos-http.conf etc/lighttpd/conf-available
```

Each line in the `debian/install` file defines a file (or files using a glob pattern) and
the destination on the target system to which is must be installed. Each line in `debian/dirs`
list exactly one directory on the target system to create. Note that all of the paths on
the target system are relative.

This particular package also includes a systemd service that must be installed and started
on boot. So the `debian/rules` file includes a change to specify that systemd helpers
should also be used:

```
#!/usr/bin/make -f
# See debhelper(7) (uncomment to enable)
# output every command that modifies files on the build system.
#export DH_VERBOSE = 1

%:
	dh $@ --with systemd
```

And we must also declare the systemd dependency in the `debian/control` file as well:

```
Source: chronos-http
Section: admin
Priority: optional
Maintainer: Owen Kirby <oskirby@gmail.com>
Build-Depends: debhelper (>=9), dh-systemd (>=1.5)
Standards-Version: 3.9.7
Homepage: http://krontech.ca/

Package: chronos-http
Architecture: all
Pre-Depends: ${misc:Pre-Depends}
Depends: ${misc:Depends}, chronos-tools, lighttpd
Description: HTTP API and Web interface for the Chronos Camera
 This package provides the HTTP API service and web interface for
 the Chronos high speed camera, and is intended to integrate with
 the lighttpd web server.
```

Once all of these peices are in place, we can now build the package using `debuild` in the
root of the source project:

```
user@example:~/chronos-http$ debuild -b -us -uc
```

The flags used here are as follows:
 * `-b`: Binary-only build, do not produce source tarballs.
 * `-us`: Unsigned-source, do not attempt to produce GPG signatures of the sources.
 * `-uc`: Unsigned-changes, do not attempt to produce GPG signatures of the build changes and manifest files.

Example - Multiple Packages and Automake
========================================
Software that needs to be compiled can simply provide, or generate, makefiles that will
do the building and installation of software. An example of such a software package is
the [chronos-cli](https://github.com/krontech/chronos-cli) repository. In this case, we
just need to augment the `debian/rules` file to include the `automake_dev` helpers:

```
#!/usr/bin/make -f
# See debhelper(7) (uncomment to enable)
# output every command that modifies files on the build system.
#export DH_VERBOSE = 1

%:
	dh $@ --with autotools_dev,systemd

override_dh_auto_configure:
	./bootstrap
	dh_auto_configure
```

In this case, we also need to add an extra step before we can `configure` the software
package, and we do so by defining an `override_dh_auto_configure` target that invokes
the `bootstrap` script that is found in the top of the source checkout.

Likewise, the `debian/control` file also includes build dependencies on automake, and
the various libraries and header files required to build and run the software:

```
Source: chronos-cli
Section: misc
Priority: optional
Maintainer: Owen Kirby <oskirby@gmail.com>
Build-Depends: debhelper (>= 9), dh-systemd (>= 1.5),
                autotools-dev, autoconf, automake,
                libtool, pkg-config,
		libglib2.0-dev,
		libdbus-1-dev, libdbus-glib-1-dev,
		libjpeg-dev,
		libgstreamer0.10-dev,
		libgstreamer-plugins-base0.10-dev,
		linux-kernel-headers
Standards-Version: 3.9.8
Homepage: https://github.com/krontech/chronos-cli

Package: chronos-video
Architecture: armel
Depends: ${shlibs:Depends}, ${misc:Depends},
        alsa-utils,
        chronos-fpga,
	gstreamer0.10-plugins-base, gstreamer0.10-plugins-good,
	gstreamer0.10-plugins-bad, gstreamer0.10-plugins-ugly
Description: Video daemon for the Chronos Camera
 GStreamer video pipeline to operate the live display, video
 playback, encoders and file saving operations for the Chronos
 high speed camera.

Package: chronos-pwrutil
Architecture: armel
Depends: ${shlib:Depends}, ${misc:Depends}
Conflicts: chronos-upower
Replaces: chronos-upower
Description: Power control daemon for the Chronos Camera
 Daemon to connect to and manage the power controller on the
 Chronos high speed camera.

Package: chronos-tools
Architecture: armel
Depends: ${shlib:Depends}, ${misc:Depends}
Description: Command line tools for the Chronos Camera
 Command line utilites for debugging, diagnostics, and recovery
 on the Chronos high speed camera.
```

Note that this one source package produces three binary packages, invoking
`make install` in the top level makefile will install all of the software.
However, the Debian packaging tools has no way to identify which of those
files belong to which of these three binary packages. When building a package
with multiple binaries, we must specify files to be included in each binary
package by adding a file named `debian/packagename.install`. This file uses
the same syntax as the `debian/install` file we have seen earliy. For
example, `debian/chronos-video.install` contains the following:

```
usr/bin/cam-pipeline
src/api/ca.krontech.chronos.conf etc/dbus-1/system.d
splash.gif var/camera
```

At this point your software is ready to be packaged. You can build it by
copying your source tree onto a Camera, satisfying its build dependencies
by running `mk-build-deps -i` and then building it with `debuild -b -us -uc`.

That last sentence probably made your skin crawl, and quite rightly so. To build a
Debian package, we must be build it on a Debian system that is running the target
architecture, and is capable of satisfying the build dependencies. While a Camera
is able to satisfy these requirements, it is not really fast enough to do it well,
but we will have to leave the topic of cross compilation for another article.

Checking Your Work
==================
Often it is helpful to inspect the results of your package build before installing
it onto a target system, especially if a packaging error could leave the system
in a broken state (eg: missing bootloader or other essential files). To take a look
at what is going to be installed by a `.deb` file, we can extract it to a temporary
directory and take a look:

```
user@example:~/$ mkdir tmp
user@example:~/$ dpkg -x example-package_1.2.3~beta55_all.deb tmp/
```

Under the hood, a `.deb` file is also an archive file, and you can extract its
contents using the `ar` tool (yes, the same one that deals with static libraries).
Inside you will find two tarballs, `control.tar.gz` which contains the package
metadata and installation hooks, and `data.tar.xz` which contains the files to be
installed onto the target filesystem.

```
user@example:~/$ mkdir tmp && cd tmp
user@example:~/tmp/$ ar -x ../example-package_1.2.3~beta55_all.deb
user@example:~/tmp/$ ls -l
total 260
drwxr-xr-x  2 user user   4096 Mar 17 17:24 .
drwxrwxr-x 31 user user   4096 Mar 17 12:10 ..
-rw-r--r--  1 user user   1722 Mar 17 17:24 control.tar.gz
-rw-r--r--  1 user user 249508 Mar 17 17:24 data.tar.xz
-rw-r--r--  1 user user      4 Mar 17 17:24 debian-binary
```

Further Reading
===============
There are some more subjects that should be given their own article to go over
in more detail than we can cover here:
 * Cross Compliation: cowbuilder and git-buildpackage
 * Python Packages: Getting to know setuptools
 * Backports: Making new software old again
 * Repositories: Sharing is caring, but trust is key.
