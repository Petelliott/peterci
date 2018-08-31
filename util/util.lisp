;;; utilities for peterci
(defpackage :peterci.util
  (:nicknames :putil)
  (:use :cl)
  (:export
    #:stream-pipe
    #:pmerge
    #:starts-with
    #:ends-with
    #:json-post
    #:json-get))

(in-package :peterci.util)


(defun stream-pipe (in-stream out-stream)
  "copies a byte stream from in-stream to
   out-stream"
  (loop
    (let ((ch (read-byte in-stream nil)))
      (if (null ch)
        (return)
        (write-byte ch out-stream)))))


(defun pmerge (&rest paths)
  "merge pathnames
   ('a' 'b')   -> 'a/b'
   ('a/' '/b') -> 'a/b'"
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
  "check if sequence whole starts with sequence
   start. t if whole == start also"
  (and
    (<= (length start) (length whole))
    (equal (subseq whole 0 (length start)) start)))


(defun ends-with (whole end)
  "check if sequence whole ends with sequence
   end. t if whole == end also"
  (and
    (<= (length end) (length whole))
    (equal (subseq whole (- (length whole) (length end))) end)))


(defun json-post (uri &optional data)
  "post a cl-json lisp object data to uri and
   then return the cl-json encoded result"
  (json:decode-json-from-string
    (dex:post
      uri
      :headers '(("Content-Type" . "application/json"))
      :content (if data
                 (json:encode-json-to-string data)
                 nil))))


(defun json-get (uri)
  "get from url and return the cl-json encoded
   result"
  (json:decode-json-from-string
    (dex:get uri)))
