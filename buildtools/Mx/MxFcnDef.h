/*
 * The contents of this file are subject to the MonetDB Public License
 * Version 1.1 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://monetdb.cwi.nl/Legal/MonetDBLicense-1.1.html
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 * The Original Code is the MonetDB Database System.
 *
 * The Initial Developer of the Original Code is CWI.
 * Portions created by CWI are Copyright (C) 1997-July 2008 CWI.
 * Copyright August 2008-2011 MonetDB B.V.
 * All Rights Reserved.
 */

/* System

extern	char *	malloc(unsigned int);
extern	int	free(char*);
extern	long	time(int);
extern	char *	ctime(long);
extern	char *	strcpy(char*, char*);
extern	int	strlen(char*);
extern	int	strcmp(char*, char*);
extern	char *	strchr(char*, char);
extern	char *	strrchr(char*, char);
extern	int	printf(char*, ...);
extern	char*	sprintf(char*, char*, ...); 
extern	int	sscanf(char*, char*, ...); 
extern	int	fgetc(FILE*);
extern	FILE *	fopen(char*, char*);
extern	FILE *	freopen(char*, char*, FILE*);
extern	int	feof(FILE*);
extern	int	fclose(FILE*);
extern	int	exit(int);
*/

/* Code.c
 */
extern void GenCode(void);
extern void CodeBlk(char *);
extern void CodeCall(char *);
extern void CodeSub(char *);
extern char *CodeSubBlk(char *, char **);
extern void CodeLine(void);
extern void UnRef(char *);
extern Tok *solveCond(Tok *);

/* Def.c
 */
extern void InitDef(void);
extern void MakeDefs(char *);
extern CmdCode DefDir(void);
extern char *DefCmd(void);
extern char *DefBlk(void);
extern void DefNl(void);
extern Def *NwDef(CmdCode, int, int, int, char *);
extern Def *GetDef(char *);
extern void DbDef(Def *);
extern char *dir2str(CmdCode);
extern char *dir2ext(CmdCode);
extern CmdCode lookup(char *);
extern int allTrue(void);
extern char *substr(char *, char *);


/* Display.c
 */
extern void PrFontStr(char *, char);
extern void PrModeStr(char *, char);
extern void PrCmd(char *);
extern void PrText(char *);
extern void PrCode(char *);
extern void PrRule(char *);

extern void PrPrelude(char *);
extern void PrPostlude(void);

/* Form.c
 */
extern void GenForm(void);
extern void FormBlk(Def *);
extern void FormSub(char *);
extern void FormTitle(void);
extern void FormHeader(void);
extern void FormMod(char *, int);
extern void FormSec(char *, int, int);
extern void FormPar(char *);
extern void FormIf(Def *);

/* Io.c
 */
extern char *FileName(char *);
extern void UpdateFiles(void);
extern void OutputDir(char *);
extern File *GetFile(char *, CmdCode);
extern int HasSuffix(char *, char *);
extern char *BaseName(char *);
extern char *TempName(char *);
extern void IoWriteFile(char *, CmdCode);
extern void IoReadFile(char *);
extern int EofFile(void);
extern void CloseFile(void);
extern char NextChr(void);
extern char *NextLine(void);
extern void PrevChr(char);
extern void PrevLine(void);

/* Mx.c
 */
extern int main(int, char **);
extern int ModeDir(char);
extern char *ExtMode(int);
extern int extract(CmdCode);
extern void WriteComment(char *, char *);


/* Print.c
 */
extern void PrCodeline(void);

extern void PrEnv(int);
extern void PrRef(int, int);
extern void PrNum(int);
extern void PrStr(char *);
extern void PrTxt(char *);
extern void PrChr(char);
extern void MathOn(void);
extern void MathOff(void);
extern void HideOn(void);
extern void HideOff(void);
extern int Hide(void);
extern void HideText(void);


/* Sys.c
 */
extern void ofile_putc(char);
extern void ofile_puts(char *);

extern char *Malloc(size_t);
extern void Free(char *);
extern char *StrDup(const char *);
extern char *Strndup(const char *, size_t);

extern void ofile_printf(char *, ...);
extern void Fatal(char *, char *, ...);
extern void Error(char *, ...);
extern void Message(char *, ...);

/* Tok.c
 */
extern Tok *FstTok(char *);
extern Tok *NxtTok(Tok *);
extern Tok *SkipTok(Tok *, char);
extern void DbTok(Tok *);
extern char **MkArgv(char *);
extern char **RmArgv(char **);
extern void DbArgv(char **);


/* Mx.c
 */

extern void addextension(char *);

