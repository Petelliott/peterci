(defpackage :peterci.api.util
  (:nicknames :api.util)
  (:use :cl)
  (:export
    #:headers
    #:nf-on-nil
    #:status
    #:truthy))

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
