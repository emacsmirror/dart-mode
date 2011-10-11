;;; dart-mode.el --- Major mode for editing Dart files

;; Copyright (C) 2011 Google Inc.

;; Author: Nathan Weizenbaum
;; URL: http://code.google.com/p/dart-mode
;; Version 0.0
;; Keywords: language

;;; Commentary:

;; To install, save this on your load path and add the following to
;; your .emacs file:
;;
;; (require 'dart-mode)

;;; Code:

(require 'cc-mode)

(eval-and-compile (c-add-language 'dart-mode 'java-mode))


;;; CC configuration

(c-lang-defconst c-primitive-type-kwds
  dart '("Dynamic" "void" "num" "int" "double" "bool"))

(c-lang-defconst c-class-decl-kwds
  dart '("class" "interface"))

;; Don't put these in c-modifier-kwds because they can be used without a type
;; following them.
(c-lang-defconst c-typeless-decl-kwds
  dart '("final" "static" "var"))

(c-lang-defconst c-modifier-kwds
  dart '("factory" "const"))

(c-lang-defconst c-other-decl-kwds
  dart nil)

(c-lang-defconst c-decl-hangon-kwds
  dart '("get" "set"))

(c-lang-defconst c-postfix-decl-spec-kwds
  dart '("extends" "implements"))

(c-lang-defconst c-type-list-kwds
  dart '("new" "const"))

(c-lang-defconst c-ref-list-kwds
  dart nil)

(c-lang-defconst c-block-stmt-2-kwds
  dart '("for" "if" "switch" "while" "catch"))

(c-lang-defconst c-simple-stmt-kwds
  dart '("break" "continue" "return" "throw"))

(c-lang-defconst c-before-label-kwds
  dart '("break" "continue"))

(c-lang-defconst c-inexpr-class-kwds
  dart nil)

(c-lang-defconst c-inexpr-brace-list-kwds
  dart nil)

(c-lang-defconst c-other-kwds
  dart '("in"))

(c-lang-defconst c-cast-parens
  dart nil)

(c-lang-defconst c-opt-type-suffix-key
  dart nil)

(c-lang-defconst c-recognize-typeless-decls
  dart t)

(c-lang-defconst c-recognize-<>-arglists
  dart t)

(c-lang-defconst c-opt-postfix-decl-spec-key
  dart nil)


;;; CC indentation support

(defadvice c-guess-basic-syntax (after dart-guess-basic-syntax activate)
  (when (c-major-mode-is 'dart-mode)
    (setf (caar ad-return-value)
          (save-excursion
            (beginning-of-line)

            (or
             ;; Handle array literal indentation
             (when (memq (caar ad-return-value)
                         '(arglist-intro
                           arglist-cont
                           arglist-cont-nonempty
                           arglist-close))
               (save-excursion
                 (c-safe
                   (backward-up-list)
                   (when (= (char-after) ?\[)
                     (case (caar ad-return-value)
                       (arglist-intro 'brace-list-intro)
                       ((arglist-cont arglist-cont-nonempty) 'brace-list-entry)
                       (arglist-close 'brace-list-close))))))

             ;; Handle indentifier keys in maps
             (when (eq (caar ad-return-value) 'label)
               (save-excursion
                 (c-safe
                   (c-backward-comments)
                   (if (= (char-before) ?\{) 'brace-list-intro
                     (backward-up-list)
                     (when (= (char-after) ?\{) 'brace-list-entry)))))

             (caar ad-return-value))))))


;;; Boilerplate font-lock piping

(defcustom dart-font-lock-extra-types nil
  "*List of extra types (aside from the type keywords) to recognize in DART mode.
Each list item should be a regexp matching a single identifier.")

(defconst dart-font-lock-keywords-1 (c-lang-const c-matchers-1 dart)
  "Minimal highlighting for Dart mode.")

(defconst dart-font-lock-keywords-2 (c-lang-const c-matchers-2 dart)
  "Fast normal highlighting for Dart mode.")

(defconst dart-font-lock-keywords-3 (c-lang-const c-matchers-3 dart)
  "Accurate normal highlighting for Dart mode.")

(defvar dart-font-lock-keywords dart-font-lock-keywords-3
  "Default expressions to highlight in Dart mode.")

(defvar dart-mode-syntax-table nil
  "Syntax table used in dart-mode buffers.")
(unless dart-mode-syntax-table
  (setq dart-mode-syntax-table
        (funcall (c-lang-const c-make-mode-syntax-table dart))))


;;; Initialization

;;;###autoload (add-to-list 'auto-mode-alist '("\\.dart\\'" . dart-mode))

;;;###autoload
(defun dart-mode ()
  "Major mode for editing Dart files.

The hook `c-mode-common-hook' is run with no args at mode
initialization, then `dart-mode-hook'.

Key bindings:
\\{dart-mode-map}"
  (interactive)
  (kill-all-local-variables)
  (c-initialize-cc-mode t)
  (setq major-mode 'dart-mode
        mode-name "Dart")
  (c-init-language-vars dart-mode)
  (c-common-init 'dart-mode)
  (run-hooks 'c-mode-common-hook)
  (run-hooks 'dart-mode-hook)
  (c-update-modeline))

(provide 'dart-mode)

;; dart-mode.el ends here