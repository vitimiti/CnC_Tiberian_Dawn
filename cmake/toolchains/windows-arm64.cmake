# LLVM-MinGW supplies ARM64 Windows compilers for Linux and Windows hosts.
set(CNC_TARGET_SYSTEM Windows)
set(CNC_TARGET_PROCESSOR aarch64)
set(CNC_TARGET_TRIPLE aarch64-w64-mingw32)
set(CNC_MSVC_ARCH arm64)
set(CNC_VS_PLATFORM ARM64)
include("${CMAKE_CURRENT_LIST_DIR}/common.cmake")
