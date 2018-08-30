;;; methods for using the db described in schema.sql
(defpackage :peterci.db
  (:nicknames pdb)
  (:use cl)
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


(defun db-oneshot (conn qstr &rest vals)
  (let ((query (dbi:prepare conn qstr)))
    (apply #'dbi:execute query vals)))


(defun itostat (i)
  (elt #(:running :stopped :passed :failed) i))


(defun stattoi (stat)
  (getf '(:running 0 :stopped 1 :passed 2 :failed 3) stat))


(defun btoi (bool)
  (if bool 1 0))


(defun itob (i)
  (if (zerop i) nil t))


(defun plist-set (plist key val)
  (if plist
    (if (eq key (car plist))
      (mcons key val (cddr plist))
      (mcons (car plist) (cadr plist)
             (plist-set (cddr plist) key val)))
    (list key val)))


(defun mcons (&rest args)
  (if (null (cdr args))
    (car args)
    (cons
      (car args)
      (apply #'mcons (cdr args)))))
