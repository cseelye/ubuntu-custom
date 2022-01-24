Executable files in this directory will be run in lexigraphical order, in the context of the chroot. This provides the ability to modify the target disk image.

Portions of the `build-custom-iso` script are implemented here as hooks. The hooks with `REQUIRED` in the name are important to setup and teardown the chroot correctly, so they should remain the first/last hooks, and be very careful about modifying them.
