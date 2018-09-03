(defpackage :peterci.api.util
  (:nicknames :api.util)
  (:use :cl)
  (:export
    #:headers
    #:nf-on-nil
    #:status))

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
