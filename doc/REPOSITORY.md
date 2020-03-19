Package Repositories
====================
Debian software is distributed using package repositores, which are a collection
of packages available online (typically hosted on an HTTP server), and manifest
files which describe where to find individual packages and their metadata. These
repository manifests are signed using GPG keys to ensure a chain of trust and
validation against tampering.

Prelude - GPG Keys
------------------
All packages that are served by a Debian repository need to be validated against
a GPG public key. The public key for the Krontech debian package repository is 
provided by the `krontech-archive-keyring` package, and can also be downloaded
directly from our repository server at http://debian.krontech.ca/krontech-archive.gpg:

```
user@example.com:~$ wget http://debian.krontech.ca/krontech-archive.gpg -qO- | gpg --keyid-format long --dry-run
pub  4096R/321CC09EC43184EA 2019-08-01 Krontech Package Signing Key <software@krontech.ca>
sub  4096R/0C5AC58A7CEF6A06 2019-08-01 [expires: 2022-07-31]
```

GPG Keys are given a finite lifetime to mitigate the damage caused by a compromise
of the private key. For these reasons, a new key should be generated every few years.
The migration to a new key can be made seamless to users by including both the
current, and previous key in the `krontech-archive-keyring` package and removing old
keys when they expire.

A good idea would be to generate and rotate the GPG keys for each major software release.

GPG Key Creation
----------------
To create a GPG keypair that can be used for package and repository signing, we can use
the `gpg --gen-key` command. We choose to configure the key as follows:
 * Key algorithm should be set to: RSA encryption with RSA signatures.
 * Key size should be at least 4096 bits.
 * Key validity time should be 3 years.
 * Real Name: Krontech Package Signing Key
 * Email Address: software@krontech.ca
 * Comment should be left empty.
 * Use a strong password to protect the secret key.

```
gpg (GnuPG) 1.4.20; Copyright (C) 2015 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Please select what kind of key you want:
   (1) RSA and RSA (default)
   (2) DSA and Elgamal
   (3) DSA (sign only)
   (4) RSA (sign only)
Your selection? 1
RSA keys may be between 1024 and 4096 bits long.
What keysize do you want? (2048) 4096
Requested keysize is 4096 bits
Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
Key is valid for? (0) 3y
Key expires at Sun 19 Mar 2023 12:52:03 PM PDT
Is this correct? (y/N) y

You need a user ID to identify your key; the software constructs the user ID
from the Real Name, Comment and Email Address in this form:
    "Heinrich Heine (Der Dichter) <heinrichh@duesseldorf.de>"

Real name: Krontech Package Signing Key
Email address: software@krontech.ca
Comment: 
You selected this USER-ID:
    "Krontech Package Signing Key <software@krontech.ca>"

Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? O
You need a Passphrase to protect your secret key.
```

At this point, you will need to wait for gpg to gather enough entropy to generate
a strong key pair. When complete it will be added to your local keyring:
```
user@example.com:~$ gpg --list-secret-keys --keyid-format LONG
/home/user/.gnupg/pubring.gpg
-----------------------------
sec   4096R/08416C4AC754B378 2020-03-19 [expires: 2023-03-19]
uid                          Krontech Package Signing Key <software@krontech.ca>
ssb   4096R/94206C81F4670702 2020-03-19
```

The public key can be exported for inclusion in the `krontech-archive-keyring`
package by using the command `gpg --armor --export <keyid>`:

```
user@example.com:~$ gpg --armor --export 08416C4AC754B378
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1

...lots and lots of base64 encoded data goes here...

-----END PGP PUBLIC KEY BLOCK-----
```

Since the loss, or compromise, of this signing key would be very bad. It is
strongly recommended to make offline backups of the secret key and its
revocation certificate, and to store them in a secure location in case of
emergency:

```
user@example.com:~$ gpg --export 08416C4AC754B378 > krontech-pubkey.gpg
user@example.com:~$ gpg --armor --export 08416C4AC754B378 > krontech-pubkey.asc
user@example.com:~$ gpg --armor --export-secret-keys 08416C4AC754B378 > krontech-secret-key.asc
user@example.com:~$ gpg --armor --gen-revoke 08416C4AC754B378 > krontech-revocation.asc
user@example.com:~$ ls -al
total 28
drwxrwxr-x 2 user user 4096 Mar 19 13:24 .
drwxrwxr-x 3 user user 4096 Mar 19 13:22 ..
-rw-rw-r-- 1 user user 3128 Mar 19 13:22 krontech-pubkey.asc
-rw-rw-r-- 1 user user 2237 Mar 19 13:22 krontech-pubkey.gpg
-rw-rw-r-- 1 user user  885 Mar 19 13:25 krontech-revocation.asc
-rw-rw-r-- 1 user user 6750 Mar 19 13:23 krontech-secret-key.asc
```

Package Repository Setup
------------------------
The Krontech package repository is hosted using the `reprepro` tool, signed using
`gpg`, and published on the internet using an HTTP server. In this example, we will
use `lighttpd` for the HTTP server. To start, let's install the required packages:

```
user@example.com:~$ apt-get install reprepro lighttpd
```

Since we intend to serve this package repository via an HTTP server, we will need
to create the top level repository directory within the HTTP document root.

```
user@example.com:~$ mkdir -p /var/www/apt/debian
user@example.com:~$ mkdir /var/www/apt/debian/conf
user@example.com:~$ touch /var/www/apt/debian/conf/distributions
```

The Krontech repository configuration for `reprepro` is as follows:
```
user@example.com:~$ cat /var/www/apt/debian/conf/distributions
Origin: debian.krontech.ca
Label: debian.krontech.ca
Codename: unstable
Architectures: armel armhf source
Components: main
Description: Chronos Package Repository (unstable)
SignWith: C43184EA
DscIndices: Sources Release . .gz

Origin: debian.krontech.ca
Label: debian.krontech.ca
Codename: voyager
Architectures: armel armhf source
Components: main
Description: Chronos Package Repository (0.4/voyager)
SignWith: C43184EA
DscIndices: Sources Release . .gz
```

In this configuration file, we are hosting two releases: `unstable` and
`voyager`. Similar to the offial Debian releases, the `unstable` release
is volatile and where active development occurs. Packages are likely to
be broken without notice in the `unstable` release. When a package is
deemed ready for testing, it is copied into the the testing release, which
we have codenamed `voyager`. When `voyager` is deemed stable, it will be
released and a new codename will be chosen for the new testing release.

The `SignWith` directive is the keyid of the GPG secret key which will be
used to sign packages and repository metadata. This secret key must be
available in the GPG keyring of the repository server in order to generate
the signatures. If necessary, it can be imported with the `gpg --import`
command.

To ensure that this repository is accessible by HTTP, and that some of the
repository internals are not exposed, we may need to adjust the server's
configuration:
```
user@example.com:~$ cat /etc/lighttpd/conf-available/debian.krontech.ca.conf
$HTTP["host"] == "debian.krontech.ca" {
	server.document-root = "/var/www/"
	dir-listing.activate = "enable"
	$HTTP["url"] =~ "apt/debian/db/" { url.access-deny = ("") }
	$HTTP["url"] =~ "apt/debian/conf/" { url.access-deny = ("") }
}
```

We can now create the initial (empty) package lists and repository structure
by doing a manual export.

```
user@example.com:~$ reprepro -b /var/www/apt/debian export unstable
user@example.com:~$ reprepro -b /var/www/apt/debian export voyager
```

You might find it helpful to set an environment variable of 
`REPREPRO_BASE_DIR=/var/www/apt/debian` to simplify the repository
commands by omitting the `-b` option.

Adding an Updating Packages
---------------------------
### Binary Packages 
To add or update a binary package in the repository, we simply invoke the
`reprepro` command as follows:
```
user@example.com:~$ reprepro includedeb unstable example-package_1.2.3~beta55_all.deb
```

You will be prompted for the passphrase to the repository signing key in order to
complete this operation. After entering the passphrase, if there exists no package
of the same name, then `example-package` will be added to the `unstable` release.
If an existing package is found, then it will be replaced with the new `.deb` file
at version `1.2.3~beta55`.

### Source Packages
Package sources include all the information necessary to rebuild the package from
scratch, as well as the build logs. To add sources to the repository, we must
provide the following files:
 * `pkgname.dsc` is the Debian Source Control file
 * `pkgname_arch.changes` contains the changelog and a file manifest.
 * `pkgname_host.build` contains the build log for the package.
 * `pkgname.tar.xz` contains the source bundle for debian native packages.
 * `pkgname.debian.tar.xz` contains patches applied to upstream packages.
 * `pkgname.orig.tar.xz` contains the source bundle for upstream packages.

Once present, the sources can be added to the repository as follows:
```
user@example.com:~$ reprepro includedsc unstable pkgname.dsc
```

Package Migration
-----------------
### Single Packages
Once packages in the `unstable` repository are deemed ready for user testing,
we can move them from the `unstable` repository into the testing repository
using the `reprepro copy` command.
```
user@example.com:~$ reprepro copy voyager unstable pkgname
```

However, more commonly we are going to migrate groups of packages at a time,
or even the entire release using glob patterns:
```
user@example.com:~$ reprepro copymatched voyager unstable 'chronos-*'
```

### Entire Releases
Before migrating the entire releases of packages, it is wise to first check
that a user on the testing release will be able to perform this upgrade, since
there is no going backwards once these packages are released. To simulate the
user's experience during this upgrade, we can first boot a camera on the
testing release, and then modify it's repository configuration to switch the
camera onto the unstable release:
```
root@chronos:~# cat /etc/apt/sources.list.d/krontech-debian.list 
deb http://debian.krontech.ca/apt/debian/ unstable main
```

Then, start the software update tool via the Util window, and attempt to update
the camera's software from the package repository. If, and only if, this update
is successful and results in a functional camera, should you procede with the
package migration.

To migrate all packages from the unstable release into testing:
```
user@example.com:~$ reprepro copymatched voyager unstable '*'
```
