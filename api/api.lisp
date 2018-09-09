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
(defvar *config*)

(defvar def-config '(:clack ()
                     :db    (:mysql
                              :database-name "peterci"
                              :username "root")
                     :gh-key #P"/home/peter/tokens/peterci-dev.2018-09-04.private-key.pem"))



;; TODO: these functions are buggy as fuck


(defun start (&optional (config def-config))
  (let* ((*config* config)
         (*conn* (apply #'dbi:connect
                       (getf *config* :db))))
    (list
      :clack (apply #'clack:clackup *app* (getf *config* :clack))
      :db-conn *conn*)))


(defun stop (handler)
  (clack:stop (getf handler :clack))
  (dbi:disconnect (getf handler :db-conn)))
