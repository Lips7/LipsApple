\NeedsTeXFormat{LaTeX2e}[2017/04/15]
\ProvidesClass{nuaathesis}[2020/04/03 v3.2.1 nuaa thesis template]

% 报错和警告
\newcommand\nuaa@error[1]{%
  \ClassError{nuaathesis}{#1}{}%
}
\newcommand\nuaa@warning[1]{%
  \ClassWarning{nuaathesis}{#1}%
}

% 检查 \LaTeXe{} kernel 版本
\@ifl@t@r\fmtversion{2017/04/15}{}{
  \nuaa@error{%
    TeX Live 2017 or later version is required to compile this document%
  }
}

% 检查编译引擎，要求使用 XeLaTeX。
\RequirePackage{iftex}
\ifXeTeX\else
  \nuaa@error{XeLaTeX is required to compile this document}
\fi


% \subsection{处理选项}

\RequirePackage{kvdefinekeys}
\RequirePackage{kvsetkeys}
\RequirePackage{kvoptions}

% 提供一个 \cs{nuaasetup} 命令支持 \emph{key-value} 的方式来设置。
\newcommand\nuaasetup{%
  \kvsetkeys{nuaa}%
}

% 同时用 \emph{key-value} 的方式来定义这些接口：
% \begin{latex}
%   \nuaa@define@key{
%     <key> = {
%       name = <name>,
%       choices = {
%         <choice1>,
%         <choice2>,
%       },
%       default = <default>,
%       code = <code>,
%     },
%   }
% \end{latex}

% 其中 |choices| 设置允许使用的值，默认为第一个（或者 \meta{default}）；
% \meta{code} 是相应的内容被设置时执行的代码。

\newcommand\nuaa@define@key[1]{%
  \kvsetkeys{nuaa@key}{#1}%
}
\kv@set@family@handler{nuaa@key}{%
%
% \cs{nuaasetup} 会将 \meta{value} 存到 \cs{nuaa@\meta{key}}，
% 但是宏的名字包含 “-” 这样的特殊字符时不方便直接调用，比如 |key = math-style|，
% 这时可以用 |name| 设置 \meta{key} 的别称，比如 |key = math@style|，
% 这样就可以通过 \cs{nuaa@math@style} 来引用。
% |default| 是定义该 \meta{key} 时默认的值，缺省为空。
%
  \@namedef{nuaa@#1@@name}{#1}%
  \def\nuaa@@default{}%
  \def\nuaa@@choices{}%
  \kv@define@key{nuaa@value}{name}{%
    \@namedef{nuaa@#1@@name}{##1}%
  }%
  \kv@define@key{nuaa@value}{code}{%
    \@namedef{nuaa@#1@@code}{##1}%
  }%
  %
  % 由于在定义接口时，\cs{nuaa@\meta{key}@@code} 不一定有定义，
  % 而且在文档类/宏包中还有可能对该 |key| 的 |code| 进行添加。
  % 所以 \cs{nuaa@\meta{key}@@code} 会检查如果在定义文档类/宏包时则推迟执行，否则立即执行。
  %
  \@namedef{nuaa@#1@@check}{}%
  \@namedef{nuaa@#1@@code}{}%
  \@namedef{nuaa@#1@@hook}{%
    \@nameuse{nuaa@#1@@code}%
  }%
  %
  % 保存下 |choices = {}| 定义的内容，在定义 \cs{nuaa@\meta{name}} 后再执行。
  %
  \kv@define@key{nuaa@value}{choices}{%
    \def\nuaa@@choices{##1}%
    \@namedef{nuaa@#1@@reset}{}%
    %
    % \cs{nuaa@\meta{key}@check} 检查 |value| 是否有效，
    % 并设置 \cs{ifnuaa@\meta{name}@\meta{value}}。
    %
    \@namedef{nuaa@#1@@check}{%
      \@ifundefined{%
        ifnuaa@\@nameuse{nuaa@#1@@name}@\@nameuse{nuaa@\@nameuse{nuaa@#1@@name}}%
      }{%
        \nuaa@error{Invalid value "#1 = \@nameuse{nuaa@\@nameuse{nuaa@#1@@name}}"}%
      }%
      \@nameuse{nuaa@#1@@reset}%
      \@nameuse{nuaa@\@nameuse{nuaa@#1@@name}@\@nameuse{nuaa@\@nameuse{nuaa@#1@@name}}true}%
    }%
  }%
  \kv@define@key{nuaa@value}{default}{%
    \def\nuaa@@default{##1}%
  }%
  \kvsetkeys{nuaa@value}{#2}%
  \@namedef{nuaa@\@nameuse{nuaa@#1@@name}}{}%
  %
  % 第一个 \meta{choice} 设为 \meta{default}，
  % 并且对每个 \meta{choice} 定义 \cs{ifnuaa@\meta{name}@\meta{choice}}。
  %
  \kv@set@family@handler{nuaa@choice}{%
    \ifx\nuaa@@default\@empty
      \def\nuaa@@default{##1}%
    \fi
    \expandafter\newif\csname ifnuaa@\@nameuse{nuaa@#1@@name}@##1\endcsname
    \expandafter\g@addto@macro\csname nuaa@#1@@reset\endcsname{%
      \@nameuse{nuaa@\@nameuse{nuaa@#1@@name}@##1false}%
    }%
  }%
  \kvsetkeys@expandafter{nuaa@choice}{\nuaa@@choices}%
  %
  % 将 \meta{default} 赋值到 \cs{nuaa@\meta{name}}，如果非空则执行相应的代码。
  %
  \expandafter\let\csname nuaa@\@nameuse{nuaa@#1@@name}\endcsname\nuaa@@default
  \expandafter\ifx\csname nuaa@\@nameuse{nuaa@#1@@name}\endcsname\@empty\else
    \@nameuse{nuaa@#1@@check}%
    \@nameuse{nuaa@#1@@hook}%
  \fi
  %
  % 定义 \cs{nuaasetup} 接口。
  %
  \kv@define@key{nuaa}{#1}{%
    \@namedef{nuaa@\@nameuse{nuaa@#1@@name}}{##1}%
    \@nameuse{nuaa@#1@@check}%
    \@nameuse{nuaa@#1@@hook}%
  }%
}

% 定义接口向 |key| 添加 |code|：

\newcommand\nuaa@option@hook[2]{%
  \expandafter\g@addto@macro\csname nuaa@#1@@code\endcsname{#2}%
}

\newif\ifnuaa@degree@graduate
\newcommand\nuaa@set@graduate{%
  \ifnuaa@degree@bachelor
    \nuaa@degree@graduatefalse
  \else
    \nuaa@degree@graduatetrue
  \fi
}
\nuaa@define@key{
  degree = {
    choices = {
      doctor,
      master,
      bachelor,
    },
    default = doctor,
    code    = {\nuaa@set@graduate},
  },
  degree-type = {
    name = degree@type,
    choices = {
      academic,
      professional,
    },
    default = academic,
  },
  language = {
    choices = {
      chinese,
      english,
    },
    default = chinese,
  },
  fontset = {
    choices = {
      windows,
      mac,
      ubuntu,
      fandol,
      none,
    },
    default = none,
  },
  system = {
    choices = {
      mac,
      unix,
      windows,
      auto,
    },
    default = auto,
  },
  font = {
    choices = {
      times,
      termes,
      xits,
      libertinus,
      lm,
      auto,
      none,
    },
    default = auto,
  },
  cjk-font = {
    name = cjk@font,
    choices = {
      windows,
      mac,
      noto,
      fandol,
      auto,
      none,
    },
    default = auto,
  },
  math-font = {
    name = math@font,
    choices = {
      xits,
      stix,
      libertinus,
      lm,
      none,
    },
    default = xits,
  },
  cite-style = {
    name = cite@style,
    choices = {
      super,
      inline,
      authoryear,
    },
  },
  output = {
    choices = {
      print,
      electronic,
    },
    default = print,
  },
  section-style = {
    name = section@style,
    choices = {
      chinese,
      arabic,
    },
    default = chinese,
  },
  badge-color = {
    name = badge@color,
    choices = {
      blue,
      black,
    },
    default = blue,
  },
}
\ifnuaa@degree@bachelor
  \ifnuaa@language@english
    \nuaasetup{section-style = arabic}
  \fi
\fi
\nuaa@option@hook{language}{%
  \ifnuaa@degree@bachelor
    \ifnuaa@language@english
      \nuaasetup{section-style = arabic}%
    \fi
  \fi
}

% 使用 \pkg{kvoptions} 提供的 key-value 接口，
\SetupKeyvalOptions{
  family  = nuaa,
  prefix  = nuaa@,
  setkeys = \kvsetkeys,
}

% 兼容旧版本的文档类选项。
% Reserved for compatibility until 2020-07-01.
\DeclareVoidOption{doctor}{\nuaasetup{degree=doctor}}
\DeclareVoidOption{master}{\nuaasetup{degree=master}}
\DeclareVoidOption{bachelor}{\nuaasetup{degree=bachelor}}
\DeclareVoidOption{chinese}{\nuaasetup{language=chinese}}
\DeclareVoidOption{english}{\nuaasetup{language=english}}
\DeclareVoidOption{academic}{\nuaasetup{degree-type=academic}}
\DeclareVoidOption{professional}{\nuaasetup{degree-type=professional}}
\DeclareVoidOption{print}{\nuaasetup{output=print}}
\DeclareVoidOption{pdf}{\nuaasetup{output=electronic}}
\newif\ifnuaa@legacy@cite@style
\DeclareVoidOption{super}{\nuaasetup{cite-style=super}\nuaa@legacy@cite@styletrue}
\DeclareVoidOption{numbers}{\nuaasetup{cite-style=inline}\nuaa@legacy@cite@styletrue}
\DeclareVoidOption{authoryear}{\nuaasetup{cite-style=authoryear}\nuaa@legacy@cite@styletrue}
\DeclareVoidOption{arabic}{\nuaasetup{section-style=arabic}}
\DeclareVoidOption{colorlogo}{\nuaasetup{badge-color=blue}}
\DeclareVoidOption{bwlogo}{\nuaasetup{badge-color=black}}

% 载入 \cls{ctexbook}。
\PassOptionsToClass{openany}{ctexbook}
\DeclareDefaultOption{\PassOptionsToClass{\CurrentOption}{ctexbook}}
\ProcessKeyvalOptions*


% \subsection{加载文档类和宏包}

\ifnuaa@language@chinese
  \PassOptionsToClass{scheme=chinese}{ctexbook}
\else
  \PassOptionsToClass{scheme=plain}{ctexbook}
\fi
\ifnuaa@output@electronic
  \PassOptionsToClass{oneside}{book}
\fi
\PassOptionsToPackage{quiet}{xeCJK}

% 载入 \cls{ctexbook} 文档类，注意要求为 2.4.9 或更高的版本。
\LoadClass[UTF8,a4paper,zihao=-4,fontset=none]{ctexbook}[2017/04/01]

% 建议在模板开始处载入全部宏包，不要轻易改变加载顺序。
% \pkg{hyperref} 一般在最后加载。
\RequirePackage{amsmath}
\RequirePackage{fontspec}[2017/03/31]
\RequirePackage{unicode-math}
\RequirePackage[driver=xetex]{geometry}
\RequirePackage{graphicx}
\RequirePackage{fancyhdr}
\RequirePackage{color}
\RequirePackage{titletoc}
\RequirePackage{caption}
\RequirePackage[perpage]{footmisc}
\RequirePackage{url}
\RequirePackage{calc}
\RequirePackage{natbib}
\RequirePackage{notoccite}

% 对冲突的宏包报错。
\RequirePackage{filehook}
\newcommand\nuaa@package@conflict[2]{
  \AtBeginOfPackageFile*{#2}{
    \nuaa@error{The "#2" package is incompatible with required "#1"}
  }
}
\nuaa@package@conflict{unicode-math}{amscd}
\nuaa@package@conflict{unicode-math}{amsfonts}
\nuaa@package@conflict{unicode-math}{amssymb}
\nuaa@package@conflict{unicode-math}{bbm}
\nuaa@package@conflict{unicode-math}{bm}
\nuaa@package@conflict{unicode-math}{eucal}
\nuaa@package@conflict{unicode-math}{eufrak}
\nuaa@package@conflict{unicode-math}{mathrsfs}


% \subsection{字体}

% 处理 \opt{fontset}
\ifnuaa@fontset@mac
  \nuaasetup{
    font     = times,
    cjk-font = mac,
  }
\else
  \ifnuaa@fontset@windows
    \nuaasetup{
      font     = times,
      cjk-font = windows,
    }
  \else
    \ifnuaa@fontset@fandol
      \nuaasetup{
        font     = termes,
        cjk-font = fandol,
      }
    \else
      \ifnuaa@fontset@ubuntu
        \nuaasetup{
          font     = termes,
          cjk-font = noto,
        }
      \fi
    \fi
  \fi
\fi

% 检测系统
\ifnuaa@system@auto
  \IfFileExists{/System/Library/Fonts/Menlo.ttc}{
    \nuaasetup{system = mac}
  }{
    \IfFileExists{/dev/null}{
      \IfFileExists{null:}{
        \nuaasetup{system = windows}
      }{
        \nuaasetup{system = unix}
      }
    }{
      \nuaasetup{system = windows}
    }
  }
\fi

% XITS 字体于 2018-10-03 更改了字体的文件名，所以需要判断。
% 原文件名为 \file{xits-regular.otf}、\file{xits-math.otf} 等，
% 后改为 \file{XITS-Regular.otf}、\file{XITSMath-Regular.otf} 等。
\let\nuaa@font@family@xits\@empty
\newcommand\nuaa@set@xits@names{%
  \ifx\nuaa@font@family@xits\@empty
    \IfFontExistsTF{XITSMath-Regular.otf}{%
      \gdef\nuaa@font@family@xits{XITS}%
      \gdef\nuaa@font@style@xits@rm{Regular}%
      \gdef\nuaa@font@style@xits@bf{Bold}%
      \gdef\nuaa@font@style@xits@it{Italic}%
      \gdef\nuaa@font@style@xits@bfit{BoldItalic}%
      \gdef\nuaa@font@name@xits@math@rm{XITSMath-Regular}%
      \gdef\nuaa@font@name@xits@math@bf{XITSMath-Bold}%
    }{%
      \gdef\nuaa@font@family@xits{xits}%
      \gdef\nuaa@font@style@xits@rm{regular}%
      \gdef\nuaa@font@style@xits@bf{bold}%
      \gdef\nuaa@font@style@xits@it{italic}%
      \gdef\nuaa@font@style@xits@bfit{bolditalic}%
      \gdef\nuaa@font@name@xits@math@rm{xits-math}%
      \gdef\nuaa@font@name@xits@math@bf{xits-mathbold}%
    }%
  \fi
}

% Libertinus 字体同样。
\let\nuaa@font@family@libertinus\@empty
\newcommand\nuaa@set@libertinus@names{%
  \ifx\nuaa@font@family@libertinus\@empty
    \IfFontExistsTF{LibertinusSerif-Regular.otf}{%
      \gdef\nuaa@font@family@libertinus@serif{LibertinusSerif}%
      \gdef\nuaa@font@family@libertinus@sans{LibertinusSans}%
      \gdef\nuaa@font@name@libertinus@math{LibertinusMath-Regular}%
      \gdef\nuaa@font@style@libertinus@rm{Regular}%
      \gdef\nuaa@font@style@libertinus@bf{Bold}%
      \gdef\nuaa@font@style@libertinus@it{Italic}%
      \gdef\nuaa@font@style@libertinus@bfit{BoldItalic}%
    }{%
      \gdef\nuaa@font@family@libertinus@serif{libertinusserif}%
      \gdef\nuaa@font@family@libertinus@sans{libertinussans}%
      \gdef\nuaa@font@name@libertinus@math{libertinusmath-regular}%
      \gdef\nuaa@font@style@libertinus@rm{regular}%
      \gdef\nuaa@font@style@libertinus@bf{bold}%
      \gdef\nuaa@font@style@libertinus@it{italic}%
      \gdef\nuaa@font@style@libertinus@bfit{bolditalic}%
    }%
  \fi
}

% 《撰写手册》要求西文字体使用 Times New Roman 和 Arial，
% 但是在 Linux 下没有这两个字体，所以使用它们的克隆版 TeX Gyre Termes 和
% TeX Gyre Heros。
\ifnuaa@font@auto
  \ifnuaa@system@unix
    \nuaasetup{font=xits}
  \else
    \nuaasetup{font=times}
  \fi
\fi
\newcommand\nuaa@load@font@times{%
  \setmainfont{Times New Roman}%
  \setsansfont{Arial}%
  \ifnuaa@system@mac
    \setmonofont{Menlo}[Scale = MatchLowercase]%
  \else
    \setmonofont{Courier New}[Scale = MatchLowercase]%
  \fi
}
\newcommand\nuaa@load@font@termes{%
  \setmainfont{texgyretermes}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-italic,
    BoldItalicFont = *-bolditalic,
  ]%
  \nuaa@load@texgyre@sans@mono
}
\newcommand\nuaa@load@texgyre@sans@mono{%
  \setsansfont{texgyreheros}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-italic,
    BoldItalicFont = *-bolditalic,
    Scale          = MatchLowercase,
  ]%
  \setmonofont{texgyrecursor}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-italic,
    BoldItalicFont = *-bolditalic,
    Scale          = MatchLowercase,
  ]%
}
\newcommand\nuaa@load@font@xits{%
  \nuaa@set@xits@names
  \setmainfont{\nuaa@font@family@xits}[
    Extension      = .otf,
    UprightFont    = *-\nuaa@font@style@xits@rm,
    BoldFont       = *-\nuaa@font@style@xits@bf,
    ItalicFont     = *-\nuaa@font@style@xits@it,
    BoldItalicFont = *-\nuaa@font@style@xits@bfit,
  ]%
  \nuaa@load@texgyre@sans@mono
}
\newcommand\nuaa@load@font@libertinus{%
  \nuaa@set@libertinus@names
  \setmainfont{\nuaa@font@family@libertinus@serif}[
    Extension      = .otf,
    UprightFont    = *-\nuaa@font@style@libertinus@rm,
    BoldFont       = *-\nuaa@font@style@libertinus@bf,
    ItalicFont     = *-\nuaa@font@style@libertinus@it,
    BoldItalicFont = *-\nuaa@font@style@libertinus@bfit,
  ]%
  \setsansfont{\nuaa@font@family@libertinus@sans}[
    Extension      = .otf,
    UprightFont    = *-\nuaa@font@style@libertinus@rm,
    BoldFont       = *-\nuaa@font@style@libertinus@bf,
    ItalicFont     = *-\nuaa@font@style@libertinus@it,
  ]%
  \setmonofont{lmmonolt10}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-oblique,
    BoldItalicFont = *-boldoblique,
  ]%
}
\newcommand\nuaa@load@font@lm{%
  \setmainfont{lmroman10}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-italic,
    BoldItalicFont = *-bolditalic,
  ]%
  \setsansfont{lmsans10}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-oblique,
    BoldItalicFont = *-boldoblique,
  ]%
  \setmonofont{lmmonolt10}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-oblique,
    BoldItalicFont = *-boldoblique,
  ]%
}
\newcommand\nuaa@load@font{%
  \@nameuse{nuaa@load@font@\nuaa@font}%
}
\nuaa@load@font
\nuaa@option@hook{font}{\nuaa@load@font}

% 中文字体
\ifnuaa@cjk@font@auto
  \ifnuaa@system@mac
    \nuaasetup{cjk-font = mac}
  \else
    \ifnuaa@system@windows
      \nuaasetup{cjk-font = windows}
    \else
      \IfFontExistsTF{Noto Serif CJK SC}{
        \nuaasetup{cjk-font = noto}
      }{
        \nuaasetup{cjk-font = fandol}
      }
    \fi
  \fi
\fi
\newcommand\nuaa@load@cjk@font@windows{%
  \xeCJKsetup{EmboldenFactor=2}
  \setCJKmainfont{SimSun}[
    AutoFakeBold = true,
    ItalicFont   = KaiTi,
  ]%
  \setCJKsansfont{SimHei}[AutoFakeBold]%
  \setCJKmonofont{FangSong}%
  \setCJKfamilyfont{zhsong}{SimSun}[AutoFakeBold]%
  \setCJKfamilyfont{zhhei}{SimHei}[AutoFakeBold]%
  \setCJKfamilyfont{zhkai}{KaiTi}%
  \setCJKfamilyfont{zhfs}{FangSong}%
}
\newcommand\nuaa@load@cjk@font@mac{%
  \setCJKmainfont{Songti SC}[
    UprightFont    = * Light,
    BoldFont       = * Bold,
    ItalicFont     = Kaiti SC,
    BoldItalicFont = Kaiti SC Bold,
  ]%
  \setCJKsansfont{Heiti SC}[BoldFont=* Medium]%
  \setCJKmonofont{STFangsong}
  \setCJKfamilyfont{zhsong}{Songti SC}[
    UprightFont = * Light,
      BoldFont  = * Bold,
  ]%
  \setCJKfamilyfont{zhhei}{Heiti SC}[
    UprightFont = * Light,
    BoldFont    = * Medium,
  ]%
  \setCJKfamilyfont{zhfs}{STFangsong}%
  \setCJKfamilyfont{zhkai}{Kaiti SC}[BoldFont = * Bold]%
  \setCJKfamilyfont{zhli}{Baoli SC}%
  \setCJKfamilyfont{zhyuan}{Yuanyi SC}[
    UprightFont = * Light,
    BoldFont    = * Bold,
  ]%
  \xeCJKsetwidth{‘’“”}{1em}%
}

% 注意 Noto CJK 的 regular 字重名字不带“Regular”。
\newcommand\nuaa@load@cjk@font@noto{%
  \setCJKmainfont{Noto Serif CJK SC}[
    UprightFont    = * Light,
    BoldFont       = * Bold,
    ItalicFont     = FandolKai-Regular,
    ItalicFeatures = {Extension = .otf},
  ]%
  \setCJKsansfont{Noto Sans CJK SC}[
    BoldFont    = * Medium,
  ]%
  \setCJKmonofont{Noto Sans Mono CJK SC}%
  \setCJKfamilyfont{zhsong}{Noto Serif CJK SC}[
    UprightFont = * Light,
    UprightFont = * Bold,
  ]%
  \setCJKfamilyfont{zhhei}{Noto Sans CJK SC}[
    BoldFont    = * Medium,
  ]%
  \setCJKfamilyfont{zhfs}{FandolFang}[
    Extension   = .otf,
    UprightFont = *-Regular,
  ]%
  \setCJKfamilyfont{zhkai}{FandolKai}[
    Extension   = .otf,
    UprightFont = *-Regular,
  ]%
}
\newcommand\nuaa@load@cjk@font@fandol{%
  \setCJKmainfont{FandolSong}[
    Extension   = .otf,
    UprightFont = *-Regular,
    BoldFont    = *-Bold,
    ItalicFont  = FandolKai-Regular,
  ]%
  \setCJKsansfont{FandolHei}[
    Extension   = .otf,
    UprightFont = *-Regular,
    BoldFont    = *-Bold,
  ]%
  \setCJKmonofont{FandolFang}[
    Extension   = .otf,
    UprightFont = *-Regular,
  ]%
  \setCJKfamilyfont{zhsong}{FandolSong}[
    Extension   = .otf,
    UprightFont = *-Regular,
    BoldFont    = *-Bold,
  ]%
  \setCJKfamilyfont{zhhei}{FandolHei}[
    Extension   = .otf,
    UprightFont = *-Regular,
    BoldFont    = *-Bold,
  ]%
  \setCJKfamilyfont{zhfs}{FandolFang}[
    Extension   = .otf,
    UprightFont = *-Regular,
  ]%
  \setCJKfamilyfont{zhkai}{FandolKai}[
    Extension   = .otf,
    UprightFont = *-Regular,
  ]%
}
\ifnuaa@cjk@font@none\else
  \providecommand\songti{\CJKfamily{zhsong}}
  \providecommand\heiti{\CJKfamily{zhhei}}
  \providecommand\fangsong{\CJKfamily{zhfs}}
  \providecommand\kaishu{\CJKfamily{zhkai}}
\fi
\newcommand\nuaa@load@cjk@font{%
  \@nameuse{nuaa@load@cjk@font@\nuaa@cjk@font}%
}
\nuaa@load@cjk@font
\nuaa@option@hook{cjk-font}{\nuaa@load@cjk@font}

% 使用 \pkg{unicode-math} 配置数学字体。
\unimathsetup{
  math-style = ISO,
  bold-style = ISO,
  nabla      = upright,
  partial    = upright,
}
\newcommand\nuaa@load@math@font@xits{%
  \nuaa@set@xits@names
  \setmathfont{\nuaa@font@name@xits@math@rm}[
    Extension    = .otf,
    BoldFont     = \nuaa@font@name@xits@math@bf,
    StylisticSet = 8,
  ]%
  \setmathfont{\nuaa@font@name@xits@math@rm}[
    Extension    = .otf,
    StylisticSet = 1,
    range        = {cal,bfcal},
  ]%
}
\newcommand\nuaa@load@math@font@stix{%
  \setmathfont{STIX2Math}[
    Extension    = .otf,
    StylisticSet = 8,
  ]%
  \setmathfont{STIX2Math}[
    Extension    = .otf,
    StylisticSet = 1,
    range        = {cal,bfcal},
  ]%
}
\newcommand\nuaa@load@math@font@libertinus{%
  \nuaa@set@libertinus@names
  \setmathfont{\nuaa@font@name@libertinus@math .otf}%
}
\newcommand\nuaa@load@math@font@lm{%
  \setmathfont{latinmodern-math.otf}%
}
\newcommand\nuaa@load@math@font{%
  \csname nuaa@load@math@font@\nuaa@math@font\endcsname
}
\nuaa@load@math@font
\nuaa@option@hook{math-font}{\nuaa@load@math@font}

% 研究生的五级节标题和脚注需要使用带圈数字，
% 但 Times New Roman 没有这些符号的字形，而华文宋体和中易宋体提供了这些字形，
% 配置在 \cs{nuaa@circlefont}。
\ifnuaa@font@times
  \ifnuaa@cjk@font@mac
    \newfontfamily\nuaa@circlefont{Songti SC Light}
  \else
    \ifnuaa@cjk@font@windows
      \newfontfamily\nuaa@circlefont{SimSun}
    \fi
  \fi
\else
  \nuaa@set@xits@names
  \newfontfamily\nuaa@circlefont{%
    \nuaa@font@family@xits-\nuaa@font@style@xits@rm.otf%
  }
\fi

% 目前最广泛使用的印刷的长度单位点（磅）通常指 PostScript point
% \footnote{\url{https://en.wikipedia.org/wiki/Point_(typography)}}，
% 在 \LaTeX{} 中是 bp，比默认的 pt 略大。
% 这里保存起来可以节约编译时间。
\newdimen\bp@
\bp@=1bp

% 下面设置字号。正文字号12bp，研究生行距20bp，本科生行距22bp；
% 其他命令的行距按照相同的的比例设置，如表~\ref{tab:fontsize}。
% \begin{table}[htb]
%   \centering
%   \caption{标准字体命令与字号、行距的对应}
%   \label{tab:fontsize}
%   \begin{tabular}{lllll}
%     \toprule
%     字体命令          & 字号 & bp   & 研究生行距 & 本科生行距 \\
%     \midrule
%     \cs{tiny}         & 小六 & 6.5  & 10.83      & 11.92      \\
%     \cs{scriptsize}   & 六号 & 7.5  & 12.5       & 13.75      \\
%     \cs{footnotesize} & 小五 & 9    & 15         & 16.5       \\
%     \cs{small}        & 五号 & 10.5 & 17.5       & 19.25      \\
%     \cs{normalsize}   & 小四 & 12   & 20         & 22         \\
%     \cs{large}        & 小三 & 15   & 25         & 27.5       \\
%     \cs{Large}        & 小二 & 18   & 30         & 33         \\
%     \cs{LARGE}        & 二号 & 22   & 36.67      & 40.33      \\
%     \cs{huge}         & 小一 & 24   & 40         & 44         \\
%     \cs{Huge}         & 一号 & 26   & 43.33      & 47.67      \\
%     \bottomrule
%   \end{tabular}
% \end{table}
\ifnuaa@degree@graduate
  \renewcommand\normalsize{%
    \@setfontsize\normalsize{12\bp@}{20\bp@}%
    \abovedisplayskip 12\bp@ \@plus3\bp@ \@minus7\bp@
    \abovedisplayshortskip \z@ \@plus3\bp@
    \belowdisplayshortskip 6.5\bp@ \@plus3.5\bp@ \@minus3\bp@
    \belowdisplayskip \abovedisplayskip
    \let\@listi\@listI}
  \normalsize
  %
  % 注意第~\ref{sec:list} 节去掉了列表的间距，所以不再修改 \cs{@listi}。
  \renewcommand\small{%
    \@setfontsize\small{10.5\bp@}{17.5\bp@}%
    \abovedisplayskip 10.5\bp@ \@plus3\bp@ \@minus6\bp@
    \abovedisplayshortskip \z@ \@plus3\bp@
    \belowdisplayshortskip 6.5\bp@ \@plus3.5\bp@ \@minus3\bp@
    \belowdisplayskip \abovedisplayskip
  }
  \renewcommand\footnotesize{%
    \@setfontsize\footnotesize{9\bp@}{15\bp@}%
    \abovedisplayskip 9\bp@ \@plus2\bp@ \@minus5\bp@
    \abovedisplayshortskip \z@ \@plus3\bp@
    \belowdisplayshortskip 6\bp@ \@plus3\bp@ \@minus3\bp@
    \belowdisplayskip \abovedisplayskip
  }
  \renewcommand\scriptsize{\@setfontsize\scriptsize{7.5\bp@}{12.5\bp@}}
  \renewcommand\tiny{\@setfontsize\tiny{6.5\bp@}{10.83\bp@}}
  \renewcommand\large{\@setfontsize\large{15\bp@}{25\bp@}}
  \renewcommand\Large{\@setfontsize\Large{18\bp@}{30\bp@}}
  \renewcommand\LARGE{\@setfontsize\LARGE{22\bp@}{36.67\bp@}}
  \renewcommand\huge{\@setfontsize\huge{24\bp@}{40\bp@}}
  \renewcommand\Huge{\@setfontsize\Huge{26\bp@}{43.33\bp@}}
\else
  \renewcommand\normalsize{%
    \@setfontsize\normalsize{12\bp@}{22\bp@}%
    \abovedisplayskip 12\bp@ \@plus3\bp@ \@minus7\bp@
    \abovedisplayshortskip \z@ \@plus3\bp@
    \belowdisplayshortskip 6.5\bp@ \@plus3.5\bp@ \@minus3\bp@
    \belowdisplayskip \abovedisplayskip
    \let\@listi\@listI}
  \normalsize
  \renewcommand\small{%
    \@setfontsize\small{10.5\bp@}{19.25\bp@}%
    \abovedisplayskip 10.5\bp@ \@plus3\bp@ \@minus6\bp@
    \abovedisplayshortskip \z@ \@plus3\bp@
    \belowdisplayshortskip 6.5\bp@ \@plus3.5\bp@ \@minus3\bp@
    \belowdisplayskip \abovedisplayskip
  }
  \renewcommand\footnotesize{%
    \@setfontsize\footnotesize{9\bp@}{16.5\bp@}%
    \abovedisplayskip 9\bp@ \@plus2\bp@ \@minus5\bp@
    \abovedisplayshortskip \z@ \@plus3\bp@
    \belowdisplayshortskip 6\bp@ \@plus3\bp@ \@minus3\bp@
    \belowdisplayskip \abovedisplayskip
  }
  \renewcommand\scriptsize{\@setfontsize\scriptsize{7.5\bp@}{13.75\bp@}}
  \renewcommand\tiny{\@setfontsize\tiny{6.5\bp@}{11.92\bp@}}
  \renewcommand\large{\@setfontsize\large{15\bp@}{27.5\bp@}}
  \renewcommand\Large{\@setfontsize\Large{18\bp@}{33\bp@}}
  \renewcommand\LARGE{\@setfontsize\LARGE{22\bp@}{40.33\bp@}}
  \renewcommand\huge{\@setfontsize\huge{24\bp@}{44\bp@}}
  \renewcommand\Huge{\@setfontsize\Huge{26\bp@}{47.67\bp@}}
\fi

% 设置行距的倍数为 1。
\linespread{1}\selectfont


% \subsection{处理语言}

% 由于 Unicode 的一些标点符号是中西文混用的：
% \unicodechar{00B7}、
% \unicodechar{2013}、
% \unicodechar{2014}、
% \unicodechar{2018}、
% \unicodechar{2019}、
% \unicodechar{201C}、
% \unicodechar{201D}、
% \unicodechar{2025}、
% \unicodechar{2026}、
% \unicodechar{2E3A}，
% 所以要根据语言设置正确的字体。
% \footnote{\url{https://github.com/CTeX-org/ctex-kit/issues/389}}
% 所以要根据语言设置正确的字体。
\newcommand\nuaa@setchinese{%
  \xeCJKResetPunctClass
}
\newcommand\nuaa@setenglish{%
  \xeCJKDeclareCharClass{HalfLeft}{"2018, "201C}%
  \xeCJKDeclareCharClass{HalfRight}{%
    "00B7, "2019, "201D, "2013, "2014, "2025, "2026, "2E3A%
  }%
}
\newcommand\nuaa@setdefaultlanguage{%
  \ifnuaa@language@chinese
    \nuaa@setchinese
  \else
    \nuaa@setenglish
  \fi
}

% 这里设置了中英文的各种名字。

% 由于《撰写手册》中的“speciality”一词使用的是英式拼法，
% 所以“acknowledgements”也保持一致。
\ifnuaa@language@chinese
  \renewcommand\listfigurename{插图清单}
  \renewcommand\listtablename{表格清单}
  \newcommand\nuaa@acknowledgements@name{致谢}
  \newcommand\nuaa@publication@name{在读期间发表的学术论文与取得的研究成果}
  \newcommand\nuaa@notation@name{符号说明}
\else
  \renewcommand\figurename{Fig.}
  \newcommand\nuaa@acknowledgements@name{Acknowledgements}
  \newcommand\nuaa@publication@name{Publications}
  \newcommand\nuaa@notation@name{Notation}
\fi


% \subsection{纸张和页面}
% 使用 \pkg{geometry} 宏包设置纸张和页面。

% 纸张：A4；

% 页面设置：上、下 2.54 cm，左、右 3.17 cm，页眉 1.5 cm，页脚 1.75 cm。

% 注意这里指的是页眉顶部到纸张顶部的距离为 1.5 cm，
% 所以应该是 2.54cm - 0.8cm - 0.24cm = 1.5cm

\geometry{
  paper      = a4paper,
  vmargin    = 2.54cm,
  hmargin    = 3.17cm,
  headheight = 0.75cm,
  headsep    = 0.29cm,
  footskip   = 0.79cm,
}

% 使用 \pkg{fancy} 需要先调用 |\pagestyle{fancy}| 再修改 \cs{chaptermark} 和
% \cs{sectionmark}。
\pagestyle{fancy}
\let\sectionmark\@gobble
\renewcommand\headrulewidth{0.4\p@}

% 使用 \pkg{ctex} 的 \cs{ctex\_patch\_cmd:Nnn} 命令。
\newcommand\nuaa@patchcmd{\csname ctex_patch_cmd:Nnn\endcsname}

% 页眉与该部分的章标题相同，宋体 10.5 磅（五号）居中。
% 页码：宋体 10.5 磅、页面下脚居中。
\ifnuaa@degree@graduate
  \newcommand\nuaa@hf@font{\fontsize{10.5\bp@}{12\bp@}\selectfont}
  \newcommand\nuaa@header{\leftmark}
  \nuaa@patchcmd\chaptermark{\MakeUppercase}{}
  \nuaa@patchcmd\chaptermark{#1}{\nuaa@spacetitle{#1}}
  %
  % 本科生要求除封面、扉页外，每面上部加页眉，
  % 用小 5 号字（9 bp）标注“南京航空航天大学本科毕业论文”，居中；
  % 从目录页开始在每面底部居中用小五宋体（9 bp）连续编页码。
\else
  \newcommand\nuaa@hf@font{\fontsize{9\bp@}{12\bp@}\selectfont}
  \newcommand\nuaa@header{南京航空航天大学本科毕业论文}
  \let\chaptermark\@gobble
\fi

% 重定义默认的 |plain| page style，会显示页眉和页脚。
\fancypagestyle{plain}{%
  \fancyhf{}%
  \fancyhead[C]{\nuaa@hf@font\nuaa@header}%
  \fancyfoot[C]{\nuaa@hf@font\thepage}%
}
\pagestyle{plain}

% |headings| 只有页眉，没有页脚，用于研究生的符号说明和本科生的 front matter。
\fancypagestyle{headings}{\fancyfoot{}}

% 每章第一页默认会设置特殊的 page style，我们希望它不改变页眉页脚，
% 所以定义一个 |none|。
\def\ps@none{}
\ctexset{chapter/pagestyle=none}

% 空白页不加页眉和页码。
\def\cleardoublepage{\clearpage\if@twoside \ifodd\c@page\else
  \hbox{}\thispagestyle{empty}\newpage\if@twocolumn\hbox{}\newpage\fi\fi\fi}
  %
  % 研究生要求从“中文摘要”开始页码用大写罗马数字，
  % 而本科生的 frontmatter（只有致谢）不编页码，从目录开始页码用阿拉伯数字。
\renewcommand\frontmatter{%
  \cleardoublepage
  \@mainmatterfalse
  \pagenumbering{Roman}%
  \ifnuaa@degree@graduate
    \pagestyle{plain}%
  \else
    \pagestyle{headings}%
  \fi
}

% 研究生要求“第 1 章”要另页起，但是本科生要求另面起。
\renewcommand\mainmatter{%
  \ifnuaa@degree@graduate
    \cleardoublepage
    \pagenumbering{arabic}%
  \else
    \clearpage
  \fi
  \pagestyle{plain}%
  \@mainmattertrue}
  %
  %
  % \subsection{封面}
  %
  %
  % 定义用户接口：
\nuaa@define@key{
  title = {
    default = {论文题目},
  },
  title* = {
    default = {Title},
    name    = title@en,
  },
  author = {
    default = {作者姓名},
  },
  author* = {
    default = {Author Name},
    name    = author@en,
  },
  speciality = {
    default = {专业},
  },
  speciality* = {
    default = {Speciality},
    name    = speciality@en,
  },
  supervisor = {
    default = {导师姓名},
  },
  supervisor* = {
    default = {Supervisor Name},
    name    = supervisor@en,
  },
  date = {
    default = {\the\year-\two@digits{\month}-\two@digits{\day}},
  },
  professional-type = {
    name = professional@type,
  },
  professional-type* = {
    name = professional@type@en,
  },
  secret-level = {
    name    = secret@level,
  },
  secret-level* = {
    name    = secret@level@en,
  },
  secret-year = {
    name    = secret@year,
  },
  keywords,
  keywords* = {
    name    = keywords@en,
  },
}

% 导师一栏可能有多个姓名，所以用 \opt{supervisor} 进行收集，
% 然后使用本命令来输出要求的格式，
% 类似于 \LaTeX3 的 \cs{clist\_use:Nn}。
\newcommand\nuaa@clist@count[1]{%
  \csname clist_count:N\endcsname{#1}%
}
\newcommand\nuaa@clist@use[2]{%
  \csname clist_use:Nn\endcsname{#1}{#2}%
}
\newcommand\nuaa@supervisor@names{%
  \nuaa@clist@use{\nuaa@supervisor}{\quad}
}
\newcounter{nuaa@count}
\newcommand\nuaa@supervisor@en@line{%
  \setcounter{nuaa@count}{\nuaa@clist@count{\nuaa@supervisor@en}}%
  \ifnum\c@nuaa@count>1\relax
    Supervisors:%
  \else
    Supervisor:%
  \fi
  \space\nuaa@clist@use{\nuaa@supervisor@en}{, }%
}

% 输出日期的给定格式：\cs{nuaa@format@date}\marg{format}\marg{date}，
% 其中格式 \meta{format} 接受三个参数分别对应年、月、日，
% \meta{date} 是 ISO 格式的日期（yyyy-mm-dd）。
\newcommand\nuaa@format@date[2]{%
  \edef\nuaa@@date{#2}%
  \def\nuaa@@process@date##1-##2-##3\@nil{%
    #1{##1}{##2}{##3}%
  }%
  \expandafter\nuaa@@process@date\nuaa@@date\@nil
}
\newcommand\nuaa@date@format@zh[3]{\zhdigits{#1}年\zhnumber{#2}月\zhnumber{#3}日}
\newcommand\nuaa@date@month[1]{%
  \ifcase\number#1\or
    January\or February\or March\or April\or May\or June\or
    July\or August\or September\or October\or November\or December%
  \fi
}
\newcommand\nuaa@date@format@en[3]{\nuaa@date@month{#2} \number#3, #1}
\newcommand\nuaa@date@zh{\nuaa@format@date{\nuaa@date@format@zh}{\nuaa@date}}
\newcommand\nuaa@date@en{\nuaa@format@date{\nuaa@date@format@en}{\nuaa@date}}

% 版本 v3.2 开始使用 \cs{nuaasetup} 设置接口，
% 兼容旧版本的命令式设置。
% Reserved for compatibility until 2020-07-01.
\def\nuaa@define@term#1#2{%
  \expandafter\gdef\csname #1\endcsname##1{%
    \nuaasetup{#2 = {##1}}%
  }%
}
\nuaa@define@term{title}{title}
\nuaa@define@term{entitle}{title*}
\nuaa@define@term{author}{author}
\nuaa@define@term{enauthor}{author*}
\nuaa@define@term{major}{speciality}
\nuaa@define@term{enmajor}{speciality*}
\nuaa@define@term{supervisor}{supervisor}
\nuaa@define@term{ensupervisor}{supervisor*}
\gdef\cosupervisor#1{%
  \g@addto@macro\nuaa@supervisor{, #1}%
}
\gdef\encosupervisor#1{%
  \g@addto@macro\nuaa@supervisor@en{, #1}%
}
\gdef\date#1{\renewcommand\nuaa@date@zh{#1}}
\gdef\endate#1{\renewcommand\nuaa@date@en{#1}}
\nuaa@define@term{professionaltype}{professional-type}
\nuaa@define@term{enprofessionaltype}{professional-type*}
\nuaa@define@term{secretlevel}{secret-level}
\nuaa@define@term{ensecretlevel}{secret-level*}
\nuaa@define@term{secretyear}{secret-year}
\gdef\keywords#1{\renewcommand\nuaa@keywords@text{#1}}
\gdef\enkeywords#1{\renewcommand\nuaa@keywords@en@text{#1}}

% 定义一些常量。
\ifnuaa@degree@doctor
  \newcommand\nuaa@thesis@name{博士学位论文}
  \newcommand\nuaa@thesis@name@en{A dissertation for doctor's degree}
\else
  \ifnuaa@degree@master
    \newcommand\nuaa@thesis@name{学士学位论文}
    \newcommand\nuaa@thesis@name@en{A dissertation for bachelor's degree}
  \else
    \newcommand\nuaa@thesis@name{学士学位论文}
    \newcommand\nuaa@thesis@name@en{A dissertation for bachelor's degree}
  \fi
\fi
\ifnuaa@degree@type@academic
  \newcommand\nuaa@speciality@name{学科专业}
\else
  \ifnuaa@degree@doctor
    \renewcommand\nuaa@thesis@name{专业博士学位论文}
  \else
    \renewcommand\nuaa@thesis@name{专业硕士学位论文}
  \fi
  \ifnuaa@cjk@font@mac
    \providecommand\lishu{\CJKfamily{zhli}}
  \else
    \ifnuaa@cjk@font@windows
      \setCJKfamilyfont{zhli}{LiSu}
      \providecommand\lishu{\CJKfamily{zhli}}
    \else
      \nuaa@warning{LiShu font is required}
      \providecommand\lishu{\sffamily}
    \fi
  \fi
  \newcommand\nuaa@speciality@name{专业领域}
\fi

% 定义校徽颜色
\definecolor{nuaablue}{cmyk}{1,0.8,0,0}

% 添加 PDF 书签，在 \pkg{hyperref} 载入后才有效。
\newcommand\nuaa@pdfbookmark{\@gobble}

% 重定义 \env{titlepage} 环境，不修改页码。
\renewenvironment{titlepage}{%
  \cleardoublepage
  \if@twocolumn
    \@restonecoltrue\onecolumn
  \else
    \@restonecolfalse\newpage
  \fi
  \thispagestyle{empty}%
}{%
  \if@restonecol\twocolumn \else \newpage \fi
}

% 中文封面：
% 密级仿宋 14 磅；
% 论文类型黑体 56 磅；
% 论文题目黑体 26 磅加粗居中，单倍行距；
% 作者姓名宋体 16 磅，单倍行距；
% 注意这里的“单倍行距”的地方开启了“对齐到网格”，所以实际行距有所偏差，
% 所以只能使用直尺测量。
\newcommand\nuaa@makezhtitle{%
  \nuaa@setchinese
  \begin{titlepage}%
    \nuaa@pdfbookmark{封面}%
    \centering
    \parbox[t][0.6cm][t]{\textwidth}{%
      \raggedleft\fangsong\fontsize{14\bp@}{14\bp@}\selectfont
      \null\nuaa@secret@level\par}\par
    \vskip 0.5cm%
    \includegraphics[height=2.6cm]{figures/nuaa-name.pdf}\par
    \vskip 0.6cm%
    {\sffamily\fontsize{56\bp@}{56\bp@}\selectfont
      \nuaa@thesis@name\par}%
    \ifnuaa@degree@type@academic
      \vskip 2.0cm%
    \else
      \vskip 0.8cm%
      {\lishu\fontsize{26\bp@}{26\bp@}\selectfont
        （\nuaa@professional@type）\par}%
      \vskip 1.0cm%
    \fi
    \ifnuaa@badge@color@blue
      \textcolor{nuaablue}{%
        \includegraphics[height=4.1cm]{figures/nuaa-badge.pdf}}%
    \else
      \includegraphics[height=4.1cm]{figures/nuaa-badge.pdf}%
    \fi\par
    \vskip 0.9cm%
    \parbox[t][3.5cm][c]{\textwidth}{%
      \centering\sffamily\bfseries\fontsize{26\bp@}{50\bp@}\selectfont
      \nuaa@title\par}\par
    \vskip 0.6cm%
    {\fontsize{16\bp@}{31\bp@}\selectfont
      \begin{tabular}{@{}l@{\hspace{\ccwd}}l@{}}%
        \textsf{作者姓名：} & \nuaa@author \\
        \textsf{\nuaa@speciality@name：} & \nuaa@speciality \\
        \textsf{导师姓名：} & \nuaa@supervisor@names \\
        \textsf{完成时间：} & \nuaa@date@zh
      \end{tabular}\par}%
  \end{titlepage}%
  \nuaa@setdefaultlanguage
}

% 英文封面
\newcommand\nuaa@makeentitle{%
  \nuaa@setenglish
  \begin{titlepage}%
    \nuaa@pdfbookmark{Title page}%
    \centering
    \parbox[t][0.4cm][t]{\textwidth}{%
      \raggedleft\fontsize{14\bp@}{14\bp@}\selectfont
      \null\nuaa@secret@level@en\par}\par
    \vskip 0.5cm%
    {\sffamily\fontsize{20\bp@}{30\bp@}\selectfont
      Nanjing University of Aeronautics and Astronautics\par}%
    {\sffamily\fontsize{26\bp@}{30\bp@}\selectfont
      \nuaa@thesis@name@en\par}%
    \ifnuaa@degree@type@academic\else
      {\fontsize{16\bp@}{32\bp@}\selectfont
        (\nuaa@professional@type@en)\par}%
    \fi
    \vskip 2.5cm%
    \ifnuaa@badge@color@blue
      \textcolor{nuaablue}{%
        \includegraphics[height=4.5cm]{figures/nuaa-badge.pdf}}%
    \else
      \includegraphics[height=4.5cm]{figures/nuaa-badge.pdf}%
    \fi\par
    \vskip 0.5cm%
    \parbox[t][4.5cm][c]{\textwidth}{%
      \centering\sffamily\bfseries\fontsize{26\bp@}{30\bp@}\selectfont
      \nuaa@title@en\par}\par
    \vskip 1.6cm%
    {\fontsize{16\bp@}{30\bp@}\selectfont
      \begin{tabular}{@{}l@{}}%
        Author:        \nuaa@author@en \\
        Speciality:    \nuaa@speciality@en \\
        \nuaa@supervisor@en@line \\
        Finished time: \nuaa@date@en
      \end{tabular}\par}%
  \end{titlepage}%
  \nuaa@setdefaultlanguage
}

% 重新定义 \cs{maketitle}，调用 \cs{nuaa@makezhtitle}, \cs{nuaa@makeentitle}
% 分别生成中、英文封面。
\renewcommand\maketitle{%
  \newgeometry{margin=2.54cm}%
  \pagenumbering{Alph}%
  \pagestyle{empty}%
  \nuaa@makezhtitle
  \nuaa@makeentitle
  \restoregeometry
  \pagestyle{plain}%
}


% \subsection{原创性声明}

% 定义原创性声明
\newcommand\nuaa@originality{%
  本人声明所呈交的学位论文，是本人在导师指导下进行研究工作所取得的成果。%
  除已特别加以标注和致谢的地方外，论文中不包含任何他人已经发表或撰写过的%
  研究成果。}
\newcommand\nuaa@authorization{%
  作为申请学位的条件之一，学位论文著作权拥有者授权南京航空航天大学大学拥有%
  学位论文的部分使用权，%
  即：学校有权按有关规定向国家有关部门或机构送交论文的复印件和电子版，%
  允许论文被查阅和借阅，可以将学位论文编入《中国学位论文全文数据库》等%
  有关数据库进行检索，可以采用影印、缩印或扫描等复制手段保存、汇编学位论文。%
  本人提交的电子文档的内容和纸质论文的内容相一致。\par
  保密的学位论文在解密后也遵守此规定。}
  %
  % 生成空的下划线
\newcommand\nuaa@underline[2][3.2cm]{\underline{\hb@xt@ #1{\hss#2\hss}}}

\newcommand\nuaa@checkbox{%
  \makebox[\z@][l]{$\square$}%
  \raisebox{-0.2ex}{\hspace{0.1em}$\checkmark$}%
}

\newcommand\copyrightpage{%
  \begin{titlepage}%
    \nuaa@pdfbookmark{原创性和授权使用声明}%
    \null
    \vskip 0.3cm%
    {\centering\sffamily\fontsize{16\bp@}{32\bp@}\selectfont
      南京航空航天大学学位论文原创性声明\par}%
    \vskip 0.7cm%
    \nuaa@originality\par
    \vskip 1.3cm%
    作者签名：\nuaa@underline{}\hspace{2.7cm}%
    签字日期：\nuaa@underline{}\par
    \vskip 1.9cm%
    {\centering\sffamily\fontsize{16\bp@}{32\bp@}\selectfont
      南京航空航天大学学位论文授权使用声明\par}%
    \vskip 0.7cm%
    \nuaa@authorization\par
    \vskip 0.6cm%
    \ifx\nuaa@secret@level\@empty
      \nuaa@checkbox{} 公开\quad
      $\square$ 保密（\nuaa@underline[0.85cm]{}年）\par
    \else
      $\square$ 公开\quad
      \nuaa@checkbox{} 保密（\nuaa@underline[0.8cm]{\nuaa@secret@year}年）\par
    \fi
    \vskip 0.5cm%
    作者签名：\nuaa@underline{}\hspace{2.7cm}%
    导师签名：\nuaa@underline{}\par
    \vskip 0.5cm%
    签字日期：\nuaa@underline{}\hspace{2.7cm}%
    签字日期：\nuaa@underline{}\par
  \end{titlepage}%
}
\ifnuaa@degree@bachelor
  \let\copyrightpage\relax
\fi
% Reserved for compatibility until 2020-07-01.
\let\makestatement\copyrightpage


% \subsection{章节标题}

% 标题最多允许使用五级。
\setcounter{secnumdepth}{5}

% 研究生规定章题为两字时中间空两字，三字时空一字，四字时空半字，四字以上不空。
% 这里用 \LaTeX3 的 \cs{str\_count:N} 判断字数。
% 注意，\pkg{stringstrings} 宏包会导致范数命令 \verb+\|+ 被修改。
\newcount\nuaa@titlelength
\DeclareRobustCommand\nuaa@spacetitle[1]{%
  \nuaa@titlelength=\csname str_count:N\endcsname{#1}%
  \begingroup
    \ifnuaa@degree@graduate
      \ifcase\nuaa@titlelength
      \or\or
        \ziju{2}%
      \or
        \ziju{1}%
      \or
        \ziju{0.5}%
      \fi
    \else
      \if@mainmatter\else
        \ifcase\nuaa@titlelength
        \or\or
          \ziju{1}%
        \or\or
          \ziju{0.5}%
        \fi
      \fi
    \fi
    #1%
  \endgroup
}

% 五级节标题和脚注需要使用带圈的数字，这里使用 \cs{nuaa@circlefont} ：
\newcommand\nuaa@textcircled[1]{%
  \ifnum\value{#1}<21\relax
    {\nuaa@circlefont\symbol{\numexpr\value{#1} + "245F\relax}}%
  \else
    \nuaa@error{Cannot display more than 10 footnotes}%
  \fi
}

% 用 \pkg{ctex} 的接口设置全部章节标题格式。

% 各章标题：黑体 16 磅加粗居中，单倍行距，段前 24 磅，段后 18 磅，
% 章序号与章名间空一字。

% 由于 Word 模板中使用“单倍行距”，还“对齐到网格”，这在 TeX 中不容易实现。
% 所以目前按照默认的行距。

% 注意 \pkg{ctex} v2.4.3 以下版本的bug会导致章节标题前后的距离的实际值偏大。
% 另外 \pkg{ctex} v2.2 前的beforeskip的符号有特殊意义。
\ctexset{
  chapter = {
    format      = \centering\sffamily\bfseries\fontsize{16\bp@}{26.67\bp@}\selectfont,
    nameformat  = {},
    titleformat = \nuaa@spacetitle,
    number      = \thechapter,
    aftername   = \hspace{\ccwd},
    beforeskip  = 24\bp@,
    afterskip   = 18\bp@,
    fixskip     = true,
  },
}

% 一级节标题：黑体 14 磅左顶格，单倍行距，段前 24 磅，段后 6 磅，
% 序号与题名间空一字。
\ctexset{
  section = {
    format     = \sffamily\fontsize{14\bp@}{23.33\bp@}\selectfont,
    aftername  = \hspace{\ccwd},
    beforeskip = 24\bp@,
    afterskip  = 6\bp@,
  },
  %
  % 二级节标题：黑体 13 磅，左缩进两字，单倍行距，段前 12 磅，段后 6 磅，
  % 序号与题名间空一字。
  subsection = {
    format     = \sffamily\fontsize{13\bp@}{21.67\bp@}\selectfont,
    aftername  = \hspace{\ccwd},
    indent     = 2\ccwd,
    beforeskip = 12\bp@,
    afterskip  = 6\bp@,
  },
  %
  % 三级及以下节标题的格式没有具体规定，按照 Word 模板的格式：
  % 使用黑体 12 磅，左缩进两字，行距 20 磅，段前段后 0 磅，序号与题名间空半字宽。
  subsubsection = {
    format     = \sffamily\fontsize{12\bp@}{20\bp@}\selectfont,
    number     = \arabic{subsubsection},
    aftername  = .\hspace{0.5\ccwd},
    indent     = 2\ccwd,
    beforeskip = \z@,
    afterskip  = \z@,
  },
  %
  % 按照 Word 模板的格式，四级节标题：宋体 12 磅，左缩进两字，行距 20 磅，
  % 段前段后 0 磅，序号使用全宽括号，与题名间空半字宽。
  paragraph = {
    format     = \rmfamily\fontsize{12\bp@}{20\bp@}\selectfont,
    number     = （\arabic{paragraph}）,
    aftername  = \hspace{0.5\ccwd},
    indent     = 2\ccwd,
    beforeskip = \z@,
    afterskip  = \z@,
    runin      = false,
  },
  %
  % 按照 Word 模板的格式，五级节标题：宋体 12 磅，左缩进两字，行距 20 磅，
  % 段前段后 0 磅，序号使用全宽括号，与题名间空半字宽。
  subparagraph = {
    format     = \rmfamily\fontsize{12\bp@}{20\bp@}\selectfont,
    number     = \nuaa@textcircled{subparagraph},
    aftername  = \hspace{0.5\ccwd},
    indent     = 2\ccwd,
    beforeskip = \z@,
    afterskip  = \z@,
    runin      = false,
  },
}

% 在研究生格式的基础上再设置本科生的章节标题格式。
\ifnuaa@degree@bachelor
  \setcounter{secnumdepth}{4}
  \ctexset{
  %
  % 论文的致谢、目录、摘要和参考文献等标题用小二号（18 bp）黑体字，居中，
  % 这通过 \cs{if@mainmatter} 区分。
  % 正文中的标题分章、节、段三级；章、节标题居中，段标题居左，
  % 分别用三号（16 bp）黑体、小三（15 bp）黑体、四号（14 bp）黑体。
    chapter = {
      format = {
        \centering\sffamily
        \if@mainmatter
          \fontsize{16\bp@}{29.33\bp@}\selectfont
        \else
          \fontsize{18\bp@}{33\bp@}\selectfont
        \fi
      },
    },
    section = {
      format = \centering\sffamily\fontsize{15\bp@}{27.5\bp@}\selectfont,
    },
    subsection = {
      format    = \sffamily\fontsize{14\bp@}{25.67\bp@}\selectfont,
      indent    = \z@,
    },
    subsubsection = {
      format    = \rmfamily\fontsize{12\bp@}{22\bp@}\selectfont,
      indent    = \ccwd,
    },
    paragraph = {
      format    = \rmfamily\fontsize{12\bp@}{22\bp@}\selectfont,
      aftername = {},
      indent    = \ccwd,
    },
  }
  %
  % 本科生的阿拉伯数字式标题的格式与研究生几乎一致，只有中文数字式需要修改。
  \ifnuaa@section@style@arabic\else
    \ctexset{
      chapter = {
        number = \chinese{chapter},
      },
      section = {
        name   = {第,节},
        number = \chinese{section},
      },
      subsection = {
        number    = \chinese{subsection},
        aftername = {、},
      },
    }
  \fi
\fi

% 默认的 \cs{chapter*} 生成的章标题没有编号、不更改页眉，
% 也不添加进目录或 PDF 书签。
% 然而像摘要、目录、符号说明这样的章节，它们不需要编号、不加入目录，
% 但是需要修改页眉，并且加入 PDF 标签。
% 所以我们新定义 \cs{nuaa@chapter} 用于处理这些章节。%
\NewDocumentCommand\nuaa@chapter{o m}{%
  \if@openright\cleardoublepage\else\clearpage\fi
  \IfValueTF{#1}{%
    \nuaa@pdfbookmark{#1}%
    \chaptermark{#1}%
  }{%
    \nuaa@pdfbookmark{#2}%
    \chaptermark{#2}%
  }%
  \chapter*{#2}}
  %
  %
  % \subsection{摘要}
  %
  % 中文摘要环境。
  % 判断 \cs{nuaa@tocloaded} 是为了防止本科生未调整摘要位置时的目录页码缺失。
\newcommand\nuaa@keywords@text{%
  \nuaa@clist@use{\nuaa@keywords}{；}%
}
\newcommand\nuaa@keywords@en@text{%
  \nuaa@clist@use{\nuaa@keywords@en}{; }%
}
\newenvironment{abstract}{%
  \nuaa@setchinese
  \ifnuaa@degree@graduate
    \nuaa@chapter{摘要}%
  \else
    \chapter{中文内容摘要}%
    \ifnuaa@tocloaded\else
      本科生需要手动将摘要置于目录后。\par
    \fi
  \fi
}{
  \par\null\par\noindent\hangindent=4\ccwd\relax
  \textbf{关键词}：\nuaa@keywords@text\par
  \nuaa@setdefaultlanguage
}

% 英文摘要环境
\newenvironment{enabstract}{%
  \nuaa@setenglish
  \ifnuaa@degree@graduate
    \nuaa@chapter[Abstract]{ABSTRACT}%
  \else
    \chapter[英文内容摘要]{Abstract}%
  \fi
}{
  \par\null\par\noindent\hangindent=5.3em\relax
  \textbf{Key Words}: \nuaa@keywords@en@text\par
  \ifnuaa@degree@graduate
    \cleardoublepage
  \fi
  \nuaa@setdefaultlanguage
}


% \subsection{目录}

% 判断是否已经加载目录，用于提醒本科生更改摘要和致谢的顺序。
\newif\ifnuaa@tocloaded

% 研究生规定目录另面起；
% 本科生规定从目录开始编页码，所以必须另页起。
\renewcommand\tableofcontents{%
  \ifnuaa@degree@bachelor
    \cleardoublepage
    \pagenumbering{arabic}%
    \pagestyle{plain}%
    \nuaa@tocloadedtrue
  \fi
  \nuaa@chapter{\contentsname}%
  \@starttoc{toc}%
}

% 下面用 \pkg{titletoc} 宏包设置目录内容的格式。
% 先定义目录线：
\newcommand\nuaa@leaders{\titlerule*[9\bp@]{\textperiodcentered}}

% 各章目录要求宋体 14 磅，单倍行距，段前 6 磅，段后 0 磅，两端对齐，
% 页码右对齐，章序号与章名间空一字。
% 但是 Word 模板中实际是行距 20 磅。

% 另外 \pkg{ctex} 在章目录的序号后加 |\hspace{.3em}|，所以用 \cs{unskip} 修正。
\ifnuaa@degree@graduate
  \titlecontents{chapter}
    [\z@]{\addvspace{6\bp@}\fontsize{14\bp@}{20\bp@}\selectfont}
    {\contentspush{\thecontentslabel\unskip\hspace{\ccwd}}}{}
    {\fontsize{12\bp@}{20\bp@}\selectfont\nuaa@leaders\contentspage}
    %
    % 一级节标题目录要求宋体 12 磅，单倍行距，左缩进一字，段前 6 磅，段后 0 磅，
    % 两端对齐，页码右对齐，序号与题名间空一字。
    % Word 模板中实际是行距 20 磅，段前 0 磅。
  \titlecontents{section}
    [\ccwd]{\fontsize{12\bp@}{20\bp@}\selectfont}
    {\contentspush{\thecontentslabel\hspace{\ccwd}}}{}
    {\fontsize{12\bp@}{20\bp@}\selectfont\nuaa@leaders\contentspage}
    %
    % 二级节标题目录要求宋体 10.5 磅，单倍行距，左缩进两字，段前 6 磅，段后 0 磅，
    % 两端对齐，页码右对齐，序号与题名间空一字。
    % Word 模板中实际是行距 20 磅，段前 0 磅。
  \titlecontents{subsection}
    [2\ccwd]{\fontsize{10.5\bp@}{20\bp@}\selectfont}
    {\contentspush{\thecontentslabel\hspace{\ccwd}}}{}
    {\fontsize{12\bp@}{20\bp@}\selectfont\nuaa@leaders\contentspage}
    %
    % 本科生的目录使用小四宋体（同正文字体），其他同研究生的格式相近。
\else
  \titlecontents{chapter}
    [\z@]{\normalsize}
    {\contentspush{\thecontentslabel\unskip\hspace{\ccwd}}}{}
    {\nuaa@leaders\contentspage}
  \titlecontents{section}
    [\ccwd]{\normalsize}
    {\contentspush{\thecontentslabel\hspace{\ccwd}}}{}
    {\nuaa@leaders\contentspage}
  \titlecontents{subsection}
    [2\ccwd]{\normalsize}
    {\contentspush{\thecontentslabel
      \ifnuaa@section@style@arabic\hspace{\ccwd}\else 、\fi}}{}
    {\nuaa@leaders\contentspage}
\fi

% 本科生要求目录中正文每章前多空一行，而目录、附录等章则不需要空行，
% 所以不能简单判断 \cs{if@mainmatter}，需要重新定义 \cs{mainmatter} 等命令。
\newif\ifnuaa@addtocspace
\ifnuaa@degree@bachelor
  \nuaa@addtocspacetrue
  \g@addto@macro\frontmatter{\nuaa@addtocspacefalse}%
  \g@addto@macro\mainmatter{\nuaa@addtocspacetrue}%
  \g@addto@macro\backmatter{\nuaa@addtocspacefalse}%
  \g@addto@macro\appendix{\nuaa@addtocspacefalse}%
\fi

% 处理本科生在目录中添加空行。
\renewcommand\chapter{%
  \if@openright\cleardoublepage\else\clearpage\fi
  \thispagestyle{\CTEX@chapter@pagestyle}%
  \global\@topnum\z@
  \@afterindenttrue
  \ifnuaa@degree@bachelor
    \ifnuaa@addtocspace
      \addtocontents{toc}{\protect\addvspace{12\bp@}}%
    \fi
  \fi
  \secdef\@chapter\@schapter
}

% 研究生要求图、表的清单须另页起。
\renewcommand\listoffigures{%
  \ifnuaa@degree@graduate
    \cleardoublepage
  \fi
  \nuaa@chapter{\listfigurename}%
  \@starttoc{lof}%
}
\titlecontents{figure}
  [2.3em]{\normalsize}
  {\contentslabel{2.3em}}{}
  {\nuaa@leaders\contentspage}
  %
\renewcommand\listoftables{%
  \ifnuaa@degree@graduate
    \cleardoublepage
  \fi
  \nuaa@chapter{\listtablename}%
  \@starttoc{lot}%
}
\titlecontents{table}
  [2.3em]{\normalsize}
  {\contentslabel{2.3em}}{}
  {\nuaa@leaders\contentspage}
  %
  %
  % \subsection{符号说明}
  %
  % 研究生规定符号说明另页起，标题字体字号等同论文正文，
  % 《撰写手册》第 9 页 1.10(2) 还规定“符号说明不加页码”。
\newenvironment{notation}{%
  \ifnuaa@degree@graduate
    \cleardoublepage
    \pagestyle{headings}%
  \fi
  \nuaa@chapter{\nuaa@notation@name}%
}{%
  \ifnuaa@degree@graduate
    \clearpage
    \pagestyle{plain}%
  \fi
}%
\newcommand*\notationlabel[1]{#1\hfil}%
\newenvironment{notationlist}[1]{%
  \list{}{%
    \itemsep 3pt%
    \labelwidth #1\relax%
    \labelsep 1em%
    \leftmargin\labelwidth
    \advance\leftmargin\labelsep
    \advance\leftmargin 3em%
    \rightmargin 3em%
    \let\makelabel\notationlabel
  }%
}{%
  \endlist
}


% \subsection{正文}

% \cs{sloppy} 可以减少“overfull boxes”。
\sloppy


\raggedbottom

% 段间距 0 磅。
\setlength{\parskip}{\z@}

% 在 \opt{scheme=plain} 时也首段缩进。
\let\@afterindentfalse\@afterindenttrue
\@afterindenttrue

% URL 的字体设为保持原样。
\urlstyle{same}

% 使用 \pkg{xurl} 宏包的方法，增加 URL 可断行的位置。
\def\UrlBreaks{%
  \do\/%
  \do\a\do\b\do\c\do\d\do\e\do\f\do\g\do\h\do\i\do\j\do\k\do\l%
     \do\m\do\n\do\o\do\p\do\q\do\r\do\s\do\t\do\u\do\v\do\w\do\x\do\y\do\z%
  \do\A\do\B\do\C\do\D\do\E\do\F\do\G\do\H\do\I\do\J\do\K\do\L%
     \do\M\do\N\do\O\do\P\do\Q\do\R\do\S\do\T\do\U\do\V\do\W\do\X\do\Y\do\Z%
  \do0\do1\do2\do3\do4\do5\do6\do7\do8\do9\do=\do/\do.\do:%
  \do\*\do\-\do\~\do\'\do\"\do\-}
\Urlmuskip=0mu plus 0.1mu

% 脚注用带圈的数字：
\renewcommand\thefootnote{\nuaa@textcircled{footnote}}

% LaTeX 默认脚注按章计数，即每章的开始才重置脚注计数器；我们修改为按页计数。
% 简单的|\@addtoreset{footnote}{page}|并不可靠，
% \footnote{\url{https://texfaq.org/FAQ-footnpp.html}}
% 所以我们使用 \pkg{footmisc} 宏包。

% 脚注线长为版心宽度的四分之一：
\renewcommand\footnoterule{%
  \kern-3\p@
  \hrule\@width.25\textwidth
  \kern2.6\p@}
  %
  % 注文缩进两字：
\renewcommand\@makefntext[1]{%
  \parindent 2\ccwd\relax
  \noindent
  \hb@xt@2\ccwd{\hss\@makefnmark}#1}


% \subsection{列表}
% \label{sec:list}

% 调整列表中各项之间过大的间距。
\setlength\partopsep{\z@}
\newcommand\nuaa@nolistsep{%
  \parsep 0\p@ \@plus.2\p@
  \topsep 0\p@ \@plus.2\p@
  \itemsep0\p@ \@plus.2\p@
}
\def\@listi{\leftmargin\leftmargini
            \nuaa@nolistsep}
\let\@listI\@listi
\@listi
\def\@listii {\leftmargin\leftmarginii
              \labelwidth\leftmarginii
              \advance\labelwidth-\labelsep
              \nuaa@nolistsep}
\def\@listiii{\leftmargin\leftmarginiii
              \labelwidth\leftmarginiii
              \advance\labelwidth-\labelsep
              \nuaa@nolistsep}


% \subsection{浮动体}

% \LaTeX{} 对放置浮动体的要求比较强，这里按照 UK TeX FAQ 的建议
% \footnote{\url{https://texfaq.org/FAQ-floats}} 对其适当放宽。
\renewcommand\topfraction{.85}
\renewcommand\bottomfraction{.7}
\renewcommand\textfraction{.15}
\renewcommand\floatpagefraction{.66}
\renewcommand\dbltopfraction{.66}
\renewcommand\dblfloatpagefraction{.66}
\setcounter{topnumber}{9}
\setcounter{bottomnumber}{9}
\setcounter{totalnumber}{20}
\setcounter{dbltopnumber}{9}

% 修改默认的浮动体描述符为 |htb|。
\def\fps@figure{htb}
\def\fps@table{htb}

% 用 \pkg{caption} 宏包设置图、表的格式：

% 图号、图题置于图的下方，宋体 10.5 磅居中，单倍行距，段前 6 磅，段后 12 磅，
% 图号与图题文字之间空一字，图号、图题加粗。
% 图注位于图的下方，左缩进两字，续行悬挂缩进左对齐，两端对齐。

% 表号、表题置于表的上方，宋体 10.5 磅居中，单倍行距，段前 6 磅，段后 6 磅，
% 表号与表题文字之间空一字，表号、表题加粗。
% 表注左缩进两字，续行悬挂缩进左对齐，两端对齐。
\setlength{\floatsep}{6\bp@}
\setlength{\textfloatsep}{6\bp@}
\setlength{\intextsep}{6\bp@}
\DeclareCaptionLabelSeparator{zhspace}{\hspace{\ccwd}}
\captionsetup{
  format         = hang,
  font           = small,
  labelsep       = zhspace,
  skip           = 6\bp@,
  figureposition = bottom,
  tableposition  = top,
}
\ifnuaa@degree@graduate
  \captionsetup{font+=bf}
\fi
\captionsetup[figure]{
  belowskip = 6\bp@,
}

% 新定义了 \cs{note} 来生成图表的附注。
% 如果用 \cs{caption} 生成图表的附注会导致图表的序号有误；
% 如果用 \cs{bicaption} 会导致表注无法置于表后，而且对齐方式不对。
\newcommand\note[1]{%
  \begingroup
  \captionsetup{
    format        = plain,
    font          = small,
    justification = justified,
    margin        = 2\ccwd,
    position      = bottom,
  }%
  \caption*{#1}%
  \endgroup
}


% \subsection{数学符号}

% 根据中文的数学排印习惯进行设置：

% 省略号一律居中，所以 \cs{ldots} 不再居于底部。
\ifnuaa@language@chinese
  \def\mathellipsis{\cdots}
\fi

% 小于等于号、大于等于号要使用倾斜的字形。
\protected\def\le{\leqslant}
\protected\def\ge{\geqslant}
\AtBeginDocument{%
  \renewcommand\leq{\leqslant}%
  \renewcommand\geq{\geqslant}%
}

% 积分号的上下限默认置于上下两侧。
\removenolimits{%
  \int\iint\iiint\iiiint\oint\oiint\oiiint
  \intclockwise\varointclockwise\ointctrclockwise\sumint
  \intbar\intBar\fint\cirfnint\awint\rppolint
  \scpolint\npolint\pointint\sqint\intlarhk\intx
  \intcap\intcup\upint\lowint
}

% 实部、虚部操作符使用罗马体 $\mathrm{Re}$、$\mathrm{Im}$ 而不是 fraktur 体
% $\Re$、$\Im$。
\AtBeginDocument{%
  \renewcommand\Re{\operatorname{Re}}%
  \renewcommand\Im{\operatorname{Im}}%
}

% \cs{nabla} 使用粗正体。
\AtBeginDocument{%
  \renewcommand\nabla{\mbfnabla}%
}

% 兼容旧的粗体命令：\pkg{bm} 的 \cs{bm} 和 \pkg{amsmath} 的 \cs{boldsymbol}。
\DeclareRobustCommand\bm[1]{{\symbf{#1}}}
\DeclareRobustCommand\boldsymbol[1]{{\symbf{#1}}}

% 兼容 \pkg{amssymb} 中的命令。
\newcommand\square{\mdlgwhtsquare}

% 提供一些方便的命令：
\newcommand\upe{\symup{e}}
\newcommand\upi{\symup{i}}
\newcommand\dif{\mathop{}\!\mathrm{d}}


% \subsection{参考文献}

% 定义几种引用文献的标注法。
\newcommand\bibstyle@super{%
  \bibpunct{[}{]}{,}{s}{,}{\textsuperscript{,}}%
  \gdef\NAT@sort{\@ne}%
  \gdef\NAT@cmprs{\@ne}%
}
\newcommand\bibstyle@inline{%
  \bibpunct{[}{]}{,}{n}{,}{,}%
  \gdef\NAT@sort{\@ne}%
  \gdef\NAT@cmprs{\@ne}%
}
\newcommand\bibstyle@authoryear{%
  \bibpunct{(}{)}{;}{a}{,}{,}%
  \gdef\NAT@sort{\z@}%
  \gdef\NAT@cmprs{\z@}%
}

% 避免在 cite-style 接口的地方定义代码，
% 因为在导言区执行 \cs{citestyle} 会妨碍 \pkg{natbib} 的 \cs{bibstyle}
% 自动设置 \cs{citestyle}。
\nuaa@option@hook{cite-style}{%
  \citestyle{\nuaa@cite@style}%
}

% 使用 \cs{bibliographystyle} 命令时自动切换为对应的引用风格。
\@namedef{bibstyle@nuaathesis-numerical}{\bibstyle@super}
\@namedef{bibstyle@nuaathesis-authoryear}{\bibstyle@authoryear}
\@namedef{bibstyle@nuaathesis-bachelor}{\bibstyle@super}

% 如果文献序号作为叙述文字的一部分，需要临时将文献序号与正文平排
\DeclareRobustCommand\inlinecite{\@inlinecite}
\def\@inlinecite#1{\begingroup\let\@cite\NAT@citenum\citep{#1}\endgroup}

% 版本 v3.2 改为按照标准方式调用 \cs{bibliographystyle}
% 版本 v3.1.* 前要求用户不使用 \cs{bibliographystyle} 命令，
% 这与标准文档类不一致。
% 为了兼容版本进行一些修改：
% Reserved for compatibility until 2020-07-01.
\let\bibstyle@numbers\bibstyle@inline
\newif\ifnuaa@bib@style@written
\def\bibliography#1{%
  \ifnuaa@bib@style@written\else
    \ifnuaa@degree@bachelor
      \bibliographystyle{nuaathesis-bachelor}%
    \else
      \bibliographystyle{nuaathesis-numerical}%
    \fi
  \fi
  \if@filesw
    \immediate\write\@auxout{\string\bibdata{\zap@space#1 \@empty}}%
  \fi
  \@input@{\jobname.bbl}}
\def\bibliographystyle#1{%
  \nuaa@bib@style@writtentrue
  \ifx\@begindocumenthook\@undefined\else
    \expandafter\AtBeginDocument
  \fi
    {\if@filesw
       \immediate\write\@auxout{\string\bibstyle{#1}}%
     \fi}}
\ifnuaa@legacy@cite@style
  \ifnuaa@degree@graduate
    \ifnuaa@cite@style@authoryear
      \citestyle{authoryear}
      \bibliographystyle{nuaathesis-authoryear}
    \else
      \ifnuaa@cite@style@super
        \citestyle{super}
      \else
        \citestyle{inline}
      \fi
      \bibliographystyle{nuaathesis-numerical}
    \fi
  \else
    \ifnuaa@cite@style@super
      \citestyle{super}
    \else
      \citestyle{numbers}
    \fi
    \bibliographystyle{nuaathesis-bachelor}
  \fi
\fi

% 下面修改引用标注的格式，主要是将页码写在上标位置。
% Numerical 模式的 \cs{citet} 的页码：
\nuaa@patchcmd{\NAT@citexnum}{%
  \@ifnum{\NAT@ctype=\z@}{%
    \if*#2*\else\NAT@cmt#2\fi
  }{}%
  \NAT@mbox{\NAT@@close}%
}{%
  \NAT@mbox{\NAT@@close}%
  \@ifnum{\NAT@ctype=\z@}{%
    \if*#2*\else\textsuperscript{#2}\fi
  }{}%
}

% Numerical 模式的 \cs{citep} 的页码：
\renewcommand\NAT@citesuper[3]{\ifNAT@swa
\if*#2*\else#2\NAT@spacechar\fi
\unskip\kern\p@\textsuperscript{\NAT@@open#1\NAT@@close\if*#3*\else#3\fi}%
   \else #1\fi\endgroup}
\renewcommand\NAT@citenum%
    [3]{\ifNAT@swa\NAT@@open\if*#2*\else#2\NAT@spacechar\fi
        #1\NAT@@close\if*#3*\else\textsuperscript{#3}\fi\else#1\fi\endgroup}
        %
        % Author-year 模式的 \cs{citet} 的页码：
\nuaa@patchcmd{\NAT@citex}{%
  \if*#2*\else\NAT@cmt#2\fi
  \if\relax\NAT@date\relax\else\NAT@@close\fi
}{%
  \if\relax\NAT@date\relax\else\NAT@@close\fi
  \if*#2*\else\textsuperscript{#2}\fi
}

% Author-year 模式的 \cs{citep} 的页码：
\renewcommand\NAT@cite%
    [3]{\ifNAT@swa\NAT@@open\if*#2*\else#2\NAT@spacechar\fi
        #1\NAT@@close\if*#3*\else\textsuperscript{#3}\fi\else#1\fi\endgroup}
        %
        % 在顺序编码制下，\pkg{natbib} 只有在三个以上连续文献引用才会使用连接号，
        % 这里修改为允许两个引用使用连接号。
        % \footnote{\url{https://tex.stackexchange.com/a/86991/82731}}
\nuaa@patchcmd{\NAT@citexnum}{%
  \ifx\NAT@last@yr\relax
    \def@NAT@last@yr{\@citea}%
  \else
    \def@NAT@last@yr{--\NAT@penalty}%
  \fi
}{%
  \def@NAT@last@yr{-\NAT@penalty}%
}

% 参考文献列表格式：宋体 10.5 磅，行距 20 磅，续行缩进两字，左对齐。
% 本科生依然是小四宋体。
\ifnuaa@degree@graduate
  \renewcommand\bibfont{\fontsize{10.5\bp@}{20\bp@}\selectfont}
\fi
\setlength{\bibsep}{0\p@ \@plus.2\p@}
\setlength{\bibhang}{2\ccwd}
\renewcommand\@biblabel[1]{[#1]\hfill}

% 为了将参考文献加入目录和 pdf 书签，重新定义 \pkg{natbib} 的 \cmd{bibsection}
\renewcommand\bibsection{%
  \@mainmatterfalse
  \chapter{\bibname}%
}

% BibTeX 生成参考文献表的样式在 \file{bst} 文件中提供。


% \subsection{附录}

% 定义了一个满足要求的致谢环境：
\newenvironment{acknowledgements}{%
  \ifnuaa@degree@graduate
    \chapter{\nuaa@acknowledgements@name}%
  \else
    \nuaa@chapter{\nuaa@acknowledgements@name}%
    \ifnuaa@tocloaded
      本科生需要手动将致谢置于目录前。\par
    \fi
  \fi
}{}


% 兼容旧版本中“acknowledgments”的拼法。
% Reserved for compatibility until 2020-07-01.
\newenvironment{acknowledgments}{%
  \begin{acknowledgements}%
}{%
  \end{acknowledgements}%
}

% 发表成果环境：
\newenvironment{publications}{\chapter{\nuaa@publication@name}}{}


% \subsection{其他宏包的设置}

% 这些宏包并非格式要求，但是为了方便同学们使用，在这里进行简单设置。


% \subsubsection{\pkg{hyperref} 宏包}

\AtEndOfPackageFile*{hyperref}{
  \hypersetup{
    bookmarksnumbered  = true,
    bookmarksopen      = true,
    bookmarksopenlevel = 1,
    linktoc            = all,
    unicode            = true,
    psdextra           = true,
  }
  %
  % 如果为 \opt{pdf} 样式，设置 hyperlink 颜色
  \ifnuaa@output@electronic
    \hypersetup{
      colorlinks = true,
      allcolors  = blue,
    }
  \else
    \hypersetup{hidelinks}
  \fi
  %
  % 填写 PDF 元信息。
  \AtBeginDocument{%
    \ifnuaa@language@chinese
      \hypersetup{
        pdftitle  = \nuaa@title,
        pdfauthor = \nuaa@author,
      }%
    \else
      \hypersetup{
        pdftitle  = \nuaa@title@en,
        pdfauthor = \nuaa@author@en,
      }%
    \fi
  }
  %
  % 添加 PDF 书签
  %
  \newcounter{nuaa@bookmarknumber}
  \renewcommand\nuaa@pdfbookmark[1]{%
    \phantomsection
    \stepcounter{nuaa@bookmarknumber}%
    \pdfbookmark[0]{#1}{nuaachapter.\thenuaa@bookmarknumber}%
  }
  %
  % 在 PDF 字符串中去掉换行，以减少 \pkg{hyperref} 的警告信息。
  \pdfstringdefDisableCommands{
    \let\\\@empty
    \let\hspace\@gobble
  }
  %
  % \pkg{hyperref} 与 \pkg{unicode-math} 存在一些兼容性问题。
  \@ifpackagelater{hyperref}{2019/04/27}{}{%
    \g@addto@macro\psdmapshortnames{\let\mu\textmu}%
  }
  %
  % 设置中文的 \cs{autoref}。
  % \footnote{\url{https://tex.stackexchange.com/a/66150/82731}}
  \ifnuaa@language@chinese
    \def\equationautorefname~#1\null{公式~(#1)\null}
    \def\footnoteautorefname{脚注}
    \def\itemautorefname~#1\null{第~#1~项\null}
    \def\figureautorefname{图}
    \def\tableautorefname{表}
    \def\partautorefname~#1\null{第~#1~部分\null}
    \def\appendixautorefname{附录}
    \def\chapterautorefname~#1\null{第~#1~章\null}
    \def\sectionautorefname~#1\null{第~#1~节\null}
    \def\subsectionautorefname~#1\null{第~#1~小节\null}
    \def\subsubsectionautorefname~#1\null{第~#1~小小节\null}
    \def\paragraphautorefname~#1\null{第~#1~段\null}
    \def\subparagraphautorefname~#1\null{第~#1~小段\null}
    \def\theoremautorefname{定理}
    \def\HyRef@autopageref#1{\hyperref[{#1}]{第~\pageref*{#1} 页}}
  \fi
}


% \subsubsection{\pkg{amsthm} 宏包}

\AtEndOfPackageFile*{amsthm}{
  \newtheoremstyle{nuaaplain}
    {}{}
    {}{2\ccwd}
    {\bfseries}{}
    {\ccwd}{}
  \theoremstyle{nuaaplain}
  % 定义新的定理
  \ifnuaa@language@chinese
    \newcommand\nuaa@assertion@name{断言}
    \newcommand\nuaa@assumption@name{假设}
    \newcommand\nuaa@axiom@name{公理}
    \newcommand\nuaa@corollary@name{推论}
    \newcommand\nuaa@definition@name{定义}
    \newcommand\nuaa@example@name{例}
    \newcommand\nuaa@lemma@name{引理}
    \newcommand\nuaa@proof@name{证明}
    \newcommand\nuaa@proposition@name{命题}
    \newcommand\nuaa@remark@name{注}
    \newcommand\nuaa@theorem@name{定理}
  \else
    \newcommand\nuaa@assertion@name{Assertion}
    \newcommand\nuaa@assumption@name{Assumption}
    \newcommand\nuaa@axiom@name{Axiom}
    \newcommand\nuaa@corollary@name{Corollary}
    \newcommand\nuaa@definition@name{Definition}
    \newcommand\nuaa@example@name{Example}
    \newcommand\nuaa@lemma@name{Lemma}
    \newcommand\nuaa@proof@name{Proof}
    \newcommand\nuaa@proposition@name{Proposition}
    \newcommand\nuaa@remark@name{Remark}
    \newcommand\nuaa@theorem@name{Theorem}
  \fi
  \newtheorem{theorem}             {\nuaa@theorem@name}    [chapter]
  \newtheorem{assertion}  [theorem]{\nuaa@assertion@name}
  \newtheorem{axiom}      [theorem]{\nuaa@axiom@name}
  \newtheorem{corollary}  [theorem]{\nuaa@corollary@name}
  \newtheorem{lemma}      [theorem]{\nuaa@lemma@name}
  \newtheorem{proposition}[theorem]{\nuaa@proposition@name}
  \newtheorem{assumption}          {\nuaa@assumption@name} [chapter]
  \newtheorem{definition}          {\nuaa@definition@name} [chapter]
  \newtheorem{example}             {\nuaa@example@name}    [chapter]
  \newtheorem*{remark}             {\nuaa@remark@name}
  % \pkg{amsthm} 单独定义了 proof 环境，这里重新定义以满足格式要求。
  % 原本模仿 \pkg{amsthm} 写成 |\item[\hskip\labelsep\hskip2\ccwd #1\hskip\ccwd]|，
  % 但是却会多出一些间隙。
  \renewenvironment{proof}[1][\nuaa@proof@name]{\par
    \pushQED{\qed}%
    \normalfont \topsep6\p@\@plus6\p@\relax
    \trivlist
      \item\relax\hskip2\ccwd
      \textbf{#1}
      \hskip\ccwd\ignorespaces
    }{%
    \popQED\endtrivlist\@endpefalse
  }
}


% \subsubsection{\pkg{algorithm2e} 宏包}

% 按章节编号。
\PassOptionsToPackage{algochapter}{algorithm2e}

\AtEndOfPackageFile*{algorithm2e}{
  \ifnuaa@language@chinese
    \SetAlgorithmName{算法}{算法}{算法清单}
  \else
    \SetAlgorithmName{Algorithm}{Algorithm}{List of Algorithms}
  \fi
  %
  % 设置算法环境的格式。
  \SetAlCapSkip{6\bp@}
  \SetAlCapFnt{\small}
  \SetAlCapNameFnt{\small}
  \ifnuaa@degree@graduate
    \SetAlCapNameSty{textbf}
  \fi
  \SetAlgoCaptionSeparator{\unskip\hspace*{\ccwd}}
  %
  % 设置算法清单的格式
  \renewcommand\listofalgocfs{%
    \ifnuaa@degree@graduate
      \cleardoublepage
    \fi
    \nuaa@chapter{\listalgorithmcfname}%
    \@starttoc{loa}%
  }
  \titlecontents{algocf}
    [2.3em]{\normalsize}
    {\contentslabel{2.3em}}{}
    {\nuaa@leaders\contentspage}
  \contentsuse{algocf}{loa}
}


% \subsubsection{\pkg{nomencl} 宏包}

\AtEndOfPackageFile*{nomencl}{
  \let\nomname\nuaa@notation@name
  \def\thenomenclature{%
    \ifnuaa@degree@graduate
      \cleardoublepage
      \pagestyle{headings}%
    \fi
    \nuaa@chapter{\nuaa@notation@name}%
    \nompreamble
    \list{}{%
      \labelwidth\nom@tempdim
      \leftmargin\labelwidth
      \advance\leftmargin\labelsep
      \itemsep\nomitemsep
      \let\makelabel\nomlabel}}
  \def\endthenomenclature{%
    \endlist
    \nompostamble
    \ifnuaa@degree@graduate
      \clearpage
      \pagestyle{plain}%
    \fi
  }
}


% \subsubsection{\pkg{siunitx} 宏包}

\AtEndOfPackageFile*{siunitx}{
  \sisetup{
    group-minimum-digits = 4,
    separate-uncertainty = true,
    inter-unit-product   = \ensuremath{{}\cdot{}},
  }
  \ifnuaa@language@chinese
    \sisetup{
      list-final-separator = { 和 },
      list-pair-separator  = { 和 },
      range-phrase         = {～},
    }
  \fi
}

% \subsubsection{\pkg{chapterbib} 宏包}

\AtEndOfPackageFile*{chapterbib}{
  \renewcommand\bibsection{%
    \ctexset{section/numbering=false}%
    \section{\bibname}%
    \ctexset{section/numbering=true}%
  }
}
