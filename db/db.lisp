;;; methods for using the db described in schema.sql
(defpackage :peterci.db
  (:nicknames pdb)
  (:use :cl :peterci.db.util)
  (:export
    #:create-repo
    #:get-repo
    #:create-build
    #:update-build))

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


(defun get-repo (conn id)
  "get the repo associated with id"
  (let ((res (dbi:fetch
               (db-oneshot conn
                           "SELECT * FROM Repo WHERE id=?"
                           id))))
    (plist-set res :|active| (itob (getf res :|active|)))))


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


(defun update-build (conn id status &optional logs)
  "update the build associated with ID
  status: one of :running :stopped :passed :failed
  logs: string of logs (left the same if null)"
  (dbi:with-transaction conn
    (update-build-status conn id status)
    (if logs
      (update-build-logs conn id logs))))


(defun update-build-status (conn id status)
  "update status of build ID to one of
  :running :stopped :passed :failed"
  (db-oneshot conn
              "UPDATE Build SET status=? WHERE id=?"
              (stattoi status) id))


(defun update-build-logs (conn id logs)
  "set the logs for build ID"
  (db-oneshot conn
              "UPDATE Build SET logs=? WHERE id=?"
              logs id))
