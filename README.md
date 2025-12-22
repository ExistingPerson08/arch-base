# Arch-base

Base [Arch Linux](https://archlinux.org/) container image with [bootc](https://github.com/bootc-dev/bootc) for usage in custom images. Similar for what is [Universal Blue main image](https://github.com/ublue-os/main/tree/main) to Fedora. Build every day.

<img width="2305" height="846" alt="image" src="https://github.com/user-attachments/assets/f496a2f4-0782-408c-b207-c7acdde2e5ac" />

## Building and running localy

In order to get a running arch-bootc system you can run the following steps:
```shell
just build-containerfile # This will build the containerfile and all the dependencies you need
just generate-bootable-image # Generates a bootable image for you using bootc!
```

Then you can run the `bootable.img` as your boot disk in your preferred hypervisor.
