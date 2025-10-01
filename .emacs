;;; ~/.emacs --- Clean, opinionated Emacs config
;;; Author: Thyruh
;;; Commentary:
;;; Structured into clear sections. Safe to paste as your full ~/.emacs.

;;; ------------------------------
;;; Bootstrap packages
;;; ------------------------------
(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("gnu"   . "https://elpa.gnu.org/packages/"))
      package-enable-at-startup nil)
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)

;;; ------------------------------
;;; Leader framework (general) + which-key
;;; ------------------------------
(use-package general
  :config
  ;; Define Space as leader, like Neovim
  (general-create-definer thy/leader
    :states '(normal visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC"))

(use-package which-key
  :init (which-key-mode 1)
  :config
  (setq which-key-idle-delay 0.3))

;;; Leader mappings (Neovim parity)
(when (featurep 'general)
  ;; <leader>pv -> Dired (file explorer)
  (thy/leader
    "p" '(:ignore t :which-key "project")
    ;; telescope-likes
    "pf" '(consult-find :which-key "find files")
    "ps" '(consult-ripgrep :which-key "grep in project")
    "f"  '(consult-flycheck :which-key "diagnostics"))
  ;; Harpoon add
  (thy/leader
    "a" '(my/harpoon-add-file :which-key "harpoon add")))

(defun my/harpoon-open-buffer ()
  "Open a special buffer to browse and jump to Harpoon files."
  (interactive)
  (let ((buf (get-buffer-create "*Harpoon*")))
    (with-current-buffer buf
      (erase-buffer)
      (insert "Harpoon Marks:\n\n")
      (cl-loop for file in my/harpoon-marks
               for i from 1 do
               (insert (format "%d. %s\n" i file)))
      (goto-char (point-min))
      (my/harpoon-buffer-mode))

    (pop-to-buffer buf)))
(define-derived-mode my/harpoon-buffer-mode special-mode "Harpoon"
  "Major mode for browsing Harpoon marks."
  (setq buffer-read-only t)
  (setq truncate-lines t)
  (define-key my/harpoon-buffer-mode-map (kbd "RET") #'my/harpoon-buffer-visit)
  (define-key my/harpoon-buffer-mode-map (kbd "d")   #'my/harpoon-buffer-remove))

(defun my/harpoon-buffer-visit ()
  "Visit the file at point in the Harpoon buffer."
  (interactive)
  (let ((file (save-excursion
                (beginning-of-line)
                (when (looking-at "[0-9]+\\. \\(.*\\)$")
                  (match-string 1)))))
    (when file
      (find-file file))))

(defun my/harpoon-buffer-remove ()
  "Remove the file at point from Harpoon and refresh buffer."
  (interactive)
  (let ((file (save-excursion
                (beginning-of-line)
                (when (looking-at "[0-9]+\\. \\(.*\\)$")
                  (match-string 1)))))
    (when file
      (setq my/harpoon-marks (delete file my/harpoon-marks))
      (my/harpoon-open-buffer))))

(with-eval-after-load 'evil
  (define-key evil-normal-state-map (kbd "C-e") #'my/harpoon-open-buffer))


;;; ------------------------------
;;; Minibuffer completion style (Tsoding-like)
;;; ------------------------------
;; Pure icomplete/fido (horizontal) + Marginalia annotations.
(icomplete-mode 1)
(fido-mode 1)
(fido-vertical-mode -1) ;; ensure horizontal UI, not vertical

(setq icomplete-compute-delay 0
      icomplete-hide-common-prefix nil
      icomplete-show-matches-on-no-input t
      icomplete-separator "  |  ")

;; Make C-n / C-p move through candidates (not history)
(with-eval-after-load 'icomplete
  (define-key icomplete-minibuffer-map (kbd "C-n") #'icomplete-forward-completions)
  (define-key icomplete-minibuffer-map (kbd "C-p") #'icomplete-backward-completions))

;; Nice annotations in minibuffer candidates
(use-package marginalia
  :init (marginalia-mode 1))

;; Explicitly disable Ivy/Counsel to avoid conflicts with icomplete
(when (fboundp 'ivy-mode)    (ivy-mode -1))
(when (fboundp 'counsel-mode)(counsel-mode -1))

;;; ------------------------------
;;; Consult (Telescope-like pickers)
;;; ------------------------------
(use-package consult
  :bind (("C-,"   . consult-buffer)     ;; buffers + recent files
         ("C-/"   . consult-line)       ;; search in current buffer
         ("M-y"   . consult-yank-pop)   ;; fuzzy kill-ring
         ("C-x r b" . consult-bookmark)
         ("C-x C-r" . consult-recent-file))
  :config
  ;; Fix consult-project root detection for VC repos
  (setq consult-project-function
        (lambda (_prompt) (when (fboundp 'vc-root-dir) (vc-root-dir))))
  (setq consult-project-root-function
        (lambda () (when (fboundp 'vc-root-dir) (vc-root-dir))))

  ;; Project ripgrep helper
  (defun thy/consult-ripgrep-project ()
    "Run consult-ripgrep from the project root if available, else default dir."
    (interactive)
    (let ((default-directory (or (funcall consult-project-root-function)
                                 default-directory)))
      (consult-ripgrep default-directory))))

;; Unbind Evil's default C-. (evil-repeat-pop) and remap to ripgrep
(with-eval-after-load 'evil
  (define-key evil-normal-state-map (kbd "C-.") nil)
  (define-key evil-motion-state-map (kbd "C-.") nil))
(global-set-key (kbd "C-.") #'thy/consult-ripgrep-project)

;; --- Dired: make <RET> open files in both Emacs and Evil normal state ---
;; Emacs states (works in insert/emacs states too)
(with-eval-after-load 'dired
  (define-key dired-mode-map (kbd "<return>") #'dired-find-file)
  (define-key dired-mode-map (kbd "RET")       #'dired-find-file))

;; Evil normal state (Evil overrides mode maps, so bind here, too)
(with-eval-after-load 'evil
  (with-eval-after-load 'dired
    (evil-define-key 'normal dired-mode-map
      (kbd "<return>") #'dired-find-file
      (kbd "RET")       #'dired-find-file
      (kbd "o")         #'dired-find-file-other-window
      (kbd "^")         #'dired-up-directory)))


;;; ------------------------------
;;; UI / UX
;;; ------------------------------
(set-face-attribute 'default nil :font "JetBrains Mono ExtraBold-18")
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/gruber-darker")
(load-theme 'gruber-darker t)

;; All frames 90% opaque
(add-to-list 'default-frame-alist '(alpha-background . 30))
(set-frame-parameter nil 'alpha-background 70)

(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)

(setq-default cursor-type 'box
              cursor-in-non-selected-windows 'box)
(blink-cursor-mode 1)
(setq blink-cursor-interval 0.5)

(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode 1)
(show-paren-mode 1)
(setq show-paren-delay 0)
(global-hl-line-mode 1)

(setq-default tab-width 4
              indent-tabs-mode nil)

(setq inhibit-startup-screen t
      initial-scratch-message nil
      initial-buffer-choice t
      use-dialog-box nil)

;;; ------------------------------
;;; Whitespace handling
;;; ------------------------------
(require 'whitespace)
(setq whitespace-style '(face tabs spaces trailing))
(global-whitespace-mode 1)
(add-hook 'before-save-hook 'delete-trailing-whitespace)

(defun rc/set-up-whitespace-handling ()
  "Enable basic whitespace handling without trailing $ markers."
  (whitespace-mode 1)
  (add-hook 'before-save-hook #'delete-trailing-whitespace nil t))
(add-hook 'prog-mode-hook #'rc/set-up-whitespace-handling)
(add-hook 'text-mode-hook #'rc/set-up-whitespace-handling)

;;; ------------------------------
;;; Core editing helpers
;;; ------------------------------
(setq-default scroll-margin 5
              scroll-conservatively 9999
              scroll-step 1)

(use-package smartparens
  :config
  (require 'smartparens-config)
  (smartparens-global-mode 1))

(toggle-word-wrap 1)

;;; ------------------------------
;;; In-buffer completion & diagnostics
;;; ------------------------------
(use-package corfu
  :config
  (global-corfu-mode)
  (setq corfu-auto t
        corfu-preselect 'first
        corfu-count 8))

(use-package flycheck
  :init (global-flycheck-mode 1))

(use-package lsp-mode
  :init
  (setq lsp-enable-indentation nil
        lsp-enable-on-type-formatting nil)
  :hook ((go-mode c-mode c++-mode python-mode rust-mode haskell-mode) . lsp-deferred)
  :commands (lsp lsp-deferred))

(use-package lsp-ui :after lsp-mode :commands lsp-ui-mode)

;;; ------------------------------
;;; Tree-sitter
;;; ------------------------------
(use-package tree-sitter :defer t)
(use-package tree-sitter-langs :after tree-sitter :defer t)
(when (require 'tree-sitter nil 'noerror)
  (global-tree-sitter-mode 1)
  (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode))

;;; ------------------------------
;;; Dired
;;; ------------------------------
(require 'dired-x)
(setq dired-listing-switches "-alFhG --group-directories-first"
      dired-dwim-target t
      dired-mouse-drag-files t)

(add-hook 'dired-mode-hook #'dired-omit-mode)
(setq dired-omit-files (concat dired-omit-files "\\|^\\..+$"))

(use-package dired
  :ensure nil ;; built-in
  :commands (dired dired-jump)
  :config
  ;; Let dired use the same buffer when opening dirs
  (setq dired-kill-when-opening-new-dired-buffer t))

;; Evil integration with minimal overrides
(use-package evil-collection
  :after evil
  :config
  ;; Tell evil-collection to not fully override dired
  (setq evil-collection-setup-minibuffer t)
  (evil-collection-init 'dired)

  ;; Restore stock Dired bindings except keep j/k for navigation
  (with-eval-after-load 'dired
    (evil-define-key 'normal dired-mode-map
      (kbd "j") 'evil-next-line
      (kbd "k") 'evil-previous-line
      (kbd "RET") 'dired-find-file
      (kbd "f") 'revert-buffer
      (kbd "^") 'dired-up-directory)))

;;; ------------------------------
;;; Compilation workflow
;;; ------------------------------
(setq display-buffer-alist
      '(("\\*compilation\\*"
         (display-buffer-reuse-window display-buffer-at-bottom)
         (window-height . 15))))

(global-set-key (kbd "C-c C-c") 'compile)
(setq compile-command ""
      compilation-read-command t)

(require 'ansi-color)
(defun rc/colorize-compilation-buffer ()
  (let ((inhibit-read-only t))
    (ansi-color-apply-on-region compilation-filter-start (point))))
(add-hook 'compilation-filter-hook #'rc/colorize-compilation-buffer)

;;; ------------------------------
;;; Harpoon-like automatic slots (1–4)
;;; ------------------------------

(defvar my/harpoon-slots (make-vector 4 nil)
  "Vector of 4 harpoon slots storing file paths.")

(defvar my/harpoon-index 0
  "Next slot index for harpoon add.")

(defun my/harpoon-add-file ()
  "Add current file to harpoon slots (cycling through 1–4)."
  (interactive)
  (if buffer-file-name
      (progn
        (aset my/harpoon-slots my/harpoon-index buffer-file-name)
        (message "Added %s → slot %d"
                 (file-name-nondirectory buffer-file-name)
                 (+ 1 my/harpoon-index))
        (setq my/harpoon-index (mod (1+ my/harpoon-index) 4)))
    (message "No file associated with this buffer!")))

(defun my/harpoon-nav (n)
  "Jump to harpoon slot N (1–4)."
  (interactive "nSlot: ")
  (let ((file (aref my/harpoon-slots (1- n))))
    (if file
        (find-file file)
      (message "Harpoon slot %d is empty" n))))

(defun my/harpoon-menu ()
  "Show all harpoon slots in a temp buffer."
  (interactive)
  (with-output-to-temp-buffer "*Harpoon*"
    (dotimes (i 4)
      (princ (format "Slot %d: %s\n"
                     (+ 1 i)
                     (or (aref my/harpoon-slots i) "empty"))))))


(defvar my/harpoon-save-file (expand-file-name "harpoon-marks.el" user-emacs-directory)
  "File to persist harpoon marks between sessions.")

(defun my/harpoon-save ()
  "Save harpoon marks to `my/harpoon-save-file`."
  (with-temp-file my/harpoon-save-file
    (prin1 my/harpoon-marks (current-buffer))))

(defun my/harpoon-restore ()
  "Restore harpoon marks if the save file exists."
  (when (file-exists-p my/harpoon-save-file)
    (with-temp-buffer
      (insert-file-contents my/harpoon-save-file)
      (setq my/harpoon-marks (read (current-buffer))))))

;; Save on exit
(add-hook 'kill-emacs-hook #'my/harpoon-save)

;; Ask on startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (when (and (file-exists-p my/harpoon-save-file)
                       (y-or-n-p "Restore Harpoon marks? "))
              (my/harpoon-restore))))


(setq desktop-dirname user-emacs-directory
      desktop-path (list user-emacs-directory)
      desktop-save t
      desktop-load-locked-desktop nil)

(defun my/desktop-restore-prompt ()
  "Ask before restoring a saved desktop session."
  (when (file-exists-p (expand-file-name "desktop" user-emacs-directory))
    (if (y-or-n-p "Restore previous session (buffers/windows)? ")
        (desktop-read)
      (message "Skipped restoring session."))))

(add-hook 'emacs-startup-hook #'my/desktop-restore-prompt)

(setq lsp-rust-analyzer-server-display-inlay-hints t)
(setq lsp-rust-analyzer-link-projects '("~/dev/sandbox/rust/begin/Cargo.toml"))
(setenv "PATH" (concat (getenv "PATH") ":/usr/bin:/home/thyruh/.cargo/bin"))
(setq exec-path (append exec-path '("/usr/bin" "/home/thyruh/.cargo/bin")))
(use-package rustic
  :ensure t
  :config
  ;; Enable dap for Rust
  (require 'dap-mode)
  (require 'dap-gdb-lldb) ;; works for Rust
  ;; Keybindings
  (define-key rustic-mode-map (kbd "<f5>") 'rustic-cargo-run)
  (define-key rustic-mode-map (kbd "<f6>") 'dap-debug))

(use-package dap-mode
  :ensure t
  :config
  (require 'dap-gdb-lldb)) ;; for Rust

;;; Visual-mode move lines with J/K (Neovim-style)
(defun my/visual-move-down (beg end)
  "Move selected lines down."
  (interactive "r"
  (let ((text (delete-and-extract-region beg end)))
    (goto-char beg)
    (forward-line 1)
    (insert text)
    (exchange-point-and-mark)
    (setq deactivate-mark nil)))

(defun my/visual-move-up (beg end)
  "Move selected lines up."
  (interactive "r")
  (let ((text (delete-and-extract-region beg end)))
    (goto-char beg)
    (forward-line -1)
    (insert text)
    (exchange-point-and-mark)
    (setq deactivate-mark nil)))

(with-eval-after-load 'evil
  (define-key evil-visual-state-map (kbd "J") #'my/visual-move-down)
  (define-key evil-visual-state-map (kbd "K") #'my/visual-move-up))

;;; Evil normal-state Harpoon keys (C-e menu; C-h/j/k/l to slots 1..4)
(with-eval-after-load 'evil
  (define-key evil-normal-state-map (kbd "C-e") #'my/harpoon-menu)
  (define-key evil-normal-state-map (kbd "C-h") (lambda () (interactive) (my/harpoon-nav 1)))
  (define-key evil-normal-state-map (kbd "C-j") (lambda () (interactive) (my/harpoon-nav 2)))
  (define-key evil-normal-state-map (kbd "C-k") (lambda () (interactive) (my/harpoon-nav 3)))
  (define-key evil-normal-state-map (kbd "C-l") (lambda () (interactive) (my/harpoon-nav 4))))

;;; ------------------------------
;;; Quality-of-life keys
;;; ------------------------------
(global-set-key (kbd "M-d") 'backward-delete-char)
(global-set-key (kbd "C-y") 'yank)
(global-set-key (kbd "C-x C-r") 'query-replace)
(global-set-key (kbd "C-x C-w") 'other-window)
(global-set-key (kbd "<escape>") #'keyboard-escape-quit)

;; Ensure dap-mode is loaded after rustic (with-eval-after-load 'rustic
  (require 'dap-mode)
  (require 'dap-gdb-lldb) ;; for Rust debugging with lldb

  ;; F5 runs the program
  (define-key rustic-mode-map (kbd "<F5>") 'rustic-cargo-run)

  ;; F6 starts debugging
  (define-key rustic-mode-map (kbd "<F6>")
    (lambda ()
      (interactive)
      (dap-debug
       (list :type "lldb"
             :request "launch"
             :name "Rust::Debug"
             :program (read-file-name "Select executable: " "target/debug/")
             :cwd nil
             :stopOnEntry t
             :args nil)))))


(defun rc/select-current-line ()
  "Select current line."
  (interactive)
  (move-beginning-of-line 1)
  (set-mark (point))
  (move-end-of-line 1))

(global-set-key (kbd "C-c l") #'rc/select-current-line)

;; Buffer switching (Tsoding-style, via Consult)
(global-set-key (kbd "C-,") #'consult-buffer)

;;; ------------------------------
;;; Evil (modal editing)
;;; ------------------------------
(setq evil-want-C-u-scroll t
      evil-want-keybinding nil
      evil-want-C-i-jump t)

(use-package evil
  :config
  (evil-mode 1))

;; Multicursor: evil-mc (replacement for multiple-cursors)
(use-package evil-mc
  :after evil
  :config
  (global-evil-mc-mode 1))

(with-eval-after-load 'evil
  (with-eval-after-load 'dired)
  (with-eval-after-load 'dired
    (define-key dired-mode-map (kbd "RET") 'dired-find-file)))

;;; ------------------------------
;;; Move lines up/down
;;; ------------------------------
(use-package move-text
  :config
  (move-text-default-bindings)
  (global-set-key (kbd "M-p") #'move-text-up)
  (global-set-key (kbd "M-n") #'move-text-down))

;;; ------------------------------
;;; Per-file quick jumps (keep your old harpoon binds)
;;; ------------------------------
(global-set-key (kbd "C-c a") #'my/harpoon-add-file)

(global-set-key (kbd "C-c f") (lambda () (interactive) (find-file "~/.emacs")))
(global-set-key (kbd "C-c r") (lambda () (interactive) (find-file "~/.zshrc")))
(global-set-key (kbd "C-c v") (lambda () (interactive) (find-file "~/dev/")))
(global-set-key (kbd "C-c i") (lambda () (interactive) (find-file "~/.config/i3/config")))

;;; ------------------------------
;;; Saves, locks, backups
;;; ------------------------------

(setq auto-save-default nil
      make-backup-files nil
      create-lockfiles nil)

;;; ------------------------------
;;; Final touches
;;; ------------------------------
(setq lsp-auto-guess-root t)


(setq custom-file (expand-file-name "~/.emacs-custom-vars.el"))
(load custom-file 'noerror 'nomessage)

(setq lsp-auto-guess-root t)

;;; .emacs ends here
