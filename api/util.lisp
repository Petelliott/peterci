(defpackage :peterci.api.util
  (:nicknames :api.util)
  (:use :cl)
  (:export
    #:headers
    #:nf-on-nil
    #:status
    #:truthy
    #:url-to-repo))

(in-package :peterci.api.util)


(defun headers (&rest headers)
  (setf (lack.response:response-headers ningle:*response*)
        (append (lack.response:response-headers ningle:*response*)
                headers)))


(defun nf-on-nil (form)
  (if (null form)
    (setf (lack.response:response-status ningle:*response*) 404))
  form)


(defun status (status)
  (setf (lack.response:response-status ningle:*response*) status))


(defun truthy (val)
  (cdr (assoc
         val
         '((t . t)
           ("true" . t)
           (1 . t))
         :test #'equal)))


(defun url-to-repo (conn params)
  "convert provider/user/repo in url to a repo id"
  (getf (db.repo:get-by-info
          conn
          (cdr (assoc :provider params))
          (cdr (assoc :user params))
          (cdr (assoc :repo params)))
        :|id|))
