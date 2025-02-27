# - Find libCrypto
# Find the native OpenSSL LIBCRYPTO includes and library
#
#  LIBCRYPTO_INCLUDE_DIR - where to find sha.h, etc.
#  LIBCRYPTO_LIBRARIES   - List of libraries when using libCrypto.  Brigitte: not used anylonger
#  LIBCRYPTO_FOUND       - True if libCrypto found.

MESSAGE("FindLibCrypto")

IF (LIBCRYPTO_INCLUDE_DIR)
  # Already in cache, be silent
  SET(LIBCRYPTO_FIND_QUIETLY TRUE)
ENDIF (LIBCRYPTO_INCLUDE_DIR)


#Brigitte: Codeblock auskommentiert -> Libs nie �ber installierte packages suchen
#IF (NOT LIBCRYPTO_INCLUDE_DIR OR NOT LIBCRYPTO_LIBRARIES)
#  FIND_PACKAGE(PkgConfig)
#
#  IF (PKG_CONFIG_FOUND)
#	MESSAGE("package config mist")
#    PKG_CHECK_MODULES (LIBCRYPTO libcrypto)
#    IF (LIBCRYPTO_FOUND)
#      SET (LIBCRYPTO_INCLUDE_DIR ${LIBCRYPTO_INCLUDE_DIRS})
#    ENDIF (LIBCRYPTO_FOUND)
#  ENDIF (PKG_CONFIG_FOUND)
#ENDIF (NOT LIBCRYPTO_INCLUDE_DIR OR NOT LIBCRYPTO_LIBRARIES)

MESSAGE("LibCrypto Libs: ${LIBCRYPTO_LIBRARIES}")
IF (NOT LIBCRYPTO_INCLUDE_DIR OR NOT LIBCRYPTO_LIBRARIES)	
  MESSAGE("Trying to find libcrypte libraries")
  # Require a regular OpenSSL even on OSX/iOS
  # IF(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
  #   # MacOSX has deprecated the use of openssl crypto functions
  #   # and replaced it with API-compatible CommonCrypto
  #   FIND_PATH(LIBCRYPTO_INCLUDE_DIR CommonCrypto/CommonDigest.h)
  #   SET(LIBCRYPTO_LIBRARY_NAMES_RELEASE ${LIBCRYPTO_LIBRARY_NAMES_RELEASE} ${LIBCRYPTO_LIBRARY_NAMES} ssl)
  #   SET(LIBCRYPTO_LIBRARY_NAMES_DEBUG ${LIBCRYPTO_LIBRARY_NAMES_DEBUG} ssld)
  # ELSE(${CMAKE_SYSTEM_NAME} MATCHES "Darwin") 
    FIND_PATH(LIBCRYPTO_INCLUDE_DIR openssl/sha.h)
    SET(LIBCRYPTO_LIBRARY_NAMES_RELEASE ${LIBCRYPTO_LIBRARY_NAMES_RELEASE} ${LIBCRYPTO_LIBRARY_NAMES} libcrypto)
    SET(LIBCRYPTO_LIBRARY_NAMES_DEBUG ${LIBCRYPTO_LIBRARY_NAMES_DEBUG} libcrypto)
  # ENDIF(${CMAKE_SYSTEM_NAME} MATCHES "Darwin") 

  FIND_LIBRARY(LIBCRYPTO_LIBRARY_RELEASE NAMES ${LIBCRYPTO_LIBRARY_NAMES_RELEASE})

  # Find a debug library if one exists and use that for debug builds.
  # This really only does anything for win32, but does no harm on other
  # platforms.
  FIND_LIBRARY(LIBCRYPTO_LIBRARY_DEBUG NAMES ${LIBCRYPTO_LIBRARY_NAMES_DEBUG})

  INCLUDE(LibraryDebugAndRelease)
  MESSAGE("LibCrypto: ${LIBCRYPTO}")
  SET_LIBRARY_FROM_DEBUG_AND_RELEASE(LIBCRYPTO)

  # handle the QUIETLY and REQUIRED arguments and set LIBCRYPTO_FOUND to TRUE if 
  # all listed variables are TRUE
  INCLUDE(FindPackageHandleStandardArgs)
  MESSAGE("LibDir: " )
  MESSAGE(${LIBCRYPTO_LIBRARY})
  FIND_PACKAGE_HANDLE_STANDARD_ARGS(LIBCRYPTO DEFAULT_MSG LIBCRYPTO_LIBRARY LIBCRYPTO_INCLUDE_DIR)

  MESSAGE("LibCrypto found: ${LIBCRYPTO_LIBRARY}")

  IF(LIBCRYPTO_FOUND)
    SET( LIBCRYPTO_LIBRARIES ${LIBCRYPTO_LIBRARY} )
  ELSE(LIBCRYPTO_FOUND)
    SET( LIBCRYPTO_LIBRARIES )
  ENDIF(LIBCRYPTO_FOUND)

  MARK_AS_ADVANCED( LIBCRYPTO_LIBRARY LIBCRYPTO_INCLUDE_DIR )

ENDIF (NOT LIBCRYPTO_INCLUDE_DIR OR NOT LIBCRYPTO_LIBRARIES)

# check whether using OpenSSL 1.1 API
IF (DEFINED LIBCRYPTO_INCLUDE_DIR AND DEFINED LIBCRYPTO_LIBRARIES)
  MESSAGE("check crypto api")
  INCLUDE(CheckCSourceCompiles)

  SET(CMAKE_REQUIRED_INCLUDES ${LIBCRYPTO_INCLUDE_DIR})
  SET(CMAKE_REQUIRED_LIBRARIES ${LIBCRYPTO_LIBRARIES})

  CHECK_C_SOURCE_COMPILES("#include <openssl/opensslv.h>
			#ifndef OPENSSL_VERSION_NUMBER
			#error No OPENSSL_VERSION_NUMBER defined
			#endif
			#if OPENSSL_VERSION_NUMBER < 0x10100000L
			#error This is not OpenSSL 1.1 or higher
			#endif
			int main(void) { return 0; }" PODOFO_HAVE_OPENSSL_1_1)

  CHECK_C_SOURCE_COMPILES("#include <openssl/opensslconf.h>
			#ifndef OPENSSL_NO_RC4
			#error No OPENSSL_NO_RC4 defined
			#endif
			int main(void) { return 0; }" PODOFO_HAVE_OPENSSL_NO_RC4)

  UNSET(CMAKE_REQUIRED_INCLUDES)
  UNSET(CMAKE_REQUIRED_LIBRARIES)
ENDIF (DEFINED LIBCRYPTO_INCLUDE_DIR AND DEFINED LIBCRYPTO_LIBRARIES)
