;;; methods for using the db described in schema.sql
(defpackage :peterci.db
  (:nicknames pdb)
  (:use cl)
  (:export
    #:create-repo))

(in-package :peterci.db)


(defun create-repo (conn provider usr repo &optional (active t))
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


(defun db-oneshot (conn qstr &rest vals)
  (let ((query (dbi:prepare conn qstr)))
    (apply #'dbi:execute query vals)))


(defun btoi (bool)
  (if bool 1 0))
