\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{Proposal}[Proposal.]

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}

\ProcessOptions\relax
\LoadClass[a4paper,12pt]{article}
\RequirePackage[zihao=5,scheme=chinese,fontset=fandol,heading]{ctex}

\RequirePackage{fontspec}
\RequirePackage{indentfirst}
\RequirePackage{mathptmx}

\ctexset{
	section={
		format=\bfseries\songti\zihao{4},
		aftername={. },
		beforeskip=0.5ex,
		afterskip=0.5ex,
	}
}
\ctexset{
	subsection={
		format=\bfseries\songti\zihao{5} ,
		beforeskip=0.5ex,
		afterskip=0.5ex,
	}
}

\ctexset{
	bibname = {}
}


\setmainfont{Times New Roman}

\RequirePackage{caption}
\DeclareCaptionFont{song}{\songti}
\DeclareCaptionFont{minusfour}{\zihao{-4}}
\DeclareCaptionFont{figurefont}{\heiti\zihao{5}}
\captionsetup[figure]{
	format=hang,
	labelsep=quad,
	font=figurefont,
	position=bottom, 
}


\RequirePackage{xunicode}
\RequirePackage{xltxtra}
\RequirePackage{fancyhdr}
\RequirePackage{fancybox}

\RequirePackage{setspace}
\RequirePackage{ifthen,epsfig,graphicx}
\RequirePackage{color}
\RequirePackage{etoolbox}

\RequirePackage{ulem}

\RequirePackage{array}
\newcommand{\PreserveBackslash}[1]{\let\temp=\\#1\let\\=\temp}
\newcolumntype{C}[1]{>{\PreserveBackslash\centering}m{#1}}
\newcolumntype{R}[1]{>{\PreserveBackslash\raggedleft}m{#1}}
\newcolumntype{L}[1]{>{\PreserveBackslash\raggedright}m{#1}}

\newcommand{\@School}{?}
\newcommand{\School}[1]{\renewcommand{\@School}{#1}}

\newcommand{\@Major}{?}
\newcommand{\Major}[1]{\renewcommand{\@Major}{#1}}

\newcommand{\@Faculty}{?}
\newcommand{\Faculty}[1]{\renewcommand{\@Faculty}{#1}}

\newcommand{\@ThesisTitle}{?}
\newcommand{\ThesisTitle}[1]{\renewcommand{\@ThesisTitle}{#1}}

\newcommand{\@Supervisor}{?}
\newcommand{\Supervisor}[1]{\renewcommand{\@Supervisor}{#1}}


\newcommand{\@Date}{?}
\newcommand{\Date}[1]{\renewcommand{\@Date}{#1}}

\setlength{\parindent}{2em}

\RequirePackage[dvipsnames]{xcolor}
\RequirePackage{hyperref}
\hypersetup{
	colorlinks=true,
	citecolor=blue,
	linkcolor=OrangeRed,
}

\RequirePackage{lipsum}

\renewcommand{\maketitle}{
	\thispagestyle{empty}
  	\clearpage
  	\noindent{\leftline{}}\\
  	\vspace{3em}\\
  
  	\noindent{\centerline{ \songti \zihao{1} \textbf{南京航空航天大学}}}\\~\\
  	\noindent{\centerline{ \songti \zihao{1} \textbf{毕业设计（论文）开题报告}}}\\
  
  	\vspace{8em}
	\begin{center}
		\zihao{3}
		\linespread{1.25}\selectfont
        \begin{tabular}{>{}p{2.6cm} >{}p{6.5cm}}
        	{{\makebox[75pt][s]{学院：}}} &\@Faculty\\\cline{2-2}\\[-1.8ex]
			{{\makebox[75pt][s]{专业：}}} &\@Major\\\cline{2-2}\\[-1.8ex]
			{{\makebox[75pt][s]{题目：}}} &\@ThesisTitle\\\cline{2-2}\\[-1.8ex]
			{{\makebox[75pt][s]{学生信息：}}} &\@author\\\cline{2-2}\\[-1.8ex]
			{{\makebox[75pt][s]{毕设地点：}}} &\@School\\\cline{2-2}\\[-1.8ex]
			{{\makebox[75pt][s]{指导教师：}}} &\@Supervisor\\\cline{2-2}\\[-1.8ex]
        \end{tabular}\\
    	\vfill
    	{\songti \bfseries\zihao{3}{\@Date}}
	\end{center}
  	\clearpage
  	\setcounter{page}{1}
  	\fancypagestyle{firststyle}{
		\fancyhead{}
		\fancyfoot[RO]{}
		\fancyfoot[LE]{}
		\fancyfoot[C]{-\thepage-}
		\renewcommand{\headrulewidth}{0pt}
	}
	\thispagestyle{firststyle}
	\clearpage
	\pagestyle{fancy}
	\fancyhead{}
	\fancyfoot[RO]{}
	\fancyfoot[LE]{}
	\fancyfoot[C]{-\thepage-}
	\renewcommand{\headrulewidth}{0pt}

	\fancypage{
		\setlength{\fboxsep}{8pt}
		\setlength{\fboxrule}{0.8pt}
		\setlength{\shadowsize}{0pt}
		\shadowbox
	}{}

}


\ifthenelse{\boolean{@titlepage}}{
	\let\@ldabstract=\abstract
  	\let\@ldendabstract=\endabstract
  	\renewenvironment{abstract}{
    	\@ldabstract
    	\setcounter{page}{0}
  	}{
		\par
    	\@keywords
    	\vfill
    	\begin{center}
      		\@lab
    	\end{center}
    	\vfill
    	\@ldendabstract
    	\setcounter{page}{1}
  	}
}{}


\AtEndDocument{
  	\clearpage
  	\begin{picture}(100,100)(0,0)
		\put(-24,85){\zihao{5} \heiti 指导教师意见（对课题的深度、广度及工作量的意见和对毕业设计（论文）结果的预测）：}
    	\put(140,-15){\zihao{5} 指导教师签字：}
		\put(300,-15){\zihao{5} 年~~~~~~月~~~~~~日}

		\put(-29.5,-20){\line(1,0){472.5}}

		\put(-24,-40){\zihao{5} \heiti 系审查意见：}	
		\put(140,-140){\zihao{5} 系主任签字：}	
		\put(300,-140){\zihao{5} 年~~~~~~月~~~~~~日}

		\put(-29.5,-145){\line(1,0){472.5}}
	\end{picture}
}


