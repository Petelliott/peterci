(defpackage :peterci.api
  (:nicknames :api)
  (:use :cl)
  (:export
    #:*app*
    #:*conn*
    #:*config*
    #:start
    #:stop))

(in-package :peterci.api)


(defvar *app* (make-instance 'ningle:<app>))

(defvar *conn*)

(defvar *config* '(:clack (*app*)
                   :db    (:mysql
                           :database-name "peterci"
                           :username "root")))


(defmacro with-config-db (&rest blck)
  `(progn
     (setf *conn* (apply #'dbi:connect
                         (getf *config* :db)))
     (unwind-protect
       (progn ,@blck)
       (dbi:disconnect *conn*))))


(defvar *handler*)

(defun start ()
    (setf *conn* (apply #'dbi:connect
                        (getf *config* :db)))
    (setf *handler* (apply #'clack:clackup (getf *config* :clack))))


(defun stop ()
  (clack:stop *handler*)
  (dbi:disconnect *conn*))
