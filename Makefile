# 
# Adapted from: https://drewsilcock.co.uk/using-make-and-latexmk  
#

LATEX=pdflatex
LATEXOPT=--shell-escape
NONSTOP=--interaction=nonstopmode
#for bibliographies
BIBTEX=bibtex

LATEXMK=latexmk
LATEXMKOPT=-pdf
CONTINUOUS=-pvc

MAIN=ArminHadzicCV
SOURCES=$(MAIN).tex Makefile
FIGURES := $(shell find figs/* -type f)

MAIN_RESUME=ArminHadzicResume
SOURCES_RESUME=$(MAIN_RESUME).tex Makefile

all: $(MAIN).pdf $(MAIN_RESUME).pdf

.refresh:
	touch .refresh

$(MAIN).pdf: $(MAIN).tex .refresh $(SOURCES) $(FIGURES)
	$(LATEXMK) $(LATEXMKOPT) $(CONTINUOUS) \
		-pdflatex="$(LATEX) $(LATEXOPT) $(NONSTOP) %O %S" $(MAIN)

$(MAIN_RESUME).pdf: $(MAIN_RESUME).tex .refresh $(SOURCES_RESUME) $(FIGURES)
	$(LATEXMK) $(LATEXMKOPT) $(CONTINUOUS) \
		-pdflatex="$(LATEX) $(LATEXOPT) $(NONSTOP) %O %S" $(MAIN_RESUME)

force:
	touch .refresh
	rm $(MAIN).pdf
	$(LATEXMK) $(LATEXMKOPT) $(CONTINUOUS) \
		-pdflatex="$(LATEX) $(LATEXOPT) %O %S" $(MAIN)
	rm $(MAIN_RESUME).pdf
	$(LATEXMK) $(LATEXMKOPT) $(CONTINUOUS) \
		-pdflatex="$(LATEX) $(LATEXOPT) %O %S" $(MAIN_RESUME)

clean:
	$(LATEXMK) -C $(MAIN)
	$(LATEXMK) -C $(MAIN_RESUME)
	rm -f $(MAIN).pdfsync
	rm -f $(MAIN_RESUME).pdfsync
	rm -rf *~ *.tmp
	rm -f *.bbl *.blg *.brf *.aux *.end *.fls *.log *.out *.fdb_latexmk *-blx.bib

once: 
	$(LATEX) $(MAIN)
	$(BIBTEX) $(MAIN).aux
	$(LATEXMK) $(LATEXMKOPT) -pdflatex="$(LATEX) $(LATEXOPT) %O %S" $(MAIN)

	$(LATEX) $(MAIN_RESUME)
	$(BIBTEX) $(MAIN_RESUME).aux
	$(LATEXMK) $(LATEXMKOPT) -pdflatex="$(LATEX) $(LATEXOPT) %O %S" $(MAIN_RESUME)

cv:
	$(LATEX) $(MAIN)
	$(BIBTEX) $(MAIN).aux
	$(LATEXMK) $(LATEXMKOPT) -pdflatex="$(LATEX) $(LATEXOPT) %O %S" $(MAIN)


resume:
	$(LATEX) $(MAIN_RESUME)
	$(BIBTEX) $(MAIN_RESUME).aux
	$(LATEXMK) $(LATEXMKOPT) -pdflatex="$(LATEX) $(LATEXOPT) %O %S" $(MAIN_RESUME)

debug:
	$(LATEX) $(LATEXOPT) $(MAIN)
	$(LATEX) $(LATEXOPT) $(MAIN_RESUME)

.PHONY: clean force once all
