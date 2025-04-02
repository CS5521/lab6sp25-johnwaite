
_cat:     file format elf32-i386


Disassembly of section .text:

00000000 <cat>:

char buf[512];

void
cat(int fd)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 28             	sub    $0x28,%esp
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0) {
   6:	eb 39                	jmp    41 <cat+0x41>
    if (write(1, buf, n) != n) {
   8:	8b 45 f4             	mov    -0xc(%ebp),%eax
   b:	89 44 24 08          	mov    %eax,0x8(%esp)
   f:	c7 44 24 04 e0 0b 00 	movl   $0xbe0,0x4(%esp)
  16:	00 
  17:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1e:	e8 a0 03 00 00       	call   3c3 <write>
  23:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  26:	74 19                	je     41 <cat+0x41>
      printf(1, "cat: write error\n");
  28:	c7 44 24 04 ff 08 00 	movl   $0x8ff,0x4(%esp)
  2f:	00 
  30:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  37:	e8 f7 04 00 00       	call   533 <printf>
      exit();
  3c:	e8 62 03 00 00       	call   3a3 <exit>
  while((n = read(fd, buf, sizeof(buf))) > 0) {
  41:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  48:	00 
  49:	c7 44 24 04 e0 0b 00 	movl   $0xbe0,0x4(%esp)
  50:	00 
  51:	8b 45 08             	mov    0x8(%ebp),%eax
  54:	89 04 24             	mov    %eax,(%esp)
  57:	e8 5f 03 00 00       	call   3bb <read>
  5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  5f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  63:	7f a3                	jg     8 <cat+0x8>
    }
  }
  if(n < 0){
  65:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  69:	79 19                	jns    84 <cat+0x84>
    printf(1, "cat: read error\n");
  6b:	c7 44 24 04 11 09 00 	movl   $0x911,0x4(%esp)
  72:	00 
  73:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  7a:	e8 b4 04 00 00       	call   533 <printf>
    exit();
  7f:	e8 1f 03 00 00       	call   3a3 <exit>
  }
}
  84:	c9                   	leave  
  85:	c3                   	ret    

00000086 <main>:

int
main(int argc, char *argv[])
{
  86:	55                   	push   %ebp
  87:	89 e5                	mov    %esp,%ebp
  89:	83 e4 f0             	and    $0xfffffff0,%esp
  8c:	83 ec 20             	sub    $0x20,%esp
  int fd, i;

  if(argc <= 1){
  8f:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  93:	7f 11                	jg     a6 <main+0x20>
    cat(0);
  95:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  9c:	e8 5f ff ff ff       	call   0 <cat>
    exit();
  a1:	e8 fd 02 00 00       	call   3a3 <exit>
  }

  for(i = 1; i < argc; i++){
  a6:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
  ad:	00 
  ae:	eb 79                	jmp    129 <main+0xa3>
    if((fd = open(argv[i], 0)) < 0){
  b0:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  b4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  be:	01 d0                	add    %edx,%eax
  c0:	8b 00                	mov    (%eax),%eax
  c2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  c9:	00 
  ca:	89 04 24             	mov    %eax,(%esp)
  cd:	e8 11 03 00 00       	call   3e3 <open>
  d2:	89 44 24 18          	mov    %eax,0x18(%esp)
  d6:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
  db:	79 2f                	jns    10c <main+0x86>
      printf(1, "cat: cannot open %s\n", argv[i]);
  dd:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  e1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  eb:	01 d0                	add    %edx,%eax
  ed:	8b 00                	mov    (%eax),%eax
  ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  f3:	c7 44 24 04 22 09 00 	movl   $0x922,0x4(%esp)
  fa:	00 
  fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 102:	e8 2c 04 00 00       	call   533 <printf>
      exit();
 107:	e8 97 02 00 00       	call   3a3 <exit>
    }
    cat(fd);
 10c:	8b 44 24 18          	mov    0x18(%esp),%eax
 110:	89 04 24             	mov    %eax,(%esp)
 113:	e8 e8 fe ff ff       	call   0 <cat>
    close(fd);
 118:	8b 44 24 18          	mov    0x18(%esp),%eax
 11c:	89 04 24             	mov    %eax,(%esp)
 11f:	e8 a7 02 00 00       	call   3cb <close>
  for(i = 1; i < argc; i++){
 124:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
 129:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 12d:	3b 45 08             	cmp    0x8(%ebp),%eax
 130:	0f 8c 7a ff ff ff    	jl     b0 <main+0x2a>
  }
  exit();
 136:	e8 68 02 00 00       	call   3a3 <exit>

0000013b <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 13b:	55                   	push   %ebp
 13c:	89 e5                	mov    %esp,%ebp
 13e:	57                   	push   %edi
 13f:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 140:	8b 4d 08             	mov    0x8(%ebp),%ecx
 143:	8b 55 10             	mov    0x10(%ebp),%edx
 146:	8b 45 0c             	mov    0xc(%ebp),%eax
 149:	89 cb                	mov    %ecx,%ebx
 14b:	89 df                	mov    %ebx,%edi
 14d:	89 d1                	mov    %edx,%ecx
 14f:	fc                   	cld    
 150:	f3 aa                	rep stos %al,%es:(%edi)
 152:	89 ca                	mov    %ecx,%edx
 154:	89 fb                	mov    %edi,%ebx
 156:	89 5d 08             	mov    %ebx,0x8(%ebp)
 159:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 15c:	5b                   	pop    %ebx
 15d:	5f                   	pop    %edi
 15e:	5d                   	pop    %ebp
 15f:	c3                   	ret    

00000160 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 160:	55                   	push   %ebp
 161:	89 e5                	mov    %esp,%ebp
 163:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 166:	8b 45 08             	mov    0x8(%ebp),%eax
 169:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 16c:	90                   	nop
 16d:	8b 45 08             	mov    0x8(%ebp),%eax
 170:	8d 50 01             	lea    0x1(%eax),%edx
 173:	89 55 08             	mov    %edx,0x8(%ebp)
 176:	8b 55 0c             	mov    0xc(%ebp),%edx
 179:	8d 4a 01             	lea    0x1(%edx),%ecx
 17c:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 17f:	0f b6 12             	movzbl (%edx),%edx
 182:	88 10                	mov    %dl,(%eax)
 184:	0f b6 00             	movzbl (%eax),%eax
 187:	84 c0                	test   %al,%al
 189:	75 e2                	jne    16d <strcpy+0xd>
    ;
  return os;
 18b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 18e:	c9                   	leave  
 18f:	c3                   	ret    

00000190 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 190:	55                   	push   %ebp
 191:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 193:	eb 08                	jmp    19d <strcmp+0xd>
    p++, q++;
 195:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 199:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 19d:	8b 45 08             	mov    0x8(%ebp),%eax
 1a0:	0f b6 00             	movzbl (%eax),%eax
 1a3:	84 c0                	test   %al,%al
 1a5:	74 10                	je     1b7 <strcmp+0x27>
 1a7:	8b 45 08             	mov    0x8(%ebp),%eax
 1aa:	0f b6 10             	movzbl (%eax),%edx
 1ad:	8b 45 0c             	mov    0xc(%ebp),%eax
 1b0:	0f b6 00             	movzbl (%eax),%eax
 1b3:	38 c2                	cmp    %al,%dl
 1b5:	74 de                	je     195 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 1b7:	8b 45 08             	mov    0x8(%ebp),%eax
 1ba:	0f b6 00             	movzbl (%eax),%eax
 1bd:	0f b6 d0             	movzbl %al,%edx
 1c0:	8b 45 0c             	mov    0xc(%ebp),%eax
 1c3:	0f b6 00             	movzbl (%eax),%eax
 1c6:	0f b6 c0             	movzbl %al,%eax
 1c9:	29 c2                	sub    %eax,%edx
 1cb:	89 d0                	mov    %edx,%eax
}
 1cd:	5d                   	pop    %ebp
 1ce:	c3                   	ret    

000001cf <strlen>:

uint
strlen(const char *s)
{
 1cf:	55                   	push   %ebp
 1d0:	89 e5                	mov    %esp,%ebp
 1d2:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1d5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1dc:	eb 04                	jmp    1e2 <strlen+0x13>
 1de:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1e2:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1e5:	8b 45 08             	mov    0x8(%ebp),%eax
 1e8:	01 d0                	add    %edx,%eax
 1ea:	0f b6 00             	movzbl (%eax),%eax
 1ed:	84 c0                	test   %al,%al
 1ef:	75 ed                	jne    1de <strlen+0xf>
    ;
  return n;
 1f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1f4:	c9                   	leave  
 1f5:	c3                   	ret    

000001f6 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1f6:	55                   	push   %ebp
 1f7:	89 e5                	mov    %esp,%ebp
 1f9:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 1fc:	8b 45 10             	mov    0x10(%ebp),%eax
 1ff:	89 44 24 08          	mov    %eax,0x8(%esp)
 203:	8b 45 0c             	mov    0xc(%ebp),%eax
 206:	89 44 24 04          	mov    %eax,0x4(%esp)
 20a:	8b 45 08             	mov    0x8(%ebp),%eax
 20d:	89 04 24             	mov    %eax,(%esp)
 210:	e8 26 ff ff ff       	call   13b <stosb>
  return dst;
 215:	8b 45 08             	mov    0x8(%ebp),%eax
}
 218:	c9                   	leave  
 219:	c3                   	ret    

0000021a <strchr>:

char*
strchr(const char *s, char c)
{
 21a:	55                   	push   %ebp
 21b:	89 e5                	mov    %esp,%ebp
 21d:	83 ec 04             	sub    $0x4,%esp
 220:	8b 45 0c             	mov    0xc(%ebp),%eax
 223:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 226:	eb 14                	jmp    23c <strchr+0x22>
    if(*s == c)
 228:	8b 45 08             	mov    0x8(%ebp),%eax
 22b:	0f b6 00             	movzbl (%eax),%eax
 22e:	3a 45 fc             	cmp    -0x4(%ebp),%al
 231:	75 05                	jne    238 <strchr+0x1e>
      return (char*)s;
 233:	8b 45 08             	mov    0x8(%ebp),%eax
 236:	eb 13                	jmp    24b <strchr+0x31>
  for(; *s; s++)
 238:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 23c:	8b 45 08             	mov    0x8(%ebp),%eax
 23f:	0f b6 00             	movzbl (%eax),%eax
 242:	84 c0                	test   %al,%al
 244:	75 e2                	jne    228 <strchr+0xe>
  return 0;
 246:	b8 00 00 00 00       	mov    $0x0,%eax
}
 24b:	c9                   	leave  
 24c:	c3                   	ret    

0000024d <gets>:

char*
gets(char *buf, int max)
{
 24d:	55                   	push   %ebp
 24e:	89 e5                	mov    %esp,%ebp
 250:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 253:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 25a:	eb 4c                	jmp    2a8 <gets+0x5b>
    cc = read(0, &c, 1);
 25c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 263:	00 
 264:	8d 45 ef             	lea    -0x11(%ebp),%eax
 267:	89 44 24 04          	mov    %eax,0x4(%esp)
 26b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 272:	e8 44 01 00 00       	call   3bb <read>
 277:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 27a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 27e:	7f 02                	jg     282 <gets+0x35>
      break;
 280:	eb 31                	jmp    2b3 <gets+0x66>
    buf[i++] = c;
 282:	8b 45 f4             	mov    -0xc(%ebp),%eax
 285:	8d 50 01             	lea    0x1(%eax),%edx
 288:	89 55 f4             	mov    %edx,-0xc(%ebp)
 28b:	89 c2                	mov    %eax,%edx
 28d:	8b 45 08             	mov    0x8(%ebp),%eax
 290:	01 c2                	add    %eax,%edx
 292:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 296:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 298:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 29c:	3c 0a                	cmp    $0xa,%al
 29e:	74 13                	je     2b3 <gets+0x66>
 2a0:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2a4:	3c 0d                	cmp    $0xd,%al
 2a6:	74 0b                	je     2b3 <gets+0x66>
  for(i=0; i+1 < max; ){
 2a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2ab:	83 c0 01             	add    $0x1,%eax
 2ae:	3b 45 0c             	cmp    0xc(%ebp),%eax
 2b1:	7c a9                	jl     25c <gets+0xf>
      break;
  }
  buf[i] = '\0';
 2b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
 2b6:	8b 45 08             	mov    0x8(%ebp),%eax
 2b9:	01 d0                	add    %edx,%eax
 2bb:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 2be:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2c1:	c9                   	leave  
 2c2:	c3                   	ret    

000002c3 <stat>:

int
stat(const char *n, struct stat *st)
{
 2c3:	55                   	push   %ebp
 2c4:	89 e5                	mov    %esp,%ebp
 2c6:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2c9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 2d0:	00 
 2d1:	8b 45 08             	mov    0x8(%ebp),%eax
 2d4:	89 04 24             	mov    %eax,(%esp)
 2d7:	e8 07 01 00 00       	call   3e3 <open>
 2dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2df:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2e3:	79 07                	jns    2ec <stat+0x29>
    return -1;
 2e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2ea:	eb 23                	jmp    30f <stat+0x4c>
  r = fstat(fd, st);
 2ec:	8b 45 0c             	mov    0xc(%ebp),%eax
 2ef:	89 44 24 04          	mov    %eax,0x4(%esp)
 2f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2f6:	89 04 24             	mov    %eax,(%esp)
 2f9:	e8 fd 00 00 00       	call   3fb <fstat>
 2fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 301:	8b 45 f4             	mov    -0xc(%ebp),%eax
 304:	89 04 24             	mov    %eax,(%esp)
 307:	e8 bf 00 00 00       	call   3cb <close>
  return r;
 30c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 30f:	c9                   	leave  
 310:	c3                   	ret    

00000311 <atoi>:

int
atoi(const char *s)
{
 311:	55                   	push   %ebp
 312:	89 e5                	mov    %esp,%ebp
 314:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 317:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 31e:	eb 25                	jmp    345 <atoi+0x34>
    n = n*10 + *s++ - '0';
 320:	8b 55 fc             	mov    -0x4(%ebp),%edx
 323:	89 d0                	mov    %edx,%eax
 325:	c1 e0 02             	shl    $0x2,%eax
 328:	01 d0                	add    %edx,%eax
 32a:	01 c0                	add    %eax,%eax
 32c:	89 c1                	mov    %eax,%ecx
 32e:	8b 45 08             	mov    0x8(%ebp),%eax
 331:	8d 50 01             	lea    0x1(%eax),%edx
 334:	89 55 08             	mov    %edx,0x8(%ebp)
 337:	0f b6 00             	movzbl (%eax),%eax
 33a:	0f be c0             	movsbl %al,%eax
 33d:	01 c8                	add    %ecx,%eax
 33f:	83 e8 30             	sub    $0x30,%eax
 342:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 345:	8b 45 08             	mov    0x8(%ebp),%eax
 348:	0f b6 00             	movzbl (%eax),%eax
 34b:	3c 2f                	cmp    $0x2f,%al
 34d:	7e 0a                	jle    359 <atoi+0x48>
 34f:	8b 45 08             	mov    0x8(%ebp),%eax
 352:	0f b6 00             	movzbl (%eax),%eax
 355:	3c 39                	cmp    $0x39,%al
 357:	7e c7                	jle    320 <atoi+0xf>
  return n;
 359:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 35c:	c9                   	leave  
 35d:	c3                   	ret    

0000035e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 35e:	55                   	push   %ebp
 35f:	89 e5                	mov    %esp,%ebp
 361:	83 ec 10             	sub    $0x10,%esp
  char *dst;
  const char *src;

  dst = vdst;
 364:	8b 45 08             	mov    0x8(%ebp),%eax
 367:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 36a:	8b 45 0c             	mov    0xc(%ebp),%eax
 36d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 370:	eb 17                	jmp    389 <memmove+0x2b>
    *dst++ = *src++;
 372:	8b 45 fc             	mov    -0x4(%ebp),%eax
 375:	8d 50 01             	lea    0x1(%eax),%edx
 378:	89 55 fc             	mov    %edx,-0x4(%ebp)
 37b:	8b 55 f8             	mov    -0x8(%ebp),%edx
 37e:	8d 4a 01             	lea    0x1(%edx),%ecx
 381:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 384:	0f b6 12             	movzbl (%edx),%edx
 387:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 389:	8b 45 10             	mov    0x10(%ebp),%eax
 38c:	8d 50 ff             	lea    -0x1(%eax),%edx
 38f:	89 55 10             	mov    %edx,0x10(%ebp)
 392:	85 c0                	test   %eax,%eax
 394:	7f dc                	jg     372 <memmove+0x14>
  return vdst;
 396:	8b 45 08             	mov    0x8(%ebp),%eax
}
 399:	c9                   	leave  
 39a:	c3                   	ret    

0000039b <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 39b:	b8 01 00 00 00       	mov    $0x1,%eax
 3a0:	cd 40                	int    $0x40
 3a2:	c3                   	ret    

000003a3 <exit>:
SYSCALL(exit)
 3a3:	b8 02 00 00 00       	mov    $0x2,%eax
 3a8:	cd 40                	int    $0x40
 3aa:	c3                   	ret    

000003ab <wait>:
SYSCALL(wait)
 3ab:	b8 03 00 00 00       	mov    $0x3,%eax
 3b0:	cd 40                	int    $0x40
 3b2:	c3                   	ret    

000003b3 <pipe>:
SYSCALL(pipe)
 3b3:	b8 04 00 00 00       	mov    $0x4,%eax
 3b8:	cd 40                	int    $0x40
 3ba:	c3                   	ret    

000003bb <read>:
SYSCALL(read)
 3bb:	b8 05 00 00 00       	mov    $0x5,%eax
 3c0:	cd 40                	int    $0x40
 3c2:	c3                   	ret    

000003c3 <write>:
SYSCALL(write)
 3c3:	b8 10 00 00 00       	mov    $0x10,%eax
 3c8:	cd 40                	int    $0x40
 3ca:	c3                   	ret    

000003cb <close>:
SYSCALL(close)
 3cb:	b8 15 00 00 00       	mov    $0x15,%eax
 3d0:	cd 40                	int    $0x40
 3d2:	c3                   	ret    

000003d3 <kill>:
SYSCALL(kill)
 3d3:	b8 06 00 00 00       	mov    $0x6,%eax
 3d8:	cd 40                	int    $0x40
 3da:	c3                   	ret    

000003db <exec>:
SYSCALL(exec)
 3db:	b8 07 00 00 00       	mov    $0x7,%eax
 3e0:	cd 40                	int    $0x40
 3e2:	c3                   	ret    

000003e3 <open>:
SYSCALL(open)
 3e3:	b8 0f 00 00 00       	mov    $0xf,%eax
 3e8:	cd 40                	int    $0x40
 3ea:	c3                   	ret    

000003eb <mknod>:
SYSCALL(mknod)
 3eb:	b8 11 00 00 00       	mov    $0x11,%eax
 3f0:	cd 40                	int    $0x40
 3f2:	c3                   	ret    

000003f3 <unlink>:
SYSCALL(unlink)
 3f3:	b8 12 00 00 00       	mov    $0x12,%eax
 3f8:	cd 40                	int    $0x40
 3fa:	c3                   	ret    

000003fb <fstat>:
SYSCALL(fstat)
 3fb:	b8 08 00 00 00       	mov    $0x8,%eax
 400:	cd 40                	int    $0x40
 402:	c3                   	ret    

00000403 <link>:
SYSCALL(link)
 403:	b8 13 00 00 00       	mov    $0x13,%eax
 408:	cd 40                	int    $0x40
 40a:	c3                   	ret    

0000040b <mkdir>:
SYSCALL(mkdir)
 40b:	b8 14 00 00 00       	mov    $0x14,%eax
 410:	cd 40                	int    $0x40
 412:	c3                   	ret    

00000413 <chdir>:
SYSCALL(chdir)
 413:	b8 09 00 00 00       	mov    $0x9,%eax
 418:	cd 40                	int    $0x40
 41a:	c3                   	ret    

0000041b <dup>:
SYSCALL(dup)
 41b:	b8 0a 00 00 00       	mov    $0xa,%eax
 420:	cd 40                	int    $0x40
 422:	c3                   	ret    

00000423 <getpid>:
SYSCALL(getpid)
 423:	b8 0b 00 00 00       	mov    $0xb,%eax
 428:	cd 40                	int    $0x40
 42a:	c3                   	ret    

0000042b <sbrk>:
SYSCALL(sbrk)
 42b:	b8 0c 00 00 00       	mov    $0xc,%eax
 430:	cd 40                	int    $0x40
 432:	c3                   	ret    

00000433 <sleep>:
SYSCALL(sleep)
 433:	b8 0d 00 00 00       	mov    $0xd,%eax
 438:	cd 40                	int    $0x40
 43a:	c3                   	ret    

0000043b <uptime>:
SYSCALL(uptime)
 43b:	b8 0e 00 00 00       	mov    $0xe,%eax
 440:	cd 40                	int    $0x40
 442:	c3                   	ret    

00000443 <hw>:
SYSCALL(hw)
 443:	b8 16 00 00 00       	mov    $0x16,%eax
 448:	cd 40                	int    $0x40
 44a:	c3                   	ret    

0000044b <fkc>:
SYSCALL(fkc)
 44b:	b8 17 00 00 00       	mov    $0x17,%eax
 450:	cd 40                	int    $0x40
 452:	c3                   	ret    

00000453 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 453:	55                   	push   %ebp
 454:	89 e5                	mov    %esp,%ebp
 456:	83 ec 18             	sub    $0x18,%esp
 459:	8b 45 0c             	mov    0xc(%ebp),%eax
 45c:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 45f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 466:	00 
 467:	8d 45 f4             	lea    -0xc(%ebp),%eax
 46a:	89 44 24 04          	mov    %eax,0x4(%esp)
 46e:	8b 45 08             	mov    0x8(%ebp),%eax
 471:	89 04 24             	mov    %eax,(%esp)
 474:	e8 4a ff ff ff       	call   3c3 <write>
}
 479:	c9                   	leave  
 47a:	c3                   	ret    

0000047b <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 47b:	55                   	push   %ebp
 47c:	89 e5                	mov    %esp,%ebp
 47e:	56                   	push   %esi
 47f:	53                   	push   %ebx
 480:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 483:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 48a:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 48e:	74 17                	je     4a7 <printint+0x2c>
 490:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 494:	79 11                	jns    4a7 <printint+0x2c>
    neg = 1;
 496:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 49d:	8b 45 0c             	mov    0xc(%ebp),%eax
 4a0:	f7 d8                	neg    %eax
 4a2:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4a5:	eb 06                	jmp    4ad <printint+0x32>
  } else {
    x = xx;
 4a7:	8b 45 0c             	mov    0xc(%ebp),%eax
 4aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 4ad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 4b4:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 4b7:	8d 41 01             	lea    0x1(%ecx),%eax
 4ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
 4bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
 4c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4c3:	ba 00 00 00 00       	mov    $0x0,%edx
 4c8:	f7 f3                	div    %ebx
 4ca:	89 d0                	mov    %edx,%eax
 4cc:	0f b6 80 a4 0b 00 00 	movzbl 0xba4(%eax),%eax
 4d3:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 4d7:	8b 75 10             	mov    0x10(%ebp),%esi
 4da:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4dd:	ba 00 00 00 00       	mov    $0x0,%edx
 4e2:	f7 f6                	div    %esi
 4e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4e7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4eb:	75 c7                	jne    4b4 <printint+0x39>
  if(neg)
 4ed:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4f1:	74 10                	je     503 <printint+0x88>
    buf[i++] = '-';
 4f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4f6:	8d 50 01             	lea    0x1(%eax),%edx
 4f9:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4fc:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 501:	eb 1f                	jmp    522 <printint+0xa7>
 503:	eb 1d                	jmp    522 <printint+0xa7>
    putc(fd, buf[i]);
 505:	8d 55 dc             	lea    -0x24(%ebp),%edx
 508:	8b 45 f4             	mov    -0xc(%ebp),%eax
 50b:	01 d0                	add    %edx,%eax
 50d:	0f b6 00             	movzbl (%eax),%eax
 510:	0f be c0             	movsbl %al,%eax
 513:	89 44 24 04          	mov    %eax,0x4(%esp)
 517:	8b 45 08             	mov    0x8(%ebp),%eax
 51a:	89 04 24             	mov    %eax,(%esp)
 51d:	e8 31 ff ff ff       	call   453 <putc>
  while(--i >= 0)
 522:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 526:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 52a:	79 d9                	jns    505 <printint+0x8a>
}
 52c:	83 c4 30             	add    $0x30,%esp
 52f:	5b                   	pop    %ebx
 530:	5e                   	pop    %esi
 531:	5d                   	pop    %ebp
 532:	c3                   	ret    

00000533 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 533:	55                   	push   %ebp
 534:	89 e5                	mov    %esp,%ebp
 536:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 539:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 540:	8d 45 0c             	lea    0xc(%ebp),%eax
 543:	83 c0 04             	add    $0x4,%eax
 546:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 549:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 550:	e9 7c 01 00 00       	jmp    6d1 <printf+0x19e>
    c = fmt[i] & 0xff;
 555:	8b 55 0c             	mov    0xc(%ebp),%edx
 558:	8b 45 f0             	mov    -0x10(%ebp),%eax
 55b:	01 d0                	add    %edx,%eax
 55d:	0f b6 00             	movzbl (%eax),%eax
 560:	0f be c0             	movsbl %al,%eax
 563:	25 ff 00 00 00       	and    $0xff,%eax
 568:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 56b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 56f:	75 2c                	jne    59d <printf+0x6a>
      if(c == '%'){
 571:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 575:	75 0c                	jne    583 <printf+0x50>
        state = '%';
 577:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 57e:	e9 4a 01 00 00       	jmp    6cd <printf+0x19a>
      } else {
        putc(fd, c);
 583:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 586:	0f be c0             	movsbl %al,%eax
 589:	89 44 24 04          	mov    %eax,0x4(%esp)
 58d:	8b 45 08             	mov    0x8(%ebp),%eax
 590:	89 04 24             	mov    %eax,(%esp)
 593:	e8 bb fe ff ff       	call   453 <putc>
 598:	e9 30 01 00 00       	jmp    6cd <printf+0x19a>
      }
    } else if(state == '%'){
 59d:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 5a1:	0f 85 26 01 00 00    	jne    6cd <printf+0x19a>
      if(c == 'd'){
 5a7:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 5ab:	75 2d                	jne    5da <printf+0xa7>
        printint(fd, *ap, 10, 1);
 5ad:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5b0:	8b 00                	mov    (%eax),%eax
 5b2:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 5b9:	00 
 5ba:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 5c1:	00 
 5c2:	89 44 24 04          	mov    %eax,0x4(%esp)
 5c6:	8b 45 08             	mov    0x8(%ebp),%eax
 5c9:	89 04 24             	mov    %eax,(%esp)
 5cc:	e8 aa fe ff ff       	call   47b <printint>
        ap++;
 5d1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5d5:	e9 ec 00 00 00       	jmp    6c6 <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 5da:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5de:	74 06                	je     5e6 <printf+0xb3>
 5e0:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5e4:	75 2d                	jne    613 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 5e6:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5e9:	8b 00                	mov    (%eax),%eax
 5eb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 5f2:	00 
 5f3:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 5fa:	00 
 5fb:	89 44 24 04          	mov    %eax,0x4(%esp)
 5ff:	8b 45 08             	mov    0x8(%ebp),%eax
 602:	89 04 24             	mov    %eax,(%esp)
 605:	e8 71 fe ff ff       	call   47b <printint>
        ap++;
 60a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 60e:	e9 b3 00 00 00       	jmp    6c6 <printf+0x193>
      } else if(c == 's'){
 613:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 617:	75 45                	jne    65e <printf+0x12b>
        s = (char*)*ap;
 619:	8b 45 e8             	mov    -0x18(%ebp),%eax
 61c:	8b 00                	mov    (%eax),%eax
 61e:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 621:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 625:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 629:	75 09                	jne    634 <printf+0x101>
          s = "(null)";
 62b:	c7 45 f4 37 09 00 00 	movl   $0x937,-0xc(%ebp)
        while(*s != 0){
 632:	eb 1e                	jmp    652 <printf+0x11f>
 634:	eb 1c                	jmp    652 <printf+0x11f>
          putc(fd, *s);
 636:	8b 45 f4             	mov    -0xc(%ebp),%eax
 639:	0f b6 00             	movzbl (%eax),%eax
 63c:	0f be c0             	movsbl %al,%eax
 63f:	89 44 24 04          	mov    %eax,0x4(%esp)
 643:	8b 45 08             	mov    0x8(%ebp),%eax
 646:	89 04 24             	mov    %eax,(%esp)
 649:	e8 05 fe ff ff       	call   453 <putc>
          s++;
 64e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 652:	8b 45 f4             	mov    -0xc(%ebp),%eax
 655:	0f b6 00             	movzbl (%eax),%eax
 658:	84 c0                	test   %al,%al
 65a:	75 da                	jne    636 <printf+0x103>
 65c:	eb 68                	jmp    6c6 <printf+0x193>
        }
      } else if(c == 'c'){
 65e:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 662:	75 1d                	jne    681 <printf+0x14e>
        putc(fd, *ap);
 664:	8b 45 e8             	mov    -0x18(%ebp),%eax
 667:	8b 00                	mov    (%eax),%eax
 669:	0f be c0             	movsbl %al,%eax
 66c:	89 44 24 04          	mov    %eax,0x4(%esp)
 670:	8b 45 08             	mov    0x8(%ebp),%eax
 673:	89 04 24             	mov    %eax,(%esp)
 676:	e8 d8 fd ff ff       	call   453 <putc>
        ap++;
 67b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 67f:	eb 45                	jmp    6c6 <printf+0x193>
      } else if(c == '%'){
 681:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 685:	75 17                	jne    69e <printf+0x16b>
        putc(fd, c);
 687:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 68a:	0f be c0             	movsbl %al,%eax
 68d:	89 44 24 04          	mov    %eax,0x4(%esp)
 691:	8b 45 08             	mov    0x8(%ebp),%eax
 694:	89 04 24             	mov    %eax,(%esp)
 697:	e8 b7 fd ff ff       	call   453 <putc>
 69c:	eb 28                	jmp    6c6 <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 69e:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 6a5:	00 
 6a6:	8b 45 08             	mov    0x8(%ebp),%eax
 6a9:	89 04 24             	mov    %eax,(%esp)
 6ac:	e8 a2 fd ff ff       	call   453 <putc>
        putc(fd, c);
 6b1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6b4:	0f be c0             	movsbl %al,%eax
 6b7:	89 44 24 04          	mov    %eax,0x4(%esp)
 6bb:	8b 45 08             	mov    0x8(%ebp),%eax
 6be:	89 04 24             	mov    %eax,(%esp)
 6c1:	e8 8d fd ff ff       	call   453 <putc>
      }
      state = 0;
 6c6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 6cd:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 6d1:	8b 55 0c             	mov    0xc(%ebp),%edx
 6d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6d7:	01 d0                	add    %edx,%eax
 6d9:	0f b6 00             	movzbl (%eax),%eax
 6dc:	84 c0                	test   %al,%al
 6de:	0f 85 71 fe ff ff    	jne    555 <printf+0x22>
    }
  }
}
 6e4:	c9                   	leave  
 6e5:	c3                   	ret    

000006e6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6e6:	55                   	push   %ebp
 6e7:	89 e5                	mov    %esp,%ebp
 6e9:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6ec:	8b 45 08             	mov    0x8(%ebp),%eax
 6ef:	83 e8 08             	sub    $0x8,%eax
 6f2:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6f5:	a1 c8 0b 00 00       	mov    0xbc8,%eax
 6fa:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6fd:	eb 24                	jmp    723 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
 702:	8b 00                	mov    (%eax),%eax
 704:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 707:	77 12                	ja     71b <free+0x35>
 709:	8b 45 f8             	mov    -0x8(%ebp),%eax
 70c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 70f:	77 24                	ja     735 <free+0x4f>
 711:	8b 45 fc             	mov    -0x4(%ebp),%eax
 714:	8b 00                	mov    (%eax),%eax
 716:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 719:	77 1a                	ja     735 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 71b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 71e:	8b 00                	mov    (%eax),%eax
 720:	89 45 fc             	mov    %eax,-0x4(%ebp)
 723:	8b 45 f8             	mov    -0x8(%ebp),%eax
 726:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 729:	76 d4                	jbe    6ff <free+0x19>
 72b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 72e:	8b 00                	mov    (%eax),%eax
 730:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 733:	76 ca                	jbe    6ff <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 735:	8b 45 f8             	mov    -0x8(%ebp),%eax
 738:	8b 40 04             	mov    0x4(%eax),%eax
 73b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 742:	8b 45 f8             	mov    -0x8(%ebp),%eax
 745:	01 c2                	add    %eax,%edx
 747:	8b 45 fc             	mov    -0x4(%ebp),%eax
 74a:	8b 00                	mov    (%eax),%eax
 74c:	39 c2                	cmp    %eax,%edx
 74e:	75 24                	jne    774 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 750:	8b 45 f8             	mov    -0x8(%ebp),%eax
 753:	8b 50 04             	mov    0x4(%eax),%edx
 756:	8b 45 fc             	mov    -0x4(%ebp),%eax
 759:	8b 00                	mov    (%eax),%eax
 75b:	8b 40 04             	mov    0x4(%eax),%eax
 75e:	01 c2                	add    %eax,%edx
 760:	8b 45 f8             	mov    -0x8(%ebp),%eax
 763:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 766:	8b 45 fc             	mov    -0x4(%ebp),%eax
 769:	8b 00                	mov    (%eax),%eax
 76b:	8b 10                	mov    (%eax),%edx
 76d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 770:	89 10                	mov    %edx,(%eax)
 772:	eb 0a                	jmp    77e <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 774:	8b 45 fc             	mov    -0x4(%ebp),%eax
 777:	8b 10                	mov    (%eax),%edx
 779:	8b 45 f8             	mov    -0x8(%ebp),%eax
 77c:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 77e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 781:	8b 40 04             	mov    0x4(%eax),%eax
 784:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 78b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 78e:	01 d0                	add    %edx,%eax
 790:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 793:	75 20                	jne    7b5 <free+0xcf>
    p->s.size += bp->s.size;
 795:	8b 45 fc             	mov    -0x4(%ebp),%eax
 798:	8b 50 04             	mov    0x4(%eax),%edx
 79b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 79e:	8b 40 04             	mov    0x4(%eax),%eax
 7a1:	01 c2                	add    %eax,%edx
 7a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a6:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 7a9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ac:	8b 10                	mov    (%eax),%edx
 7ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b1:	89 10                	mov    %edx,(%eax)
 7b3:	eb 08                	jmp    7bd <free+0xd7>
  } else
    p->s.ptr = bp;
 7b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b8:	8b 55 f8             	mov    -0x8(%ebp),%edx
 7bb:	89 10                	mov    %edx,(%eax)
  freep = p;
 7bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c0:	a3 c8 0b 00 00       	mov    %eax,0xbc8
}
 7c5:	c9                   	leave  
 7c6:	c3                   	ret    

000007c7 <morecore>:

static Header*
morecore(uint nu)
{
 7c7:	55                   	push   %ebp
 7c8:	89 e5                	mov    %esp,%ebp
 7ca:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 7cd:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 7d4:	77 07                	ja     7dd <morecore+0x16>
    nu = 4096;
 7d6:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7dd:	8b 45 08             	mov    0x8(%ebp),%eax
 7e0:	c1 e0 03             	shl    $0x3,%eax
 7e3:	89 04 24             	mov    %eax,(%esp)
 7e6:	e8 40 fc ff ff       	call   42b <sbrk>
 7eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7ee:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7f2:	75 07                	jne    7fb <morecore+0x34>
    return 0;
 7f4:	b8 00 00 00 00       	mov    $0x0,%eax
 7f9:	eb 22                	jmp    81d <morecore+0x56>
  hp = (Header*)p;
 7fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 801:	8b 45 f0             	mov    -0x10(%ebp),%eax
 804:	8b 55 08             	mov    0x8(%ebp),%edx
 807:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 80a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 80d:	83 c0 08             	add    $0x8,%eax
 810:	89 04 24             	mov    %eax,(%esp)
 813:	e8 ce fe ff ff       	call   6e6 <free>
  return freep;
 818:	a1 c8 0b 00 00       	mov    0xbc8,%eax
}
 81d:	c9                   	leave  
 81e:	c3                   	ret    

0000081f <malloc>:

void*
malloc(uint nbytes)
{
 81f:	55                   	push   %ebp
 820:	89 e5                	mov    %esp,%ebp
 822:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 825:	8b 45 08             	mov    0x8(%ebp),%eax
 828:	83 c0 07             	add    $0x7,%eax
 82b:	c1 e8 03             	shr    $0x3,%eax
 82e:	83 c0 01             	add    $0x1,%eax
 831:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 834:	a1 c8 0b 00 00       	mov    0xbc8,%eax
 839:	89 45 f0             	mov    %eax,-0x10(%ebp)
 83c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 840:	75 23                	jne    865 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 842:	c7 45 f0 c0 0b 00 00 	movl   $0xbc0,-0x10(%ebp)
 849:	8b 45 f0             	mov    -0x10(%ebp),%eax
 84c:	a3 c8 0b 00 00       	mov    %eax,0xbc8
 851:	a1 c8 0b 00 00       	mov    0xbc8,%eax
 856:	a3 c0 0b 00 00       	mov    %eax,0xbc0
    base.s.size = 0;
 85b:	c7 05 c4 0b 00 00 00 	movl   $0x0,0xbc4
 862:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 865:	8b 45 f0             	mov    -0x10(%ebp),%eax
 868:	8b 00                	mov    (%eax),%eax
 86a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 86d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 870:	8b 40 04             	mov    0x4(%eax),%eax
 873:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 876:	72 4d                	jb     8c5 <malloc+0xa6>
      if(p->s.size == nunits)
 878:	8b 45 f4             	mov    -0xc(%ebp),%eax
 87b:	8b 40 04             	mov    0x4(%eax),%eax
 87e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 881:	75 0c                	jne    88f <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 883:	8b 45 f4             	mov    -0xc(%ebp),%eax
 886:	8b 10                	mov    (%eax),%edx
 888:	8b 45 f0             	mov    -0x10(%ebp),%eax
 88b:	89 10                	mov    %edx,(%eax)
 88d:	eb 26                	jmp    8b5 <malloc+0x96>
      else {
        p->s.size -= nunits;
 88f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 892:	8b 40 04             	mov    0x4(%eax),%eax
 895:	2b 45 ec             	sub    -0x14(%ebp),%eax
 898:	89 c2                	mov    %eax,%edx
 89a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 89d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 8a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a3:	8b 40 04             	mov    0x4(%eax),%eax
 8a6:	c1 e0 03             	shl    $0x3,%eax
 8a9:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 8ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8af:	8b 55 ec             	mov    -0x14(%ebp),%edx
 8b2:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 8b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8b8:	a3 c8 0b 00 00       	mov    %eax,0xbc8
      return (void*)(p + 1);
 8bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c0:	83 c0 08             	add    $0x8,%eax
 8c3:	eb 38                	jmp    8fd <malloc+0xde>
    }
    if(p == freep)
 8c5:	a1 c8 0b 00 00       	mov    0xbc8,%eax
 8ca:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 8cd:	75 1b                	jne    8ea <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 8cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8d2:	89 04 24             	mov    %eax,(%esp)
 8d5:	e8 ed fe ff ff       	call   7c7 <morecore>
 8da:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8dd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8e1:	75 07                	jne    8ea <malloc+0xcb>
        return 0;
 8e3:	b8 00 00 00 00       	mov    $0x0,%eax
 8e8:	eb 13                	jmp    8fd <malloc+0xde>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f3:	8b 00                	mov    (%eax),%eax
 8f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
 8f8:	e9 70 ff ff ff       	jmp    86d <malloc+0x4e>
}
 8fd:	c9                   	leave  
 8fe:	c3                   	ret    
