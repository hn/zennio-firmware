
# Zennio KNX touch panel firmware

## Preamble

Zennio produces a variety of KNX devices (touch panels, switches, actuators, ...) mainly for the real estate sector.

## Hardware

Their Znn touch panel line of products uses a [i.MX25](https://www.nxp.com/docs/en/fact-sheet/IMX25INDFS.pdf)
microprocessor (ARM 926EJ).

## Software

The firmware of Znn touch panel devices is available for download at
the [Zennio product website](https://www.zennio.com/products/touch-panels-room-controllers),
e.g. [Z41_Pro_update_3_6_0.zip](https://www.zennio.com/download/application_program_firmware_z41_pro-3.6.0)
for the Z41 Pro firmware version 3.6.0. Older versions can be [downloaded](https://www.zennio.com/old-versions/z41-pro-older-versions) as well.

The firmware ZIP file contains the firmware as a single binary `*.pak`-file, e.g. `Z41_Pro_update.pak`.

The device uses U-Boot as bootloader, Linux 2.6.31 as Kernel and a GNU/Linux
OS based on [NXP/Freescale Semiconductor Embedded Linux Environment](https://www.nxp.com/design/software/embedded-software/i-mx-software/embedded-linux-for-i-mx-applications-processors:IMXLINUX)
and [NXP i.MX25 Product Development Kit](https://www.nxp.com/design/development-boards/i-mx-evaluation-and-development-boards/i-mx25-product-development-kit:IMX25PDK).

`System` and `User` data is stored in [JFFS2](https://en.wikipedia.org/wiki/JFFS2) partitions,
which can be extracted with [jefferson](https://github.com/sviehb/jefferson), for example.

The main application (GUI, KNX i/o, network) is stored as a monolithic ELF executable
on the `User` partition, e.g. `Z41_Pro_3_6_0_arm_release`.

### Unpack firmware

The firmware `*.pak`-file contains a table of contents and several sections of data.
With [unpack-zennio-firmware.pl](unpack-zennio-firmware.pl) one can unpack the file:

```
$ ./unpack-zennio-firmware.pl Z41_Pro_update.pak

Warning: Alpha Status, various things are unknown and/or wrong!

Signature: 5a343141 - Z41A

ToC  0 En: 01                                                               - .
ToC  0 Id: 4b657973000000000000000000000000000000000000000000               - Keys
ToC  0 Fn: 6b6579735f315f30000000000000000000000000000000000000000000000000 - keys_1_0
ToC  0 Of: 000003e4                                                         - 996

ToC  1 En: 01                                                               - .
ToC  1 Id: 53696773000000000000000000000000000000000000000000               - Sigs
ToC  1 Fn: 7369676e6174757265735f315f30000000000000000000000000000000000000 - signatures_1_0
ToC  1 Of: 000008e4                                                         - 2276

ToC  2 En: 01                                                               - .
ToC  2 Id: 55626f6f740000000000000000000000000000000000000000               - Uboot
ToC  2 Fn: 5a34315f50726f5f302e302e362d67706c000000000000000000000000000000 - Z41_Pro_0.0.6-gpl
ToC  2 Of: 00000de4                                                         - 3556

ToC  3 En: 01                                                               - .
ToC  3 Id: 4b65726e656c00000000000000000000000000000000000000               - Kernel
ToC  3 Fn: 5a34315f50726f5f302e312e3500000000000000000000000000000000000000 - Z41_Pro_0.1.5
ToC  3 Of: 0002d454                                                         - 185428

ToC  4 En: 01                                                               - .
ToC  4 Id: 53797374656d00000000000000000000000000000000000000               - System
ToC  4 Fn: 5a34315f50726f5f302e312e3238000000000000000000000000000000000000 - Z41_Pro_0.1.28
ToC  4 Of: 001e5884                                                         - 1988740

ToC  5 En: 01                                                               - .
ToC  5 Id: 55736572000000000000000000000000000000000000000000               - User
ToC  5 Fn: 5a34315f50726f5f332e362e3000000000000000000000000000000000000000 - Z41_Pro_3.6.0
ToC  5 Of: 01ca5894                                                         - 30038164

ToC  6 En: 00                                                               - .
ToC  7 En: 00                                                               - .
ToC  8 En: 00                                                               - .
ToC  9 En: 00                                                               - .
ToC 10 En: 00                                                               - .
ToC 11 En: 00                                                               - .
ToC 12 En: 00                                                               - .
ToC 13 En: 00                                                               - .
ToC 14 En: 00                                                               - .
ToC 15 En: 00                                                               - .

Data (!Keys, !Sigs) sections: 4

           Id               Filename      Start        End     Length
 0       Keys               keys_1_0        996       2276       1280 Z41_Pro_3.6.0-section-0-000000996-000001280-Keys-keys_1_0.bin K0 K1 K2 K3
 1       Sigs         signatures_1_0       2276       3556       1280 Z41_Pro_3.6.0-section-1-000002276-000001280-Sigs-signatures_1_0.bin S0 S1 S2 S3
 2      Uboot      Z41_Pro_0.0.6-gpl       3556     185428     181872 Z41_Pro_3.6.0-section-2-000003556-000181872-Uboot-Z41_Pro_0.0.6-gpl.bin
 3     Kernel          Z41_Pro_0.1.5     185428    1988740    1803312 Z41_Pro_3.6.0-section-3-000185428-001803312-Kernel-Z41_Pro_0.1.5.bin
 4     System         Z41_Pro_0.1.28    1988740   30038164   28049424 Z41_Pro_3.6.0-section-4-001988740-028049424-System-Z41_Pro_0.1.28.bin
 5       User          Z41_Pro_3.6.0   30038164   38195060    8156896 Z41_Pro_3.6.0-section-5-030038164-008156896-User-Z41_Pro_3.6.0.bin

```

## Crypto / Obfuscation

Some firmware `*.pak`-files (e.g. `Z41_Lite_update.pak` for the Z41 Lite)
contain 4 sections of data. These sections contain raw data and can be
analyzed/unpacked with with appropriate tools.

Some (newer?) firmware `*.pak`-files (Z41 Pro, ...) contain 6 sections of
data: a `Keys` section, a `Sigs` section and the 4 sections as in the standard case,
except that these sections are encrypted/obfuscated and cannot be readily examined.

First guess is that the `Keys` and `Sigs` sections contain 4 times 256 byte
keys and checksums to decode and check the following sections.
Some simple tests have shown that it is probably not XOR obfuscation
as one might initially expect. From the file `/usr/local/etc/update.cfg` one
could possibly deduce that public key cryptography is in use
(`ZenPublic.pem`, `Z41Public.pem`, `Z41SecretKey`, ...).
This needs further analysis.

## Misc

- I actually do not own a Zennio device. This project was done just for fun.
