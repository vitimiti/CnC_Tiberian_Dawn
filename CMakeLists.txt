cmake_minimum_required(VERSION 4.0)
project(CnC_Tiberian_Dawn)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake)

include(FetchSDL)

list(APPEND SOURCES ${PROJECT_SOURCE_DIR}/src/main.cpp)

add_executable(${PROJECT_NAME})

target_sources(${PROJECT_NAME} PRIVATE ${SOURCES})

target_compile_features(${PROJECT_NAME} PRIVATE cxx_std_26)

target_link_libraries(${PROJECT_NAME} PRIVATE SDL3::SDL3)

target_include_directories(${PROJECT_NAME} PRIVATE ${PROJECT_SOURCE_DIR}/src)

set_target_properties(${PROJECT_NAME} PROPERTIES CXX_SCAN_FOR_MODULES OFF)

if(WIN32)
    add_custom_command(
        TARGET "${PROJECT_NAME}"
        POST_BUILD
        COMMAND
            "${CMAKE_COMMAND}" -E copy -t "$<TARGET_FILE_DIR:${PROJECT_NAME}>"
            "$<TARGET_RUNTIME_DLLS:${PROJECT_NAME}>"
        USES_TERMINAL
        COMMAND_EXPAND_LISTS
    )
endif()
