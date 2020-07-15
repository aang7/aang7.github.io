(require 'ox-publish)

(setq org-publish-project-alist
      '(
	("posts"
	 :base-directory "posts/"
	 :base-extension "org"
	 :publishing-directory "public/"
	 :recursive t
	 :publishing-function org-html-publish-to-html
	 :headline-levels 4
	 :auto-sitemap t
	 :sitemap-title "Blog Index"
	 :sitemap-filename "index.org"
	 :sitemap-style list
	 :author "John Doe"
	 :email "john.doe@example.com"
	 :with-creator t)
	
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
	
	("all" :components ("posts" "css" "static-files"))
	
	)
      )
