#!/bin/bash
TARGET_DISK="/dev/sda"

bootc install to-disk \
  --generic-image \
  --wipe-volumes \
  --filesystem xfs \
  $TARGET_DISK
