
(defpackage :peterci.db-asd
  (:use :cl :asdf))


(in-package :peterci.db-asd)


(defsystem peterci.db
  :depends-on (:cl-dbi)
  :components ((:module "db"
                :components
                ((:file "util")
                 (:file "repo")
                 (:file "build")))))
