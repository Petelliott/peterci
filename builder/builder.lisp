(defpackage :peterci.builder
  (:use :cl)
  (:nicknames :builder)
  (:export
    #:build))

(in-package :peterci.builder)


(defun build (ar-file &optional (image "peterci-env"))
  "build the repo in ar-file and return the
   build status and the logs"
  (docker:with-container con image
    (docker:container-put-archive con ar-file)
    (docker:container-start con)
    (values
      (zerop (docker:container-wait con))
      (docker:container-get-logs con))))
