# Copyright (C) 2023 Advanced Micro Devices, Inc.  All rights reserved.
# SPDX-License-Identifier: MIT
cmake_minimum_required(VERSION 3.16)

include(${CMAKE_SOURCE_DIR}/Empty_applicationExample.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/UserConfig.cmake)
set(APP_NAME piano_udp_app)
project(${APP_NAME})

get_filename_component(_tool_bin "${CMAKE_C_COMPILER}" DIRECTORY)
set(APP_SIZE_TOOL "${CMAKE_SIZE}")
foreach(_size_tool
    "${_tool_bin}/arm-none-eabi-size.exe"
    "${_tool_bin}/arm-none-eabi-size")
    if(EXISTS "${_size_tool}")
        set(APP_SIZE_TOOL "${_size_tool}")
        break()
    endif()
endforeach()
if(CMAKE_HOST_WIN32)
    file(TO_CMAKE_PATH "${APP_SIZE_TOOL}" APP_SIZE_TOOL)
endif()

find_package(common)
enable_language(C ASM)

collect(PROJECT_LIB_DEPS xilstandalone)
collect(PROJECT_LIB_DEPS xil)
collect(PROJECT_LIB_DEPS xiltimer;lwip213)



collect(PROJECT_LIB_DEPS lwip213)
collect(PROJECT_LIB_DEPS gcc)
collect(PROJECT_LIB_DEPS c)

collect(PROJECT_LIB_SOURCES piano_udp_app.c)
collect(PROJECT_LIB_SOURCES platform.c)

collector_list(_deps PROJECT_LIB_DEPS)
list(APPEND _deps ${USER_LINK_LIBRARIES})
collector_list(_sources PROJECT_LIB_SOURCES)

if(CMAKE_EXPORT_COMPILE_COMMANDS)
    set(CMAKE_C_STANDARD_INCLUDE_DIRECTORIES ${CMAKE_C_IMPLICIT_INCLUDE_DIRECTORIES})
endif()

linker_gen("${CMAKE_SOURCE_DIR}/linker_files/")
string(APPEND CMAKE_C_FLAGS ${USER_COMPILE_OPTIONS})
string(APPEND CMAKE_C_LINK_FLAGS ${USER_LINK_OPTIONS})

set_source_files_properties(${_sources} OBJECT_DEPENDS "${CMAKE_LIBRARY_PATH}/*.a")
add_executable(${APP_NAME}.elf ${_sources})
set_target_properties(${APP_NAME}.elf PROPERTIES LINK_DEPENDS ${CMAKE_SOURCE_DIR}/lscript.ld)
target_link_libraries(${APP_NAME}.elf -Wl,-T -Wl,\"${CMAKE_SOURCE_DIR}/lscript.ld\" -L\"${CMAKE_SOURCE_DIR}/\" -L\"${CMAKE_LIBRARY_PATH}/\" -L\"${USER_LINK_DIRECTORIES}/\" -Wl,--start-group,-l${_deps} -Wl,--end-group)
target_compile_definitions(${APP_NAME}.elf PUBLIC ${USER_COMPILE_DEFINITIONS})
target_include_directories(${APP_NAME}.elf PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}" "${CMAKE_BINARY_DIR}/include" ${USER_INCLUDE_DIRECTORIES})
if(DEFINED APP_SIZE_TOOL)
    add_custom_command(
        TARGET ${APP_NAME}.elf POST_BUILD
        COMMAND ${APP_SIZE_TOOL} --format=berkeley ${APP_NAME}.elf
        COMMAND ${APP_SIZE_TOOL} --format=berkeley ${APP_NAME}.elf > ${CMAKE_BINARY_DIR}/${APP_NAME}.elf.size
        VERBATIM)
endif()
