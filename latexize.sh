#! /bin/bash

# genereert een pdf bestand van alle uitwerkingen

FILESPEC="*.[Cc]*"	# c/c++
FILESPEC="*.[di]cl"	# clean

generate() {

cat <<EOF
\documentclass[a4paper]{article}
\usepackage[cm, headings]{fullpage}
\usepackage{listings}
\usepackage{bera}
\begin{document}
\lstset{
%  language=C++,
%clean definitions
   language=Clean,
   literate={->}{{$\to$}}2 {<-}{{$\gets$}}2 {<=}{{$\le$}}1 {>=}{{$\ge$}}1,
%end clean definitions
   frame=topline,
   numbers=left, 
   breaklines=true,
   emptylines=*2,
   commentstyle=\rmfamily\itshape,
   basicstyle=\ttfamily\footnotesize
   }
EOF

import() {
	if [ -e "$1" ]; then
		name="${1//[&\$%\#_\{\}]/\\_}"
#		echo "\begin{lstlisting}[title=\sf ${name##*/}]"
#		cat "$1"
#		echo "\end{lstlisting}"
		echo "\lstinputlisting[title=\sf ${name##*/}]{\"$1\"}"
	fi
}

for dir in s*; do
	echo "\section*{\sf\Huge"
	if [ -e "$dir/$dir.txt" ]; then
		sed -n 's/^Name:\(.*\)$/\1\\\\/p' "$dir/$dir.txt"
	else
		echo $dir
	fi
	echo "}"
	for file in "$dir"/*.txt; do import "$file"; done
	for file in "$dir"/${FILESPEC}; do import "$file"; done
	echo "\newpage"
done

cat <<EOF
\end{document}
EOF

}

if [ "$1" == "-" ]; then
	generate
else
	generate | pdflatex
fi

