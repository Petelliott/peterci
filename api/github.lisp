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
