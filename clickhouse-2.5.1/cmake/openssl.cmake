MACRO (USE_OPENSSL)

    IF (WITH_OPENSSL)
        #FIND_PACKAGE (OpenSSL REQUIRED)
        include_directories("${PROJECT_BINARY_DIR}/../openssl-1.1.1w/include")
        include_directories("${PROJECT_SOURCE_DIR}/../openssl-1.1.1w/include")
        ADD_COMPILE_DEFINITIONS (WITH_OPENSSL=1)
    ENDIF ()

ENDMACRO ()
