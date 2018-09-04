(defpackage :peterci.api.repo
  (:nicknames :api.repo)
  (:use :cl))

(in-package :peterci.api.repo)


(setf (ningle:route api:*app* "/repo/:repo" :method :GET)
      (lambda (params)
        (api.util:headers :content-type "application/json")
        (json:encode-json-to-string
          (putil:plist-to-alist
            (api.util:nf-on-nil
              (db.repo:get-repo api:*conn* (cdr (assoc :repo params))))))))


(setf (ningle:route api:*app* "/repo/:provider/:user/:repo" :method :GET)
      (lambda (params)
        (api.util:headers :content-type "application/json")
        (json:encode-json-to-string
          (api.util:nf-on-nil
            (putil:plist-to-alist
              (db.repo:get-by-info api:*conn*
                                   (cdr (assoc :provider params))
                                   (cdr (assoc :user params))
                                   (cdr (assoc :repo params))))))))


(defun set-active (conn repo active)
  (api.util:status 204)
  (db.repo:set-active conn
                      repo
                      (api.util:truthy active)))


(setf (ningle:route api:*app* "/repo/:repo/active" :method :POST)
      (lambda (params)
        (set-active api:*conn*
                    (cdr (assoc :repo params))
                    (cdr (assoc "active" params :test #'string=)))))


(setf (ningle:route api:*app* "/repo/:provider/:user/:repo/active" :method :POST)
      (lambda (params)
        (let ((id (api.util:url-to-repo api:*conn* params)))
          (set-active api:*conn*
                      id
                      (cdr (assoc "active" params :test #'string=))))))


(defun status-image (repo &optional (branch "master"))
  "redirect to a status badge for the repo and branch"
  (api.util:status 303)
  (let ((res (db.repo:get-status api:*conn* repo branch)))
    (api.util:headers :location
                      (format nil
                              "https://img.shields.io/badge/peterci-~A-~A.svg"
                              (getf '(:passed "passing"
                                      :failed "failing"
                                      nil "unknown") res)
                              (getf '(:passed "brightgreen"
                                      :failed "red"
                                      nil "yellow") res))))
  "you should be redirected to an image")


(setf (ningle:route api:*app* "/statusimage/:repo" :method :GET)
      (lambda (params)
        (status-image (cdr (assoc :repo params)))))


(setf (ningle:route api:*app* "/statusimage/:repo/:branch" :method :GET)
      (lambda (params)
        (status-image (cdr (assoc :repo params))
                      (cdr (assoc :branch params)))))


(setf (ningle:route api:*app* "/statusimage/:provider/:user/:repo" :method :GET)
      (lambda (params)
        (let ((rid (api.util:url-to-repo api:*conn* params)))
          (status-image rid))))


(setf (ningle:route api:*app* "/statusimage/:provider/:user/:repo/:branch" :method :GET)
      (lambda (params)
        (let ((rid (api.util:url-to-repo api:*conn* params)))
          (status-image rid
                        (cdr (assoc :branch params))))))
