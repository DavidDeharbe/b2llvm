
NAME= specification

all: $(NAME).pdf translation.pdf

$(NAME).pdf:

#%.dvi : %.tex
#	latex $<
#	latex $<

%.ps : %.dvi
	dvips -o $@ $<

%.pdf : %.ps
	ps2pdf $< $@

%.pdf : %.tex
	pdflatex -shell-escape $<
	pdflatex -shell-escape $<

%.pdf : %.fig
	fig2dev -L pdftex $< $@

clean:
	-rm -f *~ *.out *.aux *.dvi *.ps *.pdf *.toc *.lof *.log *.lot *.flg *.bbl *.blg *.idx *.ind *.ilg *.snm *.nav *.fig.bak
