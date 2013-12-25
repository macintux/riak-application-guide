sources = front.md anti-patterns.md denormalization.md modeling.md \
          conflicts.md transactions.md tuning.md cautionary.md \
          backends.md dynamic.md back.md

%.pdf :: %.md
	pandoc $*.md -o $*.pdf

guide.% :: $(sources)
	pandoc --toc $(sources) -o guide.$*

guide.html :: $(sources) htmlhead.html htmltail.html
	pandoc --toc $(sources) -o tmp.html
	cat htmlhead.html tmp.html htmltail.html > guide.html
	rm tmp.html

guide.epub :: $(sources)
	pandoc --chapters $(sources) -o guide.epub

book.pdf :: $(sources)
	pandoc --chapters --toc $(sources) -o book.pdf

book.tex :: $(sources)
	pandoc --chapters --toc $(sources) -o book.tex
