
(defpackage :peterci.api-asd
  (:use :cl :asdf))


(in-package :peterci.api-asd)


(defsystem peterci.api
  :depends-on (:ningle
               :cl-dbi
               :clack
               :jose
               :pem
               :peterci.builder
               :peterci.db
               :peterci.repo
               :peterci.util)
  :components ((:module "api"
                :components
                ((:file "util")
                 (:file "api")
                 (:file "repo")
                 (:file "github")))))
