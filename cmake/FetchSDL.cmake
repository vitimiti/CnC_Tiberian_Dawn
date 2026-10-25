set(SDL3_MIN_VERSION "3.4.18")
find_package(SDL3 ${SDL3_MIN_VERSION} QUIET CONFIG)
if(SDL3_FOUND AND SDL3_VERSION VERSION_GREATER_EQUAL ${SDL3_MIN_VERSION})
    message(
        STATUS
        "SDL3 v${SDL3_VERSION} found in the system path, meets minimum version requirement."
    )
else()
    if(SDL3_FOUND AND SDL3_VERSION VERSION_LESS ${SDL3_MIN_VERSION})
        message(
            STATUS
            "SDL3 v${SDL3_VERSION} found, but it does not meet the minimum version requirement of v${SDL3_MIN_VERSION}. Will attempt to fetch it."
        )
    else()
        message(STATUS "SDL3 not found, will attempt to fetch it.")
    endif()

    include(FetchContent)
    FetchContent_Declare(
        SDL3
        GIT_REPOSITORY https://github.com/libsdl-org/SDL.git
        GIT_TAG release-${SDL3_MIN_VERSION}
    )

    FetchContent_MakeAvailable(SDL3)
endif()
