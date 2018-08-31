(defpackage :peterci.builder.docker
  (:use :cl :peterci.util)
  (:nicknames :docker)
  (:export
    #:*docker-uri*
    #:with-container
    #:container-create
    #:container-wait
    #:container-start
    #:container-stop
    #:container-delete
    #:container-put-archive
    #:container-get-logs))


(in-package :peterci.builder.docker)


;; *docker-uri* is the uri that docker requests will
;; be made to. this variable can also be used to set
;; api version.
(defvar *docker-uri* "http://localhost:2735/")


(defmacro with-container (container image &rest forms)
  "provides a temporary container that will be
   deleted after the block ends"
  `(let ((,container (container-create ,image)))
     (multiple-value-prog1
       (progn ,@forms)
       (container-delete ,container))))


(defun container-create (image)
  "create a docker container from an image and
   return it's ID"
  (cdr
    (assoc
      :*id
      (json-post
        (dpath "/containers/create")
        `(("Image" . ,image))))))


(defun container-wait (container)
  "wait for a container to finish and return it's
   exit status"
  (cdr
    (assoc
      :*Status-Code
      (json-post
        (dpath "containers" container "wait")))))


(defun container-start (container)
  "start a given container"
  (dex:post
    (dpath "containers" container "start")))


(defun container-stop (container)
  "stop a given container"
  (dex:post
    (dpath "containers" container "stop")))


(defun container-delete (container)
  "delete a given container"
  (dex:delete
    (dpath "containers" container)))


(defun container-put-archive (container ar-path)
  "upload an archive to a given container"
  (dex:put
    (dpath "containers" container "archive?path=/repo")
    :headers '(("Content-Type" . "application/x-tar"))
    :content (pathname ar-path)))


(defun container-get-logs (container)
  "get the stdout and stderr logs of a given
   container as a string"
  (parse-log-stream
    (dex:get
      (dpath "containers" container "logs?stdout=1&stderr=1"))))


(defun parse-log-stream (vec)
  "strip the 8-byte header from a docker log and
   convert it to a string"
  (setf vec (subseq vec 8))

  (with-output-to-string (strm)
    (dotimes (i (length vec))
      (write-char (code-char (elt vec i)) strm)
      (if (= (elt vec i) (char-code #\newline))
        (incf i 8)))))


(defun dpath (&rest paths)
  "merge the given paths with the  *docker-uri*"
  (apply #'pmerge (cons *docker-uri* paths)))
