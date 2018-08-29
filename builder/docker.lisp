(defpackage :builder.docker
  (:use :cl)
  (:export
    #:*docker-uri*
    #:container-create
    #:container-wait
    #:container-start
    #:container-stop
    #:container-delete
    #:container-put-archive
    #:container-get-logs))


(in-package :builder.docker)


(defvar *docker-uri* "http://localhost:2735/")


(defun container-create (image)
  (cdr
    (assoc
      :*id
      (json-post
        (dpath "/containers/create")
        `(("Image" . ,image))))))


(defun container-wait (container)
  (cdr
    (assoc
      :*Status-Code
      (json-post
        (dpath "containers" container "wait")))))


(defun container-start (container)
  (dex:post
    (dpath "containers" container "start")))


(defun container-stop (container)
  (dex:post
    (dpath "containers" container "stop")))


(defun container-delete (container)
  (dex:delete
    (dpath "containers" container)))


(defun container-put-archive (container ar-path)
  (dex:put
    (dpath "containers" container "archive?path=/repo")
    :headers '(("Content-Type" . "application/x-tar"))
    :content (pathname ar-path)))


(defun container-get-logs (container)
  (parse-log-stream
    (dex:get
      (dpath "containers" container "logs?stdout=1&stderr=1"))))


(defun parse-log-stream (vec)
  (setf vec (subseq vec 8))

  (with-output-to-string (strm)
    (dotimes (i (length vec))
      (write-char (code-char (elt vec i)) strm)
      (if (= (elt vec i) (char-code #\newline))
        (incf i 8)))))


(defun dpath (&rest paths)
  (apply #'pmerge (cons *docker-uri* paths)))


(defun pmerge (&rest paths)
  (cond
    ((= (length paths) 0) "")
    ((= (length paths) 1) (car paths))
    (t
      (concatenate
        'string
        (if (ends-with (car paths) "/")
          (car paths)
          (concatenate 'string (car paths) "/"))
        (let ((prest (apply #'pmerge (cdr paths))))
          (if (starts-with prest "/")
            (subseq prest 1)
            prest))))))


(defun starts-with (whole start)
  (and
    (<= (length start) (length whole))
    (equal (subseq whole 0 (length start)) start)))


(defun ends-with (whole end)
  (and
    (<= (length end) (length whole))
    (equal (subseq whole (- (length whole) (length end))) end)))


(defun json-post (uri &optional data)
  (json:decode-json-from-string
    (dex:post
      uri
      :headers '(("Content-Type" . "application/json"))
      :content (if data
                 (json:encode-json-to-string data)
                 nil))))


(defun json-get (uri)
  (json:decode-json-from-string
    (dex:get uri)))


