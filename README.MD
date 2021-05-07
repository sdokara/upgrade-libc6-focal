## upgrade-libc6

As of mainline kernel versions 5.10.33 and 5.11.17, the kernel headers use GLIBC 2.33, which is not installable on 
Ubuntu older than 21.04. To overcome that, `configure.sh` script generates:

- `upgrade.sh` that upgrades GLIBC to the latest version from the `hirsute` repositories,
- `downgrade.sh` that downgrades all versions to what was previously found in the system.


**Disclaimer**: messing up the `libc-bin` and `locales` packages will make your system corrupt, as a great number 
of programs depends on the C common libraries - **use at your own risk**.
