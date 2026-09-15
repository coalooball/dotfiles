;;; post-early-init.el --- Personal config -*- lexical-binding: t; -*-

;; Use Tsinghua TUNA mirrors for faster package downloads in China.
(setq package-archives '(("melpa"        . "https://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")
                          ("gnu"          . "https://mirrors.tuna.tsinghua.edu.cn/gnu/elpa/gnu/")
                          ("nongnu"       . "https://mirrors.tuna.tsinghua.edu.cn/elpa/nongnu/")
                          ("melpa-stable" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/melpa-stable/")))

;; Use ghproxy mirror for tree-sitter grammar downloads (github.com is slow/blocked)
(with-eval-after-load 'treesit-auto
  (setq treesit-language-source-alist
        (mapcar (lambda (entry)
                  (plist-put entry :url
                    (if (string-match "github.com" (plist-get entry :url))
                        (replace-match "https://ghproxy.com/https://github.com" t t (plist-get entry :url))
                      (plist-get entry :url))))
                treesit-language-source-alist)))
