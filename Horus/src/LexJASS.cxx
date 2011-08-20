// Scintilla source code edit control
// @file LexJASS.cxx
// Lexer for Blizzard JASS2 + vJass & cJass addons
//
// by Alexander (Van Damm) Vansach 
//
// v 0.4.6
// 01.10.2009


#include <stdlib.h>
#include <string.h>
#include <ctype.h>
//#include <stdarg.h>

#include "PropSet.h"
#include "Accessor.h"
#include "StyleContext.h"
#include "KeyWords.h"
#include "Scintilla.h"
#include "SciLexer.h"

//#include <stdio.h>
//#define DEBUG_COLOR
//#define DEBUG_FOLD
#define LOG(s) fprintf(log,s)

static inline bool cmp(const char* str, const char* word) {
	return (strcmp(str,word) == 0);
}

static inline bool IsValue(char ch) {
	return iswdigit(ch)>0;
}

static inline bool IsWordChar(const int ch) {
	return (ch < 0x80) && (iswalnum(ch) || ch == '_');
}

static inline bool IsWordStart(const int ch) {
	return (ch < 0x80) && (iswalnum(ch) || ch == '_' || ch == '.');
}

static inline bool IsOperator(char ch) {
	if (iswascii(ch) && iswalnum(ch))
		return false;
	if (ch == '+' || ch == '-' || ch == '*' || ch == '|' || ch == '!' || ch == '&' || ch == '=' || ch == '<' || ch == '>' || ch == '/' || ch == '(' || ch == ')' || ch == '[' || ch == ']' || ch == '\\' || ch == '{' || ch == '}')
		return true;
	return false;
}

// Syntax highlighting logic
static void ColoriseJASSDoc(unsigned int startPos, int length, int initStyle, WordList *keywordlists[], Accessor &styler) {

	#ifdef DEBUG_COLOR
		 FILE* log = fopen("logs\\horus_color.txt","a+");
		 fprintf(log,"\nColouriseJASSDoc (%i,%i,%i,...)", startPos, length, initStyle);
	#endif

	WordList &kwBlocks    = *keywordlists[0]; // 'Blocks'	 : folding points: constant, native, function, etc.
	WordList &kwSystem    = *keywordlists[1]; // 'System'    : call, set, local, return, and, or, not, debug
	WordList &kwValues    = *keywordlists[2]; // 'Values'	 : true, false, null
	WordList &kwSent      = *keywordlists[3]; // 'Sent Keys' : —
	WordList &kwTypes     = *keywordlists[4]; // 'Types'	 : nothing, integer, etc.
	WordList &kwNatives   = *keywordlists[5]; // 'natives'   : I2S, etc.
	WordList &kwBJs       = *keywordlists[6]; // 'BJs'	     : BJDebugMsg, etc
	WordList &kwUDFs      = *keywordlists[7]; // 'UDF'	     : —
	WordList &kwConstants = *keywordlists[8]; // 'Constants' : PLAYER_COLOR_RED, etc.

	#ifdef DEBUG_COLOR
		for (int i = 0; i < 9; ++i) {
			fprintf(log, "\n\tkeywordlists[%i].len = %i", i, keywordlists[i]->len);
		}
	#endif

	char cl = 0;	// Block comment nesting level
	char save[100];	// current word for eof processing

	StyleContext sc(startPos, length, initStyle, styler);

	for (; sc.More(); sc.Forward()) {

		char word[100];
		sc.GetCurrent(word,sizeof(word));

		 // Save current word for eof processing
		if (IsWordChar(sc.ch)) {
			strcpy_s(save,word);
			int tp = strlen(save);
			if (tp < 99) {
				save[tp] = static_cast<wchar_t>(tolower(sc.ch));
				save[tp+1] = '\0';
			}
		} //if (IsWordChar(sc.ch))

		// Determine if the current state should terminate.
		switch (sc.state) {
			case SCE_JASS_COMMENTLINE:
			case SCE_JASS_PCOMM:
				if (sc.atLineStart) {
					sc.SetState(SCE_JASS_DEFAULT);
				}
				break; //SCE_JASS_COMMENTLINE

			case SCE_JASS_COMMENTBLOCK:
				if (sc.Match('/','*')) {
					++cl;
				} 
				else if (sc.Match('*','/')) {
					char bracesOpen = 0;
					for (int k = sc.currentPos; k > 0; --k) {
						if (styler.StyleAt(k) != SCE_JASS_COMMENTBLOCK) {
							break;
						}
						if (styler[k]=='/' && styler[k+1]=='*') {
							++bracesOpen;
						} 
						else if (styler[k]=='*' && styler[k+1]=='/') {
							--bracesOpen;
						}
					}
					if (--cl<=0) {
						cl=0;
						sc.Forward();
						sc.Forward();
						sc.SetState(SCE_JASS_DEFAULT);
					}
					if (bracesOpen>0) {
						sc.ForwardSetState(SCE_JASS_COMMENTBLOCK);
					}
				}
				break; //SCE_JASS_COMMENTBLOCK

			case SCE_JASS_STRING:
				if (sc.ch == '\"' && (sc.chPrev != '\\' || (sc.chPrev == '\\' && styler.SafeGetCharAt(sc.currentPos-2) == '\\'))) {
					sc.ForwardSetState(SCE_JASS_DEFAULT);
				}
				break; //SCE_JASS_STRING:

			case SCE_JASS_RAWCODE:
				if (sc.atLineStart) {
					sc.SetState(SCE_JASS_DEFAULT);
				}
				if (sc.ch == '\'') {
					sc.ForwardSetState(SCE_JASS_DEFAULT);
				}
				break; //SCE_JASS_RAWCODE

			case SCE_JASS_SEMIKEYWORD:
				if (!IsWordChar(sc.ch)) {
					if (kwBlocks.InList(word)) {
						sc.ChangeState(SCE_JASS_BLOCK);
						sc.SetState(SCE_JASS_DEFAULT);
					} 
					else if (kwSystem.InList(word)) {
						sc.ChangeState(SCE_JASS_KEYWORD);
						sc.SetState(SCE_JASS_DEFAULT);
					} 
					else if (kwValues.InList(word)) {
						sc.ChangeState(SCE_JASS_VALUE);
						sc.SetState(SCE_JASS_DEFAULT);
					} 
					else if (kwTypes.InList(word)) {
						sc.ChangeState(SCE_JASS_TYPE);
						sc.SetState(SCE_JASS_DEFAULT);
					} 
					else if (kwNatives.InList(word)) {
						sc.ChangeState(SCE_JASS_NATIVE);
						sc.SetState(SCE_JASS_DEFAULT);
					} 
					else if (kwBJs.InList(word)) {
						sc.ChangeState(SCE_JASS_BJ);
						sc.SetState(SCE_JASS_DEFAULT);
					} 
					else if (kwConstants.InList(word)) {
						sc.ChangeState(SCE_JASS_CONST);
						sc.SetState(SCE_JASS_DEFAULT);
					} 
					else if (kwUDFs.InList(word)) {
						sc.ChangeState(SCE_JASS_UDF);
						sc.SetState(SCE_JASS_DEFAULT);
					} 
					else {
						sc.ChangeState(SCE_JASS_DEFAULT);
						sc.SetState(SCE_JASS_DEFAULT);
					}
				}
				break; //SCE_JASS_SEMIKEYWORD

			case SCE_JASS_OPERATOR:
				if (!IsOperator(sc.ch)) {
					sc.SetState(SCE_JASS_DEFAULT);
				} 
				else if (sc.Match('/','*')) {
					sc.SetState(SCE_JASS_COMMENTBLOCK);
				} 
				else if (sc.Match('/','/')) {
					sc.SetState(SCE_JASS_COMMENTLINE);
				}
				break; //SCE_JASS_OPERATOR

			case SCE_JASS_NUMBER:
				if (!IsValue(sc.ch) && !(IsValue(sc.chNext) && (sc.Match('x') || sc.Match('.')))) {
					sc.SetState(SCE_JASS_DEFAULT);
				}
				break; //SCE_JASS_NUMBER

			case SCE_JASS_VALUE:
				if (!IsWordChar(sc.ch)) {
					sc.SetState(SCE_JASS_DEFAULT);
				}
				break; // SCE_JASS_VALUE

		} // switch (sc.state)

		 // Determine if a new state should be entered.
		if (sc.state == SCE_JASS_DEFAULT) {
			if (sc.Match('/', '/')) {
				if (styler.SafeGetCharAt(sc.currentPos+2) == '!') {
					sc.SetState(SCE_JASS_PCOMM);
				}
				else {
					sc.SetState(SCE_JASS_COMMENTLINE);
				}
			} 
			else if (sc.Match('/', '*')) {
				++cl;
				sc.SetState(SCE_JASS_COMMENTBLOCK);
				sc.Forward();
			} 
			else if (sc.ch == '\"' && sc.chPrev != '\\') {
				sc.SetState(SCE_JASS_STRING);
			} 
			else if (sc.ch == '\'') {
				sc.SetState(SCE_JASS_RAWCODE);
			} 
			else if (IsValue(sc.ch) || (IsValue(sc.chNext) && (sc.Match('.') || sc.Match('$')))) {
				sc.SetState(SCE_JASS_NUMBER);
			} 
			else if (IsWordStart(sc.ch)) {
				sc.SetState(SCE_JASS_SEMIKEYWORD);
			} 
			else if (IsOperator(sc.ch)) {
				sc.SetState(SCE_JASS_OPERATOR);
			} 
		} //if (sc.state == SCE_JASS_DEFAULT)

	} //for (; sc.More(); sc.Forward())

	 // Colorise last word correctly
	if (sc.state == SCE_JASS_SEMIKEYWORD) {
		if (kwBlocks.InList(save)) {
			sc.ChangeState(SCE_JASS_BLOCK);
			sc.SetState(SCE_JASS_DEFAULT);
		} 
		else if (kwSystem.InList(save)) {
			sc.ChangeState(SCE_JASS_KEYWORD);
			sc.SetState(SCE_JASS_DEFAULT);
		} 
		else if (kwValues.InList(save)) {
			sc.ChangeState(SCE_JASS_VALUE);
			sc.SetState(SCE_JASS_DEFAULT);
		} 
		else if (kwTypes.InList(save)) {
			sc.ChangeState(SCE_JASS_TYPE);
			sc.SetState(SCE_JASS_DEFAULT);
		} 
		else if (kwNatives.InList(save)) {
			sc.ChangeState(SCE_JASS_NATIVE);
			sc.SetState(SCE_JASS_DEFAULT);
		} 
		else if (kwBJs.InList(save)) {
			sc.ChangeState(SCE_JASS_BJ);
			sc.SetState(SCE_JASS_DEFAULT);
		} 
		else if (kwConstants.InList(save)) {
			sc.ChangeState(SCE_JASS_CONST);
			sc.SetState(SCE_JASS_DEFAULT);
		} 
		else {
			sc.ChangeState(SCE_JASS_DEFAULT);
			sc.SetState(SCE_JASS_DEFAULT);
		}
	} //if (sc.state == SCE_JASS_SEMIKEYWORD)

	sc.Complete();

	#ifdef DEBUG_COLOR
		fprintf(log,"\nEND");
		fclose(log);
	#endif
} //ColouriseJASSDoc()


static inline bool IsCommentStyle(int style) {
	return (style == SCE_JASS_COMMENTBLOCK || style == SCE_JASS_COMMENTLINE || style == SCE_JASS_PCOMM);
}


// Used to determine if to start or end a fold
static inline bool StartFold(const char* w0, const char* w1, const char* w2, const char* w3) {
	if (cmp(w0,"function")) {
		if (cmp(w1,"interface")) {
			return false;
		} else {
			return true;
		}
	} else if (cmp(w0,"if")       || cmp(w0,"loop")           || 
			   cmp(w0,"textmacro")|| cmp(w0,"textmacro_once") || 
			   cmp(w0,"struct")   || cmp(w0,"method")		 ||
			   cmp(w0,"library")  || cmp(w0,"library_once")   || 
			   cmp(w0,"interface")|| cmp(w0,"scope")			 ||
			   cmp(w0,"inject")   || cmp(w0,"novjass")		 ||
			   cmp(w0,"module")   || cmp(w0,"globals")) {
			return true;
	} else if (cmp(w0,"private") || cmp(w0,"public")) {
		if (cmp(w1,"function") || cmp(w1,"method") || cmp(w1,"struct") || cmp(w1,"module")) {
			return true;
		} else if (cmp(w1,"static") || cmp(w1,"stub") || cmp(w1,"constant")) {
			if (cmp(w2,"method") || cmp(w2,"function")) {
				return true;
			} else if (cmp(w2,"constant") && (cmp(w3,"method"))) {
				return true;
			}
		}
	} else if (cmp(w0,"static") && cmp(w1,"method")) {
		return true;
	} else if (cmp(w0,"constant") && cmp(w1,"function")) {
		return true;
	}
	return false;
} // IfStartFold()

static inline bool EndFold(const char* w) {
	if (cmp(w,"endfunction") || cmp(w,"endmethod")   || cmp(w,"endlibrary")   ||
		cmp(w,"endscope")    || cmp(w,"endif")       || cmp(w,"endloop")      ||
		cmp(w,"endmodule")   || cmp(w,"endglobals")  || cmp(w,"endinterface") ||
		cmp(w,"endstruct")   || cmp(w,"endtextmacro")|| cmp(w,"endinject")   || 
		cmp(w,"endnovjass")) {
		return true;
	}
	return false;
}


// Find first non-space symbol on the current line and return its Style
// needed for comment lines not starting on pos 1 
static int GetFirstWord(unsigned int szLine, Accessor &styler) {
	int nsPos = styler.LineStart(szLine);
	int nePos = styler.LineStart(szLine+1) - 1;
	while (isspacechar(styler.SafeGetCharAt(nsPos)) && nsPos < nePos) {
		++nsPos; // skip to next char
	} // End While
	return styler.StyleAt(nsPos);

} // GetStyleFirstWord()


bool GetWord(char* word, unsigned int &wordStart, unsigned int &wordEnd, unsigned int &pos, unsigned int max, Accessor &styler) {
	while (pos < max && (isspacechar(styler.SafeGetCharAt(pos)) || !IsWordChar(styler.SafeGetCharAt(pos)) || styler.StyleAt(pos) == SCE_JASS_COMMENTBLOCK)) {
		++pos;
	}
	if (pos>=max || !(styler.StyleAt(pos) == SCE_JASS_BLOCK || styler.StyleAt(pos) == SCE_JASS_PCOMM)) {
		return false;
	}

	wordStart = pos;
	int wordSize = 0;
	char c = styler.SafeGetCharAt(pos);
	while (wordSize < 19 && IsWordChar(c)) {
		word[wordSize++] = c;
		c = styler.SafeGetCharAt(++pos);
	} 
	word[wordSize] = '\0';
	wordEnd = pos;

	return true;
}

// Find next/previous char. Stops only on linebreaks
inline bool FindBraceHere(char sym, unsigned int &j, Accessor &styler, bool forward) {
	short inc = forward ? 1 : -1;
	unsigned int border = forward ? styler.Length()-1 : 0;

	char c = styler.SafeGetCharAt(j);
	while (forward ? (j <= border) : (j >= border) && c != '\n') 
	{
		if (c == sym) {
			return true;
		}
		j+=inc;
		c = styler.SafeGetCharAt(j);
	}
	return false;
}

// Same as above, but doesn't concern linebreaks as stop points
inline bool FindBraceLater(char sym, unsigned int &j, Accessor &styler, bool forward) {
	short inc = forward ? 1 : -1;
	unsigned int border = forward ? styler.Length()-1 : 0;

	char c = styler.SafeGetCharAt(j);
	while (forward ? (j <= border) : (j >= border) && (IsCommentStyle(styler.StyleAt(j)) || !IsWordChar(c))) {
		if (c == sym) {
			return true;
		}
		j+=inc;
		c = styler.SafeGetCharAt(j);
	}
	return false;
}


// Find { after the opening block to decide on folding
inline bool FindNextBrace(unsigned int j, unsigned int max, Accessor &styler) {
	// Search till end of line
	while (j<=max) {
		if (styler.SafeGetCharAt(j++) == '{') {
			return true;
		}
	}

	// Search next line for { till first char
	while (j<styler.Length()-1 && (styler.StyleAt(j)==SCE_JASS_COMMENTBLOCK || !IsWordChar(styler.SafeGetCharAt(j)))) {
		if (styler.SafeGetCharAt(j++) == '{') {
			return true;
		}
	}
	return false;
}


// Code folding logic
static void FoldJASSDoc(unsigned int startPos, int length, int initStyle, WordList *[], Accessor &styler) {

	#ifdef DEBUG_FOLD
		FILE* log = fopen("logs\\horus_fold.txt","a+");
		fprintf(log,"\nFoldJASSDoc (%i,%i,%i,...)",startPos, length, initStyle);
	#endif

	bool fold = styler.GetPropertyInt("fold") != 0;
	bool foldComment = fold;  //styler.GetPropertyInt("fold.comment") != 0;
	bool foldAtElse = fold;

	unsigned int endPos = startPos + length;
	int visibleChars = 0;
	int lineCurrent = styler.GetLine(startPos);

	int levelCurrent = SC_FOLDLEVELBASE;
	if (lineCurrent > 0)
		levelCurrent = styler.LevelAt(lineCurrent-1) >> 16;
	int levelMinCurrent = levelCurrent;
	int levelNext = levelCurrent;
	char chNext = styler[startPos];
	int styleNext = styler.StyleAt(startPos);
	int style = initStyle;

	bool blockWordFound = false;
	bool blockOpen = false;
	bool interfaceFound = false;
	//unsigned int lineStart = 0;

	for (unsigned int i = startPos; i < endPos; i++) {
		char ch = chNext;
		chNext = styler.SafeGetCharAt(i + 1);
		int stylePrev = style;
		style = styleNext;
		styleNext = styler.StyleAt(i + 1);

		bool atEOL = (ch == '\r' && chNext != '\n') || (ch == '\n');

		if (foldComment && style == SCE_JASS_COMMENTBLOCK) {
			if (stylePrev != SCE_JASS_COMMENTBLOCK) {
				++levelNext;
			} else if (styleNext != SCE_JASS_COMMENTBLOCK && !atEOL) {
				// Comments don't end at end of line and the next character may be unstyled.
				--levelNext;
			}
		}
		
		if (style == SCE_JASS_OPERATOR) {
			if (ch == '{') {
				blockOpen = true;
				// Loop until the beginning of the line 
				// to find out if we have to start fold one line earlier
				/*
				bool doFold = true;
				#ifdef DEBUG_FOLD
								fprintf(log,"\n\tFound { at %i",i);
				#endif
				for (unsigned int j = i; j > startPos; j--) {
					char ch = styler.SafeGetCharAt(j);
					if (ch == '\n') {
						int lev;
						if (blockWordFound) {
							lev = ((levelCurrent-1) | (levelCurrent) << 16) | SC_FOLDLEVELHEADERFLAG;
							doFold = false;
						} else {
							lev = ((levelCurrent) | (++levelCurrent) << 16) | SC_FOLDLEVELHEADERFLAG;
						}
						styler.SetLevel(lineCurrent-1, lev);

						#ifdef DEBUG_FOLD
							fprintf(log,"\n\t\tSetLevel(%i,%i)",i);
						#endif

						doFold = false;
						break;
					}
					if (IsWordStart(ch)) {
						break;
					}
				}
				*/

				// Measure the minimum before a '{' to allow
				// folding on "} else {"
				if (levelMinCurrent > levelNext) {
					levelMinCurrent = levelNext;
				}

				//if (doFold) {
					++levelNext;
				//}
			} else if (ch == '}') {
				blockOpen = false;
				--levelNext;
			}
		}

		if (!IsASpace(ch))
			++visibleChars;

		if (atEOL || (i == endPos-1)) {

			#ifdef DEBUG_FOLD
				fprintf(log,"\n\tEOL (%i, %i -> %i)",lineCurrent+1,styler.LineStart(lineCurrent),i);
			#endif

			if (visibleChars > 0) {
				unsigned int j = styler.LineStart(lineCurrent);
				char word1[20] = {'\0'};
				char word2[20] = {'\0'};
				char word3[20] = {'\0'};
				char word4[20] = {'\0'};
				unsigned int wordBounds[8] = {0};

				if (GetWord(word1,wordBounds[0],wordBounds[4],j,i,styler)) { 
					if (GetWord(word2,wordBounds[1],wordBounds[5],j,i,styler)) { 
						if (GetWord(word3,wordBounds[2],wordBounds[6],j,i,styler)) {
							GetWord(word4,wordBounds[3],wordBounds[7],j,i,styler);
						}
					}
				}

				#ifdef DEBUG_FOLD
					fprintf(log,"\n\t\twords = [%s,%s,%s,%s]",word1,word2,word3,word4);
				#endif

				// If classic fold started
				if (StartFold(word1,word2,word3,word4)) {
					//blockWordFound = true;

					//unsigned int tmp = wordBounds[4];
					if (!FindNextBrace(wordBounds[4],i,styler) && !interfaceFound) {
						++levelNext;
					}

					// interface check
					if (cmp(word1,"interface")) {
						interfaceFound = true;
					}
				}

				// If classic fold ended
				if (EndFold(word1)) {
					--levelNext;

					// interface check
					if (cmp(word1,"endinterface")) {
						interfaceFound = false;
					}
				}

				// Fold on else
				if (cmp(word1,"else") || cmp(word1,"elseif")) {
					unsigned int wordStart = wordBounds[0];
					unsigned int wordEnd = wordBounds[4];
					//bool fixElse = false;
					//LOG("\n\t\tPerforming else fix");
					//for (int k=styler.LineStart(lineCurrent); styler.SafeGetCharAt(k) != '\n'; ++k) {
						
					//}
					if (!FindBraceLater('}', wordStart, styler, false) && 
						!FindBraceLater('{', wordEnd, styler, true)) {
						--levelCurrent;
						--levelMinCurrent;
					}

					/*	
					if (FindBraceHere('}', wordStart, styler, false)) {
						LOG("\n\t\t\t} else ?");
						if (FindBraceHere('{', wordEnd, styler, true)) {
							LOG("\n\t\t\t\t} else {");
							fixElse = false;
						} else {
							LOG("\n\t\t\t\t} else _ ?");
							if (FindBraceOtherLine('{', wordEnd, styler, true)) {
								LOG("\n\t\t\t\t\t} else _ {");
								fixElse = false;
							} else {
								LOG("\n\t\t\t\t\t} else _ _");
								fixElse = true;
								++levelNext;
							}
						}
					} else {
						LOG("\n\t\t\t? _ else ?");
						if (FindBraceOtherLine('}', wordEnd, styler, false)) {
							LOG("\n\t\t\t\t} _ else ?");
							if (FindBraceOtherLine('{', wordEnd, styler, true)) {
								LOG("\n\t\t\t\t\t} _ else { OR } _ else _ {");
								fixElse = false;
							} else {
								LOG("\n\t\t\t\t\t} _ else _ _");
								fixElse = false;
								++levelNext;
							}	
						} else {
							LOG("\n\t\t\t\t_ _ else ?");
							if (FindBraceHere('{', wordEnd, styler, true)) {
								LOG("\n\t\t\t\t\t_ _ else {");
								fixElse = true;
								--levelNext;
							} else {
								LOG("\n\t\t\t\t\t_ _ else _ ?");
								if (FindBraceOtherLine('{', wordEnd, styler, true)) {
									LOG("\n\t\t\t\t\t\t\t_ _ else _ {");
									fixElse = false;
									--levelNext;
								} else {
									LOG("\n\t\t\t\t\t\t\t_ _ else _ _");
									fixElse = true;
								}
							}
						}
					}
					*/
					/*
					if (fixElse) {
						fprintf(log,"\n\t\t\tFixing else");
						--levelCurrent;
						--levelMinCurrent;
					}
					*/
				}

			}
			int levelUse = levelCurrent;
			if (foldAtElse) {
				levelUse = levelMinCurrent;
			}
			int lev = levelUse | levelNext << 16;
			/*
			if (visibleChars == 0) {
				lev |= SC_FOLDLEVELWHITEFLAG;
				#ifdef DEBUG
					fprintf(log,"\n\t\tSC_FOLDLEVELWHITEFLAG");
				#endif
			}*/

			if (levelUse < levelNext) {
				lev |= SC_FOLDLEVELHEADERFLAG;
				#ifdef DEBUG_FOLD
					fprintf(log,"\n\t\tSC_FOLDLEVELHEADERFLAG");
				#endif
			}

			if (lev != styler.LevelAt(lineCurrent)) {
				styler.SetLevel(lineCurrent, lev);
				#ifdef DEBUG_FOLD
					fprintf(log,"\n\t\t(%i -> %i)",levelUse,levelNext);
				#endif
			}

			++lineCurrent;
			levelCurrent = levelNext;
			levelMinCurrent = levelCurrent;
			if (atEOL && (i == static_cast<unsigned int>(styler.Length()-1))) {
				// There is an empty line at end of file so give it same level and empty
				styler.SetLevel(lineCurrent, (levelCurrent | levelCurrent << 16));
			}

			visibleChars = 0;
			//lineStart = i;
		}

	}

	#ifdef DEBUG_FOLD
		fprintf(log,"\nend");
		fclose(log);
	#endif

} //FoldJASSDoc()


static const char * const JASSWordLists[] = {
	"blocks",
	"keywords",
	"values",
	"Sent keys",
	"types",
	"natives",
	"BJs",
	"expand",
	"constants",
	0
};

LexerModule lmJASS(SCLEX_JASS, ColoriseJASSDoc, "au3", FoldJASSDoc, JASSWordLists);