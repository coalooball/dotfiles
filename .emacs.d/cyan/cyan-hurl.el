;;; cyan-hurl.el --- Hurl file association -*- no-byte-compile: t; lexical-binding: t; -*-

;;; Commentary:

;; Personal configuration loaded from post-init.el.

;;; Code:

(require 'use-package)

;; Show Hurl compilation results below the current Hurl buffer.
(add-to-list 'display-buffer-alist
             '("\\*compilation\\*"
               (display-buffer-reuse-window display-buffer-below-selected)
               (window-height . 0.3)))

(defvar my/hurl-variables-file-history nil
  "History of variable files selected for Hurl runs.")

(defvar my/hurl-project-variables-files nil
  "Alist mapping project roots to their selected Hurl variables files.")

(defun my/hurl-variables-file ()
  "Return the variables file configured for the current project."
  (cdr (assoc (file-name-as-directory (expand-file-name (my/hurl-project-root)))
              my/hurl-project-variables-files)))

(defun my/hurl-project-root ()
  "Return the current project root, or the Hurl file directory."
  (or (when-let ((project (project-current)))
        (project-root project))
      (and buffer-file-name (file-name-directory buffer-file-name))))

(defun my/hurl-select-variables-file ()
  "Select a Hurl variables file below the current project root."
  (require 'consult)
  (let* ((root (file-name-as-directory (my/hurl-project-root)))
         (files (directory-files-recursively
                 root "\\.\\(properties\\|env\\|txt\\|json\\|yaml\\|yml\\)\\'"
                 nil (lambda (dir)
                       (not (member (file-name-nondirectory
                                     (directory-file-name dir))
                                    '(".git" ".venv" "__pycache__"))))))
         (choices (cons "None" (mapcar (lambda (file)
                                         (file-relative-name file root)) files)))
         (selected (consult--read choices
                                   :prompt "Variables file: "
                                   :initial (car my/hurl-variables-file-history)
                                   :history 'my/hurl-variables-file-history
                                   :require-match t)))
    (unless (equal selected "None")
      (expand-file-name selected root))))

(defun my/hurl-set-variables-file ()
  "Select the variables file for the current project.
Selecting `None' clears the current selection without running Hurl."
  (interactive)
  (let* ((root (file-name-as-directory
                (expand-file-name (my/hurl-project-root))))
         (file (my/hurl-select-variables-file)))
    (setq my/hurl-project-variables-files
          (cons (cons root file)
                (cl-remove-if (lambda (entry) (equal (car entry) root))
                              my/hurl-project-variables-files)))
    (message "Hurl variables file for %s: %s"
             (abbreviate-file-name root) (or file "None"))))

(defun my/hurl-entry-number ()
  "Return the 1-based Hurl entry number at point."
  (unless (eq major-mode 'hurl-ts-mode)
    (user-error "Current buffer is not hurl-ts-mode"))
  (let ((entry (hurl-ts--entry-at-point)))
    (unless entry
      (user-error "Point is not inside a Hurl entry"))
    (1+ (cl-loop for capture in
                     (treesit-query-capture (treesit-buffer-root-node)
                                            "(entry) @entry")
                 for node = (cdr capture)
                 until (<= (treesit-node-start node)
                           (treesit-node-start entry))
                 count 1))))

(defun my/hurl-run-buffer (&optional from-entry to-entry)
  "Run the current Hurl file, optionally limited to an entry range."
  (interactive)
  (unless buffer-file-name
    (user-error "This buffer is not visiting a file"))
  (when (buffer-modified-p)
    (save-buffer))
  (let ((default-directory (file-name-directory buffer-file-name)))
    (compile (format "hurl --no-color %s%s%s %s | perl -pe 's/\\e\\[[0-9;]*m//g' | jq -M ."
                    (if (my/hurl-variables-file)
                        (format "--variables-file %s "
                                (shell-quote-argument (my/hurl-variables-file))) "")
                    (if from-entry (format "--from-entry %d " from-entry) "")
                    (if to-entry (format "--to-entry %d " to-entry) "")
                    (shell-quote-argument (file-name-nondirectory buffer-file-name))))))

(defun my/hurl-run-entry ()
  "Run the Hurl entry at point."
  (interactive)
  (let ((entry (my/hurl-entry-number)))
    (my/hurl-run-buffer entry entry)))

(defun my/hurl-run-with-variables-file ()
  "Select the variables file for the current Hurl buffer."
  (interactive)
  (my/hurl-set-variables-file))

(use-package hurl-ts-mode
  :ensure nil
  :mode "\\.hurl\\'"
  :bind (:map hurl-ts-mode-map
              ("C-c h r" . my/hurl-run-buffer)
              ("C-c h e" . my/hurl-run-entry)
              ("C-c h f" . my/hurl-set-variables-file)))

(provide 'cyan-hurl)
;;; cyan-hurl.el ends here
