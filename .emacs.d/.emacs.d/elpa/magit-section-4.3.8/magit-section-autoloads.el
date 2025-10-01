;;; magit-section-autoloads.el --- automatically extracted autoloads  -*- lexical-binding: t -*-
;;
;;; Code:

(add-to-list 'load-path (directory-file-name
                         (or (file-name-directory #$) (car load-path))))


;;;### (autoloads nil "magit-autorevert" "magit-autorevert.el" (0
;;;;;;  0 0 0))
;;; Generated autoloads from magit-autorevert.el

(put 'magit-auto-revert-mode 'globalized-minor-mode t)

(defvar magit-auto-revert-mode (not (or global-auto-revert-mode noninteractive)) "\
Non-nil if Magit-Auto-Revert mode is enabled.
See the `magit-auto-revert-mode' command
for a description of this minor mode.
Setting this variable directly does not take effect;
either customize it (see the info node `Easy Customization')
or call the function `magit-auto-revert-mode'.")

(custom-autoload 'magit-auto-revert-mode "magit-autorevert" nil)

(autoload 'magit-auto-revert-mode "magit-autorevert" "\
Toggle Auto-Revert mode in all buffers.
With prefix ARG, enable Magit-Auto-Revert mode if ARG is positive;
otherwise, disable it.

If called from Lisp, toggle the mode if ARG is `toggle'.
Enable the mode if ARG is nil, omitted, or is a positive number.
Disable the mode if ARG is a negative number.

Auto-Revert mode is enabled in all buffers where
`magit-turn-on-auto-revert-mode-if-desired' would do it.

See `auto-revert-mode' for more information on Auto-Revert mode.

\(fn &optional ARG)" t nil)

(register-definition-prefixes "magit-autorevert" '("auto-revert-buffer" "magit-"))

;;;***

;;;### (autoloads nil "magit-dired" "magit-dired.el" (0 0 0 0))
;;; Generated autoloads from magit-dired.el

(autoload 'magit-dired-jump "magit-dired" "\
Visit file at point using Dired.
With a prefix argument, visit in another window.  If there
is no file at point, then instead visit `default-directory'.

\(fn &optional OTHER-WINDOW)" t nil)

(autoload 'magit-dired-stage "magit-dired" "\
In Dired, staged all marked files or the file at point." t nil)

(autoload 'magit-dired-unstage "magit-dired" "\
In Dired, unstaged all marked files or the file at point." t nil)

(autoload 'magit-dired-log "magit-dired" "\
In Dired, show log for all marked files or the directory if none are marked.

\(fn &optional FOLLOW)" t nil)

(autoload 'magit-dired-am-apply-patches "magit-dired" "\
In Dired, apply the marked (or next ARG) files as patches.
If inside a repository, then apply in that.  Otherwise prompt
for a repository.

\(fn REPO &optional ARG)" t nil)

(autoload 'magit-do-async-shell-command "magit-dired" "\
Open FILE with `dired-do-async-shell-command'.
Interactively, open the file at point.

\(fn FILE)" t nil)

;;;***

;;;### (autoloads nil "magit-section" "magit-section.el" (0 0 0 0))
;;; Generated autoloads from magit-section.el

(autoload 'magit-add-section-hook "magit-section" "\
Add to the value of section hook HOOK the function FUNCTION.

Add FUNCTION at the beginning of the hook list unless optional
APPEND is non-nil, in which case FUNCTION is added at the end.
If FUNCTION already is a member, then move it to the new location.

If optional AT is non-nil and a member of the hook list, then
add FUNCTION next to that instead.  Add before or after AT, or
replace AT with FUNCTION depending on APPEND.  If APPEND is the
symbol `replace', then replace AT with FUNCTION.  For any other
non-nil value place FUNCTION right after AT.  If nil, then place
FUNCTION right before AT.  If FUNCTION already is a member of the
list but AT is not, then leave FUNCTION where ever it already is.

If optional LOCAL is non-nil, then modify the hook's buffer-local
value rather than its global value.  This makes the hook local by
copying the default value.  That copy is then modified.

HOOK should be a symbol.  If HOOK is void, it is first set to nil.
HOOK's value must not be a single hook function.  FUNCTION should
be a function that takes no arguments and inserts one or multiple
sections at point, moving point forward.  FUNCTION may choose not
to insert its section(s), when doing so would not make sense.  It
should not be abused for other side-effects.  To remove FUNCTION
again use `remove-hook'.

\(fn HOOK FUNCTION &optional AT APPEND LOCAL)" nil nil)

(autoload 'magit--handle-bookmark "magit-section" "\
Open a bookmark created by `magit--make-bookmark'.

Call the generic function `magit-bookmark-get-buffer-create' to get
the appropriate buffer without displaying it.

Then call the `magit-*-setup-buffer' function of the the major-mode
with the variables' values as arguments, which were recorded by
`magit--make-bookmark'.

\(fn BOOKMARK)" nil nil)

(register-definition-prefixes "magit-section" '("context-menu-region" "isearch-clean-overlays" "magit-"))

;;;***

;;;### (autoloads nil nil ("magit-section-pkg.el") (0 0 0 0))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; magit-section-autoloads.el ends here
