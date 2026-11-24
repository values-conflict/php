PHP_ARG_ENABLE([phpdbg],
  [for phpdbg support],
  [AS_HELP_STRING([--disable-phpdbg],
    [Disable building of phpdbg])],
  [yes],
  [yes])

PHP_ARG_ENABLE([phpdbg-debug],
  [for phpdbg debug build],
  [AS_HELP_STRING([--enable-phpdbg-debug],
    [Build phpdbg in debug mode to enable additional diagnostic output for
    developing and troubleshooting phpdbg itself])],
  [no],
  [no])

PHP_ARG_ENABLE([phpdbg-readline],
  [for phpdbg readline support],
  [AS_HELP_STRING([--enable-phpdbg-readline],
    [Enable readline support in phpdbg (depends on static ext/readline)])],
  [no],
  [no])

if test "$PHP_PHPDBG" != "no"; then
  AC_HEADER_TIOCGWINSZ

  PHP_PHPDBG_CFLAGS="-DZEND_ENABLE_STATIC_TSRMLS_CACHE=1"
  AS_VAR_IF([PHP_PHPDBG_DEBUG], [no],,
    [AS_VAR_APPEND([PHP_PHPDBG_CFLAGS], [" -DPHPDBG_DEBUG=1"])])

  AC_MSG_CHECKING([for phpdbg and readline integration])
  if test "$PHP_PHPDBG_READLINE" = "yes"; then
    if test "$PHP_READLINE" != "no" || test "$PHP_LIBEDIT" != "no"; then
      AC_DEFINE([HAVE_PHPDBG_READLINE], [1],
        [Define to 1 if the phpdbg SAPI has libedit/readline integration.])
      PHPDBG_EXTRA_LIBS="$PHP_READLINE_LIBS"
      AC_MSG_RESULT([ok])
    else
      AC_MSG_RESULT([readline is not available])
    fi
  else
    AC_MSG_RESULT([disabled])
  fi

  AH_TEMPLATE([HAVE_USERFAULTFD_WRITEFAULT],
    [Define to 1 if faulting on write-protected memory support can be compiled
    for userfaultfd.])

  AC_CHECK_DECL([UFFDIO_WRITEPROTECT_MODE_WP],
    [AS_VAR_IF([enable_zts], [yes],
      [AC_DEFINE([HAVE_USERFAULTFD_WRITEFAULT], [1])],
      [AC_MSG_CHECKING([working pthreads])
        AS_VAR_IF([pthreads_working], [yes], [
          AC_MSG_RESULT([$ac_cv_pthreads_cflags -l$ac_cv_pthreads_lib])
          AS_VAR_APPEND([PHP_PHPDBG_CFLAGS], [" $ac_cv_pthreads_cflags"])
          AS_VAR_APPEND([PHPDBG_EXTRA_LIBS], [" -l$ac_cv_pthreads_lib"])
          AC_DEFINE([HAVE_USERFAULTFD_WRITEFAULT], [1])
        ], [
          AC_MSG_RESULT([no])
          AC_MSG_WARN([pthreads not available])
        ])
      ])
    ],,
    [#include <linux/userfaultfd.h>])

  PHP_ADD_MAKEFILE_FRAGMENT([$abs_srcdir/sapi/phpdbg/Makefile.frag],
    [$abs_srcdir/sapi/phpdbg],
    [sapi/phpdbg])
  PHP_SELECT_SAPI([phpdbg],
    [program],
    m4_normalize([
      phpdbg_bp.c
      phpdbg_break.c
      phpdbg_btree.c
      phpdbg_cmd.c
      phpdbg_frame.c
      phpdbg_help.c
      phpdbg_info.c
      phpdbg_io.c
      phpdbg_lexer.c
      phpdbg_list.c
      phpdbg_out.c
      phpdbg_parser.c
      phpdbg_print.c
      phpdbg_prompt.c
      phpdbg_set.c
      phpdbg_sigsafe.c
      phpdbg_utils.c
      phpdbg_watch.c
      phpdbg.c
    ]),
    [$PHP_PHPDBG_CFLAGS])

  SAPI_PHPDBG_PATH="sapi/phpdbg/phpdbg"
  SAPI_PHPDBG_SHARED_PATH="sapi/phpdbg/libphpdbg.la"

  BUILD_PHPDBG="\$(PHP_LINK_PROGRAM) \$(PHP_EXPORT_DYNAMIC) \$(CFLAGS_CLEAN) \$(EXTRA_CFLAGS) \$(PHP_PROGRAM_LDFLAGS) \$(LDFLAGS) \$(PHP_RPATHS) \
                \$(PHP_CORE_OBJS) \
                \$(call \$(PHP_PROGRAM_OBJS_FN),\$(PHP_PHPDBG_OBJS)) \
                \$(PHP_CORE_LIBS) \
                \$(EXTRA_LIBS) \
                \$(PHPDBG_EXTRA_LIBS) \
                \$(ZEND_EXTRA_LIBS) \
                \$(PHP_FRAMEWORKS) \
         -o \$(SAPI_PHPDBG_PATH)"

  BUILD_PHPDBG_SHARED="\$(LIBTOOL) --tag=CC --mode=link \
        \$(CC) -shared -Wl,-soname,libphpdbg.so -export-dynamic \$(CFLAGS_CLEAN) \$(EXTRA_CFLAGS) \$(EXTRA_LDFLAGS_PROGRAM) \$(LDFLAGS) \$(PHP_RPATHS) \
                \$(PHP_GLOBAL_OBJS) \
                \$(PHP_BINARY_OBJS) \
                \$(PHP_PHPDBG_OBJS) \
                \$(EXTRA_LIBS) \
                \$(PHPDBG_EXTRA_LIBS) \
                \$(ZEND_EXTRA_LIBS) \
         -o \$(SAPI_PHPDBG_SHARED_PATH)"

  dnl The shared library is a thin library over the shared core, too.
  AS_VAR_IF([PHP_SHARED_CORE], [yes], [
    SAPI_PHPDBG_SHARED_PATH="sapi/phpdbg/libphpdbg.so"
    BUILD_PHPDBG_SHARED="\$(CC) -shared -Wl,-soname,libphpdbg.so \$(CFLAGS_CLEAN) \$(EXTRA_CFLAGS) \$(LDFLAGS) \$(call php_pic_objs,\$(PHP_PHPDBG_OBJS)) \$(PHP_CORE_MODULE_LIBS) \$(PHPDBG_EXTRA_LIBS) \$(EXTRA_LIBS) \$(ZEND_EXTRA_LIBS) -o \$(SAPI_PHPDBG_SHARED_PATH)"
  ])

  PHP_SUBST([PHPDBG_EXTRA_LIBS])
  PHP_SUBST([SAPI_PHPDBG_PATH])
  PHP_SUBST([SAPI_PHPDBG_SHARED_PATH])
  PHP_SUBST([BUILD_PHPDBG])
  PHP_SUBST([BUILD_PHPDBG_SHARED])

  AC_CONFIG_FILES([sapi/phpdbg/phpdbg.1])
fi
