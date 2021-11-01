;;; package --- summary
;;; Commentary:
(require 'package)
(package-initialize)
;; (add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/") t)
;; (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; (package-refresh-contents)
;; (package-install 'htmlize)
;; (package-install 'org-plus-contrib)
;; Don't want to invoke insert-shebang locally
(remove-hook 'find-file-hook 'insert-shebang)

(require 'org)
(require 'ox-publish)
(require 'htmlize)
(require 'ox-html)
;; (require 'ox-rss)
(setq system-time-locale "C")


;; (setq calendar-week-start-day 1
;;           calendar-day-name-array ["Domingo" "Lunes" "Martes" "Miércoles" 
;;                                    "Jueves" "Viernes" "Sábado"]
;;           calendar-month-name-array ["Gennaio" "Febbraio" "Marzo" "Aprile" "Maggio"
;;                                      "Giugno" "Luglio" "Agosto" "Settembre" 
;;                                      "Ottobre" "Novembre" "Dicembre"])




;;; Code:
(setq org-confirm-babel-evaluate nil)


;; setting to nil, avoids "Author: x" at the bottom
(setq org-export-with-section-numbers nil
      org-export-with-smart-quotes t
      org-export-with-toc nil)


(defvar aang-date-format "%b %d, %Y")


(setq org-html-divs '((preamble "header" "top")
                      (content "main" "content")
                      (postamble "footer" "postamble"))
      org-html-container-element "section"
      org-html-metadata-timestamp-format aang-date-format
      org-html-checkbox-type 'html
      org-html-html5-fancy t
      org-html-validation-link t
      org-html-doctype "html5"
      org-html-htmlize-output-type 'css
      org-src-fontify-natively t)


(defvar aang-website-html-head
  "<meta name='viewport' content='width=device-width, initial-scale=1'>
<!-- UIkit CSS -->
<link rel='stylesheet' href='https://cdn.jsdelivr.net/npm/uikit@3.5.5/dist/css/uikit.min.css' />

<!-- UIkit JS -->
<script src='https://cdn.jsdelivr.net/npm/uikit@3.5.5/dist/js/uikit.min.js'></script>
<script src='https://cdn.jsdelivr.net/npm/uikit@3.5.5/dist/js/uikit-icons.min.js'></script>
<!-- own little style -->
<link rel='stylesheet' type='text/css' href='../css/site.css' />
<!-- Global site tag (gtag.js) - Google Analytics -->
<script async src='https://www.googletagmanager.com/gtag/js?id=UA-177387524-1'></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());

  gtag('config', 'UA-177387524-1');
</script>

")

(defun aang-website-html-preamble (plist)
  "PLIST: An entry."
  ;; Skip adding subtitle to the post if :KEYWORDS don't have 'post' has a
  ;; keyword
  (when (string-match-p "post" (format "%s" (plist-get plist :keywords)))
    (plist-put plist
	       :subtitle (format "Published on %s by %s."
				 (org-export-get-date plist aang-date-format)
				 (car (plist-get plist :author)))))

  ;; Below content will be added anyways
  "")



(defvar aang-website-html-postamble
  "
<div class='footer'>
<hr>
Copyright © 2020 <a href='mailto:aang.drummer@gmail.com'>Abel Güitian</a> | <a href='https://github.com/aang7/aang7.github.io'>Source</a><br>
Last updated on %C using %c <br>
</div>")


(defun psachin/org-sitemap-format-entry (entry style project)
  "Format posts with author and published data in the index page.

ENTRY: file-name
STYLE:
PROJECT: `posts in this case."
  (cond ((not (directory-name-p entry))
         (format "*[[file:%s][%s]]*
                 #+HTML: <p class='pubdate'>by %s on %s.</p>"
                 entry
                 (org-publish-find-title entry project)
                 (car (org-publish-find-property entry :author project))
                 (format-time-string aang-date-format
                                     (org-publish-find-date entry project))))
        ((eq style 'tree) (file-name-nondirectory (directory-file-name entry)))
        (t entry)))


;; aang stuff


(defun my-html-body-onload-filter (output backend info)
  "Add class to<body>  tag, if any."
  (when (and (eq backend 'html)
	     (string-match "<body>\n" output))
    (replace-match "<body class='uk-container-small uk-align-center uk-text-justify'> \n" nil nil output)
    ))


(defun wrap-img-tags ()
  (setq text-to-search-1 "<img src=\"")
  (goto-char (point-min))
  (setq ntimes (count-matches text-to-search-1))

  (if (> ntimes 0)
      (cl-loop repeat ntimes do ;; this is like a for loop

	   (search-forward "<img src=\"" nil t)
	   (setq x-start (point))
	   (search-forward "\"")
	   (backward-char)
	   (setq x-end (point))
	   (kill-ring-save x-start x-end)
	   (beginning-of-line)
	   (insert (format "\n<div uk-lightbox=\"animation: slide\">
     <a href=\"%s\">\n" (car kill-ring)))
	   (indent-for-tab-command)
	   (forward-line)
	   (insert (format "</a>\n</div>"))
		 	     
	   )
      
      nil
      )
  )

;; todo: create a function to add text before or after a tag


(defun add-class-to-tag (tag class)
  "Add class attribute with the class variable value.
TAG: Tag to modify.
CLASS: Class in string form to add."
;  (interactive "sTag:\nsClass:")

  (setq text-to-search (format "<%s" tag))
  (goto-char (point-min))

  (setq does-it-have-class-attribute t)
  (cl-loop repeat (how-many text-to-search)  do ;; this is like a for loop
	   
	   (search-forward text-to-search)
	   (setq x-start (point))

	   (setq does-it-have-class-attribute (search-forward
					       "class=\""
					       (line-end-position)
					       t ; if fails return nil
					       ))

	   (if (not does-it-have-class-attribute)

	       (progn ;; then
		 (insert (format " class=\"%s\"" class))
		 (setq does-it-have-class-attribute nil)
		 )

	     (progn ;; else
	       (search-forward "\"")
	       (backward-char)
	       (insert (format " %s" class))

	       ))
	   )
  
  )


(defun add-content-before-tag (tag content)
  "You have to write the exact string of the tag to add before it.
This function only works for html tags, that means that tags has to
 be wrapped with '<' and '>'
TAG: Tag to modify.
CONTENT: string to add."
  ;; (interactive "sTag:\nsContent:")
  (goto-char (point-min)) ; go to the start of the file
  (condition-case nil
      (progn
        (search-forward tag nil t) ;; this always will return nil
	  (search-backward "<" nil t)	  
	  (insert content)	 	
	  (indent-for-tab-command)	 
	  )
    (error nil))
  )


(defun org-blog-publish-to-html (plist filename pub-dir)
  "Same as `org-html-publish-to-html' but modifies html before finishing."
  (let ((file-path (org-html-publish-to-html plist filename pub-dir)))
    (with-current-buffer (find-file-noselect file-path)
      (wrap-img-tags);; aqui va la funcion de img
      (add-class-to-tag "h2" "uk-heading-divider")
      (add-class-to-tag "section" "uk-margin-remove-bottom uk-margin-remove-top uk-card uk-card-default uk-card-body uk-align-center uk-text-justify")
      (add-class-to-tag "h1" "uk-h2 uk-panel uk-padding uk-background-secondary uk-light uk-margin-left uk-margin-right")
      (when (and (string-match "posts" filename) (not (string-match "index" filename)))
	(add-content-before-tag "</main" "
<div>
<div class='comments uk-card uk-card-default uk-margin-auto'>
  <div id='disqus_thread'></div>
  <script>
    /*var disqus_config = function () {
    this.page.url = PAGE_URL;  // Replace PAGE_URL with your page's canonical URL variable
    this.page.identifier = PAGE_IDENTIFIER; // Replace PAGE_IDENTIFIER with your page's unique identifier variable
    };*/

    (function() { // DON'T EDIT BELOW THIS LINE
    var d = document, s = d.createElement('script');
    s.src = 'https://aang7-github-io.disqus.com/embed.js';
    s.setAttribute('data-timestamp', +new Date());
    (d.head || d.body).appendChild(s);
    })();
  </script>
  <noscript>Please enable JavaScript to view the <a href='https://disqus.com/?ref_noscript'>comments powered by Disqus.</a></noscript>
</div>
</div>
"))      
      (save-buffer)
      (kill-buffer)
      )
    file-path))

;; ends aang stuff


(setq org-publish-project-alist
      `(("posts"
	 :base-directory "posts"
	 :base-extension "org"
	 :recursive t
	 :publishing-function org-blog-publish-to-html ;; org-html-publish-to-html
	 :publishing-directory "./public"
	 :auto-sitemap t
	 :language "es"
	 :sitemap-filename "index.org"
	 :sitemap-title "Camino la Verdad - Blog"
	 :sitemap-format-entry psachin/org-sitemap-format-entry
	 :sitemap-style list
	 :sitemap-sort-files anti-chronologically
	 :html-link-home "../"
         :html-link-up "../"
	 :html-head-include-scripts t
         :html-head-include-default-style nil
	 :html-head ,aang-website-html-head
	 :html-preamble aang-website-html-preamble
	 :html-postamble ,aang-website-html-postamble)
	("css"
	 :base-directory "css/"
	 :base-extension "css"
	 :publishing-directory "public/css"
	 :publishing-function org-publish-attachment
	 :recursive t)
	("static-files"
	 :base-directory "files/"
	 :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|mp3\\|ogg\\|swf\\|jpeg"
	 :publishing-directory "public/files"
	 :recursive t
	 :publishing-function org-publish-attachment
	 )
	("all" :components ("posts" "css" "static-files"))))

(provide 'publish)
;;; publish.el ends here
