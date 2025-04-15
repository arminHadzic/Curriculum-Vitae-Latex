LATEX = pdflatex
LATEXOPT = --shell-escape
NONSTOP = --interaction=nonstopmode
LATEXMK = latexmk
LATEXMKOPT = -pdf
CONTINUOUS = -pvc

# Bibliography location
BIBDIR=publications
export BIBINPUTS := $(BIBDIR):


# Public resume directories (you control this list)
DIRS = general_resume general_cv

# Target for building all resumes (public + private)
all: $(DIRS) $(shell find priv -maxdepth 1 -mindepth 1 -type d)
	@echo "📦 All resumes built and collected in 'build/'"

# Rule for public directories
$(DIRS):
	@$(MAKE) build DIR=$@

# Rule for private subdirectories (like priv/openai)
priv/%: force
	@$(MAKE) build DIR=$@

# Dummy target to force rebuild
force:

# Central rule used for both public and private builds
build:
	@echo "📂 Searching for .tex file in '$(DIR)'..."
	@TEXFILE=$$(find $(DIR) -maxdepth 1 -name '*.tex'); \
	COUNT=$$(echo $$TEXFILE | wc -w); \
	if [ $$COUNT -eq 0 ]; then \
		echo "❌ No .tex file found in '$(DIR)'"; exit 1; \
	elif [ $$COUNT -gt 1 ]; then \
		echo "❌ Multiple .tex files found in '$(DIR)':"; \
		echo "$$TEXFILE"; \
		echo "➡️  Please keep only one .tex file in the folder."; exit 1; \
	else \
		echo "✅ Compiling $$TEXFILE..."; \
		$(LATEXMK) $(LATEXMKOPT) -output-directory=$(DIR) \
			-pdflatex="$(LATEX) $(LATEXOPT) $(NONSTOP) %O %S" \
			$$TEXFILE; \
		echo "📥 Moving PDF to build/ directory..."; \
		mkdir -p build; \
		BASENAME=$$(basename $$TEXFILE .tex); \
		DIRNAME=$$(basename $(DIR)); \
		mv -f $(DIR)/$$BASENAME.pdf build/$$DIRNAME-$$BASENAME.pdf; \
		echo "📄 build/$$DIRNAME-$$BASENAME.pdf created."; \
	fi


# Clean both public and private outputs
clean:
	@echo "🧼 Cleaning public directories..."
	@for dir in $(DIRS); do \
		find $$dir -maxdepth 1 \( \
			-name "*.aux" -o -name "*.log" -o -name "*.out" -o -name "*.fdb_latexmk" \
			-o -name "*.fls" -o -name "*.bbl" -o -name "*.blg" -o -name "*.pdf" \
			-o -name "*-blx.bib" -o -name "*.run.xml" \
		\) -delete 2>/dev/null || true; \
	done

	@echo "🧼 Cleaning private directories..."
	@for dir in priv/*; do \
		if [ -d $$dir ]; then \
			find $$dir -maxdepth 1 \( \
				-name "*.aux" -o -name "*.log" -o -name "*.out" -o -name "*.fdb_latexmk" \
				-o -name "*.fls" -o -name "*.bbl" -o -name "*.blg" -o -name "*.pdf" \
				-o -name "*-blx.bib" -o -name "*.run.xml" \
			\) -delete 2>/dev/null || true; \
		fi \
	done

	@echo "🗑️  Removing build directory..."
	#@rm -rf build


.PHONY: all $(DIRS) build clean force
