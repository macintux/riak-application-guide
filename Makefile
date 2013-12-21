sources = front.md anti-patterns.md denormalization.md modeling.md \
          conflicts.md tuning.md dynamic.md back.md

%.pdf :: %.md
	pandoc $*.md -o $*.pdf

guide.% :: $(sources)
	pandoc --toc $(sources) -o guide.$*

guide.epub :: $(sources)
	pandoc --chapters $(sources) -o guide.epub
