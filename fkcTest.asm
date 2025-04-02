
_fkcTest:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "types.h"
#include "stat.h"
#include "user.h"

int main() {
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 30             	sub    $0x30,%esp
  int initial = fkc(1);
   9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10:	e8 2d 04 00 00       	call   442 <fkc>
  15:	89 44 24 28          	mov    %eax,0x28(%esp)
  printf(1, "number of forks when program starts: %d\n", initial);
  19:	8b 44 24 28          	mov    0x28(%esp),%eax
  1d:	89 44 24 08          	mov    %eax,0x8(%esp)
  21:	c7 44 24 04 f8 08 00 	movl   $0x8f8,0x4(%esp)
  28:	00 
  29:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  30:	e8 f5 04 00 00       	call   52a <printf>
  int i = 0;
  35:	c7 44 24 2c 00 00 00 	movl   $0x0,0x2c(%esp)
  3c:	00 
  for (i = 0; i < 2; i++) {
  3d:	c7 44 24 2c 00 00 00 	movl   $0x0,0x2c(%esp)
  44:	00 
  45:	eb 1f                	jmp    66 <main+0x66>
    int pid = fork();
  47:	e8 46 03 00 00       	call   392 <fork>
  4c:	89 44 24 24          	mov    %eax,0x24(%esp)
    if (pid == 0) exit();
  50:	83 7c 24 24 00       	cmpl   $0x0,0x24(%esp)
  55:	75 05                	jne    5c <main+0x5c>
  57:	e8 3e 03 00 00       	call   39a <exit>
    wait();
  5c:	e8 41 03 00 00       	call   3a2 <wait>
  for (i = 0; i < 2; i++) {
  61:	83 44 24 2c 01       	addl   $0x1,0x2c(%esp)
  66:	83 7c 24 2c 01       	cmpl   $0x1,0x2c(%esp)
  6b:	7e da                	jle    47 <main+0x47>
  }

  int afterTwo = fkc(1);
  6d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  74:	e8 c9 03 00 00       	call   442 <fkc>
  79:	89 44 24 20          	mov    %eax,0x20(%esp)
  printf(1, "number of forks after two more forks: %d\n", afterTwo);
  7d:	8b 44 24 20          	mov    0x20(%esp),%eax
  81:	89 44 24 08          	mov    %eax,0x8(%esp)
  85:	c7 44 24 04 24 09 00 	movl   $0x924,0x4(%esp)
  8c:	00 
  8d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  94:	e8 91 04 00 00       	call   52a <printf>

  fkc(0);
  99:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  a0:	e8 9d 03 00 00       	call   442 <fkc>
  int afterReset = fkc(1);
  a5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  ac:	e8 91 03 00 00       	call   442 <fkc>
  b1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  printf(1, "number of forks after fork count cleared: %d\n", afterReset);
  b5:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  b9:	89 44 24 08          	mov    %eax,0x8(%esp)
  bd:	c7 44 24 04 50 09 00 	movl   $0x950,0x4(%esp)
  c4:	00 
  c5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  cc:	e8 59 04 00 00       	call   52a <printf>

  for (i = 0; i < 3; i++) {
  d1:	c7 44 24 2c 00 00 00 	movl   $0x0,0x2c(%esp)
  d8:	00 
  d9:	eb 1f                	jmp    fa <main+0xfa>
    int pid = fork();
  db:	e8 b2 02 00 00       	call   392 <fork>
  e0:	89 44 24 18          	mov    %eax,0x18(%esp)
    if (pid == 0) exit();
  e4:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
  e9:	75 05                	jne    f0 <main+0xf0>
  eb:	e8 aa 02 00 00       	call   39a <exit>
    wait();
  f0:	e8 ad 02 00 00       	call   3a2 <wait>
  for (i = 0; i < 3; i++) {
  f5:	83 44 24 2c 01       	addl   $0x1,0x2c(%esp)
  fa:	83 7c 24 2c 02       	cmpl   $0x2,0x2c(%esp)
  ff:	7e da                	jle    db <main+0xdb>
  }

  int afterThree = fkc(1);
 101:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 108:	e8 35 03 00 00       	call   442 <fkc>
 10d:	89 44 24 14          	mov    %eax,0x14(%esp)
  printf(1, "number of forks after three more forks: %d\n", afterThree);
 111:	8b 44 24 14          	mov    0x14(%esp),%eax
 115:	89 44 24 08          	mov    %eax,0x8(%esp)
 119:	c7 44 24 04 80 09 00 	movl   $0x980,0x4(%esp)
 120:	00 
 121:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 128:	e8 fd 03 00 00       	call   52a <printf>

  exit();
 12d:	e8 68 02 00 00       	call   39a <exit>

00000132 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 132:	55                   	push   %ebp
 133:	89 e5                	mov    %esp,%ebp
 135:	57                   	push   %edi
 136:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 137:	8b 4d 08             	mov    0x8(%ebp),%ecx
 13a:	8b 55 10             	mov    0x10(%ebp),%edx
 13d:	8b 45 0c             	mov    0xc(%ebp),%eax
 140:	89 cb                	mov    %ecx,%ebx
 142:	89 df                	mov    %ebx,%edi
 144:	89 d1                	mov    %edx,%ecx
 146:	fc                   	cld    
 147:	f3 aa                	rep stos %al,%es:(%edi)
 149:	89 ca                	mov    %ecx,%edx
 14b:	89 fb                	mov    %edi,%ebx
 14d:	89 5d 08             	mov    %ebx,0x8(%ebp)
 150:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 153:	5b                   	pop    %ebx
 154:	5f                   	pop    %edi
 155:	5d                   	pop    %ebp
 156:	c3                   	ret    

00000157 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 157:	55                   	push   %ebp
 158:	89 e5                	mov    %esp,%ebp
 15a:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 15d:	8b 45 08             	mov    0x8(%ebp),%eax
 160:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 163:	90                   	nop
 164:	8b 45 08             	mov    0x8(%ebp),%eax
 167:	8d 50 01             	lea    0x1(%eax),%edx
 16a:	89 55 08             	mov    %edx,0x8(%ebp)
 16d:	8b 55 0c             	mov    0xc(%ebp),%edx
 170:	8d 4a 01             	lea    0x1(%edx),%ecx
 173:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 176:	0f b6 12             	movzbl (%edx),%edx
 179:	88 10                	mov    %dl,(%eax)
 17b:	0f b6 00             	movzbl (%eax),%eax
 17e:	84 c0                	test   %al,%al
 180:	75 e2                	jne    164 <strcpy+0xd>
    ;
  return os;
 182:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 185:	c9                   	leave  
 186:	c3                   	ret    

00000187 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 187:	55                   	push   %ebp
 188:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 18a:	eb 08                	jmp    194 <strcmp+0xd>
    p++, q++;
 18c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 190:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 194:	8b 45 08             	mov    0x8(%ebp),%eax
 197:	0f b6 00             	movzbl (%eax),%eax
 19a:	84 c0                	test   %al,%al
 19c:	74 10                	je     1ae <strcmp+0x27>
 19e:	8b 45 08             	mov    0x8(%ebp),%eax
 1a1:	0f b6 10             	movzbl (%eax),%edx
 1a4:	8b 45 0c             	mov    0xc(%ebp),%eax
 1a7:	0f b6 00             	movzbl (%eax),%eax
 1aa:	38 c2                	cmp    %al,%dl
 1ac:	74 de                	je     18c <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 1ae:	8b 45 08             	mov    0x8(%ebp),%eax
 1b1:	0f b6 00             	movzbl (%eax),%eax
 1b4:	0f b6 d0             	movzbl %al,%edx
 1b7:	8b 45 0c             	mov    0xc(%ebp),%eax
 1ba:	0f b6 00             	movzbl (%eax),%eax
 1bd:	0f b6 c0             	movzbl %al,%eax
 1c0:	29 c2                	sub    %eax,%edx
 1c2:	89 d0                	mov    %edx,%eax
}
 1c4:	5d                   	pop    %ebp
 1c5:	c3                   	ret    

000001c6 <strlen>:

uint
strlen(const char *s)
{
 1c6:	55                   	push   %ebp
 1c7:	89 e5                	mov    %esp,%ebp
 1c9:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1cc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1d3:	eb 04                	jmp    1d9 <strlen+0x13>
 1d5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1d9:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1dc:	8b 45 08             	mov    0x8(%ebp),%eax
 1df:	01 d0                	add    %edx,%eax
 1e1:	0f b6 00             	movzbl (%eax),%eax
 1e4:	84 c0                	test   %al,%al
 1e6:	75 ed                	jne    1d5 <strlen+0xf>
    ;
  return n;
 1e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1eb:	c9                   	leave  
 1ec:	c3                   	ret    

000001ed <memset>:

void*
memset(void *dst, int c, uint n)
{
 1ed:	55                   	push   %ebp
 1ee:	89 e5                	mov    %esp,%ebp
 1f0:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 1f3:	8b 45 10             	mov    0x10(%ebp),%eax
 1f6:	89 44 24 08          	mov    %eax,0x8(%esp)
 1fa:	8b 45 0c             	mov    0xc(%ebp),%eax
 1fd:	89 44 24 04          	mov    %eax,0x4(%esp)
 201:	8b 45 08             	mov    0x8(%ebp),%eax
 204:	89 04 24             	mov    %eax,(%esp)
 207:	e8 26 ff ff ff       	call   132 <stosb>
  return dst;
 20c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 20f:	c9                   	leave  
 210:	c3                   	ret    

00000211 <strchr>:

char*
strchr(const char *s, char c)
{
 211:	55                   	push   %ebp
 212:	89 e5                	mov    %esp,%ebp
 214:	83 ec 04             	sub    $0x4,%esp
 217:	8b 45 0c             	mov    0xc(%ebp),%eax
 21a:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 21d:	eb 14                	jmp    233 <strchr+0x22>
    if(*s == c)
 21f:	8b 45 08             	mov    0x8(%ebp),%eax
 222:	0f b6 00             	movzbl (%eax),%eax
 225:	3a 45 fc             	cmp    -0x4(%ebp),%al
 228:	75 05                	jne    22f <strchr+0x1e>
      return (char*)s;
 22a:	8b 45 08             	mov    0x8(%ebp),%eax
 22d:	eb 13                	jmp    242 <strchr+0x31>
  for(; *s; s++)
 22f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 233:	8b 45 08             	mov    0x8(%ebp),%eax
 236:	0f b6 00             	movzbl (%eax),%eax
 239:	84 c0                	test   %al,%al
 23b:	75 e2                	jne    21f <strchr+0xe>
  return 0;
 23d:	b8 00 00 00 00       	mov    $0x0,%eax
}
 242:	c9                   	leave  
 243:	c3                   	ret    

00000244 <gets>:

char*
gets(char *buf, int max)
{
 244:	55                   	push   %ebp
 245:	89 e5                	mov    %esp,%ebp
 247:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 24a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 251:	eb 4c                	jmp    29f <gets+0x5b>
    cc = read(0, &c, 1);
 253:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 25a:	00 
 25b:	8d 45 ef             	lea    -0x11(%ebp),%eax
 25e:	89 44 24 04          	mov    %eax,0x4(%esp)
 262:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 269:	e8 44 01 00 00       	call   3b2 <read>
 26e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 271:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 275:	7f 02                	jg     279 <gets+0x35>
      break;
 277:	eb 31                	jmp    2aa <gets+0x66>
    buf[i++] = c;
 279:	8b 45 f4             	mov    -0xc(%ebp),%eax
 27c:	8d 50 01             	lea    0x1(%eax),%edx
 27f:	89 55 f4             	mov    %edx,-0xc(%ebp)
 282:	89 c2                	mov    %eax,%edx
 284:	8b 45 08             	mov    0x8(%ebp),%eax
 287:	01 c2                	add    %eax,%edx
 289:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 28d:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 28f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 293:	3c 0a                	cmp    $0xa,%al
 295:	74 13                	je     2aa <gets+0x66>
 297:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 29b:	3c 0d                	cmp    $0xd,%al
 29d:	74 0b                	je     2aa <gets+0x66>
  for(i=0; i+1 < max; ){
 29f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2a2:	83 c0 01             	add    $0x1,%eax
 2a5:	3b 45 0c             	cmp    0xc(%ebp),%eax
 2a8:	7c a9                	jl     253 <gets+0xf>
      break;
  }
  buf[i] = '\0';
 2aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
 2ad:	8b 45 08             	mov    0x8(%ebp),%eax
 2b0:	01 d0                	add    %edx,%eax
 2b2:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 2b5:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2b8:	c9                   	leave  
 2b9:	c3                   	ret    

000002ba <stat>:

int
stat(const char *n, struct stat *st)
{
 2ba:	55                   	push   %ebp
 2bb:	89 e5                	mov    %esp,%ebp
 2bd:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2c0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 2c7:	00 
 2c8:	8b 45 08             	mov    0x8(%ebp),%eax
 2cb:	89 04 24             	mov    %eax,(%esp)
 2ce:	e8 07 01 00 00       	call   3da <open>
 2d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2d6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2da:	79 07                	jns    2e3 <stat+0x29>
    return -1;
 2dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2e1:	eb 23                	jmp    306 <stat+0x4c>
  r = fstat(fd, st);
 2e3:	8b 45 0c             	mov    0xc(%ebp),%eax
 2e6:	89 44 24 04          	mov    %eax,0x4(%esp)
 2ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2ed:	89 04 24             	mov    %eax,(%esp)
 2f0:	e8 fd 00 00 00       	call   3f2 <fstat>
 2f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2fb:	89 04 24             	mov    %eax,(%esp)
 2fe:	e8 bf 00 00 00       	call   3c2 <close>
  return r;
 303:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 306:	c9                   	leave  
 307:	c3                   	ret    

00000308 <atoi>:

int
atoi(const char *s)
{
 308:	55                   	push   %ebp
 309:	89 e5                	mov    %esp,%ebp
 30b:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 30e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 315:	eb 25                	jmp    33c <atoi+0x34>
    n = n*10 + *s++ - '0';
 317:	8b 55 fc             	mov    -0x4(%ebp),%edx
 31a:	89 d0                	mov    %edx,%eax
 31c:	c1 e0 02             	shl    $0x2,%eax
 31f:	01 d0                	add    %edx,%eax
 321:	01 c0                	add    %eax,%eax
 323:	89 c1                	mov    %eax,%ecx
 325:	8b 45 08             	mov    0x8(%ebp),%eax
 328:	8d 50 01             	lea    0x1(%eax),%edx
 32b:	89 55 08             	mov    %edx,0x8(%ebp)
 32e:	0f b6 00             	movzbl (%eax),%eax
 331:	0f be c0             	movsbl %al,%eax
 334:	01 c8                	add    %ecx,%eax
 336:	83 e8 30             	sub    $0x30,%eax
 339:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 33c:	8b 45 08             	mov    0x8(%ebp),%eax
 33f:	0f b6 00             	movzbl (%eax),%eax
 342:	3c 2f                	cmp    $0x2f,%al
 344:	7e 0a                	jle    350 <atoi+0x48>
 346:	8b 45 08             	mov    0x8(%ebp),%eax
 349:	0f b6 00             	movzbl (%eax),%eax
 34c:	3c 39                	cmp    $0x39,%al
 34e:	7e c7                	jle    317 <atoi+0xf>
  return n;
 350:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 353:	c9                   	leave  
 354:	c3                   	ret    

00000355 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 355:	55                   	push   %ebp
 356:	89 e5                	mov    %esp,%ebp
 358:	83 ec 10             	sub    $0x10,%esp
  char *dst;
  const char *src;

  dst = vdst;
 35b:	8b 45 08             	mov    0x8(%ebp),%eax
 35e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 361:	8b 45 0c             	mov    0xc(%ebp),%eax
 364:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 367:	eb 17                	jmp    380 <memmove+0x2b>
    *dst++ = *src++;
 369:	8b 45 fc             	mov    -0x4(%ebp),%eax
 36c:	8d 50 01             	lea    0x1(%eax),%edx
 36f:	89 55 fc             	mov    %edx,-0x4(%ebp)
 372:	8b 55 f8             	mov    -0x8(%ebp),%edx
 375:	8d 4a 01             	lea    0x1(%edx),%ecx
 378:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 37b:	0f b6 12             	movzbl (%edx),%edx
 37e:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 380:	8b 45 10             	mov    0x10(%ebp),%eax
 383:	8d 50 ff             	lea    -0x1(%eax),%edx
 386:	89 55 10             	mov    %edx,0x10(%ebp)
 389:	85 c0                	test   %eax,%eax
 38b:	7f dc                	jg     369 <memmove+0x14>
  return vdst;
 38d:	8b 45 08             	mov    0x8(%ebp),%eax
}
 390:	c9                   	leave  
 391:	c3                   	ret    

00000392 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 392:	b8 01 00 00 00       	mov    $0x1,%eax
 397:	cd 40                	int    $0x40
 399:	c3                   	ret    

0000039a <exit>:
SYSCALL(exit)
 39a:	b8 02 00 00 00       	mov    $0x2,%eax
 39f:	cd 40                	int    $0x40
 3a1:	c3                   	ret    

000003a2 <wait>:
SYSCALL(wait)
 3a2:	b8 03 00 00 00       	mov    $0x3,%eax
 3a7:	cd 40                	int    $0x40
 3a9:	c3                   	ret    

000003aa <pipe>:
SYSCALL(pipe)
 3aa:	b8 04 00 00 00       	mov    $0x4,%eax
 3af:	cd 40                	int    $0x40
 3b1:	c3                   	ret    

000003b2 <read>:
SYSCALL(read)
 3b2:	b8 05 00 00 00       	mov    $0x5,%eax
 3b7:	cd 40                	int    $0x40
 3b9:	c3                   	ret    

000003ba <write>:
SYSCALL(write)
 3ba:	b8 10 00 00 00       	mov    $0x10,%eax
 3bf:	cd 40                	int    $0x40
 3c1:	c3                   	ret    

000003c2 <close>:
SYSCALL(close)
 3c2:	b8 15 00 00 00       	mov    $0x15,%eax
 3c7:	cd 40                	int    $0x40
 3c9:	c3                   	ret    

000003ca <kill>:
SYSCALL(kill)
 3ca:	b8 06 00 00 00       	mov    $0x6,%eax
 3cf:	cd 40                	int    $0x40
 3d1:	c3                   	ret    

000003d2 <exec>:
SYSCALL(exec)
 3d2:	b8 07 00 00 00       	mov    $0x7,%eax
 3d7:	cd 40                	int    $0x40
 3d9:	c3                   	ret    

000003da <open>:
SYSCALL(open)
 3da:	b8 0f 00 00 00       	mov    $0xf,%eax
 3df:	cd 40                	int    $0x40
 3e1:	c3                   	ret    

000003e2 <mknod>:
SYSCALL(mknod)
 3e2:	b8 11 00 00 00       	mov    $0x11,%eax
 3e7:	cd 40                	int    $0x40
 3e9:	c3                   	ret    

000003ea <unlink>:
SYSCALL(unlink)
 3ea:	b8 12 00 00 00       	mov    $0x12,%eax
 3ef:	cd 40                	int    $0x40
 3f1:	c3                   	ret    

000003f2 <fstat>:
SYSCALL(fstat)
 3f2:	b8 08 00 00 00       	mov    $0x8,%eax
 3f7:	cd 40                	int    $0x40
 3f9:	c3                   	ret    

000003fa <link>:
SYSCALL(link)
 3fa:	b8 13 00 00 00       	mov    $0x13,%eax
 3ff:	cd 40                	int    $0x40
 401:	c3                   	ret    

00000402 <mkdir>:
SYSCALL(mkdir)
 402:	b8 14 00 00 00       	mov    $0x14,%eax
 407:	cd 40                	int    $0x40
 409:	c3                   	ret    

0000040a <chdir>:
SYSCALL(chdir)
 40a:	b8 09 00 00 00       	mov    $0x9,%eax
 40f:	cd 40                	int    $0x40
 411:	c3                   	ret    

00000412 <dup>:
SYSCALL(dup)
 412:	b8 0a 00 00 00       	mov    $0xa,%eax
 417:	cd 40                	int    $0x40
 419:	c3                   	ret    

0000041a <getpid>:
SYSCALL(getpid)
 41a:	b8 0b 00 00 00       	mov    $0xb,%eax
 41f:	cd 40                	int    $0x40
 421:	c3                   	ret    

00000422 <sbrk>:
SYSCALL(sbrk)
 422:	b8 0c 00 00 00       	mov    $0xc,%eax
 427:	cd 40                	int    $0x40
 429:	c3                   	ret    

0000042a <sleep>:
SYSCALL(sleep)
 42a:	b8 0d 00 00 00       	mov    $0xd,%eax
 42f:	cd 40                	int    $0x40
 431:	c3                   	ret    

00000432 <uptime>:
SYSCALL(uptime)
 432:	b8 0e 00 00 00       	mov    $0xe,%eax
 437:	cd 40                	int    $0x40
 439:	c3                   	ret    

0000043a <hw>:
SYSCALL(hw)
 43a:	b8 16 00 00 00       	mov    $0x16,%eax
 43f:	cd 40                	int    $0x40
 441:	c3                   	ret    

00000442 <fkc>:
SYSCALL(fkc)
 442:	b8 17 00 00 00       	mov    $0x17,%eax
 447:	cd 40                	int    $0x40
 449:	c3                   	ret    

0000044a <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 44a:	55                   	push   %ebp
 44b:	89 e5                	mov    %esp,%ebp
 44d:	83 ec 18             	sub    $0x18,%esp
 450:	8b 45 0c             	mov    0xc(%ebp),%eax
 453:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 456:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 45d:	00 
 45e:	8d 45 f4             	lea    -0xc(%ebp),%eax
 461:	89 44 24 04          	mov    %eax,0x4(%esp)
 465:	8b 45 08             	mov    0x8(%ebp),%eax
 468:	89 04 24             	mov    %eax,(%esp)
 46b:	e8 4a ff ff ff       	call   3ba <write>
}
 470:	c9                   	leave  
 471:	c3                   	ret    

00000472 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 472:	55                   	push   %ebp
 473:	89 e5                	mov    %esp,%ebp
 475:	56                   	push   %esi
 476:	53                   	push   %ebx
 477:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 47a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 481:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 485:	74 17                	je     49e <printint+0x2c>
 487:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 48b:	79 11                	jns    49e <printint+0x2c>
    neg = 1;
 48d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 494:	8b 45 0c             	mov    0xc(%ebp),%eax
 497:	f7 d8                	neg    %eax
 499:	89 45 ec             	mov    %eax,-0x14(%ebp)
 49c:	eb 06                	jmp    4a4 <printint+0x32>
  } else {
    x = xx;
 49e:	8b 45 0c             	mov    0xc(%ebp),%eax
 4a1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 4a4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 4ab:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 4ae:	8d 41 01             	lea    0x1(%ecx),%eax
 4b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
 4b4:	8b 5d 10             	mov    0x10(%ebp),%ebx
 4b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4ba:	ba 00 00 00 00       	mov    $0x0,%edx
 4bf:	f7 f3                	div    %ebx
 4c1:	89 d0                	mov    %edx,%eax
 4c3:	0f b6 80 f8 0b 00 00 	movzbl 0xbf8(%eax),%eax
 4ca:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 4ce:	8b 75 10             	mov    0x10(%ebp),%esi
 4d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4d4:	ba 00 00 00 00       	mov    $0x0,%edx
 4d9:	f7 f6                	div    %esi
 4db:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4de:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4e2:	75 c7                	jne    4ab <printint+0x39>
  if(neg)
 4e4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4e8:	74 10                	je     4fa <printint+0x88>
    buf[i++] = '-';
 4ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4ed:	8d 50 01             	lea    0x1(%eax),%edx
 4f0:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4f3:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 4f8:	eb 1f                	jmp    519 <printint+0xa7>
 4fa:	eb 1d                	jmp    519 <printint+0xa7>
    putc(fd, buf[i]);
 4fc:	8d 55 dc             	lea    -0x24(%ebp),%edx
 4ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
 502:	01 d0                	add    %edx,%eax
 504:	0f b6 00             	movzbl (%eax),%eax
 507:	0f be c0             	movsbl %al,%eax
 50a:	89 44 24 04          	mov    %eax,0x4(%esp)
 50e:	8b 45 08             	mov    0x8(%ebp),%eax
 511:	89 04 24             	mov    %eax,(%esp)
 514:	e8 31 ff ff ff       	call   44a <putc>
  while(--i >= 0)
 519:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 51d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 521:	79 d9                	jns    4fc <printint+0x8a>
}
 523:	83 c4 30             	add    $0x30,%esp
 526:	5b                   	pop    %ebx
 527:	5e                   	pop    %esi
 528:	5d                   	pop    %ebp
 529:	c3                   	ret    

0000052a <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 52a:	55                   	push   %ebp
 52b:	89 e5                	mov    %esp,%ebp
 52d:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 530:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 537:	8d 45 0c             	lea    0xc(%ebp),%eax
 53a:	83 c0 04             	add    $0x4,%eax
 53d:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 540:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 547:	e9 7c 01 00 00       	jmp    6c8 <printf+0x19e>
    c = fmt[i] & 0xff;
 54c:	8b 55 0c             	mov    0xc(%ebp),%edx
 54f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 552:	01 d0                	add    %edx,%eax
 554:	0f b6 00             	movzbl (%eax),%eax
 557:	0f be c0             	movsbl %al,%eax
 55a:	25 ff 00 00 00       	and    $0xff,%eax
 55f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 562:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 566:	75 2c                	jne    594 <printf+0x6a>
      if(c == '%'){
 568:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 56c:	75 0c                	jne    57a <printf+0x50>
        state = '%';
 56e:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 575:	e9 4a 01 00 00       	jmp    6c4 <printf+0x19a>
      } else {
        putc(fd, c);
 57a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 57d:	0f be c0             	movsbl %al,%eax
 580:	89 44 24 04          	mov    %eax,0x4(%esp)
 584:	8b 45 08             	mov    0x8(%ebp),%eax
 587:	89 04 24             	mov    %eax,(%esp)
 58a:	e8 bb fe ff ff       	call   44a <putc>
 58f:	e9 30 01 00 00       	jmp    6c4 <printf+0x19a>
      }
    } else if(state == '%'){
 594:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 598:	0f 85 26 01 00 00    	jne    6c4 <printf+0x19a>
      if(c == 'd'){
 59e:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 5a2:	75 2d                	jne    5d1 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 5a4:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5a7:	8b 00                	mov    (%eax),%eax
 5a9:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 5b0:	00 
 5b1:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 5b8:	00 
 5b9:	89 44 24 04          	mov    %eax,0x4(%esp)
 5bd:	8b 45 08             	mov    0x8(%ebp),%eax
 5c0:	89 04 24             	mov    %eax,(%esp)
 5c3:	e8 aa fe ff ff       	call   472 <printint>
        ap++;
 5c8:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5cc:	e9 ec 00 00 00       	jmp    6bd <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 5d1:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5d5:	74 06                	je     5dd <printf+0xb3>
 5d7:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5db:	75 2d                	jne    60a <printf+0xe0>
        printint(fd, *ap, 16, 0);
 5dd:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5e0:	8b 00                	mov    (%eax),%eax
 5e2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 5e9:	00 
 5ea:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 5f1:	00 
 5f2:	89 44 24 04          	mov    %eax,0x4(%esp)
 5f6:	8b 45 08             	mov    0x8(%ebp),%eax
 5f9:	89 04 24             	mov    %eax,(%esp)
 5fc:	e8 71 fe ff ff       	call   472 <printint>
        ap++;
 601:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 605:	e9 b3 00 00 00       	jmp    6bd <printf+0x193>
      } else if(c == 's'){
 60a:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 60e:	75 45                	jne    655 <printf+0x12b>
        s = (char*)*ap;
 610:	8b 45 e8             	mov    -0x18(%ebp),%eax
 613:	8b 00                	mov    (%eax),%eax
 615:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 618:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 61c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 620:	75 09                	jne    62b <printf+0x101>
          s = "(null)";
 622:	c7 45 f4 ac 09 00 00 	movl   $0x9ac,-0xc(%ebp)
        while(*s != 0){
 629:	eb 1e                	jmp    649 <printf+0x11f>
 62b:	eb 1c                	jmp    649 <printf+0x11f>
          putc(fd, *s);
 62d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 630:	0f b6 00             	movzbl (%eax),%eax
 633:	0f be c0             	movsbl %al,%eax
 636:	89 44 24 04          	mov    %eax,0x4(%esp)
 63a:	8b 45 08             	mov    0x8(%ebp),%eax
 63d:	89 04 24             	mov    %eax,(%esp)
 640:	e8 05 fe ff ff       	call   44a <putc>
          s++;
 645:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 649:	8b 45 f4             	mov    -0xc(%ebp),%eax
 64c:	0f b6 00             	movzbl (%eax),%eax
 64f:	84 c0                	test   %al,%al
 651:	75 da                	jne    62d <printf+0x103>
 653:	eb 68                	jmp    6bd <printf+0x193>
        }
      } else if(c == 'c'){
 655:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 659:	75 1d                	jne    678 <printf+0x14e>
        putc(fd, *ap);
 65b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 65e:	8b 00                	mov    (%eax),%eax
 660:	0f be c0             	movsbl %al,%eax
 663:	89 44 24 04          	mov    %eax,0x4(%esp)
 667:	8b 45 08             	mov    0x8(%ebp),%eax
 66a:	89 04 24             	mov    %eax,(%esp)
 66d:	e8 d8 fd ff ff       	call   44a <putc>
        ap++;
 672:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 676:	eb 45                	jmp    6bd <printf+0x193>
      } else if(c == '%'){
 678:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 67c:	75 17                	jne    695 <printf+0x16b>
        putc(fd, c);
 67e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 681:	0f be c0             	movsbl %al,%eax
 684:	89 44 24 04          	mov    %eax,0x4(%esp)
 688:	8b 45 08             	mov    0x8(%ebp),%eax
 68b:	89 04 24             	mov    %eax,(%esp)
 68e:	e8 b7 fd ff ff       	call   44a <putc>
 693:	eb 28                	jmp    6bd <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 695:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 69c:	00 
 69d:	8b 45 08             	mov    0x8(%ebp),%eax
 6a0:	89 04 24             	mov    %eax,(%esp)
 6a3:	e8 a2 fd ff ff       	call   44a <putc>
        putc(fd, c);
 6a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6ab:	0f be c0             	movsbl %al,%eax
 6ae:	89 44 24 04          	mov    %eax,0x4(%esp)
 6b2:	8b 45 08             	mov    0x8(%ebp),%eax
 6b5:	89 04 24             	mov    %eax,(%esp)
 6b8:	e8 8d fd ff ff       	call   44a <putc>
      }
      state = 0;
 6bd:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 6c4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 6c8:	8b 55 0c             	mov    0xc(%ebp),%edx
 6cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6ce:	01 d0                	add    %edx,%eax
 6d0:	0f b6 00             	movzbl (%eax),%eax
 6d3:	84 c0                	test   %al,%al
 6d5:	0f 85 71 fe ff ff    	jne    54c <printf+0x22>
    }
  }
}
 6db:	c9                   	leave  
 6dc:	c3                   	ret    

000006dd <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6dd:	55                   	push   %ebp
 6de:	89 e5                	mov    %esp,%ebp
 6e0:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6e3:	8b 45 08             	mov    0x8(%ebp),%eax
 6e6:	83 e8 08             	sub    $0x8,%eax
 6e9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6ec:	a1 14 0c 00 00       	mov    0xc14,%eax
 6f1:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6f4:	eb 24                	jmp    71a <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f9:	8b 00                	mov    (%eax),%eax
 6fb:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6fe:	77 12                	ja     712 <free+0x35>
 700:	8b 45 f8             	mov    -0x8(%ebp),%eax
 703:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 706:	77 24                	ja     72c <free+0x4f>
 708:	8b 45 fc             	mov    -0x4(%ebp),%eax
 70b:	8b 00                	mov    (%eax),%eax
 70d:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 710:	77 1a                	ja     72c <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 712:	8b 45 fc             	mov    -0x4(%ebp),%eax
 715:	8b 00                	mov    (%eax),%eax
 717:	89 45 fc             	mov    %eax,-0x4(%ebp)
 71a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 71d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 720:	76 d4                	jbe    6f6 <free+0x19>
 722:	8b 45 fc             	mov    -0x4(%ebp),%eax
 725:	8b 00                	mov    (%eax),%eax
 727:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 72a:	76 ca                	jbe    6f6 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 72c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 72f:	8b 40 04             	mov    0x4(%eax),%eax
 732:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 739:	8b 45 f8             	mov    -0x8(%ebp),%eax
 73c:	01 c2                	add    %eax,%edx
 73e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 741:	8b 00                	mov    (%eax),%eax
 743:	39 c2                	cmp    %eax,%edx
 745:	75 24                	jne    76b <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 747:	8b 45 f8             	mov    -0x8(%ebp),%eax
 74a:	8b 50 04             	mov    0x4(%eax),%edx
 74d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 750:	8b 00                	mov    (%eax),%eax
 752:	8b 40 04             	mov    0x4(%eax),%eax
 755:	01 c2                	add    %eax,%edx
 757:	8b 45 f8             	mov    -0x8(%ebp),%eax
 75a:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 75d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 760:	8b 00                	mov    (%eax),%eax
 762:	8b 10                	mov    (%eax),%edx
 764:	8b 45 f8             	mov    -0x8(%ebp),%eax
 767:	89 10                	mov    %edx,(%eax)
 769:	eb 0a                	jmp    775 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 76b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 76e:	8b 10                	mov    (%eax),%edx
 770:	8b 45 f8             	mov    -0x8(%ebp),%eax
 773:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 775:	8b 45 fc             	mov    -0x4(%ebp),%eax
 778:	8b 40 04             	mov    0x4(%eax),%eax
 77b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 782:	8b 45 fc             	mov    -0x4(%ebp),%eax
 785:	01 d0                	add    %edx,%eax
 787:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 78a:	75 20                	jne    7ac <free+0xcf>
    p->s.size += bp->s.size;
 78c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 78f:	8b 50 04             	mov    0x4(%eax),%edx
 792:	8b 45 f8             	mov    -0x8(%ebp),%eax
 795:	8b 40 04             	mov    0x4(%eax),%eax
 798:	01 c2                	add    %eax,%edx
 79a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 79d:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 7a0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7a3:	8b 10                	mov    (%eax),%edx
 7a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a8:	89 10                	mov    %edx,(%eax)
 7aa:	eb 08                	jmp    7b4 <free+0xd7>
  } else
    p->s.ptr = bp;
 7ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7af:	8b 55 f8             	mov    -0x8(%ebp),%edx
 7b2:	89 10                	mov    %edx,(%eax)
  freep = p;
 7b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b7:	a3 14 0c 00 00       	mov    %eax,0xc14
}
 7bc:	c9                   	leave  
 7bd:	c3                   	ret    

000007be <morecore>:

static Header*
morecore(uint nu)
{
 7be:	55                   	push   %ebp
 7bf:	89 e5                	mov    %esp,%ebp
 7c1:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 7c4:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 7cb:	77 07                	ja     7d4 <morecore+0x16>
    nu = 4096;
 7cd:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7d4:	8b 45 08             	mov    0x8(%ebp),%eax
 7d7:	c1 e0 03             	shl    $0x3,%eax
 7da:	89 04 24             	mov    %eax,(%esp)
 7dd:	e8 40 fc ff ff       	call   422 <sbrk>
 7e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7e5:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7e9:	75 07                	jne    7f2 <morecore+0x34>
    return 0;
 7eb:	b8 00 00 00 00       	mov    $0x0,%eax
 7f0:	eb 22                	jmp    814 <morecore+0x56>
  hp = (Header*)p;
 7f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 7f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7fb:	8b 55 08             	mov    0x8(%ebp),%edx
 7fe:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 801:	8b 45 f0             	mov    -0x10(%ebp),%eax
 804:	83 c0 08             	add    $0x8,%eax
 807:	89 04 24             	mov    %eax,(%esp)
 80a:	e8 ce fe ff ff       	call   6dd <free>
  return freep;
 80f:	a1 14 0c 00 00       	mov    0xc14,%eax
}
 814:	c9                   	leave  
 815:	c3                   	ret    

00000816 <malloc>:

void*
malloc(uint nbytes)
{
 816:	55                   	push   %ebp
 817:	89 e5                	mov    %esp,%ebp
 819:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 81c:	8b 45 08             	mov    0x8(%ebp),%eax
 81f:	83 c0 07             	add    $0x7,%eax
 822:	c1 e8 03             	shr    $0x3,%eax
 825:	83 c0 01             	add    $0x1,%eax
 828:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 82b:	a1 14 0c 00 00       	mov    0xc14,%eax
 830:	89 45 f0             	mov    %eax,-0x10(%ebp)
 833:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 837:	75 23                	jne    85c <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 839:	c7 45 f0 0c 0c 00 00 	movl   $0xc0c,-0x10(%ebp)
 840:	8b 45 f0             	mov    -0x10(%ebp),%eax
 843:	a3 14 0c 00 00       	mov    %eax,0xc14
 848:	a1 14 0c 00 00       	mov    0xc14,%eax
 84d:	a3 0c 0c 00 00       	mov    %eax,0xc0c
    base.s.size = 0;
 852:	c7 05 10 0c 00 00 00 	movl   $0x0,0xc10
 859:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 85c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 85f:	8b 00                	mov    (%eax),%eax
 861:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 864:	8b 45 f4             	mov    -0xc(%ebp),%eax
 867:	8b 40 04             	mov    0x4(%eax),%eax
 86a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 86d:	72 4d                	jb     8bc <malloc+0xa6>
      if(p->s.size == nunits)
 86f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 872:	8b 40 04             	mov    0x4(%eax),%eax
 875:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 878:	75 0c                	jne    886 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 87a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 87d:	8b 10                	mov    (%eax),%edx
 87f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 882:	89 10                	mov    %edx,(%eax)
 884:	eb 26                	jmp    8ac <malloc+0x96>
      else {
        p->s.size -= nunits;
 886:	8b 45 f4             	mov    -0xc(%ebp),%eax
 889:	8b 40 04             	mov    0x4(%eax),%eax
 88c:	2b 45 ec             	sub    -0x14(%ebp),%eax
 88f:	89 c2                	mov    %eax,%edx
 891:	8b 45 f4             	mov    -0xc(%ebp),%eax
 894:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 897:	8b 45 f4             	mov    -0xc(%ebp),%eax
 89a:	8b 40 04             	mov    0x4(%eax),%eax
 89d:	c1 e0 03             	shl    $0x3,%eax
 8a0:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 8a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a6:	8b 55 ec             	mov    -0x14(%ebp),%edx
 8a9:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 8ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8af:	a3 14 0c 00 00       	mov    %eax,0xc14
      return (void*)(p + 1);
 8b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8b7:	83 c0 08             	add    $0x8,%eax
 8ba:	eb 38                	jmp    8f4 <malloc+0xde>
    }
    if(p == freep)
 8bc:	a1 14 0c 00 00       	mov    0xc14,%eax
 8c1:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 8c4:	75 1b                	jne    8e1 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 8c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8c9:	89 04 24             	mov    %eax,(%esp)
 8cc:	e8 ed fe ff ff       	call   7be <morecore>
 8d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8d4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8d8:	75 07                	jne    8e1 <malloc+0xcb>
        return 0;
 8da:	b8 00 00 00 00       	mov    $0x0,%eax
 8df:	eb 13                	jmp    8f4 <malloc+0xde>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ea:	8b 00                	mov    (%eax),%eax
 8ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
 8ef:	e9 70 ff ff ff       	jmp    864 <malloc+0x4e>
}
 8f4:	c9                   	leave  
 8f5:	c3                   	ret    
