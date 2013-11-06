
#include "spr_defs.h"
#include "common.h"

/* This file is taken from orpmon */

int isspace(char c)
{
  if(c == ' '){
    return 1;
  }else if(c == '\t'){
    return 1;
  }else{
    return 0;
  }
}

/***********************************************************************/ 
/* Parses hex or decimal number */
unsigned long strtoul (const char *str, char **endptr, int base)
{
  unsigned long number = 0;
  char *pos = (char *) str;
  char *fail_char = (char *) str;

  while (isspace(*pos)) pos++;	/* skip leading whitespace */

  if ((base == 16) && (*pos == '0')) { /* handle option prefix */
    ++pos;
    fail_char = pos;
    if ((*pos == 'x') || (*pos == 'X')) ++pos;
  }

  if (base == 0) {		/* dynamic base */
    base = 10;		/* default is 10 */
    if (*pos == '0') {
      ++pos;
      base -= 2;		/* now base is 8 (or 16) */
      fail_char = pos;
      if ((*pos == 'x') || (*pos == 'X')) {
        base += 8;	/* base is 16 */
        ++pos;
      }
    }
  }

  /* check for illegal base */
  if ( !((base < 2) || (base > 36)) )
    while (1) {
      int digit = 40;
      if ((*pos >= '0') && (*pos <= '9')) {
          digit = (*pos - '0');
      } else if (*pos >= 'a') {
          digit = (*pos - 'a' + 10);
      } else if (*pos >= 'A') {
          digit = (*pos - 'A' + 10);
      } else break;

      if (digit >= base) break;

      fail_char = ++pos;
      number = number * base + digit;
    }

  if (endptr) *endptr = fail_char;
    return number;
}


    
/***************** Basic string functions *****************************/

/*
  s t r l e n

  returns number of characters in s (not including terminating null character)
*/
size_t strlen(const char *s)
{
  size_t cnt = 0;

  /* count the length of string s, not including the \0 character */
  while (*s++)
    cnt++;

  return cnt;
}

/*
  s t r c p y

  Copy 'src' to 'dest'. Strings may not overlap.
*/
char *strcpy(char *dest, const char *src)
{
  char *d = dest;

  /* copy src to dest */
  while ( (*dest++ = *src++) )
  ;

  return d;
}

/***********************************************************************/ 
char *strncpy(char *dest, const char *src, size_t n)
{
  char *d = dest;

  /* copy src to dest */
  while ( *src && n ) {
    *dest++ = *src++;
    n--;
  }

  /* fill the remainder of d with nulls */
  while (n--)
    *dest++ = '\0';

  return d;
}

/***********************************************************************/ 
char *strcat(char *dest, const char *src)
{
  char *d = dest;

  /* find the end of the destination string */
  while (*dest++)
  ;

  /* append the source string to the destination string */
  while ( (*dest++ = *src++) )
  ;

  return d;
}

/***********************************************************************/ 
char *strncat(char *dest, const char *src, size_t n)
{
  char *d = dest;

  /* find the end of the destination string */
  while (*dest++)
  ;

  /* copy src to dest */
  while ( (*dest = *src) && n-- ) {
    dest++;
    src++;
  }


  /* add terminating '\0' character */
  *dest = '\0';

  return d;
}

/***********************************************************************/ 
int strcmp(const char *s1, const char *s2)
{
  while ( *s1 && (*s1 == *s2) ) {
    s1++;
    s2++;
  }

  return *s1 - *s2;
}

/***********************************************************************/ 
int strncmp(const char *s1, const char *s2, size_t n)
{
  while ( *s1 && (*s1 == *s2) && n-- ) {
    s1++;
    s2++;
  }

  return *s1 - *s2;
}

/***********************************************************************/ 
char *strchr(const char *s, int c)
{
  /* search for the character c */
  while (*s && (*s != c) )
    s++;

  return (char *)s;
}

/***********************************************************************/ 
char *strrchr(const char *s, int c)
{
  char *fnd = NULL;

  /* search for the character c */
  while (*s) {
    if (*s == c)
      fnd = (char *)s;
    s++;
  }

  return fnd;
}


/* Basic mem functions */
/***********************************************************************/ 
void *memcpy(void *dest, const void *src, size_t n)
{
  /* check if 'src' and 'dest' are on LONG boundaries */
  if ( (sizeof(unsigned long) -1) & ((unsigned long)dest | (unsigned long)src) )
  {
      /* no, do a byte-wide copy */
      char *cs = (char *) src;
      char *cd = (char *) dest;

      while (n--)
          *cd++ = *cs++;
  }
  else
  {
      /* yes, speed up copy process */
      /* copy as many LONGs as possible */
      long *ls = (long *)src;
      long *ld = (long *)dest;

      size_t cnt = n >> 2;
      while (cnt--)
        *ld++ = *ls++;

      /* finally copy the remaining bytes */
      char *cs = (char *) (src + (n & ~0x03));
      char *cd = (char *) (dest + (n & ~0x03));

      cnt = n & 0x3;
      while (cnt--)
        *cd++ = *cs++;
  }

  return dest;
}

/***********************************************************************/ 
void *memmove(void *dest, void *src, size_t n)
{
  char *d = dest;
  char *s = src;

  while (n--)
    *d++ = *s++;

  return dest;
}

/***********************************************************************/ 
int memcmp(const void *s1, const void *s2, size_t n)
{
  char *p1 = (void *)s1;
  char *p2 = (void *)s2;

  while ( (*p1 == *p2) && n-- ) {
    p1++;
    p2++;
  }

  return *p1 - *p2;
}

/***********************************************************************/ 
void *memchr(const void *s, int c, size_t n)
{
  char *p = (void *)s;

  /* search for the character c */
  while ( (*p != c) && n-- )
    p++;

  return (*p == c) ? p : NULL;
}

/***********************************************************************/ 
void *memset(void *s, int c, size_t n)
{
  char *p = s;

  while (n--)
    *p++ = c;

  return s;
}



