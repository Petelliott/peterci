;;; methods for using the db described in schema.sql
(defpackage :peterci.db
  (:nicknames pdb)
  (:use cl)
  (:export
    #:create-repo
    #:create-build))

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




(defun create-build (conn repo &optional (status :running) (logs nil))
  (dbi:with-transaction conn
    (db-oneshot conn
                "INSERT INTO Build
                (repo, status, logs)
                VALUES (?, ?, ?)"
                repo (stattoi status) logs)
    (getf (dbi:fetch
            (db-oneshot conn "SELECT LAST_INSERT_ID()"))
          :|LAST_INSERT_ID()|)))



(defun db-oneshot (conn qstr &rest vals)
  (let ((query (dbi:prepare conn qstr)))
    (apply #'dbi:execute query vals)))


(defun itostat (i)
  (elt #(:running :unfinished :passed :failed) i))


(defun stattoi (stat)
  (getf '(:running 0 :unfinished 1 :passed 2 :failed 3) stat))


(defun btoi (bool)
  (if bool 1 0))
