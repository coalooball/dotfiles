;;; post-early-init.el --- Personal config -*- lexical-binding: t; -*-

;; Use Tsinghua TUNA mirrors for faster package downloads in China.
(setq package-archives '(("melpa"        . "https://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")
                          ("gnu"          . "https://mirrors.tuna.tsinghua.edu.cn/gnu/elpa/gnu/")
                          ("nongnu"       . "https://mirrors.tuna.tsinghua.edu.cn/elpa/nongnu/")
                          ("melpa-stable" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/melpa-stable/")))
