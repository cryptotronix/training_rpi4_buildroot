# training_rpi4_buildroot
Buildroot config for a wifi-enabled RaspberryPi 4 with mqtt and other features.

## Building with an external direcotry 
(assuming you are in your work dir)
make BR2_EXTERNAL=<path_to_this_directory> O=$PWD -C <path_to_buildroot> raspberrypi4_defconfig
