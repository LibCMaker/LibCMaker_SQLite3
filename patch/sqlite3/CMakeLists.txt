# ****************************************************************************
#  Project:  LibCMaker_SQLite
#  Purpose:  A CMake build script for SQLite library
#  Author:   NikitaFeodonit, nfeodonit@yandex.com
# ****************************************************************************
#    Copyright (c) 2017-2018 NikitaFeodonit
#
#    This file is part of the LibCMaker_SQLite project.
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published
#    by the Free Software Foundation, either version 3 of the License,
#    or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#    See the GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program. If not, see <http://www.gnu.org/licenses/>.
# ****************************************************************************

# Based on the code from:
# https://github.com/tamaskenez/sqlite3-cmake/blob/master/CMakeLists.txt

cmake_minimum_required(VERSION 3.4)

# ICU is C++ library, then CXX lang. 
project(sqlite3 CXX C)


function(get_version_parts version out_MAJOR out_MINOR out_PATCH out_TWEAK)
  set(version_REGEX "^[0-9]+(\\.[0-9]+)?(\\.[0-9]+)?(\\.[0-9]+)?$")
  set(version_REGEX_1 "^[0-9]+$")
  set(version_REGEX_2 "^[0-9]+\\.[0-9]+$")
  set(version_REGEX_3 "^[0-9]+\\.[0-9]+\\.[0-9]+$")
  set(version_REGEX_4 "^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+$")

  if(NOT version MATCHES ${version_REGEX})
    message(FATAL_ERROR "Problem parsing version string.")
  endif()

  if(version MATCHES ${version_REGEX_1})
    set(count 1)
  elseif(version MATCHES ${version_REGEX_2})
    set(count 2)
  elseif(version MATCHES ${version_REGEX_3})
    set(count 3)
  elseif(version MATCHES ${version_REGEX_4})
    set(count 4)
  endif()

  string(REGEX REPLACE "^([0-9]+)(\\.[0-9]+)?(\\.[0-9]+)?(\\.[0-9]+)?"
    "\\1" major "${version}"
  )

  if(NOT count LESS 2)
    string(REGEX REPLACE "^[0-9]+\\.([0-9]+)(\\.[0-9]+)?(\\.[0-9]+)?"
      "\\1" minor "${version}"
    )
  else()
    set(minor "0")
  endif()

  if(NOT count LESS 3)
    string(REGEX REPLACE "^[0-9]+\\.[0-9]+\\.([0-9]+)(\\.[0-9]+)?"
      "\\1" patch "${version}"
    )
  else()
    set(patch "0")
  endif()

  if(NOT count LESS 4)
    string(REGEX REPLACE "^[0-9]+\\.[0-9]+\\.[0-9]+\\.([0-9]+)"
      "\\1" tweak "${version}"
    )
  else()
    set(tweak "0")
  endif()

  set(${out_MAJOR} "${major}" PARENT_SCOPE)
  set(${out_MINOR} "${minor}" PARENT_SCOPE)
  set(${out_PATCH} "${patch}" PARENT_SCOPE)
  set(${out_TWEAK} "${tweak}" PARENT_SCOPE)
endfunction()


option(BUILD_SHARED_LIBS "build shared library" OFF)
option(SQLITE_BUILD_SHELL "Build the sqlite3 shell" ON)

option(SQLITE_THREADSAFE "build a thread-safe library" ON)
option(SQLITE_OMIT_LOAD_EXTENSION
  "omits the entire extension loading mechanism" OFF
)

option(SQLITE_ENABLE_FTS3
  "version 3 of the full-text search engine, see also SQLITE_ENABLE_FTS4 which enables FTS3 as well"
  OFF
)
option(SQLITE_ENABLE_FTS3_PARENTHESIS
  "modifies the query pattern parser in FTS3 such that it supports operators AND and NOT and also allows query expressions to contain nested parenthesis"
  OFF
)
option(SQLITE_ENABLE_FTS4
  "versions 3 and 4 of the full-text search engine" OFF
)
option(SQLITE_ENABLE_FTS5 "versions 5 of the full-text search engine" OFF)
option(SQLITE_ENABLE_ICU "the ICU extension to SQLite to be added" OFF)
option(SQLITE_ENABLE_JSON1
  "the JSON SQL functions are added to the build automatically" OFF
)
option(SQLITE_ENABLE_RTREE "include support for the R*Tree index extension" OFF)
option(SQLITE_ENABLE_COLUMN_METADATA
  "include APIs that provide access to meta-data about tables and queries"
  OFF
)

option(SQLITE_DEBUG "Build SQLite debug features" OFF)
option(SQLITE_MEMDEBUG "Build SQLite memory debug features" OFF)

set(SQLITE_OS_WINRT OFF)
if(WINDOWS_STORE)
  # Don't use tools that are unavailable on RT platforms
  set(SQLITE_OS_WINRT ON)
endif()


file(STRINGS sqlite3.h version
  REGEX "#define[ \t]+SQLITE_VERSION[ \t]+\".+\""
)
string(REGEX MATCH "[0-9.]+" version "${version}" "")
get_version_parts(${version} major minor patch tweak)
if(NOT major)
  message(FATAL_ERROR
    "Version number parsing failed, please check sqlite3.h and parsing code here"
  )
endif()


include(CheckFunctionExists)
include(CheckIncludeFiles)
include(CheckTypeSize)
include(CheckSymbolExists)

set(definitions "")
foreach(c
  fdatasync gmtime_r localtime_r malloc_usable_size strchrnul usleep utime
  posix_fallocate strerror_r  # See a docs in sqlite3.c
)
  string(TOUPPER "HAVE_${c}" huc)
  # TODO: use check_symbol_exists() instead of check_function_exists().
  check_function_exists(${c} ${huc})
  if(${huc})
    list(APPEND definitions "${huc}=1")
  endif()
endforeach()

check_symbol_exists(localtime_s time.h HAVE_LOCALTIME_S)
check_symbol_exists(isnan math.h HAVE_ISNAN)

# See a docs in sqlite3.c
foreach(c inttypes malloc stdint)
  string(TOUPPER "HAVE_${c}_H" huc)
  check_include_files(${c}.h ${huc})
  if(${huc})
    list(APPEND definitions "${huc}=1")
  endif()
endforeach()

# See a docs in sqlite3.c
foreach(c int8_t int16_t uint8_t uint16_t uint32_t)
  string(TOUPPER "${c}" huc)
  check_type_size(${c} ${huc})
  if(HAVE_${huc})
    list(APPEND definitions "HAVE_${huc}=1")
  endif()
endforeach()


add_library(sqlite3 sqlite3.c sqlite3.h sqlite3ext.h)

if(SQLITE_THREADSAFE)
#  set(CMAKE_THREAD_PREFER_PTHREAD 1)
#  set(THREADS_PREFER_PTHREAD_FLAG)
  find_package(Threads REQUIRED)

  # configure.ac defines _REENTRANT=1 which is for tea/Solaris
  # we omit this here, it's used only there.
  target_compile_definitions(sqlite3 PUBLIC SQLITE_THREADSAFE=1)
  target_link_libraries(sqlite3 PRIVATE Threads::Threads)
  set(needs_threads 1)
else()
  target_compile_definitions(sqlite3 PUBLIC SQLITE_THREADSAFE=0)
endif()

if(NOT SQLITE_OMIT_LOAD_EXTENSION AND CMAKE_DL_LIBS)
  add_library(sqlite3::dl INTERFACE IMPORTED)
  set_property(TARGET sqlite3::dl PROPERTY
    INTERFACE_LINK_LIBRARIES "${CMAKE_DL_LIBS}"
  )
  target_link_libraries(sqlite3 PRIVATE sqlite3::dl)
  set(needs_dl 1)
else()
  target_compile_definitions(sqlite3 PUBLIC SQLITE_OMIT_LOAD_EXTENSION=1)
endif()

if(SQLITE_ENABLE_ICU)
  find_package(ICU REQUIRED COMPONENTS i18n uc data)
  target_link_libraries(sqlite3 PRIVATE ICU::i18n ICU::uc ICU::data)
  # ICU is C++ library.
  set_target_properties(sqlite3 PROPERTIES LINKER_LANGUAGE CXX)
endif()

set_target_properties(sqlite3 PROPERTIES
  DEBUG_POSTFIX d
)
if(UNIX)
  set_target_properties(sqlite3 PROPERTIES
    VERSION ${version}
    SOVERSION 0
  )
else()
  set_target_properties(sqlite3 PROPERTIES
    VERSION ${version}
  )
endif()

if(BUILD_SHARED_LIBS)
  if(MSVC)
    target_compile_definitions(sqlite3
      PRIVATE   "SQLITE_API=__declspec(dllexport)"
      INTERFACE "SQLITE_API=__declspec(dllimport)"
    )
  endif()
endif()

foreach(c
  SQLITE_ENABLE_FTS3 SQLITE_ENABLE_FTS3_PARENTHESIS SQLITE_ENABLE_FTS4
  SQLITE_ENABLE_FTS5 SQLITE_ENABLE_ICU SQLITE_ENABLE_JSON1
  SQLITE_ENABLE_RTREE SQLITE_ENABLE_COLUMN_METADATA
  SQLITE_DEBUG SQLITE_MEMDEBUG SQLITE_OS_WINRT
)
  if(${c})
    target_compile_definitions(sqlite3 PUBLIC ${c})
  endif()
endforeach()

target_include_directories(sqlite3 PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
  $<INSTALL_INTERFACE:include>
)

install(TARGETS sqlite3 EXPORT SQLite3Targets
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

install(EXPORT SQLite3Targets DESTINATION lib/cmake/sqlite3)

set(config_module "")

if(NOT BUILD_SHARED_LIBS)
  if(needs_threads)
    set(config_module
      "
        ${config_module}
#        set(CMAKE_THREAD_PREFER_PTHREAD 1)
#        set(THREADS_PREFER_PTHREAD_FLAG)
        find_package(Threads REQUIRED)
      "
    )
  endif()
  if(needs_dl)
    set(config_module
      "
        ${config_module}
        add_library(sqlite3::dl INTERFACE IMPORTED)
        set_property(TARGET sqlite3::dl PROPERTY
          INTERFACE_LINK_LIBRARIES \"\${CMAKE_DL_LIBS}\"
        )
      "
    )
  endif()
endif()

set(config_module
  "
    ${config_module}
    include(\${CMAKE_CURRENT_LIST_DIR}/SQLite3Targets.cmake)
  "
)
file(WRITE
  ${CMAKE_CURRENT_BINARY_DIR}/hide/SQLite3Config.cmake "${config_module}"
)

install(
  FILES ${CMAKE_CURRENT_BINARY_DIR}/hide/SQLite3Config.cmake
  DESTINATION lib/cmake/sqlite3
)
install(FILES sqlite3.h sqlite3ext.h DESTINATION include)

if(SQLITE_BUILD_SHELL)
#  find_package(SQLite3 REQUIRED)

  add_executable(shell shell.c)
  set_target_properties(shell PROPERTIES
    OUTPUT_NAME sqlite3
    DEBUG_POSTFIX d
  )
  target_link_libraries(shell PRIVATE sqlite3)
  if(SQLITE_ENABLE_ICU)
    # ICU is C++ library.
    target_link_libraries(shell PRIVATE ICU::i18n ICU::uc ICU::data)
    set_target_properties(shell PROPERTIES LINKER_LANGUAGE CXX)
  endif()

  install(TARGETS shell DESTINATION bin)
endif()
