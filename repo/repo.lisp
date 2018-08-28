;;; generic methods for repo access
(defpackage :repo
  (:use :cl)
  (:export
    #:get-tarball
    #:repo-name
    #:set-ci-status
    #:do-on-push))


(in-package :repo)


(defgeneric get-tarball (repo))

(defgeneric repo-name (repo))

(defgeneric set-ci-status (repo status))

(defgeneric do-on-push (repo func))
