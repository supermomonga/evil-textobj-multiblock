;;; evil-textobj-multiblock.el --- Multi block text object for evil  -*- lexical-binding: t; -*-

;; Copyright (C) 2015  supermomonga

;; Author: supermomonga
;; Keywords: convenience, emulations
;; Created: 2015-04-05
;; Version: 0.0.1
;; Package-Requires: ((emacs "24") (evil "1.0.0"))
;; URL: https://github.com/supermomonga/evil-textobj-multiblock

;; The MIT License (MIT)
;;
;; Copyright (c) <year> <copyright holders>
;;
;; Permission is hereby granted, free of charge, to any person obtaining a copy
;; of this software and associated documentation files (the "Software"), to deal
;; in the Software without restriction, including without limitation the rights
;; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;; copies of the Software, and to permit persons to whom the Software is
;; furnished to do so, subject to the following conditions:
;;
;; The above copyright notice and this permission notice shall be included in
;; all copies or substantial portions of the Software.
;;
;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
;; THE SOFTWARE.

;;; Commentary:

;; This is the textobj plugin for evil, to treat multiple parentheses or blocks by same key.
;; You can define keymaps like following:
;; (define-key evil-outer-text-objects-map evil-textobj-multiblock-outer-key 'evil-multiblock-outer-block)
;; (define-key evil-inner-text-objects-map evil-textobj-multiblock-inner-key 'evil-multiblock-inner-block)


;;; Code:


(require 'cl-lib)
(require 'evil)

(defgroup evil-textobj-multiblock nil
  "Text object multi block for Evil"
  :prefix "evil-textobj-multiblock-"
  :group 'evil)

(defcustom evil-textobj-multiblock-outer-key "b"
  "Key for outer block"
  :type 'string
  :group 'evil-textobj-multiblock)

(defcustom evil-textobj-multiblock-inner-key "b"
  "Key for inner block"
  :type 'string
  :group 'evil-textobj-multiblock)

;; The types of OPEN and CLOSE specify which kind of THING is used
;; for parsing with `evil-select-block'. If OPEN and CLOSE are
;; characters `evil-up-paren' is used. Otherwise OPEN and CLOSE
;; must be regular expressions and `evil-up-block' is used."
(defcustom evil-textobj-multiblock-blocks
  '(
    (?( ?))
    (?[ ?])
    (?{ ?})
    (?< ?>)
    ("\"" "\"")
    ("'" "'")
    ("`" "`")
    ;; for ruby
    ("def" "end")
    ("do" "end")
    ("case" "end")
    )
  "Pair list of beginning and end character of block"
  :type '(list (cons string (cons string (const nil))))
  :group 'evil-textobj-multiblock)

(evil-define-text-object evil-multiblock-outer-block (count &optional beg end type)
  "Select outer of block"
  :extend-selection nil
  (evil-textobj-multiblock-select-nearest-paren
   evil-textobj-multiblock-blocks beg end type count t))

(evil-define-text-object evil-multiblock-inner-block (count &optional beg end type)
  "Select inner of block"
  :extend-selection nil
  (evil-textobj-multiblock-select-nearest-paren
   evil-textobj-multiblock-blocks beg end type count))

(defun evil-textobj-multiblock-select-nearest-paren (parentheses beg end type count &optional inclusive)
  "Select a nearest parenthesis from current cursor point"
  (let ((selections
         (cl-loop for (open close) in parentheses
                  for selected = (ignore-errors (evil-select-paren open close beg end type count inclusive))
                  for (selected-beg selected-end) = selected
                  when (and selected (< selected-beg (point)) (> selected-end (point)))
                  collect selected)))
    (print selections)
    (let ((nearest-selection
          (car-safe (cl-sort selections #'> :key #'car))))
      (if (null nearest-selection)
          (error "No surrounding delimiters found") nearest-selection))))

(provide 'evil-textobj-multiblock)
;;; evil-textobj-multiblock.el ends here
