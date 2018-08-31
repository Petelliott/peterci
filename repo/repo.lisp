;;; generic methods for repo access
(defpackage :peterci.repo
  (:use :cl)
  (:export
    #:get-tarball
    #:register-service
    #:make-repo))


(in-package :repo)

;; downloads a tarball of the repo and returns it's path or stream
;; (streams are not yet supported by dexador
(defgeneric get-tarball (repo refspec))


(defvar *repo-hash* (make-hash-table))


(defun register-service (provider creat-fun)
  "registers a service provider with a function
   that takes a username and repo and returns
   an object with the neccesary generics defined"
  (setf (gethash provider *repo-hash*) creat-fun))


(defun make-repo (provider usr repo)
  "create a repo with the given characteristics"
  (funcall
    (gethash provider *repo-hash*)
    usr repo))
