(defpackage :builder
  (:use :cl :builder.docker)
  (:export
    #:build))

(in-package :builder)


(defun build (ar-file &optional (image "peterci-env"))
  (let ((con (container-create image)))
    (container-put-archive con ar-file)
    (container-start con)
    (values
      (container-wait con)
      (container-get-logs con))))

