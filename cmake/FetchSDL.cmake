set(CDU_SDL3_MIN_VERSION "3.4.18")
find_package(SDL3 ${CDU_SDL3_MIN_VERSION} QUIET CONFIG)
if(SDL3_FOUND AND SDL3_VERSION VERSION_GREATER_EQUAL ${CDU_SDL3_MIN_VERSION})
    message(
        STATUS
        "SDL3 v${SDL3_VERSION} found in the system path, using that instead."
    )
else()
    if(SDL3_FOUND AND SDL3_VERSION VERSION_LESS ${CDU_SDL3_MIN_VERSION})
        message(
            STATUS
            "SDL3 v${SDL3_VERSION} found, but it is older than the required v${CDU_SDL3_MIN_VERSION}. Fetching the required version..."
        )
    else()
        message(
            STATUS
            "SDL3 not found in the system path. Fetching the required version..."
        )
    endif()

    include(FetchContent)
    FetchContent_Declare(
        SDL3
        GIT_REPOSITORY https://github.com/libsdl-org/SDL.git
        GIT_TAG release-${CDU_SDL3_MIN_VERSION}
    )

    FetchContent_MakeAvailable(SDL3)
endif()
