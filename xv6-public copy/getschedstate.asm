
_getschedstate:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "types.h"
#include "user.h"
#include "psched.h"
#include <stddef.h>

int main(int argc, char *argv[]) {
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	push   -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	56                   	push   %esi
   e:	53                   	push   %ebx
   f:	51                   	push   %ecx
  10:	83 ec 1c             	sub    $0x1c,%esp
    struct pschedinfo *info = (struct pschedinfo *)malloc(sizeof(struct pschedinfo));
  13:	83 ec 0c             	sub    $0xc,%esp
  16:	68 00 05 00 00       	push   $0x500
  1b:	e8 1d 07 00 00       	call   73d <malloc>
  20:	83 c4 10             	add    $0x10,%esp
  23:	89 45 e4             	mov    %eax,-0x1c(%ebp)

int res = getschedstate(info);
  26:	83 ec 0c             	sub    $0xc,%esp
  29:	ff 75 e4             	push   -0x1c(%ebp)
  2c:	e8 5c 03 00 00       	call   38d <getschedstate>
  31:	83 c4 10             	add    $0x10,%esp
  34:	89 45 e0             	mov    %eax,-0x20(%ebp)

if (res == 0){
  37:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  3b:	75 3e                	jne    7b <main+0x7b>
    printf(1, "%d\n%d\n%d\n%d\n%d\n", info->inuse, info->priority, info->nice, info->pid,info->ticks);
  3d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  40:	8d b0 00 04 00 00    	lea    0x400(%eax),%esi
  46:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  49:	8d 98 00 03 00 00    	lea    0x300(%eax),%ebx
  4f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  52:	8d 88 00 02 00 00    	lea    0x200(%eax),%ecx
  58:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  5b:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
  61:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  64:	83 ec 04             	sub    $0x4,%esp
  67:	56                   	push   %esi
  68:	53                   	push   %ebx
  69:	51                   	push   %ecx
  6a:	52                   	push   %edx
  6b:	50                   	push   %eax
  6c:	68 20 08 00 00       	push   $0x820
  71:	6a 01                	push   $0x1
  73:	e8 f1 03 00 00       	call   469 <printf>
  78:	83 c4 20             	add    $0x20,%esp
}


free(info);
  7b:	83 ec 0c             	sub    $0xc,%esp
  7e:	ff 75 e4             	push   -0x1c(%ebp)
  81:	e8 75 05 00 00       	call   5fb <free>
  86:	83 c4 10             	add    $0x10,%esp

    exit();
  89:	e8 57 02 00 00       	call   2e5 <exit>

0000008e <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  8e:	55                   	push   %ebp
  8f:	89 e5                	mov    %esp,%ebp
  91:	57                   	push   %edi
  92:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  93:	8b 4d 08             	mov    0x8(%ebp),%ecx
  96:	8b 55 10             	mov    0x10(%ebp),%edx
  99:	8b 45 0c             	mov    0xc(%ebp),%eax
  9c:	89 cb                	mov    %ecx,%ebx
  9e:	89 df                	mov    %ebx,%edi
  a0:	89 d1                	mov    %edx,%ecx
  a2:	fc                   	cld    
  a3:	f3 aa                	rep stos %al,%es:(%edi)
  a5:	89 ca                	mov    %ecx,%edx
  a7:	89 fb                	mov    %edi,%ebx
  a9:	89 5d 08             	mov    %ebx,0x8(%ebp)
  ac:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  af:	90                   	nop
  b0:	5b                   	pop    %ebx
  b1:	5f                   	pop    %edi
  b2:	5d                   	pop    %ebp
  b3:	c3                   	ret    

000000b4 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  b4:	55                   	push   %ebp
  b5:	89 e5                	mov    %esp,%ebp
  b7:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  ba:	8b 45 08             	mov    0x8(%ebp),%eax
  bd:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  c0:	90                   	nop
  c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  c4:	8d 42 01             	lea    0x1(%edx),%eax
  c7:	89 45 0c             	mov    %eax,0xc(%ebp)
  ca:	8b 45 08             	mov    0x8(%ebp),%eax
  cd:	8d 48 01             	lea    0x1(%eax),%ecx
  d0:	89 4d 08             	mov    %ecx,0x8(%ebp)
  d3:	0f b6 12             	movzbl (%edx),%edx
  d6:	88 10                	mov    %dl,(%eax)
  d8:	0f b6 00             	movzbl (%eax),%eax
  db:	84 c0                	test   %al,%al
  dd:	75 e2                	jne    c1 <strcpy+0xd>
    ;
  return os;
  df:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  e2:	c9                   	leave  
  e3:	c3                   	ret    

000000e4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  e4:	55                   	push   %ebp
  e5:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  e7:	eb 08                	jmp    f1 <strcmp+0xd>
    p++, q++;
  e9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  ed:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
  f1:	8b 45 08             	mov    0x8(%ebp),%eax
  f4:	0f b6 00             	movzbl (%eax),%eax
  f7:	84 c0                	test   %al,%al
  f9:	74 10                	je     10b <strcmp+0x27>
  fb:	8b 45 08             	mov    0x8(%ebp),%eax
  fe:	0f b6 10             	movzbl (%eax),%edx
 101:	8b 45 0c             	mov    0xc(%ebp),%eax
 104:	0f b6 00             	movzbl (%eax),%eax
 107:	38 c2                	cmp    %al,%dl
 109:	74 de                	je     e9 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 10b:	8b 45 08             	mov    0x8(%ebp),%eax
 10e:	0f b6 00             	movzbl (%eax),%eax
 111:	0f b6 d0             	movzbl %al,%edx
 114:	8b 45 0c             	mov    0xc(%ebp),%eax
 117:	0f b6 00             	movzbl (%eax),%eax
 11a:	0f b6 c8             	movzbl %al,%ecx
 11d:	89 d0                	mov    %edx,%eax
 11f:	29 c8                	sub    %ecx,%eax
}
 121:	5d                   	pop    %ebp
 122:	c3                   	ret    

00000123 <strlen>:

uint
strlen(const char *s)
{
 123:	55                   	push   %ebp
 124:	89 e5                	mov    %esp,%ebp
 126:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 129:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 130:	eb 04                	jmp    136 <strlen+0x13>
 132:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 136:	8b 55 fc             	mov    -0x4(%ebp),%edx
 139:	8b 45 08             	mov    0x8(%ebp),%eax
 13c:	01 d0                	add    %edx,%eax
 13e:	0f b6 00             	movzbl (%eax),%eax
 141:	84 c0                	test   %al,%al
 143:	75 ed                	jne    132 <strlen+0xf>
    ;
  return n;
 145:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 148:	c9                   	leave  
 149:	c3                   	ret    

0000014a <memset>:

void*
memset(void *dst, int c, uint n)
{
 14a:	55                   	push   %ebp
 14b:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 14d:	8b 45 10             	mov    0x10(%ebp),%eax
 150:	50                   	push   %eax
 151:	ff 75 0c             	push   0xc(%ebp)
 154:	ff 75 08             	push   0x8(%ebp)
 157:	e8 32 ff ff ff       	call   8e <stosb>
 15c:	83 c4 0c             	add    $0xc,%esp
  return dst;
 15f:	8b 45 08             	mov    0x8(%ebp),%eax
}
 162:	c9                   	leave  
 163:	c3                   	ret    

00000164 <strchr>:

char*
strchr(const char *s, char c)
{
 164:	55                   	push   %ebp
 165:	89 e5                	mov    %esp,%ebp
 167:	83 ec 04             	sub    $0x4,%esp
 16a:	8b 45 0c             	mov    0xc(%ebp),%eax
 16d:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 170:	eb 14                	jmp    186 <strchr+0x22>
    if(*s == c)
 172:	8b 45 08             	mov    0x8(%ebp),%eax
 175:	0f b6 00             	movzbl (%eax),%eax
 178:	38 45 fc             	cmp    %al,-0x4(%ebp)
 17b:	75 05                	jne    182 <strchr+0x1e>
      return (char*)s;
 17d:	8b 45 08             	mov    0x8(%ebp),%eax
 180:	eb 13                	jmp    195 <strchr+0x31>
  for(; *s; s++)
 182:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 186:	8b 45 08             	mov    0x8(%ebp),%eax
 189:	0f b6 00             	movzbl (%eax),%eax
 18c:	84 c0                	test   %al,%al
 18e:	75 e2                	jne    172 <strchr+0xe>
  return 0;
 190:	b8 00 00 00 00       	mov    $0x0,%eax
}
 195:	c9                   	leave  
 196:	c3                   	ret    

00000197 <gets>:

char*
gets(char *buf, int max)
{
 197:	55                   	push   %ebp
 198:	89 e5                	mov    %esp,%ebp
 19a:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 19d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1a4:	eb 42                	jmp    1e8 <gets+0x51>
    cc = read(0, &c, 1);
 1a6:	83 ec 04             	sub    $0x4,%esp
 1a9:	6a 01                	push   $0x1
 1ab:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1ae:	50                   	push   %eax
 1af:	6a 00                	push   $0x0
 1b1:	e8 47 01 00 00       	call   2fd <read>
 1b6:	83 c4 10             	add    $0x10,%esp
 1b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1bc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1c0:	7e 33                	jle    1f5 <gets+0x5e>
      break;
    buf[i++] = c;
 1c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1c5:	8d 50 01             	lea    0x1(%eax),%edx
 1c8:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1cb:	89 c2                	mov    %eax,%edx
 1cd:	8b 45 08             	mov    0x8(%ebp),%eax
 1d0:	01 c2                	add    %eax,%edx
 1d2:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1d6:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1d8:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1dc:	3c 0a                	cmp    $0xa,%al
 1de:	74 16                	je     1f6 <gets+0x5f>
 1e0:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1e4:	3c 0d                	cmp    $0xd,%al
 1e6:	74 0e                	je     1f6 <gets+0x5f>
  for(i=0; i+1 < max; ){
 1e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1eb:	83 c0 01             	add    $0x1,%eax
 1ee:	39 45 0c             	cmp    %eax,0xc(%ebp)
 1f1:	7f b3                	jg     1a6 <gets+0xf>
 1f3:	eb 01                	jmp    1f6 <gets+0x5f>
      break;
 1f5:	90                   	nop
      break;
  }
  buf[i] = '\0';
 1f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1f9:	8b 45 08             	mov    0x8(%ebp),%eax
 1fc:	01 d0                	add    %edx,%eax
 1fe:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 201:	8b 45 08             	mov    0x8(%ebp),%eax
}
 204:	c9                   	leave  
 205:	c3                   	ret    

00000206 <stat>:

int
stat(const char *n, struct stat *st)
{
 206:	55                   	push   %ebp
 207:	89 e5                	mov    %esp,%ebp
 209:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 20c:	83 ec 08             	sub    $0x8,%esp
 20f:	6a 00                	push   $0x0
 211:	ff 75 08             	push   0x8(%ebp)
 214:	e8 0c 01 00 00       	call   325 <open>
 219:	83 c4 10             	add    $0x10,%esp
 21c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 21f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 223:	79 07                	jns    22c <stat+0x26>
    return -1;
 225:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 22a:	eb 25                	jmp    251 <stat+0x4b>
  r = fstat(fd, st);
 22c:	83 ec 08             	sub    $0x8,%esp
 22f:	ff 75 0c             	push   0xc(%ebp)
 232:	ff 75 f4             	push   -0xc(%ebp)
 235:	e8 03 01 00 00       	call   33d <fstat>
 23a:	83 c4 10             	add    $0x10,%esp
 23d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 240:	83 ec 0c             	sub    $0xc,%esp
 243:	ff 75 f4             	push   -0xc(%ebp)
 246:	e8 c2 00 00 00       	call   30d <close>
 24b:	83 c4 10             	add    $0x10,%esp
  return r;
 24e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 251:	c9                   	leave  
 252:	c3                   	ret    

00000253 <atoi>:

int
atoi(const char *s)
{
 253:	55                   	push   %ebp
 254:	89 e5                	mov    %esp,%ebp
 256:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 259:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 260:	eb 25                	jmp    287 <atoi+0x34>
    n = n*10 + *s++ - '0';
 262:	8b 55 fc             	mov    -0x4(%ebp),%edx
 265:	89 d0                	mov    %edx,%eax
 267:	c1 e0 02             	shl    $0x2,%eax
 26a:	01 d0                	add    %edx,%eax
 26c:	01 c0                	add    %eax,%eax
 26e:	89 c1                	mov    %eax,%ecx
 270:	8b 45 08             	mov    0x8(%ebp),%eax
 273:	8d 50 01             	lea    0x1(%eax),%edx
 276:	89 55 08             	mov    %edx,0x8(%ebp)
 279:	0f b6 00             	movzbl (%eax),%eax
 27c:	0f be c0             	movsbl %al,%eax
 27f:	01 c8                	add    %ecx,%eax
 281:	83 e8 30             	sub    $0x30,%eax
 284:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 287:	8b 45 08             	mov    0x8(%ebp),%eax
 28a:	0f b6 00             	movzbl (%eax),%eax
 28d:	3c 2f                	cmp    $0x2f,%al
 28f:	7e 0a                	jle    29b <atoi+0x48>
 291:	8b 45 08             	mov    0x8(%ebp),%eax
 294:	0f b6 00             	movzbl (%eax),%eax
 297:	3c 39                	cmp    $0x39,%al
 299:	7e c7                	jle    262 <atoi+0xf>
  return n;
 29b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 29e:	c9                   	leave  
 29f:	c3                   	ret    

000002a0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2a0:	55                   	push   %ebp
 2a1:	89 e5                	mov    %esp,%ebp
 2a3:	83 ec 10             	sub    $0x10,%esp
  char *dst;
  const char *src;

  dst = vdst;
 2a6:	8b 45 08             	mov    0x8(%ebp),%eax
 2a9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2ac:	8b 45 0c             	mov    0xc(%ebp),%eax
 2af:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2b2:	eb 17                	jmp    2cb <memmove+0x2b>
    *dst++ = *src++;
 2b4:	8b 55 f8             	mov    -0x8(%ebp),%edx
 2b7:	8d 42 01             	lea    0x1(%edx),%eax
 2ba:	89 45 f8             	mov    %eax,-0x8(%ebp)
 2bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2c0:	8d 48 01             	lea    0x1(%eax),%ecx
 2c3:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 2c6:	0f b6 12             	movzbl (%edx),%edx
 2c9:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 2cb:	8b 45 10             	mov    0x10(%ebp),%eax
 2ce:	8d 50 ff             	lea    -0x1(%eax),%edx
 2d1:	89 55 10             	mov    %edx,0x10(%ebp)
 2d4:	85 c0                	test   %eax,%eax
 2d6:	7f dc                	jg     2b4 <memmove+0x14>
  return vdst;
 2d8:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2db:	c9                   	leave  
 2dc:	c3                   	ret    

000002dd <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2dd:	b8 01 00 00 00       	mov    $0x1,%eax
 2e2:	cd 40                	int    $0x40
 2e4:	c3                   	ret    

000002e5 <exit>:
SYSCALL(exit)
 2e5:	b8 02 00 00 00       	mov    $0x2,%eax
 2ea:	cd 40                	int    $0x40
 2ec:	c3                   	ret    

000002ed <wait>:
SYSCALL(wait)
 2ed:	b8 03 00 00 00       	mov    $0x3,%eax
 2f2:	cd 40                	int    $0x40
 2f4:	c3                   	ret    

000002f5 <pipe>:
SYSCALL(pipe)
 2f5:	b8 04 00 00 00       	mov    $0x4,%eax
 2fa:	cd 40                	int    $0x40
 2fc:	c3                   	ret    

000002fd <read>:
SYSCALL(read)
 2fd:	b8 05 00 00 00       	mov    $0x5,%eax
 302:	cd 40                	int    $0x40
 304:	c3                   	ret    

00000305 <write>:
SYSCALL(write)
 305:	b8 10 00 00 00       	mov    $0x10,%eax
 30a:	cd 40                	int    $0x40
 30c:	c3                   	ret    

0000030d <close>:
SYSCALL(close)
 30d:	b8 15 00 00 00       	mov    $0x15,%eax
 312:	cd 40                	int    $0x40
 314:	c3                   	ret    

00000315 <kill>:
SYSCALL(kill)
 315:	b8 06 00 00 00       	mov    $0x6,%eax
 31a:	cd 40                	int    $0x40
 31c:	c3                   	ret    

0000031d <exec>:
SYSCALL(exec)
 31d:	b8 07 00 00 00       	mov    $0x7,%eax
 322:	cd 40                	int    $0x40
 324:	c3                   	ret    

00000325 <open>:
SYSCALL(open)
 325:	b8 0f 00 00 00       	mov    $0xf,%eax
 32a:	cd 40                	int    $0x40
 32c:	c3                   	ret    

0000032d <mknod>:
SYSCALL(mknod)
 32d:	b8 11 00 00 00       	mov    $0x11,%eax
 332:	cd 40                	int    $0x40
 334:	c3                   	ret    

00000335 <unlink>:
SYSCALL(unlink)
 335:	b8 12 00 00 00       	mov    $0x12,%eax
 33a:	cd 40                	int    $0x40
 33c:	c3                   	ret    

0000033d <fstat>:
SYSCALL(fstat)
 33d:	b8 08 00 00 00       	mov    $0x8,%eax
 342:	cd 40                	int    $0x40
 344:	c3                   	ret    

00000345 <link>:
SYSCALL(link)
 345:	b8 13 00 00 00       	mov    $0x13,%eax
 34a:	cd 40                	int    $0x40
 34c:	c3                   	ret    

0000034d <mkdir>:
SYSCALL(mkdir)
 34d:	b8 14 00 00 00       	mov    $0x14,%eax
 352:	cd 40                	int    $0x40
 354:	c3                   	ret    

00000355 <chdir>:
SYSCALL(chdir)
 355:	b8 09 00 00 00       	mov    $0x9,%eax
 35a:	cd 40                	int    $0x40
 35c:	c3                   	ret    

0000035d <dup>:
SYSCALL(dup)
 35d:	b8 0a 00 00 00       	mov    $0xa,%eax
 362:	cd 40                	int    $0x40
 364:	c3                   	ret    

00000365 <getpid>:
SYSCALL(getpid)
 365:	b8 0b 00 00 00       	mov    $0xb,%eax
 36a:	cd 40                	int    $0x40
 36c:	c3                   	ret    

0000036d <sbrk>:
SYSCALL(sbrk)
 36d:	b8 0c 00 00 00       	mov    $0xc,%eax
 372:	cd 40                	int    $0x40
 374:	c3                   	ret    

00000375 <sleep>:
SYSCALL(sleep)
 375:	b8 0d 00 00 00       	mov    $0xd,%eax
 37a:	cd 40                	int    $0x40
 37c:	c3                   	ret    

0000037d <uptime>:
SYSCALL(uptime)
 37d:	b8 0e 00 00 00       	mov    $0xe,%eax
 382:	cd 40                	int    $0x40
 384:	c3                   	ret    

00000385 <nice>:
SYSCALL(nice)
 385:	b8 16 00 00 00       	mov    $0x16,%eax
 38a:	cd 40                	int    $0x40
 38c:	c3                   	ret    

0000038d <getschedstate>:
SYSCALL(getschedstate)
 38d:	b8 17 00 00 00       	mov    $0x17,%eax
 392:	cd 40                	int    $0x40
 394:	c3                   	ret    

00000395 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 395:	55                   	push   %ebp
 396:	89 e5                	mov    %esp,%ebp
 398:	83 ec 18             	sub    $0x18,%esp
 39b:	8b 45 0c             	mov    0xc(%ebp),%eax
 39e:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 3a1:	83 ec 04             	sub    $0x4,%esp
 3a4:	6a 01                	push   $0x1
 3a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3a9:	50                   	push   %eax
 3aa:	ff 75 08             	push   0x8(%ebp)
 3ad:	e8 53 ff ff ff       	call   305 <write>
 3b2:	83 c4 10             	add    $0x10,%esp
}
 3b5:	90                   	nop
 3b6:	c9                   	leave  
 3b7:	c3                   	ret    

000003b8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3b8:	55                   	push   %ebp
 3b9:	89 e5                	mov    %esp,%ebp
 3bb:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3be:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3c5:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3c9:	74 17                	je     3e2 <printint+0x2a>
 3cb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3cf:	79 11                	jns    3e2 <printint+0x2a>
    neg = 1;
 3d1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3d8:	8b 45 0c             	mov    0xc(%ebp),%eax
 3db:	f7 d8                	neg    %eax
 3dd:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3e0:	eb 06                	jmp    3e8 <printint+0x30>
  } else {
    x = xx;
 3e2:	8b 45 0c             	mov    0xc(%ebp),%eax
 3e5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 3ef:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3f5:	ba 00 00 00 00       	mov    $0x0,%edx
 3fa:	f7 f1                	div    %ecx
 3fc:	89 d1                	mov    %edx,%ecx
 3fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
 401:	8d 50 01             	lea    0x1(%eax),%edx
 404:	89 55 f4             	mov    %edx,-0xc(%ebp)
 407:	0f b6 91 84 0a 00 00 	movzbl 0xa84(%ecx),%edx
 40e:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 412:	8b 4d 10             	mov    0x10(%ebp),%ecx
 415:	8b 45 ec             	mov    -0x14(%ebp),%eax
 418:	ba 00 00 00 00       	mov    $0x0,%edx
 41d:	f7 f1                	div    %ecx
 41f:	89 45 ec             	mov    %eax,-0x14(%ebp)
 422:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 426:	75 c7                	jne    3ef <printint+0x37>
  if(neg)
 428:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 42c:	74 2d                	je     45b <printint+0xa3>
    buf[i++] = '-';
 42e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 431:	8d 50 01             	lea    0x1(%eax),%edx
 434:	89 55 f4             	mov    %edx,-0xc(%ebp)
 437:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 43c:	eb 1d                	jmp    45b <printint+0xa3>
    putc(fd, buf[i]);
 43e:	8d 55 dc             	lea    -0x24(%ebp),%edx
 441:	8b 45 f4             	mov    -0xc(%ebp),%eax
 444:	01 d0                	add    %edx,%eax
 446:	0f b6 00             	movzbl (%eax),%eax
 449:	0f be c0             	movsbl %al,%eax
 44c:	83 ec 08             	sub    $0x8,%esp
 44f:	50                   	push   %eax
 450:	ff 75 08             	push   0x8(%ebp)
 453:	e8 3d ff ff ff       	call   395 <putc>
 458:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 45b:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 45f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 463:	79 d9                	jns    43e <printint+0x86>
}
 465:	90                   	nop
 466:	90                   	nop
 467:	c9                   	leave  
 468:	c3                   	ret    

00000469 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 469:	55                   	push   %ebp
 46a:	89 e5                	mov    %esp,%ebp
 46c:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 46f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 476:	8d 45 0c             	lea    0xc(%ebp),%eax
 479:	83 c0 04             	add    $0x4,%eax
 47c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 47f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 486:	e9 59 01 00 00       	jmp    5e4 <printf+0x17b>
    c = fmt[i] & 0xff;
 48b:	8b 55 0c             	mov    0xc(%ebp),%edx
 48e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 491:	01 d0                	add    %edx,%eax
 493:	0f b6 00             	movzbl (%eax),%eax
 496:	0f be c0             	movsbl %al,%eax
 499:	25 ff 00 00 00       	and    $0xff,%eax
 49e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 4a1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4a5:	75 2c                	jne    4d3 <printf+0x6a>
      if(c == '%'){
 4a7:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4ab:	75 0c                	jne    4b9 <printf+0x50>
        state = '%';
 4ad:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4b4:	e9 27 01 00 00       	jmp    5e0 <printf+0x177>
      } else {
        putc(fd, c);
 4b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4bc:	0f be c0             	movsbl %al,%eax
 4bf:	83 ec 08             	sub    $0x8,%esp
 4c2:	50                   	push   %eax
 4c3:	ff 75 08             	push   0x8(%ebp)
 4c6:	e8 ca fe ff ff       	call   395 <putc>
 4cb:	83 c4 10             	add    $0x10,%esp
 4ce:	e9 0d 01 00 00       	jmp    5e0 <printf+0x177>
      }
    } else if(state == '%'){
 4d3:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4d7:	0f 85 03 01 00 00    	jne    5e0 <printf+0x177>
      if(c == 'd'){
 4dd:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4e1:	75 1e                	jne    501 <printf+0x98>
        printint(fd, *ap, 10, 1);
 4e3:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4e6:	8b 00                	mov    (%eax),%eax
 4e8:	6a 01                	push   $0x1
 4ea:	6a 0a                	push   $0xa
 4ec:	50                   	push   %eax
 4ed:	ff 75 08             	push   0x8(%ebp)
 4f0:	e8 c3 fe ff ff       	call   3b8 <printint>
 4f5:	83 c4 10             	add    $0x10,%esp
        ap++;
 4f8:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4fc:	e9 d8 00 00 00       	jmp    5d9 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 501:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 505:	74 06                	je     50d <printf+0xa4>
 507:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 50b:	75 1e                	jne    52b <printf+0xc2>
        printint(fd, *ap, 16, 0);
 50d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 510:	8b 00                	mov    (%eax),%eax
 512:	6a 00                	push   $0x0
 514:	6a 10                	push   $0x10
 516:	50                   	push   %eax
 517:	ff 75 08             	push   0x8(%ebp)
 51a:	e8 99 fe ff ff       	call   3b8 <printint>
 51f:	83 c4 10             	add    $0x10,%esp
        ap++;
 522:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 526:	e9 ae 00 00 00       	jmp    5d9 <printf+0x170>
      } else if(c == 's'){
 52b:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 52f:	75 43                	jne    574 <printf+0x10b>
        s = (char*)*ap;
 531:	8b 45 e8             	mov    -0x18(%ebp),%eax
 534:	8b 00                	mov    (%eax),%eax
 536:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 539:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 53d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 541:	75 25                	jne    568 <printf+0xff>
          s = "(null)";
 543:	c7 45 f4 30 08 00 00 	movl   $0x830,-0xc(%ebp)
        while(*s != 0){
 54a:	eb 1c                	jmp    568 <printf+0xff>
          putc(fd, *s);
 54c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 54f:	0f b6 00             	movzbl (%eax),%eax
 552:	0f be c0             	movsbl %al,%eax
 555:	83 ec 08             	sub    $0x8,%esp
 558:	50                   	push   %eax
 559:	ff 75 08             	push   0x8(%ebp)
 55c:	e8 34 fe ff ff       	call   395 <putc>
 561:	83 c4 10             	add    $0x10,%esp
          s++;
 564:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 568:	8b 45 f4             	mov    -0xc(%ebp),%eax
 56b:	0f b6 00             	movzbl (%eax),%eax
 56e:	84 c0                	test   %al,%al
 570:	75 da                	jne    54c <printf+0xe3>
 572:	eb 65                	jmp    5d9 <printf+0x170>
        }
      } else if(c == 'c'){
 574:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 578:	75 1d                	jne    597 <printf+0x12e>
        putc(fd, *ap);
 57a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 57d:	8b 00                	mov    (%eax),%eax
 57f:	0f be c0             	movsbl %al,%eax
 582:	83 ec 08             	sub    $0x8,%esp
 585:	50                   	push   %eax
 586:	ff 75 08             	push   0x8(%ebp)
 589:	e8 07 fe ff ff       	call   395 <putc>
 58e:	83 c4 10             	add    $0x10,%esp
        ap++;
 591:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 595:	eb 42                	jmp    5d9 <printf+0x170>
      } else if(c == '%'){
 597:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 59b:	75 17                	jne    5b4 <printf+0x14b>
        putc(fd, c);
 59d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5a0:	0f be c0             	movsbl %al,%eax
 5a3:	83 ec 08             	sub    $0x8,%esp
 5a6:	50                   	push   %eax
 5a7:	ff 75 08             	push   0x8(%ebp)
 5aa:	e8 e6 fd ff ff       	call   395 <putc>
 5af:	83 c4 10             	add    $0x10,%esp
 5b2:	eb 25                	jmp    5d9 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5b4:	83 ec 08             	sub    $0x8,%esp
 5b7:	6a 25                	push   $0x25
 5b9:	ff 75 08             	push   0x8(%ebp)
 5bc:	e8 d4 fd ff ff       	call   395 <putc>
 5c1:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 5c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5c7:	0f be c0             	movsbl %al,%eax
 5ca:	83 ec 08             	sub    $0x8,%esp
 5cd:	50                   	push   %eax
 5ce:	ff 75 08             	push   0x8(%ebp)
 5d1:	e8 bf fd ff ff       	call   395 <putc>
 5d6:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 5d9:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 5e0:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 5e4:	8b 55 0c             	mov    0xc(%ebp),%edx
 5e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5ea:	01 d0                	add    %edx,%eax
 5ec:	0f b6 00             	movzbl (%eax),%eax
 5ef:	84 c0                	test   %al,%al
 5f1:	0f 85 94 fe ff ff    	jne    48b <printf+0x22>
    }
  }
}
 5f7:	90                   	nop
 5f8:	90                   	nop
 5f9:	c9                   	leave  
 5fa:	c3                   	ret    

000005fb <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5fb:	55                   	push   %ebp
 5fc:	89 e5                	mov    %esp,%ebp
 5fe:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 601:	8b 45 08             	mov    0x8(%ebp),%eax
 604:	83 e8 08             	sub    $0x8,%eax
 607:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 60a:	a1 a0 0a 00 00       	mov    0xaa0,%eax
 60f:	89 45 fc             	mov    %eax,-0x4(%ebp)
 612:	eb 24                	jmp    638 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 614:	8b 45 fc             	mov    -0x4(%ebp),%eax
 617:	8b 00                	mov    (%eax),%eax
 619:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 61c:	72 12                	jb     630 <free+0x35>
 61e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 621:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 624:	77 24                	ja     64a <free+0x4f>
 626:	8b 45 fc             	mov    -0x4(%ebp),%eax
 629:	8b 00                	mov    (%eax),%eax
 62b:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 62e:	72 1a                	jb     64a <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 630:	8b 45 fc             	mov    -0x4(%ebp),%eax
 633:	8b 00                	mov    (%eax),%eax
 635:	89 45 fc             	mov    %eax,-0x4(%ebp)
 638:	8b 45 f8             	mov    -0x8(%ebp),%eax
 63b:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 63e:	76 d4                	jbe    614 <free+0x19>
 640:	8b 45 fc             	mov    -0x4(%ebp),%eax
 643:	8b 00                	mov    (%eax),%eax
 645:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 648:	73 ca                	jae    614 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 64a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 64d:	8b 40 04             	mov    0x4(%eax),%eax
 650:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 657:	8b 45 f8             	mov    -0x8(%ebp),%eax
 65a:	01 c2                	add    %eax,%edx
 65c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 65f:	8b 00                	mov    (%eax),%eax
 661:	39 c2                	cmp    %eax,%edx
 663:	75 24                	jne    689 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 665:	8b 45 f8             	mov    -0x8(%ebp),%eax
 668:	8b 50 04             	mov    0x4(%eax),%edx
 66b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 66e:	8b 00                	mov    (%eax),%eax
 670:	8b 40 04             	mov    0x4(%eax),%eax
 673:	01 c2                	add    %eax,%edx
 675:	8b 45 f8             	mov    -0x8(%ebp),%eax
 678:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 67b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 67e:	8b 00                	mov    (%eax),%eax
 680:	8b 10                	mov    (%eax),%edx
 682:	8b 45 f8             	mov    -0x8(%ebp),%eax
 685:	89 10                	mov    %edx,(%eax)
 687:	eb 0a                	jmp    693 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 689:	8b 45 fc             	mov    -0x4(%ebp),%eax
 68c:	8b 10                	mov    (%eax),%edx
 68e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 691:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 693:	8b 45 fc             	mov    -0x4(%ebp),%eax
 696:	8b 40 04             	mov    0x4(%eax),%eax
 699:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a3:	01 d0                	add    %edx,%eax
 6a5:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 6a8:	75 20                	jne    6ca <free+0xcf>
    p->s.size += bp->s.size;
 6aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ad:	8b 50 04             	mov    0x4(%eax),%edx
 6b0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b3:	8b 40 04             	mov    0x4(%eax),%eax
 6b6:	01 c2                	add    %eax,%edx
 6b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6bb:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6be:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6c1:	8b 10                	mov    (%eax),%edx
 6c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c6:	89 10                	mov    %edx,(%eax)
 6c8:	eb 08                	jmp    6d2 <free+0xd7>
  } else
    p->s.ptr = bp;
 6ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6cd:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6d0:	89 10                	mov    %edx,(%eax)
  freep = p;
 6d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d5:	a3 a0 0a 00 00       	mov    %eax,0xaa0
}
 6da:	90                   	nop
 6db:	c9                   	leave  
 6dc:	c3                   	ret    

000006dd <morecore>:

static Header*
morecore(uint nu)
{
 6dd:	55                   	push   %ebp
 6de:	89 e5                	mov    %esp,%ebp
 6e0:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 6e3:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 6ea:	77 07                	ja     6f3 <morecore+0x16>
    nu = 4096;
 6ec:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 6f3:	8b 45 08             	mov    0x8(%ebp),%eax
 6f6:	c1 e0 03             	shl    $0x3,%eax
 6f9:	83 ec 0c             	sub    $0xc,%esp
 6fc:	50                   	push   %eax
 6fd:	e8 6b fc ff ff       	call   36d <sbrk>
 702:	83 c4 10             	add    $0x10,%esp
 705:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 708:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 70c:	75 07                	jne    715 <morecore+0x38>
    return 0;
 70e:	b8 00 00 00 00       	mov    $0x0,%eax
 713:	eb 26                	jmp    73b <morecore+0x5e>
  hp = (Header*)p;
 715:	8b 45 f4             	mov    -0xc(%ebp),%eax
 718:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 71b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 71e:	8b 55 08             	mov    0x8(%ebp),%edx
 721:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 724:	8b 45 f0             	mov    -0x10(%ebp),%eax
 727:	83 c0 08             	add    $0x8,%eax
 72a:	83 ec 0c             	sub    $0xc,%esp
 72d:	50                   	push   %eax
 72e:	e8 c8 fe ff ff       	call   5fb <free>
 733:	83 c4 10             	add    $0x10,%esp
  return freep;
 736:	a1 a0 0a 00 00       	mov    0xaa0,%eax
}
 73b:	c9                   	leave  
 73c:	c3                   	ret    

0000073d <malloc>:

void*
malloc(uint nbytes)
{
 73d:	55                   	push   %ebp
 73e:	89 e5                	mov    %esp,%ebp
 740:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 743:	8b 45 08             	mov    0x8(%ebp),%eax
 746:	83 c0 07             	add    $0x7,%eax
 749:	c1 e8 03             	shr    $0x3,%eax
 74c:	83 c0 01             	add    $0x1,%eax
 74f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 752:	a1 a0 0a 00 00       	mov    0xaa0,%eax
 757:	89 45 f0             	mov    %eax,-0x10(%ebp)
 75a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 75e:	75 23                	jne    783 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 760:	c7 45 f0 98 0a 00 00 	movl   $0xa98,-0x10(%ebp)
 767:	8b 45 f0             	mov    -0x10(%ebp),%eax
 76a:	a3 a0 0a 00 00       	mov    %eax,0xaa0
 76f:	a1 a0 0a 00 00       	mov    0xaa0,%eax
 774:	a3 98 0a 00 00       	mov    %eax,0xa98
    base.s.size = 0;
 779:	c7 05 9c 0a 00 00 00 	movl   $0x0,0xa9c
 780:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 783:	8b 45 f0             	mov    -0x10(%ebp),%eax
 786:	8b 00                	mov    (%eax),%eax
 788:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 78b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 78e:	8b 40 04             	mov    0x4(%eax),%eax
 791:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 794:	77 4d                	ja     7e3 <malloc+0xa6>
      if(p->s.size == nunits)
 796:	8b 45 f4             	mov    -0xc(%ebp),%eax
 799:	8b 40 04             	mov    0x4(%eax),%eax
 79c:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 79f:	75 0c                	jne    7ad <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 7a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a4:	8b 10                	mov    (%eax),%edx
 7a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7a9:	89 10                	mov    %edx,(%eax)
 7ab:	eb 26                	jmp    7d3 <malloc+0x96>
      else {
        p->s.size -= nunits;
 7ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b0:	8b 40 04             	mov    0x4(%eax),%eax
 7b3:	2b 45 ec             	sub    -0x14(%ebp),%eax
 7b6:	89 c2                	mov    %eax,%edx
 7b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7bb:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7be:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c1:	8b 40 04             	mov    0x4(%eax),%eax
 7c4:	c1 e0 03             	shl    $0x3,%eax
 7c7:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7cd:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7d0:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7d6:	a3 a0 0a 00 00       	mov    %eax,0xaa0
      return (void*)(p + 1);
 7db:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7de:	83 c0 08             	add    $0x8,%eax
 7e1:	eb 3b                	jmp    81e <malloc+0xe1>
    }
    if(p == freep)
 7e3:	a1 a0 0a 00 00       	mov    0xaa0,%eax
 7e8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 7eb:	75 1e                	jne    80b <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 7ed:	83 ec 0c             	sub    $0xc,%esp
 7f0:	ff 75 ec             	push   -0x14(%ebp)
 7f3:	e8 e5 fe ff ff       	call   6dd <morecore>
 7f8:	83 c4 10             	add    $0x10,%esp
 7fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
 7fe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 802:	75 07                	jne    80b <malloc+0xce>
        return 0;
 804:	b8 00 00 00 00       	mov    $0x0,%eax
 809:	eb 13                	jmp    81e <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 80b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 80e:	89 45 f0             	mov    %eax,-0x10(%ebp)
 811:	8b 45 f4             	mov    -0xc(%ebp),%eax
 814:	8b 00                	mov    (%eax),%eax
 816:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 819:	e9 6d ff ff ff       	jmp    78b <malloc+0x4e>
  }
}
 81e:	c9                   	leave  
 81f:	c3                   	ret    
