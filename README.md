# Curriculum-Vitae-Latex
A simple CV made for graduate school applications and new graduate students.  The CV is made using LateX and ModernCV.  Adaption by Armin Hadzic. Original by Xavier Danaux

# How it works:
The makefile builds a PDF, using LaTeX, corresponding to the \*.tex file in a given directory. 

For example, 
```
new_resume/MyNewResume.tex 
```
will correspond to am output PDF: 
```
build/new_resume-MyNewResume.pdf
```

# How to use it:

## Make a new resume/CV
```shell
mkdir new_resume
touch new_resume/MyNewResume.tex
```
Then edit the tex file.

## Building
```shell
make new_resume
```
The result should be located in the build directory:
```console
ls build/new_resume-MyNewResume.pdf
```

Alternatively, run an example:
1. Build an example resume:
```shell
make general_resume
```
2. Build an example CV:
```shell
make general_cv
```
3. Build a resume/CV in a private directory:
```shell
make priv/secret
```

## Cleaning
```shell
make clean
```