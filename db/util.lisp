(defpackage :peterci.db.util
  (:nicknames :db.util)
  (:use cl)
  (:export
    #:convert-repo-record
    #:convert-build-record
    #:db-oneshot
    #:itostat
    #:stattoi
    #:btoi
    #:itob
    #:plist-set))

(in-package :peterci.db.util)


(defun convert-repo-record (record)
  (if record
    (plist-set record :|active| (itob (getf record :|active|)))))


(defun convert-build-record (record)
  (if record
    (plist-set record :|status| (itostat (getf record :|status|)))))


(defun db-oneshot (conn qstr &rest vals)
  "prepares then executes a query with vals as args"
  (apply #'dbi:execute
         (dbi:prepare conn qstr) vals))


(defun itostat (i)
  "converts an int to a build status"
  (elt #(:running :stopped :passed :failed) i))


(defun stattoi (stat)
  "converts a build status to an int"
  (getf '(:running 0 :stopped 1 :passed 2 :failed 3) stat))


(defun btoi (bool)
  "converts a bool to an int"
  (if bool 1 0))


(defun itob (i)
  "converts an int to a bool"
  (if (zerop i) nil t))


(defun plist-set (plist key val)
  "creates a new plist with the value of
  key set to val. appends the entry if the
  key does not exist in the original list"
  (if plist
    (if (eq key (car plist))
      (mcons key val (cddr plist))
      (mcons (car plist) (cadr plist)
             (plist-set (cddr plist) key val)))
    (list key val)))


(defun mcons (&rest args)
  "conses the first n args with the last one"
  (if (null (cdr args))
    (car args)
    (cons
      (car args)
      (apply #'mcons (cdr args)))))
