sources = front.md anti-patterns.md denormalization.md modeling.md \
          conflicts.md transactions.md tuning.md cautionary.md \
          backends.md dynamic.md back.md

## Make individual chapter for review
%.pdf :: %.md
	pandoc $*.md -o $*.pdf

## Make any format not otherwise defined
guide.% :: $(sources)
	pandoc -s --toc $(sources) -o guide.$*

## Make the epub (use --chapters)
guide.epub :: $(sources)
	pandoc -s --chapters $(sources) -o guide.epub

## Not sold yet on --chapters for PDF format, so use book.pdf
## when desired, guide.pdf when not
book.pdf :: $(sources)
	pandoc -s --chapters --toc $(sources) -o book.pdf
