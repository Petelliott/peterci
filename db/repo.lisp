(defpackage :peterci.db.repo
  (:nicknames :db.repo)
  (:use :cl :peterci.db.util)
  (:export
    #:create
    #:get-repo
    #:set-active
    #:get-by-info
    #:get-status
    #:get-builds))

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


(defun set-active (conn repo &optional (active t))
  "sets the repo to active or not"
  (dbi:do-sql conn
              "UPDATE Repo SET active=? WHERE id=?"
              (db.util:btoi active) repo))



(defun get-by-info (conn provider usr repo)
  "get the repo associated with the provider, usr, and repo"
  (convert-repo-record
    (dbi:fetch
      (db-oneshot conn
                  "SELECT * FROM Repo WHERE
                  provider=? AND username=? AND repo=?"
                  provider usr repo))))


(defun get-status (conn id &optional (branch "master"))
  "get the repo's build status"
  (let ((res (getf
               (dbi:fetch (db-oneshot
                            conn
                            "SELECT status FROM Build
                            WHERE repo=? AND (status=2 OR status=3)
                                  AND branch=?
                            ORDER BY id DESC"
                            id branch))
               :|status|)))
    (if res
      (itostat res)
      res)))


(defun get-builds (conn id &optional branch)
  "get the builds of a repo, if branch is specified,
   get only those of branch"
  (if branch
    (get-builds-branch conn id branch)
    (get-builds-all conn id)))


(defun get-builds-all (conn id)
  "get the repo's builds"
  (mapcar #'convert-build-record
          (dbi:fetch-all
            (db-oneshot
              conn
              "SELECT * FROM Build
              WHERE repo=? ORDER BY id DESC"
              id))))


(defun get-builds-branch (conn id branch)
  "get the repo's builds on branch"
  (mapcar #'convert-build-record
          (dbi:fetch-all
            (db-oneshot
              conn
              "SELECT * FROM Build
              WHERE repo=? AND branch=?
              ORDER BY id DESC"
              id branch))))
