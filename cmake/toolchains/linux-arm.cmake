# ARM EABI soft-float; requires matching soft-float libraries and sysroot.
set(CNC_TARGET_SYSTEM Linux)
set(CNC_TARGET_PROCESSOR arm)
set(CNC_TARGET_TRIPLE arm-linux-gnueabi)
include("${CMAKE_CURRENT_LIST_DIR}/common.cmake")
