

(defpackage :peterci.repo-asd
  (:use :cl :asdf))


(in-package :peterci.repo-asd)


(defsystem peterci.repo
  :depends-on (:cl-json
               :dexador
               :peterci.util)
  :components ((:module "repo"
                :components
                ((:file "repo")
                 (:file "github")))))
