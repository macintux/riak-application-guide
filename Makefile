sources = front.md anti-patterns.md denormalization.md modeling.md \
          conflicts.md transactions.md tuning.md cautionary.md \
          backends.md dynamic.md back.md

## Always use -s for standalone, --smart for typographic sugar
opts = -s --smart

## Make individual chapter for review
%.pdf :: %.md
	pandoc $(opts) $*.md -o $*.pdf

## Make any format not otherwise defined
guide.% :: $(sources)
	pandoc $(opts) --toc $(sources) -o guide.$*

## Make the epub (use --chapters)
guide.epub :: $(sources)
	pandoc $(opts) --chapters $(sources) -o guide.epub

## Not sold yet on --chapters for PDF format, so use book.pdf
## when desired, guide.pdf when not
book.pdf :: $(sources)
	pandoc $(opts) --chapters --toc $(sources) -o book.pdf

clean:
	rm -f *.pdf *.html *.epub *.tex
