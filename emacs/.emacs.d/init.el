(defvar *emacs-load-start* (current-time))

(eval-when-compile
  (require 'package)
  (setq package-archives '(("melpa"        . "https://melpa.org/packages/")
                           ("melpa-stable" . "https://stable.melpa.org/packages/")
                           ("gnu"          . "https://elpa.gnu.org/packages/")
                           ("org"          . "https://orgmode.org/elpa/")))

  (setq package-archive-priorities '(("org"          . 30)
                                     ("melpa-stable" . 20)
                                     ("gnu"          . 10)
                                     ("melpa"        . 0)))

  (unless package--initialized (package-initialize t))

  (unless (package-installed-p 'use-package)
    (package-refresh-contents)
    (package-install 'use-package))

  (require 'use-package)
  (setq use-package-always-ensure t))

;; Package Configuration
(use-package ag :ensure t)

(use-package company
  :ensure t
  :init (setq company-dabbrev-downcase 0)
        (setq company-idle-delay 0)
  :config (global-company-mode)
          (push 'company-robe company-backends))

(use-package counsel :ensure t)

(use-package doom-themes
  :ensure t
  :config (load-theme 'doom-challenger-deep t))

(use-package enh-ruby-mode
  :ensure t
  :mode "\\.rb"
        "\\Gemfile"
        "\\.ru"
        "\\Rakefile"
        "\\.rake"
  :init (add-hook 'enh-ruby-mode-hook 'robe-mode)
        (setq ruby-insert-encoding-magic-comment nil)
        (setq enh-ruby-add-encoding-comment-on-save nil)
        (setq enh-ruby-bounce-deep-indent t)
        (setq enh-ruby-hanging-brace-indent-level 2))

(use-package exec-path-from-shell
  :ensure t
  :if (memq window-system '(mac ns x))
  :init (setq exec-path-from-shell-variables '("PATH" "MANPATH" "GEM_HOME" "GEM_PATH"))
        (setq exec-path-from-shell-check-startup-files nil)
        (exec-path-from-shell-initialize))

(use-package flx :ensure t)

(use-package ivy
  :ensure t
  :init (setq ivy-use-virtual-buffers t)
        (setq ivy-re-builders-alist
              ;; I want this to be ivy--regex-fuzzy but it's just too slow in core
              '((swiper . ivy--regex-plus)
                (t      . ivy--regex-plus)))
        (ivy-mode 1)
  :config (ivy-rich-mode 1)
  :bind ("C-s"     . swiper)
        ("M-x"     . counsel-M-x)
        ("C-x C-f" . counsel-find-file)
        ("<f2> i"  . counsel-info-lookup-symbol)
        ("C-c u "  . counsel-unicode-char)
        ("C-c j"   . counsel-git-grep)
        ("C-c k"   . counsel-ag))

(use-package ivy-rich
  :ensure t)

(use-package magit
  :ensure t
  :init (setq magit-display-buffer-function #'magit-display-buffer-fullframe-status-v1)
        (setq magit-push-current-set-remote-if-missing nil)
  :bind ("C-c s" . magit-status))

(use-package minitest
  :ensure t
  :hook enh-ruby-mode)

(use-package minimap
  :ensure t
  :config (setq minimap-window-location 'right)
          (setq minimap-automatically-delete-window nil)
  :bind ("C-c m" . minimap-mode))

(use-package nyan-mode
  :ensure t
  :init (nyan-mode))

(use-package org
  :ensure t
  :mode "\\.org")

(use-package project-explorer
  :ensure t
  :bind ("C-c C-p" . project-explorer-toggle))

(defun mvh-projectile-switch-project ()
  (exec-path-from-shell-initialize)
  (projectile-find-file))

(use-package projectile
  :ensure t
  :config (setq projectile-switch-project-action 'mvh-projectile-switch-project)
          (setq projectile-globally-ignored-directories
                (append '(".buildkite"
                          ".github"
                          ".bundle"
                          ".dev"
                          "tmp"
                          "log"
                          "*/images"
                          "/app/assets") projectile-globally-ignored-directories))


          (setq projectile-globally-ignored-files
                (append '(".DS_Store"
                          ".codecov.yml"
                          ".byebug_history"
                          ".image_optim.yml"
                          ".rubocop-http---shopify-github-io-ruby-style-guide-rubocop-yml"
                          ".rubocop.ci.yml"
                          ".rubocop.yml"
                          ".yardopts"
                          ".yarnclean"
                          ".eslintignore"
                          ".projectile") projectile-globally-ignored-files))

          (setq projectile-globally-ignored-file-suffixes
                (append '(".svg"
                          ".jpg"
                          ".png"
                          ".gif"
                          ".pdf"
                          ".woff"
                          ".woff2"
                          ".ttf"
                          ".eot"
                          ".js"
                          ".coffee"
                          ".zpl"
                          ".scss") projectile-globally-ignored-file-suffixes))
          (projectile-global-mode)
  :bind-keymap ("C-c p" . projectile-command-map)
  :init (setq projectile-completion-system 'ivy))


(use-package projectile-rails :ensure t)

(use-package robe :ensure t)

(use-package toml-mode
  :ensure t
  :mode "\\.toml")

(use-package tide
  :ensure t
  :mode ("\\.ts\\'" . typescript-mode)
  :config (add-hook 'typescript-mode-hook
                    (lambda ()
                      (tide-setup)
                      (setq typescript-indent-level 2)
                      (add-hook 'before-save-hook 'tide-format-before-save nil t))))

(use-package web-mode
  :ensure t
  :mode "\\.tsx"
        "\\.erb"
        "\\.jsx"
        "\\.html"
        "\\.css"
        "\\.scss"
        "\\.sass"
  :init (setq web-mode-markup-indent-offset 2)
        (setq web-mode-css-indent-offset 2)
        (setq web-mode-code-indent-offset 2)
        (setq web-mode-enable-auto-indentation nil))

(use-package ws-butler
  :ensure t
  :init (setq ws-butler-keep-whitespace-before-point nil)
        (ws-butler-global-mode))

(use-package yaml-mode :ensure t :mode "\\.yml" "\\.yaml")

;; Customize Settingss
(setq custom-file "~/.emacs.d/customisations.el")
(load custom-file)

;; Appearance
(setq-default cursor-type 'bar)
(toggle-scroll-bar -1)
(menu-bar-mode 0)
(tool-bar-mode 0)
(setq initial-scratch-message "")
(setq inhibit-startup-message t)
(setq-default line-spacing 5)
(global-display-line-numbers-mode t)
(set-face-attribute 'default nil :font "Fira Code 14")

;; Save/Backup file behaviour
(setq auto-save-default nil)
(setq backup-directory-alist
      (list (cons "." (expand-file-name "backup" user-emacs-directory))))
(setq make-backup-files nil)

;; General editing settings
;; These keybindings minimize the frame on OSX - which is annoying as fuck
(when window-system
  ((lambda ()
     (global-unset-key "\C-z")
     (global-unset-key "\C-x\C-z"))))

;; y/n instead of yes/no for confirming things
;; shift-arrows to switch windows
(fset 'yes-or-no-p 'y-or-n-p)
(when (fboundp 'windmove-default-keybindings)
  (windmove-default-keybindings))

;; Open line above - like O in vim
(defun open-line-above ()
  "Open a line above the line the point is at. Then move to that line and indent according to mode"
  (interactive)
  (indent-according-to-mode)
  (move-beginning-of-line 1)
  (newline)
  (previous-line)
  (indent-according-to-mode))
(global-set-key (kbd "C-o") 'open-line-above)

;; Use different keys for M-x
(global-set-key "\C-x\C-m" 'execute-extended-command)
(global-set-key "\C-c\C-m" 'execute-extended-command)

;; resize windows
(global-set-key (kbd "s-<left>")  'shrink-window-horizontally)
(global-set-key (kbd "s-<right>") 'enlarge-window-horizontally)
(global-set-key (kbd "s-<up>")    'enlarge-window)
(global-set-key (kbd "s-<down>")  'shrink-window)

(global-set-key (kbd "s-<return>") 'toggle-frame-fullscreen)

;; Enable mouse support
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1) ((control) . nil)))

;; Don't use tabs
(setq-default indent-tabs-mode nil)

;; Disable electric indent mode by default
(electric-indent-mode -1)

;; start a server if there's not one running so emacsclient will work
(unless (bound-and-true-p server-running-p)
  (server-start))

(message "My .emacs loaded in %ds" (destructuring-bind
                                       (hi lo ms psec)
                                       (current-time)
                                     (- (+ hi lo)
                                        (+ (first *emacs-load-start*)
                                           (second *emacs-load-start*)))))
