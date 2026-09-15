;;; hurl-ts-mode.el --- Native Tree-sitter support for Hurl -*- lexical-binding: t; -*-

;;; Commentary:
;; Uses https://github.com/pfeiferj/tree-sitter-hurl (ABI 14).
;; Install the grammar manually with M-x treesit-install-language-grammar.

;;; Code:

(require 'treesit)

(defgroup hurl-ts nil
  "Tree-sitter support for Hurl."
  :group 'hurl)

(defcustom hurl-ts-fold-entries t
  "When non-nil, allow folding Hurl entries with TAB."
  :type 'boolean
  :group 'hurl-ts)

(defvar-local hurl-ts--entry-fold-overlays nil)

(defun hurl-ts--entry-at-point ()
  "Return the Hurl `entry' node containing point, if any."
  (when-let* ((node (treesit-node-at (point))))
    (while (and node (not (equal (treesit-node-type node) "entry")))
      (setq node (treesit-node-parent node)))
    node))

(defun hurl-ts--fold-overlay-p (overlay)
  "Return non-nil when OVERLAY is a Hurl entry fold."
  (eq (overlay-get overlay 'hurl-ts-entry-fold) t))

(defun hurl-ts--unfold-entry (entry)
  "Unfold ENTRY, if it is currently folded."
  (dolist (overlay hurl-ts--entry-fold-overlays)
    (when (and (hurl-ts--fold-overlay-p overlay)
               (<= (treesit-node-start entry) (overlay-start overlay))
               (>= (treesit-node-end entry) (overlay-end overlay)))
      (delete-overlay overlay)))
  (setq hurl-ts--entry-fold-overlays
        (seq-filter #'overlay-buffer hurl-ts--entry-fold-overlays)))

(defun hurl-ts--fold-entry (entry)
  "Fold ENTRY, preserving its first line."
  (hurl-ts--unfold-entry entry)
  (let ((start (save-excursion
                 (goto-char (treesit-node-start entry))
                 (line-beginning-position 2)))
        (end (treesit-node-end entry)))
    (when (< start end)
      (let ((overlay (make-overlay start end (current-buffer) nil nil)))
        (overlay-put overlay 'hurl-ts-entry-fold t)
        (overlay-put overlay 'invisible 'hurl-ts-entry-fold)
        (overlay-put overlay 'isearch-open-invisible #'delete-overlay)
        (push overlay hurl-ts--entry-fold-overlays)))))

(defun hurl-ts-fold-toggle ()
  "Toggle folding of the Hurl entry at point."
  (interactive)
  (if (not hurl-ts-fold-entries)
      (indent-for-tab-command)
    (if-let ((entry (hurl-ts--entry-at-point)))
        (let ((folded (seq-some
                       (lambda (overlay)
                         (and (hurl-ts--fold-overlay-p overlay)
                              (= (overlay-start overlay)
                                 (save-excursion
                                   (goto-char (treesit-node-start entry))
                                   (line-beginning-position 2)))))
                       hurl-ts--entry-fold-overlays)))
          (if folded
              (hurl-ts--unfold-entry entry)
            (hurl-ts--fold-entry entry)))
      (indent-for-tab-command))))

(defun hurl-ts-fold-toggle-all ()
  "Expand all Hurl entries, or fold all entries when none are folded."
  (interactive)
  (if (not hurl-ts-fold-entries)
      (indent-for-tab-command)
    (let ((entries (treesit-query-capture (treesit-buffer-root-node)
                                          "(entry) @entry")))
      (if hurl-ts--entry-fold-overlays
          (progn
            (mapc #'delete-overlay hurl-ts--entry-fold-overlays)
            (setq hurl-ts--entry-fold-overlays nil))
        (dolist (capture entries)
          (hurl-ts--fold-entry (cdr capture)))))))

(add-to-list 'treesit-language-source-alist
             '(hurl "https://github.com/pfeiferj/tree-sitter-hurl"))

(defvar hurl-ts-mode-syntax-table
  (let ((table (make-syntax-table)))
    (modify-syntax-entry ?# "<" table)
    (modify-syntax-entry ?\n ">" table)
    table)
  "Syntax table for Hurl comments and structural navigation.")

(defun hurl-ts-mode--font-lock-settings ()
  "Build highlighting queries for the Hurl grammar."
  (treesit-font-lock-rules
   :language 'hurl :feature 'comment
   '((comment) @font-lock-comment-face)
   :language 'hurl :feature 'string
   '([(value_string) (quoted_string) (json_string) (file_value)
      (regex) (multiline_string) (oneline_string)] @font-lock-string-face)
   :language 'hurl :feature 'keyword
   '((method) @font-lock-keyword-face
     (version) @font-lock-builtin-face
     (_ section_header: _ @font-lock-keyword-face)
     (_ query_name: _ @font-lock-builtin-face)
     (_ predicate_name: _ @font-lock-keyword-face)
     ["not" "==" "!=" ">" ">=" "<" "<="] @font-lock-keyword-face)
   :language 'hurl :feature 'property :override t
   '([(key_string) (json_key_string)] @font-lock-property-name-face
     (_ option_key: _ @font-lock-property-name-face))
   :language 'hurl :feature 'number
   '([(integer) (float) (status) (json_number)] @font-lock-number-face
     [(boolean) "null"] @font-lock-constant-face)
   :language 'hurl :feature 'variable :override t
   '((variable_name) @font-lock-variable-name-face
     ["{{" "}}"] @font-lock-preprocessor-face)
   :language 'hurl :feature 'delimiter
   '([":" "," "[" "]" "{" "}"] @font-lock-delimiter-face)))

;;;###autoload
(define-derived-mode hurl-ts-mode prog-mode "Hurl[TS]"
  "Edit Hurl requests with native Tree-sitter highlighting.
Install the grammar manually with `treesit-install-language-grammar'."
  :syntax-table hurl-ts-mode-syntax-table
  (unless (treesit-available-p)
    (user-error "This Emacs lacks native Tree-sitter support"))
  (unless (treesit-ready-p 'hurl t)
    (user-error "Hurl grammar unavailable; run M-x treesit-install-language-grammar RET hurl RET"))
  (treesit-parser-create 'hurl)
  (setq-local comment-start "# "
              comment-end ""
              comment-start-skip "#+[\t ]*"
              treesit-font-lock-settings (hurl-ts-mode--font-lock-settings)
              treesit-font-lock-feature-list
              '((comment string) (keyword) (property number variable) (delimiter)))
  (treesit-major-mode-setup))

(define-key hurl-ts-mode-map (kbd "TAB") #'hurl-ts-fold-toggle)
(define-key hurl-ts-mode-map (kbd "<backtab>") #'hurl-ts-fold-toggle-all)
(define-key hurl-ts-mode-map (kbd "S-TAB") #'hurl-ts-fold-toggle-all)

(provide 'hurl-ts-mode)
;;; hurl-ts-mode.el ends here
