## upgrade-libc6

As of mainline kernel versions 5.10.33 and 5.11.17, the kernel headers use GLIBC 2.33, which is not installable on 
Ubuntu older than `hirsute` (21.04).
Also, as of 5.13.15 and 5.14.3, the kernel headers use GLIBC 2.34, which is not installable on Ubuntu older than 
`impish` (21.10).

To overcome that, `configure.sh` script generates:

- `upgrade.sh` that upgrades GLIBC to the latest version from the `hirsute` or `impish` repositories,
- `downgrade.sh` that downgrades all versions to what was previously found in the system.


**Disclaimer**: messing up the `libc-bin` and `locales` packages will make your system corrupt, as a great number 
of programs depends on the C common libraries - **use at your own risk**.
