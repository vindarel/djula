(in-package #:djula)

(define-condition template-error (simple-error)
  ())

(defun template-error-string (fmt &rest args)
  (format nil "{# Error: ~? #}" fmt args))

(defun template-error-string* (error fmt &rest args)
  (if *verbose-errors-p*
      (format nil "{# Error: ~A : ~A #}"
              (apply #'format nil fmt args)
              error)
      (apply #'template-error-string fmt args)))

(defun template-error (msg &rest args)
  (error 'template-error
         :format-control msg
         :format-arguments args))

(defun template-error* (error msg &rest args)
  (if *verbose-errors-p*
      (error 'template-error
             :format-control "~A: ~A"
             :format-arguments (list* error args))
      (apply #'template-error msg args)))

(defmacro with-template-error (recovery-form &body body)
  (with-unique-names (e)
    `(handler-case
         (progn
           ,@body)
       (error (,e)
         (if (and *catch-template-errors-p*
                  (not *fancy-error-template-p*))
             ,recovery-form
             (error ,e))))))

(defun render-error-template (error backtrace &optional template stream)
  "Render the *ERROR-TEMPLATE* with the ERROR, the BACKTRACE and the TEMPLATE
where the error ocurred."
  (let ((error-template (compile-template* *error-template*)))
    (djula:render-template* error-template stream
                            :error error
                            :error-backtrace backtrace
                            :template template)))
