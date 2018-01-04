add_definitions(-DTANGRAM_ANDROID)

# RATIO
include(${PROJECT_SOURCE_DIR}/ratio-ride-core/ratio.cmake)
# end of RATIO

# load core library
add_subdirectory(${PROJECT_SOURCE_DIR}/core)

set(ANDROID_PROJECT_DIR ${PROJECT_SOURCE_DIR}/platforms/android/tangram)

set(LIB_NAME tangram) # in order to have libtangram.so

add_library(${LIB_NAME} SHARED
  ${RATIO_CORE_SRC}
  ${PROJECT_SOURCE_DIR}/ratio/ratio_coord.c
  ${PROJECT_SOURCE_DIR}/ratio/RoadTile.cpp
  ${PROJECT_SOURCE_DIR}/platforms/common/platform_gl.cpp
  ${PROJECT_SOURCE_DIR}/platforms/android/tangram/src/main/cpp/jniExports.cpp
  ${PROJECT_SOURCE_DIR}/platforms/android/tangram/src/main/cpp/androidPlatform.cpp
  ${PROJECT_SOURCE_DIR}/platforms/android/tangram/src/main/cpp/sqlite3ndk.cpp)

target_include_directories(${LIB_NAME} PUBLIC
  ${RATIO_CORE_HDR}
  ${PROJECT_SOURCE_DIR}/core/include/tangram/tile/
  ${PROJECT_SOURCE_DIR}/ratio
  ${PROJECT_SOURCE_DIR}/core/deps/SQLiteCpp/sqlite3) # sqlite3ndk.cpp needs sqlite3.h

target_link_libraries(${LIB_NAME}
  PUBLIC
  ${CORE_LIBRARY}
  # android libraries
  GLESv2 log z atomic android)
