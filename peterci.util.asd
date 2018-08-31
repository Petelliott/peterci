

(defpackage :peterci.util-asd
  (:use :cl :asdf))


(in-package :peterci.util-asd)


(defsystem peterci.util
  :depends-on (:cl-json
               :dexador)
  :components ((:module "util"
                :components
                ((:file "util")))))
