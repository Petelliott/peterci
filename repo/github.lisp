(defpackage :peterci.repo.github
  (:nicknames github-driver)
  (:use :cl :peterci.repo :peterci.util))

(in-package :peterci.repo.github)


(defstruct gh-repo
  username
  repo)

(defun make-gh-repo-call (username repo)
  (make-gh-repo :username username
                :repo     repo))


(register-service "github" #'make-gh-repo-call)


(defmethod get-tarball ((repo gh-repo) refspec &optional strm)
  (let ((tar-strm
          (dex:get
            (pmerge "https://api.github.com/repos"
                    (gh-repo-username repo)
                    (gh-repo-repo repo)
                    "tarball" refspec)
            :want-stream t
            :force-binary t)))
    (if strm
      (stream-pipe tar-strm strm)
      tar-strm)))
