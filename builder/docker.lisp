(defpackage :builder.docker
  (:use :cl)
  (:export
    #:*docker-uri*
    #:create
    #:dpath
    #:json-post
    #:json-get))


(in-package :builder.docker)


(defvar *docker-uri* "http://localhost:2735/")


(defun create (image)
  (cdr
    (assoc
      :*id
      (json-post
        (dpath "/containers/create")
        `(("Image" . ,image))))))


(defun dpath (path)
  (concatenate
    'string *docker-uri*
    (if (and (> (length path) 0) (equal (elt path 0) #\/))
      (subseq path 1)
      path)))


(defun json-post (uri data)
  (json:decode-json-from-string
    (dex:post
      uri
      :headers '(("Content-Type" . "application/json"))
      :content (json:encode-json-to-string
                 data))))


(defun json-get (uri)
  (json:decode-json-from-string
    (dex:get uri)))


