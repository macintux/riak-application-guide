sources = front.md anti-patterns.md denormalization.md modeling.md conflicts.md dynamic.md back.md

%.pdf :: %.md
	pandoc $*.md -o $*.pdf

guide.% :: $(sources)
	pandoc $(sources) -o guide.$*

guide.epub :: $(sources)
	pandoc --chapters $(sources) -o guide.epub
