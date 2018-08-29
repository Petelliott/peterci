(defpackage :peterci.builder
  (:use :cl)
  (:nicknames :builder)
  (:export
    #:build))

(in-package :peterci.builder)


(defun build (ar-file &optional (image "peterci-env"))
  (let ((con (docker:container-create image)))
    (docker:container-put-archive con ar-file)
    (docker:container-start con)
    (multiple-value-prog1
      (values
        (docker:container-wait con)
        (docker:container-get-logs con))
      (docker:container-delete con))))

