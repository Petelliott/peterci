(defpackage :peterci.db.repo
  (:nicknames :db.repo)
  (:use :cl :peterci.db.util)
  (:export
    #:create
    #:get-repo
    #:get-by-info))

(in-package :peterci.db.repo)


(defun create (conn provider usr repo &optional (active t))
  "creates a repo with the given paramaters, an returns it's id"
  (dbi:with-transaction conn
    (db-oneshot conn
                "INSERT INTO Repo
                (provider, username, repo, active)
                VALUES (?, ?, ?, ?)"
                provider usr repo (btoi active))
    (getf (dbi:fetch
            (db-oneshot conn "SELECT LAST_INSERT_ID()"))
          :|LAST_INSERT_ID()|)))


(defun get-repo (conn id)
  "get the repo associated with id"
  (convert-repo-record
    (dbi:fetch
      (db-oneshot conn
                  "SELECT * FROM Repo WHERE id=?"
                  id))))


(defun get-by-info (conn provider usr repo)
  "get the repo associated with the provider, usr, and repo"
  (convert-repo-record
    (dbi:fetch
      (db-oneshot conn
                  "SELECT * FROM Repo WHERE
                  provider=? AND username=? AND repo=?"
                  provider usr repo))))
