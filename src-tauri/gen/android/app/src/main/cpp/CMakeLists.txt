cmake_minimum_required(VERSION 3.22.1)
project(crispybridge C)

# --- SDL2 (vendored source) ---
# Path to your SDL2 source dir
set(SDL2_DIR "${CMAKE_SOURCE_DIR}/../../../native/SDL2")
add_subdirectory("${SDL2_DIR}" "${CMAKE_BINARY_DIR}/sdl2_build")

# SDL2 exports target SDL2::SDL2 (newer) or SDL2 (older). Normalize:
if (TARGET SDL2::SDL2)
  set(SDL2_TARGET SDL2::SDL2)
else()
  set(SDL2_TARGET SDL2)
endif()

# --- Crispy Doom sources ---
# Root of your crispy-doom repo
set(CRISPY_ROOT "${CMAKE_SOURCE_DIR}/../../../native/crispydoom")

# Include directories (adjust if paths differ)
include_directories(
  "${CRISPY_ROOT}/src"
  "${CRISPY_ROOT}/src/doom"
  "${CRISPY_ROOT}/src/common"
  "${CRISPY_ROOT}/src/i_video"
  "${CRISPY_ROOT}/src/opl"
  "${CRISPY_ROOT}/src/opl/compat"
)

# Collect core C files.
# (If Crispy layout differs, adjust the globs to include the real .c files.
# You mainly need: src/doom/*.c + src/common/*.c + platform/*.c)
file(GLOB_RECURSE CRISPY_SOURCES
  "${CRISPY_ROOT}/src/doom/*.c"
  "${CRISPY_ROOT}/src/common/*.c"
  "${CRISPY_ROOT}/src/i_*.c"
  "${CRISPY_ROOT}/src/m_*.c"
  "${CRISPY_ROOT}/src/opl/*.c"
)

# --- Our bridge library (JNI + entry wrapper + crispy sources) ---
add_library(crispybridge SHARED
  crispy_android_entry.c
  crispy_entry.c
  ${CRISPY_SOURCES}
)

# Definitions Crispy/SDL typically expect on Android
target_compile_definitions(crispybridge PRIVATE
  __ANDROID__
  ANDROID
  HAVE_CONFIG_H
)

# Link libraries
find_library(log-lib log)
find_library(android-lib android)
find_library(m-lib m)
target_link_libraries(crispybridge
  ${SDL2_TARGET}
  ${log-lib}
  ${android-lib}
  ${m-lib}
)
target_include_directories(crispybridge PRIVATE
  "${CMAKE_CURRENT_SOURCE_DIR}"  # where config.h lives
)
target_compile_definitions(crispybridge PRIVATE HAVE_CONFIG_H)