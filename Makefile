.PHONEY: publish
publish: | public themes/beautifulhugo static/css/syntax.css
	hugo
	cd public && git add -A .
	cd public && git commit -m "Publishing site $(shell date)"
	cd public && git push origin master
	@echo
	@echo "Published to https://polothy.github.io"

themes/beautifulhugo:
	git clone https://github.com/halogenica/beautifulhugo.git themes/beautifulhugo

static/css/syntax.css:
	# try paraiso-dark
	hugo gen chromastyles --style=dracula > static/css/syntax.css

public:
	git clone git@github.com:polothy/polothy.github.io.git public
	cd public && git config user.email "watermark.nielsen@gmail.com"