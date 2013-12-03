{% set nsname = name | replace(' ', '')  %}
{% if not upname %}
    {% set upname = nsname | upper %}
{% endif %}
#
# {{ name }}
#
{% set cv = '${' %}
{% if owner %}
# Copyright {{ this_year }}, {{ owner }}{% if owner_contact %} <{{ owner_contact }}>{% endif %}
#
{% endif %}

#---------------------------------------------------------
# Section: Init cmake
#---------------------------------------------------------
cmake_minimum_required(VERSION 2.8)
{% if cmp0002 %}
# Enable non unique target names in different subdirs
# (used for unit tests)
cmake_policy(SET CMP0002 OLD)
{% endif %}

project({{ nsname }} CXX)

set({{ upname }}_MAJOR 0)
set({{ upname }}_MINOR 1)
set({{ upname }}_PATCH 0)
# Include build number if specified
# NOTE This feature used by build server to make a packages that
# would differ from previous build.
if ({{ upname }}_BUILD_NUMBER)
    set({{ upname }}_VERSION {{ cv }}{{ upname }}_MAJOR}.{{ cv }}{{ upname }}_MINOR}.{{ cv }}{{ upname }}_PATCH}.{{ cv }}{{ upname }}_BUILD_NUMBER})
else()
    set({{ upname }}_VERSION {{ cv }}{{ upname }}_MAJOR}.{{ cv }}{{ upname }}_MINOR}.{{ cv }}{{ upname }}_PATCH})
endif()
message(STATUS "Configuring ${PROJECT_NAME} {{ cv }}{{ upname }}_VERSION}")

set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/modules" ${CMAKE_MODULE_PATH})

#---------------------------------------------------------
# Section: Include aux init (cmake) functions
#---------------------------------------------------------

# Define install destination dirs
include(GNUInstallDirs)

{% if tests %}
include(CTest)
# Custom (from package's cmake/modules/ directory)
include(AddBoostTests)
# Allow testing using CTest
enable_testing()
{% endif %}
{% if export %}
include(GenerateExportHeader)
{% endif %}

#---------------------------------------------------------
# Section: Find used stuff
#---------------------------------------------------------
{% if boost_libs %}
set(Boost_USE_MULTITHREADED ON)
find_package(
    # TODO Set desired boost version
    Boost 1.53 REQUIRED COMPONENTS
    # Lets keep libs list sorted... :)
    {% for l in boost_libs %}
    {{ l }}
    {% endfor %}
    {% if tests %}
    unit_test_framework
    {% endif %}
  )
{% endif %}

# TODO Add find_package() calls for required libraries

#---------------------------------------------------------
# Section: Configure builing process
#---------------------------------------------------------

# NOTE Order is important!
include_directories(${PROJECT_SOURCE_DIR})
include_directories(${PROJECT_BINARY_DIR})
{% if boost_libs %}
include_directories(${Boost_INCLUDE_DIRS})
# Tell to boost::result_of to use decltype to decay return type of callable.
# NOTE This would enabel to use C++11 labmda expressions w/ boost::rage adaptors
add_definitions(-DBOOST_RESULT_OF_USE_DECLTYPE)
# Force the boost::asio to use std::chrono
add_definitions(-DBOOST_ASIO_DISABLE_BOOST_CHRONO)
# Don't want to use any deprecated API
add_definitions(-DBOOST_SYSTEM_NO_DEPRECATED)
add_definitions(-DBOOST_FILESYSTEM_NO_DEPRECATED)
# Use latest available Boost.Thread library
# (stay as close as possible to the C++11 Standard)
add_definitions(-DBOOST_THREAD_VERSION=4)
{% endif %}

# Do not link w/ libraries which isn't provide undefined symbols.
# (they are specified as dependencies for other targets from this
# project, but listed as unused by `ldd -u binary`)
set(CMAKE_EXE_LINKER_FLAGS "-Wl,--as-needed ${CMAKE_EXE_LINKER_FLAGS}")
set(CMAKE_MODULE_LINKER_FLAGS "-Wl,--as-needed ${CMAKE_MODULE_LINKER_FLAGS}")

# Include declaration of use_compiler_option()
include(MacroUseCompilerOption)
# Set some compiler options
use_compiler_option(OPTION -pipe LANGUAGE CXX OUTPUT COMPILER_HAS_PIPE_OPTION)
use_compiler_option(OPTION -Wall LANGUAGE CXX OUTPUT COMPILER_HAS_WALL_OPTION)
{% if cxx11 %}
use_compiler_option(OPTION -std=c++11 LANGUAGE CXX OUTPUT CXX_COMPILER_HAS_CPP11_OPTION)
if(NOT CXX_COMPILER_HAS_CPP11_OPTION)
    message(FATAL_ERROR "C++11 compatible compiler required to build this project (gcc >= 4.8)")
endif()
{% endif %}

# If CMAKE_BUILD_TYPE is not set, try to guess it
include(GuessBuildType)

# Setup compiler options depending on build type
message(STATUS "Setting options for ${CMAKE_BUILD_TYPE} build type")
if(CMAKE_BUILD_TYPE STREQUAL "Debug" OR CMAKE_BUILD_TYPE STREQUAL "DebugFull")
    # Show even more warnings in debug mode
    use_compiler_option(OPTION -Wextra LANGUAGE CXX OUTPUT COMPILER_HAS_WALL_OPTION)
    use_compiler_option(OPTION -ggdb3 LANGUAGE CXX OUTPUT COMPILER_HAS_GGDB3_OPTION)
    if(NOT COMPILER_HAS_GGDB3_OPTION)
        use_compiler_option(OPTION -g3 LANGUAGE CXX OUTPUT COMPILER_HAS_G3_OPTION)
    endif()
else()
    # More linker optimizations in release mode
    set(CMAKE_EXE_LINKER_FLAGS_RELEASE
        "-Wl,-O1 -Wl,--sort-common ${CMAKE_EXE_LINKER_FLAGS_RELEASE}"
      )
    set(CMAKE_MODULE_LINKER_FLAGS_RELEASE
        "-Wl,-O1 -Wl,--sort-common ${CMAKE_MODULE_LINKER_FLAGS_RELEASE}"
      )
endif()

#---------------------------------------------------------
# Section: Misc actions
#---------------------------------------------------------

{% if tests and cmp0002 %}
# Set a project-wide name for unit tests executable
# (a target to be build in every tests/ directories)
set(UNIT_TESTS unit_tests)
{% endif %}

{% if cpack %}
#---------------------------------------------------------
# Section: Packaging options
#---------------------------------------------------------

include(CMakePackageConfigHelpers)
# Obtain distribution codename according LSB
include(GetDistribInfo)
{% if boost_libs %}

# Specifying precise versions of some packages which are distinct
# in different distributions.
if(DISTRIB_CODENAME STREQUAL "precise")
  set(BOOST_DEV_VERSION_PKG_DEP "1.48")
elseif(DISTRIB_CODENAME STREQUAL "quantal")
  set(BOOST_DEV_VERSION_PKG_DEP "1.50")
elseif(DISTRIB_CODENAME STREQUAL "raring")
  set(BOOST_DEV_VERSION_PKG_DEP "1.53")
elseif(DISTRIB_CODENAME STREQUAL "saucy")
  set(BOOST_DEV_VERSION_PKG_DEP "1.54")
else()
  message(STATUS "WARNING: Target distribution codename is unknown! Do not even try to build .deb packages!")
endif()
set(BOOST_VERSION_PKG_DEP "${BOOST_DEV_VERSION_PKG_DEP}.0")
{% endif %}

if(
     CMAKE_BUILD_TYPE STREQUAL "Debug"
  OR CMAKE_BUILD_TYPE STREQUAL "DebugFull"
  OR CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo"
  )
  set(CMAKE_INSTALL_DO_STRIP OFF)
  set(CPACK_BUILD_FLAVOUR "-dbg")
else()
  set(CPACK_BUILD_FLAVOUR "")
endif()

# Include CPack support
include(CPack)
set(CPACK_GENERATOR DEB)
set(CPACK_SOURCE_GENERATOR TBZ2)
include(AddPackage)

# TODO Uncomment if .deb sign and deploy required
# Make sign options available to set from the CLI/GUI
# set(
#     {{ upname }}_SIGN_KEY_ID
#     "94CF01DC"
#     CACHE STRING "GPG key ID to be used to sign result packages"
#   )
# set(
#     {{ upname }}_SIGN_USER_NAME
#     "builder"
#     CACHE STRING "User name to be used to sign packages (builder)"
#   )
# set(
#     {{ upname }}_DEB_REPOSITORY
#     "$ENV{HOME}/repo"
#     CACHE FILEPATH "Path to repository to deploy .deb packages to"
#   )

set_common_package_options(
    PROJECT_VERSION "{{ cv }}{{ upname }}_VERSION}"
    VENDOR_NAME "{{ owner }}"
    VENDOR_CONTACT "{{ owner }} <{{ owner_contact }}>"
    BUILD_FLAVOUR "${CPACK_BUILD_FLAVOUR}"
    # TODO Uncomment if .deb sign and deploy required
    #SIGN_BY {{ cv }}{{ upname }}_SIGN_USER_NAME}
    #SIGN_WITH {{ cv }}{{ upname }}_SIGN_KEY_ID}
    #ALLOW_DEPLOY_PACKAGES
    #DEPLOY_TO {{ cv }}{{ upname }}_DEB_REPOSITORY}
  )

# TODO Fix .deb package base-name
set(PKG_VERSION "{{ cv }}{{ upname }}_VERSION}-0ubuntu1")

# TODO Fill package meta properly
add_package(
    NAME {{ nsname }}
    SUMMARY "<Enter package summary here>"
    DESCRIPTION "<Enter package description here>"
    HOMEPAGE "https://<Enter project homepage>"
    VERSION "${PKG_VERSION}"
    SECTION "<Enter suitable section here>"
    DEPENDS
        "<Add dependencies here>"
          {% if boost_libs %}
        "libboost-system${BOOST_VERSION_PKG_DEP}"
        "libboost-thread${BOOST_VERSION_PKG_DEP}"
          {% endif %}
    REPLACES "{{ nsname }}${CPACK_BUILD_FLAVOUR} (<= ${PKG_VERSION})"
    # TODO Uncomment if .deb package signning required
    #SIGN_WITH
  )
{% if doxygen %}
if(NOT NO_DOXY_DOCS OR NOT NO_DOXY_DOCS STREQUAL "ON")
    add_package(
        NAME {{ nsname }}-doc
        SUMMARY "{{ name }} documentation"
        DESCRIPTION "Doxygened API documentation for {{ name }}"
        HOMEPAGE "https://<Enter project homepage>"
        VERSION "${PKG_VERSION}"
        SECTION "devel"
        REPLACES "{{ nsname }}-doc (<= ${PKG_VERSION})"
        PRE_BUILD doxygen
      )
endif()
{% endif %}
{% endif %}

#---------------------------------------------------------
# Section: Dive into subdirs after main configuration
#---------------------------------------------------------
# TODO Add add_subdirectory() calls here

#---------------------------------------------------------
# Section: Define some helpful targets (using included)
#          functions.
# ALERT It should be at the bottom!
#       To make sure all vars r defined!
#---------------------------------------------------------

{% if headers_checker %}
get_directory_property(CHECK_HEADER_DEFINITIONS_LIST COMPILE_DEFINITIONS)
foreach(_define ${CHECK_HEADER_DEFINITIONS_LIST})
    set(CHECK_HEADER_DEFINITIONS "-D${_define} ${CHECK_HEADER_DEFINITIONS}")
endforeach()
include(DefineCheckHeadersTarget)
{% endif %}
{% if doxygen %}
# Setup doxygen
set(DOXYGEN_PROJECT_BRIEF "\"{{ name }}\"")
if(EXISTS $ENV{HOME}/.cache/doxygen/libstdc++.tag)
    # TODO Download libstdc++ tag file
    set(
        DOXYGEN_TAGFILES
            "$ENV{HOME}/.cache/doxygen/libstdc++.tag=http://gcc.gnu.org/onlinedocs/libstdc++/latest-doxygen/"
      )
endif()
{% if export %}
set(DOXYGEN_PREDEFINED "DOXYGEN_RUNNING {{ upname }}_EXPORT {{ upname }}_NO_EXPORT")
{% else %}
set(DOXYGEN_PREDEFINED "DOXYGEN_RUNNING")
{% endif %}
set(DOXYGEN_PROJECT_NUMBER {{ cv }}{{ upname }}_VERSION})
{% if pch %}
set(DOXYGEN_EXCLUDE_PATTERNS {{ pch | replace(' ', '') }})
{% else %}
# set(DOXYGEN_EXCLUDE_PATTERNS {{ upname | lower }}_pch.hh)
{% endif %}
include(DefineDoxyDocsTargetIfPossible)
{% endif %}
{% if autogen %}
include(DefineSkeletonGenerationTargetsIfPossible)
define_skeleton_generation_targets(
    PROJECT_LICENSE {{ license }}
    PROJECT_NAMESPACE "{{ vendor_namespace }}"
    PROJECT_PREFIX "{{ name }}"
    PROJECT_OWNER "{{ owner }}"
    PROJECT_YEARS "{{ this_year }}"
    {% if tests %}
    ENABLE_TESTS
    {% endif %}
    USE_PRAGMA_ONCE
  )
{% endif %}
{% if pch %}
include(UsePCHFile)
use_pch_file(
    PCH_FILE ${CMAKE_BINARY_DIR}/{{ pch | replace(' ', '') }}
    EXCLUDE_DIRS cmake docs tests
    # EXCLUDE_HEADERS ext/hash_set ext/hash_map
  )
{% endif %}

#---------------------------------------------------------
# Section: Top level installs
#---------------------------------------------------------

{% if doxygen %}
if(NOT NO_DOXY_DOCS OR NOT NO_DOXY_DOCS STREQUAL "ON")
    install(
        DIRECTORY ${DOXYGEN_OUTPUT_DIRECTORY}/html
        DESTINATION ${CMAKE_INSTALL_DOCDIR}
        {% if cpack %}
        COMPONENT {{ cv }}{{ upname }}_DOC_PACKAGE}
        {% endif %}
        PATTERN "*.html"
        PATTERN "*.svg"
        PATTERN "*.ttf"
        PATTERN "*.png"
        PATTERN "*.css"
        PATTERN "*.map" EXCLUDE
        PATTERN "*.md5" EXCLUDE
        PATTERN "*.dot" EXCLUDE
      )
endif()

{% endif %}
install(
    FILES README.md LICENSE
    DESTINATION ${CMAKE_INSTALL_DOCDIR}
    {% if cpack %}
    COMPONENT {{ cv }}{{ upname }}_PACKAGE}
    {% endif %}
  )
{#
# kate: hl cmake;
#}
