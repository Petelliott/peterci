(defpackage :peterci.builder
  (:use :cl)
  (:nicknames :builder)
  (:export
    #:build
    #:sql-build))

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


(defun sql-build (conn repoid branch ref)
  "builds the branch repoid and creates an sql build
   this function is designed to be run as it's own thread"
  (let* ((res (db.repo:get-repo conn repoid))
         (path (fad:with-output-to-temporary-file
                 (strm :element-type '(unsigned-byte 8))
                 (ci-repo:get-tarball
                   (res-to-repo res)
                   ref strm)))
         (buildid (db.build:create conn repoid ref branch)))
    (multiple-value-bind (status logs)
        (build path)
      (db.build:update
        conn buildid
        (if status :passed :failed)
        logs))))


(defun res-to-repo (res)
  (ci-repo:make-repo
    (getf res :|provider|)
    (getf res :|username|)
    (getf res :|repo|)))

