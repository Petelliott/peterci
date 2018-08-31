(defpackage :peterci.db.build
  (:nicknames :db.build)
  (:use :cl :peterci.db.util)
  (:export
    #:create
    #:update
    #:get-build))


(in-package :peterci.db.build)


(defun create (conn repo &optional (status :running) logs)
  (dbi:with-transaction conn
    (db-oneshot conn
                "INSERT INTO Build
                (repo, status, logs)
                VALUES (?, ?, ?)"
                repo (stattoi status) logs)
    (getf (dbi:fetch
            (db-oneshot conn "SELECT LAST_INSERT_ID()"))
          :|LAST_INSERT_ID()|)))


(defun update (conn id status &optional logs)
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


(defun get-build (conn id)
  "get the build associated with ID"
  (convert-build-record
    (dbi:fetch
      (db-oneshot conn
                  "SELECT * FROM Build
                  WHERE id=?"
                  id))))
