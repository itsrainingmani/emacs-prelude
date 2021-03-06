;;; my-config.el --- the heart of the beast -*- lexical-binding: t; -*-

(prelude-require-packages '(doom-modeline doom-themes flycheck-clj-kondo))

(require 'doom-modeline)
(require 'flycheck-clj-kondo)
(require 'doom-themes)
;; (require 'dimmer)

(defconst IS-LINUX   (eq system-type 'gnu/linux))

;; Prelude configs

(setq prelude-whitespace nil)
;; Get rid of the dumb arrow key navigation warnings
(setq prelude-guru nil)
(toggle-scroll-bar -1)

(window-divider-mode)
;; (set-face-background 'vertical-border "gray")
;; (set-face-foreground 'vertical-border (face-background 'vertical-border))

;;
;;; Doom Themes Config
;; For treemacs users
(setq doom-themes-treemacs-theme "doom-colors") ; use the colorful treemacs theme
(doom-themes-treemacs-config)
(setq treemacs-user-mode-line-format t)
(setq doom-themes-treemacs-enable-variable-pitch nil)

(global-set-key (kbd "C-x t t") 'treemacs)

;; Corrects (and improves) org-mode's native fontification.
(doom-themes-org-config)

;; Modeline config
(doom-modeline-mode 1)
(setq doom-modeline-height 10)
(setq doom-modeline-buffer-file-name-style 'relative-from-project)
(setq doom-modeline-buffer-encoding nil)

;; Make the cursor an i-beam
(setq-default cursor-type 'bar)

;; Emacs "updates" its ui more often than it needs to, so we slow it down
;; slightly from 0.5s:
(setq idle-update-delay 1.0)

;; Set the left-margin-width to 2 and enable line numbers
(setq left-margin-width 2)
(global-display-line-numbers-mode)
;; (setq display-line-numbers-type 'relative)

;;
;;; Optimizations

;; Disable bidirectional text rendering for a modest performance boost. I've set
;; this to `nil' in the past, but the `bidi-display-reordering's docs say that
;; is an undefined state and suggest this to be just as good:
(setq-default bidi-display-reordering 'left-to-right
              bidi-paragraph-direction 'left-to-right)

;; Disabling the BPA makes redisplay faster, but might produce incorrect display
;; reordering of bidirectional text with embedded parentheses and other bracket
;; characters whose 'paired-bracket' Unicode property is non-nil.
(setq bidi-inhibit-bpa t)  ; Emacs 27 only

;; Reduce rendering/line scan work for Emacs by not rendering cursors or regions
;; in non-focused windows.
(setq-default cursor-in-non-selected-windows nil)
(setq highlight-nonselected-windows nil)

;; More performant rapid scrolling over unfontified regions. May cause brief
;; spells of inaccurate syntax highlighting right after scrolling, which should
;; quickly self-correct.
(setq fast-but-imprecise-scrolling t)

;; Resizing the Emacs frame can be a terribly expensive part of changing the
;; font. By inhibiting this, we halve startup times, particularly when we use
;; fonts that are larger than the system default (which would resize the frame).
(setq frame-inhibit-implied-resize t)

;; Font compacting can be terribly expensive, especially for rendering icon
;; fonts on Windows. Whether it has a notable affect on Linux and Mac hasn't
;; been determined, but we inhibit it there anyway.
(setq inhibit-compacting-font-caches t)

(unless IS-LINUX (setq command-line-x-option-alist nil))

;; Use the all the icons mode for dired since dired-icon-mode is fucking broken
(add-hook 'dired-mode-hook 'all-the-icons-dired-mode)

(setq lsp-rust-server 'rust-analyzer)

;; Clojure Config
;; Enable Fuzzy completion for company when cider-mode is activated
(add-hook 'cider-repl-mode-hook #'cider-company-enable-fuzzy-completion)
(add-hook 'cider-mode-hook #'cider-company-enable-fuzzy-completion)

;; syntax hilighting for midje
(add-hook 'clojure-mode-hook
          (lambda ()
            (setq inferior-lisp-program "lein repl")
            (font-lock-add-keywords
             nil
             '(("(\\(facts?\\)"
                (1 font-lock-keyword-face))
               ("(\\(background?\\)"
                (1 font-lock-keyword-face))))
            (define-clojure-indent (fact 1))
            (define-clojure-indent (facts 1))
            (rainbow-delimiters-mode)))

;; When there's a cider error, show its buffer and switch to it
(setq cider-show-error-buffer t)
(setq cider-auto-select-error-buffer t)

;; Do not show health banner
(setq cider-repl-display-help-banner nil)

;; Use clojure mode for other extensions
(add-to-list 'auto-mode-alist '("\\.edn$" . clojure-mode))
(add-to-list 'auto-mode-alist '("\\.boot$" . clojure-mode))

;; key bindings
;; these help me out with the way I usually develop web apps
(defun cider-start-http-server ()
  (interactive)
  (cider-load-current-buffer)
  (let ((ns (cider-current-ns)))
    (cider-repl-set-ns ns)
    (cider-interactive-eval (format "(println '(def server (%s/start))) (println 'server)" ns))
    (cider-interactive-eval (format "(def server (%s/start)) (println server)" ns))))


(defun cider-refresh ()
  (interactive)
  (cider-interactive-eval (format "(user/reset)")))

(defun cider-user-ns ()
  (interactive)
  (cider-repl-set-ns "user"))

(eval-after-load 'cider
  '(progn
     (define-key clojure-mode-map (kbd "C-c C-v") 'cider-start-http-server)
     (define-key clojure-mode-map (kbd "C-M-r") 'cider-refresh)
     (define-key clojure-mode-map (kbd "C-c u") 'cider-user-ns)
     (define-key cider-mode-map (kbd "C-c u") 'cider-user-ns)))
