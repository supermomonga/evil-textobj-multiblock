;;; evil-textobj-multiblock.el --- Multi block text object for evil  -*- lexical-binding: t; -*-

;; Copyright (C) 2015  supermomonga

;; Author: supermomonga <@supermomonga>
;; Keywords: convenience, emulations

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; You can define maps as following:
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

(defcustom evil-textobj-multiblock-blocks
  '(
    ("(" ")")
    ("[" "]")
    ("{" "}")
    ("<" ">")
    ("\"" "\"")
    ("'" "'")
    ("`" "`")
    )
  "Pair list of beginning and end character of block"
  :type '(list (cons string (cons string (const nil))))
  :group 'evil-textobj-multiblock)

(evil-define-text-object evil-multiblock-outer-block (count &optional beg end type)
  "Select outer of block"
  (evil-textobj-multiblock-select-nearest-paren
   evil-textobj-multiblock-blocks beg end type count t))

(evil-define-text-object evil-multiblock-inner-block (count &optional beg end type)
  "Select inner of block"
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
    (let ((nearest-selection
          (car-safe (sort selections
                          (lambda (a b)
                              (> (car a) (car b)))))))
      (if (null nearest-selection)
          (error "No surrounding delimiters found") nearest-selection))))

(provide 'evil-textobj-multiblock)
;;; evil-textobj-multiblock.el ends here
