(defpackage :peterci.api
  (:nicknames :api)
  (:use :cl)
  (:export
    *app*
    *conn*
    *config*))

(in-package :peterci.api)


(defvar *app* (make-instance 'ningle:<app>))


(defvar *conn* (dbi:connect :mysql
                            :database-name "peterci"
                            :username "root"))


(defvar *config* nil)
