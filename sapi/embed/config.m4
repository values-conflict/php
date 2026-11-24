AC_MSG_CHECKING([for embedded SAPI library support])

if test "$PHP_EMBED" != "no"; then
  AS_CASE([$PHP_EMBED],
    [yes|shared], [
      LIBPHP_CFLAGS="-shared"
      AS_CASE(["$host_alias"], [*darwin*], [
        SAPI_SHARED="libs/libphp.dylib"
        PHP_EMBED_TYPE=shared-dylib
      ], [PHP_EMBED_TYPE=shared])
      INSTALL_IT="\$(mkinstalldirs) \$(INSTALL_ROOT)\$(orig_libdir); \$(INSTALL) -m 0755 $SAPI_SHARED \$(INSTALL_ROOT)\$(orig_libdir)"
    ],
    [static], [
      LIBPHP_CFLAGS="-static"
      PHP_EMBED_TYPE=static
      INSTALL_IT="\$(mkinstalldirs) \$(INSTALL_ROOT)\$(orig_libdir); \$(INSTALL) -m 0644 $SAPI_STATIC \$(INSTALL_ROOT)\$(orig_libdir)"
    ],
    [PHP_EMBED_TYPE=])

  AS_VAR_IF([PHP_EMBED_TYPE],, [AC_MSG_RESULT([no])], [
    AC_MSG_RESULT([$PHP_EMBED_TYPE])
    PHP_SUBST([LIBPHP_CFLAGS])
    AC_SUBST([PHP_EMBED_TYPE])

    dnl A static libphp.a is a complete engine of its own.
    AS_IF([test "$PHP_SHARED_CORE" = "yes" && test "$PHP_EMBED_TYPE" != "shared"],
      [AC_MSG_ERROR([--enable-shared-core only supports --enable-embed=shared])])

    AS_VAR_IF([PHP_SHARED_CORE], [yes], [
      dnl With the shared core, the embed SAPI is part of the shared library the
      dnl other SAPIs link against, which is libphp, so that embedders link
      dnl against the same library as before. It does not take the SAPI module
      dnl slot. The CLI objects are part of the library, too (see the CLI SAPI).
      PHP_ADD_BUILD_DIR([sapi/embed])
      PHP_INSTALLED_SAPIS="$PHP_INSTALLED_SAPIS embed"
      PHP_ADD_SOURCES([sapi/embed], [php_embed.c],
        [-DZEND_ENABLE_STATIC_TSRMLS_CACHE=1], [sapi])
    ], [
      PHP_SELECT_SAPI([embed],
        [$PHP_EMBED_TYPE],
        [php_embed.c],
        [-DZEND_ENABLE_STATIC_TSRMLS_CACHE=1])

      dnl Link the CLI objects into libphp for do_php_cli().
      PHP_SAPI_OBJS="$PHP_SAPI_OBJS $PHP_CLI_SHARED_OBJS"
    ])
    PHP_INSTALL_HEADERS([sapi/embed], [php_embed.h])
  ])
else
  AC_MSG_RESULT([no])
fi
