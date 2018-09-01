(defpackage :peterci.api.repo
  (:nicknames :api.repo)
  (:use :cl)
  (:export
    ))

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
