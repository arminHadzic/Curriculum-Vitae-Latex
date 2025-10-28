LATEX ?= xelatex # pdflatex
LATEXOPT = --shell-escape
NONSTOP = --interaction=nonstopmode
LATEXMK = latexmk
CONTINUOUS = -pvc

# Build the command latexmk should run for "PDF-from-LaTeX"
LATEXMK_ENGINE_OPT = -$(LATEX)

# Bibliography location
BIBDIR = publications
export BIBINPUTS := $(BIBDIR):

# Optional preview mode
PREVIEW_MODE ?= false

# Public resume directories (you control this list)
DIRS = general_resume general_cv general_hybrid

.PHONY: preview all $(DIRS) force build clean

# Update the pdf live whenever a tex change is made
preview: PREVIEW_MODE=true
preview: $(filter-out preview,$(MAKECMDGOALS))

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
		$(LATEXMK) $(LATEXMK_ENGINE_OPT) \
			 -output-directory=$(DIR) \
			 -latexoption="$(NONSTOP)" \
			 -latexoption="$(LATEXOPT)" \
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


# Catch-all rule for building resumes (with or without preview)
%:
	@echo "📂 Processing target '$@'..."
	@TEXFILE=$$(realpath $$(find $@ -maxdepth 1 -name '*.tex')); \
	COUNT=$$(echo $$TEXFILE | wc -w); \
	if [ $$COUNT -eq 0 ]; then \
		echo "❌ No .tex file found in '$@'"; exit 1; \
	elif [ $$COUNT -gt 1 ]; then \
		echo "❌ Multiple .tex files found in '$@':"; \
		echo "$$TEXFILE"; \
		echo "➡️  Please keep only one .tex file in the folder."; exit 1; \
	else \
		echo "✅ Found $$TEXFILE"; \
		mkdir -p build; \
		BASENAME=$$(basename $$TEXFILE .tex); \
		DIRNAME=$$(basename $@); \
		OUTPDF="build/$$DIRNAME-$$BASENAME.pdf"; \
		if [ "$(PREVIEW_MODE)" = "true" ]; then \
			echo "👀 Live preview mode enabled..."; \
			$(LATEXMK) $(LATEXMK_ENGINE_OPT) -pvc \
				-jobname="$$DIRNAME-$$BASENAME" \
				-output-directory=build \
				-latexoption="$(NONSTOP)" \
  				-latexoption="$(LATEXOPT)" \
				$$TEXFILE; \
		else \
			echo "🔨 Compiling once to $$OUTPDF..."; \
			$(LATEXMK) $(LATEXMK_ENGINE_OPT) \
				-jobname="$$DIRNAME-$$BASENAME" \
				-output-directory=build \
				-latexoption="$(NONSTOP)" \
  				-latexoption="$(LATEXOPT)" \
				$$TEXFILE; \
			echo "✅ Output: $$OUTPDF"; \
		fi
