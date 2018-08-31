;;; generic methods for repo access
(defpackage :peterci.repo
  (:nicknames :ci-repo)
  (:use :cl)
  (:export
    #:get-tarball
    #:register-service
    #:make-repo))


(in-package :peterci.repo)

;; downloads a tarball of the repo and returns a strem
;; unless strm is set, in which case it writes to strm
(defgeneric get-tarball (repo refspec &optional strm))


(defvar *repo-hash* (make-hash-table :test #'equal))


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
