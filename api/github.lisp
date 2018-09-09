(defpackage :peterci.api.github
  (:nicknames api.gh)
  (:use :cl))

(in-package :peterci.api.github)


(setf (ningle:route api:*app* "/hooks/github/authorize" :method :POST)
      (lambda (params)
        (print params)
        (print #\newline)))


(setf (ningle:route api:*app* "/hooks/github" :method :POST)
      (lambda (params)
        (print params)
        (print #\newline)))


(defun unix-time ()
  (- (get-universal-time)
     (encode-universal-time 0 0 0 1 1 1970 0)))


(defun get-jwt-token (id pemfile)
  "gets a jwt for github with id"
  (jose/jwt:encode
    :RS256
    (pem:read-from-file pemfile)
    `(("iat" . ,(unix-time))
      ("exp" . ,(+ (unix-time) (* 10 60)))
      ("iss" . ,id))))
