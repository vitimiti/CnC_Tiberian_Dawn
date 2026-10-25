# ARMv7 hard-float; requires matching armhf libraries and sysroot.
set(CNC_TARGET_SYSTEM Linux)
set(CNC_TARGET_PROCESSOR armv7)
set(CNC_TARGET_TRIPLE arm-linux-gnueabihf)
set(CMAKE_C_FLAGS_INIT "-march=armv7-a -mfpu=vfpv3-d16 -mfloat-abi=hard")
set(CMAKE_CXX_FLAGS_INIT "-march=armv7-a -mfpu=vfpv3-d16 -mfloat-abi=hard")
include("${CMAKE_CURRENT_LIST_DIR}/common.cmake")
