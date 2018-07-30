;;; dart-mode-test.el --- Tests for dart-mode

(require 'dart-mode)
(require 'faceup)

(ert-deftest dart-test ()
  (let ((file (make-temp-file "analysis")))
    (dart-add-analysis-root-for-file file)
    (let ((proc (dart--analysis-server-process
		 dart--analysis-server)))
      (accept-process-output proc)
      (accept-process-output proc)
      (accept-process-output proc 8))))

(defun dart-font-lock-test (faceup)
  (let (dart-enable-analysis-server)
    (if (and (= emacs-major-version 24)
	     (= emacs-minor-version 3))
	(let ((c-standard-font-lock-fontify-region-function
	       'font-lock-default-fontify-region))
	  (faceup-test-font-lock-string 'dart-mode faceup))
      (faceup-test-font-lock-string 'dart-mode faceup))))
(faceup-defexplainer dart-font-lock-test)

(ert-deftest dart-void-main-test ()
  (should (dart-font-lock-test "«t:void» «f:main»() =>")))

(ert-deftest dart-main-test ()
  :expected-result :failed
  (should (dart-font-lock-test "«f:main»() =>")))

(ert-deftest dart-double-quoted-string-test ()
  (should (dart-font-lock-test "«t:String» «v:str» = «s:\"Hello, World!\"»;")))

(ert-deftest dart-single-quoted-string-test ()
  :expected-result (if (>= emacs-major-version 26)
                       :failed
                     :passed)
  (should (dart-font-lock-test "«t:String» «v:str» = «s:'Hello, World!'»;")))

(ert-deftest dart-single-quoted-multi-line-string-test ()
  :expected-result :failed
  (should (dart-font-lock-test "«t:String» «v:str» = «s:'''Don't do that.'''»;")))

(ert-deftest dart-double-quoted-multi-line-string-test ()
  (should (dart-font-lock-test "«t:String» «v:str» = «s:\"\"\"Don't do that.\"\"\"»;")))

;;; dart-mode-test.el ends here
