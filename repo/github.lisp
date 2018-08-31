(defpackage :peterci.repo.github
  (:nicknames github-driver)
  (:use :cl :peterci.repo)
  (:export
    ))

(in-package :peterci.repo.github)


(defstruct gh-repo
  username
  repo)

(defun make-gh-repo-call (username repo)
  (make-gh-repo :username username
                :repo     repo))


(register-service "github" #'make-gh-repo-call)


(defmethod get-tarball ((repo gh-repo) refspec)
  (dex-get
