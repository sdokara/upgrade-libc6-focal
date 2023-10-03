## upgrade-libc6

As new mainline kernels are released, their kernel headers require greater versions of GLIBC which are not
available from the default repositories on older Ubuntu versions. 

To overcome that, `configure.sh` script generates:

- `upgrade.sh` that upgrades `libc6` and depending packages to the latest versions from one of the newer repositories,
- `downgrade.sh` that downgrades all versions to what was previously found in the system.


**Disclaimer**: messing up the `libc-bin` and `locales` packages will make your system corrupt, as a great number 
of programs depends on the C common libraries - **use at your own risk**.
