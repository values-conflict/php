/*
   +----------------------------------------------------------------------+
   | Copyright © The PHP Group and Contributors.                          |
   +----------------------------------------------------------------------+
   | This source file is subject to the Modified BSD License that is      |
   | bundled with this package in the file LICENSE, and is available      |
   | through the World Wide Web at <https://www.php.net/license/>.        |
   |                                                                      |
   | SPDX-License-Identifier: BSD-3-Clause                                |
   +----------------------------------------------------------------------+
*/

/* Linked into a SAPI module over the shared core. By default the core registers
 * the extensions of the programs and of the embed SAPI, which include those that
 * only make sense for them (pcntl, readline). A SAPI module installs the core's
 * other list of extensions when it is loaded instead. */

#include "php.h"
#include "php_main.h"

PHPAPI int php_register_module_internal_extensions(void);

static void __attribute__((constructor)) php_use_module_internal_extensions(void)
{
	php_register_internal_extensions_func = php_register_module_internal_extensions;
}
