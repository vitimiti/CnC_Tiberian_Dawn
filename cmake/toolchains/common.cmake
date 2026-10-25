# Select a platform file, not this helper. Use a separate build directory per toolchain:
# cmake -S . -B build/linux-armhf --toolchain cmake/toolchains/linux-armhf.cmake
# Add -DCNC_TOOLCHAIN_COMPILER=GNU|Clang|MSVC|ClangCL as appropriate.
# GNU uses GCC/MinGW; Clang uses the GNU ABI (LLVM-MinGW on Windows).
# MSVC/ClangCL require Windows plus a target-matching developer environment
# for Ninja, or a Visual Studio generator with the matching -A platform.
# Cross builds need target libraries, not host SDL. Supply CMAKE_SYSROOT and/or
# CMAKE_FIND_ROOT_PATH for the target SDK. Clang also needs target C/C++ runtimes.
# Existing explicit CMAKE_*_COMPILER paths take precedence over discovery.

include_guard(GLOBAL)

if(NOT DEFINED CNC_TARGET_SYSTEM)
    message(FATAL_ERROR "Select a platform toolchain file, not common.cmake.")
endif()

set(_cnc_default_compiler GNU)
if(CNC_TARGET_SYSTEM STREQUAL "Windows")
    if(CMAKE_HOST_WIN32)
        set(_cnc_default_compiler MSVC)
    elseif(CNC_TARGET_PROCESSOR STREQUAL "aarch64")
        set(_cnc_default_compiler Clang)
    endif()
endif()
set(CNC_TOOLCHAIN_COMPILER "${_cnc_default_compiler}" CACHE STRING "Toolchain compiler family")
set_property(CACHE CNC_TOOLCHAIN_COMPILER PROPERTY STRINGS GNU Clang MSVC ClangCL)
list(APPEND CMAKE_TRY_COMPILE_PLATFORM_VARIABLES CNC_TOOLCHAIN_COMPILER)

set(_cnc_native FALSE)
if(CMAKE_HOST_SYSTEM_NAME STREQUAL CNC_TARGET_SYSTEM)
    if(CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL CNC_TARGET_PROCESSOR
       OR (CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "^(AMD64|amd64|x86_64)$"
           AND CNC_TARGET_PROCESSOR STREQUAL "x86_64")
       OR (CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "^(ARM64|arm64|aarch64)$"
           AND CNC_TARGET_PROCESSOR STREQUAL "aarch64")
       OR (CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "^(i[3-6]86|x86)$"
           AND CNC_TARGET_PROCESSOR STREQUAL "i686"))
        set(_cnc_native TRUE)
    endif()
endif()
if(NOT _cnc_native)
    set(CMAKE_SYSTEM_NAME "${CNC_TARGET_SYSTEM}")
endif()
set(CMAKE_SYSTEM_PROCESSOR "${CNC_TARGET_PROCESSOR}")

if(CNC_TOOLCHAIN_COMPILER MATCHES "^(MSVC|ClangCL)$")
    if(NOT CMAKE_HOST_WIN32 OR NOT CNC_TARGET_SYSTEM STREQUAL "Windows")
        message(FATAL_ERROR "MSVC and ClangCL require a Windows host and Windows target.")
    endif()
    if(CMAKE_GENERATOR MATCHES "^Visual Studio")
        if(CMAKE_GENERATOR_PLATFORM AND NOT CMAKE_GENERATOR_PLATFORM STREQUAL CNC_VS_PLATFORM)
            message(FATAL_ERROR "This toolchain requires -A ${CNC_VS_PLATFORM}.")
        endif()
        set(CMAKE_GENERATOR_PLATFORM "${CNC_VS_PLATFORM}" CACHE STRING "Visual Studio target")
        if(CNC_TOOLCHAIN_COMPILER STREQUAL "ClangCL")
            set(CMAKE_GENERATOR_TOOLSET ClangCL CACHE STRING "Visual Studio toolset")
        endif()
    else()
        if(NOT "$ENV{VSCMD_ARG_TGT_ARCH}" STREQUAL CNC_MSVC_ARCH)
            message(FATAL_ERROR "Run from a Visual Studio developer environment for ${CNC_MSVC_ARCH}.")
        endif()
        if(CNC_TOOLCHAIN_COMPILER STREQUAL "MSVC")
            set(_cnc_c_names cl)
            set(_cnc_cxx_names cl)
        else()
            set(_cnc_c_names clang-cl)
            set(_cnc_cxx_names clang-cl)
        endif()
    endif()
elseif(CNC_TOOLCHAIN_COMPILER STREQUAL "GNU")
    set(_cnc_c_names "${CNC_TARGET_TRIPLE}-gcc")
    set(_cnc_cxx_names "${CNC_TARGET_TRIPLE}-g++")
    if(_cnc_native)
        list(APPEND _cnc_c_names gcc)
        list(APPEND _cnc_cxx_names g++)
    endif()
elseif(CNC_TOOLCHAIN_COMPILER STREQUAL "Clang")
    set(_cnc_c_names "${CNC_TARGET_TRIPLE}-clang" clang)
    set(_cnc_cxx_names "${CNC_TARGET_TRIPLE}-clang++" clang++)
    set(CMAKE_C_COMPILER_TARGET "${CNC_TARGET_TRIPLE}")
    set(CMAKE_CXX_COMPILER_TARGET "${CNC_TARGET_TRIPLE}")
else()
    message(FATAL_ERROR "Unknown CNC_TOOLCHAIN_COMPILER: ${CNC_TOOLCHAIN_COMPILER}")
endif()

if(_cnc_c_names)
    if(NOT CMAKE_C_COMPILER)
        find_program(CMAKE_C_COMPILER NAMES ${_cnc_c_names} REQUIRED)
    endif()
    if(NOT CMAKE_CXX_COMPILER)
        find_program(CMAKE_CXX_COMPILER NAMES ${_cnc_cxx_names} REQUIRED)
    endif()
endif()

if(CNC_TARGET_SYSTEM STREQUAL "Windows" AND CNC_TOOLCHAIN_COMPILER MATCHES "^(GNU|Clang)$")
    if(NOT CMAKE_RC_COMPILER)
        find_program(CMAKE_RC_COMPILER
            NAMES "${CNC_TARGET_TRIPLE}-windres" "${CNC_TARGET_TRIPLE}-llvm-windres"
            REQUIRED
        )
    endif()
endif()

if(NOT _cnc_native)
    # Keep host tools available, but never resolve target dependencies from the host.
    if(CNC_TOOLCHAIN_COMPILER STREQUAL "GNU")
        execute_process(
            COMMAND "${CMAKE_C_COMPILER}" -print-sysroot
            OUTPUT_VARIABLE _cnc_sysroot
            OUTPUT_STRIP_TRAILING_WHITESPACE
            COMMAND_ERROR_IS_FATAL ANY
        )
        if(_cnc_sysroot AND NOT _cnc_sysroot STREQUAL "/" AND IS_DIRECTORY "${_cnc_sysroot}")
            list(APPEND CMAKE_FIND_ROOT_PATH "${_cnc_sysroot}")
        endif()
    endif()
    get_filename_component(_cnc_compiler_bin "${CMAKE_C_COMPILER}" DIRECTORY)
    get_filename_component(_cnc_compiler_prefix "${_cnc_compiler_bin}" DIRECTORY)
    foreach(_cnc_root
        "${_cnc_compiler_prefix}/${CNC_TARGET_TRIPLE}"
        "/usr/${CNC_TARGET_TRIPLE}"
        "/usr/${CNC_TARGET_TRIPLE}/sys-root/mingw"
    )
        if(IS_DIRECTORY "${_cnc_root}")
            list(APPEND CMAKE_FIND_ROOT_PATH "${_cnc_root}")
        endif()
    endforeach()
    list(REMOVE_DUPLICATES CMAKE_FIND_ROOT_PATH)
    if(CNC_TOOLCHAIN_COMPILER MATCHES "^(GNU|Clang)$"
       AND NOT CMAKE_FIND_ROOT_PATH AND NOT CMAKE_SYSROOT)
        message(FATAL_ERROR
            "No target SDK root found. Set CMAKE_SYSROOT or CMAKE_FIND_ROOT_PATH "
            "to the ${CNC_TARGET_TRIPLE} SDK; host libraries cannot be used."
        )
    endif()
    set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
    set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
    set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
    set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
endif()
