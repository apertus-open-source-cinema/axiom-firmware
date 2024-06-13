#!/bin/bash

# SPDX-FileCopyrightText: © 2024 Jaro Habiger <jarohabiger@googlemail.com>
# SPDX-License-Identifier: GPL-2.0-only

sudo growpart /dev/mmcblk0 2
sudo resize2fs /dev/mmcblk0p2
