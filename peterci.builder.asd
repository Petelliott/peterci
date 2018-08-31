
(defpackage :peterci.builder-asd
  (:use :cl :asdf))


(in-package :peterci.builder-asd)


(defsystem peterci.builder
  :depends-on (:cl-json
               :dexador
               :peterci.util)
  :components ((:module "builder"
                :components
                ((:file "docker")
                 (:file "builder")))))
