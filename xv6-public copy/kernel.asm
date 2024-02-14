
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc e0 69 11 80       	mov    $0x801169e0,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 5b 38 10 80       	mov    $0x8010385b,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	83 ec 08             	sub    $0x8,%esp
8010003d:	68 a4 85 10 80       	push   $0x801085a4
80100042:	68 80 b5 10 80       	push   $0x8010b580
80100047:	e8 f1 50 00 00       	call   8010513d <initlock>
8010004c:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004f:	c7 05 cc fc 10 80 7c 	movl   $0x8010fc7c,0x8010fccc
80100056:	fc 10 80 
  bcache.head.next = &bcache.head;
80100059:	c7 05 d0 fc 10 80 7c 	movl   $0x8010fc7c,0x8010fcd0
80100060:	fc 10 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100063:	c7 45 f4 b4 b5 10 80 	movl   $0x8010b5b4,-0xc(%ebp)
8010006a:	eb 47                	jmp    801000b3 <binit+0x7f>
    b->next = bcache.head.next;
8010006c:	8b 15 d0 fc 10 80    	mov    0x8010fcd0,%edx
80100072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100075:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007b:	c7 40 50 7c fc 10 80 	movl   $0x8010fc7c,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
80100082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100085:	83 c0 0c             	add    $0xc,%eax
80100088:	83 ec 08             	sub    $0x8,%esp
8010008b:	68 ab 85 10 80       	push   $0x801085ab
80100090:	50                   	push   %eax
80100091:	e8 24 4f 00 00       	call   80104fba <initsleeplock>
80100096:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
80100099:	a1 d0 fc 10 80       	mov    0x8010fcd0,%eax
8010009e:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000a1:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000a7:	a3 d0 fc 10 80       	mov    %eax,0x8010fcd0
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000ac:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000b3:	b8 7c fc 10 80       	mov    $0x8010fc7c,%eax
801000b8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000bb:	72 af                	jb     8010006c <binit+0x38>
  }
}
801000bd:	90                   	nop
801000be:	90                   	nop
801000bf:	c9                   	leave  
801000c0:	c3                   	ret    

801000c1 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000c1:	55                   	push   %ebp
801000c2:	89 e5                	mov    %esp,%ebp
801000c4:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000c7:	83 ec 0c             	sub    $0xc,%esp
801000ca:	68 80 b5 10 80       	push   $0x8010b580
801000cf:	e8 8b 50 00 00       	call   8010515f <acquire>
801000d4:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000d7:	a1 d0 fc 10 80       	mov    0x8010fcd0,%eax
801000dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000df:	eb 58                	jmp    80100139 <bget+0x78>
    if(b->dev == dev && b->blockno == blockno){
801000e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e4:	8b 40 04             	mov    0x4(%eax),%eax
801000e7:	39 45 08             	cmp    %eax,0x8(%ebp)
801000ea:	75 44                	jne    80100130 <bget+0x6f>
801000ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ef:	8b 40 08             	mov    0x8(%eax),%eax
801000f2:	39 45 0c             	cmp    %eax,0xc(%ebp)
801000f5:	75 39                	jne    80100130 <bget+0x6f>
      b->refcnt++;
801000f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000fa:	8b 40 4c             	mov    0x4c(%eax),%eax
801000fd:	8d 50 01             	lea    0x1(%eax),%edx
80100100:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100103:	89 50 4c             	mov    %edx,0x4c(%eax)
      release(&bcache.lock);
80100106:	83 ec 0c             	sub    $0xc,%esp
80100109:	68 80 b5 10 80       	push   $0x8010b580
8010010e:	e8 ba 50 00 00       	call   801051cd <release>
80100113:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100116:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100119:	83 c0 0c             	add    $0xc,%eax
8010011c:	83 ec 0c             	sub    $0xc,%esp
8010011f:	50                   	push   %eax
80100120:	e8 d1 4e 00 00       	call   80104ff6 <acquiresleep>
80100125:	83 c4 10             	add    $0x10,%esp
      return b;
80100128:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010012b:	e9 9d 00 00 00       	jmp    801001cd <bget+0x10c>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100130:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100133:	8b 40 54             	mov    0x54(%eax),%eax
80100136:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100139:	81 7d f4 7c fc 10 80 	cmpl   $0x8010fc7c,-0xc(%ebp)
80100140:	75 9f                	jne    801000e1 <bget+0x20>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100142:	a1 cc fc 10 80       	mov    0x8010fccc,%eax
80100147:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010014a:	eb 6b                	jmp    801001b7 <bget+0xf6>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
8010014c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014f:	8b 40 4c             	mov    0x4c(%eax),%eax
80100152:	85 c0                	test   %eax,%eax
80100154:	75 58                	jne    801001ae <bget+0xed>
80100156:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100159:	8b 00                	mov    (%eax),%eax
8010015b:	83 e0 04             	and    $0x4,%eax
8010015e:	85 c0                	test   %eax,%eax
80100160:	75 4c                	jne    801001ae <bget+0xed>
      b->dev = dev;
80100162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100165:	8b 55 08             	mov    0x8(%ebp),%edx
80100168:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010016b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016e:	8b 55 0c             	mov    0xc(%ebp),%edx
80100171:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = 0;
80100174:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100177:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      b->refcnt = 1;
8010017d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100180:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
      release(&bcache.lock);
80100187:	83 ec 0c             	sub    $0xc,%esp
8010018a:	68 80 b5 10 80       	push   $0x8010b580
8010018f:	e8 39 50 00 00       	call   801051cd <release>
80100194:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100197:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010019a:	83 c0 0c             	add    $0xc,%eax
8010019d:	83 ec 0c             	sub    $0xc,%esp
801001a0:	50                   	push   %eax
801001a1:	e8 50 4e 00 00       	call   80104ff6 <acquiresleep>
801001a6:	83 c4 10             	add    $0x10,%esp
      return b;
801001a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001ac:	eb 1f                	jmp    801001cd <bget+0x10c>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001b1:	8b 40 50             	mov    0x50(%eax),%eax
801001b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001b7:	81 7d f4 7c fc 10 80 	cmpl   $0x8010fc7c,-0xc(%ebp)
801001be:	75 8c                	jne    8010014c <bget+0x8b>
    }
  }
  panic("bget: no buffers");
801001c0:	83 ec 0c             	sub    $0xc,%esp
801001c3:	68 b2 85 10 80       	push   $0x801085b2
801001c8:	e8 e8 03 00 00       	call   801005b5 <panic>
}
801001cd:	c9                   	leave  
801001ce:	c3                   	ret    

801001cf <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001cf:	55                   	push   %ebp
801001d0:	89 e5                	mov    %esp,%ebp
801001d2:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001d5:	83 ec 08             	sub    $0x8,%esp
801001d8:	ff 75 0c             	push   0xc(%ebp)
801001db:	ff 75 08             	push   0x8(%ebp)
801001de:	e8 de fe ff ff       	call   801000c1 <bget>
801001e3:	83 c4 10             	add    $0x10,%esp
801001e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((b->flags & B_VALID) == 0) {
801001e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001ec:	8b 00                	mov    (%eax),%eax
801001ee:	83 e0 02             	and    $0x2,%eax
801001f1:	85 c0                	test   %eax,%eax
801001f3:	75 0e                	jne    80100203 <bread+0x34>
    iderw(b);
801001f5:	83 ec 0c             	sub    $0xc,%esp
801001f8:	ff 75 f4             	push   -0xc(%ebp)
801001fb:	e8 5b 27 00 00       	call   8010295b <iderw>
80100200:	83 c4 10             	add    $0x10,%esp
  }
  return b;
80100203:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80100206:	c9                   	leave  
80100207:	c3                   	ret    

80100208 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
80100208:	55                   	push   %ebp
80100209:	89 e5                	mov    %esp,%ebp
8010020b:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
8010020e:	8b 45 08             	mov    0x8(%ebp),%eax
80100211:	83 c0 0c             	add    $0xc,%eax
80100214:	83 ec 0c             	sub    $0xc,%esp
80100217:	50                   	push   %eax
80100218:	e8 8b 4e 00 00       	call   801050a8 <holdingsleep>
8010021d:	83 c4 10             	add    $0x10,%esp
80100220:	85 c0                	test   %eax,%eax
80100222:	75 0d                	jne    80100231 <bwrite+0x29>
    panic("bwrite");
80100224:	83 ec 0c             	sub    $0xc,%esp
80100227:	68 c3 85 10 80       	push   $0x801085c3
8010022c:	e8 84 03 00 00       	call   801005b5 <panic>
  b->flags |= B_DIRTY;
80100231:	8b 45 08             	mov    0x8(%ebp),%eax
80100234:	8b 00                	mov    (%eax),%eax
80100236:	83 c8 04             	or     $0x4,%eax
80100239:	89 c2                	mov    %eax,%edx
8010023b:	8b 45 08             	mov    0x8(%ebp),%eax
8010023e:	89 10                	mov    %edx,(%eax)
  iderw(b);
80100240:	83 ec 0c             	sub    $0xc,%esp
80100243:	ff 75 08             	push   0x8(%ebp)
80100246:	e8 10 27 00 00       	call   8010295b <iderw>
8010024b:	83 c4 10             	add    $0x10,%esp
}
8010024e:	90                   	nop
8010024f:	c9                   	leave  
80100250:	c3                   	ret    

80100251 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100251:	55                   	push   %ebp
80100252:	89 e5                	mov    %esp,%ebp
80100254:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
80100257:	8b 45 08             	mov    0x8(%ebp),%eax
8010025a:	83 c0 0c             	add    $0xc,%eax
8010025d:	83 ec 0c             	sub    $0xc,%esp
80100260:	50                   	push   %eax
80100261:	e8 42 4e 00 00       	call   801050a8 <holdingsleep>
80100266:	83 c4 10             	add    $0x10,%esp
80100269:	85 c0                	test   %eax,%eax
8010026b:	75 0d                	jne    8010027a <brelse+0x29>
    panic("brelse");
8010026d:	83 ec 0c             	sub    $0xc,%esp
80100270:	68 ca 85 10 80       	push   $0x801085ca
80100275:	e8 3b 03 00 00       	call   801005b5 <panic>

  releasesleep(&b->lock);
8010027a:	8b 45 08             	mov    0x8(%ebp),%eax
8010027d:	83 c0 0c             	add    $0xc,%eax
80100280:	83 ec 0c             	sub    $0xc,%esp
80100283:	50                   	push   %eax
80100284:	e8 d1 4d 00 00       	call   8010505a <releasesleep>
80100289:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
8010028c:	83 ec 0c             	sub    $0xc,%esp
8010028f:	68 80 b5 10 80       	push   $0x8010b580
80100294:	e8 c6 4e 00 00       	call   8010515f <acquire>
80100299:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
8010029c:	8b 45 08             	mov    0x8(%ebp),%eax
8010029f:	8b 40 4c             	mov    0x4c(%eax),%eax
801002a2:	8d 50 ff             	lea    -0x1(%eax),%edx
801002a5:	8b 45 08             	mov    0x8(%ebp),%eax
801002a8:	89 50 4c             	mov    %edx,0x4c(%eax)
  if (b->refcnt == 0) {
801002ab:	8b 45 08             	mov    0x8(%ebp),%eax
801002ae:	8b 40 4c             	mov    0x4c(%eax),%eax
801002b1:	85 c0                	test   %eax,%eax
801002b3:	75 47                	jne    801002fc <brelse+0xab>
    // no one is waiting for it.
    b->next->prev = b->prev;
801002b5:	8b 45 08             	mov    0x8(%ebp),%eax
801002b8:	8b 40 54             	mov    0x54(%eax),%eax
801002bb:	8b 55 08             	mov    0x8(%ebp),%edx
801002be:	8b 52 50             	mov    0x50(%edx),%edx
801002c1:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
801002c4:	8b 45 08             	mov    0x8(%ebp),%eax
801002c7:	8b 40 50             	mov    0x50(%eax),%eax
801002ca:	8b 55 08             	mov    0x8(%ebp),%edx
801002cd:	8b 52 54             	mov    0x54(%edx),%edx
801002d0:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
801002d3:	8b 15 d0 fc 10 80    	mov    0x8010fcd0,%edx
801002d9:	8b 45 08             	mov    0x8(%ebp),%eax
801002dc:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801002df:	8b 45 08             	mov    0x8(%ebp),%eax
801002e2:	c7 40 50 7c fc 10 80 	movl   $0x8010fc7c,0x50(%eax)
    bcache.head.next->prev = b;
801002e9:	a1 d0 fc 10 80       	mov    0x8010fcd0,%eax
801002ee:	8b 55 08             	mov    0x8(%ebp),%edx
801002f1:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801002f4:	8b 45 08             	mov    0x8(%ebp),%eax
801002f7:	a3 d0 fc 10 80       	mov    %eax,0x8010fcd0
  }
  
  release(&bcache.lock);
801002fc:	83 ec 0c             	sub    $0xc,%esp
801002ff:	68 80 b5 10 80       	push   $0x8010b580
80100304:	e8 c4 4e 00 00       	call   801051cd <release>
80100309:	83 c4 10             	add    $0x10,%esp
}
8010030c:	90                   	nop
8010030d:	c9                   	leave  
8010030e:	c3                   	ret    

8010030f <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010030f:	55                   	push   %ebp
80100310:	89 e5                	mov    %esp,%ebp
80100312:	83 ec 14             	sub    $0x14,%esp
80100315:	8b 45 08             	mov    0x8(%ebp),%eax
80100318:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010031c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80100320:	89 c2                	mov    %eax,%edx
80100322:	ec                   	in     (%dx),%al
80100323:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80100326:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010032a:	c9                   	leave  
8010032b:	c3                   	ret    

8010032c <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010032c:	55                   	push   %ebp
8010032d:	89 e5                	mov    %esp,%ebp
8010032f:	83 ec 08             	sub    $0x8,%esp
80100332:	8b 45 08             	mov    0x8(%ebp),%eax
80100335:	8b 55 0c             	mov    0xc(%ebp),%edx
80100338:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010033c:	89 d0                	mov    %edx,%eax
8010033e:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100341:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80100345:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80100349:	ee                   	out    %al,(%dx)
}
8010034a:	90                   	nop
8010034b:	c9                   	leave  
8010034c:	c3                   	ret    

8010034d <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
8010034d:	55                   	push   %ebp
8010034e:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100350:	fa                   	cli    
}
80100351:	90                   	nop
80100352:	5d                   	pop    %ebp
80100353:	c3                   	ret    

80100354 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100354:	55                   	push   %ebp
80100355:	89 e5                	mov    %esp,%ebp
80100357:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010035a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010035e:	74 1c                	je     8010037c <printint+0x28>
80100360:	8b 45 08             	mov    0x8(%ebp),%eax
80100363:	c1 e8 1f             	shr    $0x1f,%eax
80100366:	0f b6 c0             	movzbl %al,%eax
80100369:	89 45 10             	mov    %eax,0x10(%ebp)
8010036c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100370:	74 0a                	je     8010037c <printint+0x28>
    x = -xx;
80100372:	8b 45 08             	mov    0x8(%ebp),%eax
80100375:	f7 d8                	neg    %eax
80100377:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010037a:	eb 06                	jmp    80100382 <printint+0x2e>
  else
    x = xx;
8010037c:	8b 45 08             	mov    0x8(%ebp),%eax
8010037f:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100382:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100389:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010038c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010038f:	ba 00 00 00 00       	mov    $0x0,%edx
80100394:	f7 f1                	div    %ecx
80100396:	89 d1                	mov    %edx,%ecx
80100398:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010039b:	8d 50 01             	lea    0x1(%eax),%edx
8010039e:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003a1:	0f b6 91 04 90 10 80 	movzbl -0x7fef6ffc(%ecx),%edx
801003a8:	88 54 05 e0          	mov    %dl,-0x20(%ebp,%eax,1)
  }while((x /= base) != 0);
801003ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801003af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801003b2:	ba 00 00 00 00       	mov    $0x0,%edx
801003b7:	f7 f1                	div    %ecx
801003b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801003bc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801003c0:	75 c7                	jne    80100389 <printint+0x35>

  if(sign)
801003c2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801003c6:	74 2a                	je     801003f2 <printint+0x9e>
    buf[i++] = '-';
801003c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003cb:	8d 50 01             	lea    0x1(%eax),%edx
801003ce:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003d1:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
801003d6:	eb 1a                	jmp    801003f2 <printint+0x9e>
    consputc(buf[i]);
801003d8:	8d 55 e0             	lea    -0x20(%ebp),%edx
801003db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003de:	01 d0                	add    %edx,%eax
801003e0:	0f b6 00             	movzbl (%eax),%eax
801003e3:	0f be c0             	movsbl %al,%eax
801003e6:	83 ec 0c             	sub    $0xc,%esp
801003e9:	50                   	push   %eax
801003ea:	e8 f9 03 00 00       	call   801007e8 <consputc>
801003ef:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
801003f2:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003f6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003fa:	79 dc                	jns    801003d8 <printint+0x84>
}
801003fc:	90                   	nop
801003fd:	90                   	nop
801003fe:	c9                   	leave  
801003ff:	c3                   	ret    

80100400 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
80100400:	55                   	push   %ebp
80100401:	89 e5                	mov    %esp,%ebp
80100403:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
80100406:	a1 b4 ff 10 80       	mov    0x8010ffb4,%eax
8010040b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
8010040e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100412:	74 10                	je     80100424 <cprintf+0x24>
    acquire(&cons.lock);
80100414:	83 ec 0c             	sub    $0xc,%esp
80100417:	68 80 ff 10 80       	push   $0x8010ff80
8010041c:	e8 3e 4d 00 00       	call   8010515f <acquire>
80100421:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100424:	8b 45 08             	mov    0x8(%ebp),%eax
80100427:	85 c0                	test   %eax,%eax
80100429:	75 0d                	jne    80100438 <cprintf+0x38>
    panic("null fmt");
8010042b:	83 ec 0c             	sub    $0xc,%esp
8010042e:	68 d1 85 10 80       	push   $0x801085d1
80100433:	e8 7d 01 00 00       	call   801005b5 <panic>

  argp = (uint*)(void*)(&fmt + 1);
80100438:	8d 45 0c             	lea    0xc(%ebp),%eax
8010043b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010043e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100445:	e9 2f 01 00 00       	jmp    80100579 <cprintf+0x179>
    if(c != '%'){
8010044a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
8010044e:	74 13                	je     80100463 <cprintf+0x63>
      consputc(c);
80100450:	83 ec 0c             	sub    $0xc,%esp
80100453:	ff 75 e4             	push   -0x1c(%ebp)
80100456:	e8 8d 03 00 00       	call   801007e8 <consputc>
8010045b:	83 c4 10             	add    $0x10,%esp
      continue;
8010045e:	e9 12 01 00 00       	jmp    80100575 <cprintf+0x175>
    }
    c = fmt[++i] & 0xff;
80100463:	8b 55 08             	mov    0x8(%ebp),%edx
80100466:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010046a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010046d:	01 d0                	add    %edx,%eax
8010046f:	0f b6 00             	movzbl (%eax),%eax
80100472:	0f be c0             	movsbl %al,%eax
80100475:	25 ff 00 00 00       	and    $0xff,%eax
8010047a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
8010047d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100481:	0f 84 14 01 00 00    	je     8010059b <cprintf+0x19b>
      break;
    switch(c){
80100487:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
8010048b:	74 5e                	je     801004eb <cprintf+0xeb>
8010048d:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
80100491:	0f 8f c2 00 00 00    	jg     80100559 <cprintf+0x159>
80100497:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
8010049b:	74 6b                	je     80100508 <cprintf+0x108>
8010049d:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
801004a1:	0f 8f b2 00 00 00    	jg     80100559 <cprintf+0x159>
801004a7:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
801004ab:	74 3e                	je     801004eb <cprintf+0xeb>
801004ad:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
801004b1:	0f 8f a2 00 00 00    	jg     80100559 <cprintf+0x159>
801004b7:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801004bb:	0f 84 89 00 00 00    	je     8010054a <cprintf+0x14a>
801004c1:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
801004c5:	0f 85 8e 00 00 00    	jne    80100559 <cprintf+0x159>
    case 'd':
      printint(*argp++, 10, 1);
801004cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004ce:	8d 50 04             	lea    0x4(%eax),%edx
801004d1:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004d4:	8b 00                	mov    (%eax),%eax
801004d6:	83 ec 04             	sub    $0x4,%esp
801004d9:	6a 01                	push   $0x1
801004db:	6a 0a                	push   $0xa
801004dd:	50                   	push   %eax
801004de:	e8 71 fe ff ff       	call   80100354 <printint>
801004e3:	83 c4 10             	add    $0x10,%esp
      break;
801004e6:	e9 8a 00 00 00       	jmp    80100575 <cprintf+0x175>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
801004eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004ee:	8d 50 04             	lea    0x4(%eax),%edx
801004f1:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004f4:	8b 00                	mov    (%eax),%eax
801004f6:	83 ec 04             	sub    $0x4,%esp
801004f9:	6a 00                	push   $0x0
801004fb:	6a 10                	push   $0x10
801004fd:	50                   	push   %eax
801004fe:	e8 51 fe ff ff       	call   80100354 <printint>
80100503:	83 c4 10             	add    $0x10,%esp
      break;
80100506:	eb 6d                	jmp    80100575 <cprintf+0x175>
    case 's':
      if((s = (char*)*argp++) == 0)
80100508:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010050b:	8d 50 04             	lea    0x4(%eax),%edx
8010050e:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100511:	8b 00                	mov    (%eax),%eax
80100513:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100516:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010051a:	75 22                	jne    8010053e <cprintf+0x13e>
        s = "(null)";
8010051c:	c7 45 ec da 85 10 80 	movl   $0x801085da,-0x14(%ebp)
      for(; *s; s++)
80100523:	eb 19                	jmp    8010053e <cprintf+0x13e>
        consputc(*s);
80100525:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100528:	0f b6 00             	movzbl (%eax),%eax
8010052b:	0f be c0             	movsbl %al,%eax
8010052e:	83 ec 0c             	sub    $0xc,%esp
80100531:	50                   	push   %eax
80100532:	e8 b1 02 00 00       	call   801007e8 <consputc>
80100537:	83 c4 10             	add    $0x10,%esp
      for(; *s; s++)
8010053a:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010053e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100541:	0f b6 00             	movzbl (%eax),%eax
80100544:	84 c0                	test   %al,%al
80100546:	75 dd                	jne    80100525 <cprintf+0x125>
      break;
80100548:	eb 2b                	jmp    80100575 <cprintf+0x175>
    case '%':
      consputc('%');
8010054a:	83 ec 0c             	sub    $0xc,%esp
8010054d:	6a 25                	push   $0x25
8010054f:	e8 94 02 00 00       	call   801007e8 <consputc>
80100554:	83 c4 10             	add    $0x10,%esp
      break;
80100557:	eb 1c                	jmp    80100575 <cprintf+0x175>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
80100559:	83 ec 0c             	sub    $0xc,%esp
8010055c:	6a 25                	push   $0x25
8010055e:	e8 85 02 00 00       	call   801007e8 <consputc>
80100563:	83 c4 10             	add    $0x10,%esp
      consputc(c);
80100566:	83 ec 0c             	sub    $0xc,%esp
80100569:	ff 75 e4             	push   -0x1c(%ebp)
8010056c:	e8 77 02 00 00       	call   801007e8 <consputc>
80100571:	83 c4 10             	add    $0x10,%esp
      break;
80100574:	90                   	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100575:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100579:	8b 55 08             	mov    0x8(%ebp),%edx
8010057c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010057f:	01 d0                	add    %edx,%eax
80100581:	0f b6 00             	movzbl (%eax),%eax
80100584:	0f be c0             	movsbl %al,%eax
80100587:	25 ff 00 00 00       	and    $0xff,%eax
8010058c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010058f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100593:	0f 85 b1 fe ff ff    	jne    8010044a <cprintf+0x4a>
80100599:	eb 01                	jmp    8010059c <cprintf+0x19c>
      break;
8010059b:	90                   	nop
    }
  }

  if(locking)
8010059c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801005a0:	74 10                	je     801005b2 <cprintf+0x1b2>
    release(&cons.lock);
801005a2:	83 ec 0c             	sub    $0xc,%esp
801005a5:	68 80 ff 10 80       	push   $0x8010ff80
801005aa:	e8 1e 4c 00 00       	call   801051cd <release>
801005af:	83 c4 10             	add    $0x10,%esp
}
801005b2:	90                   	nop
801005b3:	c9                   	leave  
801005b4:	c3                   	ret    

801005b5 <panic>:

void
panic(char *s)
{
801005b5:	55                   	push   %ebp
801005b6:	89 e5                	mov    %esp,%ebp
801005b8:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];

  cli();
801005bb:	e8 8d fd ff ff       	call   8010034d <cli>
  cons.locking = 0;
801005c0:	c7 05 b4 ff 10 80 00 	movl   $0x0,0x8010ffb4
801005c7:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
801005ca:	e8 21 2a 00 00       	call   80102ff0 <lapicid>
801005cf:	83 ec 08             	sub    $0x8,%esp
801005d2:	50                   	push   %eax
801005d3:	68 e1 85 10 80       	push   $0x801085e1
801005d8:	e8 23 fe ff ff       	call   80100400 <cprintf>
801005dd:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
801005e0:	8b 45 08             	mov    0x8(%ebp),%eax
801005e3:	83 ec 0c             	sub    $0xc,%esp
801005e6:	50                   	push   %eax
801005e7:	e8 14 fe ff ff       	call   80100400 <cprintf>
801005ec:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005ef:	83 ec 0c             	sub    $0xc,%esp
801005f2:	68 f5 85 10 80       	push   $0x801085f5
801005f7:	e8 04 fe ff ff       	call   80100400 <cprintf>
801005fc:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005ff:	83 ec 08             	sub    $0x8,%esp
80100602:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100605:	50                   	push   %eax
80100606:	8d 45 08             	lea    0x8(%ebp),%eax
80100609:	50                   	push   %eax
8010060a:	e8 10 4c 00 00       	call   8010521f <getcallerpcs>
8010060f:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100612:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100619:	eb 1c                	jmp    80100637 <panic+0x82>
    cprintf(" %p", pcs[i]);
8010061b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010061e:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100622:	83 ec 08             	sub    $0x8,%esp
80100625:	50                   	push   %eax
80100626:	68 f7 85 10 80       	push   $0x801085f7
8010062b:	e8 d0 fd ff ff       	call   80100400 <cprintf>
80100630:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100633:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100637:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010063b:	7e de                	jle    8010061b <panic+0x66>
  panicked = 1; // freeze other CPU
8010063d:	c7 05 6c ff 10 80 01 	movl   $0x1,0x8010ff6c
80100644:	00 00 00 
  for(;;)
80100647:	eb fe                	jmp    80100647 <panic+0x92>

80100649 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
80100649:	55                   	push   %ebp
8010064a:	89 e5                	mov    %esp,%ebp
8010064c:	53                   	push   %ebx
8010064d:	83 ec 14             	sub    $0x14,%esp
  int pos;

  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
80100650:	6a 0e                	push   $0xe
80100652:	68 d4 03 00 00       	push   $0x3d4
80100657:	e8 d0 fc ff ff       	call   8010032c <outb>
8010065c:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
8010065f:	68 d5 03 00 00       	push   $0x3d5
80100664:	e8 a6 fc ff ff       	call   8010030f <inb>
80100669:	83 c4 04             	add    $0x4,%esp
8010066c:	0f b6 c0             	movzbl %al,%eax
8010066f:	c1 e0 08             	shl    $0x8,%eax
80100672:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
80100675:	6a 0f                	push   $0xf
80100677:	68 d4 03 00 00       	push   $0x3d4
8010067c:	e8 ab fc ff ff       	call   8010032c <outb>
80100681:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
80100684:	68 d5 03 00 00       	push   $0x3d5
80100689:	e8 81 fc ff ff       	call   8010030f <inb>
8010068e:	83 c4 04             	add    $0x4,%esp
80100691:	0f b6 c0             	movzbl %al,%eax
80100694:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
80100697:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
8010069b:	75 34                	jne    801006d1 <cgaputc+0x88>
    pos += 80 - pos%80;
8010069d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006a0:	ba 67 66 66 66       	mov    $0x66666667,%edx
801006a5:	89 c8                	mov    %ecx,%eax
801006a7:	f7 ea                	imul   %edx
801006a9:	89 d0                	mov    %edx,%eax
801006ab:	c1 f8 05             	sar    $0x5,%eax
801006ae:	89 cb                	mov    %ecx,%ebx
801006b0:	c1 fb 1f             	sar    $0x1f,%ebx
801006b3:	29 d8                	sub    %ebx,%eax
801006b5:	89 c2                	mov    %eax,%edx
801006b7:	89 d0                	mov    %edx,%eax
801006b9:	c1 e0 02             	shl    $0x2,%eax
801006bc:	01 d0                	add    %edx,%eax
801006be:	c1 e0 04             	shl    $0x4,%eax
801006c1:	29 c1                	sub    %eax,%ecx
801006c3:	89 ca                	mov    %ecx,%edx
801006c5:	b8 50 00 00 00       	mov    $0x50,%eax
801006ca:	29 d0                	sub    %edx,%eax
801006cc:	01 45 f4             	add    %eax,-0xc(%ebp)
801006cf:	eb 38                	jmp    80100709 <cgaputc+0xc0>
  else if(c == BACKSPACE){
801006d1:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801006d8:	75 0c                	jne    801006e6 <cgaputc+0x9d>
    if(pos > 0) --pos;
801006da:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801006de:	7e 29                	jle    80100709 <cgaputc+0xc0>
801006e0:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801006e4:	eb 23                	jmp    80100709 <cgaputc+0xc0>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
801006e6:	8b 45 08             	mov    0x8(%ebp),%eax
801006e9:	0f b6 c0             	movzbl %al,%eax
801006ec:	80 cc 07             	or     $0x7,%ah
801006ef:	89 c1                	mov    %eax,%ecx
801006f1:	8b 1d 00 90 10 80    	mov    0x80109000,%ebx
801006f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006fa:	8d 50 01             	lea    0x1(%eax),%edx
801006fd:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100700:	01 c0                	add    %eax,%eax
80100702:	01 d8                	add    %ebx,%eax
80100704:	89 ca                	mov    %ecx,%edx
80100706:	66 89 10             	mov    %dx,(%eax)

  if(pos < 0 || pos > 25*80)
80100709:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010070d:	78 09                	js     80100718 <cgaputc+0xcf>
8010070f:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
80100716:	7e 0d                	jle    80100725 <cgaputc+0xdc>
    panic("pos under/overflow");
80100718:	83 ec 0c             	sub    $0xc,%esp
8010071b:	68 fb 85 10 80       	push   $0x801085fb
80100720:	e8 90 fe ff ff       	call   801005b5 <panic>

  if((pos/80) >= 24){  // Scroll up.
80100725:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
8010072c:	7e 4d                	jle    8010077b <cgaputc+0x132>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
8010072e:	a1 00 90 10 80       	mov    0x80109000,%eax
80100733:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
80100739:	a1 00 90 10 80       	mov    0x80109000,%eax
8010073e:	83 ec 04             	sub    $0x4,%esp
80100741:	68 60 0e 00 00       	push   $0xe60
80100746:	52                   	push   %edx
80100747:	50                   	push   %eax
80100748:	e8 57 4d 00 00       	call   801054a4 <memmove>
8010074d:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
80100750:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100754:	b8 80 07 00 00       	mov    $0x780,%eax
80100759:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010075c:	8d 14 00             	lea    (%eax,%eax,1),%edx
8010075f:	8b 0d 00 90 10 80    	mov    0x80109000,%ecx
80100765:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100768:	01 c0                	add    %eax,%eax
8010076a:	01 c8                	add    %ecx,%eax
8010076c:	83 ec 04             	sub    $0x4,%esp
8010076f:	52                   	push   %edx
80100770:	6a 00                	push   $0x0
80100772:	50                   	push   %eax
80100773:	e8 6d 4c 00 00       	call   801053e5 <memset>
80100778:	83 c4 10             	add    $0x10,%esp
  }

  outb(CRTPORT, 14);
8010077b:	83 ec 08             	sub    $0x8,%esp
8010077e:	6a 0e                	push   $0xe
80100780:	68 d4 03 00 00       	push   $0x3d4
80100785:	e8 a2 fb ff ff       	call   8010032c <outb>
8010078a:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos>>8);
8010078d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100790:	c1 f8 08             	sar    $0x8,%eax
80100793:	0f b6 c0             	movzbl %al,%eax
80100796:	83 ec 08             	sub    $0x8,%esp
80100799:	50                   	push   %eax
8010079a:	68 d5 03 00 00       	push   $0x3d5
8010079f:	e8 88 fb ff ff       	call   8010032c <outb>
801007a4:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT, 15);
801007a7:	83 ec 08             	sub    $0x8,%esp
801007aa:	6a 0f                	push   $0xf
801007ac:	68 d4 03 00 00       	push   $0x3d4
801007b1:	e8 76 fb ff ff       	call   8010032c <outb>
801007b6:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos);
801007b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007bc:	0f b6 c0             	movzbl %al,%eax
801007bf:	83 ec 08             	sub    $0x8,%esp
801007c2:	50                   	push   %eax
801007c3:	68 d5 03 00 00       	push   $0x3d5
801007c8:	e8 5f fb ff ff       	call   8010032c <outb>
801007cd:	83 c4 10             	add    $0x10,%esp
  crt[pos] = ' ' | 0x0700;
801007d0:	8b 15 00 90 10 80    	mov    0x80109000,%edx
801007d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007d9:	01 c0                	add    %eax,%eax
801007db:	01 d0                	add    %edx,%eax
801007dd:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
801007e2:	90                   	nop
801007e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801007e6:	c9                   	leave  
801007e7:	c3                   	ret    

801007e8 <consputc>:

void
consputc(int c)
{
801007e8:	55                   	push   %ebp
801007e9:	89 e5                	mov    %esp,%ebp
801007eb:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
801007ee:	a1 6c ff 10 80       	mov    0x8010ff6c,%eax
801007f3:	85 c0                	test   %eax,%eax
801007f5:	74 07                	je     801007fe <consputc+0x16>
    cli();
801007f7:	e8 51 fb ff ff       	call   8010034d <cli>
    for(;;)
801007fc:	eb fe                	jmp    801007fc <consputc+0x14>
      ;
  }

  if(c == BACKSPACE){
801007fe:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100805:	75 29                	jne    80100830 <consputc+0x48>
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100807:	83 ec 0c             	sub    $0xc,%esp
8010080a:	6a 08                	push   $0x8
8010080c:	e8 42 65 00 00       	call   80106d53 <uartputc>
80100811:	83 c4 10             	add    $0x10,%esp
80100814:	83 ec 0c             	sub    $0xc,%esp
80100817:	6a 20                	push   $0x20
80100819:	e8 35 65 00 00       	call   80106d53 <uartputc>
8010081e:	83 c4 10             	add    $0x10,%esp
80100821:	83 ec 0c             	sub    $0xc,%esp
80100824:	6a 08                	push   $0x8
80100826:	e8 28 65 00 00       	call   80106d53 <uartputc>
8010082b:	83 c4 10             	add    $0x10,%esp
8010082e:	eb 0e                	jmp    8010083e <consputc+0x56>
  } else
    uartputc(c);
80100830:	83 ec 0c             	sub    $0xc,%esp
80100833:	ff 75 08             	push   0x8(%ebp)
80100836:	e8 18 65 00 00       	call   80106d53 <uartputc>
8010083b:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
8010083e:	83 ec 0c             	sub    $0xc,%esp
80100841:	ff 75 08             	push   0x8(%ebp)
80100844:	e8 00 fe ff ff       	call   80100649 <cgaputc>
80100849:	83 c4 10             	add    $0x10,%esp
}
8010084c:	90                   	nop
8010084d:	c9                   	leave  
8010084e:	c3                   	ret    

8010084f <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
8010084f:	55                   	push   %ebp
80100850:	89 e5                	mov    %esp,%ebp
80100852:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
80100855:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
8010085c:	83 ec 0c             	sub    $0xc,%esp
8010085f:	68 80 ff 10 80       	push   $0x8010ff80
80100864:	e8 f6 48 00 00       	call   8010515f <acquire>
80100869:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
8010086c:	e9 50 01 00 00       	jmp    801009c1 <consoleintr+0x172>
    switch(c){
80100871:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80100875:	0f 84 81 00 00 00    	je     801008fc <consoleintr+0xad>
8010087b:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
8010087f:	0f 8f ac 00 00 00    	jg     80100931 <consoleintr+0xe2>
80100885:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100889:	74 43                	je     801008ce <consoleintr+0x7f>
8010088b:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
8010088f:	0f 8f 9c 00 00 00    	jg     80100931 <consoleintr+0xe2>
80100895:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
80100899:	74 61                	je     801008fc <consoleintr+0xad>
8010089b:	83 7d f0 10          	cmpl   $0x10,-0x10(%ebp)
8010089f:	0f 85 8c 00 00 00    	jne    80100931 <consoleintr+0xe2>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
801008a5:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
801008ac:	e9 10 01 00 00       	jmp    801009c1 <consoleintr+0x172>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
801008b1:	a1 68 ff 10 80       	mov    0x8010ff68,%eax
801008b6:	83 e8 01             	sub    $0x1,%eax
801008b9:	a3 68 ff 10 80       	mov    %eax,0x8010ff68
        consputc(BACKSPACE);
801008be:	83 ec 0c             	sub    $0xc,%esp
801008c1:	68 00 01 00 00       	push   $0x100
801008c6:	e8 1d ff ff ff       	call   801007e8 <consputc>
801008cb:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
801008ce:	8b 15 68 ff 10 80    	mov    0x8010ff68,%edx
801008d4:	a1 64 ff 10 80       	mov    0x8010ff64,%eax
801008d9:	39 c2                	cmp    %eax,%edx
801008db:	0f 84 e0 00 00 00    	je     801009c1 <consoleintr+0x172>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
801008e1:	a1 68 ff 10 80       	mov    0x8010ff68,%eax
801008e6:	83 e8 01             	sub    $0x1,%eax
801008e9:	83 e0 7f             	and    $0x7f,%eax
801008ec:	0f b6 80 e0 fe 10 80 	movzbl -0x7fef0120(%eax),%eax
      while(input.e != input.w &&
801008f3:	3c 0a                	cmp    $0xa,%al
801008f5:	75 ba                	jne    801008b1 <consoleintr+0x62>
      }
      break;
801008f7:	e9 c5 00 00 00       	jmp    801009c1 <consoleintr+0x172>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
801008fc:	8b 15 68 ff 10 80    	mov    0x8010ff68,%edx
80100902:	a1 64 ff 10 80       	mov    0x8010ff64,%eax
80100907:	39 c2                	cmp    %eax,%edx
80100909:	0f 84 b2 00 00 00    	je     801009c1 <consoleintr+0x172>
        input.e--;
8010090f:	a1 68 ff 10 80       	mov    0x8010ff68,%eax
80100914:	83 e8 01             	sub    $0x1,%eax
80100917:	a3 68 ff 10 80       	mov    %eax,0x8010ff68
        consputc(BACKSPACE);
8010091c:	83 ec 0c             	sub    $0xc,%esp
8010091f:	68 00 01 00 00       	push   $0x100
80100924:	e8 bf fe ff ff       	call   801007e8 <consputc>
80100929:	83 c4 10             	add    $0x10,%esp
      }
      break;
8010092c:	e9 90 00 00 00       	jmp    801009c1 <consoleintr+0x172>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100931:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100935:	0f 84 85 00 00 00    	je     801009c0 <consoleintr+0x171>
8010093b:	a1 68 ff 10 80       	mov    0x8010ff68,%eax
80100940:	8b 15 60 ff 10 80    	mov    0x8010ff60,%edx
80100946:	29 d0                	sub    %edx,%eax
80100948:	83 f8 7f             	cmp    $0x7f,%eax
8010094b:	77 73                	ja     801009c0 <consoleintr+0x171>
        c = (c == '\r') ? '\n' : c;
8010094d:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80100951:	74 05                	je     80100958 <consoleintr+0x109>
80100953:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100956:	eb 05                	jmp    8010095d <consoleintr+0x10e>
80100958:	b8 0a 00 00 00       	mov    $0xa,%eax
8010095d:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
80100960:	a1 68 ff 10 80       	mov    0x8010ff68,%eax
80100965:	8d 50 01             	lea    0x1(%eax),%edx
80100968:	89 15 68 ff 10 80    	mov    %edx,0x8010ff68
8010096e:	83 e0 7f             	and    $0x7f,%eax
80100971:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100974:	88 90 e0 fe 10 80    	mov    %dl,-0x7fef0120(%eax)
        consputc(c);
8010097a:	83 ec 0c             	sub    $0xc,%esp
8010097d:	ff 75 f0             	push   -0x10(%ebp)
80100980:	e8 63 fe ff ff       	call   801007e8 <consputc>
80100985:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100988:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
8010098c:	74 18                	je     801009a6 <consoleintr+0x157>
8010098e:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100992:	74 12                	je     801009a6 <consoleintr+0x157>
80100994:	a1 68 ff 10 80       	mov    0x8010ff68,%eax
80100999:	8b 15 60 ff 10 80    	mov    0x8010ff60,%edx
8010099f:	83 ea 80             	sub    $0xffffff80,%edx
801009a2:	39 d0                	cmp    %edx,%eax
801009a4:	75 1a                	jne    801009c0 <consoleintr+0x171>
          input.w = input.e;
801009a6:	a1 68 ff 10 80       	mov    0x8010ff68,%eax
801009ab:	a3 64 ff 10 80       	mov    %eax,0x8010ff64
          wakeup(&input.r);
801009b0:	83 ec 0c             	sub    $0xc,%esp
801009b3:	68 60 ff 10 80       	push   $0x8010ff60
801009b8:	e8 3c 43 00 00       	call   80104cf9 <wakeup>
801009bd:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
801009c0:	90                   	nop
  while((c = getc()) >= 0){
801009c1:	8b 45 08             	mov    0x8(%ebp),%eax
801009c4:	ff d0                	call   *%eax
801009c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801009c9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801009cd:	0f 89 9e fe ff ff    	jns    80100871 <consoleintr+0x22>
    }
  }
  release(&cons.lock);
801009d3:	83 ec 0c             	sub    $0xc,%esp
801009d6:	68 80 ff 10 80       	push   $0x8010ff80
801009db:	e8 ed 47 00 00       	call   801051cd <release>
801009e0:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
801009e3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801009e7:	74 05                	je     801009ee <consoleintr+0x19f>
    procdump();  // now call procdump() wo. cons.lock held
801009e9:	e8 c9 43 00 00       	call   80104db7 <procdump>
  }
}
801009ee:	90                   	nop
801009ef:	c9                   	leave  
801009f0:	c3                   	ret    

801009f1 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
801009f1:	55                   	push   %ebp
801009f2:	89 e5                	mov    %esp,%ebp
801009f4:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
801009f7:	83 ec 0c             	sub    $0xc,%esp
801009fa:	ff 75 08             	push   0x8(%ebp)
801009fd:	e8 2b 11 00 00       	call   80101b2d <iunlock>
80100a02:	83 c4 10             	add    $0x10,%esp
  target = n;
80100a05:	8b 45 10             	mov    0x10(%ebp),%eax
80100a08:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100a0b:	83 ec 0c             	sub    $0xc,%esp
80100a0e:	68 80 ff 10 80       	push   $0x8010ff80
80100a13:	e8 47 47 00 00       	call   8010515f <acquire>
80100a18:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
80100a1b:	e9 ab 00 00 00       	jmp    80100acb <consoleread+0xda>
    while(input.r == input.w){
      if(myproc()->killed){
80100a20:	e8 74 38 00 00       	call   80104299 <myproc>
80100a25:	8b 40 24             	mov    0x24(%eax),%eax
80100a28:	85 c0                	test   %eax,%eax
80100a2a:	74 28                	je     80100a54 <consoleread+0x63>
        release(&cons.lock);
80100a2c:	83 ec 0c             	sub    $0xc,%esp
80100a2f:	68 80 ff 10 80       	push   $0x8010ff80
80100a34:	e8 94 47 00 00       	call   801051cd <release>
80100a39:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80100a3c:	83 ec 0c             	sub    $0xc,%esp
80100a3f:	ff 75 08             	push   0x8(%ebp)
80100a42:	e8 d3 0f 00 00       	call   80101a1a <ilock>
80100a47:	83 c4 10             	add    $0x10,%esp
        return -1;
80100a4a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100a4f:	e9 a9 00 00 00       	jmp    80100afd <consoleread+0x10c>
      }
      sleep(&input.r, &cons.lock);
80100a54:	83 ec 08             	sub    $0x8,%esp
80100a57:	68 80 ff 10 80       	push   $0x8010ff80
80100a5c:	68 60 ff 10 80       	push   $0x8010ff60
80100a61:	e8 a9 41 00 00       	call   80104c0f <sleep>
80100a66:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
80100a69:	8b 15 60 ff 10 80    	mov    0x8010ff60,%edx
80100a6f:	a1 64 ff 10 80       	mov    0x8010ff64,%eax
80100a74:	39 c2                	cmp    %eax,%edx
80100a76:	74 a8                	je     80100a20 <consoleread+0x2f>
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a78:	a1 60 ff 10 80       	mov    0x8010ff60,%eax
80100a7d:	8d 50 01             	lea    0x1(%eax),%edx
80100a80:	89 15 60 ff 10 80    	mov    %edx,0x8010ff60
80100a86:	83 e0 7f             	and    $0x7f,%eax
80100a89:	0f b6 80 e0 fe 10 80 	movzbl -0x7fef0120(%eax),%eax
80100a90:	0f be c0             	movsbl %al,%eax
80100a93:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a96:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a9a:	75 17                	jne    80100ab3 <consoleread+0xc2>
      if(n < target){
80100a9c:	8b 45 10             	mov    0x10(%ebp),%eax
80100a9f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100aa2:	76 2f                	jbe    80100ad3 <consoleread+0xe2>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100aa4:	a1 60 ff 10 80       	mov    0x8010ff60,%eax
80100aa9:	83 e8 01             	sub    $0x1,%eax
80100aac:	a3 60 ff 10 80       	mov    %eax,0x8010ff60
      }
      break;
80100ab1:	eb 20                	jmp    80100ad3 <consoleread+0xe2>
    }
    *dst++ = c;
80100ab3:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ab6:	8d 50 01             	lea    0x1(%eax),%edx
80100ab9:	89 55 0c             	mov    %edx,0xc(%ebp)
80100abc:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100abf:	88 10                	mov    %dl,(%eax)
    --n;
80100ac1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100ac5:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100ac9:	74 0b                	je     80100ad6 <consoleread+0xe5>
  while(n > 0){
80100acb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100acf:	7f 98                	jg     80100a69 <consoleread+0x78>
80100ad1:	eb 04                	jmp    80100ad7 <consoleread+0xe6>
      break;
80100ad3:	90                   	nop
80100ad4:	eb 01                	jmp    80100ad7 <consoleread+0xe6>
      break;
80100ad6:	90                   	nop
  }
  release(&cons.lock);
80100ad7:	83 ec 0c             	sub    $0xc,%esp
80100ada:	68 80 ff 10 80       	push   $0x8010ff80
80100adf:	e8 e9 46 00 00       	call   801051cd <release>
80100ae4:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100ae7:	83 ec 0c             	sub    $0xc,%esp
80100aea:	ff 75 08             	push   0x8(%ebp)
80100aed:	e8 28 0f 00 00       	call   80101a1a <ilock>
80100af2:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100af5:	8b 55 10             	mov    0x10(%ebp),%edx
80100af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100afb:	29 d0                	sub    %edx,%eax
}
80100afd:	c9                   	leave  
80100afe:	c3                   	ret    

80100aff <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100aff:	55                   	push   %ebp
80100b00:	89 e5                	mov    %esp,%ebp
80100b02:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100b05:	83 ec 0c             	sub    $0xc,%esp
80100b08:	ff 75 08             	push   0x8(%ebp)
80100b0b:	e8 1d 10 00 00       	call   80101b2d <iunlock>
80100b10:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100b13:	83 ec 0c             	sub    $0xc,%esp
80100b16:	68 80 ff 10 80       	push   $0x8010ff80
80100b1b:	e8 3f 46 00 00       	call   8010515f <acquire>
80100b20:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100b23:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100b2a:	eb 21                	jmp    80100b4d <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100b2c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b2f:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b32:	01 d0                	add    %edx,%eax
80100b34:	0f b6 00             	movzbl (%eax),%eax
80100b37:	0f be c0             	movsbl %al,%eax
80100b3a:	0f b6 c0             	movzbl %al,%eax
80100b3d:	83 ec 0c             	sub    $0xc,%esp
80100b40:	50                   	push   %eax
80100b41:	e8 a2 fc ff ff       	call   801007e8 <consputc>
80100b46:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100b49:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b50:	3b 45 10             	cmp    0x10(%ebp),%eax
80100b53:	7c d7                	jl     80100b2c <consolewrite+0x2d>
  release(&cons.lock);
80100b55:	83 ec 0c             	sub    $0xc,%esp
80100b58:	68 80 ff 10 80       	push   $0x8010ff80
80100b5d:	e8 6b 46 00 00       	call   801051cd <release>
80100b62:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b65:	83 ec 0c             	sub    $0xc,%esp
80100b68:	ff 75 08             	push   0x8(%ebp)
80100b6b:	e8 aa 0e 00 00       	call   80101a1a <ilock>
80100b70:	83 c4 10             	add    $0x10,%esp

  return n;
80100b73:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100b76:	c9                   	leave  
80100b77:	c3                   	ret    

80100b78 <consoleinit>:

void
consoleinit(void)
{
80100b78:	55                   	push   %ebp
80100b79:	89 e5                	mov    %esp,%ebp
80100b7b:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100b7e:	83 ec 08             	sub    $0x8,%esp
80100b81:	68 0e 86 10 80       	push   $0x8010860e
80100b86:	68 80 ff 10 80       	push   $0x8010ff80
80100b8b:	e8 ad 45 00 00       	call   8010513d <initlock>
80100b90:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b93:	c7 05 cc ff 10 80 ff 	movl   $0x80100aff,0x8010ffcc
80100b9a:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b9d:	c7 05 c8 ff 10 80 f1 	movl   $0x801009f1,0x8010ffc8
80100ba4:	09 10 80 
  cons.locking = 1;
80100ba7:	c7 05 b4 ff 10 80 01 	movl   $0x1,0x8010ffb4
80100bae:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100bb1:	83 ec 08             	sub    $0x8,%esp
80100bb4:	6a 00                	push   $0x0
80100bb6:	6a 01                	push   $0x1
80100bb8:	e8 67 1f 00 00       	call   80102b24 <ioapicenable>
80100bbd:	83 c4 10             	add    $0x10,%esp
}
80100bc0:	90                   	nop
80100bc1:	c9                   	leave  
80100bc2:	c3                   	ret    

80100bc3 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100bc3:	55                   	push   %ebp
80100bc4:	89 e5                	mov    %esp,%ebp
80100bc6:	81 ec 18 01 00 00    	sub    $0x118,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100bcc:	e8 c8 36 00 00       	call   80104299 <myproc>
80100bd1:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100bd4:	e8 59 29 00 00       	call   80103532 <begin_op>

  if((ip = namei(path)) == 0){
80100bd9:	83 ec 0c             	sub    $0xc,%esp
80100bdc:	ff 75 08             	push   0x8(%ebp)
80100bdf:	e8 69 19 00 00       	call   8010254d <namei>
80100be4:	83 c4 10             	add    $0x10,%esp
80100be7:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100bea:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bee:	75 1f                	jne    80100c0f <exec+0x4c>
    end_op();
80100bf0:	e8 c9 29 00 00       	call   801035be <end_op>
    cprintf("exec: fail\n");
80100bf5:	83 ec 0c             	sub    $0xc,%esp
80100bf8:	68 16 86 10 80       	push   $0x80108616
80100bfd:	e8 fe f7 ff ff       	call   80100400 <cprintf>
80100c02:	83 c4 10             	add    $0x10,%esp
    return -1;
80100c05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c0a:	e9 f1 03 00 00       	jmp    80101000 <exec+0x43d>
  }
  ilock(ip);
80100c0f:	83 ec 0c             	sub    $0xc,%esp
80100c12:	ff 75 d8             	push   -0x28(%ebp)
80100c15:	e8 00 0e 00 00       	call   80101a1a <ilock>
80100c1a:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100c1d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100c24:	6a 34                	push   $0x34
80100c26:	6a 00                	push   $0x0
80100c28:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100c2e:	50                   	push   %eax
80100c2f:	ff 75 d8             	push   -0x28(%ebp)
80100c32:	e8 cf 12 00 00       	call   80101f06 <readi>
80100c37:	83 c4 10             	add    $0x10,%esp
80100c3a:	83 f8 34             	cmp    $0x34,%eax
80100c3d:	0f 85 66 03 00 00    	jne    80100fa9 <exec+0x3e6>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c43:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100c49:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c4e:	0f 85 58 03 00 00    	jne    80100fac <exec+0x3e9>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c54:	e8 f6 70 00 00       	call   80107d4f <setupkvm>
80100c59:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c5c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c60:	0f 84 49 03 00 00    	je     80100faf <exec+0x3ec>
    goto bad;

  // Load program into memory.
  sz = 0;
80100c66:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c6d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c74:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100c7a:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c7d:	e9 de 00 00 00       	jmp    80100d60 <exec+0x19d>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c82:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c85:	6a 20                	push   $0x20
80100c87:	50                   	push   %eax
80100c88:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100c8e:	50                   	push   %eax
80100c8f:	ff 75 d8             	push   -0x28(%ebp)
80100c92:	e8 6f 12 00 00       	call   80101f06 <readi>
80100c97:	83 c4 10             	add    $0x10,%esp
80100c9a:	83 f8 20             	cmp    $0x20,%eax
80100c9d:	0f 85 0f 03 00 00    	jne    80100fb2 <exec+0x3ef>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100ca3:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100ca9:	83 f8 01             	cmp    $0x1,%eax
80100cac:	0f 85 a0 00 00 00    	jne    80100d52 <exec+0x18f>
      continue;
    if(ph.memsz < ph.filesz)
80100cb2:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100cb8:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100cbe:	39 c2                	cmp    %eax,%edx
80100cc0:	0f 82 ef 02 00 00    	jb     80100fb5 <exec+0x3f2>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100cc6:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100ccc:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cd2:	01 c2                	add    %eax,%edx
80100cd4:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cda:	39 c2                	cmp    %eax,%edx
80100cdc:	0f 82 d6 02 00 00    	jb     80100fb8 <exec+0x3f5>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100ce2:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100ce8:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cee:	01 d0                	add    %edx,%eax
80100cf0:	83 ec 04             	sub    $0x4,%esp
80100cf3:	50                   	push   %eax
80100cf4:	ff 75 e0             	push   -0x20(%ebp)
80100cf7:	ff 75 d4             	push   -0x2c(%ebp)
80100cfa:	e8 f6 73 00 00       	call   801080f5 <allocuvm>
80100cff:	83 c4 10             	add    $0x10,%esp
80100d02:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d05:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d09:	0f 84 ac 02 00 00    	je     80100fbb <exec+0x3f8>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100d0f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100d15:	25 ff 0f 00 00       	and    $0xfff,%eax
80100d1a:	85 c0                	test   %eax,%eax
80100d1c:	0f 85 9c 02 00 00    	jne    80100fbe <exec+0x3fb>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100d22:	8b 95 f8 fe ff ff    	mov    -0x108(%ebp),%edx
80100d28:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100d2e:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100d34:	83 ec 0c             	sub    $0xc,%esp
80100d37:	52                   	push   %edx
80100d38:	50                   	push   %eax
80100d39:	ff 75 d8             	push   -0x28(%ebp)
80100d3c:	51                   	push   %ecx
80100d3d:	ff 75 d4             	push   -0x2c(%ebp)
80100d40:	e8 e3 72 00 00       	call   80108028 <loaduvm>
80100d45:	83 c4 20             	add    $0x20,%esp
80100d48:	85 c0                	test   %eax,%eax
80100d4a:	0f 88 71 02 00 00    	js     80100fc1 <exec+0x3fe>
80100d50:	eb 01                	jmp    80100d53 <exec+0x190>
      continue;
80100d52:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d53:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100d57:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d5a:	83 c0 20             	add    $0x20,%eax
80100d5d:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d60:	0f b7 85 34 ff ff ff 	movzwl -0xcc(%ebp),%eax
80100d67:	0f b7 c0             	movzwl %ax,%eax
80100d6a:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100d6d:	0f 8c 0f ff ff ff    	jl     80100c82 <exec+0xbf>
      goto bad;
  }
  iunlockput(ip);
80100d73:	83 ec 0c             	sub    $0xc,%esp
80100d76:	ff 75 d8             	push   -0x28(%ebp)
80100d79:	e8 cd 0e 00 00       	call   80101c4b <iunlockput>
80100d7e:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d81:	e8 38 28 00 00       	call   801035be <end_op>
  ip = 0;
80100d86:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100d8d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d90:	05 ff 0f 00 00       	add    $0xfff,%eax
80100d95:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d9a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d9d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100da0:	05 00 20 00 00       	add    $0x2000,%eax
80100da5:	83 ec 04             	sub    $0x4,%esp
80100da8:	50                   	push   %eax
80100da9:	ff 75 e0             	push   -0x20(%ebp)
80100dac:	ff 75 d4             	push   -0x2c(%ebp)
80100daf:	e8 41 73 00 00       	call   801080f5 <allocuvm>
80100db4:	83 c4 10             	add    $0x10,%esp
80100db7:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100dba:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100dbe:	0f 84 00 02 00 00    	je     80100fc4 <exec+0x401>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100dc4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100dc7:	2d 00 20 00 00       	sub    $0x2000,%eax
80100dcc:	83 ec 08             	sub    $0x8,%esp
80100dcf:	50                   	push   %eax
80100dd0:	ff 75 d4             	push   -0x2c(%ebp)
80100dd3:	e8 7f 75 00 00       	call   80108357 <clearpteu>
80100dd8:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100ddb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100dde:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100de1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100de8:	e9 96 00 00 00       	jmp    80100e83 <exec+0x2c0>
    if(argc >= MAXARG)
80100ded:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100df1:	0f 87 d0 01 00 00    	ja     80100fc7 <exec+0x404>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100df7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dfa:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e01:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e04:	01 d0                	add    %edx,%eax
80100e06:	8b 00                	mov    (%eax),%eax
80100e08:	83 ec 0c             	sub    $0xc,%esp
80100e0b:	50                   	push   %eax
80100e0c:	e8 22 48 00 00       	call   80105633 <strlen>
80100e11:	83 c4 10             	add    $0x10,%esp
80100e14:	89 c2                	mov    %eax,%edx
80100e16:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e19:	29 d0                	sub    %edx,%eax
80100e1b:	83 e8 01             	sub    $0x1,%eax
80100e1e:	83 e0 fc             	and    $0xfffffffc,%eax
80100e21:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100e24:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e27:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e2e:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e31:	01 d0                	add    %edx,%eax
80100e33:	8b 00                	mov    (%eax),%eax
80100e35:	83 ec 0c             	sub    $0xc,%esp
80100e38:	50                   	push   %eax
80100e39:	e8 f5 47 00 00       	call   80105633 <strlen>
80100e3e:	83 c4 10             	add    $0x10,%esp
80100e41:	83 c0 01             	add    $0x1,%eax
80100e44:	89 c2                	mov    %eax,%edx
80100e46:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e49:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100e50:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e53:	01 c8                	add    %ecx,%eax
80100e55:	8b 00                	mov    (%eax),%eax
80100e57:	52                   	push   %edx
80100e58:	50                   	push   %eax
80100e59:	ff 75 dc             	push   -0x24(%ebp)
80100e5c:	ff 75 d4             	push   -0x2c(%ebp)
80100e5f:	e8 9f 76 00 00       	call   80108503 <copyout>
80100e64:	83 c4 10             	add    $0x10,%esp
80100e67:	85 c0                	test   %eax,%eax
80100e69:	0f 88 5b 01 00 00    	js     80100fca <exec+0x407>
      goto bad;
    ustack[3+argc] = sp;
80100e6f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e72:	8d 50 03             	lea    0x3(%eax),%edx
80100e75:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e78:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100e7f:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e83:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e86:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e8d:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e90:	01 d0                	add    %edx,%eax
80100e92:	8b 00                	mov    (%eax),%eax
80100e94:	85 c0                	test   %eax,%eax
80100e96:	0f 85 51 ff ff ff    	jne    80100ded <exec+0x22a>
  }
  ustack[3+argc] = 0;
80100e9c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e9f:	83 c0 03             	add    $0x3,%eax
80100ea2:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100ea9:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100ead:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100eb4:	ff ff ff 
  ustack[1] = argc;
80100eb7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eba:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100ec0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ec3:	83 c0 01             	add    $0x1,%eax
80100ec6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ecd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ed0:	29 d0                	sub    %edx,%eax
80100ed2:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100ed8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100edb:	83 c0 04             	add    $0x4,%eax
80100ede:	c1 e0 02             	shl    $0x2,%eax
80100ee1:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100ee4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ee7:	83 c0 04             	add    $0x4,%eax
80100eea:	c1 e0 02             	shl    $0x2,%eax
80100eed:	50                   	push   %eax
80100eee:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100ef4:	50                   	push   %eax
80100ef5:	ff 75 dc             	push   -0x24(%ebp)
80100ef8:	ff 75 d4             	push   -0x2c(%ebp)
80100efb:	e8 03 76 00 00       	call   80108503 <copyout>
80100f00:	83 c4 10             	add    $0x10,%esp
80100f03:	85 c0                	test   %eax,%eax
80100f05:	0f 88 c2 00 00 00    	js     80100fcd <exec+0x40a>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100f0b:	8b 45 08             	mov    0x8(%ebp),%eax
80100f0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100f11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f14:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100f17:	eb 17                	jmp    80100f30 <exec+0x36d>
    if(*s == '/')
80100f19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f1c:	0f b6 00             	movzbl (%eax),%eax
80100f1f:	3c 2f                	cmp    $0x2f,%al
80100f21:	75 09                	jne    80100f2c <exec+0x369>
      last = s+1;
80100f23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f26:	83 c0 01             	add    $0x1,%eax
80100f29:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100f2c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100f30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f33:	0f b6 00             	movzbl (%eax),%eax
80100f36:	84 c0                	test   %al,%al
80100f38:	75 df                	jne    80100f19 <exec+0x356>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100f3a:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f3d:	83 c0 6c             	add    $0x6c,%eax
80100f40:	83 ec 04             	sub    $0x4,%esp
80100f43:	6a 10                	push   $0x10
80100f45:	ff 75 f0             	push   -0x10(%ebp)
80100f48:	50                   	push   %eax
80100f49:	e8 9a 46 00 00       	call   801055e8 <safestrcpy>
80100f4e:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100f51:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f54:	8b 40 04             	mov    0x4(%eax),%eax
80100f57:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100f5a:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f5d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f60:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100f63:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f66:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f69:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100f6b:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f6e:	8b 40 18             	mov    0x18(%eax),%eax
80100f71:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100f77:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100f7a:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f7d:	8b 40 18             	mov    0x18(%eax),%eax
80100f80:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f83:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100f86:	83 ec 0c             	sub    $0xc,%esp
80100f89:	ff 75 d0             	push   -0x30(%ebp)
80100f8c:	e8 88 6e 00 00       	call   80107e19 <switchuvm>
80100f91:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f94:	83 ec 0c             	sub    $0xc,%esp
80100f97:	ff 75 cc             	push   -0x34(%ebp)
80100f9a:	e8 1f 73 00 00       	call   801082be <freevm>
80100f9f:	83 c4 10             	add    $0x10,%esp
  return 0;
80100fa2:	b8 00 00 00 00       	mov    $0x0,%eax
80100fa7:	eb 57                	jmp    80101000 <exec+0x43d>
    goto bad;
80100fa9:	90                   	nop
80100faa:	eb 22                	jmp    80100fce <exec+0x40b>
    goto bad;
80100fac:	90                   	nop
80100fad:	eb 1f                	jmp    80100fce <exec+0x40b>
    goto bad;
80100faf:	90                   	nop
80100fb0:	eb 1c                	jmp    80100fce <exec+0x40b>
      goto bad;
80100fb2:	90                   	nop
80100fb3:	eb 19                	jmp    80100fce <exec+0x40b>
      goto bad;
80100fb5:	90                   	nop
80100fb6:	eb 16                	jmp    80100fce <exec+0x40b>
      goto bad;
80100fb8:	90                   	nop
80100fb9:	eb 13                	jmp    80100fce <exec+0x40b>
      goto bad;
80100fbb:	90                   	nop
80100fbc:	eb 10                	jmp    80100fce <exec+0x40b>
      goto bad;
80100fbe:	90                   	nop
80100fbf:	eb 0d                	jmp    80100fce <exec+0x40b>
      goto bad;
80100fc1:	90                   	nop
80100fc2:	eb 0a                	jmp    80100fce <exec+0x40b>
    goto bad;
80100fc4:	90                   	nop
80100fc5:	eb 07                	jmp    80100fce <exec+0x40b>
      goto bad;
80100fc7:	90                   	nop
80100fc8:	eb 04                	jmp    80100fce <exec+0x40b>
      goto bad;
80100fca:	90                   	nop
80100fcb:	eb 01                	jmp    80100fce <exec+0x40b>
    goto bad;
80100fcd:	90                   	nop

 bad:
  if(pgdir)
80100fce:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100fd2:	74 0e                	je     80100fe2 <exec+0x41f>
    freevm(pgdir);
80100fd4:	83 ec 0c             	sub    $0xc,%esp
80100fd7:	ff 75 d4             	push   -0x2c(%ebp)
80100fda:	e8 df 72 00 00       	call   801082be <freevm>
80100fdf:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100fe2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100fe6:	74 13                	je     80100ffb <exec+0x438>
    iunlockput(ip);
80100fe8:	83 ec 0c             	sub    $0xc,%esp
80100feb:	ff 75 d8             	push   -0x28(%ebp)
80100fee:	e8 58 0c 00 00       	call   80101c4b <iunlockput>
80100ff3:	83 c4 10             	add    $0x10,%esp
    end_op();
80100ff6:	e8 c3 25 00 00       	call   801035be <end_op>
  }
  return -1;
80100ffb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101000:	c9                   	leave  
80101001:	c3                   	ret    

80101002 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80101002:	55                   	push   %ebp
80101003:	89 e5                	mov    %esp,%ebp
80101005:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80101008:	83 ec 08             	sub    $0x8,%esp
8010100b:	68 22 86 10 80       	push   $0x80108622
80101010:	68 20 00 11 80       	push   $0x80110020
80101015:	e8 23 41 00 00       	call   8010513d <initlock>
8010101a:	83 c4 10             	add    $0x10,%esp
}
8010101d:	90                   	nop
8010101e:	c9                   	leave  
8010101f:	c3                   	ret    

80101020 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80101020:	55                   	push   %ebp
80101021:	89 e5                	mov    %esp,%ebp
80101023:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80101026:	83 ec 0c             	sub    $0xc,%esp
80101029:	68 20 00 11 80       	push   $0x80110020
8010102e:	e8 2c 41 00 00       	call   8010515f <acquire>
80101033:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101036:	c7 45 f4 54 00 11 80 	movl   $0x80110054,-0xc(%ebp)
8010103d:	eb 2d                	jmp    8010106c <filealloc+0x4c>
    if(f->ref == 0){
8010103f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101042:	8b 40 04             	mov    0x4(%eax),%eax
80101045:	85 c0                	test   %eax,%eax
80101047:	75 1f                	jne    80101068 <filealloc+0x48>
      f->ref = 1;
80101049:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010104c:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80101053:	83 ec 0c             	sub    $0xc,%esp
80101056:	68 20 00 11 80       	push   $0x80110020
8010105b:	e8 6d 41 00 00       	call   801051cd <release>
80101060:	83 c4 10             	add    $0x10,%esp
      return f;
80101063:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101066:	eb 23                	jmp    8010108b <filealloc+0x6b>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101068:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
8010106c:	b8 b4 09 11 80       	mov    $0x801109b4,%eax
80101071:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101074:	72 c9                	jb     8010103f <filealloc+0x1f>
    }
  }
  release(&ftable.lock);
80101076:	83 ec 0c             	sub    $0xc,%esp
80101079:	68 20 00 11 80       	push   $0x80110020
8010107e:	e8 4a 41 00 00       	call   801051cd <release>
80101083:	83 c4 10             	add    $0x10,%esp
  return 0;
80101086:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010108b:	c9                   	leave  
8010108c:	c3                   	ret    

8010108d <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
8010108d:	55                   	push   %ebp
8010108e:	89 e5                	mov    %esp,%ebp
80101090:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80101093:	83 ec 0c             	sub    $0xc,%esp
80101096:	68 20 00 11 80       	push   $0x80110020
8010109b:	e8 bf 40 00 00       	call   8010515f <acquire>
801010a0:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010a3:	8b 45 08             	mov    0x8(%ebp),%eax
801010a6:	8b 40 04             	mov    0x4(%eax),%eax
801010a9:	85 c0                	test   %eax,%eax
801010ab:	7f 0d                	jg     801010ba <filedup+0x2d>
    panic("filedup");
801010ad:	83 ec 0c             	sub    $0xc,%esp
801010b0:	68 29 86 10 80       	push   $0x80108629
801010b5:	e8 fb f4 ff ff       	call   801005b5 <panic>
  f->ref++;
801010ba:	8b 45 08             	mov    0x8(%ebp),%eax
801010bd:	8b 40 04             	mov    0x4(%eax),%eax
801010c0:	8d 50 01             	lea    0x1(%eax),%edx
801010c3:	8b 45 08             	mov    0x8(%ebp),%eax
801010c6:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
801010c9:	83 ec 0c             	sub    $0xc,%esp
801010cc:	68 20 00 11 80       	push   $0x80110020
801010d1:	e8 f7 40 00 00       	call   801051cd <release>
801010d6:	83 c4 10             	add    $0x10,%esp
  return f;
801010d9:	8b 45 08             	mov    0x8(%ebp),%eax
}
801010dc:	c9                   	leave  
801010dd:	c3                   	ret    

801010de <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801010de:	55                   	push   %ebp
801010df:	89 e5                	mov    %esp,%ebp
801010e1:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801010e4:	83 ec 0c             	sub    $0xc,%esp
801010e7:	68 20 00 11 80       	push   $0x80110020
801010ec:	e8 6e 40 00 00       	call   8010515f <acquire>
801010f1:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010f4:	8b 45 08             	mov    0x8(%ebp),%eax
801010f7:	8b 40 04             	mov    0x4(%eax),%eax
801010fa:	85 c0                	test   %eax,%eax
801010fc:	7f 0d                	jg     8010110b <fileclose+0x2d>
    panic("fileclose");
801010fe:	83 ec 0c             	sub    $0xc,%esp
80101101:	68 31 86 10 80       	push   $0x80108631
80101106:	e8 aa f4 ff ff       	call   801005b5 <panic>
  if(--f->ref > 0){
8010110b:	8b 45 08             	mov    0x8(%ebp),%eax
8010110e:	8b 40 04             	mov    0x4(%eax),%eax
80101111:	8d 50 ff             	lea    -0x1(%eax),%edx
80101114:	8b 45 08             	mov    0x8(%ebp),%eax
80101117:	89 50 04             	mov    %edx,0x4(%eax)
8010111a:	8b 45 08             	mov    0x8(%ebp),%eax
8010111d:	8b 40 04             	mov    0x4(%eax),%eax
80101120:	85 c0                	test   %eax,%eax
80101122:	7e 15                	jle    80101139 <fileclose+0x5b>
    release(&ftable.lock);
80101124:	83 ec 0c             	sub    $0xc,%esp
80101127:	68 20 00 11 80       	push   $0x80110020
8010112c:	e8 9c 40 00 00       	call   801051cd <release>
80101131:	83 c4 10             	add    $0x10,%esp
80101134:	e9 8b 00 00 00       	jmp    801011c4 <fileclose+0xe6>
    return;
  }
  ff = *f;
80101139:	8b 45 08             	mov    0x8(%ebp),%eax
8010113c:	8b 10                	mov    (%eax),%edx
8010113e:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101141:	8b 50 04             	mov    0x4(%eax),%edx
80101144:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101147:	8b 50 08             	mov    0x8(%eax),%edx
8010114a:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010114d:	8b 50 0c             	mov    0xc(%eax),%edx
80101150:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101153:	8b 50 10             	mov    0x10(%eax),%edx
80101156:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101159:	8b 40 14             	mov    0x14(%eax),%eax
8010115c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
8010115f:	8b 45 08             	mov    0x8(%ebp),%eax
80101162:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101169:	8b 45 08             	mov    0x8(%ebp),%eax
8010116c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101172:	83 ec 0c             	sub    $0xc,%esp
80101175:	68 20 00 11 80       	push   $0x80110020
8010117a:	e8 4e 40 00 00       	call   801051cd <release>
8010117f:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
80101182:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101185:	83 f8 01             	cmp    $0x1,%eax
80101188:	75 19                	jne    801011a3 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
8010118a:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010118e:	0f be d0             	movsbl %al,%edx
80101191:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101194:	83 ec 08             	sub    $0x8,%esp
80101197:	52                   	push   %edx
80101198:	50                   	push   %eax
80101199:	e8 8a 2d 00 00       	call   80103f28 <pipeclose>
8010119e:	83 c4 10             	add    $0x10,%esp
801011a1:	eb 21                	jmp    801011c4 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
801011a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801011a6:	83 f8 02             	cmp    $0x2,%eax
801011a9:	75 19                	jne    801011c4 <fileclose+0xe6>
    begin_op();
801011ab:	e8 82 23 00 00       	call   80103532 <begin_op>
    iput(ff.ip);
801011b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801011b3:	83 ec 0c             	sub    $0xc,%esp
801011b6:	50                   	push   %eax
801011b7:	e8 bf 09 00 00       	call   80101b7b <iput>
801011bc:	83 c4 10             	add    $0x10,%esp
    end_op();
801011bf:	e8 fa 23 00 00       	call   801035be <end_op>
  }
}
801011c4:	c9                   	leave  
801011c5:	c3                   	ret    

801011c6 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801011c6:	55                   	push   %ebp
801011c7:	89 e5                	mov    %esp,%ebp
801011c9:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
801011cc:	8b 45 08             	mov    0x8(%ebp),%eax
801011cf:	8b 00                	mov    (%eax),%eax
801011d1:	83 f8 02             	cmp    $0x2,%eax
801011d4:	75 40                	jne    80101216 <filestat+0x50>
    ilock(f->ip);
801011d6:	8b 45 08             	mov    0x8(%ebp),%eax
801011d9:	8b 40 10             	mov    0x10(%eax),%eax
801011dc:	83 ec 0c             	sub    $0xc,%esp
801011df:	50                   	push   %eax
801011e0:	e8 35 08 00 00       	call   80101a1a <ilock>
801011e5:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801011e8:	8b 45 08             	mov    0x8(%ebp),%eax
801011eb:	8b 40 10             	mov    0x10(%eax),%eax
801011ee:	83 ec 08             	sub    $0x8,%esp
801011f1:	ff 75 0c             	push   0xc(%ebp)
801011f4:	50                   	push   %eax
801011f5:	e8 c6 0c 00 00       	call   80101ec0 <stati>
801011fa:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
801011fd:	8b 45 08             	mov    0x8(%ebp),%eax
80101200:	8b 40 10             	mov    0x10(%eax),%eax
80101203:	83 ec 0c             	sub    $0xc,%esp
80101206:	50                   	push   %eax
80101207:	e8 21 09 00 00       	call   80101b2d <iunlock>
8010120c:	83 c4 10             	add    $0x10,%esp
    return 0;
8010120f:	b8 00 00 00 00       	mov    $0x0,%eax
80101214:	eb 05                	jmp    8010121b <filestat+0x55>
  }
  return -1;
80101216:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010121b:	c9                   	leave  
8010121c:	c3                   	ret    

8010121d <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
8010121d:	55                   	push   %ebp
8010121e:	89 e5                	mov    %esp,%ebp
80101220:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
80101223:	8b 45 08             	mov    0x8(%ebp),%eax
80101226:	0f b6 40 08          	movzbl 0x8(%eax),%eax
8010122a:	84 c0                	test   %al,%al
8010122c:	75 0a                	jne    80101238 <fileread+0x1b>
    return -1;
8010122e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101233:	e9 9b 00 00 00       	jmp    801012d3 <fileread+0xb6>
  if(f->type == FD_PIPE)
80101238:	8b 45 08             	mov    0x8(%ebp),%eax
8010123b:	8b 00                	mov    (%eax),%eax
8010123d:	83 f8 01             	cmp    $0x1,%eax
80101240:	75 1a                	jne    8010125c <fileread+0x3f>
    return piperead(f->pipe, addr, n);
80101242:	8b 45 08             	mov    0x8(%ebp),%eax
80101245:	8b 40 0c             	mov    0xc(%eax),%eax
80101248:	83 ec 04             	sub    $0x4,%esp
8010124b:	ff 75 10             	push   0x10(%ebp)
8010124e:	ff 75 0c             	push   0xc(%ebp)
80101251:	50                   	push   %eax
80101252:	e8 7e 2e 00 00       	call   801040d5 <piperead>
80101257:	83 c4 10             	add    $0x10,%esp
8010125a:	eb 77                	jmp    801012d3 <fileread+0xb6>
  if(f->type == FD_INODE){
8010125c:	8b 45 08             	mov    0x8(%ebp),%eax
8010125f:	8b 00                	mov    (%eax),%eax
80101261:	83 f8 02             	cmp    $0x2,%eax
80101264:	75 60                	jne    801012c6 <fileread+0xa9>
    ilock(f->ip);
80101266:	8b 45 08             	mov    0x8(%ebp),%eax
80101269:	8b 40 10             	mov    0x10(%eax),%eax
8010126c:	83 ec 0c             	sub    $0xc,%esp
8010126f:	50                   	push   %eax
80101270:	e8 a5 07 00 00       	call   80101a1a <ilock>
80101275:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101278:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010127b:	8b 45 08             	mov    0x8(%ebp),%eax
8010127e:	8b 50 14             	mov    0x14(%eax),%edx
80101281:	8b 45 08             	mov    0x8(%ebp),%eax
80101284:	8b 40 10             	mov    0x10(%eax),%eax
80101287:	51                   	push   %ecx
80101288:	52                   	push   %edx
80101289:	ff 75 0c             	push   0xc(%ebp)
8010128c:	50                   	push   %eax
8010128d:	e8 74 0c 00 00       	call   80101f06 <readi>
80101292:	83 c4 10             	add    $0x10,%esp
80101295:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101298:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010129c:	7e 11                	jle    801012af <fileread+0x92>
      f->off += r;
8010129e:	8b 45 08             	mov    0x8(%ebp),%eax
801012a1:	8b 50 14             	mov    0x14(%eax),%edx
801012a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012a7:	01 c2                	add    %eax,%edx
801012a9:	8b 45 08             	mov    0x8(%ebp),%eax
801012ac:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801012af:	8b 45 08             	mov    0x8(%ebp),%eax
801012b2:	8b 40 10             	mov    0x10(%eax),%eax
801012b5:	83 ec 0c             	sub    $0xc,%esp
801012b8:	50                   	push   %eax
801012b9:	e8 6f 08 00 00       	call   80101b2d <iunlock>
801012be:	83 c4 10             	add    $0x10,%esp
    return r;
801012c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012c4:	eb 0d                	jmp    801012d3 <fileread+0xb6>
  }
  panic("fileread");
801012c6:	83 ec 0c             	sub    $0xc,%esp
801012c9:	68 3b 86 10 80       	push   $0x8010863b
801012ce:	e8 e2 f2 ff ff       	call   801005b5 <panic>
}
801012d3:	c9                   	leave  
801012d4:	c3                   	ret    

801012d5 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801012d5:	55                   	push   %ebp
801012d6:	89 e5                	mov    %esp,%ebp
801012d8:	53                   	push   %ebx
801012d9:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
801012dc:	8b 45 08             	mov    0x8(%ebp),%eax
801012df:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801012e3:	84 c0                	test   %al,%al
801012e5:	75 0a                	jne    801012f1 <filewrite+0x1c>
    return -1;
801012e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012ec:	e9 1b 01 00 00       	jmp    8010140c <filewrite+0x137>
  if(f->type == FD_PIPE)
801012f1:	8b 45 08             	mov    0x8(%ebp),%eax
801012f4:	8b 00                	mov    (%eax),%eax
801012f6:	83 f8 01             	cmp    $0x1,%eax
801012f9:	75 1d                	jne    80101318 <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
801012fb:	8b 45 08             	mov    0x8(%ebp),%eax
801012fe:	8b 40 0c             	mov    0xc(%eax),%eax
80101301:	83 ec 04             	sub    $0x4,%esp
80101304:	ff 75 10             	push   0x10(%ebp)
80101307:	ff 75 0c             	push   0xc(%ebp)
8010130a:	50                   	push   %eax
8010130b:	e8 c3 2c 00 00       	call   80103fd3 <pipewrite>
80101310:	83 c4 10             	add    $0x10,%esp
80101313:	e9 f4 00 00 00       	jmp    8010140c <filewrite+0x137>
  if(f->type == FD_INODE){
80101318:	8b 45 08             	mov    0x8(%ebp),%eax
8010131b:	8b 00                	mov    (%eax),%eax
8010131d:	83 f8 02             	cmp    $0x2,%eax
80101320:	0f 85 d9 00 00 00    	jne    801013ff <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
80101326:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
8010132d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101334:	e9 a3 00 00 00       	jmp    801013dc <filewrite+0x107>
      int n1 = n - i;
80101339:	8b 45 10             	mov    0x10(%ebp),%eax
8010133c:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010133f:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101342:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101345:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101348:	7e 06                	jle    80101350 <filewrite+0x7b>
        n1 = max;
8010134a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010134d:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101350:	e8 dd 21 00 00       	call   80103532 <begin_op>
      ilock(f->ip);
80101355:	8b 45 08             	mov    0x8(%ebp),%eax
80101358:	8b 40 10             	mov    0x10(%eax),%eax
8010135b:	83 ec 0c             	sub    $0xc,%esp
8010135e:	50                   	push   %eax
8010135f:	e8 b6 06 00 00       	call   80101a1a <ilock>
80101364:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101367:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010136a:	8b 45 08             	mov    0x8(%ebp),%eax
8010136d:	8b 50 14             	mov    0x14(%eax),%edx
80101370:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101373:	8b 45 0c             	mov    0xc(%ebp),%eax
80101376:	01 c3                	add    %eax,%ebx
80101378:	8b 45 08             	mov    0x8(%ebp),%eax
8010137b:	8b 40 10             	mov    0x10(%eax),%eax
8010137e:	51                   	push   %ecx
8010137f:	52                   	push   %edx
80101380:	53                   	push   %ebx
80101381:	50                   	push   %eax
80101382:	e8 d4 0c 00 00       	call   8010205b <writei>
80101387:	83 c4 10             	add    $0x10,%esp
8010138a:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010138d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101391:	7e 11                	jle    801013a4 <filewrite+0xcf>
        f->off += r;
80101393:	8b 45 08             	mov    0x8(%ebp),%eax
80101396:	8b 50 14             	mov    0x14(%eax),%edx
80101399:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010139c:	01 c2                	add    %eax,%edx
8010139e:	8b 45 08             	mov    0x8(%ebp),%eax
801013a1:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801013a4:	8b 45 08             	mov    0x8(%ebp),%eax
801013a7:	8b 40 10             	mov    0x10(%eax),%eax
801013aa:	83 ec 0c             	sub    $0xc,%esp
801013ad:	50                   	push   %eax
801013ae:	e8 7a 07 00 00       	call   80101b2d <iunlock>
801013b3:	83 c4 10             	add    $0x10,%esp
      end_op();
801013b6:	e8 03 22 00 00       	call   801035be <end_op>

      if(r < 0)
801013bb:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801013bf:	78 29                	js     801013ea <filewrite+0x115>
        break;
      if(r != n1)
801013c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013c4:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801013c7:	74 0d                	je     801013d6 <filewrite+0x101>
        panic("short filewrite");
801013c9:	83 ec 0c             	sub    $0xc,%esp
801013cc:	68 44 86 10 80       	push   $0x80108644
801013d1:	e8 df f1 ff ff       	call   801005b5 <panic>
      i += r;
801013d6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013d9:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
801013dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013df:	3b 45 10             	cmp    0x10(%ebp),%eax
801013e2:	0f 8c 51 ff ff ff    	jl     80101339 <filewrite+0x64>
801013e8:	eb 01                	jmp    801013eb <filewrite+0x116>
        break;
801013ea:	90                   	nop
    }
    return i == n ? n : -1;
801013eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013ee:	3b 45 10             	cmp    0x10(%ebp),%eax
801013f1:	75 05                	jne    801013f8 <filewrite+0x123>
801013f3:	8b 45 10             	mov    0x10(%ebp),%eax
801013f6:	eb 14                	jmp    8010140c <filewrite+0x137>
801013f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013fd:	eb 0d                	jmp    8010140c <filewrite+0x137>
  }
  panic("filewrite");
801013ff:	83 ec 0c             	sub    $0xc,%esp
80101402:	68 54 86 10 80       	push   $0x80108654
80101407:	e8 a9 f1 ff ff       	call   801005b5 <panic>
}
8010140c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010140f:	c9                   	leave  
80101410:	c3                   	ret    

80101411 <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101411:	55                   	push   %ebp
80101412:	89 e5                	mov    %esp,%ebp
80101414:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
80101417:	8b 45 08             	mov    0x8(%ebp),%eax
8010141a:	83 ec 08             	sub    $0x8,%esp
8010141d:	6a 01                	push   $0x1
8010141f:	50                   	push   %eax
80101420:	e8 aa ed ff ff       	call   801001cf <bread>
80101425:	83 c4 10             	add    $0x10,%esp
80101428:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
8010142b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010142e:	83 c0 5c             	add    $0x5c,%eax
80101431:	83 ec 04             	sub    $0x4,%esp
80101434:	6a 1c                	push   $0x1c
80101436:	50                   	push   %eax
80101437:	ff 75 0c             	push   0xc(%ebp)
8010143a:	e8 65 40 00 00       	call   801054a4 <memmove>
8010143f:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101442:	83 ec 0c             	sub    $0xc,%esp
80101445:	ff 75 f4             	push   -0xc(%ebp)
80101448:	e8 04 ee ff ff       	call   80100251 <brelse>
8010144d:	83 c4 10             	add    $0x10,%esp
}
80101450:	90                   	nop
80101451:	c9                   	leave  
80101452:	c3                   	ret    

80101453 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101453:	55                   	push   %ebp
80101454:	89 e5                	mov    %esp,%ebp
80101456:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
80101459:	8b 55 0c             	mov    0xc(%ebp),%edx
8010145c:	8b 45 08             	mov    0x8(%ebp),%eax
8010145f:	83 ec 08             	sub    $0x8,%esp
80101462:	52                   	push   %edx
80101463:	50                   	push   %eax
80101464:	e8 66 ed ff ff       	call   801001cf <bread>
80101469:	83 c4 10             	add    $0x10,%esp
8010146c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010146f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101472:	83 c0 5c             	add    $0x5c,%eax
80101475:	83 ec 04             	sub    $0x4,%esp
80101478:	68 00 02 00 00       	push   $0x200
8010147d:	6a 00                	push   $0x0
8010147f:	50                   	push   %eax
80101480:	e8 60 3f 00 00       	call   801053e5 <memset>
80101485:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101488:	83 ec 0c             	sub    $0xc,%esp
8010148b:	ff 75 f4             	push   -0xc(%ebp)
8010148e:	e8 d8 22 00 00       	call   8010376b <log_write>
80101493:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101496:	83 ec 0c             	sub    $0xc,%esp
80101499:	ff 75 f4             	push   -0xc(%ebp)
8010149c:	e8 b0 ed ff ff       	call   80100251 <brelse>
801014a1:	83 c4 10             	add    $0x10,%esp
}
801014a4:	90                   	nop
801014a5:	c9                   	leave  
801014a6:	c3                   	ret    

801014a7 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801014a7:	55                   	push   %ebp
801014a8:	89 e5                	mov    %esp,%ebp
801014aa:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
801014ad:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
801014b4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801014bb:	e9 0b 01 00 00       	jmp    801015cb <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
801014c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014c3:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801014c9:	85 c0                	test   %eax,%eax
801014cb:	0f 48 c2             	cmovs  %edx,%eax
801014ce:	c1 f8 0c             	sar    $0xc,%eax
801014d1:	89 c2                	mov    %eax,%edx
801014d3:	a1 d8 09 11 80       	mov    0x801109d8,%eax
801014d8:	01 d0                	add    %edx,%eax
801014da:	83 ec 08             	sub    $0x8,%esp
801014dd:	50                   	push   %eax
801014de:	ff 75 08             	push   0x8(%ebp)
801014e1:	e8 e9 ec ff ff       	call   801001cf <bread>
801014e6:	83 c4 10             	add    $0x10,%esp
801014e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014ec:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801014f3:	e9 9e 00 00 00       	jmp    80101596 <balloc+0xef>
      m = 1 << (bi % 8);
801014f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014fb:	83 e0 07             	and    $0x7,%eax
801014fe:	ba 01 00 00 00       	mov    $0x1,%edx
80101503:	89 c1                	mov    %eax,%ecx
80101505:	d3 e2                	shl    %cl,%edx
80101507:	89 d0                	mov    %edx,%eax
80101509:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010150c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010150f:	8d 50 07             	lea    0x7(%eax),%edx
80101512:	85 c0                	test   %eax,%eax
80101514:	0f 48 c2             	cmovs  %edx,%eax
80101517:	c1 f8 03             	sar    $0x3,%eax
8010151a:	89 c2                	mov    %eax,%edx
8010151c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010151f:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101524:	0f b6 c0             	movzbl %al,%eax
80101527:	23 45 e8             	and    -0x18(%ebp),%eax
8010152a:	85 c0                	test   %eax,%eax
8010152c:	75 64                	jne    80101592 <balloc+0xeb>
        bp->data[bi/8] |= m;  // Mark block in use.
8010152e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101531:	8d 50 07             	lea    0x7(%eax),%edx
80101534:	85 c0                	test   %eax,%eax
80101536:	0f 48 c2             	cmovs  %edx,%eax
80101539:	c1 f8 03             	sar    $0x3,%eax
8010153c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010153f:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101544:	89 d1                	mov    %edx,%ecx
80101546:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101549:	09 ca                	or     %ecx,%edx
8010154b:	89 d1                	mov    %edx,%ecx
8010154d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101550:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
80101554:	83 ec 0c             	sub    $0xc,%esp
80101557:	ff 75 ec             	push   -0x14(%ebp)
8010155a:	e8 0c 22 00 00       	call   8010376b <log_write>
8010155f:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80101562:	83 ec 0c             	sub    $0xc,%esp
80101565:	ff 75 ec             	push   -0x14(%ebp)
80101568:	e8 e4 ec ff ff       	call   80100251 <brelse>
8010156d:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
80101570:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101573:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101576:	01 c2                	add    %eax,%edx
80101578:	8b 45 08             	mov    0x8(%ebp),%eax
8010157b:	83 ec 08             	sub    $0x8,%esp
8010157e:	52                   	push   %edx
8010157f:	50                   	push   %eax
80101580:	e8 ce fe ff ff       	call   80101453 <bzero>
80101585:	83 c4 10             	add    $0x10,%esp
        return b + bi;
80101588:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010158b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010158e:	01 d0                	add    %edx,%eax
80101590:	eb 57                	jmp    801015e9 <balloc+0x142>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101592:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101596:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
8010159d:	7f 17                	jg     801015b6 <balloc+0x10f>
8010159f:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015a5:	01 d0                	add    %edx,%eax
801015a7:	89 c2                	mov    %eax,%edx
801015a9:	a1 c0 09 11 80       	mov    0x801109c0,%eax
801015ae:	39 c2                	cmp    %eax,%edx
801015b0:	0f 82 42 ff ff ff    	jb     801014f8 <balloc+0x51>
      }
    }
    brelse(bp);
801015b6:	83 ec 0c             	sub    $0xc,%esp
801015b9:	ff 75 ec             	push   -0x14(%ebp)
801015bc:	e8 90 ec ff ff       	call   80100251 <brelse>
801015c1:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
801015c4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801015cb:	8b 15 c0 09 11 80    	mov    0x801109c0,%edx
801015d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015d4:	39 c2                	cmp    %eax,%edx
801015d6:	0f 87 e4 fe ff ff    	ja     801014c0 <balloc+0x19>
  }
  panic("balloc: out of blocks");
801015dc:	83 ec 0c             	sub    $0xc,%esp
801015df:	68 60 86 10 80       	push   $0x80108660
801015e4:	e8 cc ef ff ff       	call   801005b5 <panic>
}
801015e9:	c9                   	leave  
801015ea:	c3                   	ret    

801015eb <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801015eb:	55                   	push   %ebp
801015ec:	89 e5                	mov    %esp,%ebp
801015ee:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
801015f1:	8b 45 0c             	mov    0xc(%ebp),%eax
801015f4:	c1 e8 0c             	shr    $0xc,%eax
801015f7:	89 c2                	mov    %eax,%edx
801015f9:	a1 d8 09 11 80       	mov    0x801109d8,%eax
801015fe:	01 c2                	add    %eax,%edx
80101600:	8b 45 08             	mov    0x8(%ebp),%eax
80101603:	83 ec 08             	sub    $0x8,%esp
80101606:	52                   	push   %edx
80101607:	50                   	push   %eax
80101608:	e8 c2 eb ff ff       	call   801001cf <bread>
8010160d:	83 c4 10             	add    $0x10,%esp
80101610:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101613:	8b 45 0c             	mov    0xc(%ebp),%eax
80101616:	25 ff 0f 00 00       	and    $0xfff,%eax
8010161b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
8010161e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101621:	83 e0 07             	and    $0x7,%eax
80101624:	ba 01 00 00 00       	mov    $0x1,%edx
80101629:	89 c1                	mov    %eax,%ecx
8010162b:	d3 e2                	shl    %cl,%edx
8010162d:	89 d0                	mov    %edx,%eax
8010162f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101632:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101635:	8d 50 07             	lea    0x7(%eax),%edx
80101638:	85 c0                	test   %eax,%eax
8010163a:	0f 48 c2             	cmovs  %edx,%eax
8010163d:	c1 f8 03             	sar    $0x3,%eax
80101640:	89 c2                	mov    %eax,%edx
80101642:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101645:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
8010164a:	0f b6 c0             	movzbl %al,%eax
8010164d:	23 45 ec             	and    -0x14(%ebp),%eax
80101650:	85 c0                	test   %eax,%eax
80101652:	75 0d                	jne    80101661 <bfree+0x76>
    panic("freeing free block");
80101654:	83 ec 0c             	sub    $0xc,%esp
80101657:	68 76 86 10 80       	push   $0x80108676
8010165c:	e8 54 ef ff ff       	call   801005b5 <panic>
  bp->data[bi/8] &= ~m;
80101661:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101664:	8d 50 07             	lea    0x7(%eax),%edx
80101667:	85 c0                	test   %eax,%eax
80101669:	0f 48 c2             	cmovs  %edx,%eax
8010166c:	c1 f8 03             	sar    $0x3,%eax
8010166f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101672:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101677:	89 d1                	mov    %edx,%ecx
80101679:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010167c:	f7 d2                	not    %edx
8010167e:	21 ca                	and    %ecx,%edx
80101680:	89 d1                	mov    %edx,%ecx
80101682:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101685:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
80101689:	83 ec 0c             	sub    $0xc,%esp
8010168c:	ff 75 f4             	push   -0xc(%ebp)
8010168f:	e8 d7 20 00 00       	call   8010376b <log_write>
80101694:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101697:	83 ec 0c             	sub    $0xc,%esp
8010169a:	ff 75 f4             	push   -0xc(%ebp)
8010169d:	e8 af eb ff ff       	call   80100251 <brelse>
801016a2:	83 c4 10             	add    $0x10,%esp
}
801016a5:	90                   	nop
801016a6:	c9                   	leave  
801016a7:	c3                   	ret    

801016a8 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
801016a8:	55                   	push   %ebp
801016a9:	89 e5                	mov    %esp,%ebp
801016ab:	57                   	push   %edi
801016ac:	56                   	push   %esi
801016ad:	53                   	push   %ebx
801016ae:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
801016b1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
801016b8:	83 ec 08             	sub    $0x8,%esp
801016bb:	68 89 86 10 80       	push   $0x80108689
801016c0:	68 e0 09 11 80       	push   $0x801109e0
801016c5:	e8 73 3a 00 00       	call   8010513d <initlock>
801016ca:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801016cd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801016d4:	eb 2d                	jmp    80101703 <iinit+0x5b>
    initsleeplock(&icache.inode[i].lock, "inode");
801016d6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801016d9:	89 d0                	mov    %edx,%eax
801016db:	c1 e0 03             	shl    $0x3,%eax
801016de:	01 d0                	add    %edx,%eax
801016e0:	c1 e0 04             	shl    $0x4,%eax
801016e3:	83 c0 30             	add    $0x30,%eax
801016e6:	05 e0 09 11 80       	add    $0x801109e0,%eax
801016eb:	83 c0 10             	add    $0x10,%eax
801016ee:	83 ec 08             	sub    $0x8,%esp
801016f1:	68 90 86 10 80       	push   $0x80108690
801016f6:	50                   	push   %eax
801016f7:	e8 be 38 00 00       	call   80104fba <initsleeplock>
801016fc:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801016ff:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80101703:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
80101707:	7e cd                	jle    801016d6 <iinit+0x2e>
  }

  readsb(dev, &sb);
80101709:	83 ec 08             	sub    $0x8,%esp
8010170c:	68 c0 09 11 80       	push   $0x801109c0
80101711:	ff 75 08             	push   0x8(%ebp)
80101714:	e8 f8 fc ff ff       	call   80101411 <readsb>
80101719:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
8010171c:	a1 d8 09 11 80       	mov    0x801109d8,%eax
80101721:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80101724:	8b 3d d4 09 11 80    	mov    0x801109d4,%edi
8010172a:	8b 35 d0 09 11 80    	mov    0x801109d0,%esi
80101730:	8b 1d cc 09 11 80    	mov    0x801109cc,%ebx
80101736:	8b 0d c8 09 11 80    	mov    0x801109c8,%ecx
8010173c:	8b 15 c4 09 11 80    	mov    0x801109c4,%edx
80101742:	a1 c0 09 11 80       	mov    0x801109c0,%eax
80101747:	ff 75 d4             	push   -0x2c(%ebp)
8010174a:	57                   	push   %edi
8010174b:	56                   	push   %esi
8010174c:	53                   	push   %ebx
8010174d:	51                   	push   %ecx
8010174e:	52                   	push   %edx
8010174f:	50                   	push   %eax
80101750:	68 98 86 10 80       	push   $0x80108698
80101755:	e8 a6 ec ff ff       	call   80100400 <cprintf>
8010175a:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
8010175d:	90                   	nop
8010175e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101761:	5b                   	pop    %ebx
80101762:	5e                   	pop    %esi
80101763:	5f                   	pop    %edi
80101764:	5d                   	pop    %ebp
80101765:	c3                   	ret    

80101766 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
80101766:	55                   	push   %ebp
80101767:	89 e5                	mov    %esp,%ebp
80101769:	83 ec 28             	sub    $0x28,%esp
8010176c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010176f:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101773:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
8010177a:	e9 9e 00 00 00       	jmp    8010181d <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
8010177f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101782:	c1 e8 03             	shr    $0x3,%eax
80101785:	89 c2                	mov    %eax,%edx
80101787:	a1 d4 09 11 80       	mov    0x801109d4,%eax
8010178c:	01 d0                	add    %edx,%eax
8010178e:	83 ec 08             	sub    $0x8,%esp
80101791:	50                   	push   %eax
80101792:	ff 75 08             	push   0x8(%ebp)
80101795:	e8 35 ea ff ff       	call   801001cf <bread>
8010179a:	83 c4 10             	add    $0x10,%esp
8010179d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801017a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017a3:	8d 50 5c             	lea    0x5c(%eax),%edx
801017a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017a9:	83 e0 07             	and    $0x7,%eax
801017ac:	c1 e0 06             	shl    $0x6,%eax
801017af:	01 d0                	add    %edx,%eax
801017b1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
801017b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017b7:	0f b7 00             	movzwl (%eax),%eax
801017ba:	66 85 c0             	test   %ax,%ax
801017bd:	75 4c                	jne    8010180b <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
801017bf:	83 ec 04             	sub    $0x4,%esp
801017c2:	6a 40                	push   $0x40
801017c4:	6a 00                	push   $0x0
801017c6:	ff 75 ec             	push   -0x14(%ebp)
801017c9:	e8 17 3c 00 00       	call   801053e5 <memset>
801017ce:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801017d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017d4:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801017d8:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801017db:	83 ec 0c             	sub    $0xc,%esp
801017de:	ff 75 f0             	push   -0x10(%ebp)
801017e1:	e8 85 1f 00 00       	call   8010376b <log_write>
801017e6:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801017e9:	83 ec 0c             	sub    $0xc,%esp
801017ec:	ff 75 f0             	push   -0x10(%ebp)
801017ef:	e8 5d ea ff ff       	call   80100251 <brelse>
801017f4:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801017f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017fa:	83 ec 08             	sub    $0x8,%esp
801017fd:	50                   	push   %eax
801017fe:	ff 75 08             	push   0x8(%ebp)
80101801:	e8 f8 00 00 00       	call   801018fe <iget>
80101806:	83 c4 10             	add    $0x10,%esp
80101809:	eb 30                	jmp    8010183b <ialloc+0xd5>
    }
    brelse(bp);
8010180b:	83 ec 0c             	sub    $0xc,%esp
8010180e:	ff 75 f0             	push   -0x10(%ebp)
80101811:	e8 3b ea ff ff       	call   80100251 <brelse>
80101816:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
80101819:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010181d:	8b 15 c8 09 11 80    	mov    0x801109c8,%edx
80101823:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101826:	39 c2                	cmp    %eax,%edx
80101828:	0f 87 51 ff ff ff    	ja     8010177f <ialloc+0x19>
  }
  panic("ialloc: no inodes");
8010182e:	83 ec 0c             	sub    $0xc,%esp
80101831:	68 eb 86 10 80       	push   $0x801086eb
80101836:	e8 7a ed ff ff       	call   801005b5 <panic>
}
8010183b:	c9                   	leave  
8010183c:	c3                   	ret    

8010183d <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
8010183d:	55                   	push   %ebp
8010183e:	89 e5                	mov    %esp,%ebp
80101840:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101843:	8b 45 08             	mov    0x8(%ebp),%eax
80101846:	8b 40 04             	mov    0x4(%eax),%eax
80101849:	c1 e8 03             	shr    $0x3,%eax
8010184c:	89 c2                	mov    %eax,%edx
8010184e:	a1 d4 09 11 80       	mov    0x801109d4,%eax
80101853:	01 c2                	add    %eax,%edx
80101855:	8b 45 08             	mov    0x8(%ebp),%eax
80101858:	8b 00                	mov    (%eax),%eax
8010185a:	83 ec 08             	sub    $0x8,%esp
8010185d:	52                   	push   %edx
8010185e:	50                   	push   %eax
8010185f:	e8 6b e9 ff ff       	call   801001cf <bread>
80101864:	83 c4 10             	add    $0x10,%esp
80101867:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010186a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010186d:	8d 50 5c             	lea    0x5c(%eax),%edx
80101870:	8b 45 08             	mov    0x8(%ebp),%eax
80101873:	8b 40 04             	mov    0x4(%eax),%eax
80101876:	83 e0 07             	and    $0x7,%eax
80101879:	c1 e0 06             	shl    $0x6,%eax
8010187c:	01 d0                	add    %edx,%eax
8010187e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101881:	8b 45 08             	mov    0x8(%ebp),%eax
80101884:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101888:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010188b:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010188e:	8b 45 08             	mov    0x8(%ebp),%eax
80101891:	0f b7 50 52          	movzwl 0x52(%eax),%edx
80101895:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101898:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010189c:	8b 45 08             	mov    0x8(%ebp),%eax
8010189f:	0f b7 50 54          	movzwl 0x54(%eax),%edx
801018a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018a6:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
801018aa:	8b 45 08             	mov    0x8(%ebp),%eax
801018ad:	0f b7 50 56          	movzwl 0x56(%eax),%edx
801018b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018b4:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
801018b8:	8b 45 08             	mov    0x8(%ebp),%eax
801018bb:	8b 50 58             	mov    0x58(%eax),%edx
801018be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018c1:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801018c4:	8b 45 08             	mov    0x8(%ebp),%eax
801018c7:	8d 50 5c             	lea    0x5c(%eax),%edx
801018ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018cd:	83 c0 0c             	add    $0xc,%eax
801018d0:	83 ec 04             	sub    $0x4,%esp
801018d3:	6a 34                	push   $0x34
801018d5:	52                   	push   %edx
801018d6:	50                   	push   %eax
801018d7:	e8 c8 3b 00 00       	call   801054a4 <memmove>
801018dc:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801018df:	83 ec 0c             	sub    $0xc,%esp
801018e2:	ff 75 f4             	push   -0xc(%ebp)
801018e5:	e8 81 1e 00 00       	call   8010376b <log_write>
801018ea:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801018ed:	83 ec 0c             	sub    $0xc,%esp
801018f0:	ff 75 f4             	push   -0xc(%ebp)
801018f3:	e8 59 e9 ff ff       	call   80100251 <brelse>
801018f8:	83 c4 10             	add    $0x10,%esp
}
801018fb:	90                   	nop
801018fc:	c9                   	leave  
801018fd:	c3                   	ret    

801018fe <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801018fe:	55                   	push   %ebp
801018ff:	89 e5                	mov    %esp,%ebp
80101901:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101904:	83 ec 0c             	sub    $0xc,%esp
80101907:	68 e0 09 11 80       	push   $0x801109e0
8010190c:	e8 4e 38 00 00       	call   8010515f <acquire>
80101911:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101914:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010191b:	c7 45 f4 14 0a 11 80 	movl   $0x80110a14,-0xc(%ebp)
80101922:	eb 60                	jmp    80101984 <iget+0x86>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101924:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101927:	8b 40 08             	mov    0x8(%eax),%eax
8010192a:	85 c0                	test   %eax,%eax
8010192c:	7e 39                	jle    80101967 <iget+0x69>
8010192e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101931:	8b 00                	mov    (%eax),%eax
80101933:	39 45 08             	cmp    %eax,0x8(%ebp)
80101936:	75 2f                	jne    80101967 <iget+0x69>
80101938:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010193b:	8b 40 04             	mov    0x4(%eax),%eax
8010193e:	39 45 0c             	cmp    %eax,0xc(%ebp)
80101941:	75 24                	jne    80101967 <iget+0x69>
      ip->ref++;
80101943:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101946:	8b 40 08             	mov    0x8(%eax),%eax
80101949:	8d 50 01             	lea    0x1(%eax),%edx
8010194c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010194f:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101952:	83 ec 0c             	sub    $0xc,%esp
80101955:	68 e0 09 11 80       	push   $0x801109e0
8010195a:	e8 6e 38 00 00       	call   801051cd <release>
8010195f:	83 c4 10             	add    $0x10,%esp
      return ip;
80101962:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101965:	eb 77                	jmp    801019de <iget+0xe0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101967:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010196b:	75 10                	jne    8010197d <iget+0x7f>
8010196d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101970:	8b 40 08             	mov    0x8(%eax),%eax
80101973:	85 c0                	test   %eax,%eax
80101975:	75 06                	jne    8010197d <iget+0x7f>
      empty = ip;
80101977:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010197a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010197d:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101984:	81 7d f4 34 26 11 80 	cmpl   $0x80112634,-0xc(%ebp)
8010198b:	72 97                	jb     80101924 <iget+0x26>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
8010198d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101991:	75 0d                	jne    801019a0 <iget+0xa2>
    panic("iget: no inodes");
80101993:	83 ec 0c             	sub    $0xc,%esp
80101996:	68 fd 86 10 80       	push   $0x801086fd
8010199b:	e8 15 ec ff ff       	call   801005b5 <panic>

  ip = empty;
801019a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
801019a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019a9:	8b 55 08             	mov    0x8(%ebp),%edx
801019ac:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
801019ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019b1:	8b 55 0c             	mov    0xc(%ebp),%edx
801019b4:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
801019b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019ba:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
801019c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019c4:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
801019cb:	83 ec 0c             	sub    $0xc,%esp
801019ce:	68 e0 09 11 80       	push   $0x801109e0
801019d3:	e8 f5 37 00 00       	call   801051cd <release>
801019d8:	83 c4 10             	add    $0x10,%esp

  return ip;
801019db:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801019de:	c9                   	leave  
801019df:	c3                   	ret    

801019e0 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801019e0:	55                   	push   %ebp
801019e1:	89 e5                	mov    %esp,%ebp
801019e3:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
801019e6:	83 ec 0c             	sub    $0xc,%esp
801019e9:	68 e0 09 11 80       	push   $0x801109e0
801019ee:	e8 6c 37 00 00       	call   8010515f <acquire>
801019f3:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801019f6:	8b 45 08             	mov    0x8(%ebp),%eax
801019f9:	8b 40 08             	mov    0x8(%eax),%eax
801019fc:	8d 50 01             	lea    0x1(%eax),%edx
801019ff:	8b 45 08             	mov    0x8(%ebp),%eax
80101a02:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101a05:	83 ec 0c             	sub    $0xc,%esp
80101a08:	68 e0 09 11 80       	push   $0x801109e0
80101a0d:	e8 bb 37 00 00       	call   801051cd <release>
80101a12:	83 c4 10             	add    $0x10,%esp
  return ip;
80101a15:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101a18:	c9                   	leave  
80101a19:	c3                   	ret    

80101a1a <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101a1a:	55                   	push   %ebp
80101a1b:	89 e5                	mov    %esp,%ebp
80101a1d:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101a20:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101a24:	74 0a                	je     80101a30 <ilock+0x16>
80101a26:	8b 45 08             	mov    0x8(%ebp),%eax
80101a29:	8b 40 08             	mov    0x8(%eax),%eax
80101a2c:	85 c0                	test   %eax,%eax
80101a2e:	7f 0d                	jg     80101a3d <ilock+0x23>
    panic("ilock");
80101a30:	83 ec 0c             	sub    $0xc,%esp
80101a33:	68 0d 87 10 80       	push   $0x8010870d
80101a38:	e8 78 eb ff ff       	call   801005b5 <panic>

  acquiresleep(&ip->lock);
80101a3d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a40:	83 c0 0c             	add    $0xc,%eax
80101a43:	83 ec 0c             	sub    $0xc,%esp
80101a46:	50                   	push   %eax
80101a47:	e8 aa 35 00 00       	call   80104ff6 <acquiresleep>
80101a4c:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101a4f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a52:	8b 40 4c             	mov    0x4c(%eax),%eax
80101a55:	85 c0                	test   %eax,%eax
80101a57:	0f 85 cd 00 00 00    	jne    80101b2a <ilock+0x110>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a5d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a60:	8b 40 04             	mov    0x4(%eax),%eax
80101a63:	c1 e8 03             	shr    $0x3,%eax
80101a66:	89 c2                	mov    %eax,%edx
80101a68:	a1 d4 09 11 80       	mov    0x801109d4,%eax
80101a6d:	01 c2                	add    %eax,%edx
80101a6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a72:	8b 00                	mov    (%eax),%eax
80101a74:	83 ec 08             	sub    $0x8,%esp
80101a77:	52                   	push   %edx
80101a78:	50                   	push   %eax
80101a79:	e8 51 e7 ff ff       	call   801001cf <bread>
80101a7e:	83 c4 10             	add    $0x10,%esp
80101a81:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a87:	8d 50 5c             	lea    0x5c(%eax),%edx
80101a8a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a8d:	8b 40 04             	mov    0x4(%eax),%eax
80101a90:	83 e0 07             	and    $0x7,%eax
80101a93:	c1 e0 06             	shl    $0x6,%eax
80101a96:	01 d0                	add    %edx,%eax
80101a98:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a9e:	0f b7 10             	movzwl (%eax),%edx
80101aa1:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa4:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101aa8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aab:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101aaf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab2:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101ab6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ab9:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101abd:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac0:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101ac4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ac7:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101acb:	8b 45 08             	mov    0x8(%ebp),%eax
80101ace:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101ad2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ad5:	8b 50 08             	mov    0x8(%eax),%edx
80101ad8:	8b 45 08             	mov    0x8(%ebp),%eax
80101adb:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101ade:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ae1:	8d 50 0c             	lea    0xc(%eax),%edx
80101ae4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae7:	83 c0 5c             	add    $0x5c,%eax
80101aea:	83 ec 04             	sub    $0x4,%esp
80101aed:	6a 34                	push   $0x34
80101aef:	52                   	push   %edx
80101af0:	50                   	push   %eax
80101af1:	e8 ae 39 00 00       	call   801054a4 <memmove>
80101af6:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101af9:	83 ec 0c             	sub    $0xc,%esp
80101afc:	ff 75 f4             	push   -0xc(%ebp)
80101aff:	e8 4d e7 ff ff       	call   80100251 <brelse>
80101b04:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101b07:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0a:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101b11:	8b 45 08             	mov    0x8(%ebp),%eax
80101b14:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101b18:	66 85 c0             	test   %ax,%ax
80101b1b:	75 0d                	jne    80101b2a <ilock+0x110>
      panic("ilock: no type");
80101b1d:	83 ec 0c             	sub    $0xc,%esp
80101b20:	68 13 87 10 80       	push   $0x80108713
80101b25:	e8 8b ea ff ff       	call   801005b5 <panic>
  }
}
80101b2a:	90                   	nop
80101b2b:	c9                   	leave  
80101b2c:	c3                   	ret    

80101b2d <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101b2d:	55                   	push   %ebp
80101b2e:	89 e5                	mov    %esp,%ebp
80101b30:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101b33:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b37:	74 20                	je     80101b59 <iunlock+0x2c>
80101b39:	8b 45 08             	mov    0x8(%ebp),%eax
80101b3c:	83 c0 0c             	add    $0xc,%eax
80101b3f:	83 ec 0c             	sub    $0xc,%esp
80101b42:	50                   	push   %eax
80101b43:	e8 60 35 00 00       	call   801050a8 <holdingsleep>
80101b48:	83 c4 10             	add    $0x10,%esp
80101b4b:	85 c0                	test   %eax,%eax
80101b4d:	74 0a                	je     80101b59 <iunlock+0x2c>
80101b4f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b52:	8b 40 08             	mov    0x8(%eax),%eax
80101b55:	85 c0                	test   %eax,%eax
80101b57:	7f 0d                	jg     80101b66 <iunlock+0x39>
    panic("iunlock");
80101b59:	83 ec 0c             	sub    $0xc,%esp
80101b5c:	68 22 87 10 80       	push   $0x80108722
80101b61:	e8 4f ea ff ff       	call   801005b5 <panic>

  releasesleep(&ip->lock);
80101b66:	8b 45 08             	mov    0x8(%ebp),%eax
80101b69:	83 c0 0c             	add    $0xc,%eax
80101b6c:	83 ec 0c             	sub    $0xc,%esp
80101b6f:	50                   	push   %eax
80101b70:	e8 e5 34 00 00       	call   8010505a <releasesleep>
80101b75:	83 c4 10             	add    $0x10,%esp
}
80101b78:	90                   	nop
80101b79:	c9                   	leave  
80101b7a:	c3                   	ret    

80101b7b <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b7b:	55                   	push   %ebp
80101b7c:	89 e5                	mov    %esp,%ebp
80101b7e:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101b81:	8b 45 08             	mov    0x8(%ebp),%eax
80101b84:	83 c0 0c             	add    $0xc,%eax
80101b87:	83 ec 0c             	sub    $0xc,%esp
80101b8a:	50                   	push   %eax
80101b8b:	e8 66 34 00 00       	call   80104ff6 <acquiresleep>
80101b90:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101b93:	8b 45 08             	mov    0x8(%ebp),%eax
80101b96:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b99:	85 c0                	test   %eax,%eax
80101b9b:	74 6a                	je     80101c07 <iput+0x8c>
80101b9d:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba0:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101ba4:	66 85 c0             	test   %ax,%ax
80101ba7:	75 5e                	jne    80101c07 <iput+0x8c>
    acquire(&icache.lock);
80101ba9:	83 ec 0c             	sub    $0xc,%esp
80101bac:	68 e0 09 11 80       	push   $0x801109e0
80101bb1:	e8 a9 35 00 00       	call   8010515f <acquire>
80101bb6:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101bb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bbc:	8b 40 08             	mov    0x8(%eax),%eax
80101bbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101bc2:	83 ec 0c             	sub    $0xc,%esp
80101bc5:	68 e0 09 11 80       	push   $0x801109e0
80101bca:	e8 fe 35 00 00       	call   801051cd <release>
80101bcf:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101bd2:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101bd6:	75 2f                	jne    80101c07 <iput+0x8c>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101bd8:	83 ec 0c             	sub    $0xc,%esp
80101bdb:	ff 75 08             	push   0x8(%ebp)
80101bde:	e8 ad 01 00 00       	call   80101d90 <itrunc>
80101be3:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101be6:	8b 45 08             	mov    0x8(%ebp),%eax
80101be9:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101bef:	83 ec 0c             	sub    $0xc,%esp
80101bf2:	ff 75 08             	push   0x8(%ebp)
80101bf5:	e8 43 fc ff ff       	call   8010183d <iupdate>
80101bfa:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101bfd:	8b 45 08             	mov    0x8(%ebp),%eax
80101c00:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101c07:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0a:	83 c0 0c             	add    $0xc,%eax
80101c0d:	83 ec 0c             	sub    $0xc,%esp
80101c10:	50                   	push   %eax
80101c11:	e8 44 34 00 00       	call   8010505a <releasesleep>
80101c16:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101c19:	83 ec 0c             	sub    $0xc,%esp
80101c1c:	68 e0 09 11 80       	push   $0x801109e0
80101c21:	e8 39 35 00 00       	call   8010515f <acquire>
80101c26:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101c29:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2c:	8b 40 08             	mov    0x8(%eax),%eax
80101c2f:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c32:	8b 45 08             	mov    0x8(%ebp),%eax
80101c35:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c38:	83 ec 0c             	sub    $0xc,%esp
80101c3b:	68 e0 09 11 80       	push   $0x801109e0
80101c40:	e8 88 35 00 00       	call   801051cd <release>
80101c45:	83 c4 10             	add    $0x10,%esp
}
80101c48:	90                   	nop
80101c49:	c9                   	leave  
80101c4a:	c3                   	ret    

80101c4b <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c4b:	55                   	push   %ebp
80101c4c:	89 e5                	mov    %esp,%ebp
80101c4e:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c51:	83 ec 0c             	sub    $0xc,%esp
80101c54:	ff 75 08             	push   0x8(%ebp)
80101c57:	e8 d1 fe ff ff       	call   80101b2d <iunlock>
80101c5c:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c5f:	83 ec 0c             	sub    $0xc,%esp
80101c62:	ff 75 08             	push   0x8(%ebp)
80101c65:	e8 11 ff ff ff       	call   80101b7b <iput>
80101c6a:	83 c4 10             	add    $0x10,%esp
}
80101c6d:	90                   	nop
80101c6e:	c9                   	leave  
80101c6f:	c3                   	ret    

80101c70 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c70:	55                   	push   %ebp
80101c71:	89 e5                	mov    %esp,%ebp
80101c73:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c76:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c7a:	77 42                	ja     80101cbe <bmap+0x4e>
    if((addr = ip->addrs[bn]) == 0)
80101c7c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c7f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c82:	83 c2 14             	add    $0x14,%edx
80101c85:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c89:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c8c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c90:	75 24                	jne    80101cb6 <bmap+0x46>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c92:	8b 45 08             	mov    0x8(%ebp),%eax
80101c95:	8b 00                	mov    (%eax),%eax
80101c97:	83 ec 0c             	sub    $0xc,%esp
80101c9a:	50                   	push   %eax
80101c9b:	e8 07 f8 ff ff       	call   801014a7 <balloc>
80101ca0:	83 c4 10             	add    $0x10,%esp
80101ca3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ca6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca9:	8b 55 0c             	mov    0xc(%ebp),%edx
80101cac:	8d 4a 14             	lea    0x14(%edx),%ecx
80101caf:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cb2:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101cb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101cb9:	e9 d0 00 00 00       	jmp    80101d8e <bmap+0x11e>
  }
  bn -= NDIRECT;
80101cbe:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101cc2:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101cc6:	0f 87 b5 00 00 00    	ja     80101d81 <bmap+0x111>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101ccc:	8b 45 08             	mov    0x8(%ebp),%eax
80101ccf:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101cd5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cd8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cdc:	75 20                	jne    80101cfe <bmap+0x8e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101cde:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce1:	8b 00                	mov    (%eax),%eax
80101ce3:	83 ec 0c             	sub    $0xc,%esp
80101ce6:	50                   	push   %eax
80101ce7:	e8 bb f7 ff ff       	call   801014a7 <balloc>
80101cec:	83 c4 10             	add    $0x10,%esp
80101cef:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cf2:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cf8:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101cfe:	8b 45 08             	mov    0x8(%ebp),%eax
80101d01:	8b 00                	mov    (%eax),%eax
80101d03:	83 ec 08             	sub    $0x8,%esp
80101d06:	ff 75 f4             	push   -0xc(%ebp)
80101d09:	50                   	push   %eax
80101d0a:	e8 c0 e4 ff ff       	call   801001cf <bread>
80101d0f:	83 c4 10             	add    $0x10,%esp
80101d12:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101d15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d18:	83 c0 5c             	add    $0x5c,%eax
80101d1b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101d1e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d21:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d28:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d2b:	01 d0                	add    %edx,%eax
80101d2d:	8b 00                	mov    (%eax),%eax
80101d2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d32:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d36:	75 36                	jne    80101d6e <bmap+0xfe>
      a[bn] = addr = balloc(ip->dev);
80101d38:	8b 45 08             	mov    0x8(%ebp),%eax
80101d3b:	8b 00                	mov    (%eax),%eax
80101d3d:	83 ec 0c             	sub    $0xc,%esp
80101d40:	50                   	push   %eax
80101d41:	e8 61 f7 ff ff       	call   801014a7 <balloc>
80101d46:	83 c4 10             	add    $0x10,%esp
80101d49:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d4c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d4f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d56:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d59:	01 c2                	add    %eax,%edx
80101d5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d5e:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101d60:	83 ec 0c             	sub    $0xc,%esp
80101d63:	ff 75 f0             	push   -0x10(%ebp)
80101d66:	e8 00 1a 00 00       	call   8010376b <log_write>
80101d6b:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101d6e:	83 ec 0c             	sub    $0xc,%esp
80101d71:	ff 75 f0             	push   -0x10(%ebp)
80101d74:	e8 d8 e4 ff ff       	call   80100251 <brelse>
80101d79:	83 c4 10             	add    $0x10,%esp
    return addr;
80101d7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d7f:	eb 0d                	jmp    80101d8e <bmap+0x11e>
  }

  panic("bmap: out of range");
80101d81:	83 ec 0c             	sub    $0xc,%esp
80101d84:	68 2a 87 10 80       	push   $0x8010872a
80101d89:	e8 27 e8 ff ff       	call   801005b5 <panic>
}
80101d8e:	c9                   	leave  
80101d8f:	c3                   	ret    

80101d90 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d90:	55                   	push   %ebp
80101d91:	89 e5                	mov    %esp,%ebp
80101d93:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d96:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d9d:	eb 45                	jmp    80101de4 <itrunc+0x54>
    if(ip->addrs[i]){
80101d9f:	8b 45 08             	mov    0x8(%ebp),%eax
80101da2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101da5:	83 c2 14             	add    $0x14,%edx
80101da8:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101dac:	85 c0                	test   %eax,%eax
80101dae:	74 30                	je     80101de0 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101db0:	8b 45 08             	mov    0x8(%ebp),%eax
80101db3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101db6:	83 c2 14             	add    $0x14,%edx
80101db9:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101dbd:	8b 55 08             	mov    0x8(%ebp),%edx
80101dc0:	8b 12                	mov    (%edx),%edx
80101dc2:	83 ec 08             	sub    $0x8,%esp
80101dc5:	50                   	push   %eax
80101dc6:	52                   	push   %edx
80101dc7:	e8 1f f8 ff ff       	call   801015eb <bfree>
80101dcc:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101dcf:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101dd5:	83 c2 14             	add    $0x14,%edx
80101dd8:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101ddf:	00 
  for(i = 0; i < NDIRECT; i++){
80101de0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101de4:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101de8:	7e b5                	jle    80101d9f <itrunc+0xf>
    }
  }

  if(ip->addrs[NDIRECT]){
80101dea:	8b 45 08             	mov    0x8(%ebp),%eax
80101ded:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101df3:	85 c0                	test   %eax,%eax
80101df5:	0f 84 aa 00 00 00    	je     80101ea5 <itrunc+0x115>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101dfb:	8b 45 08             	mov    0x8(%ebp),%eax
80101dfe:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101e04:	8b 45 08             	mov    0x8(%ebp),%eax
80101e07:	8b 00                	mov    (%eax),%eax
80101e09:	83 ec 08             	sub    $0x8,%esp
80101e0c:	52                   	push   %edx
80101e0d:	50                   	push   %eax
80101e0e:	e8 bc e3 ff ff       	call   801001cf <bread>
80101e13:	83 c4 10             	add    $0x10,%esp
80101e16:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101e19:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e1c:	83 c0 5c             	add    $0x5c,%eax
80101e1f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101e22:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101e29:	eb 3c                	jmp    80101e67 <itrunc+0xd7>
      if(a[j])
80101e2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e2e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e35:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e38:	01 d0                	add    %edx,%eax
80101e3a:	8b 00                	mov    (%eax),%eax
80101e3c:	85 c0                	test   %eax,%eax
80101e3e:	74 23                	je     80101e63 <itrunc+0xd3>
        bfree(ip->dev, a[j]);
80101e40:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e43:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e4a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e4d:	01 d0                	add    %edx,%eax
80101e4f:	8b 00                	mov    (%eax),%eax
80101e51:	8b 55 08             	mov    0x8(%ebp),%edx
80101e54:	8b 12                	mov    (%edx),%edx
80101e56:	83 ec 08             	sub    $0x8,%esp
80101e59:	50                   	push   %eax
80101e5a:	52                   	push   %edx
80101e5b:	e8 8b f7 ff ff       	call   801015eb <bfree>
80101e60:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101e63:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e6a:	83 f8 7f             	cmp    $0x7f,%eax
80101e6d:	76 bc                	jbe    80101e2b <itrunc+0x9b>
    }
    brelse(bp);
80101e6f:	83 ec 0c             	sub    $0xc,%esp
80101e72:	ff 75 ec             	push   -0x14(%ebp)
80101e75:	e8 d7 e3 ff ff       	call   80100251 <brelse>
80101e7a:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e7d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e80:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e86:	8b 55 08             	mov    0x8(%ebp),%edx
80101e89:	8b 12                	mov    (%edx),%edx
80101e8b:	83 ec 08             	sub    $0x8,%esp
80101e8e:	50                   	push   %eax
80101e8f:	52                   	push   %edx
80101e90:	e8 56 f7 ff ff       	call   801015eb <bfree>
80101e95:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e98:	8b 45 08             	mov    0x8(%ebp),%eax
80101e9b:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101ea2:	00 00 00 
  }

  ip->size = 0;
80101ea5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea8:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101eaf:	83 ec 0c             	sub    $0xc,%esp
80101eb2:	ff 75 08             	push   0x8(%ebp)
80101eb5:	e8 83 f9 ff ff       	call   8010183d <iupdate>
80101eba:	83 c4 10             	add    $0x10,%esp
}
80101ebd:	90                   	nop
80101ebe:	c9                   	leave  
80101ebf:	c3                   	ret    

80101ec0 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101ec0:	55                   	push   %ebp
80101ec1:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101ec3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec6:	8b 00                	mov    (%eax),%eax
80101ec8:	89 c2                	mov    %eax,%edx
80101eca:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ecd:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101ed0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed3:	8b 50 04             	mov    0x4(%eax),%edx
80101ed6:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ed9:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101edc:	8b 45 08             	mov    0x8(%ebp),%eax
80101edf:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101ee3:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ee6:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101ee9:	8b 45 08             	mov    0x8(%ebp),%eax
80101eec:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101ef0:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ef3:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101ef7:	8b 45 08             	mov    0x8(%ebp),%eax
80101efa:	8b 50 58             	mov    0x58(%eax),%edx
80101efd:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f00:	89 50 10             	mov    %edx,0x10(%eax)
}
80101f03:	90                   	nop
80101f04:	5d                   	pop    %ebp
80101f05:	c3                   	ret    

80101f06 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101f06:	55                   	push   %ebp
80101f07:	89 e5                	mov    %esp,%ebp
80101f09:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101f0c:	8b 45 08             	mov    0x8(%ebp),%eax
80101f0f:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101f13:	66 83 f8 03          	cmp    $0x3,%ax
80101f17:	75 5c                	jne    80101f75 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101f19:	8b 45 08             	mov    0x8(%ebp),%eax
80101f1c:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f20:	66 85 c0             	test   %ax,%ax
80101f23:	78 20                	js     80101f45 <readi+0x3f>
80101f25:	8b 45 08             	mov    0x8(%ebp),%eax
80101f28:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f2c:	66 83 f8 09          	cmp    $0x9,%ax
80101f30:	7f 13                	jg     80101f45 <readi+0x3f>
80101f32:	8b 45 08             	mov    0x8(%ebp),%eax
80101f35:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f39:	98                   	cwtl   
80101f3a:	8b 04 c5 c0 ff 10 80 	mov    -0x7fef0040(,%eax,8),%eax
80101f41:	85 c0                	test   %eax,%eax
80101f43:	75 0a                	jne    80101f4f <readi+0x49>
      return -1;
80101f45:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f4a:	e9 0a 01 00 00       	jmp    80102059 <readi+0x153>
    return devsw[ip->major].read(ip, dst, n);
80101f4f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f52:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f56:	98                   	cwtl   
80101f57:	8b 04 c5 c0 ff 10 80 	mov    -0x7fef0040(,%eax,8),%eax
80101f5e:	8b 55 14             	mov    0x14(%ebp),%edx
80101f61:	83 ec 04             	sub    $0x4,%esp
80101f64:	52                   	push   %edx
80101f65:	ff 75 0c             	push   0xc(%ebp)
80101f68:	ff 75 08             	push   0x8(%ebp)
80101f6b:	ff d0                	call   *%eax
80101f6d:	83 c4 10             	add    $0x10,%esp
80101f70:	e9 e4 00 00 00       	jmp    80102059 <readi+0x153>
  }

  if(off > ip->size || off + n < off)
80101f75:	8b 45 08             	mov    0x8(%ebp),%eax
80101f78:	8b 40 58             	mov    0x58(%eax),%eax
80101f7b:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f7e:	77 0d                	ja     80101f8d <readi+0x87>
80101f80:	8b 55 10             	mov    0x10(%ebp),%edx
80101f83:	8b 45 14             	mov    0x14(%ebp),%eax
80101f86:	01 d0                	add    %edx,%eax
80101f88:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f8b:	76 0a                	jbe    80101f97 <readi+0x91>
    return -1;
80101f8d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f92:	e9 c2 00 00 00       	jmp    80102059 <readi+0x153>
  if(off + n > ip->size)
80101f97:	8b 55 10             	mov    0x10(%ebp),%edx
80101f9a:	8b 45 14             	mov    0x14(%ebp),%eax
80101f9d:	01 c2                	add    %eax,%edx
80101f9f:	8b 45 08             	mov    0x8(%ebp),%eax
80101fa2:	8b 40 58             	mov    0x58(%eax),%eax
80101fa5:	39 c2                	cmp    %eax,%edx
80101fa7:	76 0c                	jbe    80101fb5 <readi+0xaf>
    n = ip->size - off;
80101fa9:	8b 45 08             	mov    0x8(%ebp),%eax
80101fac:	8b 40 58             	mov    0x58(%eax),%eax
80101faf:	2b 45 10             	sub    0x10(%ebp),%eax
80101fb2:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101fb5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101fbc:	e9 89 00 00 00       	jmp    8010204a <readi+0x144>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101fc1:	8b 45 10             	mov    0x10(%ebp),%eax
80101fc4:	c1 e8 09             	shr    $0x9,%eax
80101fc7:	83 ec 08             	sub    $0x8,%esp
80101fca:	50                   	push   %eax
80101fcb:	ff 75 08             	push   0x8(%ebp)
80101fce:	e8 9d fc ff ff       	call   80101c70 <bmap>
80101fd3:	83 c4 10             	add    $0x10,%esp
80101fd6:	8b 55 08             	mov    0x8(%ebp),%edx
80101fd9:	8b 12                	mov    (%edx),%edx
80101fdb:	83 ec 08             	sub    $0x8,%esp
80101fde:	50                   	push   %eax
80101fdf:	52                   	push   %edx
80101fe0:	e8 ea e1 ff ff       	call   801001cf <bread>
80101fe5:	83 c4 10             	add    $0x10,%esp
80101fe8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101feb:	8b 45 10             	mov    0x10(%ebp),%eax
80101fee:	25 ff 01 00 00       	and    $0x1ff,%eax
80101ff3:	ba 00 02 00 00       	mov    $0x200,%edx
80101ff8:	29 c2                	sub    %eax,%edx
80101ffa:	8b 45 14             	mov    0x14(%ebp),%eax
80101ffd:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102000:	39 c2                	cmp    %eax,%edx
80102002:	0f 46 c2             	cmovbe %edx,%eax
80102005:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80102008:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010200b:	8d 50 5c             	lea    0x5c(%eax),%edx
8010200e:	8b 45 10             	mov    0x10(%ebp),%eax
80102011:	25 ff 01 00 00       	and    $0x1ff,%eax
80102016:	01 d0                	add    %edx,%eax
80102018:	83 ec 04             	sub    $0x4,%esp
8010201b:	ff 75 ec             	push   -0x14(%ebp)
8010201e:	50                   	push   %eax
8010201f:	ff 75 0c             	push   0xc(%ebp)
80102022:	e8 7d 34 00 00       	call   801054a4 <memmove>
80102027:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
8010202a:	83 ec 0c             	sub    $0xc,%esp
8010202d:	ff 75 f0             	push   -0x10(%ebp)
80102030:	e8 1c e2 ff ff       	call   80100251 <brelse>
80102035:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102038:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010203b:	01 45 f4             	add    %eax,-0xc(%ebp)
8010203e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102041:	01 45 10             	add    %eax,0x10(%ebp)
80102044:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102047:	01 45 0c             	add    %eax,0xc(%ebp)
8010204a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010204d:	3b 45 14             	cmp    0x14(%ebp),%eax
80102050:	0f 82 6b ff ff ff    	jb     80101fc1 <readi+0xbb>
  }
  return n;
80102056:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102059:	c9                   	leave  
8010205a:	c3                   	ret    

8010205b <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
8010205b:	55                   	push   %ebp
8010205c:	89 e5                	mov    %esp,%ebp
8010205e:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102061:	8b 45 08             	mov    0x8(%ebp),%eax
80102064:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102068:	66 83 f8 03          	cmp    $0x3,%ax
8010206c:	75 5c                	jne    801020ca <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
8010206e:	8b 45 08             	mov    0x8(%ebp),%eax
80102071:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102075:	66 85 c0             	test   %ax,%ax
80102078:	78 20                	js     8010209a <writei+0x3f>
8010207a:	8b 45 08             	mov    0x8(%ebp),%eax
8010207d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102081:	66 83 f8 09          	cmp    $0x9,%ax
80102085:	7f 13                	jg     8010209a <writei+0x3f>
80102087:	8b 45 08             	mov    0x8(%ebp),%eax
8010208a:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010208e:	98                   	cwtl   
8010208f:	8b 04 c5 c4 ff 10 80 	mov    -0x7fef003c(,%eax,8),%eax
80102096:	85 c0                	test   %eax,%eax
80102098:	75 0a                	jne    801020a4 <writei+0x49>
      return -1;
8010209a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010209f:	e9 3b 01 00 00       	jmp    801021df <writei+0x184>
    return devsw[ip->major].write(ip, src, n);
801020a4:	8b 45 08             	mov    0x8(%ebp),%eax
801020a7:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801020ab:	98                   	cwtl   
801020ac:	8b 04 c5 c4 ff 10 80 	mov    -0x7fef003c(,%eax,8),%eax
801020b3:	8b 55 14             	mov    0x14(%ebp),%edx
801020b6:	83 ec 04             	sub    $0x4,%esp
801020b9:	52                   	push   %edx
801020ba:	ff 75 0c             	push   0xc(%ebp)
801020bd:	ff 75 08             	push   0x8(%ebp)
801020c0:	ff d0                	call   *%eax
801020c2:	83 c4 10             	add    $0x10,%esp
801020c5:	e9 15 01 00 00       	jmp    801021df <writei+0x184>
  }

  if(off > ip->size || off + n < off)
801020ca:	8b 45 08             	mov    0x8(%ebp),%eax
801020cd:	8b 40 58             	mov    0x58(%eax),%eax
801020d0:	39 45 10             	cmp    %eax,0x10(%ebp)
801020d3:	77 0d                	ja     801020e2 <writei+0x87>
801020d5:	8b 55 10             	mov    0x10(%ebp),%edx
801020d8:	8b 45 14             	mov    0x14(%ebp),%eax
801020db:	01 d0                	add    %edx,%eax
801020dd:	39 45 10             	cmp    %eax,0x10(%ebp)
801020e0:	76 0a                	jbe    801020ec <writei+0x91>
    return -1;
801020e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020e7:	e9 f3 00 00 00       	jmp    801021df <writei+0x184>
  if(off + n > MAXFILE*BSIZE)
801020ec:	8b 55 10             	mov    0x10(%ebp),%edx
801020ef:	8b 45 14             	mov    0x14(%ebp),%eax
801020f2:	01 d0                	add    %edx,%eax
801020f4:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020f9:	76 0a                	jbe    80102105 <writei+0xaa>
    return -1;
801020fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102100:	e9 da 00 00 00       	jmp    801021df <writei+0x184>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102105:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010210c:	e9 97 00 00 00       	jmp    801021a8 <writei+0x14d>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102111:	8b 45 10             	mov    0x10(%ebp),%eax
80102114:	c1 e8 09             	shr    $0x9,%eax
80102117:	83 ec 08             	sub    $0x8,%esp
8010211a:	50                   	push   %eax
8010211b:	ff 75 08             	push   0x8(%ebp)
8010211e:	e8 4d fb ff ff       	call   80101c70 <bmap>
80102123:	83 c4 10             	add    $0x10,%esp
80102126:	8b 55 08             	mov    0x8(%ebp),%edx
80102129:	8b 12                	mov    (%edx),%edx
8010212b:	83 ec 08             	sub    $0x8,%esp
8010212e:	50                   	push   %eax
8010212f:	52                   	push   %edx
80102130:	e8 9a e0 ff ff       	call   801001cf <bread>
80102135:	83 c4 10             	add    $0x10,%esp
80102138:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010213b:	8b 45 10             	mov    0x10(%ebp),%eax
8010213e:	25 ff 01 00 00       	and    $0x1ff,%eax
80102143:	ba 00 02 00 00       	mov    $0x200,%edx
80102148:	29 c2                	sub    %eax,%edx
8010214a:	8b 45 14             	mov    0x14(%ebp),%eax
8010214d:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102150:	39 c2                	cmp    %eax,%edx
80102152:	0f 46 c2             	cmovbe %edx,%eax
80102155:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102158:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010215b:	8d 50 5c             	lea    0x5c(%eax),%edx
8010215e:	8b 45 10             	mov    0x10(%ebp),%eax
80102161:	25 ff 01 00 00       	and    $0x1ff,%eax
80102166:	01 d0                	add    %edx,%eax
80102168:	83 ec 04             	sub    $0x4,%esp
8010216b:	ff 75 ec             	push   -0x14(%ebp)
8010216e:	ff 75 0c             	push   0xc(%ebp)
80102171:	50                   	push   %eax
80102172:	e8 2d 33 00 00       	call   801054a4 <memmove>
80102177:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
8010217a:	83 ec 0c             	sub    $0xc,%esp
8010217d:	ff 75 f0             	push   -0x10(%ebp)
80102180:	e8 e6 15 00 00       	call   8010376b <log_write>
80102185:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102188:	83 ec 0c             	sub    $0xc,%esp
8010218b:	ff 75 f0             	push   -0x10(%ebp)
8010218e:	e8 be e0 ff ff       	call   80100251 <brelse>
80102193:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102196:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102199:	01 45 f4             	add    %eax,-0xc(%ebp)
8010219c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010219f:	01 45 10             	add    %eax,0x10(%ebp)
801021a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021a5:	01 45 0c             	add    %eax,0xc(%ebp)
801021a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021ab:	3b 45 14             	cmp    0x14(%ebp),%eax
801021ae:	0f 82 5d ff ff ff    	jb     80102111 <writei+0xb6>
  }

  if(n > 0 && off > ip->size){
801021b4:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801021b8:	74 22                	je     801021dc <writei+0x181>
801021ba:	8b 45 08             	mov    0x8(%ebp),%eax
801021bd:	8b 40 58             	mov    0x58(%eax),%eax
801021c0:	39 45 10             	cmp    %eax,0x10(%ebp)
801021c3:	76 17                	jbe    801021dc <writei+0x181>
    ip->size = off;
801021c5:	8b 45 08             	mov    0x8(%ebp),%eax
801021c8:	8b 55 10             	mov    0x10(%ebp),%edx
801021cb:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
801021ce:	83 ec 0c             	sub    $0xc,%esp
801021d1:	ff 75 08             	push   0x8(%ebp)
801021d4:	e8 64 f6 ff ff       	call   8010183d <iupdate>
801021d9:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801021dc:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021df:	c9                   	leave  
801021e0:	c3                   	ret    

801021e1 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801021e1:	55                   	push   %ebp
801021e2:	89 e5                	mov    %esp,%ebp
801021e4:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801021e7:	83 ec 04             	sub    $0x4,%esp
801021ea:	6a 0e                	push   $0xe
801021ec:	ff 75 0c             	push   0xc(%ebp)
801021ef:	ff 75 08             	push   0x8(%ebp)
801021f2:	e8 43 33 00 00       	call   8010553a <strncmp>
801021f7:	83 c4 10             	add    $0x10,%esp
}
801021fa:	c9                   	leave  
801021fb:	c3                   	ret    

801021fc <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021fc:	55                   	push   %ebp
801021fd:	89 e5                	mov    %esp,%ebp
801021ff:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102202:	8b 45 08             	mov    0x8(%ebp),%eax
80102205:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102209:	66 83 f8 01          	cmp    $0x1,%ax
8010220d:	74 0d                	je     8010221c <dirlookup+0x20>
    panic("dirlookup not DIR");
8010220f:	83 ec 0c             	sub    $0xc,%esp
80102212:	68 3d 87 10 80       	push   $0x8010873d
80102217:	e8 99 e3 ff ff       	call   801005b5 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
8010221c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102223:	eb 7b                	jmp    801022a0 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102225:	6a 10                	push   $0x10
80102227:	ff 75 f4             	push   -0xc(%ebp)
8010222a:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010222d:	50                   	push   %eax
8010222e:	ff 75 08             	push   0x8(%ebp)
80102231:	e8 d0 fc ff ff       	call   80101f06 <readi>
80102236:	83 c4 10             	add    $0x10,%esp
80102239:	83 f8 10             	cmp    $0x10,%eax
8010223c:	74 0d                	je     8010224b <dirlookup+0x4f>
      panic("dirlookup read");
8010223e:	83 ec 0c             	sub    $0xc,%esp
80102241:	68 4f 87 10 80       	push   $0x8010874f
80102246:	e8 6a e3 ff ff       	call   801005b5 <panic>
    if(de.inum == 0)
8010224b:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010224f:	66 85 c0             	test   %ax,%ax
80102252:	74 47                	je     8010229b <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
80102254:	83 ec 08             	sub    $0x8,%esp
80102257:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010225a:	83 c0 02             	add    $0x2,%eax
8010225d:	50                   	push   %eax
8010225e:	ff 75 0c             	push   0xc(%ebp)
80102261:	e8 7b ff ff ff       	call   801021e1 <namecmp>
80102266:	83 c4 10             	add    $0x10,%esp
80102269:	85 c0                	test   %eax,%eax
8010226b:	75 2f                	jne    8010229c <dirlookup+0xa0>
      // entry matches path element
      if(poff)
8010226d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102271:	74 08                	je     8010227b <dirlookup+0x7f>
        *poff = off;
80102273:	8b 45 10             	mov    0x10(%ebp),%eax
80102276:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102279:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010227b:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010227f:	0f b7 c0             	movzwl %ax,%eax
80102282:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102285:	8b 45 08             	mov    0x8(%ebp),%eax
80102288:	8b 00                	mov    (%eax),%eax
8010228a:	83 ec 08             	sub    $0x8,%esp
8010228d:	ff 75 f0             	push   -0x10(%ebp)
80102290:	50                   	push   %eax
80102291:	e8 68 f6 ff ff       	call   801018fe <iget>
80102296:	83 c4 10             	add    $0x10,%esp
80102299:	eb 19                	jmp    801022b4 <dirlookup+0xb8>
      continue;
8010229b:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
8010229c:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801022a0:	8b 45 08             	mov    0x8(%ebp),%eax
801022a3:	8b 40 58             	mov    0x58(%eax),%eax
801022a6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801022a9:	0f 82 76 ff ff ff    	jb     80102225 <dirlookup+0x29>
    }
  }

  return 0;
801022af:	b8 00 00 00 00       	mov    $0x0,%eax
}
801022b4:	c9                   	leave  
801022b5:	c3                   	ret    

801022b6 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
801022b6:	55                   	push   %ebp
801022b7:	89 e5                	mov    %esp,%ebp
801022b9:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801022bc:	83 ec 04             	sub    $0x4,%esp
801022bf:	6a 00                	push   $0x0
801022c1:	ff 75 0c             	push   0xc(%ebp)
801022c4:	ff 75 08             	push   0x8(%ebp)
801022c7:	e8 30 ff ff ff       	call   801021fc <dirlookup>
801022cc:	83 c4 10             	add    $0x10,%esp
801022cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
801022d2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801022d6:	74 18                	je     801022f0 <dirlink+0x3a>
    iput(ip);
801022d8:	83 ec 0c             	sub    $0xc,%esp
801022db:	ff 75 f0             	push   -0x10(%ebp)
801022de:	e8 98 f8 ff ff       	call   80101b7b <iput>
801022e3:	83 c4 10             	add    $0x10,%esp
    return -1;
801022e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022eb:	e9 9c 00 00 00       	jmp    8010238c <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022f0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022f7:	eb 39                	jmp    80102332 <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022fc:	6a 10                	push   $0x10
801022fe:	50                   	push   %eax
801022ff:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102302:	50                   	push   %eax
80102303:	ff 75 08             	push   0x8(%ebp)
80102306:	e8 fb fb ff ff       	call   80101f06 <readi>
8010230b:	83 c4 10             	add    $0x10,%esp
8010230e:	83 f8 10             	cmp    $0x10,%eax
80102311:	74 0d                	je     80102320 <dirlink+0x6a>
      panic("dirlink read");
80102313:	83 ec 0c             	sub    $0xc,%esp
80102316:	68 5e 87 10 80       	push   $0x8010875e
8010231b:	e8 95 e2 ff ff       	call   801005b5 <panic>
    if(de.inum == 0)
80102320:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102324:	66 85 c0             	test   %ax,%ax
80102327:	74 18                	je     80102341 <dirlink+0x8b>
  for(off = 0; off < dp->size; off += sizeof(de)){
80102329:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010232c:	83 c0 10             	add    $0x10,%eax
8010232f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102332:	8b 45 08             	mov    0x8(%ebp),%eax
80102335:	8b 50 58             	mov    0x58(%eax),%edx
80102338:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010233b:	39 c2                	cmp    %eax,%edx
8010233d:	77 ba                	ja     801022f9 <dirlink+0x43>
8010233f:	eb 01                	jmp    80102342 <dirlink+0x8c>
      break;
80102341:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102342:	83 ec 04             	sub    $0x4,%esp
80102345:	6a 0e                	push   $0xe
80102347:	ff 75 0c             	push   0xc(%ebp)
8010234a:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010234d:	83 c0 02             	add    $0x2,%eax
80102350:	50                   	push   %eax
80102351:	e8 3a 32 00 00       	call   80105590 <strncpy>
80102356:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102359:	8b 45 10             	mov    0x10(%ebp),%eax
8010235c:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102360:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102363:	6a 10                	push   $0x10
80102365:	50                   	push   %eax
80102366:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102369:	50                   	push   %eax
8010236a:	ff 75 08             	push   0x8(%ebp)
8010236d:	e8 e9 fc ff ff       	call   8010205b <writei>
80102372:	83 c4 10             	add    $0x10,%esp
80102375:	83 f8 10             	cmp    $0x10,%eax
80102378:	74 0d                	je     80102387 <dirlink+0xd1>
    panic("dirlink");
8010237a:	83 ec 0c             	sub    $0xc,%esp
8010237d:	68 6b 87 10 80       	push   $0x8010876b
80102382:	e8 2e e2 ff ff       	call   801005b5 <panic>

  return 0;
80102387:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010238c:	c9                   	leave  
8010238d:	c3                   	ret    

8010238e <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010238e:	55                   	push   %ebp
8010238f:	89 e5                	mov    %esp,%ebp
80102391:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
80102394:	eb 04                	jmp    8010239a <skipelem+0xc>
    path++;
80102396:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
8010239a:	8b 45 08             	mov    0x8(%ebp),%eax
8010239d:	0f b6 00             	movzbl (%eax),%eax
801023a0:	3c 2f                	cmp    $0x2f,%al
801023a2:	74 f2                	je     80102396 <skipelem+0x8>
  if(*path == 0)
801023a4:	8b 45 08             	mov    0x8(%ebp),%eax
801023a7:	0f b6 00             	movzbl (%eax),%eax
801023aa:	84 c0                	test   %al,%al
801023ac:	75 07                	jne    801023b5 <skipelem+0x27>
    return 0;
801023ae:	b8 00 00 00 00       	mov    $0x0,%eax
801023b3:	eb 77                	jmp    8010242c <skipelem+0x9e>
  s = path;
801023b5:	8b 45 08             	mov    0x8(%ebp),%eax
801023b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801023bb:	eb 04                	jmp    801023c1 <skipelem+0x33>
    path++;
801023bd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
801023c1:	8b 45 08             	mov    0x8(%ebp),%eax
801023c4:	0f b6 00             	movzbl (%eax),%eax
801023c7:	3c 2f                	cmp    $0x2f,%al
801023c9:	74 0a                	je     801023d5 <skipelem+0x47>
801023cb:	8b 45 08             	mov    0x8(%ebp),%eax
801023ce:	0f b6 00             	movzbl (%eax),%eax
801023d1:	84 c0                	test   %al,%al
801023d3:	75 e8                	jne    801023bd <skipelem+0x2f>
  len = path - s;
801023d5:	8b 45 08             	mov    0x8(%ebp),%eax
801023d8:	2b 45 f4             	sub    -0xc(%ebp),%eax
801023db:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801023de:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801023e2:	7e 15                	jle    801023f9 <skipelem+0x6b>
    memmove(name, s, DIRSIZ);
801023e4:	83 ec 04             	sub    $0x4,%esp
801023e7:	6a 0e                	push   $0xe
801023e9:	ff 75 f4             	push   -0xc(%ebp)
801023ec:	ff 75 0c             	push   0xc(%ebp)
801023ef:	e8 b0 30 00 00       	call   801054a4 <memmove>
801023f4:	83 c4 10             	add    $0x10,%esp
801023f7:	eb 26                	jmp    8010241f <skipelem+0x91>
  else {
    memmove(name, s, len);
801023f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023fc:	83 ec 04             	sub    $0x4,%esp
801023ff:	50                   	push   %eax
80102400:	ff 75 f4             	push   -0xc(%ebp)
80102403:	ff 75 0c             	push   0xc(%ebp)
80102406:	e8 99 30 00 00       	call   801054a4 <memmove>
8010240b:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
8010240e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102411:	8b 45 0c             	mov    0xc(%ebp),%eax
80102414:	01 d0                	add    %edx,%eax
80102416:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102419:	eb 04                	jmp    8010241f <skipelem+0x91>
    path++;
8010241b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
8010241f:	8b 45 08             	mov    0x8(%ebp),%eax
80102422:	0f b6 00             	movzbl (%eax),%eax
80102425:	3c 2f                	cmp    $0x2f,%al
80102427:	74 f2                	je     8010241b <skipelem+0x8d>
  return path;
80102429:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010242c:	c9                   	leave  
8010242d:	c3                   	ret    

8010242e <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
8010242e:	55                   	push   %ebp
8010242f:	89 e5                	mov    %esp,%ebp
80102431:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102434:	8b 45 08             	mov    0x8(%ebp),%eax
80102437:	0f b6 00             	movzbl (%eax),%eax
8010243a:	3c 2f                	cmp    $0x2f,%al
8010243c:	75 17                	jne    80102455 <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
8010243e:	83 ec 08             	sub    $0x8,%esp
80102441:	6a 01                	push   $0x1
80102443:	6a 01                	push   $0x1
80102445:	e8 b4 f4 ff ff       	call   801018fe <iget>
8010244a:	83 c4 10             	add    $0x10,%esp
8010244d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102450:	e9 ba 00 00 00       	jmp    8010250f <namex+0xe1>
  else
    ip = idup(myproc()->cwd);
80102455:	e8 3f 1e 00 00       	call   80104299 <myproc>
8010245a:	8b 40 68             	mov    0x68(%eax),%eax
8010245d:	83 ec 0c             	sub    $0xc,%esp
80102460:	50                   	push   %eax
80102461:	e8 7a f5 ff ff       	call   801019e0 <idup>
80102466:	83 c4 10             	add    $0x10,%esp
80102469:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010246c:	e9 9e 00 00 00       	jmp    8010250f <namex+0xe1>
    ilock(ip);
80102471:	83 ec 0c             	sub    $0xc,%esp
80102474:	ff 75 f4             	push   -0xc(%ebp)
80102477:	e8 9e f5 ff ff       	call   80101a1a <ilock>
8010247c:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
8010247f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102482:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102486:	66 83 f8 01          	cmp    $0x1,%ax
8010248a:	74 18                	je     801024a4 <namex+0x76>
      iunlockput(ip);
8010248c:	83 ec 0c             	sub    $0xc,%esp
8010248f:	ff 75 f4             	push   -0xc(%ebp)
80102492:	e8 b4 f7 ff ff       	call   80101c4b <iunlockput>
80102497:	83 c4 10             	add    $0x10,%esp
      return 0;
8010249a:	b8 00 00 00 00       	mov    $0x0,%eax
8010249f:	e9 a7 00 00 00       	jmp    8010254b <namex+0x11d>
    }
    if(nameiparent && *path == '\0'){
801024a4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801024a8:	74 20                	je     801024ca <namex+0x9c>
801024aa:	8b 45 08             	mov    0x8(%ebp),%eax
801024ad:	0f b6 00             	movzbl (%eax),%eax
801024b0:	84 c0                	test   %al,%al
801024b2:	75 16                	jne    801024ca <namex+0x9c>
      // Stop one level early.
      iunlock(ip);
801024b4:	83 ec 0c             	sub    $0xc,%esp
801024b7:	ff 75 f4             	push   -0xc(%ebp)
801024ba:	e8 6e f6 ff ff       	call   80101b2d <iunlock>
801024bf:	83 c4 10             	add    $0x10,%esp
      return ip;
801024c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024c5:	e9 81 00 00 00       	jmp    8010254b <namex+0x11d>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801024ca:	83 ec 04             	sub    $0x4,%esp
801024cd:	6a 00                	push   $0x0
801024cf:	ff 75 10             	push   0x10(%ebp)
801024d2:	ff 75 f4             	push   -0xc(%ebp)
801024d5:	e8 22 fd ff ff       	call   801021fc <dirlookup>
801024da:	83 c4 10             	add    $0x10,%esp
801024dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024e0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024e4:	75 15                	jne    801024fb <namex+0xcd>
      iunlockput(ip);
801024e6:	83 ec 0c             	sub    $0xc,%esp
801024e9:	ff 75 f4             	push   -0xc(%ebp)
801024ec:	e8 5a f7 ff ff       	call   80101c4b <iunlockput>
801024f1:	83 c4 10             	add    $0x10,%esp
      return 0;
801024f4:	b8 00 00 00 00       	mov    $0x0,%eax
801024f9:	eb 50                	jmp    8010254b <namex+0x11d>
    }
    iunlockput(ip);
801024fb:	83 ec 0c             	sub    $0xc,%esp
801024fe:	ff 75 f4             	push   -0xc(%ebp)
80102501:	e8 45 f7 ff ff       	call   80101c4b <iunlockput>
80102506:	83 c4 10             	add    $0x10,%esp
    ip = next;
80102509:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010250c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
8010250f:	83 ec 08             	sub    $0x8,%esp
80102512:	ff 75 10             	push   0x10(%ebp)
80102515:	ff 75 08             	push   0x8(%ebp)
80102518:	e8 71 fe ff ff       	call   8010238e <skipelem>
8010251d:	83 c4 10             	add    $0x10,%esp
80102520:	89 45 08             	mov    %eax,0x8(%ebp)
80102523:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102527:	0f 85 44 ff ff ff    	jne    80102471 <namex+0x43>
  }
  if(nameiparent){
8010252d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102531:	74 15                	je     80102548 <namex+0x11a>
    iput(ip);
80102533:	83 ec 0c             	sub    $0xc,%esp
80102536:	ff 75 f4             	push   -0xc(%ebp)
80102539:	e8 3d f6 ff ff       	call   80101b7b <iput>
8010253e:	83 c4 10             	add    $0x10,%esp
    return 0;
80102541:	b8 00 00 00 00       	mov    $0x0,%eax
80102546:	eb 03                	jmp    8010254b <namex+0x11d>
  }
  return ip;
80102548:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010254b:	c9                   	leave  
8010254c:	c3                   	ret    

8010254d <namei>:

struct inode*
namei(char *path)
{
8010254d:	55                   	push   %ebp
8010254e:	89 e5                	mov    %esp,%ebp
80102550:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102553:	83 ec 04             	sub    $0x4,%esp
80102556:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102559:	50                   	push   %eax
8010255a:	6a 00                	push   $0x0
8010255c:	ff 75 08             	push   0x8(%ebp)
8010255f:	e8 ca fe ff ff       	call   8010242e <namex>
80102564:	83 c4 10             	add    $0x10,%esp
}
80102567:	c9                   	leave  
80102568:	c3                   	ret    

80102569 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102569:	55                   	push   %ebp
8010256a:	89 e5                	mov    %esp,%ebp
8010256c:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
8010256f:	83 ec 04             	sub    $0x4,%esp
80102572:	ff 75 0c             	push   0xc(%ebp)
80102575:	6a 01                	push   $0x1
80102577:	ff 75 08             	push   0x8(%ebp)
8010257a:	e8 af fe ff ff       	call   8010242e <namex>
8010257f:	83 c4 10             	add    $0x10,%esp
}
80102582:	c9                   	leave  
80102583:	c3                   	ret    

80102584 <inb>:
{
80102584:	55                   	push   %ebp
80102585:	89 e5                	mov    %esp,%ebp
80102587:	83 ec 14             	sub    $0x14,%esp
8010258a:	8b 45 08             	mov    0x8(%ebp),%eax
8010258d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102591:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102595:	89 c2                	mov    %eax,%edx
80102597:	ec                   	in     (%dx),%al
80102598:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010259b:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010259f:	c9                   	leave  
801025a0:	c3                   	ret    

801025a1 <insl>:
{
801025a1:	55                   	push   %ebp
801025a2:	89 e5                	mov    %esp,%ebp
801025a4:	57                   	push   %edi
801025a5:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
801025a6:	8b 55 08             	mov    0x8(%ebp),%edx
801025a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801025ac:	8b 45 10             	mov    0x10(%ebp),%eax
801025af:	89 cb                	mov    %ecx,%ebx
801025b1:	89 df                	mov    %ebx,%edi
801025b3:	89 c1                	mov    %eax,%ecx
801025b5:	fc                   	cld    
801025b6:	f3 6d                	rep insl (%dx),%es:(%edi)
801025b8:	89 c8                	mov    %ecx,%eax
801025ba:	89 fb                	mov    %edi,%ebx
801025bc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801025bf:	89 45 10             	mov    %eax,0x10(%ebp)
}
801025c2:	90                   	nop
801025c3:	5b                   	pop    %ebx
801025c4:	5f                   	pop    %edi
801025c5:	5d                   	pop    %ebp
801025c6:	c3                   	ret    

801025c7 <outb>:
{
801025c7:	55                   	push   %ebp
801025c8:	89 e5                	mov    %esp,%ebp
801025ca:	83 ec 08             	sub    $0x8,%esp
801025cd:	8b 45 08             	mov    0x8(%ebp),%eax
801025d0:	8b 55 0c             	mov    0xc(%ebp),%edx
801025d3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801025d7:	89 d0                	mov    %edx,%eax
801025d9:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801025dc:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801025e0:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801025e4:	ee                   	out    %al,(%dx)
}
801025e5:	90                   	nop
801025e6:	c9                   	leave  
801025e7:	c3                   	ret    

801025e8 <outsl>:
{
801025e8:	55                   	push   %ebp
801025e9:	89 e5                	mov    %esp,%ebp
801025eb:	56                   	push   %esi
801025ec:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801025ed:	8b 55 08             	mov    0x8(%ebp),%edx
801025f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801025f3:	8b 45 10             	mov    0x10(%ebp),%eax
801025f6:	89 cb                	mov    %ecx,%ebx
801025f8:	89 de                	mov    %ebx,%esi
801025fa:	89 c1                	mov    %eax,%ecx
801025fc:	fc                   	cld    
801025fd:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801025ff:	89 c8                	mov    %ecx,%eax
80102601:	89 f3                	mov    %esi,%ebx
80102603:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102606:	89 45 10             	mov    %eax,0x10(%ebp)
}
80102609:	90                   	nop
8010260a:	5b                   	pop    %ebx
8010260b:	5e                   	pop    %esi
8010260c:	5d                   	pop    %ebp
8010260d:	c3                   	ret    

8010260e <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
8010260e:	55                   	push   %ebp
8010260f:	89 e5                	mov    %esp,%ebp
80102611:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80102614:	90                   	nop
80102615:	68 f7 01 00 00       	push   $0x1f7
8010261a:	e8 65 ff ff ff       	call   80102584 <inb>
8010261f:	83 c4 04             	add    $0x4,%esp
80102622:	0f b6 c0             	movzbl %al,%eax
80102625:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102628:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010262b:	25 c0 00 00 00       	and    $0xc0,%eax
80102630:	83 f8 40             	cmp    $0x40,%eax
80102633:	75 e0                	jne    80102615 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102635:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102639:	74 11                	je     8010264c <idewait+0x3e>
8010263b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010263e:	83 e0 21             	and    $0x21,%eax
80102641:	85 c0                	test   %eax,%eax
80102643:	74 07                	je     8010264c <idewait+0x3e>
    return -1;
80102645:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010264a:	eb 05                	jmp    80102651 <idewait+0x43>
  return 0;
8010264c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102651:	c9                   	leave  
80102652:	c3                   	ret    

80102653 <ideinit>:

void
ideinit(void)
{
80102653:	55                   	push   %ebp
80102654:	89 e5                	mov    %esp,%ebp
80102656:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
80102659:	83 ec 08             	sub    $0x8,%esp
8010265c:	68 73 87 10 80       	push   $0x80108773
80102661:	68 40 26 11 80       	push   $0x80112640
80102666:	e8 d2 2a 00 00       	call   8010513d <initlock>
8010266b:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
8010266e:	a1 40 2d 11 80       	mov    0x80112d40,%eax
80102673:	83 e8 01             	sub    $0x1,%eax
80102676:	83 ec 08             	sub    $0x8,%esp
80102679:	50                   	push   %eax
8010267a:	6a 0e                	push   $0xe
8010267c:	e8 a3 04 00 00       	call   80102b24 <ioapicenable>
80102681:	83 c4 10             	add    $0x10,%esp
  idewait(0);
80102684:	83 ec 0c             	sub    $0xc,%esp
80102687:	6a 00                	push   $0x0
80102689:	e8 80 ff ff ff       	call   8010260e <idewait>
8010268e:	83 c4 10             	add    $0x10,%esp

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102691:	83 ec 08             	sub    $0x8,%esp
80102694:	68 f0 00 00 00       	push   $0xf0
80102699:	68 f6 01 00 00       	push   $0x1f6
8010269e:	e8 24 ff ff ff       	call   801025c7 <outb>
801026a3:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
801026a6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801026ad:	eb 24                	jmp    801026d3 <ideinit+0x80>
    if(inb(0x1f7) != 0){
801026af:	83 ec 0c             	sub    $0xc,%esp
801026b2:	68 f7 01 00 00       	push   $0x1f7
801026b7:	e8 c8 fe ff ff       	call   80102584 <inb>
801026bc:	83 c4 10             	add    $0x10,%esp
801026bf:	84 c0                	test   %al,%al
801026c1:	74 0c                	je     801026cf <ideinit+0x7c>
      havedisk1 = 1;
801026c3:	c7 05 78 26 11 80 01 	movl   $0x1,0x80112678
801026ca:	00 00 00 
      break;
801026cd:	eb 0d                	jmp    801026dc <ideinit+0x89>
  for(i=0; i<1000; i++){
801026cf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801026d3:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801026da:	7e d3                	jle    801026af <ideinit+0x5c>
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801026dc:	83 ec 08             	sub    $0x8,%esp
801026df:	68 e0 00 00 00       	push   $0xe0
801026e4:	68 f6 01 00 00       	push   $0x1f6
801026e9:	e8 d9 fe ff ff       	call   801025c7 <outb>
801026ee:	83 c4 10             	add    $0x10,%esp
}
801026f1:	90                   	nop
801026f2:	c9                   	leave  
801026f3:	c3                   	ret    

801026f4 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801026f4:	55                   	push   %ebp
801026f5:	89 e5                	mov    %esp,%ebp
801026f7:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801026fa:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026fe:	75 0d                	jne    8010270d <idestart+0x19>
    panic("idestart");
80102700:	83 ec 0c             	sub    $0xc,%esp
80102703:	68 77 87 10 80       	push   $0x80108777
80102708:	e8 a8 de ff ff       	call   801005b5 <panic>
  if(b->blockno >= FSSIZE)
8010270d:	8b 45 08             	mov    0x8(%ebp),%eax
80102710:	8b 40 08             	mov    0x8(%eax),%eax
80102713:	3d e7 03 00 00       	cmp    $0x3e7,%eax
80102718:	76 0d                	jbe    80102727 <idestart+0x33>
    panic("incorrect blockno");
8010271a:	83 ec 0c             	sub    $0xc,%esp
8010271d:	68 80 87 10 80       	push   $0x80108780
80102722:	e8 8e de ff ff       	call   801005b5 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102727:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
8010272e:	8b 45 08             	mov    0x8(%ebp),%eax
80102731:	8b 50 08             	mov    0x8(%eax),%edx
80102734:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102737:	0f af c2             	imul   %edx,%eax
8010273a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
8010273d:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102741:	75 07                	jne    8010274a <idestart+0x56>
80102743:	b8 20 00 00 00       	mov    $0x20,%eax
80102748:	eb 05                	jmp    8010274f <idestart+0x5b>
8010274a:	b8 c4 00 00 00       	mov    $0xc4,%eax
8010274f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
80102752:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102756:	75 07                	jne    8010275f <idestart+0x6b>
80102758:	b8 30 00 00 00       	mov    $0x30,%eax
8010275d:	eb 05                	jmp    80102764 <idestart+0x70>
8010275f:	b8 c5 00 00 00       	mov    $0xc5,%eax
80102764:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102767:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
8010276b:	7e 0d                	jle    8010277a <idestart+0x86>
8010276d:	83 ec 0c             	sub    $0xc,%esp
80102770:	68 77 87 10 80       	push   $0x80108777
80102775:	e8 3b de ff ff       	call   801005b5 <panic>

  idewait(0);
8010277a:	83 ec 0c             	sub    $0xc,%esp
8010277d:	6a 00                	push   $0x0
8010277f:	e8 8a fe ff ff       	call   8010260e <idewait>
80102784:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102787:	83 ec 08             	sub    $0x8,%esp
8010278a:	6a 00                	push   $0x0
8010278c:	68 f6 03 00 00       	push   $0x3f6
80102791:	e8 31 fe ff ff       	call   801025c7 <outb>
80102796:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102799:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010279c:	0f b6 c0             	movzbl %al,%eax
8010279f:	83 ec 08             	sub    $0x8,%esp
801027a2:	50                   	push   %eax
801027a3:	68 f2 01 00 00       	push   $0x1f2
801027a8:	e8 1a fe ff ff       	call   801025c7 <outb>
801027ad:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
801027b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027b3:	0f b6 c0             	movzbl %al,%eax
801027b6:	83 ec 08             	sub    $0x8,%esp
801027b9:	50                   	push   %eax
801027ba:	68 f3 01 00 00       	push   $0x1f3
801027bf:	e8 03 fe ff ff       	call   801025c7 <outb>
801027c4:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
801027c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027ca:	c1 f8 08             	sar    $0x8,%eax
801027cd:	0f b6 c0             	movzbl %al,%eax
801027d0:	83 ec 08             	sub    $0x8,%esp
801027d3:	50                   	push   %eax
801027d4:	68 f4 01 00 00       	push   $0x1f4
801027d9:	e8 e9 fd ff ff       	call   801025c7 <outb>
801027de:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
801027e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027e4:	c1 f8 10             	sar    $0x10,%eax
801027e7:	0f b6 c0             	movzbl %al,%eax
801027ea:	83 ec 08             	sub    $0x8,%esp
801027ed:	50                   	push   %eax
801027ee:	68 f5 01 00 00       	push   $0x1f5
801027f3:	e8 cf fd ff ff       	call   801025c7 <outb>
801027f8:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
801027fb:	8b 45 08             	mov    0x8(%ebp),%eax
801027fe:	8b 40 04             	mov    0x4(%eax),%eax
80102801:	c1 e0 04             	shl    $0x4,%eax
80102804:	83 e0 10             	and    $0x10,%eax
80102807:	89 c2                	mov    %eax,%edx
80102809:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010280c:	c1 f8 18             	sar    $0x18,%eax
8010280f:	83 e0 0f             	and    $0xf,%eax
80102812:	09 d0                	or     %edx,%eax
80102814:	83 c8 e0             	or     $0xffffffe0,%eax
80102817:	0f b6 c0             	movzbl %al,%eax
8010281a:	83 ec 08             	sub    $0x8,%esp
8010281d:	50                   	push   %eax
8010281e:	68 f6 01 00 00       	push   $0x1f6
80102823:	e8 9f fd ff ff       	call   801025c7 <outb>
80102828:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
8010282b:	8b 45 08             	mov    0x8(%ebp),%eax
8010282e:	8b 00                	mov    (%eax),%eax
80102830:	83 e0 04             	and    $0x4,%eax
80102833:	85 c0                	test   %eax,%eax
80102835:	74 35                	je     8010286c <idestart+0x178>
    outb(0x1f7, write_cmd);
80102837:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010283a:	0f b6 c0             	movzbl %al,%eax
8010283d:	83 ec 08             	sub    $0x8,%esp
80102840:	50                   	push   %eax
80102841:	68 f7 01 00 00       	push   $0x1f7
80102846:	e8 7c fd ff ff       	call   801025c7 <outb>
8010284b:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
8010284e:	8b 45 08             	mov    0x8(%ebp),%eax
80102851:	83 c0 5c             	add    $0x5c,%eax
80102854:	83 ec 04             	sub    $0x4,%esp
80102857:	68 80 00 00 00       	push   $0x80
8010285c:	50                   	push   %eax
8010285d:	68 f0 01 00 00       	push   $0x1f0
80102862:	e8 81 fd ff ff       	call   801025e8 <outsl>
80102867:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, read_cmd);
  }
}
8010286a:	eb 17                	jmp    80102883 <idestart+0x18f>
    outb(0x1f7, read_cmd);
8010286c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010286f:	0f b6 c0             	movzbl %al,%eax
80102872:	83 ec 08             	sub    $0x8,%esp
80102875:	50                   	push   %eax
80102876:	68 f7 01 00 00       	push   $0x1f7
8010287b:	e8 47 fd ff ff       	call   801025c7 <outb>
80102880:	83 c4 10             	add    $0x10,%esp
}
80102883:	90                   	nop
80102884:	c9                   	leave  
80102885:	c3                   	ret    

80102886 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102886:	55                   	push   %ebp
80102887:	89 e5                	mov    %esp,%ebp
80102889:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
8010288c:	83 ec 0c             	sub    $0xc,%esp
8010288f:	68 40 26 11 80       	push   $0x80112640
80102894:	e8 c6 28 00 00       	call   8010515f <acquire>
80102899:	83 c4 10             	add    $0x10,%esp

  if((b = idequeue) == 0){
8010289c:	a1 74 26 11 80       	mov    0x80112674,%eax
801028a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801028a4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801028a8:	75 15                	jne    801028bf <ideintr+0x39>
    release(&idelock);
801028aa:	83 ec 0c             	sub    $0xc,%esp
801028ad:	68 40 26 11 80       	push   $0x80112640
801028b2:	e8 16 29 00 00       	call   801051cd <release>
801028b7:	83 c4 10             	add    $0x10,%esp
    return;
801028ba:	e9 9a 00 00 00       	jmp    80102959 <ideintr+0xd3>
  }
  idequeue = b->qnext;
801028bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028c2:	8b 40 58             	mov    0x58(%eax),%eax
801028c5:	a3 74 26 11 80       	mov    %eax,0x80112674

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
801028ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028cd:	8b 00                	mov    (%eax),%eax
801028cf:	83 e0 04             	and    $0x4,%eax
801028d2:	85 c0                	test   %eax,%eax
801028d4:	75 2d                	jne    80102903 <ideintr+0x7d>
801028d6:	83 ec 0c             	sub    $0xc,%esp
801028d9:	6a 01                	push   $0x1
801028db:	e8 2e fd ff ff       	call   8010260e <idewait>
801028e0:	83 c4 10             	add    $0x10,%esp
801028e3:	85 c0                	test   %eax,%eax
801028e5:	78 1c                	js     80102903 <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
801028e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028ea:	83 c0 5c             	add    $0x5c,%eax
801028ed:	83 ec 04             	sub    $0x4,%esp
801028f0:	68 80 00 00 00       	push   $0x80
801028f5:	50                   	push   %eax
801028f6:	68 f0 01 00 00       	push   $0x1f0
801028fb:	e8 a1 fc ff ff       	call   801025a1 <insl>
80102900:	83 c4 10             	add    $0x10,%esp

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102903:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102906:	8b 00                	mov    (%eax),%eax
80102908:	83 c8 02             	or     $0x2,%eax
8010290b:	89 c2                	mov    %eax,%edx
8010290d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102910:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102912:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102915:	8b 00                	mov    (%eax),%eax
80102917:	83 e0 fb             	and    $0xfffffffb,%eax
8010291a:	89 c2                	mov    %eax,%edx
8010291c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010291f:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102921:	83 ec 0c             	sub    $0xc,%esp
80102924:	ff 75 f4             	push   -0xc(%ebp)
80102927:	e8 cd 23 00 00       	call   80104cf9 <wakeup>
8010292c:	83 c4 10             	add    $0x10,%esp

  // Start disk on next buf in queue.
  if(idequeue != 0)
8010292f:	a1 74 26 11 80       	mov    0x80112674,%eax
80102934:	85 c0                	test   %eax,%eax
80102936:	74 11                	je     80102949 <ideintr+0xc3>
    idestart(idequeue);
80102938:	a1 74 26 11 80       	mov    0x80112674,%eax
8010293d:	83 ec 0c             	sub    $0xc,%esp
80102940:	50                   	push   %eax
80102941:	e8 ae fd ff ff       	call   801026f4 <idestart>
80102946:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
80102949:	83 ec 0c             	sub    $0xc,%esp
8010294c:	68 40 26 11 80       	push   $0x80112640
80102951:	e8 77 28 00 00       	call   801051cd <release>
80102956:	83 c4 10             	add    $0x10,%esp
}
80102959:	c9                   	leave  
8010295a:	c3                   	ret    

8010295b <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010295b:	55                   	push   %ebp
8010295c:	89 e5                	mov    %esp,%ebp
8010295e:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80102961:	8b 45 08             	mov    0x8(%ebp),%eax
80102964:	83 c0 0c             	add    $0xc,%eax
80102967:	83 ec 0c             	sub    $0xc,%esp
8010296a:	50                   	push   %eax
8010296b:	e8 38 27 00 00       	call   801050a8 <holdingsleep>
80102970:	83 c4 10             	add    $0x10,%esp
80102973:	85 c0                	test   %eax,%eax
80102975:	75 0d                	jne    80102984 <iderw+0x29>
    panic("iderw: buf not locked");
80102977:	83 ec 0c             	sub    $0xc,%esp
8010297a:	68 92 87 10 80       	push   $0x80108792
8010297f:	e8 31 dc ff ff       	call   801005b5 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102984:	8b 45 08             	mov    0x8(%ebp),%eax
80102987:	8b 00                	mov    (%eax),%eax
80102989:	83 e0 06             	and    $0x6,%eax
8010298c:	83 f8 02             	cmp    $0x2,%eax
8010298f:	75 0d                	jne    8010299e <iderw+0x43>
    panic("iderw: nothing to do");
80102991:	83 ec 0c             	sub    $0xc,%esp
80102994:	68 a8 87 10 80       	push   $0x801087a8
80102999:	e8 17 dc ff ff       	call   801005b5 <panic>
  if(b->dev != 0 && !havedisk1)
8010299e:	8b 45 08             	mov    0x8(%ebp),%eax
801029a1:	8b 40 04             	mov    0x4(%eax),%eax
801029a4:	85 c0                	test   %eax,%eax
801029a6:	74 16                	je     801029be <iderw+0x63>
801029a8:	a1 78 26 11 80       	mov    0x80112678,%eax
801029ad:	85 c0                	test   %eax,%eax
801029af:	75 0d                	jne    801029be <iderw+0x63>
    panic("iderw: ide disk 1 not present");
801029b1:	83 ec 0c             	sub    $0xc,%esp
801029b4:	68 bd 87 10 80       	push   $0x801087bd
801029b9:	e8 f7 db ff ff       	call   801005b5 <panic>

  acquire(&idelock);  //DOC:acquire-lock
801029be:	83 ec 0c             	sub    $0xc,%esp
801029c1:	68 40 26 11 80       	push   $0x80112640
801029c6:	e8 94 27 00 00       	call   8010515f <acquire>
801029cb:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
801029ce:	8b 45 08             	mov    0x8(%ebp),%eax
801029d1:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801029d8:	c7 45 f4 74 26 11 80 	movl   $0x80112674,-0xc(%ebp)
801029df:	eb 0b                	jmp    801029ec <iderw+0x91>
801029e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029e4:	8b 00                	mov    (%eax),%eax
801029e6:	83 c0 58             	add    $0x58,%eax
801029e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801029ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029ef:	8b 00                	mov    (%eax),%eax
801029f1:	85 c0                	test   %eax,%eax
801029f3:	75 ec                	jne    801029e1 <iderw+0x86>
    ;
  *pp = b;
801029f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029f8:	8b 55 08             	mov    0x8(%ebp),%edx
801029fb:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
801029fd:	a1 74 26 11 80       	mov    0x80112674,%eax
80102a02:	39 45 08             	cmp    %eax,0x8(%ebp)
80102a05:	75 23                	jne    80102a2a <iderw+0xcf>
    idestart(b);
80102a07:	83 ec 0c             	sub    $0xc,%esp
80102a0a:	ff 75 08             	push   0x8(%ebp)
80102a0d:	e8 e2 fc ff ff       	call   801026f4 <idestart>
80102a12:	83 c4 10             	add    $0x10,%esp

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a15:	eb 13                	jmp    80102a2a <iderw+0xcf>
    sleep(b, &idelock);
80102a17:	83 ec 08             	sub    $0x8,%esp
80102a1a:	68 40 26 11 80       	push   $0x80112640
80102a1f:	ff 75 08             	push   0x8(%ebp)
80102a22:	e8 e8 21 00 00       	call   80104c0f <sleep>
80102a27:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a2a:	8b 45 08             	mov    0x8(%ebp),%eax
80102a2d:	8b 00                	mov    (%eax),%eax
80102a2f:	83 e0 06             	and    $0x6,%eax
80102a32:	83 f8 02             	cmp    $0x2,%eax
80102a35:	75 e0                	jne    80102a17 <iderw+0xbc>
  }


  release(&idelock);
80102a37:	83 ec 0c             	sub    $0xc,%esp
80102a3a:	68 40 26 11 80       	push   $0x80112640
80102a3f:	e8 89 27 00 00       	call   801051cd <release>
80102a44:	83 c4 10             	add    $0x10,%esp
}
80102a47:	90                   	nop
80102a48:	c9                   	leave  
80102a49:	c3                   	ret    

80102a4a <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102a4a:	55                   	push   %ebp
80102a4b:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a4d:	a1 7c 26 11 80       	mov    0x8011267c,%eax
80102a52:	8b 55 08             	mov    0x8(%ebp),%edx
80102a55:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102a57:	a1 7c 26 11 80       	mov    0x8011267c,%eax
80102a5c:	8b 40 10             	mov    0x10(%eax),%eax
}
80102a5f:	5d                   	pop    %ebp
80102a60:	c3                   	ret    

80102a61 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102a61:	55                   	push   %ebp
80102a62:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a64:	a1 7c 26 11 80       	mov    0x8011267c,%eax
80102a69:	8b 55 08             	mov    0x8(%ebp),%edx
80102a6c:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102a6e:	a1 7c 26 11 80       	mov    0x8011267c,%eax
80102a73:	8b 55 0c             	mov    0xc(%ebp),%edx
80102a76:	89 50 10             	mov    %edx,0x10(%eax)
}
80102a79:	90                   	nop
80102a7a:	5d                   	pop    %ebp
80102a7b:	c3                   	ret    

80102a7c <ioapicinit>:

void
ioapicinit(void)
{
80102a7c:	55                   	push   %ebp
80102a7d:	89 e5                	mov    %esp,%ebp
80102a7f:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102a82:	c7 05 7c 26 11 80 00 	movl   $0xfec00000,0x8011267c
80102a89:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102a8c:	6a 01                	push   $0x1
80102a8e:	e8 b7 ff ff ff       	call   80102a4a <ioapicread>
80102a93:	83 c4 04             	add    $0x4,%esp
80102a96:	c1 e8 10             	shr    $0x10,%eax
80102a99:	25 ff 00 00 00       	and    $0xff,%eax
80102a9e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102aa1:	6a 00                	push   $0x0
80102aa3:	e8 a2 ff ff ff       	call   80102a4a <ioapicread>
80102aa8:	83 c4 04             	add    $0x4,%esp
80102aab:	c1 e8 18             	shr    $0x18,%eax
80102aae:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102ab1:	0f b6 05 44 2d 11 80 	movzbl 0x80112d44,%eax
80102ab8:	0f b6 c0             	movzbl %al,%eax
80102abb:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80102abe:	74 10                	je     80102ad0 <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102ac0:	83 ec 0c             	sub    $0xc,%esp
80102ac3:	68 dc 87 10 80       	push   $0x801087dc
80102ac8:	e8 33 d9 ff ff       	call   80100400 <cprintf>
80102acd:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102ad0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102ad7:	eb 3f                	jmp    80102b18 <ioapicinit+0x9c>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102adc:	83 c0 20             	add    $0x20,%eax
80102adf:	0d 00 00 01 00       	or     $0x10000,%eax
80102ae4:	89 c2                	mov    %eax,%edx
80102ae6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ae9:	83 c0 08             	add    $0x8,%eax
80102aec:	01 c0                	add    %eax,%eax
80102aee:	83 ec 08             	sub    $0x8,%esp
80102af1:	52                   	push   %edx
80102af2:	50                   	push   %eax
80102af3:	e8 69 ff ff ff       	call   80102a61 <ioapicwrite>
80102af8:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102afb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102afe:	83 c0 08             	add    $0x8,%eax
80102b01:	01 c0                	add    %eax,%eax
80102b03:	83 c0 01             	add    $0x1,%eax
80102b06:	83 ec 08             	sub    $0x8,%esp
80102b09:	6a 00                	push   $0x0
80102b0b:	50                   	push   %eax
80102b0c:	e8 50 ff ff ff       	call   80102a61 <ioapicwrite>
80102b11:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102b14:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102b18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b1b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102b1e:	7e b9                	jle    80102ad9 <ioapicinit+0x5d>
  }
}
80102b20:	90                   	nop
80102b21:	90                   	nop
80102b22:	c9                   	leave  
80102b23:	c3                   	ret    

80102b24 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102b24:	55                   	push   %ebp
80102b25:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102b27:	8b 45 08             	mov    0x8(%ebp),%eax
80102b2a:	83 c0 20             	add    $0x20,%eax
80102b2d:	89 c2                	mov    %eax,%edx
80102b2f:	8b 45 08             	mov    0x8(%ebp),%eax
80102b32:	83 c0 08             	add    $0x8,%eax
80102b35:	01 c0                	add    %eax,%eax
80102b37:	52                   	push   %edx
80102b38:	50                   	push   %eax
80102b39:	e8 23 ff ff ff       	call   80102a61 <ioapicwrite>
80102b3e:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102b41:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b44:	c1 e0 18             	shl    $0x18,%eax
80102b47:	89 c2                	mov    %eax,%edx
80102b49:	8b 45 08             	mov    0x8(%ebp),%eax
80102b4c:	83 c0 08             	add    $0x8,%eax
80102b4f:	01 c0                	add    %eax,%eax
80102b51:	83 c0 01             	add    $0x1,%eax
80102b54:	52                   	push   %edx
80102b55:	50                   	push   %eax
80102b56:	e8 06 ff ff ff       	call   80102a61 <ioapicwrite>
80102b5b:	83 c4 08             	add    $0x8,%esp
}
80102b5e:	90                   	nop
80102b5f:	c9                   	leave  
80102b60:	c3                   	ret    

80102b61 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102b61:	55                   	push   %ebp
80102b62:	89 e5                	mov    %esp,%ebp
80102b64:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102b67:	83 ec 08             	sub    $0x8,%esp
80102b6a:	68 0e 88 10 80       	push   $0x8010880e
80102b6f:	68 80 26 11 80       	push   $0x80112680
80102b74:	e8 c4 25 00 00       	call   8010513d <initlock>
80102b79:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102b7c:	c7 05 b4 26 11 80 00 	movl   $0x0,0x801126b4
80102b83:	00 00 00 
  freerange(vstart, vend);
80102b86:	83 ec 08             	sub    $0x8,%esp
80102b89:	ff 75 0c             	push   0xc(%ebp)
80102b8c:	ff 75 08             	push   0x8(%ebp)
80102b8f:	e8 2a 00 00 00       	call   80102bbe <freerange>
80102b94:	83 c4 10             	add    $0x10,%esp
}
80102b97:	90                   	nop
80102b98:	c9                   	leave  
80102b99:	c3                   	ret    

80102b9a <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102b9a:	55                   	push   %ebp
80102b9b:	89 e5                	mov    %esp,%ebp
80102b9d:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102ba0:	83 ec 08             	sub    $0x8,%esp
80102ba3:	ff 75 0c             	push   0xc(%ebp)
80102ba6:	ff 75 08             	push   0x8(%ebp)
80102ba9:	e8 10 00 00 00       	call   80102bbe <freerange>
80102bae:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102bb1:	c7 05 b4 26 11 80 01 	movl   $0x1,0x801126b4
80102bb8:	00 00 00 
}
80102bbb:	90                   	nop
80102bbc:	c9                   	leave  
80102bbd:	c3                   	ret    

80102bbe <freerange>:

void
freerange(void *vstart, void *vend)
{
80102bbe:	55                   	push   %ebp
80102bbf:	89 e5                	mov    %esp,%ebp
80102bc1:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102bc4:	8b 45 08             	mov    0x8(%ebp),%eax
80102bc7:	05 ff 0f 00 00       	add    $0xfff,%eax
80102bcc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102bd1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102bd4:	eb 15                	jmp    80102beb <freerange+0x2d>
    kfree(p);
80102bd6:	83 ec 0c             	sub    $0xc,%esp
80102bd9:	ff 75 f4             	push   -0xc(%ebp)
80102bdc:	e8 1b 00 00 00       	call   80102bfc <kfree>
80102be1:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102be4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102beb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bee:	05 00 10 00 00       	add    $0x1000,%eax
80102bf3:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102bf6:	73 de                	jae    80102bd6 <freerange+0x18>
}
80102bf8:	90                   	nop
80102bf9:	90                   	nop
80102bfa:	c9                   	leave  
80102bfb:	c3                   	ret    

80102bfc <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102bfc:	55                   	push   %ebp
80102bfd:	89 e5                	mov    %esp,%ebp
80102bff:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102c02:	8b 45 08             	mov    0x8(%ebp),%eax
80102c05:	25 ff 0f 00 00       	and    $0xfff,%eax
80102c0a:	85 c0                	test   %eax,%eax
80102c0c:	75 18                	jne    80102c26 <kfree+0x2a>
80102c0e:	81 7d 08 e0 69 11 80 	cmpl   $0x801169e0,0x8(%ebp)
80102c15:	72 0f                	jb     80102c26 <kfree+0x2a>
80102c17:	8b 45 08             	mov    0x8(%ebp),%eax
80102c1a:	05 00 00 00 80       	add    $0x80000000,%eax
80102c1f:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102c24:	76 0d                	jbe    80102c33 <kfree+0x37>
    panic("kfree");
80102c26:	83 ec 0c             	sub    $0xc,%esp
80102c29:	68 13 88 10 80       	push   $0x80108813
80102c2e:	e8 82 d9 ff ff       	call   801005b5 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102c33:	83 ec 04             	sub    $0x4,%esp
80102c36:	68 00 10 00 00       	push   $0x1000
80102c3b:	6a 01                	push   $0x1
80102c3d:	ff 75 08             	push   0x8(%ebp)
80102c40:	e8 a0 27 00 00       	call   801053e5 <memset>
80102c45:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102c48:	a1 b4 26 11 80       	mov    0x801126b4,%eax
80102c4d:	85 c0                	test   %eax,%eax
80102c4f:	74 10                	je     80102c61 <kfree+0x65>
    acquire(&kmem.lock);
80102c51:	83 ec 0c             	sub    $0xc,%esp
80102c54:	68 80 26 11 80       	push   $0x80112680
80102c59:	e8 01 25 00 00       	call   8010515f <acquire>
80102c5e:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102c61:	8b 45 08             	mov    0x8(%ebp),%eax
80102c64:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102c67:	8b 15 b8 26 11 80    	mov    0x801126b8,%edx
80102c6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c70:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102c72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c75:	a3 b8 26 11 80       	mov    %eax,0x801126b8
  if(kmem.use_lock)
80102c7a:	a1 b4 26 11 80       	mov    0x801126b4,%eax
80102c7f:	85 c0                	test   %eax,%eax
80102c81:	74 10                	je     80102c93 <kfree+0x97>
    release(&kmem.lock);
80102c83:	83 ec 0c             	sub    $0xc,%esp
80102c86:	68 80 26 11 80       	push   $0x80112680
80102c8b:	e8 3d 25 00 00       	call   801051cd <release>
80102c90:	83 c4 10             	add    $0x10,%esp
}
80102c93:	90                   	nop
80102c94:	c9                   	leave  
80102c95:	c3                   	ret    

80102c96 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102c96:	55                   	push   %ebp
80102c97:	89 e5                	mov    %esp,%ebp
80102c99:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102c9c:	a1 b4 26 11 80       	mov    0x801126b4,%eax
80102ca1:	85 c0                	test   %eax,%eax
80102ca3:	74 10                	je     80102cb5 <kalloc+0x1f>
    acquire(&kmem.lock);
80102ca5:	83 ec 0c             	sub    $0xc,%esp
80102ca8:	68 80 26 11 80       	push   $0x80112680
80102cad:	e8 ad 24 00 00       	call   8010515f <acquire>
80102cb2:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102cb5:	a1 b8 26 11 80       	mov    0x801126b8,%eax
80102cba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102cbd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102cc1:	74 0a                	je     80102ccd <kalloc+0x37>
    kmem.freelist = r->next;
80102cc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cc6:	8b 00                	mov    (%eax),%eax
80102cc8:	a3 b8 26 11 80       	mov    %eax,0x801126b8
  if(kmem.use_lock)
80102ccd:	a1 b4 26 11 80       	mov    0x801126b4,%eax
80102cd2:	85 c0                	test   %eax,%eax
80102cd4:	74 10                	je     80102ce6 <kalloc+0x50>
    release(&kmem.lock);
80102cd6:	83 ec 0c             	sub    $0xc,%esp
80102cd9:	68 80 26 11 80       	push   $0x80112680
80102cde:	e8 ea 24 00 00       	call   801051cd <release>
80102ce3:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102ce6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102ce9:	c9                   	leave  
80102cea:	c3                   	ret    

80102ceb <inb>:
{
80102ceb:	55                   	push   %ebp
80102cec:	89 e5                	mov    %esp,%ebp
80102cee:	83 ec 14             	sub    $0x14,%esp
80102cf1:	8b 45 08             	mov    0x8(%ebp),%eax
80102cf4:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102cf8:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102cfc:	89 c2                	mov    %eax,%edx
80102cfe:	ec                   	in     (%dx),%al
80102cff:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102d02:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102d06:	c9                   	leave  
80102d07:	c3                   	ret    

80102d08 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102d08:	55                   	push   %ebp
80102d09:	89 e5                	mov    %esp,%ebp
80102d0b:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102d0e:	6a 64                	push   $0x64
80102d10:	e8 d6 ff ff ff       	call   80102ceb <inb>
80102d15:	83 c4 04             	add    $0x4,%esp
80102d18:	0f b6 c0             	movzbl %al,%eax
80102d1b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102d1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d21:	83 e0 01             	and    $0x1,%eax
80102d24:	85 c0                	test   %eax,%eax
80102d26:	75 0a                	jne    80102d32 <kbdgetc+0x2a>
    return -1;
80102d28:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d2d:	e9 23 01 00 00       	jmp    80102e55 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102d32:	6a 60                	push   $0x60
80102d34:	e8 b2 ff ff ff       	call   80102ceb <inb>
80102d39:	83 c4 04             	add    $0x4,%esp
80102d3c:	0f b6 c0             	movzbl %al,%eax
80102d3f:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102d42:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102d49:	75 17                	jne    80102d62 <kbdgetc+0x5a>
    shift |= E0ESC;
80102d4b:	a1 bc 26 11 80       	mov    0x801126bc,%eax
80102d50:	83 c8 40             	or     $0x40,%eax
80102d53:	a3 bc 26 11 80       	mov    %eax,0x801126bc
    return 0;
80102d58:	b8 00 00 00 00       	mov    $0x0,%eax
80102d5d:	e9 f3 00 00 00       	jmp    80102e55 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102d62:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d65:	25 80 00 00 00       	and    $0x80,%eax
80102d6a:	85 c0                	test   %eax,%eax
80102d6c:	74 45                	je     80102db3 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102d6e:	a1 bc 26 11 80       	mov    0x801126bc,%eax
80102d73:	83 e0 40             	and    $0x40,%eax
80102d76:	85 c0                	test   %eax,%eax
80102d78:	75 08                	jne    80102d82 <kbdgetc+0x7a>
80102d7a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d7d:	83 e0 7f             	and    $0x7f,%eax
80102d80:	eb 03                	jmp    80102d85 <kbdgetc+0x7d>
80102d82:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d85:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102d88:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d8b:	05 20 90 10 80       	add    $0x80109020,%eax
80102d90:	0f b6 00             	movzbl (%eax),%eax
80102d93:	83 c8 40             	or     $0x40,%eax
80102d96:	0f b6 c0             	movzbl %al,%eax
80102d99:	f7 d0                	not    %eax
80102d9b:	89 c2                	mov    %eax,%edx
80102d9d:	a1 bc 26 11 80       	mov    0x801126bc,%eax
80102da2:	21 d0                	and    %edx,%eax
80102da4:	a3 bc 26 11 80       	mov    %eax,0x801126bc
    return 0;
80102da9:	b8 00 00 00 00       	mov    $0x0,%eax
80102dae:	e9 a2 00 00 00       	jmp    80102e55 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102db3:	a1 bc 26 11 80       	mov    0x801126bc,%eax
80102db8:	83 e0 40             	and    $0x40,%eax
80102dbb:	85 c0                	test   %eax,%eax
80102dbd:	74 14                	je     80102dd3 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102dbf:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102dc6:	a1 bc 26 11 80       	mov    0x801126bc,%eax
80102dcb:	83 e0 bf             	and    $0xffffffbf,%eax
80102dce:	a3 bc 26 11 80       	mov    %eax,0x801126bc
  }

  shift |= shiftcode[data];
80102dd3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dd6:	05 20 90 10 80       	add    $0x80109020,%eax
80102ddb:	0f b6 00             	movzbl (%eax),%eax
80102dde:	0f b6 d0             	movzbl %al,%edx
80102de1:	a1 bc 26 11 80       	mov    0x801126bc,%eax
80102de6:	09 d0                	or     %edx,%eax
80102de8:	a3 bc 26 11 80       	mov    %eax,0x801126bc
  shift ^= togglecode[data];
80102ded:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102df0:	05 20 91 10 80       	add    $0x80109120,%eax
80102df5:	0f b6 00             	movzbl (%eax),%eax
80102df8:	0f b6 d0             	movzbl %al,%edx
80102dfb:	a1 bc 26 11 80       	mov    0x801126bc,%eax
80102e00:	31 d0                	xor    %edx,%eax
80102e02:	a3 bc 26 11 80       	mov    %eax,0x801126bc
  c = charcode[shift & (CTL | SHIFT)][data];
80102e07:	a1 bc 26 11 80       	mov    0x801126bc,%eax
80102e0c:	83 e0 03             	and    $0x3,%eax
80102e0f:	8b 14 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%edx
80102e16:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e19:	01 d0                	add    %edx,%eax
80102e1b:	0f b6 00             	movzbl (%eax),%eax
80102e1e:	0f b6 c0             	movzbl %al,%eax
80102e21:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102e24:	a1 bc 26 11 80       	mov    0x801126bc,%eax
80102e29:	83 e0 08             	and    $0x8,%eax
80102e2c:	85 c0                	test   %eax,%eax
80102e2e:	74 22                	je     80102e52 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102e30:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102e34:	76 0c                	jbe    80102e42 <kbdgetc+0x13a>
80102e36:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102e3a:	77 06                	ja     80102e42 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102e3c:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102e40:	eb 10                	jmp    80102e52 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102e42:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102e46:	76 0a                	jbe    80102e52 <kbdgetc+0x14a>
80102e48:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102e4c:	77 04                	ja     80102e52 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102e4e:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102e52:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102e55:	c9                   	leave  
80102e56:	c3                   	ret    

80102e57 <kbdintr>:

void
kbdintr(void)
{
80102e57:	55                   	push   %ebp
80102e58:	89 e5                	mov    %esp,%ebp
80102e5a:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102e5d:	83 ec 0c             	sub    $0xc,%esp
80102e60:	68 08 2d 10 80       	push   $0x80102d08
80102e65:	e8 e5 d9 ff ff       	call   8010084f <consoleintr>
80102e6a:	83 c4 10             	add    $0x10,%esp
}
80102e6d:	90                   	nop
80102e6e:	c9                   	leave  
80102e6f:	c3                   	ret    

80102e70 <inb>:
{
80102e70:	55                   	push   %ebp
80102e71:	89 e5                	mov    %esp,%ebp
80102e73:	83 ec 14             	sub    $0x14,%esp
80102e76:	8b 45 08             	mov    0x8(%ebp),%eax
80102e79:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e7d:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102e81:	89 c2                	mov    %eax,%edx
80102e83:	ec                   	in     (%dx),%al
80102e84:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102e87:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102e8b:	c9                   	leave  
80102e8c:	c3                   	ret    

80102e8d <outb>:
{
80102e8d:	55                   	push   %ebp
80102e8e:	89 e5                	mov    %esp,%ebp
80102e90:	83 ec 08             	sub    $0x8,%esp
80102e93:	8b 45 08             	mov    0x8(%ebp),%eax
80102e96:	8b 55 0c             	mov    0xc(%ebp),%edx
80102e99:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102e9d:	89 d0                	mov    %edx,%eax
80102e9f:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102ea2:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102ea6:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102eaa:	ee                   	out    %al,(%dx)
}
80102eab:	90                   	nop
80102eac:	c9                   	leave  
80102ead:	c3                   	ret    

80102eae <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102eae:	55                   	push   %ebp
80102eaf:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102eb1:	8b 15 c0 26 11 80    	mov    0x801126c0,%edx
80102eb7:	8b 45 08             	mov    0x8(%ebp),%eax
80102eba:	c1 e0 02             	shl    $0x2,%eax
80102ebd:	01 c2                	add    %eax,%edx
80102ebf:	8b 45 0c             	mov    0xc(%ebp),%eax
80102ec2:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102ec4:	a1 c0 26 11 80       	mov    0x801126c0,%eax
80102ec9:	83 c0 20             	add    $0x20,%eax
80102ecc:	8b 00                	mov    (%eax),%eax
}
80102ece:	90                   	nop
80102ecf:	5d                   	pop    %ebp
80102ed0:	c3                   	ret    

80102ed1 <lapicinit>:

void
lapicinit(void)
{
80102ed1:	55                   	push   %ebp
80102ed2:	89 e5                	mov    %esp,%ebp
  if(!lapic)
80102ed4:	a1 c0 26 11 80       	mov    0x801126c0,%eax
80102ed9:	85 c0                	test   %eax,%eax
80102edb:	0f 84 0c 01 00 00    	je     80102fed <lapicinit+0x11c>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102ee1:	68 3f 01 00 00       	push   $0x13f
80102ee6:	6a 3c                	push   $0x3c
80102ee8:	e8 c1 ff ff ff       	call   80102eae <lapicw>
80102eed:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102ef0:	6a 0b                	push   $0xb
80102ef2:	68 f8 00 00 00       	push   $0xf8
80102ef7:	e8 b2 ff ff ff       	call   80102eae <lapicw>
80102efc:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102eff:	68 20 00 02 00       	push   $0x20020
80102f04:	68 c8 00 00 00       	push   $0xc8
80102f09:	e8 a0 ff ff ff       	call   80102eae <lapicw>
80102f0e:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102f11:	68 80 96 98 00       	push   $0x989680
80102f16:	68 e0 00 00 00       	push   $0xe0
80102f1b:	e8 8e ff ff ff       	call   80102eae <lapicw>
80102f20:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102f23:	68 00 00 01 00       	push   $0x10000
80102f28:	68 d4 00 00 00       	push   $0xd4
80102f2d:	e8 7c ff ff ff       	call   80102eae <lapicw>
80102f32:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102f35:	68 00 00 01 00       	push   $0x10000
80102f3a:	68 d8 00 00 00       	push   $0xd8
80102f3f:	e8 6a ff ff ff       	call   80102eae <lapicw>
80102f44:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102f47:	a1 c0 26 11 80       	mov    0x801126c0,%eax
80102f4c:	83 c0 30             	add    $0x30,%eax
80102f4f:	8b 00                	mov    (%eax),%eax
80102f51:	c1 e8 10             	shr    $0x10,%eax
80102f54:	25 fc 00 00 00       	and    $0xfc,%eax
80102f59:	85 c0                	test   %eax,%eax
80102f5b:	74 12                	je     80102f6f <lapicinit+0x9e>
    lapicw(PCINT, MASKED);
80102f5d:	68 00 00 01 00       	push   $0x10000
80102f62:	68 d0 00 00 00       	push   $0xd0
80102f67:	e8 42 ff ff ff       	call   80102eae <lapicw>
80102f6c:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102f6f:	6a 33                	push   $0x33
80102f71:	68 dc 00 00 00       	push   $0xdc
80102f76:	e8 33 ff ff ff       	call   80102eae <lapicw>
80102f7b:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102f7e:	6a 00                	push   $0x0
80102f80:	68 a0 00 00 00       	push   $0xa0
80102f85:	e8 24 ff ff ff       	call   80102eae <lapicw>
80102f8a:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102f8d:	6a 00                	push   $0x0
80102f8f:	68 a0 00 00 00       	push   $0xa0
80102f94:	e8 15 ff ff ff       	call   80102eae <lapicw>
80102f99:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102f9c:	6a 00                	push   $0x0
80102f9e:	6a 2c                	push   $0x2c
80102fa0:	e8 09 ff ff ff       	call   80102eae <lapicw>
80102fa5:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102fa8:	6a 00                	push   $0x0
80102faa:	68 c4 00 00 00       	push   $0xc4
80102faf:	e8 fa fe ff ff       	call   80102eae <lapicw>
80102fb4:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102fb7:	68 00 85 08 00       	push   $0x88500
80102fbc:	68 c0 00 00 00       	push   $0xc0
80102fc1:	e8 e8 fe ff ff       	call   80102eae <lapicw>
80102fc6:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102fc9:	90                   	nop
80102fca:	a1 c0 26 11 80       	mov    0x801126c0,%eax
80102fcf:	05 00 03 00 00       	add    $0x300,%eax
80102fd4:	8b 00                	mov    (%eax),%eax
80102fd6:	25 00 10 00 00       	and    $0x1000,%eax
80102fdb:	85 c0                	test   %eax,%eax
80102fdd:	75 eb                	jne    80102fca <lapicinit+0xf9>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102fdf:	6a 00                	push   $0x0
80102fe1:	6a 20                	push   $0x20
80102fe3:	e8 c6 fe ff ff       	call   80102eae <lapicw>
80102fe8:	83 c4 08             	add    $0x8,%esp
80102feb:	eb 01                	jmp    80102fee <lapicinit+0x11d>
    return;
80102fed:	90                   	nop
}
80102fee:	c9                   	leave  
80102fef:	c3                   	ret    

80102ff0 <lapicid>:

int
lapicid(void)
{
80102ff0:	55                   	push   %ebp
80102ff1:	89 e5                	mov    %esp,%ebp
  if (!lapic)
80102ff3:	a1 c0 26 11 80       	mov    0x801126c0,%eax
80102ff8:	85 c0                	test   %eax,%eax
80102ffa:	75 07                	jne    80103003 <lapicid+0x13>
    return 0;
80102ffc:	b8 00 00 00 00       	mov    $0x0,%eax
80103001:	eb 0d                	jmp    80103010 <lapicid+0x20>
  return lapic[ID] >> 24;
80103003:	a1 c0 26 11 80       	mov    0x801126c0,%eax
80103008:	83 c0 20             	add    $0x20,%eax
8010300b:	8b 00                	mov    (%eax),%eax
8010300d:	c1 e8 18             	shr    $0x18,%eax
}
80103010:	5d                   	pop    %ebp
80103011:	c3                   	ret    

80103012 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103012:	55                   	push   %ebp
80103013:	89 e5                	mov    %esp,%ebp
  if(lapic)
80103015:	a1 c0 26 11 80       	mov    0x801126c0,%eax
8010301a:	85 c0                	test   %eax,%eax
8010301c:	74 0c                	je     8010302a <lapiceoi+0x18>
    lapicw(EOI, 0);
8010301e:	6a 00                	push   $0x0
80103020:	6a 2c                	push   $0x2c
80103022:	e8 87 fe ff ff       	call   80102eae <lapicw>
80103027:	83 c4 08             	add    $0x8,%esp
}
8010302a:	90                   	nop
8010302b:	c9                   	leave  
8010302c:	c3                   	ret    

8010302d <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
8010302d:	55                   	push   %ebp
8010302e:	89 e5                	mov    %esp,%ebp
}
80103030:	90                   	nop
80103031:	5d                   	pop    %ebp
80103032:	c3                   	ret    

80103033 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103033:	55                   	push   %ebp
80103034:	89 e5                	mov    %esp,%ebp
80103036:	83 ec 14             	sub    $0x14,%esp
80103039:	8b 45 08             	mov    0x8(%ebp),%eax
8010303c:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
8010303f:	6a 0f                	push   $0xf
80103041:	6a 70                	push   $0x70
80103043:	e8 45 fe ff ff       	call   80102e8d <outb>
80103048:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
8010304b:	6a 0a                	push   $0xa
8010304d:	6a 71                	push   $0x71
8010304f:	e8 39 fe ff ff       	call   80102e8d <outb>
80103054:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103057:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
8010305e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103061:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103066:	8b 45 0c             	mov    0xc(%ebp),%eax
80103069:	c1 e8 04             	shr    $0x4,%eax
8010306c:	89 c2                	mov    %eax,%edx
8010306e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103071:	83 c0 02             	add    $0x2,%eax
80103074:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103077:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010307b:	c1 e0 18             	shl    $0x18,%eax
8010307e:	50                   	push   %eax
8010307f:	68 c4 00 00 00       	push   $0xc4
80103084:	e8 25 fe ff ff       	call   80102eae <lapicw>
80103089:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010308c:	68 00 c5 00 00       	push   $0xc500
80103091:	68 c0 00 00 00       	push   $0xc0
80103096:	e8 13 fe ff ff       	call   80102eae <lapicw>
8010309b:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
8010309e:	68 c8 00 00 00       	push   $0xc8
801030a3:	e8 85 ff ff ff       	call   8010302d <microdelay>
801030a8:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
801030ab:	68 00 85 00 00       	push   $0x8500
801030b0:	68 c0 00 00 00       	push   $0xc0
801030b5:	e8 f4 fd ff ff       	call   80102eae <lapicw>
801030ba:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801030bd:	6a 64                	push   $0x64
801030bf:	e8 69 ff ff ff       	call   8010302d <microdelay>
801030c4:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801030c7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801030ce:	eb 3d                	jmp    8010310d <lapicstartap+0xda>
    lapicw(ICRHI, apicid<<24);
801030d0:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801030d4:	c1 e0 18             	shl    $0x18,%eax
801030d7:	50                   	push   %eax
801030d8:	68 c4 00 00 00       	push   $0xc4
801030dd:	e8 cc fd ff ff       	call   80102eae <lapicw>
801030e2:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
801030e5:	8b 45 0c             	mov    0xc(%ebp),%eax
801030e8:	c1 e8 0c             	shr    $0xc,%eax
801030eb:	80 cc 06             	or     $0x6,%ah
801030ee:	50                   	push   %eax
801030ef:	68 c0 00 00 00       	push   $0xc0
801030f4:	e8 b5 fd ff ff       	call   80102eae <lapicw>
801030f9:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
801030fc:	68 c8 00 00 00       	push   $0xc8
80103101:	e8 27 ff ff ff       	call   8010302d <microdelay>
80103106:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80103109:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010310d:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103111:	7e bd                	jle    801030d0 <lapicstartap+0x9d>
  }
}
80103113:	90                   	nop
80103114:	90                   	nop
80103115:	c9                   	leave  
80103116:	c3                   	ret    

80103117 <cmos_read>:
#define MONTH   0x08
#define YEAR    0x09

static uint
cmos_read(uint reg)
{
80103117:	55                   	push   %ebp
80103118:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
8010311a:	8b 45 08             	mov    0x8(%ebp),%eax
8010311d:	0f b6 c0             	movzbl %al,%eax
80103120:	50                   	push   %eax
80103121:	6a 70                	push   $0x70
80103123:	e8 65 fd ff ff       	call   80102e8d <outb>
80103128:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
8010312b:	68 c8 00 00 00       	push   $0xc8
80103130:	e8 f8 fe ff ff       	call   8010302d <microdelay>
80103135:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80103138:	6a 71                	push   $0x71
8010313a:	e8 31 fd ff ff       	call   80102e70 <inb>
8010313f:	83 c4 04             	add    $0x4,%esp
80103142:	0f b6 c0             	movzbl %al,%eax
}
80103145:	c9                   	leave  
80103146:	c3                   	ret    

80103147 <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
80103147:	55                   	push   %ebp
80103148:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
8010314a:	6a 00                	push   $0x0
8010314c:	e8 c6 ff ff ff       	call   80103117 <cmos_read>
80103151:	83 c4 04             	add    $0x4,%esp
80103154:	8b 55 08             	mov    0x8(%ebp),%edx
80103157:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80103159:	6a 02                	push   $0x2
8010315b:	e8 b7 ff ff ff       	call   80103117 <cmos_read>
80103160:	83 c4 04             	add    $0x4,%esp
80103163:	8b 55 08             	mov    0x8(%ebp),%edx
80103166:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80103169:	6a 04                	push   $0x4
8010316b:	e8 a7 ff ff ff       	call   80103117 <cmos_read>
80103170:	83 c4 04             	add    $0x4,%esp
80103173:	8b 55 08             	mov    0x8(%ebp),%edx
80103176:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80103179:	6a 07                	push   $0x7
8010317b:	e8 97 ff ff ff       	call   80103117 <cmos_read>
80103180:	83 c4 04             	add    $0x4,%esp
80103183:	8b 55 08             	mov    0x8(%ebp),%edx
80103186:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80103189:	6a 08                	push   $0x8
8010318b:	e8 87 ff ff ff       	call   80103117 <cmos_read>
80103190:	83 c4 04             	add    $0x4,%esp
80103193:	8b 55 08             	mov    0x8(%ebp),%edx
80103196:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80103199:	6a 09                	push   $0x9
8010319b:	e8 77 ff ff ff       	call   80103117 <cmos_read>
801031a0:	83 c4 04             	add    $0x4,%esp
801031a3:	8b 55 08             	mov    0x8(%ebp),%edx
801031a6:	89 42 14             	mov    %eax,0x14(%edx)
}
801031a9:	90                   	nop
801031aa:	c9                   	leave  
801031ab:	c3                   	ret    

801031ac <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
801031ac:	55                   	push   %ebp
801031ad:	89 e5                	mov    %esp,%ebp
801031af:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801031b2:	6a 0b                	push   $0xb
801031b4:	e8 5e ff ff ff       	call   80103117 <cmos_read>
801031b9:	83 c4 04             	add    $0x4,%esp
801031bc:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801031bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031c2:	83 e0 04             	and    $0x4,%eax
801031c5:	85 c0                	test   %eax,%eax
801031c7:	0f 94 c0             	sete   %al
801031ca:	0f b6 c0             	movzbl %al,%eax
801031cd:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
801031d0:	8d 45 d8             	lea    -0x28(%ebp),%eax
801031d3:	50                   	push   %eax
801031d4:	e8 6e ff ff ff       	call   80103147 <fill_rtcdate>
801031d9:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
801031dc:	6a 0a                	push   $0xa
801031de:	e8 34 ff ff ff       	call   80103117 <cmos_read>
801031e3:	83 c4 04             	add    $0x4,%esp
801031e6:	25 80 00 00 00       	and    $0x80,%eax
801031eb:	85 c0                	test   %eax,%eax
801031ed:	75 27                	jne    80103216 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
801031ef:	8d 45 c0             	lea    -0x40(%ebp),%eax
801031f2:	50                   	push   %eax
801031f3:	e8 4f ff ff ff       	call   80103147 <fill_rtcdate>
801031f8:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
801031fb:	83 ec 04             	sub    $0x4,%esp
801031fe:	6a 18                	push   $0x18
80103200:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103203:	50                   	push   %eax
80103204:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103207:	50                   	push   %eax
80103208:	e8 3f 22 00 00       	call   8010544c <memcmp>
8010320d:	83 c4 10             	add    $0x10,%esp
80103210:	85 c0                	test   %eax,%eax
80103212:	74 05                	je     80103219 <cmostime+0x6d>
80103214:	eb ba                	jmp    801031d0 <cmostime+0x24>
        continue;
80103216:	90                   	nop
    fill_rtcdate(&t1);
80103217:	eb b7                	jmp    801031d0 <cmostime+0x24>
      break;
80103219:	90                   	nop
  }

  // convert
  if(bcd) {
8010321a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010321e:	0f 84 b4 00 00 00    	je     801032d8 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103224:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103227:	c1 e8 04             	shr    $0x4,%eax
8010322a:	89 c2                	mov    %eax,%edx
8010322c:	89 d0                	mov    %edx,%eax
8010322e:	c1 e0 02             	shl    $0x2,%eax
80103231:	01 d0                	add    %edx,%eax
80103233:	01 c0                	add    %eax,%eax
80103235:	89 c2                	mov    %eax,%edx
80103237:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010323a:	83 e0 0f             	and    $0xf,%eax
8010323d:	01 d0                	add    %edx,%eax
8010323f:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103242:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103245:	c1 e8 04             	shr    $0x4,%eax
80103248:	89 c2                	mov    %eax,%edx
8010324a:	89 d0                	mov    %edx,%eax
8010324c:	c1 e0 02             	shl    $0x2,%eax
8010324f:	01 d0                	add    %edx,%eax
80103251:	01 c0                	add    %eax,%eax
80103253:	89 c2                	mov    %eax,%edx
80103255:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103258:	83 e0 0f             	and    $0xf,%eax
8010325b:	01 d0                	add    %edx,%eax
8010325d:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80103260:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103263:	c1 e8 04             	shr    $0x4,%eax
80103266:	89 c2                	mov    %eax,%edx
80103268:	89 d0                	mov    %edx,%eax
8010326a:	c1 e0 02             	shl    $0x2,%eax
8010326d:	01 d0                	add    %edx,%eax
8010326f:	01 c0                	add    %eax,%eax
80103271:	89 c2                	mov    %eax,%edx
80103273:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103276:	83 e0 0f             	and    $0xf,%eax
80103279:	01 d0                	add    %edx,%eax
8010327b:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
8010327e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103281:	c1 e8 04             	shr    $0x4,%eax
80103284:	89 c2                	mov    %eax,%edx
80103286:	89 d0                	mov    %edx,%eax
80103288:	c1 e0 02             	shl    $0x2,%eax
8010328b:	01 d0                	add    %edx,%eax
8010328d:	01 c0                	add    %eax,%eax
8010328f:	89 c2                	mov    %eax,%edx
80103291:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103294:	83 e0 0f             	and    $0xf,%eax
80103297:	01 d0                	add    %edx,%eax
80103299:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
8010329c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010329f:	c1 e8 04             	shr    $0x4,%eax
801032a2:	89 c2                	mov    %eax,%edx
801032a4:	89 d0                	mov    %edx,%eax
801032a6:	c1 e0 02             	shl    $0x2,%eax
801032a9:	01 d0                	add    %edx,%eax
801032ab:	01 c0                	add    %eax,%eax
801032ad:	89 c2                	mov    %eax,%edx
801032af:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032b2:	83 e0 0f             	and    $0xf,%eax
801032b5:	01 d0                	add    %edx,%eax
801032b7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801032ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032bd:	c1 e8 04             	shr    $0x4,%eax
801032c0:	89 c2                	mov    %eax,%edx
801032c2:	89 d0                	mov    %edx,%eax
801032c4:	c1 e0 02             	shl    $0x2,%eax
801032c7:	01 d0                	add    %edx,%eax
801032c9:	01 c0                	add    %eax,%eax
801032cb:	89 c2                	mov    %eax,%edx
801032cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032d0:	83 e0 0f             	and    $0xf,%eax
801032d3:	01 d0                	add    %edx,%eax
801032d5:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
801032d8:	8b 45 08             	mov    0x8(%ebp),%eax
801032db:	8b 55 d8             	mov    -0x28(%ebp),%edx
801032de:	89 10                	mov    %edx,(%eax)
801032e0:	8b 55 dc             	mov    -0x24(%ebp),%edx
801032e3:	89 50 04             	mov    %edx,0x4(%eax)
801032e6:	8b 55 e0             	mov    -0x20(%ebp),%edx
801032e9:	89 50 08             	mov    %edx,0x8(%eax)
801032ec:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801032ef:	89 50 0c             	mov    %edx,0xc(%eax)
801032f2:	8b 55 e8             	mov    -0x18(%ebp),%edx
801032f5:	89 50 10             	mov    %edx,0x10(%eax)
801032f8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801032fb:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
801032fe:	8b 45 08             	mov    0x8(%ebp),%eax
80103301:	8b 40 14             	mov    0x14(%eax),%eax
80103304:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
8010330a:	8b 45 08             	mov    0x8(%ebp),%eax
8010330d:	89 50 14             	mov    %edx,0x14(%eax)
}
80103310:	90                   	nop
80103311:	c9                   	leave  
80103312:	c3                   	ret    

80103313 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80103313:	55                   	push   %ebp
80103314:	89 e5                	mov    %esp,%ebp
80103316:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103319:	83 ec 08             	sub    $0x8,%esp
8010331c:	68 19 88 10 80       	push   $0x80108819
80103321:	68 e0 26 11 80       	push   $0x801126e0
80103326:	e8 12 1e 00 00       	call   8010513d <initlock>
8010332b:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
8010332e:	83 ec 08             	sub    $0x8,%esp
80103331:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103334:	50                   	push   %eax
80103335:	ff 75 08             	push   0x8(%ebp)
80103338:	e8 d4 e0 ff ff       	call   80101411 <readsb>
8010333d:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80103340:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103343:	a3 14 27 11 80       	mov    %eax,0x80112714
  log.size = sb.nlog;
80103348:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010334b:	a3 18 27 11 80       	mov    %eax,0x80112718
  log.dev = dev;
80103350:	8b 45 08             	mov    0x8(%ebp),%eax
80103353:	a3 24 27 11 80       	mov    %eax,0x80112724
  recover_from_log();
80103358:	e8 b3 01 00 00       	call   80103510 <recover_from_log>
}
8010335d:	90                   	nop
8010335e:	c9                   	leave  
8010335f:	c3                   	ret    

80103360 <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80103360:	55                   	push   %ebp
80103361:	89 e5                	mov    %esp,%ebp
80103363:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103366:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010336d:	e9 95 00 00 00       	jmp    80103407 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103372:	8b 15 14 27 11 80    	mov    0x80112714,%edx
80103378:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010337b:	01 d0                	add    %edx,%eax
8010337d:	83 c0 01             	add    $0x1,%eax
80103380:	89 c2                	mov    %eax,%edx
80103382:	a1 24 27 11 80       	mov    0x80112724,%eax
80103387:	83 ec 08             	sub    $0x8,%esp
8010338a:	52                   	push   %edx
8010338b:	50                   	push   %eax
8010338c:	e8 3e ce ff ff       	call   801001cf <bread>
80103391:	83 c4 10             	add    $0x10,%esp
80103394:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103397:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010339a:	83 c0 10             	add    $0x10,%eax
8010339d:	8b 04 85 ec 26 11 80 	mov    -0x7feed914(,%eax,4),%eax
801033a4:	89 c2                	mov    %eax,%edx
801033a6:	a1 24 27 11 80       	mov    0x80112724,%eax
801033ab:	83 ec 08             	sub    $0x8,%esp
801033ae:	52                   	push   %edx
801033af:	50                   	push   %eax
801033b0:	e8 1a ce ff ff       	call   801001cf <bread>
801033b5:	83 c4 10             	add    $0x10,%esp
801033b8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801033bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033be:	8d 50 5c             	lea    0x5c(%eax),%edx
801033c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033c4:	83 c0 5c             	add    $0x5c,%eax
801033c7:	83 ec 04             	sub    $0x4,%esp
801033ca:	68 00 02 00 00       	push   $0x200
801033cf:	52                   	push   %edx
801033d0:	50                   	push   %eax
801033d1:	e8 ce 20 00 00       	call   801054a4 <memmove>
801033d6:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
801033d9:	83 ec 0c             	sub    $0xc,%esp
801033dc:	ff 75 ec             	push   -0x14(%ebp)
801033df:	e8 24 ce ff ff       	call   80100208 <bwrite>
801033e4:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
801033e7:	83 ec 0c             	sub    $0xc,%esp
801033ea:	ff 75 f0             	push   -0x10(%ebp)
801033ed:	e8 5f ce ff ff       	call   80100251 <brelse>
801033f2:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
801033f5:	83 ec 0c             	sub    $0xc,%esp
801033f8:	ff 75 ec             	push   -0x14(%ebp)
801033fb:	e8 51 ce ff ff       	call   80100251 <brelse>
80103400:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103403:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103407:	a1 28 27 11 80       	mov    0x80112728,%eax
8010340c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010340f:	0f 8c 5d ff ff ff    	jl     80103372 <install_trans+0x12>
  }
}
80103415:	90                   	nop
80103416:	90                   	nop
80103417:	c9                   	leave  
80103418:	c3                   	ret    

80103419 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103419:	55                   	push   %ebp
8010341a:	89 e5                	mov    %esp,%ebp
8010341c:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
8010341f:	a1 14 27 11 80       	mov    0x80112714,%eax
80103424:	89 c2                	mov    %eax,%edx
80103426:	a1 24 27 11 80       	mov    0x80112724,%eax
8010342b:	83 ec 08             	sub    $0x8,%esp
8010342e:	52                   	push   %edx
8010342f:	50                   	push   %eax
80103430:	e8 9a cd ff ff       	call   801001cf <bread>
80103435:	83 c4 10             	add    $0x10,%esp
80103438:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
8010343b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010343e:	83 c0 5c             	add    $0x5c,%eax
80103441:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103444:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103447:	8b 00                	mov    (%eax),%eax
80103449:	a3 28 27 11 80       	mov    %eax,0x80112728
  for (i = 0; i < log.lh.n; i++) {
8010344e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103455:	eb 1b                	jmp    80103472 <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80103457:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010345a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010345d:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103461:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103464:	83 c2 10             	add    $0x10,%edx
80103467:	89 04 95 ec 26 11 80 	mov    %eax,-0x7feed914(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010346e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103472:	a1 28 27 11 80       	mov    0x80112728,%eax
80103477:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010347a:	7c db                	jl     80103457 <read_head+0x3e>
  }
  brelse(buf);
8010347c:	83 ec 0c             	sub    $0xc,%esp
8010347f:	ff 75 f0             	push   -0x10(%ebp)
80103482:	e8 ca cd ff ff       	call   80100251 <brelse>
80103487:	83 c4 10             	add    $0x10,%esp
}
8010348a:	90                   	nop
8010348b:	c9                   	leave  
8010348c:	c3                   	ret    

8010348d <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
8010348d:	55                   	push   %ebp
8010348e:	89 e5                	mov    %esp,%ebp
80103490:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103493:	a1 14 27 11 80       	mov    0x80112714,%eax
80103498:	89 c2                	mov    %eax,%edx
8010349a:	a1 24 27 11 80       	mov    0x80112724,%eax
8010349f:	83 ec 08             	sub    $0x8,%esp
801034a2:	52                   	push   %edx
801034a3:	50                   	push   %eax
801034a4:	e8 26 cd ff ff       	call   801001cf <bread>
801034a9:	83 c4 10             	add    $0x10,%esp
801034ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801034af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034b2:	83 c0 5c             	add    $0x5c,%eax
801034b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801034b8:	8b 15 28 27 11 80    	mov    0x80112728,%edx
801034be:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034c1:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801034c3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801034ca:	eb 1b                	jmp    801034e7 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
801034cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034cf:	83 c0 10             	add    $0x10,%eax
801034d2:	8b 0c 85 ec 26 11 80 	mov    -0x7feed914(,%eax,4),%ecx
801034d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034df:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
801034e3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801034e7:	a1 28 27 11 80       	mov    0x80112728,%eax
801034ec:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801034ef:	7c db                	jl     801034cc <write_head+0x3f>
  }
  bwrite(buf);
801034f1:	83 ec 0c             	sub    $0xc,%esp
801034f4:	ff 75 f0             	push   -0x10(%ebp)
801034f7:	e8 0c cd ff ff       	call   80100208 <bwrite>
801034fc:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
801034ff:	83 ec 0c             	sub    $0xc,%esp
80103502:	ff 75 f0             	push   -0x10(%ebp)
80103505:	e8 47 cd ff ff       	call   80100251 <brelse>
8010350a:	83 c4 10             	add    $0x10,%esp
}
8010350d:	90                   	nop
8010350e:	c9                   	leave  
8010350f:	c3                   	ret    

80103510 <recover_from_log>:

static void
recover_from_log(void)
{
80103510:	55                   	push   %ebp
80103511:	89 e5                	mov    %esp,%ebp
80103513:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103516:	e8 fe fe ff ff       	call   80103419 <read_head>
  install_trans(); // if committed, copy from log to disk
8010351b:	e8 40 fe ff ff       	call   80103360 <install_trans>
  log.lh.n = 0;
80103520:	c7 05 28 27 11 80 00 	movl   $0x0,0x80112728
80103527:	00 00 00 
  write_head(); // clear the log
8010352a:	e8 5e ff ff ff       	call   8010348d <write_head>
}
8010352f:	90                   	nop
80103530:	c9                   	leave  
80103531:	c3                   	ret    

80103532 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103532:	55                   	push   %ebp
80103533:	89 e5                	mov    %esp,%ebp
80103535:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103538:	83 ec 0c             	sub    $0xc,%esp
8010353b:	68 e0 26 11 80       	push   $0x801126e0
80103540:	e8 1a 1c 00 00       	call   8010515f <acquire>
80103545:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103548:	a1 20 27 11 80       	mov    0x80112720,%eax
8010354d:	85 c0                	test   %eax,%eax
8010354f:	74 17                	je     80103568 <begin_op+0x36>
      sleep(&log, &log.lock);
80103551:	83 ec 08             	sub    $0x8,%esp
80103554:	68 e0 26 11 80       	push   $0x801126e0
80103559:	68 e0 26 11 80       	push   $0x801126e0
8010355e:	e8 ac 16 00 00       	call   80104c0f <sleep>
80103563:	83 c4 10             	add    $0x10,%esp
80103566:	eb e0                	jmp    80103548 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103568:	8b 0d 28 27 11 80    	mov    0x80112728,%ecx
8010356e:	a1 1c 27 11 80       	mov    0x8011271c,%eax
80103573:	8d 50 01             	lea    0x1(%eax),%edx
80103576:	89 d0                	mov    %edx,%eax
80103578:	c1 e0 02             	shl    $0x2,%eax
8010357b:	01 d0                	add    %edx,%eax
8010357d:	01 c0                	add    %eax,%eax
8010357f:	01 c8                	add    %ecx,%eax
80103581:	83 f8 1e             	cmp    $0x1e,%eax
80103584:	7e 17                	jle    8010359d <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103586:	83 ec 08             	sub    $0x8,%esp
80103589:	68 e0 26 11 80       	push   $0x801126e0
8010358e:	68 e0 26 11 80       	push   $0x801126e0
80103593:	e8 77 16 00 00       	call   80104c0f <sleep>
80103598:	83 c4 10             	add    $0x10,%esp
8010359b:	eb ab                	jmp    80103548 <begin_op+0x16>
    } else {
      log.outstanding += 1;
8010359d:	a1 1c 27 11 80       	mov    0x8011271c,%eax
801035a2:	83 c0 01             	add    $0x1,%eax
801035a5:	a3 1c 27 11 80       	mov    %eax,0x8011271c
      release(&log.lock);
801035aa:	83 ec 0c             	sub    $0xc,%esp
801035ad:	68 e0 26 11 80       	push   $0x801126e0
801035b2:	e8 16 1c 00 00       	call   801051cd <release>
801035b7:	83 c4 10             	add    $0x10,%esp
      break;
801035ba:	90                   	nop
    }
  }
}
801035bb:	90                   	nop
801035bc:	c9                   	leave  
801035bd:	c3                   	ret    

801035be <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801035be:	55                   	push   %ebp
801035bf:	89 e5                	mov    %esp,%ebp
801035c1:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801035c4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801035cb:	83 ec 0c             	sub    $0xc,%esp
801035ce:	68 e0 26 11 80       	push   $0x801126e0
801035d3:	e8 87 1b 00 00       	call   8010515f <acquire>
801035d8:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801035db:	a1 1c 27 11 80       	mov    0x8011271c,%eax
801035e0:	83 e8 01             	sub    $0x1,%eax
801035e3:	a3 1c 27 11 80       	mov    %eax,0x8011271c
  if(log.committing)
801035e8:	a1 20 27 11 80       	mov    0x80112720,%eax
801035ed:	85 c0                	test   %eax,%eax
801035ef:	74 0d                	je     801035fe <end_op+0x40>
    panic("log.committing");
801035f1:	83 ec 0c             	sub    $0xc,%esp
801035f4:	68 1d 88 10 80       	push   $0x8010881d
801035f9:	e8 b7 cf ff ff       	call   801005b5 <panic>
  if(log.outstanding == 0){
801035fe:	a1 1c 27 11 80       	mov    0x8011271c,%eax
80103603:	85 c0                	test   %eax,%eax
80103605:	75 13                	jne    8010361a <end_op+0x5c>
    do_commit = 1;
80103607:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
8010360e:	c7 05 20 27 11 80 01 	movl   $0x1,0x80112720
80103615:	00 00 00 
80103618:	eb 10                	jmp    8010362a <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
8010361a:	83 ec 0c             	sub    $0xc,%esp
8010361d:	68 e0 26 11 80       	push   $0x801126e0
80103622:	e8 d2 16 00 00       	call   80104cf9 <wakeup>
80103627:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
8010362a:	83 ec 0c             	sub    $0xc,%esp
8010362d:	68 e0 26 11 80       	push   $0x801126e0
80103632:	e8 96 1b 00 00       	call   801051cd <release>
80103637:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
8010363a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010363e:	74 3f                	je     8010367f <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103640:	e8 f6 00 00 00       	call   8010373b <commit>
    acquire(&log.lock);
80103645:	83 ec 0c             	sub    $0xc,%esp
80103648:	68 e0 26 11 80       	push   $0x801126e0
8010364d:	e8 0d 1b 00 00       	call   8010515f <acquire>
80103652:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103655:	c7 05 20 27 11 80 00 	movl   $0x0,0x80112720
8010365c:	00 00 00 
    wakeup(&log);
8010365f:	83 ec 0c             	sub    $0xc,%esp
80103662:	68 e0 26 11 80       	push   $0x801126e0
80103667:	e8 8d 16 00 00       	call   80104cf9 <wakeup>
8010366c:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
8010366f:	83 ec 0c             	sub    $0xc,%esp
80103672:	68 e0 26 11 80       	push   $0x801126e0
80103677:	e8 51 1b 00 00       	call   801051cd <release>
8010367c:	83 c4 10             	add    $0x10,%esp
  }
}
8010367f:	90                   	nop
80103680:	c9                   	leave  
80103681:	c3                   	ret    

80103682 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80103682:	55                   	push   %ebp
80103683:	89 e5                	mov    %esp,%ebp
80103685:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103688:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010368f:	e9 95 00 00 00       	jmp    80103729 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103694:	8b 15 14 27 11 80    	mov    0x80112714,%edx
8010369a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010369d:	01 d0                	add    %edx,%eax
8010369f:	83 c0 01             	add    $0x1,%eax
801036a2:	89 c2                	mov    %eax,%edx
801036a4:	a1 24 27 11 80       	mov    0x80112724,%eax
801036a9:	83 ec 08             	sub    $0x8,%esp
801036ac:	52                   	push   %edx
801036ad:	50                   	push   %eax
801036ae:	e8 1c cb ff ff       	call   801001cf <bread>
801036b3:	83 c4 10             	add    $0x10,%esp
801036b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801036b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036bc:	83 c0 10             	add    $0x10,%eax
801036bf:	8b 04 85 ec 26 11 80 	mov    -0x7feed914(,%eax,4),%eax
801036c6:	89 c2                	mov    %eax,%edx
801036c8:	a1 24 27 11 80       	mov    0x80112724,%eax
801036cd:	83 ec 08             	sub    $0x8,%esp
801036d0:	52                   	push   %edx
801036d1:	50                   	push   %eax
801036d2:	e8 f8 ca ff ff       	call   801001cf <bread>
801036d7:	83 c4 10             	add    $0x10,%esp
801036da:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801036dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036e0:	8d 50 5c             	lea    0x5c(%eax),%edx
801036e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036e6:	83 c0 5c             	add    $0x5c,%eax
801036e9:	83 ec 04             	sub    $0x4,%esp
801036ec:	68 00 02 00 00       	push   $0x200
801036f1:	52                   	push   %edx
801036f2:	50                   	push   %eax
801036f3:	e8 ac 1d 00 00       	call   801054a4 <memmove>
801036f8:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
801036fb:	83 ec 0c             	sub    $0xc,%esp
801036fe:	ff 75 f0             	push   -0x10(%ebp)
80103701:	e8 02 cb ff ff       	call   80100208 <bwrite>
80103706:	83 c4 10             	add    $0x10,%esp
    brelse(from);
80103709:	83 ec 0c             	sub    $0xc,%esp
8010370c:	ff 75 ec             	push   -0x14(%ebp)
8010370f:	e8 3d cb ff ff       	call   80100251 <brelse>
80103714:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103717:	83 ec 0c             	sub    $0xc,%esp
8010371a:	ff 75 f0             	push   -0x10(%ebp)
8010371d:	e8 2f cb ff ff       	call   80100251 <brelse>
80103722:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103725:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103729:	a1 28 27 11 80       	mov    0x80112728,%eax
8010372e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103731:	0f 8c 5d ff ff ff    	jl     80103694 <write_log+0x12>
  }
}
80103737:	90                   	nop
80103738:	90                   	nop
80103739:	c9                   	leave  
8010373a:	c3                   	ret    

8010373b <commit>:

static void
commit()
{
8010373b:	55                   	push   %ebp
8010373c:	89 e5                	mov    %esp,%ebp
8010373e:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103741:	a1 28 27 11 80       	mov    0x80112728,%eax
80103746:	85 c0                	test   %eax,%eax
80103748:	7e 1e                	jle    80103768 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
8010374a:	e8 33 ff ff ff       	call   80103682 <write_log>
    write_head();    // Write header to disk -- the real commit
8010374f:	e8 39 fd ff ff       	call   8010348d <write_head>
    install_trans(); // Now install writes to home locations
80103754:	e8 07 fc ff ff       	call   80103360 <install_trans>
    log.lh.n = 0;
80103759:	c7 05 28 27 11 80 00 	movl   $0x0,0x80112728
80103760:	00 00 00 
    write_head();    // Erase the transaction from the log
80103763:	e8 25 fd ff ff       	call   8010348d <write_head>
  }
}
80103768:	90                   	nop
80103769:	c9                   	leave  
8010376a:	c3                   	ret    

8010376b <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
8010376b:	55                   	push   %ebp
8010376c:	89 e5                	mov    %esp,%ebp
8010376e:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103771:	a1 28 27 11 80       	mov    0x80112728,%eax
80103776:	83 f8 1d             	cmp    $0x1d,%eax
80103779:	7f 12                	jg     8010378d <log_write+0x22>
8010377b:	a1 28 27 11 80       	mov    0x80112728,%eax
80103780:	8b 15 18 27 11 80    	mov    0x80112718,%edx
80103786:	83 ea 01             	sub    $0x1,%edx
80103789:	39 d0                	cmp    %edx,%eax
8010378b:	7c 0d                	jl     8010379a <log_write+0x2f>
    panic("too big a transaction");
8010378d:	83 ec 0c             	sub    $0xc,%esp
80103790:	68 2c 88 10 80       	push   $0x8010882c
80103795:	e8 1b ce ff ff       	call   801005b5 <panic>
  if (log.outstanding < 1)
8010379a:	a1 1c 27 11 80       	mov    0x8011271c,%eax
8010379f:	85 c0                	test   %eax,%eax
801037a1:	7f 0d                	jg     801037b0 <log_write+0x45>
    panic("log_write outside of trans");
801037a3:	83 ec 0c             	sub    $0xc,%esp
801037a6:	68 42 88 10 80       	push   $0x80108842
801037ab:	e8 05 ce ff ff       	call   801005b5 <panic>

  acquire(&log.lock);
801037b0:	83 ec 0c             	sub    $0xc,%esp
801037b3:	68 e0 26 11 80       	push   $0x801126e0
801037b8:	e8 a2 19 00 00       	call   8010515f <acquire>
801037bd:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801037c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801037c7:	eb 1d                	jmp    801037e6 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801037c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037cc:	83 c0 10             	add    $0x10,%eax
801037cf:	8b 04 85 ec 26 11 80 	mov    -0x7feed914(,%eax,4),%eax
801037d6:	89 c2                	mov    %eax,%edx
801037d8:	8b 45 08             	mov    0x8(%ebp),%eax
801037db:	8b 40 08             	mov    0x8(%eax),%eax
801037de:	39 c2                	cmp    %eax,%edx
801037e0:	74 10                	je     801037f2 <log_write+0x87>
  for (i = 0; i < log.lh.n; i++) {
801037e2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801037e6:	a1 28 27 11 80       	mov    0x80112728,%eax
801037eb:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801037ee:	7c d9                	jl     801037c9 <log_write+0x5e>
801037f0:	eb 01                	jmp    801037f3 <log_write+0x88>
      break;
801037f2:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801037f3:	8b 45 08             	mov    0x8(%ebp),%eax
801037f6:	8b 40 08             	mov    0x8(%eax),%eax
801037f9:	89 c2                	mov    %eax,%edx
801037fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037fe:	83 c0 10             	add    $0x10,%eax
80103801:	89 14 85 ec 26 11 80 	mov    %edx,-0x7feed914(,%eax,4)
  if (i == log.lh.n)
80103808:	a1 28 27 11 80       	mov    0x80112728,%eax
8010380d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103810:	75 0d                	jne    8010381f <log_write+0xb4>
    log.lh.n++;
80103812:	a1 28 27 11 80       	mov    0x80112728,%eax
80103817:	83 c0 01             	add    $0x1,%eax
8010381a:	a3 28 27 11 80       	mov    %eax,0x80112728
  b->flags |= B_DIRTY; // prevent eviction
8010381f:	8b 45 08             	mov    0x8(%ebp),%eax
80103822:	8b 00                	mov    (%eax),%eax
80103824:	83 c8 04             	or     $0x4,%eax
80103827:	89 c2                	mov    %eax,%edx
80103829:	8b 45 08             	mov    0x8(%ebp),%eax
8010382c:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
8010382e:	83 ec 0c             	sub    $0xc,%esp
80103831:	68 e0 26 11 80       	push   $0x801126e0
80103836:	e8 92 19 00 00       	call   801051cd <release>
8010383b:	83 c4 10             	add    $0x10,%esp
}
8010383e:	90                   	nop
8010383f:	c9                   	leave  
80103840:	c3                   	ret    

80103841 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103841:	55                   	push   %ebp
80103842:	89 e5                	mov    %esp,%ebp
80103844:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103847:	8b 55 08             	mov    0x8(%ebp),%edx
8010384a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010384d:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103850:	f0 87 02             	lock xchg %eax,(%edx)
80103853:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103856:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103859:	c9                   	leave  
8010385a:	c3                   	ret    

8010385b <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
8010385b:	8d 4c 24 04          	lea    0x4(%esp),%ecx
8010385f:	83 e4 f0             	and    $0xfffffff0,%esp
80103862:	ff 71 fc             	push   -0x4(%ecx)
80103865:	55                   	push   %ebp
80103866:	89 e5                	mov    %esp,%ebp
80103868:	51                   	push   %ecx
80103869:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010386c:	83 ec 08             	sub    $0x8,%esp
8010386f:	68 00 00 40 80       	push   $0x80400000
80103874:	68 e0 69 11 80       	push   $0x801169e0
80103879:	e8 e3 f2 ff ff       	call   80102b61 <kinit1>
8010387e:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103881:	e8 62 45 00 00       	call   80107de8 <kvmalloc>
  mpinit();        // detect other processors
80103886:	e8 bd 03 00 00       	call   80103c48 <mpinit>
  lapicinit();     // interrupt controller
8010388b:	e8 41 f6 ff ff       	call   80102ed1 <lapicinit>
  seginit();       // segment descriptors
80103890:	e8 3e 40 00 00       	call   801078d3 <seginit>
  picinit();       // disable pic
80103895:	e8 15 05 00 00       	call   80103daf <picinit>
  ioapicinit();    // another interrupt controller
8010389a:	e8 dd f1 ff ff       	call   80102a7c <ioapicinit>
  consoleinit();   // console hardware
8010389f:	e8 d4 d2 ff ff       	call   80100b78 <consoleinit>
  uartinit();      // serial port
801038a4:	e8 c3 33 00 00       	call   80106c6c <uartinit>
  pinit();         // process table
801038a9:	e8 3a 09 00 00       	call   801041e8 <pinit>
  tvinit();        // trap vectors
801038ae:	e8 99 2f 00 00       	call   8010684c <tvinit>
  binit();         // buffer cache
801038b3:	e8 7c c7 ff ff       	call   80100034 <binit>
  fileinit();      // file table
801038b8:	e8 45 d7 ff ff       	call   80101002 <fileinit>
  ideinit();       // disk 
801038bd:	e8 91 ed ff ff       	call   80102653 <ideinit>
  startothers();   // start other processors
801038c2:	e8 80 00 00 00       	call   80103947 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801038c7:	83 ec 08             	sub    $0x8,%esp
801038ca:	68 00 00 00 8e       	push   $0x8e000000
801038cf:	68 00 00 40 80       	push   $0x80400000
801038d4:	e8 c1 f2 ff ff       	call   80102b9a <kinit2>
801038d9:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
801038dc:	e8 ff 0a 00 00       	call   801043e0 <userinit>
  mpmain();        // finish this processor's setup
801038e1:	e8 1a 00 00 00       	call   80103900 <mpmain>

801038e6 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801038e6:	55                   	push   %ebp
801038e7:	89 e5                	mov    %esp,%ebp
801038e9:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
801038ec:	e8 0f 45 00 00       	call   80107e00 <switchkvm>
  seginit();
801038f1:	e8 dd 3f 00 00       	call   801078d3 <seginit>
  lapicinit();
801038f6:	e8 d6 f5 ff ff       	call   80102ed1 <lapicinit>
  mpmain();
801038fb:	e8 00 00 00 00       	call   80103900 <mpmain>

80103900 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103900:	55                   	push   %ebp
80103901:	89 e5                	mov    %esp,%ebp
80103903:	53                   	push   %ebx
80103904:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103907:	e8 fa 08 00 00       	call   80104206 <cpuid>
8010390c:	89 c3                	mov    %eax,%ebx
8010390e:	e8 f3 08 00 00       	call   80104206 <cpuid>
80103913:	83 ec 04             	sub    $0x4,%esp
80103916:	53                   	push   %ebx
80103917:	50                   	push   %eax
80103918:	68 5d 88 10 80       	push   $0x8010885d
8010391d:	e8 de ca ff ff       	call   80100400 <cprintf>
80103922:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103925:	e8 98 30 00 00       	call   801069c2 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
8010392a:	e8 f2 08 00 00       	call   80104221 <mycpu>
8010392f:	05 a0 00 00 00       	add    $0xa0,%eax
80103934:	83 ec 08             	sub    $0x8,%esp
80103937:	6a 01                	push   $0x1
80103939:	50                   	push   %eax
8010393a:	e8 02 ff ff ff       	call   80103841 <xchg>
8010393f:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103942:	e8 3b 10 00 00       	call   80104982 <scheduler>

80103947 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103947:	55                   	push   %ebp
80103948:	89 e5                	mov    %esp,%ebp
8010394a:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
8010394d:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103954:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103959:	83 ec 04             	sub    $0x4,%esp
8010395c:	50                   	push   %eax
8010395d:	68 ec b4 10 80       	push   $0x8010b4ec
80103962:	ff 75 f0             	push   -0x10(%ebp)
80103965:	e8 3a 1b 00 00       	call   801054a4 <memmove>
8010396a:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
8010396d:	c7 45 f4 c0 27 11 80 	movl   $0x801127c0,-0xc(%ebp)
80103974:	eb 79                	jmp    801039ef <startothers+0xa8>
    if(c == mycpu())  // We've started already.
80103976:	e8 a6 08 00 00       	call   80104221 <mycpu>
8010397b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010397e:	74 67                	je     801039e7 <startothers+0xa0>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103980:	e8 11 f3 ff ff       	call   80102c96 <kalloc>
80103985:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103988:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010398b:	83 e8 04             	sub    $0x4,%eax
8010398e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103991:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103997:	89 10                	mov    %edx,(%eax)
    *(void(**)(void))(code-8) = mpenter;
80103999:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010399c:	83 e8 08             	sub    $0x8,%eax
8010399f:	c7 00 e6 38 10 80    	movl   $0x801038e6,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801039a5:	b8 00 a0 10 80       	mov    $0x8010a000,%eax
801039aa:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801039b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039b3:	83 e8 0c             	sub    $0xc,%eax
801039b6:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
801039b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039bb:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801039c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039c4:	0f b6 00             	movzbl (%eax),%eax
801039c7:	0f b6 c0             	movzbl %al,%eax
801039ca:	83 ec 08             	sub    $0x8,%esp
801039cd:	52                   	push   %edx
801039ce:	50                   	push   %eax
801039cf:	e8 5f f6 ff ff       	call   80103033 <lapicstartap>
801039d4:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801039d7:	90                   	nop
801039d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039db:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801039e1:	85 c0                	test   %eax,%eax
801039e3:	74 f3                	je     801039d8 <startothers+0x91>
801039e5:	eb 01                	jmp    801039e8 <startothers+0xa1>
      continue;
801039e7:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
801039e8:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
801039ef:	a1 40 2d 11 80       	mov    0x80112d40,%eax
801039f4:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801039fa:	05 c0 27 11 80       	add    $0x801127c0,%eax
801039ff:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a02:	0f 82 6e ff ff ff    	jb     80103976 <startothers+0x2f>
      ;
  }
}
80103a08:	90                   	nop
80103a09:	90                   	nop
80103a0a:	c9                   	leave  
80103a0b:	c3                   	ret    

80103a0c <inb>:
{
80103a0c:	55                   	push   %ebp
80103a0d:	89 e5                	mov    %esp,%ebp
80103a0f:	83 ec 14             	sub    $0x14,%esp
80103a12:	8b 45 08             	mov    0x8(%ebp),%eax
80103a15:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103a19:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103a1d:	89 c2                	mov    %eax,%edx
80103a1f:	ec                   	in     (%dx),%al
80103a20:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103a23:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103a27:	c9                   	leave  
80103a28:	c3                   	ret    

80103a29 <outb>:
{
80103a29:	55                   	push   %ebp
80103a2a:	89 e5                	mov    %esp,%ebp
80103a2c:	83 ec 08             	sub    $0x8,%esp
80103a2f:	8b 45 08             	mov    0x8(%ebp),%eax
80103a32:	8b 55 0c             	mov    0xc(%ebp),%edx
80103a35:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103a39:	89 d0                	mov    %edx,%eax
80103a3b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103a3e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103a42:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103a46:	ee                   	out    %al,(%dx)
}
80103a47:	90                   	nop
80103a48:	c9                   	leave  
80103a49:	c3                   	ret    

80103a4a <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80103a4a:	55                   	push   %ebp
80103a4b:	89 e5                	mov    %esp,%ebp
80103a4d:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
80103a50:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103a57:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103a5e:	eb 15                	jmp    80103a75 <sum+0x2b>
    sum += addr[i];
80103a60:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103a63:	8b 45 08             	mov    0x8(%ebp),%eax
80103a66:	01 d0                	add    %edx,%eax
80103a68:	0f b6 00             	movzbl (%eax),%eax
80103a6b:	0f b6 c0             	movzbl %al,%eax
80103a6e:	01 45 f8             	add    %eax,-0x8(%ebp)
  for(i=0; i<len; i++)
80103a71:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103a75:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103a78:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103a7b:	7c e3                	jl     80103a60 <sum+0x16>
  return sum;
80103a7d:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103a80:	c9                   	leave  
80103a81:	c3                   	ret    

80103a82 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103a82:	55                   	push   %ebp
80103a83:	89 e5                	mov    %esp,%ebp
80103a85:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103a88:	8b 45 08             	mov    0x8(%ebp),%eax
80103a8b:	05 00 00 00 80       	add    $0x80000000,%eax
80103a90:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103a93:	8b 55 0c             	mov    0xc(%ebp),%edx
80103a96:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a99:	01 d0                	add    %edx,%eax
80103a9b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103a9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103aa1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103aa4:	eb 36                	jmp    80103adc <mpsearch1+0x5a>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103aa6:	83 ec 04             	sub    $0x4,%esp
80103aa9:	6a 04                	push   $0x4
80103aab:	68 74 88 10 80       	push   $0x80108874
80103ab0:	ff 75 f4             	push   -0xc(%ebp)
80103ab3:	e8 94 19 00 00       	call   8010544c <memcmp>
80103ab8:	83 c4 10             	add    $0x10,%esp
80103abb:	85 c0                	test   %eax,%eax
80103abd:	75 19                	jne    80103ad8 <mpsearch1+0x56>
80103abf:	83 ec 08             	sub    $0x8,%esp
80103ac2:	6a 10                	push   $0x10
80103ac4:	ff 75 f4             	push   -0xc(%ebp)
80103ac7:	e8 7e ff ff ff       	call   80103a4a <sum>
80103acc:	83 c4 10             	add    $0x10,%esp
80103acf:	84 c0                	test   %al,%al
80103ad1:	75 05                	jne    80103ad8 <mpsearch1+0x56>
      return (struct mp*)p;
80103ad3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ad6:	eb 11                	jmp    80103ae9 <mpsearch1+0x67>
  for(p = addr; p < e; p += sizeof(struct mp))
80103ad8:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103adf:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103ae2:	72 c2                	jb     80103aa6 <mpsearch1+0x24>
  return 0;
80103ae4:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103ae9:	c9                   	leave  
80103aea:	c3                   	ret    

80103aeb <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103aeb:	55                   	push   %ebp
80103aec:	89 e5                	mov    %esp,%ebp
80103aee:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103af1:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103afb:	83 c0 0f             	add    $0xf,%eax
80103afe:	0f b6 00             	movzbl (%eax),%eax
80103b01:	0f b6 c0             	movzbl %al,%eax
80103b04:	c1 e0 08             	shl    $0x8,%eax
80103b07:	89 c2                	mov    %eax,%edx
80103b09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b0c:	83 c0 0e             	add    $0xe,%eax
80103b0f:	0f b6 00             	movzbl (%eax),%eax
80103b12:	0f b6 c0             	movzbl %al,%eax
80103b15:	09 d0                	or     %edx,%eax
80103b17:	c1 e0 04             	shl    $0x4,%eax
80103b1a:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103b1d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103b21:	74 21                	je     80103b44 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103b23:	83 ec 08             	sub    $0x8,%esp
80103b26:	68 00 04 00 00       	push   $0x400
80103b2b:	ff 75 f0             	push   -0x10(%ebp)
80103b2e:	e8 4f ff ff ff       	call   80103a82 <mpsearch1>
80103b33:	83 c4 10             	add    $0x10,%esp
80103b36:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b39:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b3d:	74 51                	je     80103b90 <mpsearch+0xa5>
      return mp;
80103b3f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b42:	eb 61                	jmp    80103ba5 <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b47:	83 c0 14             	add    $0x14,%eax
80103b4a:	0f b6 00             	movzbl (%eax),%eax
80103b4d:	0f b6 c0             	movzbl %al,%eax
80103b50:	c1 e0 08             	shl    $0x8,%eax
80103b53:	89 c2                	mov    %eax,%edx
80103b55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b58:	83 c0 13             	add    $0x13,%eax
80103b5b:	0f b6 00             	movzbl (%eax),%eax
80103b5e:	0f b6 c0             	movzbl %al,%eax
80103b61:	09 d0                	or     %edx,%eax
80103b63:	c1 e0 0a             	shl    $0xa,%eax
80103b66:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103b69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b6c:	2d 00 04 00 00       	sub    $0x400,%eax
80103b71:	83 ec 08             	sub    $0x8,%esp
80103b74:	68 00 04 00 00       	push   $0x400
80103b79:	50                   	push   %eax
80103b7a:	e8 03 ff ff ff       	call   80103a82 <mpsearch1>
80103b7f:	83 c4 10             	add    $0x10,%esp
80103b82:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b85:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b89:	74 05                	je     80103b90 <mpsearch+0xa5>
      return mp;
80103b8b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b8e:	eb 15                	jmp    80103ba5 <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80103b90:	83 ec 08             	sub    $0x8,%esp
80103b93:	68 00 00 01 00       	push   $0x10000
80103b98:	68 00 00 0f 00       	push   $0xf0000
80103b9d:	e8 e0 fe ff ff       	call   80103a82 <mpsearch1>
80103ba2:	83 c4 10             	add    $0x10,%esp
}
80103ba5:	c9                   	leave  
80103ba6:	c3                   	ret    

80103ba7 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103ba7:	55                   	push   %ebp
80103ba8:	89 e5                	mov    %esp,%ebp
80103baa:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103bad:	e8 39 ff ff ff       	call   80103aeb <mpsearch>
80103bb2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103bb5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103bb9:	74 0a                	je     80103bc5 <mpconfig+0x1e>
80103bbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bbe:	8b 40 04             	mov    0x4(%eax),%eax
80103bc1:	85 c0                	test   %eax,%eax
80103bc3:	75 07                	jne    80103bcc <mpconfig+0x25>
    return 0;
80103bc5:	b8 00 00 00 00       	mov    $0x0,%eax
80103bca:	eb 7a                	jmp    80103c46 <mpconfig+0x9f>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103bcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bcf:	8b 40 04             	mov    0x4(%eax),%eax
80103bd2:	05 00 00 00 80       	add    $0x80000000,%eax
80103bd7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103bda:	83 ec 04             	sub    $0x4,%esp
80103bdd:	6a 04                	push   $0x4
80103bdf:	68 79 88 10 80       	push   $0x80108879
80103be4:	ff 75 f0             	push   -0x10(%ebp)
80103be7:	e8 60 18 00 00       	call   8010544c <memcmp>
80103bec:	83 c4 10             	add    $0x10,%esp
80103bef:	85 c0                	test   %eax,%eax
80103bf1:	74 07                	je     80103bfa <mpconfig+0x53>
    return 0;
80103bf3:	b8 00 00 00 00       	mov    $0x0,%eax
80103bf8:	eb 4c                	jmp    80103c46 <mpconfig+0x9f>
  if(conf->version != 1 && conf->version != 4)
80103bfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bfd:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103c01:	3c 01                	cmp    $0x1,%al
80103c03:	74 12                	je     80103c17 <mpconfig+0x70>
80103c05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c08:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103c0c:	3c 04                	cmp    $0x4,%al
80103c0e:	74 07                	je     80103c17 <mpconfig+0x70>
    return 0;
80103c10:	b8 00 00 00 00       	mov    $0x0,%eax
80103c15:	eb 2f                	jmp    80103c46 <mpconfig+0x9f>
  if(sum((uchar*)conf, conf->length) != 0)
80103c17:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c1a:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103c1e:	0f b7 c0             	movzwl %ax,%eax
80103c21:	83 ec 08             	sub    $0x8,%esp
80103c24:	50                   	push   %eax
80103c25:	ff 75 f0             	push   -0x10(%ebp)
80103c28:	e8 1d fe ff ff       	call   80103a4a <sum>
80103c2d:	83 c4 10             	add    $0x10,%esp
80103c30:	84 c0                	test   %al,%al
80103c32:	74 07                	je     80103c3b <mpconfig+0x94>
    return 0;
80103c34:	b8 00 00 00 00       	mov    $0x0,%eax
80103c39:	eb 0b                	jmp    80103c46 <mpconfig+0x9f>
  *pmp = mp;
80103c3b:	8b 45 08             	mov    0x8(%ebp),%eax
80103c3e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c41:	89 10                	mov    %edx,(%eax)
  return conf;
80103c43:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103c46:	c9                   	leave  
80103c47:	c3                   	ret    

80103c48 <mpinit>:

void
mpinit(void)
{
80103c48:	55                   	push   %ebp
80103c49:	89 e5                	mov    %esp,%ebp
80103c4b:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103c4e:	83 ec 0c             	sub    $0xc,%esp
80103c51:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103c54:	50                   	push   %eax
80103c55:	e8 4d ff ff ff       	call   80103ba7 <mpconfig>
80103c5a:	83 c4 10             	add    $0x10,%esp
80103c5d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c60:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c64:	75 0d                	jne    80103c73 <mpinit+0x2b>
    panic("Expect to run on an SMP");
80103c66:	83 ec 0c             	sub    $0xc,%esp
80103c69:	68 7e 88 10 80       	push   $0x8010887e
80103c6e:	e8 42 c9 ff ff       	call   801005b5 <panic>
  ismp = 1;
80103c73:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80103c7a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c7d:	8b 40 24             	mov    0x24(%eax),%eax
80103c80:	a3 c0 26 11 80       	mov    %eax,0x801126c0
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103c85:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c88:	83 c0 2c             	add    $0x2c,%eax
80103c8b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c8e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c91:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103c95:	0f b7 d0             	movzwl %ax,%edx
80103c98:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c9b:	01 d0                	add    %edx,%eax
80103c9d:	89 45 e8             	mov    %eax,-0x18(%ebp)
80103ca0:	e9 8c 00 00 00       	jmp    80103d31 <mpinit+0xe9>
    switch(*p){
80103ca5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ca8:	0f b6 00             	movzbl (%eax),%eax
80103cab:	0f b6 c0             	movzbl %al,%eax
80103cae:	83 f8 04             	cmp    $0x4,%eax
80103cb1:	7f 76                	jg     80103d29 <mpinit+0xe1>
80103cb3:	83 f8 03             	cmp    $0x3,%eax
80103cb6:	7d 6b                	jge    80103d23 <mpinit+0xdb>
80103cb8:	83 f8 02             	cmp    $0x2,%eax
80103cbb:	74 4e                	je     80103d0b <mpinit+0xc3>
80103cbd:	83 f8 02             	cmp    $0x2,%eax
80103cc0:	7f 67                	jg     80103d29 <mpinit+0xe1>
80103cc2:	85 c0                	test   %eax,%eax
80103cc4:	74 07                	je     80103ccd <mpinit+0x85>
80103cc6:	83 f8 01             	cmp    $0x1,%eax
80103cc9:	74 58                	je     80103d23 <mpinit+0xdb>
80103ccb:	eb 5c                	jmp    80103d29 <mpinit+0xe1>
    case MPPROC:
      proc = (struct mpproc*)p;
80103ccd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cd0:	89 45 e0             	mov    %eax,-0x20(%ebp)
      if(ncpu < NCPU) {
80103cd3:	a1 40 2d 11 80       	mov    0x80112d40,%eax
80103cd8:	83 f8 07             	cmp    $0x7,%eax
80103cdb:	7f 28                	jg     80103d05 <mpinit+0xbd>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103cdd:	8b 15 40 2d 11 80    	mov    0x80112d40,%edx
80103ce3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103ce6:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103cea:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80103cf0:	81 c2 c0 27 11 80    	add    $0x801127c0,%edx
80103cf6:	88 02                	mov    %al,(%edx)
        ncpu++;
80103cf8:	a1 40 2d 11 80       	mov    0x80112d40,%eax
80103cfd:	83 c0 01             	add    $0x1,%eax
80103d00:	a3 40 2d 11 80       	mov    %eax,0x80112d40
      }
      p += sizeof(struct mpproc);
80103d05:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103d09:	eb 26                	jmp    80103d31 <mpinit+0xe9>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103d0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d0e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103d11:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103d14:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d18:	a2 44 2d 11 80       	mov    %al,0x80112d44
      p += sizeof(struct mpioapic);
80103d1d:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d21:	eb 0e                	jmp    80103d31 <mpinit+0xe9>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103d23:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d27:	eb 08                	jmp    80103d31 <mpinit+0xe9>
    default:
      ismp = 0;
80103d29:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
80103d30:	90                   	nop
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d34:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80103d37:	0f 82 68 ff ff ff    	jb     80103ca5 <mpinit+0x5d>
    }
  }
  if(!ismp)
80103d3d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103d41:	75 0d                	jne    80103d50 <mpinit+0x108>
    panic("Didn't find a suitable machine");
80103d43:	83 ec 0c             	sub    $0xc,%esp
80103d46:	68 98 88 10 80       	push   $0x80108898
80103d4b:	e8 65 c8 ff ff       	call   801005b5 <panic>

  if(mp->imcrp){
80103d50:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d53:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103d57:	84 c0                	test   %al,%al
80103d59:	74 30                	je     80103d8b <mpinit+0x143>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103d5b:	83 ec 08             	sub    $0x8,%esp
80103d5e:	6a 70                	push   $0x70
80103d60:	6a 22                	push   $0x22
80103d62:	e8 c2 fc ff ff       	call   80103a29 <outb>
80103d67:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103d6a:	83 ec 0c             	sub    $0xc,%esp
80103d6d:	6a 23                	push   $0x23
80103d6f:	e8 98 fc ff ff       	call   80103a0c <inb>
80103d74:	83 c4 10             	add    $0x10,%esp
80103d77:	83 c8 01             	or     $0x1,%eax
80103d7a:	0f b6 c0             	movzbl %al,%eax
80103d7d:	83 ec 08             	sub    $0x8,%esp
80103d80:	50                   	push   %eax
80103d81:	6a 23                	push   $0x23
80103d83:	e8 a1 fc ff ff       	call   80103a29 <outb>
80103d88:	83 c4 10             	add    $0x10,%esp
  }
}
80103d8b:	90                   	nop
80103d8c:	c9                   	leave  
80103d8d:	c3                   	ret    

80103d8e <outb>:
{
80103d8e:	55                   	push   %ebp
80103d8f:	89 e5                	mov    %esp,%ebp
80103d91:	83 ec 08             	sub    $0x8,%esp
80103d94:	8b 45 08             	mov    0x8(%ebp),%eax
80103d97:	8b 55 0c             	mov    0xc(%ebp),%edx
80103d9a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103d9e:	89 d0                	mov    %edx,%eax
80103da0:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103da3:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103da7:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103dab:	ee                   	out    %al,(%dx)
}
80103dac:	90                   	nop
80103dad:	c9                   	leave  
80103dae:	c3                   	ret    

80103daf <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103daf:	55                   	push   %ebp
80103db0:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103db2:	68 ff 00 00 00       	push   $0xff
80103db7:	6a 21                	push   $0x21
80103db9:	e8 d0 ff ff ff       	call   80103d8e <outb>
80103dbe:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103dc1:	68 ff 00 00 00       	push   $0xff
80103dc6:	68 a1 00 00 00       	push   $0xa1
80103dcb:	e8 be ff ff ff       	call   80103d8e <outb>
80103dd0:	83 c4 08             	add    $0x8,%esp
}
80103dd3:	90                   	nop
80103dd4:	c9                   	leave  
80103dd5:	c3                   	ret    

80103dd6 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103dd6:	55                   	push   %ebp
80103dd7:	89 e5                	mov    %esp,%ebp
80103dd9:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103ddc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103de3:	8b 45 0c             	mov    0xc(%ebp),%eax
80103de6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103dec:	8b 45 0c             	mov    0xc(%ebp),%eax
80103def:	8b 10                	mov    (%eax),%edx
80103df1:	8b 45 08             	mov    0x8(%ebp),%eax
80103df4:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103df6:	e8 25 d2 ff ff       	call   80101020 <filealloc>
80103dfb:	8b 55 08             	mov    0x8(%ebp),%edx
80103dfe:	89 02                	mov    %eax,(%edx)
80103e00:	8b 45 08             	mov    0x8(%ebp),%eax
80103e03:	8b 00                	mov    (%eax),%eax
80103e05:	85 c0                	test   %eax,%eax
80103e07:	0f 84 c8 00 00 00    	je     80103ed5 <pipealloc+0xff>
80103e0d:	e8 0e d2 ff ff       	call   80101020 <filealloc>
80103e12:	8b 55 0c             	mov    0xc(%ebp),%edx
80103e15:	89 02                	mov    %eax,(%edx)
80103e17:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e1a:	8b 00                	mov    (%eax),%eax
80103e1c:	85 c0                	test   %eax,%eax
80103e1e:	0f 84 b1 00 00 00    	je     80103ed5 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103e24:	e8 6d ee ff ff       	call   80102c96 <kalloc>
80103e29:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103e2c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103e30:	0f 84 a2 00 00 00    	je     80103ed8 <pipealloc+0x102>
    goto bad;
  p->readopen = 1;
80103e36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e39:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103e40:	00 00 00 
  p->writeopen = 1;
80103e43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e46:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103e4d:	00 00 00 
  p->nwrite = 0;
80103e50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e53:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103e5a:	00 00 00 
  p->nread = 0;
80103e5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e60:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103e67:	00 00 00 
  initlock(&p->lock, "pipe");
80103e6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e6d:	83 ec 08             	sub    $0x8,%esp
80103e70:	68 b7 88 10 80       	push   $0x801088b7
80103e75:	50                   	push   %eax
80103e76:	e8 c2 12 00 00       	call   8010513d <initlock>
80103e7b:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103e7e:	8b 45 08             	mov    0x8(%ebp),%eax
80103e81:	8b 00                	mov    (%eax),%eax
80103e83:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103e89:	8b 45 08             	mov    0x8(%ebp),%eax
80103e8c:	8b 00                	mov    (%eax),%eax
80103e8e:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103e92:	8b 45 08             	mov    0x8(%ebp),%eax
80103e95:	8b 00                	mov    (%eax),%eax
80103e97:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103e9b:	8b 45 08             	mov    0x8(%ebp),%eax
80103e9e:	8b 00                	mov    (%eax),%eax
80103ea0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ea3:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103ea6:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ea9:	8b 00                	mov    (%eax),%eax
80103eab:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103eb1:	8b 45 0c             	mov    0xc(%ebp),%eax
80103eb4:	8b 00                	mov    (%eax),%eax
80103eb6:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103eba:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ebd:	8b 00                	mov    (%eax),%eax
80103ebf:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103ec3:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ec6:	8b 00                	mov    (%eax),%eax
80103ec8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ecb:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103ece:	b8 00 00 00 00       	mov    $0x0,%eax
80103ed3:	eb 51                	jmp    80103f26 <pipealloc+0x150>
    goto bad;
80103ed5:	90                   	nop
80103ed6:	eb 01                	jmp    80103ed9 <pipealloc+0x103>
    goto bad;
80103ed8:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80103ed9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103edd:	74 0e                	je     80103eed <pipealloc+0x117>
    kfree((char*)p);
80103edf:	83 ec 0c             	sub    $0xc,%esp
80103ee2:	ff 75 f4             	push   -0xc(%ebp)
80103ee5:	e8 12 ed ff ff       	call   80102bfc <kfree>
80103eea:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80103eed:	8b 45 08             	mov    0x8(%ebp),%eax
80103ef0:	8b 00                	mov    (%eax),%eax
80103ef2:	85 c0                	test   %eax,%eax
80103ef4:	74 11                	je     80103f07 <pipealloc+0x131>
    fileclose(*f0);
80103ef6:	8b 45 08             	mov    0x8(%ebp),%eax
80103ef9:	8b 00                	mov    (%eax),%eax
80103efb:	83 ec 0c             	sub    $0xc,%esp
80103efe:	50                   	push   %eax
80103eff:	e8 da d1 ff ff       	call   801010de <fileclose>
80103f04:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80103f07:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f0a:	8b 00                	mov    (%eax),%eax
80103f0c:	85 c0                	test   %eax,%eax
80103f0e:	74 11                	je     80103f21 <pipealloc+0x14b>
    fileclose(*f1);
80103f10:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f13:	8b 00                	mov    (%eax),%eax
80103f15:	83 ec 0c             	sub    $0xc,%esp
80103f18:	50                   	push   %eax
80103f19:	e8 c0 d1 ff ff       	call   801010de <fileclose>
80103f1e:	83 c4 10             	add    $0x10,%esp
  return -1;
80103f21:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103f26:	c9                   	leave  
80103f27:	c3                   	ret    

80103f28 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103f28:	55                   	push   %ebp
80103f29:	89 e5                	mov    %esp,%ebp
80103f2b:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80103f2e:	8b 45 08             	mov    0x8(%ebp),%eax
80103f31:	83 ec 0c             	sub    $0xc,%esp
80103f34:	50                   	push   %eax
80103f35:	e8 25 12 00 00       	call   8010515f <acquire>
80103f3a:	83 c4 10             	add    $0x10,%esp
  if(writable){
80103f3d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103f41:	74 23                	je     80103f66 <pipeclose+0x3e>
    p->writeopen = 0;
80103f43:	8b 45 08             	mov    0x8(%ebp),%eax
80103f46:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103f4d:	00 00 00 
    wakeup(&p->nread);
80103f50:	8b 45 08             	mov    0x8(%ebp),%eax
80103f53:	05 34 02 00 00       	add    $0x234,%eax
80103f58:	83 ec 0c             	sub    $0xc,%esp
80103f5b:	50                   	push   %eax
80103f5c:	e8 98 0d 00 00       	call   80104cf9 <wakeup>
80103f61:	83 c4 10             	add    $0x10,%esp
80103f64:	eb 21                	jmp    80103f87 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
80103f66:	8b 45 08             	mov    0x8(%ebp),%eax
80103f69:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103f70:	00 00 00 
    wakeup(&p->nwrite);
80103f73:	8b 45 08             	mov    0x8(%ebp),%eax
80103f76:	05 38 02 00 00       	add    $0x238,%eax
80103f7b:	83 ec 0c             	sub    $0xc,%esp
80103f7e:	50                   	push   %eax
80103f7f:	e8 75 0d 00 00       	call   80104cf9 <wakeup>
80103f84:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103f87:	8b 45 08             	mov    0x8(%ebp),%eax
80103f8a:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103f90:	85 c0                	test   %eax,%eax
80103f92:	75 2c                	jne    80103fc0 <pipeclose+0x98>
80103f94:	8b 45 08             	mov    0x8(%ebp),%eax
80103f97:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103f9d:	85 c0                	test   %eax,%eax
80103f9f:	75 1f                	jne    80103fc0 <pipeclose+0x98>
    release(&p->lock);
80103fa1:	8b 45 08             	mov    0x8(%ebp),%eax
80103fa4:	83 ec 0c             	sub    $0xc,%esp
80103fa7:	50                   	push   %eax
80103fa8:	e8 20 12 00 00       	call   801051cd <release>
80103fad:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80103fb0:	83 ec 0c             	sub    $0xc,%esp
80103fb3:	ff 75 08             	push   0x8(%ebp)
80103fb6:	e8 41 ec ff ff       	call   80102bfc <kfree>
80103fbb:	83 c4 10             	add    $0x10,%esp
80103fbe:	eb 10                	jmp    80103fd0 <pipeclose+0xa8>
  } else
    release(&p->lock);
80103fc0:	8b 45 08             	mov    0x8(%ebp),%eax
80103fc3:	83 ec 0c             	sub    $0xc,%esp
80103fc6:	50                   	push   %eax
80103fc7:	e8 01 12 00 00       	call   801051cd <release>
80103fcc:	83 c4 10             	add    $0x10,%esp
}
80103fcf:	90                   	nop
80103fd0:	90                   	nop
80103fd1:	c9                   	leave  
80103fd2:	c3                   	ret    

80103fd3 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103fd3:	55                   	push   %ebp
80103fd4:	89 e5                	mov    %esp,%ebp
80103fd6:	53                   	push   %ebx
80103fd7:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80103fda:	8b 45 08             	mov    0x8(%ebp),%eax
80103fdd:	83 ec 0c             	sub    $0xc,%esp
80103fe0:	50                   	push   %eax
80103fe1:	e8 79 11 00 00       	call   8010515f <acquire>
80103fe6:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80103fe9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103ff0:	e9 ad 00 00 00       	jmp    801040a2 <pipewrite+0xcf>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
80103ff5:	8b 45 08             	mov    0x8(%ebp),%eax
80103ff8:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103ffe:	85 c0                	test   %eax,%eax
80104000:	74 0c                	je     8010400e <pipewrite+0x3b>
80104002:	e8 92 02 00 00       	call   80104299 <myproc>
80104007:	8b 40 24             	mov    0x24(%eax),%eax
8010400a:	85 c0                	test   %eax,%eax
8010400c:	74 19                	je     80104027 <pipewrite+0x54>
        release(&p->lock);
8010400e:	8b 45 08             	mov    0x8(%ebp),%eax
80104011:	83 ec 0c             	sub    $0xc,%esp
80104014:	50                   	push   %eax
80104015:	e8 b3 11 00 00       	call   801051cd <release>
8010401a:	83 c4 10             	add    $0x10,%esp
        return -1;
8010401d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104022:	e9 a9 00 00 00       	jmp    801040d0 <pipewrite+0xfd>
      }
      wakeup(&p->nread);
80104027:	8b 45 08             	mov    0x8(%ebp),%eax
8010402a:	05 34 02 00 00       	add    $0x234,%eax
8010402f:	83 ec 0c             	sub    $0xc,%esp
80104032:	50                   	push   %eax
80104033:	e8 c1 0c 00 00       	call   80104cf9 <wakeup>
80104038:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010403b:	8b 45 08             	mov    0x8(%ebp),%eax
8010403e:	8b 55 08             	mov    0x8(%ebp),%edx
80104041:	81 c2 38 02 00 00    	add    $0x238,%edx
80104047:	83 ec 08             	sub    $0x8,%esp
8010404a:	50                   	push   %eax
8010404b:	52                   	push   %edx
8010404c:	e8 be 0b 00 00       	call   80104c0f <sleep>
80104051:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104054:	8b 45 08             	mov    0x8(%ebp),%eax
80104057:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
8010405d:	8b 45 08             	mov    0x8(%ebp),%eax
80104060:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104066:	05 00 02 00 00       	add    $0x200,%eax
8010406b:	39 c2                	cmp    %eax,%edx
8010406d:	74 86                	je     80103ff5 <pipewrite+0x22>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
8010406f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104072:	8b 45 0c             	mov    0xc(%ebp),%eax
80104075:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104078:	8b 45 08             	mov    0x8(%ebp),%eax
8010407b:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104081:	8d 48 01             	lea    0x1(%eax),%ecx
80104084:	8b 55 08             	mov    0x8(%ebp),%edx
80104087:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
8010408d:	25 ff 01 00 00       	and    $0x1ff,%eax
80104092:	89 c1                	mov    %eax,%ecx
80104094:	0f b6 13             	movzbl (%ebx),%edx
80104097:	8b 45 08             	mov    0x8(%ebp),%eax
8010409a:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
8010409e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801040a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040a5:	3b 45 10             	cmp    0x10(%ebp),%eax
801040a8:	7c aa                	jl     80104054 <pipewrite+0x81>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801040aa:	8b 45 08             	mov    0x8(%ebp),%eax
801040ad:	05 34 02 00 00       	add    $0x234,%eax
801040b2:	83 ec 0c             	sub    $0xc,%esp
801040b5:	50                   	push   %eax
801040b6:	e8 3e 0c 00 00       	call   80104cf9 <wakeup>
801040bb:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801040be:	8b 45 08             	mov    0x8(%ebp),%eax
801040c1:	83 ec 0c             	sub    $0xc,%esp
801040c4:	50                   	push   %eax
801040c5:	e8 03 11 00 00       	call   801051cd <release>
801040ca:	83 c4 10             	add    $0x10,%esp
  return n;
801040cd:	8b 45 10             	mov    0x10(%ebp),%eax
}
801040d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801040d3:	c9                   	leave  
801040d4:	c3                   	ret    

801040d5 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801040d5:	55                   	push   %ebp
801040d6:	89 e5                	mov    %esp,%ebp
801040d8:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
801040db:	8b 45 08             	mov    0x8(%ebp),%eax
801040de:	83 ec 0c             	sub    $0xc,%esp
801040e1:	50                   	push   %eax
801040e2:	e8 78 10 00 00       	call   8010515f <acquire>
801040e7:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801040ea:	eb 3e                	jmp    8010412a <piperead+0x55>
    if(myproc()->killed){
801040ec:	e8 a8 01 00 00       	call   80104299 <myproc>
801040f1:	8b 40 24             	mov    0x24(%eax),%eax
801040f4:	85 c0                	test   %eax,%eax
801040f6:	74 19                	je     80104111 <piperead+0x3c>
      release(&p->lock);
801040f8:	8b 45 08             	mov    0x8(%ebp),%eax
801040fb:	83 ec 0c             	sub    $0xc,%esp
801040fe:	50                   	push   %eax
801040ff:	e8 c9 10 00 00       	call   801051cd <release>
80104104:	83 c4 10             	add    $0x10,%esp
      return -1;
80104107:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010410c:	e9 be 00 00 00       	jmp    801041cf <piperead+0xfa>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104111:	8b 45 08             	mov    0x8(%ebp),%eax
80104114:	8b 55 08             	mov    0x8(%ebp),%edx
80104117:	81 c2 34 02 00 00    	add    $0x234,%edx
8010411d:	83 ec 08             	sub    $0x8,%esp
80104120:	50                   	push   %eax
80104121:	52                   	push   %edx
80104122:	e8 e8 0a 00 00       	call   80104c0f <sleep>
80104127:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010412a:	8b 45 08             	mov    0x8(%ebp),%eax
8010412d:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104133:	8b 45 08             	mov    0x8(%ebp),%eax
80104136:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010413c:	39 c2                	cmp    %eax,%edx
8010413e:	75 0d                	jne    8010414d <piperead+0x78>
80104140:	8b 45 08             	mov    0x8(%ebp),%eax
80104143:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104149:	85 c0                	test   %eax,%eax
8010414b:	75 9f                	jne    801040ec <piperead+0x17>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010414d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104154:	eb 48                	jmp    8010419e <piperead+0xc9>
    if(p->nread == p->nwrite)
80104156:	8b 45 08             	mov    0x8(%ebp),%eax
80104159:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010415f:	8b 45 08             	mov    0x8(%ebp),%eax
80104162:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104168:	39 c2                	cmp    %eax,%edx
8010416a:	74 3c                	je     801041a8 <piperead+0xd3>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
8010416c:	8b 45 08             	mov    0x8(%ebp),%eax
8010416f:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104175:	8d 48 01             	lea    0x1(%eax),%ecx
80104178:	8b 55 08             	mov    0x8(%ebp),%edx
8010417b:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104181:	25 ff 01 00 00       	and    $0x1ff,%eax
80104186:	89 c1                	mov    %eax,%ecx
80104188:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010418b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010418e:	01 c2                	add    %eax,%edx
80104190:	8b 45 08             	mov    0x8(%ebp),%eax
80104193:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
80104198:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010419a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010419e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041a1:	3b 45 10             	cmp    0x10(%ebp),%eax
801041a4:	7c b0                	jl     80104156 <piperead+0x81>
801041a6:	eb 01                	jmp    801041a9 <piperead+0xd4>
      break;
801041a8:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801041a9:	8b 45 08             	mov    0x8(%ebp),%eax
801041ac:	05 38 02 00 00       	add    $0x238,%eax
801041b1:	83 ec 0c             	sub    $0xc,%esp
801041b4:	50                   	push   %eax
801041b5:	e8 3f 0b 00 00       	call   80104cf9 <wakeup>
801041ba:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801041bd:	8b 45 08             	mov    0x8(%ebp),%eax
801041c0:	83 ec 0c             	sub    $0xc,%esp
801041c3:	50                   	push   %eax
801041c4:	e8 04 10 00 00       	call   801051cd <release>
801041c9:	83 c4 10             	add    $0x10,%esp
  return i;
801041cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801041cf:	c9                   	leave  
801041d0:	c3                   	ret    

801041d1 <readeflags>:
{
801041d1:	55                   	push   %ebp
801041d2:	89 e5                	mov    %esp,%ebp
801041d4:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801041d7:	9c                   	pushf  
801041d8:	58                   	pop    %eax
801041d9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801041dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801041df:	c9                   	leave  
801041e0:	c3                   	ret    

801041e1 <sti>:
{
801041e1:	55                   	push   %ebp
801041e2:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801041e4:	fb                   	sti    
}
801041e5:	90                   	nop
801041e6:	5d                   	pop    %ebp
801041e7:	c3                   	ret    

801041e8 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
801041e8:	55                   	push   %ebp
801041e9:	89 e5                	mov    %esp,%ebp
801041eb:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
801041ee:	83 ec 08             	sub    $0x8,%esp
801041f1:	68 bc 88 10 80       	push   $0x801088bc
801041f6:	68 60 2d 11 80       	push   $0x80112d60
801041fb:	e8 3d 0f 00 00       	call   8010513d <initlock>
80104200:	83 c4 10             	add    $0x10,%esp
}
80104203:	90                   	nop
80104204:	c9                   	leave  
80104205:	c3                   	ret    

80104206 <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80104206:	55                   	push   %ebp
80104207:	89 e5                	mov    %esp,%ebp
80104209:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
8010420c:	e8 10 00 00 00       	call   80104221 <mycpu>
80104211:	2d c0 27 11 80       	sub    $0x801127c0,%eax
80104216:	c1 f8 04             	sar    $0x4,%eax
80104219:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
8010421f:	c9                   	leave  
80104220:	c3                   	ret    

80104221 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80104221:	55                   	push   %ebp
80104222:	89 e5                	mov    %esp,%ebp
80104224:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF)
80104227:	e8 a5 ff ff ff       	call   801041d1 <readeflags>
8010422c:	25 00 02 00 00       	and    $0x200,%eax
80104231:	85 c0                	test   %eax,%eax
80104233:	74 0d                	je     80104242 <mycpu+0x21>
    panic("mycpu called with interrupts enabled\n");
80104235:	83 ec 0c             	sub    $0xc,%esp
80104238:	68 c4 88 10 80       	push   $0x801088c4
8010423d:	e8 73 c3 ff ff       	call   801005b5 <panic>
  
  apicid = lapicid();
80104242:	e8 a9 ed ff ff       	call   80102ff0 <lapicid>
80104247:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
8010424a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104251:	eb 2d                	jmp    80104280 <mycpu+0x5f>
    if (cpus[i].apicid == apicid)
80104253:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104256:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
8010425c:	05 c0 27 11 80       	add    $0x801127c0,%eax
80104261:	0f b6 00             	movzbl (%eax),%eax
80104264:	0f b6 c0             	movzbl %al,%eax
80104267:	39 45 f0             	cmp    %eax,-0x10(%ebp)
8010426a:	75 10                	jne    8010427c <mycpu+0x5b>
      return &cpus[i];
8010426c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010426f:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80104275:	05 c0 27 11 80       	add    $0x801127c0,%eax
8010427a:	eb 1b                	jmp    80104297 <mycpu+0x76>
  for (i = 0; i < ncpu; ++i) {
8010427c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104280:	a1 40 2d 11 80       	mov    0x80112d40,%eax
80104285:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80104288:	7c c9                	jl     80104253 <mycpu+0x32>
  }
  panic("unknown apicid\n");
8010428a:	83 ec 0c             	sub    $0xc,%esp
8010428d:	68 ea 88 10 80       	push   $0x801088ea
80104292:	e8 1e c3 ff ff       	call   801005b5 <panic>
}
80104297:	c9                   	leave  
80104298:	c3                   	ret    

80104299 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80104299:	55                   	push   %ebp
8010429a:	89 e5                	mov    %esp,%ebp
8010429c:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
8010429f:	e8 36 10 00 00       	call   801052da <pushcli>
  c = mycpu();
801042a4:	e8 78 ff ff ff       	call   80104221 <mycpu>
801042a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
801042ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042af:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801042b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
801042b8:	e8 6a 10 00 00       	call   80105327 <popcli>
  return p;
801042bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801042c0:	c9                   	leave  
801042c1:	c3                   	ret    

801042c2 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
801042c2:	55                   	push   %ebp
801042c3:	89 e5                	mov    %esp,%ebp
801042c5:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
801042c8:	83 ec 0c             	sub    $0xc,%esp
801042cb:	68 60 2d 11 80       	push   $0x80112d60
801042d0:	e8 8a 0e 00 00       	call   8010515f <acquire>
801042d5:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801042d8:	c7 45 f4 94 2d 11 80 	movl   $0x80112d94,-0xc(%ebp)
801042df:	eb 11                	jmp    801042f2 <allocproc+0x30>
    if(p->state == UNUSED)
801042e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042e4:	8b 40 0c             	mov    0xc(%eax),%eax
801042e7:	85 c0                	test   %eax,%eax
801042e9:	74 2a                	je     80104315 <allocproc+0x53>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801042eb:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
801042f2:	81 7d f4 94 51 11 80 	cmpl   $0x80115194,-0xc(%ebp)
801042f9:	72 e6                	jb     801042e1 <allocproc+0x1f>
      goto found;

  release(&ptable.lock);
801042fb:	83 ec 0c             	sub    $0xc,%esp
801042fe:	68 60 2d 11 80       	push   $0x80112d60
80104303:	e8 c5 0e 00 00       	call   801051cd <release>
80104308:	83 c4 10             	add    $0x10,%esp
  return 0;
8010430b:	b8 00 00 00 00       	mov    $0x0,%eax
80104310:	e9 c9 00 00 00       	jmp    801043de <allocproc+0x11c>
      goto found;
80104315:	90                   	nop

found:
  p->state = EMBRYO;
80104316:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104319:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104320:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80104325:	8d 50 01             	lea    0x1(%eax),%edx
80104328:	89 15 00 b0 10 80    	mov    %edx,0x8010b000
8010432e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104331:	89 42 10             	mov    %eax,0x10(%edx)
  p->priority = 0;
80104334:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104337:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
8010433e:	00 00 00 
  p->nice_value = 0;
80104341:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104344:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)




  release(&ptable.lock);
8010434b:	83 ec 0c             	sub    $0xc,%esp
8010434e:	68 60 2d 11 80       	push   $0x80112d60
80104353:	e8 75 0e 00 00       	call   801051cd <release>
80104358:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
8010435b:	e8 36 e9 ff ff       	call   80102c96 <kalloc>
80104360:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104363:	89 42 08             	mov    %eax,0x8(%edx)
80104366:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104369:	8b 40 08             	mov    0x8(%eax),%eax
8010436c:	85 c0                	test   %eax,%eax
8010436e:	75 11                	jne    80104381 <allocproc+0xbf>
    p->state = UNUSED;
80104370:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104373:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
8010437a:	b8 00 00 00 00       	mov    $0x0,%eax
8010437f:	eb 5d                	jmp    801043de <allocproc+0x11c>
  }
  sp = p->kstack + KSTACKSIZE;
80104381:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104384:	8b 40 08             	mov    0x8(%eax),%eax
80104387:	05 00 10 00 00       	add    $0x1000,%eax
8010438c:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
8010438f:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104393:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104396:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104399:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
8010439c:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
801043a0:	ba 06 68 10 80       	mov    $0x80106806,%edx
801043a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043a8:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
801043aa:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
801043ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043b1:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043b4:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
801043b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ba:	8b 40 1c             	mov    0x1c(%eax),%eax
801043bd:	83 ec 04             	sub    $0x4,%esp
801043c0:	6a 14                	push   $0x14
801043c2:	6a 00                	push   $0x0
801043c4:	50                   	push   %eax
801043c5:	e8 1b 10 00 00       	call   801053e5 <memset>
801043ca:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
801043cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043d0:	8b 40 1c             	mov    0x1c(%eax),%eax
801043d3:	ba c9 4b 10 80       	mov    $0x80104bc9,%edx
801043d8:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
801043db:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801043de:	c9                   	leave  
801043df:	c3                   	ret    

801043e0 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801043e0:	55                   	push   %ebp
801043e1:	89 e5                	mov    %esp,%ebp
801043e3:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
801043e6:	e8 d7 fe ff ff       	call   801042c2 <allocproc>
801043eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
801043ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043f1:	a3 94 51 11 80       	mov    %eax,0x80115194
  if((p->pgdir = setupkvm()) == 0)
801043f6:	e8 54 39 00 00       	call   80107d4f <setupkvm>
801043fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043fe:	89 42 04             	mov    %eax,0x4(%edx)
80104401:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104404:	8b 40 04             	mov    0x4(%eax),%eax
80104407:	85 c0                	test   %eax,%eax
80104409:	75 0d                	jne    80104418 <userinit+0x38>
    panic("userinit: out of memory?");
8010440b:	83 ec 0c             	sub    $0xc,%esp
8010440e:	68 fa 88 10 80       	push   $0x801088fa
80104413:	e8 9d c1 ff ff       	call   801005b5 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104418:	ba 2c 00 00 00       	mov    $0x2c,%edx
8010441d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104420:	8b 40 04             	mov    0x4(%eax),%eax
80104423:	83 ec 04             	sub    $0x4,%esp
80104426:	52                   	push   %edx
80104427:	68 c0 b4 10 80       	push   $0x8010b4c0
8010442c:	50                   	push   %eax
8010442d:	e8 86 3b 00 00       	call   80107fb8 <inituvm>
80104432:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80104435:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104438:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
8010443e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104441:	8b 40 18             	mov    0x18(%eax),%eax
80104444:	83 ec 04             	sub    $0x4,%esp
80104447:	6a 4c                	push   $0x4c
80104449:	6a 00                	push   $0x0
8010444b:	50                   	push   %eax
8010444c:	e8 94 0f 00 00       	call   801053e5 <memset>
80104451:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104454:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104457:	8b 40 18             	mov    0x18(%eax),%eax
8010445a:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104460:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104463:	8b 40 18             	mov    0x18(%eax),%eax
80104466:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010446c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010446f:	8b 50 18             	mov    0x18(%eax),%edx
80104472:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104475:	8b 40 18             	mov    0x18(%eax),%eax
80104478:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010447c:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104480:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104483:	8b 50 18             	mov    0x18(%eax),%edx
80104486:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104489:	8b 40 18             	mov    0x18(%eax),%eax
8010448c:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104490:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104494:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104497:	8b 40 18             	mov    0x18(%eax),%eax
8010449a:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801044a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044a4:	8b 40 18             	mov    0x18(%eax),%eax
801044a7:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801044ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044b1:	8b 40 18             	mov    0x18(%eax),%eax
801044b4:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
801044bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044be:	83 c0 6c             	add    $0x6c,%eax
801044c1:	83 ec 04             	sub    $0x4,%esp
801044c4:	6a 10                	push   $0x10
801044c6:	68 13 89 10 80       	push   $0x80108913
801044cb:	50                   	push   %eax
801044cc:	e8 17 11 00 00       	call   801055e8 <safestrcpy>
801044d1:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
801044d4:	83 ec 0c             	sub    $0xc,%esp
801044d7:	68 1c 89 10 80       	push   $0x8010891c
801044dc:	e8 6c e0 ff ff       	call   8010254d <namei>
801044e1:	83 c4 10             	add    $0x10,%esp
801044e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044e7:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
801044ea:	83 ec 0c             	sub    $0xc,%esp
801044ed:	68 60 2d 11 80       	push   $0x80112d60
801044f2:	e8 68 0c 00 00       	call   8010515f <acquire>
801044f7:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
801044fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044fd:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104504:	83 ec 0c             	sub    $0xc,%esp
80104507:	68 60 2d 11 80       	push   $0x80112d60
8010450c:	e8 bc 0c 00 00       	call   801051cd <release>
80104511:	83 c4 10             	add    $0x10,%esp
}
80104514:	90                   	nop
80104515:	c9                   	leave  
80104516:	c3                   	ret    

80104517 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104517:	55                   	push   %ebp
80104518:	89 e5                	mov    %esp,%ebp
8010451a:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
8010451d:	e8 77 fd ff ff       	call   80104299 <myproc>
80104522:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80104525:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104528:	8b 00                	mov    (%eax),%eax
8010452a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
8010452d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104531:	7e 2e                	jle    80104561 <growproc+0x4a>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104533:	8b 55 08             	mov    0x8(%ebp),%edx
80104536:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104539:	01 c2                	add    %eax,%edx
8010453b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010453e:	8b 40 04             	mov    0x4(%eax),%eax
80104541:	83 ec 04             	sub    $0x4,%esp
80104544:	52                   	push   %edx
80104545:	ff 75 f4             	push   -0xc(%ebp)
80104548:	50                   	push   %eax
80104549:	e8 a7 3b 00 00       	call   801080f5 <allocuvm>
8010454e:	83 c4 10             	add    $0x10,%esp
80104551:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104554:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104558:	75 3b                	jne    80104595 <growproc+0x7e>
      return -1;
8010455a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010455f:	eb 4f                	jmp    801045b0 <growproc+0x99>
  } else if(n < 0){
80104561:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104565:	79 2e                	jns    80104595 <growproc+0x7e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104567:	8b 55 08             	mov    0x8(%ebp),%edx
8010456a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010456d:	01 c2                	add    %eax,%edx
8010456f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104572:	8b 40 04             	mov    0x4(%eax),%eax
80104575:	83 ec 04             	sub    $0x4,%esp
80104578:	52                   	push   %edx
80104579:	ff 75 f4             	push   -0xc(%ebp)
8010457c:	50                   	push   %eax
8010457d:	e8 78 3c 00 00       	call   801081fa <deallocuvm>
80104582:	83 c4 10             	add    $0x10,%esp
80104585:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104588:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010458c:	75 07                	jne    80104595 <growproc+0x7e>
      return -1;
8010458e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104593:	eb 1b                	jmp    801045b0 <growproc+0x99>
  }
  curproc->sz = sz;
80104595:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104598:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010459b:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
8010459d:	83 ec 0c             	sub    $0xc,%esp
801045a0:	ff 75 f0             	push   -0x10(%ebp)
801045a3:	e8 71 38 00 00       	call   80107e19 <switchuvm>
801045a8:	83 c4 10             	add    $0x10,%esp
  return 0;
801045ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
801045b0:	c9                   	leave  
801045b1:	c3                   	ret    

801045b2 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
801045b2:	55                   	push   %ebp
801045b3:	89 e5                	mov    %esp,%ebp
801045b5:	57                   	push   %edi
801045b6:	56                   	push   %esi
801045b7:	53                   	push   %ebx
801045b8:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
801045bb:	e8 d9 fc ff ff       	call   80104299 <myproc>
801045c0:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
801045c3:	e8 fa fc ff ff       	call   801042c2 <allocproc>
801045c8:	89 45 dc             	mov    %eax,-0x24(%ebp)
801045cb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
801045cf:	75 0a                	jne    801045db <fork+0x29>
    return -1;
801045d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045d6:	e9 48 01 00 00       	jmp    80104723 <fork+0x171>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
801045db:	8b 45 e0             	mov    -0x20(%ebp),%eax
801045de:	8b 10                	mov    (%eax),%edx
801045e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801045e3:	8b 40 04             	mov    0x4(%eax),%eax
801045e6:	83 ec 08             	sub    $0x8,%esp
801045e9:	52                   	push   %edx
801045ea:	50                   	push   %eax
801045eb:	e8 a8 3d 00 00       	call   80108398 <copyuvm>
801045f0:	83 c4 10             	add    $0x10,%esp
801045f3:	8b 55 dc             	mov    -0x24(%ebp),%edx
801045f6:	89 42 04             	mov    %eax,0x4(%edx)
801045f9:	8b 45 dc             	mov    -0x24(%ebp),%eax
801045fc:	8b 40 04             	mov    0x4(%eax),%eax
801045ff:	85 c0                	test   %eax,%eax
80104601:	75 30                	jne    80104633 <fork+0x81>
    kfree(np->kstack);
80104603:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104606:	8b 40 08             	mov    0x8(%eax),%eax
80104609:	83 ec 0c             	sub    $0xc,%esp
8010460c:	50                   	push   %eax
8010460d:	e8 ea e5 ff ff       	call   80102bfc <kfree>
80104612:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80104615:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104618:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
8010461f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104622:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104629:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010462e:	e9 f0 00 00 00       	jmp    80104723 <fork+0x171>
  }
  np->sz = curproc->sz;
80104633:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104636:	8b 10                	mov    (%eax),%edx
80104638:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010463b:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
8010463d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104640:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104643:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80104646:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104649:	8b 48 18             	mov    0x18(%eax),%ecx
8010464c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010464f:	8b 40 18             	mov    0x18(%eax),%eax
80104652:	89 c2                	mov    %eax,%edx
80104654:	89 cb                	mov    %ecx,%ebx
80104656:	b8 13 00 00 00       	mov    $0x13,%eax
8010465b:	89 d7                	mov    %edx,%edi
8010465d:	89 de                	mov    %ebx,%esi
8010465f:	89 c1                	mov    %eax,%ecx
80104661:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104663:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104666:	8b 40 18             	mov    0x18(%eax),%eax
80104669:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104670:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104677:	eb 3b                	jmp    801046b4 <fork+0x102>
    if(curproc->ofile[i])
80104679:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010467c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010467f:	83 c2 08             	add    $0x8,%edx
80104682:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104686:	85 c0                	test   %eax,%eax
80104688:	74 26                	je     801046b0 <fork+0xfe>
      np->ofile[i] = filedup(curproc->ofile[i]);
8010468a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010468d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104690:	83 c2 08             	add    $0x8,%edx
80104693:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104697:	83 ec 0c             	sub    $0xc,%esp
8010469a:	50                   	push   %eax
8010469b:	e8 ed c9 ff ff       	call   8010108d <filedup>
801046a0:	83 c4 10             	add    $0x10,%esp
801046a3:	8b 55 dc             	mov    -0x24(%ebp),%edx
801046a6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801046a9:	83 c1 08             	add    $0x8,%ecx
801046ac:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
801046b0:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801046b4:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801046b8:	7e bf                	jle    80104679 <fork+0xc7>
  np->cwd = idup(curproc->cwd);
801046ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046bd:	8b 40 68             	mov    0x68(%eax),%eax
801046c0:	83 ec 0c             	sub    $0xc,%esp
801046c3:	50                   	push   %eax
801046c4:	e8 17 d3 ff ff       	call   801019e0 <idup>
801046c9:	83 c4 10             	add    $0x10,%esp
801046cc:	8b 55 dc             	mov    -0x24(%ebp),%edx
801046cf:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
801046d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046d5:	8d 50 6c             	lea    0x6c(%eax),%edx
801046d8:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046db:	83 c0 6c             	add    $0x6c,%eax
801046de:	83 ec 04             	sub    $0x4,%esp
801046e1:	6a 10                	push   $0x10
801046e3:	52                   	push   %edx
801046e4:	50                   	push   %eax
801046e5:	e8 fe 0e 00 00       	call   801055e8 <safestrcpy>
801046ea:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
801046ed:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046f0:	8b 40 10             	mov    0x10(%eax),%eax
801046f3:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
801046f6:	83 ec 0c             	sub    $0xc,%esp
801046f9:	68 60 2d 11 80       	push   $0x80112d60
801046fe:	e8 5c 0a 00 00       	call   8010515f <acquire>
80104703:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80104706:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104709:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104710:	83 ec 0c             	sub    $0xc,%esp
80104713:	68 60 2d 11 80       	push   $0x80112d60
80104718:	e8 b0 0a 00 00       	call   801051cd <release>
8010471d:	83 c4 10             	add    $0x10,%esp

  return pid;
80104720:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80104723:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104726:	5b                   	pop    %ebx
80104727:	5e                   	pop    %esi
80104728:	5f                   	pop    %edi
80104729:	5d                   	pop    %ebp
8010472a:	c3                   	ret    

8010472b <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
8010472b:	55                   	push   %ebp
8010472c:	89 e5                	mov    %esp,%ebp
8010472e:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104731:	e8 63 fb ff ff       	call   80104299 <myproc>
80104736:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80104739:	a1 94 51 11 80       	mov    0x80115194,%eax
8010473e:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104741:	75 0d                	jne    80104750 <exit+0x25>
    panic("init exiting");
80104743:	83 ec 0c             	sub    $0xc,%esp
80104746:	68 1e 89 10 80       	push   $0x8010891e
8010474b:	e8 65 be ff ff       	call   801005b5 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104750:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104757:	eb 3f                	jmp    80104798 <exit+0x6d>
    if(curproc->ofile[fd]){
80104759:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010475c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010475f:	83 c2 08             	add    $0x8,%edx
80104762:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104766:	85 c0                	test   %eax,%eax
80104768:	74 2a                	je     80104794 <exit+0x69>
      fileclose(curproc->ofile[fd]);
8010476a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010476d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104770:	83 c2 08             	add    $0x8,%edx
80104773:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104777:	83 ec 0c             	sub    $0xc,%esp
8010477a:	50                   	push   %eax
8010477b:	e8 5e c9 ff ff       	call   801010de <fileclose>
80104780:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80104783:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104786:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104789:	83 c2 08             	add    $0x8,%edx
8010478c:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104793:	00 
  for(fd = 0; fd < NOFILE; fd++){
80104794:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104798:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
8010479c:	7e bb                	jle    80104759 <exit+0x2e>
    }
  }

  begin_op();
8010479e:	e8 8f ed ff ff       	call   80103532 <begin_op>
  iput(curproc->cwd);
801047a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047a6:	8b 40 68             	mov    0x68(%eax),%eax
801047a9:	83 ec 0c             	sub    $0xc,%esp
801047ac:	50                   	push   %eax
801047ad:	e8 c9 d3 ff ff       	call   80101b7b <iput>
801047b2:	83 c4 10             	add    $0x10,%esp
  end_op();
801047b5:	e8 04 ee ff ff       	call   801035be <end_op>
  curproc->cwd = 0;
801047ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047bd:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801047c4:	83 ec 0c             	sub    $0xc,%esp
801047c7:	68 60 2d 11 80       	push   $0x80112d60
801047cc:	e8 8e 09 00 00       	call   8010515f <acquire>
801047d1:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
801047d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047d7:	8b 40 14             	mov    0x14(%eax),%eax
801047da:	83 ec 0c             	sub    $0xc,%esp
801047dd:	50                   	push   %eax
801047de:	e8 d3 04 00 00       	call   80104cb6 <wakeup1>
801047e3:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801047e6:	c7 45 f4 94 2d 11 80 	movl   $0x80112d94,-0xc(%ebp)
801047ed:	eb 3a                	jmp    80104829 <exit+0xfe>
    if(p->parent == curproc){
801047ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047f2:	8b 40 14             	mov    0x14(%eax),%eax
801047f5:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801047f8:	75 28                	jne    80104822 <exit+0xf7>
      p->parent = initproc;
801047fa:	8b 15 94 51 11 80    	mov    0x80115194,%edx
80104800:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104803:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104806:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104809:	8b 40 0c             	mov    0xc(%eax),%eax
8010480c:	83 f8 05             	cmp    $0x5,%eax
8010480f:	75 11                	jne    80104822 <exit+0xf7>
        wakeup1(initproc);
80104811:	a1 94 51 11 80       	mov    0x80115194,%eax
80104816:	83 ec 0c             	sub    $0xc,%esp
80104819:	50                   	push   %eax
8010481a:	e8 97 04 00 00       	call   80104cb6 <wakeup1>
8010481f:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104822:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80104829:	81 7d f4 94 51 11 80 	cmpl   $0x80115194,-0xc(%ebp)
80104830:	72 bd                	jb     801047ef <exit+0xc4>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104832:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104835:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
8010483c:	e8 95 02 00 00       	call   80104ad6 <sched>
  panic("zombie exit");
80104841:	83 ec 0c             	sub    $0xc,%esp
80104844:	68 2b 89 10 80       	push   $0x8010892b
80104849:	e8 67 bd ff ff       	call   801005b5 <panic>

8010484e <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
8010484e:	55                   	push   %ebp
8010484f:	89 e5                	mov    %esp,%ebp
80104851:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80104854:	e8 40 fa ff ff       	call   80104299 <myproc>
80104859:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
8010485c:	83 ec 0c             	sub    $0xc,%esp
8010485f:	68 60 2d 11 80       	push   $0x80112d60
80104864:	e8 f6 08 00 00       	call   8010515f <acquire>
80104869:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
8010486c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104873:	c7 45 f4 94 2d 11 80 	movl   $0x80112d94,-0xc(%ebp)
8010487a:	e9 a4 00 00 00       	jmp    80104923 <wait+0xd5>
      if(p->parent != curproc)
8010487f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104882:	8b 40 14             	mov    0x14(%eax),%eax
80104885:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104888:	0f 85 8d 00 00 00    	jne    8010491b <wait+0xcd>
        continue;
      havekids = 1;
8010488e:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104895:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104898:	8b 40 0c             	mov    0xc(%eax),%eax
8010489b:	83 f8 05             	cmp    $0x5,%eax
8010489e:	75 7c                	jne    8010491c <wait+0xce>
        // Found one.
        pid = p->pid;
801048a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048a3:	8b 40 10             	mov    0x10(%eax),%eax
801048a6:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
801048a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048ac:	8b 40 08             	mov    0x8(%eax),%eax
801048af:	83 ec 0c             	sub    $0xc,%esp
801048b2:	50                   	push   %eax
801048b3:	e8 44 e3 ff ff       	call   80102bfc <kfree>
801048b8:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
801048bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048be:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801048c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048c8:	8b 40 04             	mov    0x4(%eax),%eax
801048cb:	83 ec 0c             	sub    $0xc,%esp
801048ce:	50                   	push   %eax
801048cf:	e8 ea 39 00 00       	call   801082be <freevm>
801048d4:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
801048d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048da:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801048e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048e4:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801048eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048ee:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
801048f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048f5:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
801048fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048ff:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104906:	83 ec 0c             	sub    $0xc,%esp
80104909:	68 60 2d 11 80       	push   $0x80112d60
8010490e:	e8 ba 08 00 00       	call   801051cd <release>
80104913:	83 c4 10             	add    $0x10,%esp
        return pid;
80104916:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104919:	eb 54                	jmp    8010496f <wait+0x121>
        continue;
8010491b:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010491c:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80104923:	81 7d f4 94 51 11 80 	cmpl   $0x80115194,-0xc(%ebp)
8010492a:	0f 82 4f ff ff ff    	jb     8010487f <wait+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104930:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104934:	74 0a                	je     80104940 <wait+0xf2>
80104936:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104939:	8b 40 24             	mov    0x24(%eax),%eax
8010493c:	85 c0                	test   %eax,%eax
8010493e:	74 17                	je     80104957 <wait+0x109>
      release(&ptable.lock);
80104940:	83 ec 0c             	sub    $0xc,%esp
80104943:	68 60 2d 11 80       	push   $0x80112d60
80104948:	e8 80 08 00 00       	call   801051cd <release>
8010494d:	83 c4 10             	add    $0x10,%esp
      return -1;
80104950:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104955:	eb 18                	jmp    8010496f <wait+0x121>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104957:	83 ec 08             	sub    $0x8,%esp
8010495a:	68 60 2d 11 80       	push   $0x80112d60
8010495f:	ff 75 ec             	push   -0x14(%ebp)
80104962:	e8 a8 02 00 00       	call   80104c0f <sleep>
80104967:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
8010496a:	e9 fd fe ff ff       	jmp    8010486c <wait+0x1e>
  }
}
8010496f:	c9                   	leave  
80104970:	c3                   	ret    

80104971 <decay>:

int
decay(int cpu)
{
80104971:	55                   	push   %ebp
80104972:	89 e5                	mov    %esp,%ebp
 return cpu/2;
80104974:	8b 45 08             	mov    0x8(%ebp),%eax
80104977:	89 c2                	mov    %eax,%edx
80104979:	c1 ea 1f             	shr    $0x1f,%edx
8010497c:	01 d0                	add    %edx,%eax
8010497e:	d1 f8                	sar    %eax
}
80104980:	5d                   	pop    %ebp
80104981:	c3                   	ret    

80104982 <scheduler>:
//  - eventually that process transfers control
//      via swtch back to the scheduler.

void
scheduler(void)
{
80104982:	55                   	push   %ebp
80104983:	89 e5                	mov    %esp,%ebp
80104985:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104988:	e8 94 f8 ff ff       	call   80104221 <mycpu>
8010498d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  c->proc = 0;
80104990:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104993:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010499a:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
8010499d:	e8 3f f8 ff ff       	call   801041e1 <sti>
    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
801049a2:	83 ec 0c             	sub    $0xc,%esp
801049a5:	68 60 2d 11 80       	push   $0x80112d60
801049aa:	e8 b0 07 00 00       	call   8010515f <acquire>
801049af:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049b2:	c7 45 f4 94 2d 11 80 	movl   $0x80112d94,-0xc(%ebp)
801049b9:	e9 f6 00 00 00       	jmp    80104ab4 <scheduler+0x132>
      if(p->state != RUNNABLE)
801049be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049c1:	8b 40 0c             	mov    0xc(%eax),%eax
801049c4:	83 f8 03             	cmp    $0x3,%eax
801049c7:	0f 85 df 00 00 00    	jne    80104aac <scheduler+0x12a>

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.

      if(p == myproc()){
801049cd:	e8 c7 f8 ff ff       	call   80104299 <myproc>
801049d2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801049d5:	75 15                	jne    801049ec <scheduler+0x6a>
        p->ticks++;
801049d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049da:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
801049e0:	8d 50 01             	lea    0x1(%eax),%edx
801049e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049e6:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
      }

      uint current_ticks = ticks;
801049ec:	a1 d4 59 11 80       	mov    0x801159d4,%eax
801049f1:	89 45 e8             	mov    %eax,-0x18(%ebp)
      uint time_since_decay = current_ticks - p->last_decay;
801049f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049f7:	8b 90 88 00 00 00    	mov    0x88(%eax),%edx
801049fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104a00:	29 d0                	sub    %edx,%eax
80104a02:	89 45 f0             	mov    %eax,-0x10(%ebp)

      while (time_since_decay % 100 == 0) {
80104a05:	eb 1a                	jmp    80104a21 <scheduler+0x9f>
        p->adjusted_ticks /= 2;
80104a07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a0a:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80104a10:	d1 e8                	shr    %eax
80104a12:	89 c2                	mov    %eax,%edx
80104a14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a17:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
        time_since_decay -= 100;
80104a1d:	83 6d f0 64          	subl   $0x64,-0x10(%ebp)
      while (time_since_decay % 100 == 0) {
80104a21:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104a24:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
80104a29:	89 c8                	mov    %ecx,%eax
80104a2b:	f7 e2                	mul    %edx
80104a2d:	89 d0                	mov    %edx,%eax
80104a2f:	c1 e8 05             	shr    $0x5,%eax
80104a32:	6b d0 64             	imul   $0x64,%eax,%edx
80104a35:	89 c8                	mov    %ecx,%eax
80104a37:	29 d0                	sub    %edx,%eax
80104a39:	85 c0                	test   %eax,%eax
80104a3b:	74 ca                	je     80104a07 <scheduler+0x85>
      }

      p->last_decay = p->adjusted_ticks/2 + p->nice_value;
80104a3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a40:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80104a46:	d1 e8                	shr    %eax
80104a48:	89 c2                	mov    %eax,%edx
80104a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a4d:	8b 40 7c             	mov    0x7c(%eax),%eax
80104a50:	01 c2                	add    %eax,%edx
80104a52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a55:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)

      c->proc = p;
80104a5b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a5e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a61:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104a67:	83 ec 0c             	sub    $0xc,%esp
80104a6a:	ff 75 f4             	push   -0xc(%ebp)
80104a6d:	e8 a7 33 00 00       	call   80107e19 <switchuvm>
80104a72:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104a75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a78:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a82:	8b 40 1c             	mov    0x1c(%eax),%eax
80104a85:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104a88:	83 c2 04             	add    $0x4,%edx
80104a8b:	83 ec 08             	sub    $0x8,%esp
80104a8e:	50                   	push   %eax
80104a8f:	52                   	push   %edx
80104a90:	e8 c5 0b 00 00       	call   8010565a <swtch>
80104a95:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104a98:	e8 63 33 00 00       	call   80107e00 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104a9d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104aa0:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104aa7:	00 00 00 
80104aaa:	eb 01                	jmp    80104aad <scheduler+0x12b>
        continue;
80104aac:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104aad:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80104ab4:	81 7d f4 94 51 11 80 	cmpl   $0x80115194,-0xc(%ebp)
80104abb:	0f 82 fd fe ff ff    	jb     801049be <scheduler+0x3c>
    }
    release(&ptable.lock);
80104ac1:	83 ec 0c             	sub    $0xc,%esp
80104ac4:	68 60 2d 11 80       	push   $0x80112d60
80104ac9:	e8 ff 06 00 00       	call   801051cd <release>
80104ace:	83 c4 10             	add    $0x10,%esp
    sti();
80104ad1:	e9 c7 fe ff ff       	jmp    8010499d <scheduler+0x1b>

80104ad6 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104ad6:	55                   	push   %ebp
80104ad7:	89 e5                	mov    %esp,%ebp
80104ad9:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104adc:	e8 b8 f7 ff ff       	call   80104299 <myproc>
80104ae1:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104ae4:	83 ec 0c             	sub    $0xc,%esp
80104ae7:	68 60 2d 11 80       	push   $0x80112d60
80104aec:	e8 a9 07 00 00       	call   8010529a <holding>
80104af1:	83 c4 10             	add    $0x10,%esp
80104af4:	85 c0                	test   %eax,%eax
80104af6:	75 0d                	jne    80104b05 <sched+0x2f>
    panic("sched ptable.lock");
80104af8:	83 ec 0c             	sub    $0xc,%esp
80104afb:	68 37 89 10 80       	push   $0x80108937
80104b00:	e8 b0 ba ff ff       	call   801005b5 <panic>
  if(mycpu()->ncli != 1)
80104b05:	e8 17 f7 ff ff       	call   80104221 <mycpu>
80104b0a:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104b10:	83 f8 01             	cmp    $0x1,%eax
80104b13:	74 0d                	je     80104b22 <sched+0x4c>
    panic("sched locks");
80104b15:	83 ec 0c             	sub    $0xc,%esp
80104b18:	68 49 89 10 80       	push   $0x80108949
80104b1d:	e8 93 ba ff ff       	call   801005b5 <panic>
  if(p->state == RUNNING)
80104b22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b25:	8b 40 0c             	mov    0xc(%eax),%eax
80104b28:	83 f8 04             	cmp    $0x4,%eax
80104b2b:	75 0d                	jne    80104b3a <sched+0x64>
    panic("sched running");
80104b2d:	83 ec 0c             	sub    $0xc,%esp
80104b30:	68 55 89 10 80       	push   $0x80108955
80104b35:	e8 7b ba ff ff       	call   801005b5 <panic>
  if(readeflags()&FL_IF)
80104b3a:	e8 92 f6 ff ff       	call   801041d1 <readeflags>
80104b3f:	25 00 02 00 00       	and    $0x200,%eax
80104b44:	85 c0                	test   %eax,%eax
80104b46:	74 0d                	je     80104b55 <sched+0x7f>
    panic("sched interruptible");
80104b48:	83 ec 0c             	sub    $0xc,%esp
80104b4b:	68 63 89 10 80       	push   $0x80108963
80104b50:	e8 60 ba ff ff       	call   801005b5 <panic>
  intena = mycpu()->intena;
80104b55:	e8 c7 f6 ff ff       	call   80104221 <mycpu>
80104b5a:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104b60:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104b63:	e8 b9 f6 ff ff       	call   80104221 <mycpu>
80104b68:	8b 40 04             	mov    0x4(%eax),%eax
80104b6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104b6e:	83 c2 1c             	add    $0x1c,%edx
80104b71:	83 ec 08             	sub    $0x8,%esp
80104b74:	50                   	push   %eax
80104b75:	52                   	push   %edx
80104b76:	e8 df 0a 00 00       	call   8010565a <swtch>
80104b7b:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104b7e:	e8 9e f6 ff ff       	call   80104221 <mycpu>
80104b83:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104b86:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104b8c:	90                   	nop
80104b8d:	c9                   	leave  
80104b8e:	c3                   	ret    

80104b8f <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104b8f:	55                   	push   %ebp
80104b90:	89 e5                	mov    %esp,%ebp
80104b92:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104b95:	83 ec 0c             	sub    $0xc,%esp
80104b98:	68 60 2d 11 80       	push   $0x80112d60
80104b9d:	e8 bd 05 00 00       	call   8010515f <acquire>
80104ba2:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104ba5:	e8 ef f6 ff ff       	call   80104299 <myproc>
80104baa:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  // if (ticks % 100 == 0){
  //   recalculate_priority(); //nice system call
  // }

  sched();
80104bb1:	e8 20 ff ff ff       	call   80104ad6 <sched>
  release(&ptable.lock);
80104bb6:	83 ec 0c             	sub    $0xc,%esp
80104bb9:	68 60 2d 11 80       	push   $0x80112d60
80104bbe:	e8 0a 06 00 00       	call   801051cd <release>
80104bc3:	83 c4 10             	add    $0x10,%esp
}
80104bc6:	90                   	nop
80104bc7:	c9                   	leave  
80104bc8:	c3                   	ret    

80104bc9 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104bc9:	55                   	push   %ebp
80104bca:	89 e5                	mov    %esp,%ebp
80104bcc:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104bcf:	83 ec 0c             	sub    $0xc,%esp
80104bd2:	68 60 2d 11 80       	push   $0x80112d60
80104bd7:	e8 f1 05 00 00       	call   801051cd <release>
80104bdc:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104bdf:	a1 04 b0 10 80       	mov    0x8010b004,%eax
80104be4:	85 c0                	test   %eax,%eax
80104be6:	74 24                	je     80104c0c <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104be8:	c7 05 04 b0 10 80 00 	movl   $0x0,0x8010b004
80104bef:	00 00 00 
    iinit(ROOTDEV);
80104bf2:	83 ec 0c             	sub    $0xc,%esp
80104bf5:	6a 01                	push   $0x1
80104bf7:	e8 ac ca ff ff       	call   801016a8 <iinit>
80104bfc:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104bff:	83 ec 0c             	sub    $0xc,%esp
80104c02:	6a 01                	push   $0x1
80104c04:	e8 0a e7 ff ff       	call   80103313 <initlog>
80104c09:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104c0c:	90                   	nop
80104c0d:	c9                   	leave  
80104c0e:	c3                   	ret    

80104c0f <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104c0f:	55                   	push   %ebp
80104c10:	89 e5                	mov    %esp,%ebp
80104c12:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80104c15:	e8 7f f6 ff ff       	call   80104299 <myproc>
80104c1a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104c1d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104c21:	75 0d                	jne    80104c30 <sleep+0x21>
    panic("sleep");
80104c23:	83 ec 0c             	sub    $0xc,%esp
80104c26:	68 77 89 10 80       	push   $0x80108977
80104c2b:	e8 85 b9 ff ff       	call   801005b5 <panic>

  if(lk == 0)
80104c30:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104c34:	75 0d                	jne    80104c43 <sleep+0x34>
    panic("sleep without lk");
80104c36:	83 ec 0c             	sub    $0xc,%esp
80104c39:	68 7d 89 10 80       	push   $0x8010897d
80104c3e:	e8 72 b9 ff ff       	call   801005b5 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104c43:	81 7d 0c 60 2d 11 80 	cmpl   $0x80112d60,0xc(%ebp)
80104c4a:	74 1e                	je     80104c6a <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104c4c:	83 ec 0c             	sub    $0xc,%esp
80104c4f:	68 60 2d 11 80       	push   $0x80112d60
80104c54:	e8 06 05 00 00       	call   8010515f <acquire>
80104c59:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104c5c:	83 ec 0c             	sub    $0xc,%esp
80104c5f:	ff 75 0c             	push   0xc(%ebp)
80104c62:	e8 66 05 00 00       	call   801051cd <release>
80104c67:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104c6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c6d:	8b 55 08             	mov    0x8(%ebp),%edx
80104c70:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104c73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c76:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104c7d:	e8 54 fe ff ff       	call   80104ad6 <sched>

  // Tidy up.
  p->chan = 0;
80104c82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c85:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104c8c:	81 7d 0c 60 2d 11 80 	cmpl   $0x80112d60,0xc(%ebp)
80104c93:	74 1e                	je     80104cb3 <sleep+0xa4>
    release(&ptable.lock);
80104c95:	83 ec 0c             	sub    $0xc,%esp
80104c98:	68 60 2d 11 80       	push   $0x80112d60
80104c9d:	e8 2b 05 00 00       	call   801051cd <release>
80104ca2:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104ca5:	83 ec 0c             	sub    $0xc,%esp
80104ca8:	ff 75 0c             	push   0xc(%ebp)
80104cab:	e8 af 04 00 00       	call   8010515f <acquire>
80104cb0:	83 c4 10             	add    $0x10,%esp
  }
}
80104cb3:	90                   	nop
80104cb4:	c9                   	leave  
80104cb5:	c3                   	ret    

80104cb6 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104cb6:	55                   	push   %ebp
80104cb7:	89 e5                	mov    %esp,%ebp
80104cb9:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104cbc:	c7 45 fc 94 2d 11 80 	movl   $0x80112d94,-0x4(%ebp)
80104cc3:	eb 27                	jmp    80104cec <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80104cc5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104cc8:	8b 40 0c             	mov    0xc(%eax),%eax
80104ccb:	83 f8 02             	cmp    $0x2,%eax
80104cce:	75 15                	jne    80104ce5 <wakeup1+0x2f>
80104cd0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104cd3:	8b 40 20             	mov    0x20(%eax),%eax
80104cd6:	39 45 08             	cmp    %eax,0x8(%ebp)
80104cd9:	75 0a                	jne    80104ce5 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104cdb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104cde:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104ce5:	81 45 fc 90 00 00 00 	addl   $0x90,-0x4(%ebp)
80104cec:	81 7d fc 94 51 11 80 	cmpl   $0x80115194,-0x4(%ebp)
80104cf3:	72 d0                	jb     80104cc5 <wakeup1+0xf>
}
80104cf5:	90                   	nop
80104cf6:	90                   	nop
80104cf7:	c9                   	leave  
80104cf8:	c3                   	ret    

80104cf9 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104cf9:	55                   	push   %ebp
80104cfa:	89 e5                	mov    %esp,%ebp
80104cfc:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104cff:	83 ec 0c             	sub    $0xc,%esp
80104d02:	68 60 2d 11 80       	push   $0x80112d60
80104d07:	e8 53 04 00 00       	call   8010515f <acquire>
80104d0c:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104d0f:	83 ec 0c             	sub    $0xc,%esp
80104d12:	ff 75 08             	push   0x8(%ebp)
80104d15:	e8 9c ff ff ff       	call   80104cb6 <wakeup1>
80104d1a:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104d1d:	83 ec 0c             	sub    $0xc,%esp
80104d20:	68 60 2d 11 80       	push   $0x80112d60
80104d25:	e8 a3 04 00 00       	call   801051cd <release>
80104d2a:	83 c4 10             	add    $0x10,%esp
}
80104d2d:	90                   	nop
80104d2e:	c9                   	leave  
80104d2f:	c3                   	ret    

80104d30 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104d30:	55                   	push   %ebp
80104d31:	89 e5                	mov    %esp,%ebp
80104d33:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104d36:	83 ec 0c             	sub    $0xc,%esp
80104d39:	68 60 2d 11 80       	push   $0x80112d60
80104d3e:	e8 1c 04 00 00       	call   8010515f <acquire>
80104d43:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d46:	c7 45 f4 94 2d 11 80 	movl   $0x80112d94,-0xc(%ebp)
80104d4d:	eb 48                	jmp    80104d97 <kill+0x67>
    if(p->pid == pid){
80104d4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d52:	8b 40 10             	mov    0x10(%eax),%eax
80104d55:	39 45 08             	cmp    %eax,0x8(%ebp)
80104d58:	75 36                	jne    80104d90 <kill+0x60>
      p->killed = 1;
80104d5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d5d:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104d64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d67:	8b 40 0c             	mov    0xc(%eax),%eax
80104d6a:	83 f8 02             	cmp    $0x2,%eax
80104d6d:	75 0a                	jne    80104d79 <kill+0x49>
        p->state = RUNNABLE;
80104d6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d72:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104d79:	83 ec 0c             	sub    $0xc,%esp
80104d7c:	68 60 2d 11 80       	push   $0x80112d60
80104d81:	e8 47 04 00 00       	call   801051cd <release>
80104d86:	83 c4 10             	add    $0x10,%esp
      return 0;
80104d89:	b8 00 00 00 00       	mov    $0x0,%eax
80104d8e:	eb 25                	jmp    80104db5 <kill+0x85>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d90:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80104d97:	81 7d f4 94 51 11 80 	cmpl   $0x80115194,-0xc(%ebp)
80104d9e:	72 af                	jb     80104d4f <kill+0x1f>
    }
  }
  release(&ptable.lock);
80104da0:	83 ec 0c             	sub    $0xc,%esp
80104da3:	68 60 2d 11 80       	push   $0x80112d60
80104da8:	e8 20 04 00 00       	call   801051cd <release>
80104dad:	83 c4 10             	add    $0x10,%esp
  return -1;
80104db0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104db5:	c9                   	leave  
80104db6:	c3                   	ret    

80104db7 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104db7:	55                   	push   %ebp
80104db8:	89 e5                	mov    %esp,%ebp
80104dba:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104dbd:	c7 45 f0 94 2d 11 80 	movl   $0x80112d94,-0x10(%ebp)
80104dc4:	e9 da 00 00 00       	jmp    80104ea3 <procdump+0xec>
    if(p->state == UNUSED)
80104dc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dcc:	8b 40 0c             	mov    0xc(%eax),%eax
80104dcf:	85 c0                	test   %eax,%eax
80104dd1:	0f 84 c4 00 00 00    	je     80104e9b <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104dd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dda:	8b 40 0c             	mov    0xc(%eax),%eax
80104ddd:	83 f8 05             	cmp    $0x5,%eax
80104de0:	77 23                	ja     80104e05 <procdump+0x4e>
80104de2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104de5:	8b 40 0c             	mov    0xc(%eax),%eax
80104de8:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104def:	85 c0                	test   %eax,%eax
80104df1:	74 12                	je     80104e05 <procdump+0x4e>
      state = states[p->state];
80104df3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104df6:	8b 40 0c             	mov    0xc(%eax),%eax
80104df9:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104e00:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104e03:	eb 07                	jmp    80104e0c <procdump+0x55>
    else
      state = "???";
80104e05:	c7 45 ec 8e 89 10 80 	movl   $0x8010898e,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104e0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e0f:	8d 50 6c             	lea    0x6c(%eax),%edx
80104e12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e15:	8b 40 10             	mov    0x10(%eax),%eax
80104e18:	52                   	push   %edx
80104e19:	ff 75 ec             	push   -0x14(%ebp)
80104e1c:	50                   	push   %eax
80104e1d:	68 92 89 10 80       	push   $0x80108992
80104e22:	e8 d9 b5 ff ff       	call   80100400 <cprintf>
80104e27:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104e2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e2d:	8b 40 0c             	mov    0xc(%eax),%eax
80104e30:	83 f8 02             	cmp    $0x2,%eax
80104e33:	75 54                	jne    80104e89 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104e35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e38:	8b 40 1c             	mov    0x1c(%eax),%eax
80104e3b:	8b 40 0c             	mov    0xc(%eax),%eax
80104e3e:	83 c0 08             	add    $0x8,%eax
80104e41:	89 c2                	mov    %eax,%edx
80104e43:	83 ec 08             	sub    $0x8,%esp
80104e46:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104e49:	50                   	push   %eax
80104e4a:	52                   	push   %edx
80104e4b:	e8 cf 03 00 00       	call   8010521f <getcallerpcs>
80104e50:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104e53:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104e5a:	eb 1c                	jmp    80104e78 <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104e5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e5f:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104e63:	83 ec 08             	sub    $0x8,%esp
80104e66:	50                   	push   %eax
80104e67:	68 9b 89 10 80       	push   $0x8010899b
80104e6c:	e8 8f b5 ff ff       	call   80100400 <cprintf>
80104e71:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104e74:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104e78:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104e7c:	7f 0b                	jg     80104e89 <procdump+0xd2>
80104e7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e81:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104e85:	85 c0                	test   %eax,%eax
80104e87:	75 d3                	jne    80104e5c <procdump+0xa5>
    }
    cprintf("\n");
80104e89:	83 ec 0c             	sub    $0xc,%esp
80104e8c:	68 9f 89 10 80       	push   $0x8010899f
80104e91:	e8 6a b5 ff ff       	call   80100400 <cprintf>
80104e96:	83 c4 10             	add    $0x10,%esp
80104e99:	eb 01                	jmp    80104e9c <procdump+0xe5>
      continue;
80104e9b:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e9c:	81 45 f0 90 00 00 00 	addl   $0x90,-0x10(%ebp)
80104ea3:	81 7d f0 94 51 11 80 	cmpl   $0x80115194,-0x10(%ebp)
80104eaa:	0f 82 19 ff ff ff    	jb     80104dc9 <procdump+0x12>
  }
}
80104eb0:	90                   	nop
80104eb1:	90                   	nop
80104eb2:	c9                   	leave  
80104eb3:	c3                   	ret    

80104eb4 <nice>:

int
nice(int n){
80104eb4:	55                   	push   %ebp
80104eb5:	89 e5                	mov    %esp,%ebp
80104eb7:	83 ec 18             	sub    $0x18,%esp

  if (n <0 || n > 20)
80104eba:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104ebe:	78 06                	js     80104ec6 <nice+0x12>
80104ec0:	83 7d 08 14          	cmpl   $0x14,0x8(%ebp)
80104ec4:	7e 07                	jle    80104ecd <nice+0x19>
    return -1;
80104ec6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ecb:	eb 19                	jmp    80104ee6 <nice+0x32>

  int previous_nice = myproc()->nice_value;
80104ecd:	e8 c7 f3 ff ff       	call   80104299 <myproc>
80104ed2:	8b 40 7c             	mov    0x7c(%eax),%eax
80104ed5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  myproc()->nice_value = n;
80104ed8:	e8 bc f3 ff ff       	call   80104299 <myproc>
80104edd:	8b 55 08             	mov    0x8(%ebp),%edx
80104ee0:	89 50 7c             	mov    %edx,0x7c(%eax)

  return previous_nice;
80104ee3:	8b 45 f4             	mov    -0xc(%ebp),%eax

}
80104ee6:	c9                   	leave  
80104ee7:	c3                   	ret    

80104ee8 <getschedstate>:

int
getschedstate(struct pschedinfo *psi){
80104ee8:	55                   	push   %ebp
80104ee9:	89 e5                	mov    %esp,%ebp
80104eeb:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int i =0;
80104eee:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  acquire(&ptable.lock);
80104ef5:	83 ec 0c             	sub    $0xc,%esp
80104ef8:	68 60 2d 11 80       	push   $0x80112d60
80104efd:	e8 5d 02 00 00       	call   8010515f <acquire>
80104f02:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f05:	c7 45 f4 94 2d 11 80 	movl   $0x80112d94,-0xc(%ebp)
80104f0c:	e9 85 00 00 00       	jmp    80104f96 <getschedstate+0xae>
    if(p->state != UNUSED){
80104f11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f14:	8b 40 0c             	mov    0xc(%eax),%eax
80104f17:	85 c0                	test   %eax,%eax
80104f19:	74 74                	je     80104f8f <getschedstate+0xa7>
      psi->inuse[p->pid] = 1;
80104f1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f1e:	8b 50 10             	mov    0x10(%eax),%edx
80104f21:	8b 45 08             	mov    0x8(%ebp),%eax
80104f24:	c7 04 90 01 00 00 00 	movl   $0x1,(%eax,%edx,4)
      psi->priority[p->pid] = p->priority;
80104f2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f2e:	8b 48 10             	mov    0x10(%eax),%ecx
80104f31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f34:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80104f3a:	8b 45 08             	mov    0x8(%ebp),%eax
80104f3d:	83 c1 40             	add    $0x40,%ecx
80104f40:	89 14 88             	mov    %edx,(%eax,%ecx,4)
      psi->nice[p->pid] = p->nice_value;
80104f43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f46:	8b 48 10             	mov    0x10(%eax),%ecx
80104f49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f4c:	8b 50 7c             	mov    0x7c(%eax),%edx
80104f4f:	8b 45 08             	mov    0x8(%ebp),%eax
80104f52:	83 e9 80             	sub    $0xffffff80,%ecx
80104f55:	89 14 88             	mov    %edx,(%eax,%ecx,4)
      psi->pid[p->pid] = p->pid;
80104f58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f5b:	8b 48 10             	mov    0x10(%eax),%ecx
80104f5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f61:	8b 50 10             	mov    0x10(%eax),%edx
80104f64:	8b 45 08             	mov    0x8(%ebp),%eax
80104f67:	81 c1 c0 00 00 00    	add    $0xc0,%ecx
80104f6d:	89 14 88             	mov    %edx,(%eax,%ecx,4)
      psi->ticks[p->pid] = p->ticks;
80104f70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f73:	8b 88 84 00 00 00    	mov    0x84(%eax),%ecx
80104f79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f7c:	8b 50 10             	mov    0x10(%eax),%edx
80104f7f:	8b 45 08             	mov    0x8(%ebp),%eax
80104f82:	81 c2 00 01 00 00    	add    $0x100,%edx
80104f88:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
      i++;
80104f8b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f8f:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80104f96:	81 7d f4 94 51 11 80 	cmpl   $0x80115194,-0xc(%ebp)
80104f9d:	0f 82 6e ff ff ff    	jb     80104f11 <getschedstate+0x29>
    }
  }  
  release(&ptable.lock);
80104fa3:	83 ec 0c             	sub    $0xc,%esp
80104fa6:	68 60 2d 11 80       	push   $0x80112d60
80104fab:	e8 1d 02 00 00       	call   801051cd <release>
80104fb0:	83 c4 10             	add    $0x10,%esp
  return 0;
80104fb3:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104fb8:	c9                   	leave  
80104fb9:	c3                   	ret    

80104fba <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104fba:	55                   	push   %ebp
80104fbb:	89 e5                	mov    %esp,%ebp
80104fbd:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104fc0:	8b 45 08             	mov    0x8(%ebp),%eax
80104fc3:	83 c0 04             	add    $0x4,%eax
80104fc6:	83 ec 08             	sub    $0x8,%esp
80104fc9:	68 cb 89 10 80       	push   $0x801089cb
80104fce:	50                   	push   %eax
80104fcf:	e8 69 01 00 00       	call   8010513d <initlock>
80104fd4:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80104fd7:	8b 45 08             	mov    0x8(%ebp),%eax
80104fda:	8b 55 0c             	mov    0xc(%ebp),%edx
80104fdd:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104fe0:	8b 45 08             	mov    0x8(%ebp),%eax
80104fe3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104fe9:	8b 45 08             	mov    0x8(%ebp),%eax
80104fec:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104ff3:	90                   	nop
80104ff4:	c9                   	leave  
80104ff5:	c3                   	ret    

80104ff6 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104ff6:	55                   	push   %ebp
80104ff7:	89 e5                	mov    %esp,%ebp
80104ff9:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104ffc:	8b 45 08             	mov    0x8(%ebp),%eax
80104fff:	83 c0 04             	add    $0x4,%eax
80105002:	83 ec 0c             	sub    $0xc,%esp
80105005:	50                   	push   %eax
80105006:	e8 54 01 00 00       	call   8010515f <acquire>
8010500b:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
8010500e:	eb 15                	jmp    80105025 <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
80105010:	8b 45 08             	mov    0x8(%ebp),%eax
80105013:	83 c0 04             	add    $0x4,%eax
80105016:	83 ec 08             	sub    $0x8,%esp
80105019:	50                   	push   %eax
8010501a:	ff 75 08             	push   0x8(%ebp)
8010501d:	e8 ed fb ff ff       	call   80104c0f <sleep>
80105022:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80105025:	8b 45 08             	mov    0x8(%ebp),%eax
80105028:	8b 00                	mov    (%eax),%eax
8010502a:	85 c0                	test   %eax,%eax
8010502c:	75 e2                	jne    80105010 <acquiresleep+0x1a>
  }
  lk->locked = 1;
8010502e:	8b 45 08             	mov    0x8(%ebp),%eax
80105031:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80105037:	e8 5d f2 ff ff       	call   80104299 <myproc>
8010503c:	8b 50 10             	mov    0x10(%eax),%edx
8010503f:	8b 45 08             	mov    0x8(%ebp),%eax
80105042:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80105045:	8b 45 08             	mov    0x8(%ebp),%eax
80105048:	83 c0 04             	add    $0x4,%eax
8010504b:	83 ec 0c             	sub    $0xc,%esp
8010504e:	50                   	push   %eax
8010504f:	e8 79 01 00 00       	call   801051cd <release>
80105054:	83 c4 10             	add    $0x10,%esp
}
80105057:	90                   	nop
80105058:	c9                   	leave  
80105059:	c3                   	ret    

8010505a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
8010505a:	55                   	push   %ebp
8010505b:	89 e5                	mov    %esp,%ebp
8010505d:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80105060:	8b 45 08             	mov    0x8(%ebp),%eax
80105063:	83 c0 04             	add    $0x4,%eax
80105066:	83 ec 0c             	sub    $0xc,%esp
80105069:	50                   	push   %eax
8010506a:	e8 f0 00 00 00       	call   8010515f <acquire>
8010506f:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80105072:	8b 45 08             	mov    0x8(%ebp),%eax
80105075:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010507b:	8b 45 08             	mov    0x8(%ebp),%eax
8010507e:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80105085:	83 ec 0c             	sub    $0xc,%esp
80105088:	ff 75 08             	push   0x8(%ebp)
8010508b:	e8 69 fc ff ff       	call   80104cf9 <wakeup>
80105090:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80105093:	8b 45 08             	mov    0x8(%ebp),%eax
80105096:	83 c0 04             	add    $0x4,%eax
80105099:	83 ec 0c             	sub    $0xc,%esp
8010509c:	50                   	push   %eax
8010509d:	e8 2b 01 00 00       	call   801051cd <release>
801050a2:	83 c4 10             	add    $0x10,%esp
}
801050a5:	90                   	nop
801050a6:	c9                   	leave  
801050a7:	c3                   	ret    

801050a8 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
801050a8:	55                   	push   %ebp
801050a9:	89 e5                	mov    %esp,%ebp
801050ab:	53                   	push   %ebx
801050ac:	83 ec 14             	sub    $0x14,%esp
  int r;
  
  acquire(&lk->lk);
801050af:	8b 45 08             	mov    0x8(%ebp),%eax
801050b2:	83 c0 04             	add    $0x4,%eax
801050b5:	83 ec 0c             	sub    $0xc,%esp
801050b8:	50                   	push   %eax
801050b9:	e8 a1 00 00 00       	call   8010515f <acquire>
801050be:	83 c4 10             	add    $0x10,%esp
  r = lk->locked && (lk->pid == myproc()->pid);
801050c1:	8b 45 08             	mov    0x8(%ebp),%eax
801050c4:	8b 00                	mov    (%eax),%eax
801050c6:	85 c0                	test   %eax,%eax
801050c8:	74 19                	je     801050e3 <holdingsleep+0x3b>
801050ca:	8b 45 08             	mov    0x8(%ebp),%eax
801050cd:	8b 58 3c             	mov    0x3c(%eax),%ebx
801050d0:	e8 c4 f1 ff ff       	call   80104299 <myproc>
801050d5:	8b 40 10             	mov    0x10(%eax),%eax
801050d8:	39 c3                	cmp    %eax,%ebx
801050da:	75 07                	jne    801050e3 <holdingsleep+0x3b>
801050dc:	b8 01 00 00 00       	mov    $0x1,%eax
801050e1:	eb 05                	jmp    801050e8 <holdingsleep+0x40>
801050e3:	b8 00 00 00 00       	mov    $0x0,%eax
801050e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
801050eb:	8b 45 08             	mov    0x8(%ebp),%eax
801050ee:	83 c0 04             	add    $0x4,%eax
801050f1:	83 ec 0c             	sub    $0xc,%esp
801050f4:	50                   	push   %eax
801050f5:	e8 d3 00 00 00       	call   801051cd <release>
801050fa:	83 c4 10             	add    $0x10,%esp
  return r;
801050fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105100:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105103:	c9                   	leave  
80105104:	c3                   	ret    

80105105 <readeflags>:
{
80105105:	55                   	push   %ebp
80105106:	89 e5                	mov    %esp,%ebp
80105108:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010510b:	9c                   	pushf  
8010510c:	58                   	pop    %eax
8010510d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105110:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105113:	c9                   	leave  
80105114:	c3                   	ret    

80105115 <cli>:
{
80105115:	55                   	push   %ebp
80105116:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105118:	fa                   	cli    
}
80105119:	90                   	nop
8010511a:	5d                   	pop    %ebp
8010511b:	c3                   	ret    

8010511c <sti>:
{
8010511c:	55                   	push   %ebp
8010511d:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010511f:	fb                   	sti    
}
80105120:	90                   	nop
80105121:	5d                   	pop    %ebp
80105122:	c3                   	ret    

80105123 <xchg>:
{
80105123:	55                   	push   %ebp
80105124:	89 e5                	mov    %esp,%ebp
80105126:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80105129:	8b 55 08             	mov    0x8(%ebp),%edx
8010512c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010512f:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105132:	f0 87 02             	lock xchg %eax,(%edx)
80105135:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80105138:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010513b:	c9                   	leave  
8010513c:	c3                   	ret    

8010513d <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
8010513d:	55                   	push   %ebp
8010513e:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105140:	8b 45 08             	mov    0x8(%ebp),%eax
80105143:	8b 55 0c             	mov    0xc(%ebp),%edx
80105146:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105149:	8b 45 08             	mov    0x8(%ebp),%eax
8010514c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105152:	8b 45 08             	mov    0x8(%ebp),%eax
80105155:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
8010515c:	90                   	nop
8010515d:	5d                   	pop    %ebp
8010515e:	c3                   	ret    

8010515f <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
8010515f:	55                   	push   %ebp
80105160:	89 e5                	mov    %esp,%ebp
80105162:	53                   	push   %ebx
80105163:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105166:	e8 6f 01 00 00       	call   801052da <pushcli>
  if(holding(lk))
8010516b:	8b 45 08             	mov    0x8(%ebp),%eax
8010516e:	83 ec 0c             	sub    $0xc,%esp
80105171:	50                   	push   %eax
80105172:	e8 23 01 00 00       	call   8010529a <holding>
80105177:	83 c4 10             	add    $0x10,%esp
8010517a:	85 c0                	test   %eax,%eax
8010517c:	74 0d                	je     8010518b <acquire+0x2c>
    panic("acquire");
8010517e:	83 ec 0c             	sub    $0xc,%esp
80105181:	68 d6 89 10 80       	push   $0x801089d6
80105186:	e8 2a b4 ff ff       	call   801005b5 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
8010518b:	90                   	nop
8010518c:	8b 45 08             	mov    0x8(%ebp),%eax
8010518f:	83 ec 08             	sub    $0x8,%esp
80105192:	6a 01                	push   $0x1
80105194:	50                   	push   %eax
80105195:	e8 89 ff ff ff       	call   80105123 <xchg>
8010519a:	83 c4 10             	add    $0x10,%esp
8010519d:	85 c0                	test   %eax,%eax
8010519f:	75 eb                	jne    8010518c <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
801051a1:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
801051a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
801051a9:	e8 73 f0 ff ff       	call   80104221 <mycpu>
801051ae:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
801051b1:	8b 45 08             	mov    0x8(%ebp),%eax
801051b4:	83 c0 0c             	add    $0xc,%eax
801051b7:	83 ec 08             	sub    $0x8,%esp
801051ba:	50                   	push   %eax
801051bb:	8d 45 08             	lea    0x8(%ebp),%eax
801051be:	50                   	push   %eax
801051bf:	e8 5b 00 00 00       	call   8010521f <getcallerpcs>
801051c4:	83 c4 10             	add    $0x10,%esp
}
801051c7:	90                   	nop
801051c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801051cb:	c9                   	leave  
801051cc:	c3                   	ret    

801051cd <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801051cd:	55                   	push   %ebp
801051ce:	89 e5                	mov    %esp,%ebp
801051d0:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
801051d3:	83 ec 0c             	sub    $0xc,%esp
801051d6:	ff 75 08             	push   0x8(%ebp)
801051d9:	e8 bc 00 00 00       	call   8010529a <holding>
801051de:	83 c4 10             	add    $0x10,%esp
801051e1:	85 c0                	test   %eax,%eax
801051e3:	75 0d                	jne    801051f2 <release+0x25>
    panic("release");
801051e5:	83 ec 0c             	sub    $0xc,%esp
801051e8:	68 de 89 10 80       	push   $0x801089de
801051ed:	e8 c3 b3 ff ff       	call   801005b5 <panic>

  lk->pcs[0] = 0;
801051f2:	8b 45 08             	mov    0x8(%ebp),%eax
801051f5:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801051fc:	8b 45 08             	mov    0x8(%ebp),%eax
801051ff:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80105206:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
8010520b:	8b 45 08             	mov    0x8(%ebp),%eax
8010520e:	8b 55 08             	mov    0x8(%ebp),%edx
80105211:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80105217:	e8 0b 01 00 00       	call   80105327 <popcli>
}
8010521c:	90                   	nop
8010521d:	c9                   	leave  
8010521e:	c3                   	ret    

8010521f <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
8010521f:	55                   	push   %ebp
80105220:	89 e5                	mov    %esp,%ebp
80105222:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80105225:	8b 45 08             	mov    0x8(%ebp),%eax
80105228:	83 e8 08             	sub    $0x8,%eax
8010522b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010522e:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105235:	eb 38                	jmp    8010526f <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105237:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
8010523b:	74 53                	je     80105290 <getcallerpcs+0x71>
8010523d:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105244:	76 4a                	jbe    80105290 <getcallerpcs+0x71>
80105246:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
8010524a:	74 44                	je     80105290 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
8010524c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010524f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105256:	8b 45 0c             	mov    0xc(%ebp),%eax
80105259:	01 c2                	add    %eax,%edx
8010525b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010525e:	8b 40 04             	mov    0x4(%eax),%eax
80105261:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105263:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105266:	8b 00                	mov    (%eax),%eax
80105268:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010526b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010526f:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105273:	7e c2                	jle    80105237 <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
80105275:	eb 19                	jmp    80105290 <getcallerpcs+0x71>
    pcs[i] = 0;
80105277:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010527a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105281:	8b 45 0c             	mov    0xc(%ebp),%eax
80105284:	01 d0                	add    %edx,%eax
80105286:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
8010528c:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105290:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105294:	7e e1                	jle    80105277 <getcallerpcs+0x58>
}
80105296:	90                   	nop
80105297:	90                   	nop
80105298:	c9                   	leave  
80105299:	c3                   	ret    

8010529a <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
8010529a:	55                   	push   %ebp
8010529b:	89 e5                	mov    %esp,%ebp
8010529d:	53                   	push   %ebx
8010529e:	83 ec 14             	sub    $0x14,%esp
  int r;
  pushcli();
801052a1:	e8 34 00 00 00       	call   801052da <pushcli>
  r = lock->locked && lock->cpu == mycpu();
801052a6:	8b 45 08             	mov    0x8(%ebp),%eax
801052a9:	8b 00                	mov    (%eax),%eax
801052ab:	85 c0                	test   %eax,%eax
801052ad:	74 16                	je     801052c5 <holding+0x2b>
801052af:	8b 45 08             	mov    0x8(%ebp),%eax
801052b2:	8b 58 08             	mov    0x8(%eax),%ebx
801052b5:	e8 67 ef ff ff       	call   80104221 <mycpu>
801052ba:	39 c3                	cmp    %eax,%ebx
801052bc:	75 07                	jne    801052c5 <holding+0x2b>
801052be:	b8 01 00 00 00       	mov    $0x1,%eax
801052c3:	eb 05                	jmp    801052ca <holding+0x30>
801052c5:	b8 00 00 00 00       	mov    $0x0,%eax
801052ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
  popcli();
801052cd:	e8 55 00 00 00       	call   80105327 <popcli>
  return r;
801052d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801052d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801052d8:	c9                   	leave  
801052d9:	c3                   	ret    

801052da <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801052da:	55                   	push   %ebp
801052db:	89 e5                	mov    %esp,%ebp
801052dd:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
801052e0:	e8 20 fe ff ff       	call   80105105 <readeflags>
801052e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
801052e8:	e8 28 fe ff ff       	call   80105115 <cli>
  if(mycpu()->ncli == 0)
801052ed:	e8 2f ef ff ff       	call   80104221 <mycpu>
801052f2:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801052f8:	85 c0                	test   %eax,%eax
801052fa:	75 14                	jne    80105310 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
801052fc:	e8 20 ef ff ff       	call   80104221 <mycpu>
80105301:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105304:	81 e2 00 02 00 00    	and    $0x200,%edx
8010530a:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80105310:	e8 0c ef ff ff       	call   80104221 <mycpu>
80105315:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
8010531b:	83 c2 01             	add    $0x1,%edx
8010531e:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80105324:	90                   	nop
80105325:	c9                   	leave  
80105326:	c3                   	ret    

80105327 <popcli>:

void
popcli(void)
{
80105327:	55                   	push   %ebp
80105328:	89 e5                	mov    %esp,%ebp
8010532a:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
8010532d:	e8 d3 fd ff ff       	call   80105105 <readeflags>
80105332:	25 00 02 00 00       	and    $0x200,%eax
80105337:	85 c0                	test   %eax,%eax
80105339:	74 0d                	je     80105348 <popcli+0x21>
    panic("popcli - interruptible");
8010533b:	83 ec 0c             	sub    $0xc,%esp
8010533e:	68 e6 89 10 80       	push   $0x801089e6
80105343:	e8 6d b2 ff ff       	call   801005b5 <panic>
  if(--mycpu()->ncli < 0)
80105348:	e8 d4 ee ff ff       	call   80104221 <mycpu>
8010534d:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105353:	83 ea 01             	sub    $0x1,%edx
80105356:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
8010535c:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105362:	85 c0                	test   %eax,%eax
80105364:	79 0d                	jns    80105373 <popcli+0x4c>
    panic("popcli");
80105366:	83 ec 0c             	sub    $0xc,%esp
80105369:	68 fd 89 10 80       	push   $0x801089fd
8010536e:	e8 42 b2 ff ff       	call   801005b5 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80105373:	e8 a9 ee ff ff       	call   80104221 <mycpu>
80105378:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010537e:	85 c0                	test   %eax,%eax
80105380:	75 14                	jne    80105396 <popcli+0x6f>
80105382:	e8 9a ee ff ff       	call   80104221 <mycpu>
80105387:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010538d:	85 c0                	test   %eax,%eax
8010538f:	74 05                	je     80105396 <popcli+0x6f>
    sti();
80105391:	e8 86 fd ff ff       	call   8010511c <sti>
}
80105396:	90                   	nop
80105397:	c9                   	leave  
80105398:	c3                   	ret    

80105399 <stosb>:
{
80105399:	55                   	push   %ebp
8010539a:	89 e5                	mov    %esp,%ebp
8010539c:	57                   	push   %edi
8010539d:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
8010539e:	8b 4d 08             	mov    0x8(%ebp),%ecx
801053a1:	8b 55 10             	mov    0x10(%ebp),%edx
801053a4:	8b 45 0c             	mov    0xc(%ebp),%eax
801053a7:	89 cb                	mov    %ecx,%ebx
801053a9:	89 df                	mov    %ebx,%edi
801053ab:	89 d1                	mov    %edx,%ecx
801053ad:	fc                   	cld    
801053ae:	f3 aa                	rep stos %al,%es:(%edi)
801053b0:	89 ca                	mov    %ecx,%edx
801053b2:	89 fb                	mov    %edi,%ebx
801053b4:	89 5d 08             	mov    %ebx,0x8(%ebp)
801053b7:	89 55 10             	mov    %edx,0x10(%ebp)
}
801053ba:	90                   	nop
801053bb:	5b                   	pop    %ebx
801053bc:	5f                   	pop    %edi
801053bd:	5d                   	pop    %ebp
801053be:	c3                   	ret    

801053bf <stosl>:
{
801053bf:	55                   	push   %ebp
801053c0:	89 e5                	mov    %esp,%ebp
801053c2:	57                   	push   %edi
801053c3:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801053c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
801053c7:	8b 55 10             	mov    0x10(%ebp),%edx
801053ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801053cd:	89 cb                	mov    %ecx,%ebx
801053cf:	89 df                	mov    %ebx,%edi
801053d1:	89 d1                	mov    %edx,%ecx
801053d3:	fc                   	cld    
801053d4:	f3 ab                	rep stos %eax,%es:(%edi)
801053d6:	89 ca                	mov    %ecx,%edx
801053d8:	89 fb                	mov    %edi,%ebx
801053da:	89 5d 08             	mov    %ebx,0x8(%ebp)
801053dd:	89 55 10             	mov    %edx,0x10(%ebp)
}
801053e0:	90                   	nop
801053e1:	5b                   	pop    %ebx
801053e2:	5f                   	pop    %edi
801053e3:	5d                   	pop    %ebp
801053e4:	c3                   	ret    

801053e5 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801053e5:	55                   	push   %ebp
801053e6:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
801053e8:	8b 45 08             	mov    0x8(%ebp),%eax
801053eb:	83 e0 03             	and    $0x3,%eax
801053ee:	85 c0                	test   %eax,%eax
801053f0:	75 43                	jne    80105435 <memset+0x50>
801053f2:	8b 45 10             	mov    0x10(%ebp),%eax
801053f5:	83 e0 03             	and    $0x3,%eax
801053f8:	85 c0                	test   %eax,%eax
801053fa:	75 39                	jne    80105435 <memset+0x50>
    c &= 0xFF;
801053fc:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105403:	8b 45 10             	mov    0x10(%ebp),%eax
80105406:	c1 e8 02             	shr    $0x2,%eax
80105409:	89 c2                	mov    %eax,%edx
8010540b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010540e:	c1 e0 18             	shl    $0x18,%eax
80105411:	89 c1                	mov    %eax,%ecx
80105413:	8b 45 0c             	mov    0xc(%ebp),%eax
80105416:	c1 e0 10             	shl    $0x10,%eax
80105419:	09 c1                	or     %eax,%ecx
8010541b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010541e:	c1 e0 08             	shl    $0x8,%eax
80105421:	09 c8                	or     %ecx,%eax
80105423:	0b 45 0c             	or     0xc(%ebp),%eax
80105426:	52                   	push   %edx
80105427:	50                   	push   %eax
80105428:	ff 75 08             	push   0x8(%ebp)
8010542b:	e8 8f ff ff ff       	call   801053bf <stosl>
80105430:	83 c4 0c             	add    $0xc,%esp
80105433:	eb 12                	jmp    80105447 <memset+0x62>
  } else
    stosb(dst, c, n);
80105435:	8b 45 10             	mov    0x10(%ebp),%eax
80105438:	50                   	push   %eax
80105439:	ff 75 0c             	push   0xc(%ebp)
8010543c:	ff 75 08             	push   0x8(%ebp)
8010543f:	e8 55 ff ff ff       	call   80105399 <stosb>
80105444:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105447:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010544a:	c9                   	leave  
8010544b:	c3                   	ret    

8010544c <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
8010544c:	55                   	push   %ebp
8010544d:	89 e5                	mov    %esp,%ebp
8010544f:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80105452:	8b 45 08             	mov    0x8(%ebp),%eax
80105455:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105458:	8b 45 0c             	mov    0xc(%ebp),%eax
8010545b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
8010545e:	eb 30                	jmp    80105490 <memcmp+0x44>
    if(*s1 != *s2)
80105460:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105463:	0f b6 10             	movzbl (%eax),%edx
80105466:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105469:	0f b6 00             	movzbl (%eax),%eax
8010546c:	38 c2                	cmp    %al,%dl
8010546e:	74 18                	je     80105488 <memcmp+0x3c>
      return *s1 - *s2;
80105470:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105473:	0f b6 00             	movzbl (%eax),%eax
80105476:	0f b6 d0             	movzbl %al,%edx
80105479:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010547c:	0f b6 00             	movzbl (%eax),%eax
8010547f:	0f b6 c8             	movzbl %al,%ecx
80105482:	89 d0                	mov    %edx,%eax
80105484:	29 c8                	sub    %ecx,%eax
80105486:	eb 1a                	jmp    801054a2 <memcmp+0x56>
    s1++, s2++;
80105488:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010548c:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80105490:	8b 45 10             	mov    0x10(%ebp),%eax
80105493:	8d 50 ff             	lea    -0x1(%eax),%edx
80105496:	89 55 10             	mov    %edx,0x10(%ebp)
80105499:	85 c0                	test   %eax,%eax
8010549b:	75 c3                	jne    80105460 <memcmp+0x14>
  }

  return 0;
8010549d:	b8 00 00 00 00       	mov    $0x0,%eax
}
801054a2:	c9                   	leave  
801054a3:	c3                   	ret    

801054a4 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801054a4:	55                   	push   %ebp
801054a5:	89 e5                	mov    %esp,%ebp
801054a7:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801054aa:	8b 45 0c             	mov    0xc(%ebp),%eax
801054ad:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801054b0:	8b 45 08             	mov    0x8(%ebp),%eax
801054b3:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801054b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054b9:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801054bc:	73 54                	jae    80105512 <memmove+0x6e>
801054be:	8b 55 fc             	mov    -0x4(%ebp),%edx
801054c1:	8b 45 10             	mov    0x10(%ebp),%eax
801054c4:	01 d0                	add    %edx,%eax
801054c6:	39 45 f8             	cmp    %eax,-0x8(%ebp)
801054c9:	73 47                	jae    80105512 <memmove+0x6e>
    s += n;
801054cb:	8b 45 10             	mov    0x10(%ebp),%eax
801054ce:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801054d1:	8b 45 10             	mov    0x10(%ebp),%eax
801054d4:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801054d7:	eb 13                	jmp    801054ec <memmove+0x48>
      *--d = *--s;
801054d9:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801054dd:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
801054e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054e4:	0f b6 10             	movzbl (%eax),%edx
801054e7:	8b 45 f8             	mov    -0x8(%ebp),%eax
801054ea:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
801054ec:	8b 45 10             	mov    0x10(%ebp),%eax
801054ef:	8d 50 ff             	lea    -0x1(%eax),%edx
801054f2:	89 55 10             	mov    %edx,0x10(%ebp)
801054f5:	85 c0                	test   %eax,%eax
801054f7:	75 e0                	jne    801054d9 <memmove+0x35>
  if(s < d && s + n > d){
801054f9:	eb 24                	jmp    8010551f <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
801054fb:	8b 55 fc             	mov    -0x4(%ebp),%edx
801054fe:	8d 42 01             	lea    0x1(%edx),%eax
80105501:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105504:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105507:	8d 48 01             	lea    0x1(%eax),%ecx
8010550a:	89 4d f8             	mov    %ecx,-0x8(%ebp)
8010550d:	0f b6 12             	movzbl (%edx),%edx
80105510:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80105512:	8b 45 10             	mov    0x10(%ebp),%eax
80105515:	8d 50 ff             	lea    -0x1(%eax),%edx
80105518:	89 55 10             	mov    %edx,0x10(%ebp)
8010551b:	85 c0                	test   %eax,%eax
8010551d:	75 dc                	jne    801054fb <memmove+0x57>

  return dst;
8010551f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105522:	c9                   	leave  
80105523:	c3                   	ret    

80105524 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105524:	55                   	push   %ebp
80105525:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105527:	ff 75 10             	push   0x10(%ebp)
8010552a:	ff 75 0c             	push   0xc(%ebp)
8010552d:	ff 75 08             	push   0x8(%ebp)
80105530:	e8 6f ff ff ff       	call   801054a4 <memmove>
80105535:	83 c4 0c             	add    $0xc,%esp
}
80105538:	c9                   	leave  
80105539:	c3                   	ret    

8010553a <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
8010553a:	55                   	push   %ebp
8010553b:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
8010553d:	eb 0c                	jmp    8010554b <strncmp+0x11>
    n--, p++, q++;
8010553f:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105543:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105547:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
8010554b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010554f:	74 1a                	je     8010556b <strncmp+0x31>
80105551:	8b 45 08             	mov    0x8(%ebp),%eax
80105554:	0f b6 00             	movzbl (%eax),%eax
80105557:	84 c0                	test   %al,%al
80105559:	74 10                	je     8010556b <strncmp+0x31>
8010555b:	8b 45 08             	mov    0x8(%ebp),%eax
8010555e:	0f b6 10             	movzbl (%eax),%edx
80105561:	8b 45 0c             	mov    0xc(%ebp),%eax
80105564:	0f b6 00             	movzbl (%eax),%eax
80105567:	38 c2                	cmp    %al,%dl
80105569:	74 d4                	je     8010553f <strncmp+0x5>
  if(n == 0)
8010556b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010556f:	75 07                	jne    80105578 <strncmp+0x3e>
    return 0;
80105571:	b8 00 00 00 00       	mov    $0x0,%eax
80105576:	eb 16                	jmp    8010558e <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80105578:	8b 45 08             	mov    0x8(%ebp),%eax
8010557b:	0f b6 00             	movzbl (%eax),%eax
8010557e:	0f b6 d0             	movzbl %al,%edx
80105581:	8b 45 0c             	mov    0xc(%ebp),%eax
80105584:	0f b6 00             	movzbl (%eax),%eax
80105587:	0f b6 c8             	movzbl %al,%ecx
8010558a:	89 d0                	mov    %edx,%eax
8010558c:	29 c8                	sub    %ecx,%eax
}
8010558e:	5d                   	pop    %ebp
8010558f:	c3                   	ret    

80105590 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105590:	55                   	push   %ebp
80105591:	89 e5                	mov    %esp,%ebp
80105593:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105596:	8b 45 08             	mov    0x8(%ebp),%eax
80105599:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
8010559c:	90                   	nop
8010559d:	8b 45 10             	mov    0x10(%ebp),%eax
801055a0:	8d 50 ff             	lea    -0x1(%eax),%edx
801055a3:	89 55 10             	mov    %edx,0x10(%ebp)
801055a6:	85 c0                	test   %eax,%eax
801055a8:	7e 2c                	jle    801055d6 <strncpy+0x46>
801055aa:	8b 55 0c             	mov    0xc(%ebp),%edx
801055ad:	8d 42 01             	lea    0x1(%edx),%eax
801055b0:	89 45 0c             	mov    %eax,0xc(%ebp)
801055b3:	8b 45 08             	mov    0x8(%ebp),%eax
801055b6:	8d 48 01             	lea    0x1(%eax),%ecx
801055b9:	89 4d 08             	mov    %ecx,0x8(%ebp)
801055bc:	0f b6 12             	movzbl (%edx),%edx
801055bf:	88 10                	mov    %dl,(%eax)
801055c1:	0f b6 00             	movzbl (%eax),%eax
801055c4:	84 c0                	test   %al,%al
801055c6:	75 d5                	jne    8010559d <strncpy+0xd>
    ;
  while(n-- > 0)
801055c8:	eb 0c                	jmp    801055d6 <strncpy+0x46>
    *s++ = 0;
801055ca:	8b 45 08             	mov    0x8(%ebp),%eax
801055cd:	8d 50 01             	lea    0x1(%eax),%edx
801055d0:	89 55 08             	mov    %edx,0x8(%ebp)
801055d3:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
801055d6:	8b 45 10             	mov    0x10(%ebp),%eax
801055d9:	8d 50 ff             	lea    -0x1(%eax),%edx
801055dc:	89 55 10             	mov    %edx,0x10(%ebp)
801055df:	85 c0                	test   %eax,%eax
801055e1:	7f e7                	jg     801055ca <strncpy+0x3a>
  return os;
801055e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801055e6:	c9                   	leave  
801055e7:	c3                   	ret    

801055e8 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801055e8:	55                   	push   %ebp
801055e9:	89 e5                	mov    %esp,%ebp
801055eb:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801055ee:	8b 45 08             	mov    0x8(%ebp),%eax
801055f1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801055f4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801055f8:	7f 05                	jg     801055ff <safestrcpy+0x17>
    return os;
801055fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055fd:	eb 32                	jmp    80105631 <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
801055ff:	90                   	nop
80105600:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105604:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105608:	7e 1e                	jle    80105628 <safestrcpy+0x40>
8010560a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010560d:	8d 42 01             	lea    0x1(%edx),%eax
80105610:	89 45 0c             	mov    %eax,0xc(%ebp)
80105613:	8b 45 08             	mov    0x8(%ebp),%eax
80105616:	8d 48 01             	lea    0x1(%eax),%ecx
80105619:	89 4d 08             	mov    %ecx,0x8(%ebp)
8010561c:	0f b6 12             	movzbl (%edx),%edx
8010561f:	88 10                	mov    %dl,(%eax)
80105621:	0f b6 00             	movzbl (%eax),%eax
80105624:	84 c0                	test   %al,%al
80105626:	75 d8                	jne    80105600 <safestrcpy+0x18>
    ;
  *s = 0;
80105628:	8b 45 08             	mov    0x8(%ebp),%eax
8010562b:	c6 00 00             	movb   $0x0,(%eax)
  return os;
8010562e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105631:	c9                   	leave  
80105632:	c3                   	ret    

80105633 <strlen>:

int
strlen(const char *s)
{
80105633:	55                   	push   %ebp
80105634:	89 e5                	mov    %esp,%ebp
80105636:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105639:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105640:	eb 04                	jmp    80105646 <strlen+0x13>
80105642:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105646:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105649:	8b 45 08             	mov    0x8(%ebp),%eax
8010564c:	01 d0                	add    %edx,%eax
8010564e:	0f b6 00             	movzbl (%eax),%eax
80105651:	84 c0                	test   %al,%al
80105653:	75 ed                	jne    80105642 <strlen+0xf>
    ;
  return n;
80105655:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105658:	c9                   	leave  
80105659:	c3                   	ret    

8010565a <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010565a:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
8010565e:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
80105662:	55                   	push   %ebp
  pushl %ebx
80105663:	53                   	push   %ebx
  pushl %esi
80105664:	56                   	push   %esi
  pushl %edi
80105665:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105666:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105668:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
8010566a:	5f                   	pop    %edi
  popl %esi
8010566b:	5e                   	pop    %esi
  popl %ebx
8010566c:	5b                   	pop    %ebx
  popl %ebp
8010566d:	5d                   	pop    %ebp
  ret
8010566e:	c3                   	ret    

8010566f <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
8010566f:	55                   	push   %ebp
80105670:	89 e5                	mov    %esp,%ebp
80105672:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80105675:	e8 1f ec ff ff       	call   80104299 <myproc>
8010567a:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
8010567d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105680:	8b 00                	mov    (%eax),%eax
80105682:	39 45 08             	cmp    %eax,0x8(%ebp)
80105685:	73 0f                	jae    80105696 <fetchint+0x27>
80105687:	8b 45 08             	mov    0x8(%ebp),%eax
8010568a:	8d 50 04             	lea    0x4(%eax),%edx
8010568d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105690:	8b 00                	mov    (%eax),%eax
80105692:	39 c2                	cmp    %eax,%edx
80105694:	76 07                	jbe    8010569d <fetchint+0x2e>
    return -1;
80105696:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010569b:	eb 0f                	jmp    801056ac <fetchint+0x3d>
  *ip = *(int*)(addr);
8010569d:	8b 45 08             	mov    0x8(%ebp),%eax
801056a0:	8b 10                	mov    (%eax),%edx
801056a2:	8b 45 0c             	mov    0xc(%ebp),%eax
801056a5:	89 10                	mov    %edx,(%eax)
  return 0;
801056a7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801056ac:	c9                   	leave  
801056ad:	c3                   	ret    

801056ae <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801056ae:	55                   	push   %ebp
801056af:	89 e5                	mov    %esp,%ebp
801056b1:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
801056b4:	e8 e0 eb ff ff       	call   80104299 <myproc>
801056b9:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
801056bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056bf:	8b 00                	mov    (%eax),%eax
801056c1:	39 45 08             	cmp    %eax,0x8(%ebp)
801056c4:	72 07                	jb     801056cd <fetchstr+0x1f>
    return -1;
801056c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056cb:	eb 41                	jmp    8010570e <fetchstr+0x60>
  *pp = (char*)addr;
801056cd:	8b 55 08             	mov    0x8(%ebp),%edx
801056d0:	8b 45 0c             	mov    0xc(%ebp),%eax
801056d3:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
801056d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056d8:	8b 00                	mov    (%eax),%eax
801056da:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
801056dd:	8b 45 0c             	mov    0xc(%ebp),%eax
801056e0:	8b 00                	mov    (%eax),%eax
801056e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801056e5:	eb 1a                	jmp    80105701 <fetchstr+0x53>
    if(*s == 0)
801056e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056ea:	0f b6 00             	movzbl (%eax),%eax
801056ed:	84 c0                	test   %al,%al
801056ef:	75 0c                	jne    801056fd <fetchstr+0x4f>
      return s - *pp;
801056f1:	8b 45 0c             	mov    0xc(%ebp),%eax
801056f4:	8b 10                	mov    (%eax),%edx
801056f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056f9:	29 d0                	sub    %edx,%eax
801056fb:	eb 11                	jmp    8010570e <fetchstr+0x60>
  for(s = *pp; s < ep; s++){
801056fd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105701:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105704:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105707:	72 de                	jb     801056e7 <fetchstr+0x39>
  }
  return -1;
80105709:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010570e:	c9                   	leave  
8010570f:	c3                   	ret    

80105710 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105710:	55                   	push   %ebp
80105711:	89 e5                	mov    %esp,%ebp
80105713:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105716:	e8 7e eb ff ff       	call   80104299 <myproc>
8010571b:	8b 40 18             	mov    0x18(%eax),%eax
8010571e:	8b 50 44             	mov    0x44(%eax),%edx
80105721:	8b 45 08             	mov    0x8(%ebp),%eax
80105724:	c1 e0 02             	shl    $0x2,%eax
80105727:	01 d0                	add    %edx,%eax
80105729:	83 c0 04             	add    $0x4,%eax
8010572c:	83 ec 08             	sub    $0x8,%esp
8010572f:	ff 75 0c             	push   0xc(%ebp)
80105732:	50                   	push   %eax
80105733:	e8 37 ff ff ff       	call   8010566f <fetchint>
80105738:	83 c4 10             	add    $0x10,%esp
}
8010573b:	c9                   	leave  
8010573c:	c3                   	ret    

8010573d <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
8010573d:	55                   	push   %ebp
8010573e:	89 e5                	mov    %esp,%ebp
80105740:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
80105743:	e8 51 eb ff ff       	call   80104299 <myproc>
80105748:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
8010574b:	83 ec 08             	sub    $0x8,%esp
8010574e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105751:	50                   	push   %eax
80105752:	ff 75 08             	push   0x8(%ebp)
80105755:	e8 b6 ff ff ff       	call   80105710 <argint>
8010575a:	83 c4 10             	add    $0x10,%esp
8010575d:	85 c0                	test   %eax,%eax
8010575f:	79 07                	jns    80105768 <argptr+0x2b>
    return -1;
80105761:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105766:	eb 3b                	jmp    801057a3 <argptr+0x66>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80105768:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010576c:	78 1f                	js     8010578d <argptr+0x50>
8010576e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105771:	8b 00                	mov    (%eax),%eax
80105773:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105776:	39 d0                	cmp    %edx,%eax
80105778:	76 13                	jbe    8010578d <argptr+0x50>
8010577a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010577d:	89 c2                	mov    %eax,%edx
8010577f:	8b 45 10             	mov    0x10(%ebp),%eax
80105782:	01 c2                	add    %eax,%edx
80105784:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105787:	8b 00                	mov    (%eax),%eax
80105789:	39 c2                	cmp    %eax,%edx
8010578b:	76 07                	jbe    80105794 <argptr+0x57>
    return -1;
8010578d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105792:	eb 0f                	jmp    801057a3 <argptr+0x66>
  *pp = (char*)i;
80105794:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105797:	89 c2                	mov    %eax,%edx
80105799:	8b 45 0c             	mov    0xc(%ebp),%eax
8010579c:	89 10                	mov    %edx,(%eax)
  return 0;
8010579e:	b8 00 00 00 00       	mov    $0x0,%eax
}
801057a3:	c9                   	leave  
801057a4:	c3                   	ret    

801057a5 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801057a5:	55                   	push   %ebp
801057a6:	89 e5                	mov    %esp,%ebp
801057a8:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
801057ab:	83 ec 08             	sub    $0x8,%esp
801057ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
801057b1:	50                   	push   %eax
801057b2:	ff 75 08             	push   0x8(%ebp)
801057b5:	e8 56 ff ff ff       	call   80105710 <argint>
801057ba:	83 c4 10             	add    $0x10,%esp
801057bd:	85 c0                	test   %eax,%eax
801057bf:	79 07                	jns    801057c8 <argstr+0x23>
    return -1;
801057c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057c6:	eb 12                	jmp    801057da <argstr+0x35>
  return fetchstr(addr, pp);
801057c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057cb:	83 ec 08             	sub    $0x8,%esp
801057ce:	ff 75 0c             	push   0xc(%ebp)
801057d1:	50                   	push   %eax
801057d2:	e8 d7 fe ff ff       	call   801056ae <fetchstr>
801057d7:	83 c4 10             	add    $0x10,%esp
}
801057da:	c9                   	leave  
801057db:	c3                   	ret    

801057dc <syscall>:
[SYS_getschedstate] sys_getschedstate,
};

void
syscall(void)
{
801057dc:	55                   	push   %ebp
801057dd:	89 e5                	mov    %esp,%ebp
801057df:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
801057e2:	e8 b2 ea ff ff       	call   80104299 <myproc>
801057e7:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
801057ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057ed:	8b 40 18             	mov    0x18(%eax),%eax
801057f0:	8b 40 1c             	mov    0x1c(%eax),%eax
801057f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801057f6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801057fa:	7e 2f                	jle    8010582b <syscall+0x4f>
801057fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057ff:	83 f8 17             	cmp    $0x17,%eax
80105802:	77 27                	ja     8010582b <syscall+0x4f>
80105804:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105807:	8b 04 85 20 b0 10 80 	mov    -0x7fef4fe0(,%eax,4),%eax
8010580e:	85 c0                	test   %eax,%eax
80105810:	74 19                	je     8010582b <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
80105812:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105815:	8b 04 85 20 b0 10 80 	mov    -0x7fef4fe0(,%eax,4),%eax
8010581c:	ff d0                	call   *%eax
8010581e:	89 c2                	mov    %eax,%edx
80105820:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105823:	8b 40 18             	mov    0x18(%eax),%eax
80105826:	89 50 1c             	mov    %edx,0x1c(%eax)
80105829:	eb 2c                	jmp    80105857 <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
8010582b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010582e:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80105831:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105834:	8b 40 10             	mov    0x10(%eax),%eax
80105837:	ff 75 f0             	push   -0x10(%ebp)
8010583a:	52                   	push   %edx
8010583b:	50                   	push   %eax
8010583c:	68 04 8a 10 80       	push   $0x80108a04
80105841:	e8 ba ab ff ff       	call   80100400 <cprintf>
80105846:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80105849:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010584c:	8b 40 18             	mov    0x18(%eax),%eax
8010584f:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105856:	90                   	nop
80105857:	90                   	nop
80105858:	c9                   	leave  
80105859:	c3                   	ret    

8010585a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
8010585a:	55                   	push   %ebp
8010585b:	89 e5                	mov    %esp,%ebp
8010585d:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105860:	83 ec 08             	sub    $0x8,%esp
80105863:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105866:	50                   	push   %eax
80105867:	ff 75 08             	push   0x8(%ebp)
8010586a:	e8 a1 fe ff ff       	call   80105710 <argint>
8010586f:	83 c4 10             	add    $0x10,%esp
80105872:	85 c0                	test   %eax,%eax
80105874:	79 07                	jns    8010587d <argfd+0x23>
    return -1;
80105876:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010587b:	eb 4f                	jmp    801058cc <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
8010587d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105880:	85 c0                	test   %eax,%eax
80105882:	78 20                	js     801058a4 <argfd+0x4a>
80105884:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105887:	83 f8 0f             	cmp    $0xf,%eax
8010588a:	7f 18                	jg     801058a4 <argfd+0x4a>
8010588c:	e8 08 ea ff ff       	call   80104299 <myproc>
80105891:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105894:	83 c2 08             	add    $0x8,%edx
80105897:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010589b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010589e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058a2:	75 07                	jne    801058ab <argfd+0x51>
    return -1;
801058a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058a9:	eb 21                	jmp    801058cc <argfd+0x72>
  if(pfd)
801058ab:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801058af:	74 08                	je     801058b9 <argfd+0x5f>
    *pfd = fd;
801058b1:	8b 55 f0             	mov    -0x10(%ebp),%edx
801058b4:	8b 45 0c             	mov    0xc(%ebp),%eax
801058b7:	89 10                	mov    %edx,(%eax)
  if(pf)
801058b9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801058bd:	74 08                	je     801058c7 <argfd+0x6d>
    *pf = f;
801058bf:	8b 45 10             	mov    0x10(%ebp),%eax
801058c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801058c5:	89 10                	mov    %edx,(%eax)
  return 0;
801058c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801058cc:	c9                   	leave  
801058cd:	c3                   	ret    

801058ce <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801058ce:	55                   	push   %ebp
801058cf:	89 e5                	mov    %esp,%ebp
801058d1:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
801058d4:	e8 c0 e9 ff ff       	call   80104299 <myproc>
801058d9:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
801058dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801058e3:	eb 2a                	jmp    8010590f <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
801058e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801058eb:	83 c2 08             	add    $0x8,%edx
801058ee:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801058f2:	85 c0                	test   %eax,%eax
801058f4:	75 15                	jne    8010590b <fdalloc+0x3d>
      curproc->ofile[fd] = f;
801058f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801058fc:	8d 4a 08             	lea    0x8(%edx),%ecx
801058ff:	8b 55 08             	mov    0x8(%ebp),%edx
80105902:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105906:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105909:	eb 0f                	jmp    8010591a <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
8010590b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010590f:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105913:	7e d0                	jle    801058e5 <fdalloc+0x17>
    }
  }
  return -1;
80105915:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010591a:	c9                   	leave  
8010591b:	c3                   	ret    

8010591c <sys_dup>:

int
sys_dup(void)
{
8010591c:	55                   	push   %ebp
8010591d:	89 e5                	mov    %esp,%ebp
8010591f:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105922:	83 ec 04             	sub    $0x4,%esp
80105925:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105928:	50                   	push   %eax
80105929:	6a 00                	push   $0x0
8010592b:	6a 00                	push   $0x0
8010592d:	e8 28 ff ff ff       	call   8010585a <argfd>
80105932:	83 c4 10             	add    $0x10,%esp
80105935:	85 c0                	test   %eax,%eax
80105937:	79 07                	jns    80105940 <sys_dup+0x24>
    return -1;
80105939:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010593e:	eb 31                	jmp    80105971 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105940:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105943:	83 ec 0c             	sub    $0xc,%esp
80105946:	50                   	push   %eax
80105947:	e8 82 ff ff ff       	call   801058ce <fdalloc>
8010594c:	83 c4 10             	add    $0x10,%esp
8010594f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105952:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105956:	79 07                	jns    8010595f <sys_dup+0x43>
    return -1;
80105958:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010595d:	eb 12                	jmp    80105971 <sys_dup+0x55>
  filedup(f);
8010595f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105962:	83 ec 0c             	sub    $0xc,%esp
80105965:	50                   	push   %eax
80105966:	e8 22 b7 ff ff       	call   8010108d <filedup>
8010596b:	83 c4 10             	add    $0x10,%esp
  return fd;
8010596e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105971:	c9                   	leave  
80105972:	c3                   	ret    

80105973 <sys_read>:

int
sys_read(void)
{
80105973:	55                   	push   %ebp
80105974:	89 e5                	mov    %esp,%ebp
80105976:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105979:	83 ec 04             	sub    $0x4,%esp
8010597c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010597f:	50                   	push   %eax
80105980:	6a 00                	push   $0x0
80105982:	6a 00                	push   $0x0
80105984:	e8 d1 fe ff ff       	call   8010585a <argfd>
80105989:	83 c4 10             	add    $0x10,%esp
8010598c:	85 c0                	test   %eax,%eax
8010598e:	78 2e                	js     801059be <sys_read+0x4b>
80105990:	83 ec 08             	sub    $0x8,%esp
80105993:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105996:	50                   	push   %eax
80105997:	6a 02                	push   $0x2
80105999:	e8 72 fd ff ff       	call   80105710 <argint>
8010599e:	83 c4 10             	add    $0x10,%esp
801059a1:	85 c0                	test   %eax,%eax
801059a3:	78 19                	js     801059be <sys_read+0x4b>
801059a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059a8:	83 ec 04             	sub    $0x4,%esp
801059ab:	50                   	push   %eax
801059ac:	8d 45 ec             	lea    -0x14(%ebp),%eax
801059af:	50                   	push   %eax
801059b0:	6a 01                	push   $0x1
801059b2:	e8 86 fd ff ff       	call   8010573d <argptr>
801059b7:	83 c4 10             	add    $0x10,%esp
801059ba:	85 c0                	test   %eax,%eax
801059bc:	79 07                	jns    801059c5 <sys_read+0x52>
    return -1;
801059be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059c3:	eb 17                	jmp    801059dc <sys_read+0x69>
  return fileread(f, p, n);
801059c5:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801059c8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801059cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059ce:	83 ec 04             	sub    $0x4,%esp
801059d1:	51                   	push   %ecx
801059d2:	52                   	push   %edx
801059d3:	50                   	push   %eax
801059d4:	e8 44 b8 ff ff       	call   8010121d <fileread>
801059d9:	83 c4 10             	add    $0x10,%esp
}
801059dc:	c9                   	leave  
801059dd:	c3                   	ret    

801059de <sys_write>:

int
sys_write(void)
{
801059de:	55                   	push   %ebp
801059df:	89 e5                	mov    %esp,%ebp
801059e1:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801059e4:	83 ec 04             	sub    $0x4,%esp
801059e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
801059ea:	50                   	push   %eax
801059eb:	6a 00                	push   $0x0
801059ed:	6a 00                	push   $0x0
801059ef:	e8 66 fe ff ff       	call   8010585a <argfd>
801059f4:	83 c4 10             	add    $0x10,%esp
801059f7:	85 c0                	test   %eax,%eax
801059f9:	78 2e                	js     80105a29 <sys_write+0x4b>
801059fb:	83 ec 08             	sub    $0x8,%esp
801059fe:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a01:	50                   	push   %eax
80105a02:	6a 02                	push   $0x2
80105a04:	e8 07 fd ff ff       	call   80105710 <argint>
80105a09:	83 c4 10             	add    $0x10,%esp
80105a0c:	85 c0                	test   %eax,%eax
80105a0e:	78 19                	js     80105a29 <sys_write+0x4b>
80105a10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a13:	83 ec 04             	sub    $0x4,%esp
80105a16:	50                   	push   %eax
80105a17:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105a1a:	50                   	push   %eax
80105a1b:	6a 01                	push   $0x1
80105a1d:	e8 1b fd ff ff       	call   8010573d <argptr>
80105a22:	83 c4 10             	add    $0x10,%esp
80105a25:	85 c0                	test   %eax,%eax
80105a27:	79 07                	jns    80105a30 <sys_write+0x52>
    return -1;
80105a29:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a2e:	eb 17                	jmp    80105a47 <sys_write+0x69>
  return filewrite(f, p, n);
80105a30:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105a33:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105a36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a39:	83 ec 04             	sub    $0x4,%esp
80105a3c:	51                   	push   %ecx
80105a3d:	52                   	push   %edx
80105a3e:	50                   	push   %eax
80105a3f:	e8 91 b8 ff ff       	call   801012d5 <filewrite>
80105a44:	83 c4 10             	add    $0x10,%esp
}
80105a47:	c9                   	leave  
80105a48:	c3                   	ret    

80105a49 <sys_close>:

int
sys_close(void)
{
80105a49:	55                   	push   %ebp
80105a4a:	89 e5                	mov    %esp,%ebp
80105a4c:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105a4f:	83 ec 04             	sub    $0x4,%esp
80105a52:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a55:	50                   	push   %eax
80105a56:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a59:	50                   	push   %eax
80105a5a:	6a 00                	push   $0x0
80105a5c:	e8 f9 fd ff ff       	call   8010585a <argfd>
80105a61:	83 c4 10             	add    $0x10,%esp
80105a64:	85 c0                	test   %eax,%eax
80105a66:	79 07                	jns    80105a6f <sys_close+0x26>
    return -1;
80105a68:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a6d:	eb 27                	jmp    80105a96 <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
80105a6f:	e8 25 e8 ff ff       	call   80104299 <myproc>
80105a74:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a77:	83 c2 08             	add    $0x8,%edx
80105a7a:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105a81:	00 
  fileclose(f);
80105a82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a85:	83 ec 0c             	sub    $0xc,%esp
80105a88:	50                   	push   %eax
80105a89:	e8 50 b6 ff ff       	call   801010de <fileclose>
80105a8e:	83 c4 10             	add    $0x10,%esp
  return 0;
80105a91:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a96:	c9                   	leave  
80105a97:	c3                   	ret    

80105a98 <sys_fstat>:

int
sys_fstat(void)
{
80105a98:	55                   	push   %ebp
80105a99:	89 e5                	mov    %esp,%ebp
80105a9b:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105a9e:	83 ec 04             	sub    $0x4,%esp
80105aa1:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105aa4:	50                   	push   %eax
80105aa5:	6a 00                	push   $0x0
80105aa7:	6a 00                	push   $0x0
80105aa9:	e8 ac fd ff ff       	call   8010585a <argfd>
80105aae:	83 c4 10             	add    $0x10,%esp
80105ab1:	85 c0                	test   %eax,%eax
80105ab3:	78 17                	js     80105acc <sys_fstat+0x34>
80105ab5:	83 ec 04             	sub    $0x4,%esp
80105ab8:	6a 14                	push   $0x14
80105aba:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105abd:	50                   	push   %eax
80105abe:	6a 01                	push   $0x1
80105ac0:	e8 78 fc ff ff       	call   8010573d <argptr>
80105ac5:	83 c4 10             	add    $0x10,%esp
80105ac8:	85 c0                	test   %eax,%eax
80105aca:	79 07                	jns    80105ad3 <sys_fstat+0x3b>
    return -1;
80105acc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ad1:	eb 13                	jmp    80105ae6 <sys_fstat+0x4e>
  return filestat(f, st);
80105ad3:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105ad6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ad9:	83 ec 08             	sub    $0x8,%esp
80105adc:	52                   	push   %edx
80105add:	50                   	push   %eax
80105ade:	e8 e3 b6 ff ff       	call   801011c6 <filestat>
80105ae3:	83 c4 10             	add    $0x10,%esp
}
80105ae6:	c9                   	leave  
80105ae7:	c3                   	ret    

80105ae8 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105ae8:	55                   	push   %ebp
80105ae9:	89 e5                	mov    %esp,%ebp
80105aeb:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105aee:	83 ec 08             	sub    $0x8,%esp
80105af1:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105af4:	50                   	push   %eax
80105af5:	6a 00                	push   $0x0
80105af7:	e8 a9 fc ff ff       	call   801057a5 <argstr>
80105afc:	83 c4 10             	add    $0x10,%esp
80105aff:	85 c0                	test   %eax,%eax
80105b01:	78 15                	js     80105b18 <sys_link+0x30>
80105b03:	83 ec 08             	sub    $0x8,%esp
80105b06:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105b09:	50                   	push   %eax
80105b0a:	6a 01                	push   $0x1
80105b0c:	e8 94 fc ff ff       	call   801057a5 <argstr>
80105b11:	83 c4 10             	add    $0x10,%esp
80105b14:	85 c0                	test   %eax,%eax
80105b16:	79 0a                	jns    80105b22 <sys_link+0x3a>
    return -1;
80105b18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b1d:	e9 68 01 00 00       	jmp    80105c8a <sys_link+0x1a2>

  begin_op();
80105b22:	e8 0b da ff ff       	call   80103532 <begin_op>
  if((ip = namei(old)) == 0){
80105b27:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105b2a:	83 ec 0c             	sub    $0xc,%esp
80105b2d:	50                   	push   %eax
80105b2e:	e8 1a ca ff ff       	call   8010254d <namei>
80105b33:	83 c4 10             	add    $0x10,%esp
80105b36:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b39:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b3d:	75 0f                	jne    80105b4e <sys_link+0x66>
    end_op();
80105b3f:	e8 7a da ff ff       	call   801035be <end_op>
    return -1;
80105b44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b49:	e9 3c 01 00 00       	jmp    80105c8a <sys_link+0x1a2>
  }

  ilock(ip);
80105b4e:	83 ec 0c             	sub    $0xc,%esp
80105b51:	ff 75 f4             	push   -0xc(%ebp)
80105b54:	e8 c1 be ff ff       	call   80101a1a <ilock>
80105b59:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105b5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b5f:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105b63:	66 83 f8 01          	cmp    $0x1,%ax
80105b67:	75 1d                	jne    80105b86 <sys_link+0x9e>
    iunlockput(ip);
80105b69:	83 ec 0c             	sub    $0xc,%esp
80105b6c:	ff 75 f4             	push   -0xc(%ebp)
80105b6f:	e8 d7 c0 ff ff       	call   80101c4b <iunlockput>
80105b74:	83 c4 10             	add    $0x10,%esp
    end_op();
80105b77:	e8 42 da ff ff       	call   801035be <end_op>
    return -1;
80105b7c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b81:	e9 04 01 00 00       	jmp    80105c8a <sys_link+0x1a2>
  }

  ip->nlink++;
80105b86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b89:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105b8d:	83 c0 01             	add    $0x1,%eax
80105b90:	89 c2                	mov    %eax,%edx
80105b92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b95:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105b99:	83 ec 0c             	sub    $0xc,%esp
80105b9c:	ff 75 f4             	push   -0xc(%ebp)
80105b9f:	e8 99 bc ff ff       	call   8010183d <iupdate>
80105ba4:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105ba7:	83 ec 0c             	sub    $0xc,%esp
80105baa:	ff 75 f4             	push   -0xc(%ebp)
80105bad:	e8 7b bf ff ff       	call   80101b2d <iunlock>
80105bb2:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105bb5:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105bb8:	83 ec 08             	sub    $0x8,%esp
80105bbb:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105bbe:	52                   	push   %edx
80105bbf:	50                   	push   %eax
80105bc0:	e8 a4 c9 ff ff       	call   80102569 <nameiparent>
80105bc5:	83 c4 10             	add    $0x10,%esp
80105bc8:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105bcb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105bcf:	74 71                	je     80105c42 <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105bd1:	83 ec 0c             	sub    $0xc,%esp
80105bd4:	ff 75 f0             	push   -0x10(%ebp)
80105bd7:	e8 3e be ff ff       	call   80101a1a <ilock>
80105bdc:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105bdf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105be2:	8b 10                	mov    (%eax),%edx
80105be4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105be7:	8b 00                	mov    (%eax),%eax
80105be9:	39 c2                	cmp    %eax,%edx
80105beb:	75 1d                	jne    80105c0a <sys_link+0x122>
80105bed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bf0:	8b 40 04             	mov    0x4(%eax),%eax
80105bf3:	83 ec 04             	sub    $0x4,%esp
80105bf6:	50                   	push   %eax
80105bf7:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105bfa:	50                   	push   %eax
80105bfb:	ff 75 f0             	push   -0x10(%ebp)
80105bfe:	e8 b3 c6 ff ff       	call   801022b6 <dirlink>
80105c03:	83 c4 10             	add    $0x10,%esp
80105c06:	85 c0                	test   %eax,%eax
80105c08:	79 10                	jns    80105c1a <sys_link+0x132>
    iunlockput(dp);
80105c0a:	83 ec 0c             	sub    $0xc,%esp
80105c0d:	ff 75 f0             	push   -0x10(%ebp)
80105c10:	e8 36 c0 ff ff       	call   80101c4b <iunlockput>
80105c15:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105c18:	eb 29                	jmp    80105c43 <sys_link+0x15b>
  }
  iunlockput(dp);
80105c1a:	83 ec 0c             	sub    $0xc,%esp
80105c1d:	ff 75 f0             	push   -0x10(%ebp)
80105c20:	e8 26 c0 ff ff       	call   80101c4b <iunlockput>
80105c25:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105c28:	83 ec 0c             	sub    $0xc,%esp
80105c2b:	ff 75 f4             	push   -0xc(%ebp)
80105c2e:	e8 48 bf ff ff       	call   80101b7b <iput>
80105c33:	83 c4 10             	add    $0x10,%esp

  end_op();
80105c36:	e8 83 d9 ff ff       	call   801035be <end_op>

  return 0;
80105c3b:	b8 00 00 00 00       	mov    $0x0,%eax
80105c40:	eb 48                	jmp    80105c8a <sys_link+0x1a2>
    goto bad;
80105c42:	90                   	nop

bad:
  ilock(ip);
80105c43:	83 ec 0c             	sub    $0xc,%esp
80105c46:	ff 75 f4             	push   -0xc(%ebp)
80105c49:	e8 cc bd ff ff       	call   80101a1a <ilock>
80105c4e:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105c51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c54:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105c58:	83 e8 01             	sub    $0x1,%eax
80105c5b:	89 c2                	mov    %eax,%edx
80105c5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c60:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105c64:	83 ec 0c             	sub    $0xc,%esp
80105c67:	ff 75 f4             	push   -0xc(%ebp)
80105c6a:	e8 ce bb ff ff       	call   8010183d <iupdate>
80105c6f:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105c72:	83 ec 0c             	sub    $0xc,%esp
80105c75:	ff 75 f4             	push   -0xc(%ebp)
80105c78:	e8 ce bf ff ff       	call   80101c4b <iunlockput>
80105c7d:	83 c4 10             	add    $0x10,%esp
  end_op();
80105c80:	e8 39 d9 ff ff       	call   801035be <end_op>
  return -1;
80105c85:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105c8a:	c9                   	leave  
80105c8b:	c3                   	ret    

80105c8c <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105c8c:	55                   	push   %ebp
80105c8d:	89 e5                	mov    %esp,%ebp
80105c8f:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105c92:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105c99:	eb 40                	jmp    80105cdb <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105c9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c9e:	6a 10                	push   $0x10
80105ca0:	50                   	push   %eax
80105ca1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105ca4:	50                   	push   %eax
80105ca5:	ff 75 08             	push   0x8(%ebp)
80105ca8:	e8 59 c2 ff ff       	call   80101f06 <readi>
80105cad:	83 c4 10             	add    $0x10,%esp
80105cb0:	83 f8 10             	cmp    $0x10,%eax
80105cb3:	74 0d                	je     80105cc2 <isdirempty+0x36>
      panic("isdirempty: readi");
80105cb5:	83 ec 0c             	sub    $0xc,%esp
80105cb8:	68 20 8a 10 80       	push   $0x80108a20
80105cbd:	e8 f3 a8 ff ff       	call   801005b5 <panic>
    if(de.inum != 0)
80105cc2:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105cc6:	66 85 c0             	test   %ax,%ax
80105cc9:	74 07                	je     80105cd2 <isdirempty+0x46>
      return 0;
80105ccb:	b8 00 00 00 00       	mov    $0x0,%eax
80105cd0:	eb 1b                	jmp    80105ced <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105cd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cd5:	83 c0 10             	add    $0x10,%eax
80105cd8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105cdb:	8b 45 08             	mov    0x8(%ebp),%eax
80105cde:	8b 50 58             	mov    0x58(%eax),%edx
80105ce1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ce4:	39 c2                	cmp    %eax,%edx
80105ce6:	77 b3                	ja     80105c9b <isdirempty+0xf>
  }
  return 1;
80105ce8:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105ced:	c9                   	leave  
80105cee:	c3                   	ret    

80105cef <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105cef:	55                   	push   %ebp
80105cf0:	89 e5                	mov    %esp,%ebp
80105cf2:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105cf5:	83 ec 08             	sub    $0x8,%esp
80105cf8:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105cfb:	50                   	push   %eax
80105cfc:	6a 00                	push   $0x0
80105cfe:	e8 a2 fa ff ff       	call   801057a5 <argstr>
80105d03:	83 c4 10             	add    $0x10,%esp
80105d06:	85 c0                	test   %eax,%eax
80105d08:	79 0a                	jns    80105d14 <sys_unlink+0x25>
    return -1;
80105d0a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d0f:	e9 bf 01 00 00       	jmp    80105ed3 <sys_unlink+0x1e4>

  begin_op();
80105d14:	e8 19 d8 ff ff       	call   80103532 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105d19:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105d1c:	83 ec 08             	sub    $0x8,%esp
80105d1f:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105d22:	52                   	push   %edx
80105d23:	50                   	push   %eax
80105d24:	e8 40 c8 ff ff       	call   80102569 <nameiparent>
80105d29:	83 c4 10             	add    $0x10,%esp
80105d2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d2f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d33:	75 0f                	jne    80105d44 <sys_unlink+0x55>
    end_op();
80105d35:	e8 84 d8 ff ff       	call   801035be <end_op>
    return -1;
80105d3a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d3f:	e9 8f 01 00 00       	jmp    80105ed3 <sys_unlink+0x1e4>
  }

  ilock(dp);
80105d44:	83 ec 0c             	sub    $0xc,%esp
80105d47:	ff 75 f4             	push   -0xc(%ebp)
80105d4a:	e8 cb bc ff ff       	call   80101a1a <ilock>
80105d4f:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105d52:	83 ec 08             	sub    $0x8,%esp
80105d55:	68 32 8a 10 80       	push   $0x80108a32
80105d5a:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105d5d:	50                   	push   %eax
80105d5e:	e8 7e c4 ff ff       	call   801021e1 <namecmp>
80105d63:	83 c4 10             	add    $0x10,%esp
80105d66:	85 c0                	test   %eax,%eax
80105d68:	0f 84 49 01 00 00    	je     80105eb7 <sys_unlink+0x1c8>
80105d6e:	83 ec 08             	sub    $0x8,%esp
80105d71:	68 34 8a 10 80       	push   $0x80108a34
80105d76:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105d79:	50                   	push   %eax
80105d7a:	e8 62 c4 ff ff       	call   801021e1 <namecmp>
80105d7f:	83 c4 10             	add    $0x10,%esp
80105d82:	85 c0                	test   %eax,%eax
80105d84:	0f 84 2d 01 00 00    	je     80105eb7 <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105d8a:	83 ec 04             	sub    $0x4,%esp
80105d8d:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105d90:	50                   	push   %eax
80105d91:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105d94:	50                   	push   %eax
80105d95:	ff 75 f4             	push   -0xc(%ebp)
80105d98:	e8 5f c4 ff ff       	call   801021fc <dirlookup>
80105d9d:	83 c4 10             	add    $0x10,%esp
80105da0:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105da3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105da7:	0f 84 0d 01 00 00    	je     80105eba <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
80105dad:	83 ec 0c             	sub    $0xc,%esp
80105db0:	ff 75 f0             	push   -0x10(%ebp)
80105db3:	e8 62 bc ff ff       	call   80101a1a <ilock>
80105db8:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105dbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dbe:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105dc2:	66 85 c0             	test   %ax,%ax
80105dc5:	7f 0d                	jg     80105dd4 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80105dc7:	83 ec 0c             	sub    $0xc,%esp
80105dca:	68 37 8a 10 80       	push   $0x80108a37
80105dcf:	e8 e1 a7 ff ff       	call   801005b5 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105dd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dd7:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105ddb:	66 83 f8 01          	cmp    $0x1,%ax
80105ddf:	75 25                	jne    80105e06 <sys_unlink+0x117>
80105de1:	83 ec 0c             	sub    $0xc,%esp
80105de4:	ff 75 f0             	push   -0x10(%ebp)
80105de7:	e8 a0 fe ff ff       	call   80105c8c <isdirempty>
80105dec:	83 c4 10             	add    $0x10,%esp
80105def:	85 c0                	test   %eax,%eax
80105df1:	75 13                	jne    80105e06 <sys_unlink+0x117>
    iunlockput(ip);
80105df3:	83 ec 0c             	sub    $0xc,%esp
80105df6:	ff 75 f0             	push   -0x10(%ebp)
80105df9:	e8 4d be ff ff       	call   80101c4b <iunlockput>
80105dfe:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105e01:	e9 b5 00 00 00       	jmp    80105ebb <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
80105e06:	83 ec 04             	sub    $0x4,%esp
80105e09:	6a 10                	push   $0x10
80105e0b:	6a 00                	push   $0x0
80105e0d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105e10:	50                   	push   %eax
80105e11:	e8 cf f5 ff ff       	call   801053e5 <memset>
80105e16:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105e19:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105e1c:	6a 10                	push   $0x10
80105e1e:	50                   	push   %eax
80105e1f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105e22:	50                   	push   %eax
80105e23:	ff 75 f4             	push   -0xc(%ebp)
80105e26:	e8 30 c2 ff ff       	call   8010205b <writei>
80105e2b:	83 c4 10             	add    $0x10,%esp
80105e2e:	83 f8 10             	cmp    $0x10,%eax
80105e31:	74 0d                	je     80105e40 <sys_unlink+0x151>
    panic("unlink: writei");
80105e33:	83 ec 0c             	sub    $0xc,%esp
80105e36:	68 49 8a 10 80       	push   $0x80108a49
80105e3b:	e8 75 a7 ff ff       	call   801005b5 <panic>
  if(ip->type == T_DIR){
80105e40:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e43:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105e47:	66 83 f8 01          	cmp    $0x1,%ax
80105e4b:	75 21                	jne    80105e6e <sys_unlink+0x17f>
    dp->nlink--;
80105e4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e50:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105e54:	83 e8 01             	sub    $0x1,%eax
80105e57:	89 c2                	mov    %eax,%edx
80105e59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e5c:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105e60:	83 ec 0c             	sub    $0xc,%esp
80105e63:	ff 75 f4             	push   -0xc(%ebp)
80105e66:	e8 d2 b9 ff ff       	call   8010183d <iupdate>
80105e6b:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105e6e:	83 ec 0c             	sub    $0xc,%esp
80105e71:	ff 75 f4             	push   -0xc(%ebp)
80105e74:	e8 d2 bd ff ff       	call   80101c4b <iunlockput>
80105e79:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105e7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e7f:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105e83:	83 e8 01             	sub    $0x1,%eax
80105e86:	89 c2                	mov    %eax,%edx
80105e88:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e8b:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105e8f:	83 ec 0c             	sub    $0xc,%esp
80105e92:	ff 75 f0             	push   -0x10(%ebp)
80105e95:	e8 a3 b9 ff ff       	call   8010183d <iupdate>
80105e9a:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105e9d:	83 ec 0c             	sub    $0xc,%esp
80105ea0:	ff 75 f0             	push   -0x10(%ebp)
80105ea3:	e8 a3 bd ff ff       	call   80101c4b <iunlockput>
80105ea8:	83 c4 10             	add    $0x10,%esp

  end_op();
80105eab:	e8 0e d7 ff ff       	call   801035be <end_op>

  return 0;
80105eb0:	b8 00 00 00 00       	mov    $0x0,%eax
80105eb5:	eb 1c                	jmp    80105ed3 <sys_unlink+0x1e4>
    goto bad;
80105eb7:	90                   	nop
80105eb8:	eb 01                	jmp    80105ebb <sys_unlink+0x1cc>
    goto bad;
80105eba:	90                   	nop

bad:
  iunlockput(dp);
80105ebb:	83 ec 0c             	sub    $0xc,%esp
80105ebe:	ff 75 f4             	push   -0xc(%ebp)
80105ec1:	e8 85 bd ff ff       	call   80101c4b <iunlockput>
80105ec6:	83 c4 10             	add    $0x10,%esp
  end_op();
80105ec9:	e8 f0 d6 ff ff       	call   801035be <end_op>
  return -1;
80105ece:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105ed3:	c9                   	leave  
80105ed4:	c3                   	ret    

80105ed5 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105ed5:	55                   	push   %ebp
80105ed6:	89 e5                	mov    %esp,%ebp
80105ed8:	83 ec 38             	sub    $0x38,%esp
80105edb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105ede:	8b 55 10             	mov    0x10(%ebp),%edx
80105ee1:	8b 45 14             	mov    0x14(%ebp),%eax
80105ee4:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105ee8:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105eec:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105ef0:	83 ec 08             	sub    $0x8,%esp
80105ef3:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105ef6:	50                   	push   %eax
80105ef7:	ff 75 08             	push   0x8(%ebp)
80105efa:	e8 6a c6 ff ff       	call   80102569 <nameiparent>
80105eff:	83 c4 10             	add    $0x10,%esp
80105f02:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f05:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f09:	75 0a                	jne    80105f15 <create+0x40>
    return 0;
80105f0b:	b8 00 00 00 00       	mov    $0x0,%eax
80105f10:	e9 8e 01 00 00       	jmp    801060a3 <create+0x1ce>
  ilock(dp);
80105f15:	83 ec 0c             	sub    $0xc,%esp
80105f18:	ff 75 f4             	push   -0xc(%ebp)
80105f1b:	e8 fa ba ff ff       	call   80101a1a <ilock>
80105f20:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, 0)) != 0){
80105f23:	83 ec 04             	sub    $0x4,%esp
80105f26:	6a 00                	push   $0x0
80105f28:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105f2b:	50                   	push   %eax
80105f2c:	ff 75 f4             	push   -0xc(%ebp)
80105f2f:	e8 c8 c2 ff ff       	call   801021fc <dirlookup>
80105f34:	83 c4 10             	add    $0x10,%esp
80105f37:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f3a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f3e:	74 50                	je     80105f90 <create+0xbb>
    iunlockput(dp);
80105f40:	83 ec 0c             	sub    $0xc,%esp
80105f43:	ff 75 f4             	push   -0xc(%ebp)
80105f46:	e8 00 bd ff ff       	call   80101c4b <iunlockput>
80105f4b:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105f4e:	83 ec 0c             	sub    $0xc,%esp
80105f51:	ff 75 f0             	push   -0x10(%ebp)
80105f54:	e8 c1 ba ff ff       	call   80101a1a <ilock>
80105f59:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105f5c:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105f61:	75 15                	jne    80105f78 <create+0xa3>
80105f63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f66:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105f6a:	66 83 f8 02          	cmp    $0x2,%ax
80105f6e:	75 08                	jne    80105f78 <create+0xa3>
      return ip;
80105f70:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f73:	e9 2b 01 00 00       	jmp    801060a3 <create+0x1ce>
    iunlockput(ip);
80105f78:	83 ec 0c             	sub    $0xc,%esp
80105f7b:	ff 75 f0             	push   -0x10(%ebp)
80105f7e:	e8 c8 bc ff ff       	call   80101c4b <iunlockput>
80105f83:	83 c4 10             	add    $0x10,%esp
    return 0;
80105f86:	b8 00 00 00 00       	mov    $0x0,%eax
80105f8b:	e9 13 01 00 00       	jmp    801060a3 <create+0x1ce>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105f90:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105f94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f97:	8b 00                	mov    (%eax),%eax
80105f99:	83 ec 08             	sub    $0x8,%esp
80105f9c:	52                   	push   %edx
80105f9d:	50                   	push   %eax
80105f9e:	e8 c3 b7 ff ff       	call   80101766 <ialloc>
80105fa3:	83 c4 10             	add    $0x10,%esp
80105fa6:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105fa9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105fad:	75 0d                	jne    80105fbc <create+0xe7>
    panic("create: ialloc");
80105faf:	83 ec 0c             	sub    $0xc,%esp
80105fb2:	68 58 8a 10 80       	push   $0x80108a58
80105fb7:	e8 f9 a5 ff ff       	call   801005b5 <panic>

  ilock(ip);
80105fbc:	83 ec 0c             	sub    $0xc,%esp
80105fbf:	ff 75 f0             	push   -0x10(%ebp)
80105fc2:	e8 53 ba ff ff       	call   80101a1a <ilock>
80105fc7:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105fca:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fcd:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105fd1:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105fd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fd8:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105fdc:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105fe0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fe3:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105fe9:	83 ec 0c             	sub    $0xc,%esp
80105fec:	ff 75 f0             	push   -0x10(%ebp)
80105fef:	e8 49 b8 ff ff       	call   8010183d <iupdate>
80105ff4:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105ff7:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105ffc:	75 6a                	jne    80106068 <create+0x193>
    dp->nlink++;  // for ".."
80105ffe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106001:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80106005:	83 c0 01             	add    $0x1,%eax
80106008:	89 c2                	mov    %eax,%edx
8010600a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010600d:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80106011:	83 ec 0c             	sub    $0xc,%esp
80106014:	ff 75 f4             	push   -0xc(%ebp)
80106017:	e8 21 b8 ff ff       	call   8010183d <iupdate>
8010601c:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
8010601f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106022:	8b 40 04             	mov    0x4(%eax),%eax
80106025:	83 ec 04             	sub    $0x4,%esp
80106028:	50                   	push   %eax
80106029:	68 32 8a 10 80       	push   $0x80108a32
8010602e:	ff 75 f0             	push   -0x10(%ebp)
80106031:	e8 80 c2 ff ff       	call   801022b6 <dirlink>
80106036:	83 c4 10             	add    $0x10,%esp
80106039:	85 c0                	test   %eax,%eax
8010603b:	78 1e                	js     8010605b <create+0x186>
8010603d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106040:	8b 40 04             	mov    0x4(%eax),%eax
80106043:	83 ec 04             	sub    $0x4,%esp
80106046:	50                   	push   %eax
80106047:	68 34 8a 10 80       	push   $0x80108a34
8010604c:	ff 75 f0             	push   -0x10(%ebp)
8010604f:	e8 62 c2 ff ff       	call   801022b6 <dirlink>
80106054:	83 c4 10             	add    $0x10,%esp
80106057:	85 c0                	test   %eax,%eax
80106059:	79 0d                	jns    80106068 <create+0x193>
      panic("create dots");
8010605b:	83 ec 0c             	sub    $0xc,%esp
8010605e:	68 67 8a 10 80       	push   $0x80108a67
80106063:	e8 4d a5 ff ff       	call   801005b5 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80106068:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010606b:	8b 40 04             	mov    0x4(%eax),%eax
8010606e:	83 ec 04             	sub    $0x4,%esp
80106071:	50                   	push   %eax
80106072:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80106075:	50                   	push   %eax
80106076:	ff 75 f4             	push   -0xc(%ebp)
80106079:	e8 38 c2 ff ff       	call   801022b6 <dirlink>
8010607e:	83 c4 10             	add    $0x10,%esp
80106081:	85 c0                	test   %eax,%eax
80106083:	79 0d                	jns    80106092 <create+0x1bd>
    panic("create: dirlink");
80106085:	83 ec 0c             	sub    $0xc,%esp
80106088:	68 73 8a 10 80       	push   $0x80108a73
8010608d:	e8 23 a5 ff ff       	call   801005b5 <panic>

  iunlockput(dp);
80106092:	83 ec 0c             	sub    $0xc,%esp
80106095:	ff 75 f4             	push   -0xc(%ebp)
80106098:	e8 ae bb ff ff       	call   80101c4b <iunlockput>
8010609d:	83 c4 10             	add    $0x10,%esp

  return ip;
801060a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801060a3:	c9                   	leave  
801060a4:	c3                   	ret    

801060a5 <sys_open>:

int
sys_open(void)
{
801060a5:	55                   	push   %ebp
801060a6:	89 e5                	mov    %esp,%ebp
801060a8:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801060ab:	83 ec 08             	sub    $0x8,%esp
801060ae:	8d 45 e8             	lea    -0x18(%ebp),%eax
801060b1:	50                   	push   %eax
801060b2:	6a 00                	push   $0x0
801060b4:	e8 ec f6 ff ff       	call   801057a5 <argstr>
801060b9:	83 c4 10             	add    $0x10,%esp
801060bc:	85 c0                	test   %eax,%eax
801060be:	78 15                	js     801060d5 <sys_open+0x30>
801060c0:	83 ec 08             	sub    $0x8,%esp
801060c3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801060c6:	50                   	push   %eax
801060c7:	6a 01                	push   $0x1
801060c9:	e8 42 f6 ff ff       	call   80105710 <argint>
801060ce:	83 c4 10             	add    $0x10,%esp
801060d1:	85 c0                	test   %eax,%eax
801060d3:	79 0a                	jns    801060df <sys_open+0x3a>
    return -1;
801060d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060da:	e9 61 01 00 00       	jmp    80106240 <sys_open+0x19b>

  begin_op();
801060df:	e8 4e d4 ff ff       	call   80103532 <begin_op>

  if(omode & O_CREATE){
801060e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060e7:	25 00 02 00 00       	and    $0x200,%eax
801060ec:	85 c0                	test   %eax,%eax
801060ee:	74 2a                	je     8010611a <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
801060f0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801060f3:	6a 00                	push   $0x0
801060f5:	6a 00                	push   $0x0
801060f7:	6a 02                	push   $0x2
801060f9:	50                   	push   %eax
801060fa:	e8 d6 fd ff ff       	call   80105ed5 <create>
801060ff:	83 c4 10             	add    $0x10,%esp
80106102:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106105:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106109:	75 75                	jne    80106180 <sys_open+0xdb>
      end_op();
8010610b:	e8 ae d4 ff ff       	call   801035be <end_op>
      return -1;
80106110:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106115:	e9 26 01 00 00       	jmp    80106240 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
8010611a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010611d:	83 ec 0c             	sub    $0xc,%esp
80106120:	50                   	push   %eax
80106121:	e8 27 c4 ff ff       	call   8010254d <namei>
80106126:	83 c4 10             	add    $0x10,%esp
80106129:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010612c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106130:	75 0f                	jne    80106141 <sys_open+0x9c>
      end_op();
80106132:	e8 87 d4 ff ff       	call   801035be <end_op>
      return -1;
80106137:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010613c:	e9 ff 00 00 00       	jmp    80106240 <sys_open+0x19b>
    }
    ilock(ip);
80106141:	83 ec 0c             	sub    $0xc,%esp
80106144:	ff 75 f4             	push   -0xc(%ebp)
80106147:	e8 ce b8 ff ff       	call   80101a1a <ilock>
8010614c:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
8010614f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106152:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106156:	66 83 f8 01          	cmp    $0x1,%ax
8010615a:	75 24                	jne    80106180 <sys_open+0xdb>
8010615c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010615f:	85 c0                	test   %eax,%eax
80106161:	74 1d                	je     80106180 <sys_open+0xdb>
      iunlockput(ip);
80106163:	83 ec 0c             	sub    $0xc,%esp
80106166:	ff 75 f4             	push   -0xc(%ebp)
80106169:	e8 dd ba ff ff       	call   80101c4b <iunlockput>
8010616e:	83 c4 10             	add    $0x10,%esp
      end_op();
80106171:	e8 48 d4 ff ff       	call   801035be <end_op>
      return -1;
80106176:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010617b:	e9 c0 00 00 00       	jmp    80106240 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106180:	e8 9b ae ff ff       	call   80101020 <filealloc>
80106185:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106188:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010618c:	74 17                	je     801061a5 <sys_open+0x100>
8010618e:	83 ec 0c             	sub    $0xc,%esp
80106191:	ff 75 f0             	push   -0x10(%ebp)
80106194:	e8 35 f7 ff ff       	call   801058ce <fdalloc>
80106199:	83 c4 10             	add    $0x10,%esp
8010619c:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010619f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801061a3:	79 2e                	jns    801061d3 <sys_open+0x12e>
    if(f)
801061a5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801061a9:	74 0e                	je     801061b9 <sys_open+0x114>
      fileclose(f);
801061ab:	83 ec 0c             	sub    $0xc,%esp
801061ae:	ff 75 f0             	push   -0x10(%ebp)
801061b1:	e8 28 af ff ff       	call   801010de <fileclose>
801061b6:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801061b9:	83 ec 0c             	sub    $0xc,%esp
801061bc:	ff 75 f4             	push   -0xc(%ebp)
801061bf:	e8 87 ba ff ff       	call   80101c4b <iunlockput>
801061c4:	83 c4 10             	add    $0x10,%esp
    end_op();
801061c7:	e8 f2 d3 ff ff       	call   801035be <end_op>
    return -1;
801061cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061d1:	eb 6d                	jmp    80106240 <sys_open+0x19b>
  }
  iunlock(ip);
801061d3:	83 ec 0c             	sub    $0xc,%esp
801061d6:	ff 75 f4             	push   -0xc(%ebp)
801061d9:	e8 4f b9 ff ff       	call   80101b2d <iunlock>
801061de:	83 c4 10             	add    $0x10,%esp
  end_op();
801061e1:	e8 d8 d3 ff ff       	call   801035be <end_op>

  f->type = FD_INODE;
801061e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061e9:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801061ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801061f5:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801061f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061fb:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106202:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106205:	83 e0 01             	and    $0x1,%eax
80106208:	85 c0                	test   %eax,%eax
8010620a:	0f 94 c0             	sete   %al
8010620d:	89 c2                	mov    %eax,%edx
8010620f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106212:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106215:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106218:	83 e0 01             	and    $0x1,%eax
8010621b:	85 c0                	test   %eax,%eax
8010621d:	75 0a                	jne    80106229 <sys_open+0x184>
8010621f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106222:	83 e0 02             	and    $0x2,%eax
80106225:	85 c0                	test   %eax,%eax
80106227:	74 07                	je     80106230 <sys_open+0x18b>
80106229:	b8 01 00 00 00       	mov    $0x1,%eax
8010622e:	eb 05                	jmp    80106235 <sys_open+0x190>
80106230:	b8 00 00 00 00       	mov    $0x0,%eax
80106235:	89 c2                	mov    %eax,%edx
80106237:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010623a:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
8010623d:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106240:	c9                   	leave  
80106241:	c3                   	ret    

80106242 <sys_mkdir>:

int
sys_mkdir(void)
{
80106242:	55                   	push   %ebp
80106243:	89 e5                	mov    %esp,%ebp
80106245:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106248:	e8 e5 d2 ff ff       	call   80103532 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
8010624d:	83 ec 08             	sub    $0x8,%esp
80106250:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106253:	50                   	push   %eax
80106254:	6a 00                	push   $0x0
80106256:	e8 4a f5 ff ff       	call   801057a5 <argstr>
8010625b:	83 c4 10             	add    $0x10,%esp
8010625e:	85 c0                	test   %eax,%eax
80106260:	78 1b                	js     8010627d <sys_mkdir+0x3b>
80106262:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106265:	6a 00                	push   $0x0
80106267:	6a 00                	push   $0x0
80106269:	6a 01                	push   $0x1
8010626b:	50                   	push   %eax
8010626c:	e8 64 fc ff ff       	call   80105ed5 <create>
80106271:	83 c4 10             	add    $0x10,%esp
80106274:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106277:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010627b:	75 0c                	jne    80106289 <sys_mkdir+0x47>
    end_op();
8010627d:	e8 3c d3 ff ff       	call   801035be <end_op>
    return -1;
80106282:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106287:	eb 18                	jmp    801062a1 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80106289:	83 ec 0c             	sub    $0xc,%esp
8010628c:	ff 75 f4             	push   -0xc(%ebp)
8010628f:	e8 b7 b9 ff ff       	call   80101c4b <iunlockput>
80106294:	83 c4 10             	add    $0x10,%esp
  end_op();
80106297:	e8 22 d3 ff ff       	call   801035be <end_op>
  return 0;
8010629c:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062a1:	c9                   	leave  
801062a2:	c3                   	ret    

801062a3 <sys_mknod>:

int
sys_mknod(void)
{
801062a3:	55                   	push   %ebp
801062a4:	89 e5                	mov    %esp,%ebp
801062a6:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
801062a9:	e8 84 d2 ff ff       	call   80103532 <begin_op>
  if((argstr(0, &path)) < 0 ||
801062ae:	83 ec 08             	sub    $0x8,%esp
801062b1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062b4:	50                   	push   %eax
801062b5:	6a 00                	push   $0x0
801062b7:	e8 e9 f4 ff ff       	call   801057a5 <argstr>
801062bc:	83 c4 10             	add    $0x10,%esp
801062bf:	85 c0                	test   %eax,%eax
801062c1:	78 4f                	js     80106312 <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
801062c3:	83 ec 08             	sub    $0x8,%esp
801062c6:	8d 45 ec             	lea    -0x14(%ebp),%eax
801062c9:	50                   	push   %eax
801062ca:	6a 01                	push   $0x1
801062cc:	e8 3f f4 ff ff       	call   80105710 <argint>
801062d1:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
801062d4:	85 c0                	test   %eax,%eax
801062d6:	78 3a                	js     80106312 <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
801062d8:	83 ec 08             	sub    $0x8,%esp
801062db:	8d 45 e8             	lea    -0x18(%ebp),%eax
801062de:	50                   	push   %eax
801062df:	6a 02                	push   $0x2
801062e1:	e8 2a f4 ff ff       	call   80105710 <argint>
801062e6:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
801062e9:	85 c0                	test   %eax,%eax
801062eb:	78 25                	js     80106312 <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
801062ed:	8b 45 e8             	mov    -0x18(%ebp),%eax
801062f0:	0f bf c8             	movswl %ax,%ecx
801062f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801062f6:	0f bf d0             	movswl %ax,%edx
801062f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062fc:	51                   	push   %ecx
801062fd:	52                   	push   %edx
801062fe:	6a 03                	push   $0x3
80106300:	50                   	push   %eax
80106301:	e8 cf fb ff ff       	call   80105ed5 <create>
80106306:	83 c4 10             	add    $0x10,%esp
80106309:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
8010630c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106310:	75 0c                	jne    8010631e <sys_mknod+0x7b>
    end_op();
80106312:	e8 a7 d2 ff ff       	call   801035be <end_op>
    return -1;
80106317:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010631c:	eb 18                	jmp    80106336 <sys_mknod+0x93>
  }
  iunlockput(ip);
8010631e:	83 ec 0c             	sub    $0xc,%esp
80106321:	ff 75 f4             	push   -0xc(%ebp)
80106324:	e8 22 b9 ff ff       	call   80101c4b <iunlockput>
80106329:	83 c4 10             	add    $0x10,%esp
  end_op();
8010632c:	e8 8d d2 ff ff       	call   801035be <end_op>
  return 0;
80106331:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106336:	c9                   	leave  
80106337:	c3                   	ret    

80106338 <sys_chdir>:

int
sys_chdir(void)
{
80106338:	55                   	push   %ebp
80106339:	89 e5                	mov    %esp,%ebp
8010633b:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
8010633e:	e8 56 df ff ff       	call   80104299 <myproc>
80106343:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80106346:	e8 e7 d1 ff ff       	call   80103532 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
8010634b:	83 ec 08             	sub    $0x8,%esp
8010634e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106351:	50                   	push   %eax
80106352:	6a 00                	push   $0x0
80106354:	e8 4c f4 ff ff       	call   801057a5 <argstr>
80106359:	83 c4 10             	add    $0x10,%esp
8010635c:	85 c0                	test   %eax,%eax
8010635e:	78 18                	js     80106378 <sys_chdir+0x40>
80106360:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106363:	83 ec 0c             	sub    $0xc,%esp
80106366:	50                   	push   %eax
80106367:	e8 e1 c1 ff ff       	call   8010254d <namei>
8010636c:	83 c4 10             	add    $0x10,%esp
8010636f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106372:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106376:	75 0c                	jne    80106384 <sys_chdir+0x4c>
    end_op();
80106378:	e8 41 d2 ff ff       	call   801035be <end_op>
    return -1;
8010637d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106382:	eb 68                	jmp    801063ec <sys_chdir+0xb4>
  }
  ilock(ip);
80106384:	83 ec 0c             	sub    $0xc,%esp
80106387:	ff 75 f0             	push   -0x10(%ebp)
8010638a:	e8 8b b6 ff ff       	call   80101a1a <ilock>
8010638f:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80106392:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106395:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106399:	66 83 f8 01          	cmp    $0x1,%ax
8010639d:	74 1a                	je     801063b9 <sys_chdir+0x81>
    iunlockput(ip);
8010639f:	83 ec 0c             	sub    $0xc,%esp
801063a2:	ff 75 f0             	push   -0x10(%ebp)
801063a5:	e8 a1 b8 ff ff       	call   80101c4b <iunlockput>
801063aa:	83 c4 10             	add    $0x10,%esp
    end_op();
801063ad:	e8 0c d2 ff ff       	call   801035be <end_op>
    return -1;
801063b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063b7:	eb 33                	jmp    801063ec <sys_chdir+0xb4>
  }
  iunlock(ip);
801063b9:	83 ec 0c             	sub    $0xc,%esp
801063bc:	ff 75 f0             	push   -0x10(%ebp)
801063bf:	e8 69 b7 ff ff       	call   80101b2d <iunlock>
801063c4:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
801063c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063ca:	8b 40 68             	mov    0x68(%eax),%eax
801063cd:	83 ec 0c             	sub    $0xc,%esp
801063d0:	50                   	push   %eax
801063d1:	e8 a5 b7 ff ff       	call   80101b7b <iput>
801063d6:	83 c4 10             	add    $0x10,%esp
  end_op();
801063d9:	e8 e0 d1 ff ff       	call   801035be <end_op>
  curproc->cwd = ip;
801063de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063e1:	8b 55 f0             	mov    -0x10(%ebp),%edx
801063e4:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
801063e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801063ec:	c9                   	leave  
801063ed:	c3                   	ret    

801063ee <sys_exec>:

int
sys_exec(void)
{
801063ee:	55                   	push   %ebp
801063ef:	89 e5                	mov    %esp,%ebp
801063f1:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801063f7:	83 ec 08             	sub    $0x8,%esp
801063fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063fd:	50                   	push   %eax
801063fe:	6a 00                	push   $0x0
80106400:	e8 a0 f3 ff ff       	call   801057a5 <argstr>
80106405:	83 c4 10             	add    $0x10,%esp
80106408:	85 c0                	test   %eax,%eax
8010640a:	78 18                	js     80106424 <sys_exec+0x36>
8010640c:	83 ec 08             	sub    $0x8,%esp
8010640f:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106415:	50                   	push   %eax
80106416:	6a 01                	push   $0x1
80106418:	e8 f3 f2 ff ff       	call   80105710 <argint>
8010641d:	83 c4 10             	add    $0x10,%esp
80106420:	85 c0                	test   %eax,%eax
80106422:	79 0a                	jns    8010642e <sys_exec+0x40>
    return -1;
80106424:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106429:	e9 c6 00 00 00       	jmp    801064f4 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
8010642e:	83 ec 04             	sub    $0x4,%esp
80106431:	68 80 00 00 00       	push   $0x80
80106436:	6a 00                	push   $0x0
80106438:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010643e:	50                   	push   %eax
8010643f:	e8 a1 ef ff ff       	call   801053e5 <memset>
80106444:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106447:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
8010644e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106451:	83 f8 1f             	cmp    $0x1f,%eax
80106454:	76 0a                	jbe    80106460 <sys_exec+0x72>
      return -1;
80106456:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010645b:	e9 94 00 00 00       	jmp    801064f4 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106460:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106463:	c1 e0 02             	shl    $0x2,%eax
80106466:	89 c2                	mov    %eax,%edx
80106468:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
8010646e:	01 c2                	add    %eax,%edx
80106470:	83 ec 08             	sub    $0x8,%esp
80106473:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106479:	50                   	push   %eax
8010647a:	52                   	push   %edx
8010647b:	e8 ef f1 ff ff       	call   8010566f <fetchint>
80106480:	83 c4 10             	add    $0x10,%esp
80106483:	85 c0                	test   %eax,%eax
80106485:	79 07                	jns    8010648e <sys_exec+0xa0>
      return -1;
80106487:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010648c:	eb 66                	jmp    801064f4 <sys_exec+0x106>
    if(uarg == 0){
8010648e:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106494:	85 c0                	test   %eax,%eax
80106496:	75 27                	jne    801064bf <sys_exec+0xd1>
      argv[i] = 0;
80106498:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010649b:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801064a2:	00 00 00 00 
      break;
801064a6:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801064a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064aa:	83 ec 08             	sub    $0x8,%esp
801064ad:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801064b3:	52                   	push   %edx
801064b4:	50                   	push   %eax
801064b5:	e8 09 a7 ff ff       	call   80100bc3 <exec>
801064ba:	83 c4 10             	add    $0x10,%esp
801064bd:	eb 35                	jmp    801064f4 <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
801064bf:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801064c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064c8:	c1 e0 02             	shl    $0x2,%eax
801064cb:	01 c2                	add    %eax,%edx
801064cd:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801064d3:	83 ec 08             	sub    $0x8,%esp
801064d6:	52                   	push   %edx
801064d7:	50                   	push   %eax
801064d8:	e8 d1 f1 ff ff       	call   801056ae <fetchstr>
801064dd:	83 c4 10             	add    $0x10,%esp
801064e0:	85 c0                	test   %eax,%eax
801064e2:	79 07                	jns    801064eb <sys_exec+0xfd>
      return -1;
801064e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064e9:	eb 09                	jmp    801064f4 <sys_exec+0x106>
  for(i=0;; i++){
801064eb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
801064ef:	e9 5a ff ff ff       	jmp    8010644e <sys_exec+0x60>
}
801064f4:	c9                   	leave  
801064f5:	c3                   	ret    

801064f6 <sys_pipe>:

int
sys_pipe(void)
{
801064f6:	55                   	push   %ebp
801064f7:	89 e5                	mov    %esp,%ebp
801064f9:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801064fc:	83 ec 04             	sub    $0x4,%esp
801064ff:	6a 08                	push   $0x8
80106501:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106504:	50                   	push   %eax
80106505:	6a 00                	push   $0x0
80106507:	e8 31 f2 ff ff       	call   8010573d <argptr>
8010650c:	83 c4 10             	add    $0x10,%esp
8010650f:	85 c0                	test   %eax,%eax
80106511:	79 0a                	jns    8010651d <sys_pipe+0x27>
    return -1;
80106513:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106518:	e9 ae 00 00 00       	jmp    801065cb <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
8010651d:	83 ec 08             	sub    $0x8,%esp
80106520:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106523:	50                   	push   %eax
80106524:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106527:	50                   	push   %eax
80106528:	e8 a9 d8 ff ff       	call   80103dd6 <pipealloc>
8010652d:	83 c4 10             	add    $0x10,%esp
80106530:	85 c0                	test   %eax,%eax
80106532:	79 0a                	jns    8010653e <sys_pipe+0x48>
    return -1;
80106534:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106539:	e9 8d 00 00 00       	jmp    801065cb <sys_pipe+0xd5>
  fd0 = -1;
8010653e:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106545:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106548:	83 ec 0c             	sub    $0xc,%esp
8010654b:	50                   	push   %eax
8010654c:	e8 7d f3 ff ff       	call   801058ce <fdalloc>
80106551:	83 c4 10             	add    $0x10,%esp
80106554:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106557:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010655b:	78 18                	js     80106575 <sys_pipe+0x7f>
8010655d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106560:	83 ec 0c             	sub    $0xc,%esp
80106563:	50                   	push   %eax
80106564:	e8 65 f3 ff ff       	call   801058ce <fdalloc>
80106569:	83 c4 10             	add    $0x10,%esp
8010656c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010656f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106573:	79 3e                	jns    801065b3 <sys_pipe+0xbd>
    if(fd0 >= 0)
80106575:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106579:	78 13                	js     8010658e <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
8010657b:	e8 19 dd ff ff       	call   80104299 <myproc>
80106580:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106583:	83 c2 08             	add    $0x8,%edx
80106586:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010658d:	00 
    fileclose(rf);
8010658e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106591:	83 ec 0c             	sub    $0xc,%esp
80106594:	50                   	push   %eax
80106595:	e8 44 ab ff ff       	call   801010de <fileclose>
8010659a:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
8010659d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801065a0:	83 ec 0c             	sub    $0xc,%esp
801065a3:	50                   	push   %eax
801065a4:	e8 35 ab ff ff       	call   801010de <fileclose>
801065a9:	83 c4 10             	add    $0x10,%esp
    return -1;
801065ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065b1:	eb 18                	jmp    801065cb <sys_pipe+0xd5>
  }
  fd[0] = fd0;
801065b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801065b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801065b9:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801065bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801065be:	8d 50 04             	lea    0x4(%eax),%edx
801065c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065c4:	89 02                	mov    %eax,(%edx)
  return 0;
801065c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801065cb:	c9                   	leave  
801065cc:	c3                   	ret    

801065cd <sys_fork>:
  struct proc proc[NPROC];
} ptable;

int
sys_fork(void)
{
801065cd:	55                   	push   %ebp
801065ce:	89 e5                	mov    %esp,%ebp
801065d0:	83 ec 08             	sub    $0x8,%esp
  return fork();
801065d3:	e8 da df ff ff       	call   801045b2 <fork>
}
801065d8:	c9                   	leave  
801065d9:	c3                   	ret    

801065da <sys_exit>:

int
sys_exit(void)
{
801065da:	55                   	push   %ebp
801065db:	89 e5                	mov    %esp,%ebp
801065dd:	83 ec 08             	sub    $0x8,%esp
  exit();
801065e0:	e8 46 e1 ff ff       	call   8010472b <exit>
  return 0;  // not reached
801065e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801065ea:	c9                   	leave  
801065eb:	c3                   	ret    

801065ec <sys_wait>:

int
sys_wait(void)
{
801065ec:	55                   	push   %ebp
801065ed:	89 e5                	mov    %esp,%ebp
801065ef:	83 ec 08             	sub    $0x8,%esp
  return wait();
801065f2:	e8 57 e2 ff ff       	call   8010484e <wait>
}
801065f7:	c9                   	leave  
801065f8:	c3                   	ret    

801065f9 <sys_kill>:

int
sys_kill(void)
{
801065f9:	55                   	push   %ebp
801065fa:	89 e5                	mov    %esp,%ebp
801065fc:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
801065ff:	83 ec 08             	sub    $0x8,%esp
80106602:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106605:	50                   	push   %eax
80106606:	6a 00                	push   $0x0
80106608:	e8 03 f1 ff ff       	call   80105710 <argint>
8010660d:	83 c4 10             	add    $0x10,%esp
80106610:	85 c0                	test   %eax,%eax
80106612:	79 07                	jns    8010661b <sys_kill+0x22>
    return -1;
80106614:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106619:	eb 0f                	jmp    8010662a <sys_kill+0x31>
  return kill(pid);
8010661b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010661e:	83 ec 0c             	sub    $0xc,%esp
80106621:	50                   	push   %eax
80106622:	e8 09 e7 ff ff       	call   80104d30 <kill>
80106627:	83 c4 10             	add    $0x10,%esp
}
8010662a:	c9                   	leave  
8010662b:	c3                   	ret    

8010662c <sys_getpid>:

int
sys_getpid(void)
{
8010662c:	55                   	push   %ebp
8010662d:	89 e5                	mov    %esp,%ebp
8010662f:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80106632:	e8 62 dc ff ff       	call   80104299 <myproc>
80106637:	8b 40 10             	mov    0x10(%eax),%eax
}
8010663a:	c9                   	leave  
8010663b:	c3                   	ret    

8010663c <sys_sbrk>:

int
sys_sbrk(void)
{
8010663c:	55                   	push   %ebp
8010663d:	89 e5                	mov    %esp,%ebp
8010663f:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106642:	83 ec 08             	sub    $0x8,%esp
80106645:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106648:	50                   	push   %eax
80106649:	6a 00                	push   $0x0
8010664b:	e8 c0 f0 ff ff       	call   80105710 <argint>
80106650:	83 c4 10             	add    $0x10,%esp
80106653:	85 c0                	test   %eax,%eax
80106655:	79 07                	jns    8010665e <sys_sbrk+0x22>
    return -1;
80106657:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010665c:	eb 27                	jmp    80106685 <sys_sbrk+0x49>
  addr = myproc()->sz;
8010665e:	e8 36 dc ff ff       	call   80104299 <myproc>
80106663:	8b 00                	mov    (%eax),%eax
80106665:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106668:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010666b:	83 ec 0c             	sub    $0xc,%esp
8010666e:	50                   	push   %eax
8010666f:	e8 a3 de ff ff       	call   80104517 <growproc>
80106674:	83 c4 10             	add    $0x10,%esp
80106677:	85 c0                	test   %eax,%eax
80106679:	79 07                	jns    80106682 <sys_sbrk+0x46>
    return -1;
8010667b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106680:	eb 03                	jmp    80106685 <sys_sbrk+0x49>
  return addr;
80106682:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106685:	c9                   	leave  
80106686:	c3                   	ret    

80106687 <sys_sleep>:

int
sys_sleep(void)
{
80106687:	55                   	push   %ebp
80106688:	89 e5                	mov    %esp,%ebp
8010668a:	53                   	push   %ebx
8010668b:	83 ec 14             	sub    $0x14,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
8010668e:	83 ec 08             	sub    $0x8,%esp
80106691:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106694:	50                   	push   %eax
80106695:	6a 00                	push   $0x0
80106697:	e8 74 f0 ff ff       	call   80105710 <argint>
8010669c:	83 c4 10             	add    $0x10,%esp
8010669f:	85 c0                	test   %eax,%eax
801066a1:	79 0a                	jns    801066ad <sys_sleep+0x26>
    return -1;
801066a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066a8:	e9 90 00 00 00       	jmp    8010673d <sys_sleep+0xb6>
  acquire(&tickslock);
801066ad:	83 ec 0c             	sub    $0xc,%esp
801066b0:	68 a0 59 11 80       	push   $0x801159a0
801066b5:	e8 a5 ea ff ff       	call   8010515f <acquire>
801066ba:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
801066bd:	a1 d4 59 11 80       	mov    0x801159d4,%eax
801066c2:	89 45 f4             	mov    %eax,-0xc(%ebp)

  myproc()->ticks = ticks0 + n; 
801066c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066c8:	89 c3                	mov    %eax,%ebx
801066ca:	e8 ca db ff ff       	call   80104299 <myproc>
801066cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
801066d2:	01 da                	add    %ebx,%edx
801066d4:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)

  while(ticks < myproc()->ticks){
801066da:	eb 38                	jmp    80106714 <sys_sleep+0x8d>
    if(myproc()->killed){
801066dc:	e8 b8 db ff ff       	call   80104299 <myproc>
801066e1:	8b 40 24             	mov    0x24(%eax),%eax
801066e4:	85 c0                	test   %eax,%eax
801066e6:	74 17                	je     801066ff <sys_sleep+0x78>
      release(&tickslock);
801066e8:	83 ec 0c             	sub    $0xc,%esp
801066eb:	68 a0 59 11 80       	push   $0x801159a0
801066f0:	e8 d8 ea ff ff       	call   801051cd <release>
801066f5:	83 c4 10             	add    $0x10,%esp
      return -1;
801066f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066fd:	eb 3e                	jmp    8010673d <sys_sleep+0xb6>
    }
    sleep(&ticks, &tickslock);
801066ff:	83 ec 08             	sub    $0x8,%esp
80106702:	68 a0 59 11 80       	push   $0x801159a0
80106707:	68 d4 59 11 80       	push   $0x801159d4
8010670c:	e8 fe e4 ff ff       	call   80104c0f <sleep>
80106711:	83 c4 10             	add    $0x10,%esp
  while(ticks < myproc()->ticks){
80106714:	e8 80 db ff ff       	call   80104299 <myproc>
80106719:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
8010671f:	a1 d4 59 11 80       	mov    0x801159d4,%eax
80106724:	39 c2                	cmp    %eax,%edx
80106726:	77 b4                	ja     801066dc <sys_sleep+0x55>
  }
  release(&tickslock);
80106728:	83 ec 0c             	sub    $0xc,%esp
8010672b:	68 a0 59 11 80       	push   $0x801159a0
80106730:	e8 98 ea ff ff       	call   801051cd <release>
80106735:	83 c4 10             	add    $0x10,%esp
  return 0;
80106738:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010673d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80106740:	c9                   	leave  
80106741:	c3                   	ret    

80106742 <sys_nice>:

int
sys_nice(void)
{
80106742:	55                   	push   %ebp
80106743:	89 e5                	mov    %esp,%ebp
80106745:	83 ec 18             	sub    $0x18,%esp
  int n;
  if(argint(0, &n) < 0)
80106748:	83 ec 08             	sub    $0x8,%esp
8010674b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010674e:	50                   	push   %eax
8010674f:	6a 00                	push   $0x0
80106751:	e8 ba ef ff ff       	call   80105710 <argint>
80106756:	83 c4 10             	add    $0x10,%esp
80106759:	85 c0                	test   %eax,%eax
8010675b:	79 07                	jns    80106764 <sys_nice+0x22>
    return -1;
8010675d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106762:	eb 0f                	jmp    80106773 <sys_nice+0x31>


  return nice(n);
80106764:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106767:	83 ec 0c             	sub    $0xc,%esp
8010676a:	50                   	push   %eax
8010676b:	e8 44 e7 ff ff       	call   80104eb4 <nice>
80106770:	83 c4 10             	add    $0x10,%esp
}
80106773:	c9                   	leave  
80106774:	c3                   	ret    

80106775 <sys_getschedstate>:

int 
sys_getschedstate(void)
{
80106775:	55                   	push   %ebp
80106776:	89 e5                	mov    %esp,%ebp
80106778:	83 ec 18             	sub    $0x18,%esp
 struct pschedinfo *pschedinfo;

 if(argptr(0, (void*)&pschedinfo, sizeof(struct pschedinfo)) < 0)
8010677b:	83 ec 04             	sub    $0x4,%esp
8010677e:	68 00 05 00 00       	push   $0x500
80106783:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106786:	50                   	push   %eax
80106787:	6a 00                	push   $0x0
80106789:	e8 af ef ff ff       	call   8010573d <argptr>
8010678e:	83 c4 10             	add    $0x10,%esp
80106791:	85 c0                	test   %eax,%eax
80106793:	79 07                	jns    8010679c <sys_getschedstate+0x27>
    return -1;
80106795:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010679a:	eb 1d                	jmp    801067b9 <sys_getschedstate+0x44>
  
  if(pschedinfo == NULL)
8010679c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010679f:	85 c0                	test   %eax,%eax
801067a1:	75 07                	jne    801067aa <sys_getschedstate+0x35>
    return -1;
801067a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067a8:	eb 0f                	jmp    801067b9 <sys_getschedstate+0x44>

 return getschedstate(pschedinfo);
801067aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067ad:	83 ec 0c             	sub    $0xc,%esp
801067b0:	50                   	push   %eax
801067b1:	e8 32 e7 ff ff       	call   80104ee8 <getschedstate>
801067b6:	83 c4 10             	add    $0x10,%esp
}
801067b9:	c9                   	leave  
801067ba:	c3                   	ret    

801067bb <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801067bb:	55                   	push   %ebp
801067bc:	89 e5                	mov    %esp,%ebp
801067be:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
801067c1:	83 ec 0c             	sub    $0xc,%esp
801067c4:	68 a0 59 11 80       	push   $0x801159a0
801067c9:	e8 91 e9 ff ff       	call   8010515f <acquire>
801067ce:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
801067d1:	a1 d4 59 11 80       	mov    0x801159d4,%eax
801067d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801067d9:	83 ec 0c             	sub    $0xc,%esp
801067dc:	68 a0 59 11 80       	push   $0x801159a0
801067e1:	e8 e7 e9 ff ff       	call   801051cd <release>
801067e6:	83 c4 10             	add    $0x10,%esp
  return xticks;
801067e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801067ec:	c9                   	leave  
801067ed:	c3                   	ret    

801067ee <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801067ee:	1e                   	push   %ds
  pushl %es
801067ef:	06                   	push   %es
  pushl %fs
801067f0:	0f a0                	push   %fs
  pushl %gs
801067f2:	0f a8                	push   %gs
  pushal
801067f4:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
801067f5:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801067f9:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801067fb:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
801067fd:	54                   	push   %esp
  call trap
801067fe:	e8 d7 01 00 00       	call   801069da <trap>
  addl $4, %esp
80106803:	83 c4 04             	add    $0x4,%esp

80106806 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106806:	61                   	popa   
  popl %gs
80106807:	0f a9                	pop    %gs
  popl %fs
80106809:	0f a1                	pop    %fs
  popl %es
8010680b:	07                   	pop    %es
  popl %ds
8010680c:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010680d:	83 c4 08             	add    $0x8,%esp
  iret
80106810:	cf                   	iret   

80106811 <lidt>:
{
80106811:	55                   	push   %ebp
80106812:	89 e5                	mov    %esp,%ebp
80106814:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106817:	8b 45 0c             	mov    0xc(%ebp),%eax
8010681a:	83 e8 01             	sub    $0x1,%eax
8010681d:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106821:	8b 45 08             	mov    0x8(%ebp),%eax
80106824:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106828:	8b 45 08             	mov    0x8(%ebp),%eax
8010682b:	c1 e8 10             	shr    $0x10,%eax
8010682e:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80106832:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106835:	0f 01 18             	lidtl  (%eax)
}
80106838:	90                   	nop
80106839:	c9                   	leave  
8010683a:	c3                   	ret    

8010683b <rcr2>:

static inline uint
rcr2(void)
{
8010683b:	55                   	push   %ebp
8010683c:	89 e5                	mov    %esp,%ebp
8010683e:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106841:	0f 20 d0             	mov    %cr2,%eax
80106844:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106847:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010684a:	c9                   	leave  
8010684b:	c3                   	ret    

8010684c <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
8010684c:	55                   	push   %ebp
8010684d:	89 e5                	mov    %esp,%ebp
8010684f:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106852:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106859:	e9 c3 00 00 00       	jmp    80106921 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
8010685e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106861:	8b 04 85 80 b0 10 80 	mov    -0x7fef4f80(,%eax,4),%eax
80106868:	89 c2                	mov    %eax,%edx
8010686a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010686d:	66 89 14 c5 a0 51 11 	mov    %dx,-0x7feeae60(,%eax,8)
80106874:	80 
80106875:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106878:	66 c7 04 c5 a2 51 11 	movw   $0x8,-0x7feeae5e(,%eax,8)
8010687f:	80 08 00 
80106882:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106885:	0f b6 14 c5 a4 51 11 	movzbl -0x7feeae5c(,%eax,8),%edx
8010688c:	80 
8010688d:	83 e2 e0             	and    $0xffffffe0,%edx
80106890:	88 14 c5 a4 51 11 80 	mov    %dl,-0x7feeae5c(,%eax,8)
80106897:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010689a:	0f b6 14 c5 a4 51 11 	movzbl -0x7feeae5c(,%eax,8),%edx
801068a1:	80 
801068a2:	83 e2 1f             	and    $0x1f,%edx
801068a5:	88 14 c5 a4 51 11 80 	mov    %dl,-0x7feeae5c(,%eax,8)
801068ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068af:	0f b6 14 c5 a5 51 11 	movzbl -0x7feeae5b(,%eax,8),%edx
801068b6:	80 
801068b7:	83 e2 f0             	and    $0xfffffff0,%edx
801068ba:	83 ca 0e             	or     $0xe,%edx
801068bd:	88 14 c5 a5 51 11 80 	mov    %dl,-0x7feeae5b(,%eax,8)
801068c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068c7:	0f b6 14 c5 a5 51 11 	movzbl -0x7feeae5b(,%eax,8),%edx
801068ce:	80 
801068cf:	83 e2 ef             	and    $0xffffffef,%edx
801068d2:	88 14 c5 a5 51 11 80 	mov    %dl,-0x7feeae5b(,%eax,8)
801068d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068dc:	0f b6 14 c5 a5 51 11 	movzbl -0x7feeae5b(,%eax,8),%edx
801068e3:	80 
801068e4:	83 e2 9f             	and    $0xffffff9f,%edx
801068e7:	88 14 c5 a5 51 11 80 	mov    %dl,-0x7feeae5b(,%eax,8)
801068ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068f1:	0f b6 14 c5 a5 51 11 	movzbl -0x7feeae5b(,%eax,8),%edx
801068f8:	80 
801068f9:	83 ca 80             	or     $0xffffff80,%edx
801068fc:	88 14 c5 a5 51 11 80 	mov    %dl,-0x7feeae5b(,%eax,8)
80106903:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106906:	8b 04 85 80 b0 10 80 	mov    -0x7fef4f80(,%eax,4),%eax
8010690d:	c1 e8 10             	shr    $0x10,%eax
80106910:	89 c2                	mov    %eax,%edx
80106912:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106915:	66 89 14 c5 a6 51 11 	mov    %dx,-0x7feeae5a(,%eax,8)
8010691c:	80 
  for(i = 0; i < 256; i++)
8010691d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106921:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106928:	0f 8e 30 ff ff ff    	jle    8010685e <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010692e:	a1 80 b1 10 80       	mov    0x8010b180,%eax
80106933:	66 a3 a0 53 11 80    	mov    %ax,0x801153a0
80106939:	66 c7 05 a2 53 11 80 	movw   $0x8,0x801153a2
80106940:	08 00 
80106942:	0f b6 05 a4 53 11 80 	movzbl 0x801153a4,%eax
80106949:	83 e0 e0             	and    $0xffffffe0,%eax
8010694c:	a2 a4 53 11 80       	mov    %al,0x801153a4
80106951:	0f b6 05 a4 53 11 80 	movzbl 0x801153a4,%eax
80106958:	83 e0 1f             	and    $0x1f,%eax
8010695b:	a2 a4 53 11 80       	mov    %al,0x801153a4
80106960:	0f b6 05 a5 53 11 80 	movzbl 0x801153a5,%eax
80106967:	83 c8 0f             	or     $0xf,%eax
8010696a:	a2 a5 53 11 80       	mov    %al,0x801153a5
8010696f:	0f b6 05 a5 53 11 80 	movzbl 0x801153a5,%eax
80106976:	83 e0 ef             	and    $0xffffffef,%eax
80106979:	a2 a5 53 11 80       	mov    %al,0x801153a5
8010697e:	0f b6 05 a5 53 11 80 	movzbl 0x801153a5,%eax
80106985:	83 c8 60             	or     $0x60,%eax
80106988:	a2 a5 53 11 80       	mov    %al,0x801153a5
8010698d:	0f b6 05 a5 53 11 80 	movzbl 0x801153a5,%eax
80106994:	83 c8 80             	or     $0xffffff80,%eax
80106997:	a2 a5 53 11 80       	mov    %al,0x801153a5
8010699c:	a1 80 b1 10 80       	mov    0x8010b180,%eax
801069a1:	c1 e8 10             	shr    $0x10,%eax
801069a4:	66 a3 a6 53 11 80    	mov    %ax,0x801153a6

  initlock(&tickslock, "time");
801069aa:	83 ec 08             	sub    $0x8,%esp
801069ad:	68 84 8a 10 80       	push   $0x80108a84
801069b2:	68 a0 59 11 80       	push   $0x801159a0
801069b7:	e8 81 e7 ff ff       	call   8010513d <initlock>
801069bc:	83 c4 10             	add    $0x10,%esp
}
801069bf:	90                   	nop
801069c0:	c9                   	leave  
801069c1:	c3                   	ret    

801069c2 <idtinit>:

void
idtinit(void)
{
801069c2:	55                   	push   %ebp
801069c3:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
801069c5:	68 00 08 00 00       	push   $0x800
801069ca:	68 a0 51 11 80       	push   $0x801151a0
801069cf:	e8 3d fe ff ff       	call   80106811 <lidt>
801069d4:	83 c4 08             	add    $0x8,%esp
}
801069d7:	90                   	nop
801069d8:	c9                   	leave  
801069d9:	c3                   	ret    

801069da <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801069da:	55                   	push   %ebp
801069db:	89 e5                	mov    %esp,%ebp
801069dd:	57                   	push   %edi
801069de:	56                   	push   %esi
801069df:	53                   	push   %ebx
801069e0:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
801069e3:	8b 45 08             	mov    0x8(%ebp),%eax
801069e6:	8b 40 30             	mov    0x30(%eax),%eax
801069e9:	83 f8 40             	cmp    $0x40,%eax
801069ec:	75 3b                	jne    80106a29 <trap+0x4f>
    if(myproc()->killed)
801069ee:	e8 a6 d8 ff ff       	call   80104299 <myproc>
801069f3:	8b 40 24             	mov    0x24(%eax),%eax
801069f6:	85 c0                	test   %eax,%eax
801069f8:	74 05                	je     801069ff <trap+0x25>
      exit();
801069fa:	e8 2c dd ff ff       	call   8010472b <exit>
    myproc()->tf = tf;
801069ff:	e8 95 d8 ff ff       	call   80104299 <myproc>
80106a04:	8b 55 08             	mov    0x8(%ebp),%edx
80106a07:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106a0a:	e8 cd ed ff ff       	call   801057dc <syscall>
    if(myproc()->killed)
80106a0f:	e8 85 d8 ff ff       	call   80104299 <myproc>
80106a14:	8b 40 24             	mov    0x24(%eax),%eax
80106a17:	85 c0                	test   %eax,%eax
80106a19:	0f 84 06 02 00 00    	je     80106c25 <trap+0x24b>
      exit();
80106a1f:	e8 07 dd ff ff       	call   8010472b <exit>
    return;
80106a24:	e9 fc 01 00 00       	jmp    80106c25 <trap+0x24b>
  }

  switch(tf->trapno){
80106a29:	8b 45 08             	mov    0x8(%ebp),%eax
80106a2c:	8b 40 30             	mov    0x30(%eax),%eax
80106a2f:	83 e8 20             	sub    $0x20,%eax
80106a32:	83 f8 1f             	cmp    $0x1f,%eax
80106a35:	0f 87 b5 00 00 00    	ja     80106af0 <trap+0x116>
80106a3b:	8b 04 85 2c 8b 10 80 	mov    -0x7fef74d4(,%eax,4),%eax
80106a42:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80106a44:	e8 bd d7 ff ff       	call   80104206 <cpuid>
80106a49:	85 c0                	test   %eax,%eax
80106a4b:	75 3d                	jne    80106a8a <trap+0xb0>
      acquire(&tickslock);
80106a4d:	83 ec 0c             	sub    $0xc,%esp
80106a50:	68 a0 59 11 80       	push   $0x801159a0
80106a55:	e8 05 e7 ff ff       	call   8010515f <acquire>
80106a5a:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106a5d:	a1 d4 59 11 80       	mov    0x801159d4,%eax
80106a62:	83 c0 01             	add    $0x1,%eax
80106a65:	a3 d4 59 11 80       	mov    %eax,0x801159d4
      wakeup(&ticks);
80106a6a:	83 ec 0c             	sub    $0xc,%esp
80106a6d:	68 d4 59 11 80       	push   $0x801159d4
80106a72:	e8 82 e2 ff ff       	call   80104cf9 <wakeup>
80106a77:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106a7a:	83 ec 0c             	sub    $0xc,%esp
80106a7d:	68 a0 59 11 80       	push   $0x801159a0
80106a82:	e8 46 e7 ff ff       	call   801051cd <release>
80106a87:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106a8a:	e8 83 c5 ff ff       	call   80103012 <lapiceoi>
    break;
80106a8f:	e9 11 01 00 00       	jmp    80106ba5 <trap+0x1cb>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106a94:	e8 ed bd ff ff       	call   80102886 <ideintr>
    lapiceoi();
80106a99:	e8 74 c5 ff ff       	call   80103012 <lapiceoi>
    break;
80106a9e:	e9 02 01 00 00       	jmp    80106ba5 <trap+0x1cb>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106aa3:	e8 af c3 ff ff       	call   80102e57 <kbdintr>
    lapiceoi();
80106aa8:	e8 65 c5 ff ff       	call   80103012 <lapiceoi>
    break;
80106aad:	e9 f3 00 00 00       	jmp    80106ba5 <trap+0x1cb>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106ab2:	e8 44 03 00 00       	call   80106dfb <uartintr>
    lapiceoi();
80106ab7:	e8 56 c5 ff ff       	call   80103012 <lapiceoi>
    break;
80106abc:	e9 e4 00 00 00       	jmp    80106ba5 <trap+0x1cb>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106ac1:	8b 45 08             	mov    0x8(%ebp),%eax
80106ac4:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106ac7:	8b 45 08             	mov    0x8(%ebp),%eax
80106aca:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106ace:	0f b7 d8             	movzwl %ax,%ebx
80106ad1:	e8 30 d7 ff ff       	call   80104206 <cpuid>
80106ad6:	56                   	push   %esi
80106ad7:	53                   	push   %ebx
80106ad8:	50                   	push   %eax
80106ad9:	68 8c 8a 10 80       	push   $0x80108a8c
80106ade:	e8 1d 99 ff ff       	call   80100400 <cprintf>
80106ae3:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106ae6:	e8 27 c5 ff ff       	call   80103012 <lapiceoi>
    break;
80106aeb:	e9 b5 00 00 00       	jmp    80106ba5 <trap+0x1cb>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106af0:	e8 a4 d7 ff ff       	call   80104299 <myproc>
80106af5:	85 c0                	test   %eax,%eax
80106af7:	74 11                	je     80106b0a <trap+0x130>
80106af9:	8b 45 08             	mov    0x8(%ebp),%eax
80106afc:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106b00:	0f b7 c0             	movzwl %ax,%eax
80106b03:	83 e0 03             	and    $0x3,%eax
80106b06:	85 c0                	test   %eax,%eax
80106b08:	75 39                	jne    80106b43 <trap+0x169>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106b0a:	e8 2c fd ff ff       	call   8010683b <rcr2>
80106b0f:	89 c3                	mov    %eax,%ebx
80106b11:	8b 45 08             	mov    0x8(%ebp),%eax
80106b14:	8b 70 38             	mov    0x38(%eax),%esi
80106b17:	e8 ea d6 ff ff       	call   80104206 <cpuid>
80106b1c:	8b 55 08             	mov    0x8(%ebp),%edx
80106b1f:	8b 52 30             	mov    0x30(%edx),%edx
80106b22:	83 ec 0c             	sub    $0xc,%esp
80106b25:	53                   	push   %ebx
80106b26:	56                   	push   %esi
80106b27:	50                   	push   %eax
80106b28:	52                   	push   %edx
80106b29:	68 b0 8a 10 80       	push   $0x80108ab0
80106b2e:	e8 cd 98 ff ff       	call   80100400 <cprintf>
80106b33:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106b36:	83 ec 0c             	sub    $0xc,%esp
80106b39:	68 e2 8a 10 80       	push   $0x80108ae2
80106b3e:	e8 72 9a ff ff       	call   801005b5 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106b43:	e8 f3 fc ff ff       	call   8010683b <rcr2>
80106b48:	89 c6                	mov    %eax,%esi
80106b4a:	8b 45 08             	mov    0x8(%ebp),%eax
80106b4d:	8b 40 38             	mov    0x38(%eax),%eax
80106b50:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106b53:	e8 ae d6 ff ff       	call   80104206 <cpuid>
80106b58:	89 c3                	mov    %eax,%ebx
80106b5a:	8b 45 08             	mov    0x8(%ebp),%eax
80106b5d:	8b 48 34             	mov    0x34(%eax),%ecx
80106b60:	89 4d e0             	mov    %ecx,-0x20(%ebp)
80106b63:	8b 45 08             	mov    0x8(%ebp),%eax
80106b66:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106b69:	e8 2b d7 ff ff       	call   80104299 <myproc>
80106b6e:	8d 50 6c             	lea    0x6c(%eax),%edx
80106b71:	89 55 dc             	mov    %edx,-0x24(%ebp)
80106b74:	e8 20 d7 ff ff       	call   80104299 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106b79:	8b 40 10             	mov    0x10(%eax),%eax
80106b7c:	56                   	push   %esi
80106b7d:	ff 75 e4             	push   -0x1c(%ebp)
80106b80:	53                   	push   %ebx
80106b81:	ff 75 e0             	push   -0x20(%ebp)
80106b84:	57                   	push   %edi
80106b85:	ff 75 dc             	push   -0x24(%ebp)
80106b88:	50                   	push   %eax
80106b89:	68 e8 8a 10 80       	push   $0x80108ae8
80106b8e:	e8 6d 98 ff ff       	call   80100400 <cprintf>
80106b93:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106b96:	e8 fe d6 ff ff       	call   80104299 <myproc>
80106b9b:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106ba2:	eb 01                	jmp    80106ba5 <trap+0x1cb>
    break;
80106ba4:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106ba5:	e8 ef d6 ff ff       	call   80104299 <myproc>
80106baa:	85 c0                	test   %eax,%eax
80106bac:	74 23                	je     80106bd1 <trap+0x1f7>
80106bae:	e8 e6 d6 ff ff       	call   80104299 <myproc>
80106bb3:	8b 40 24             	mov    0x24(%eax),%eax
80106bb6:	85 c0                	test   %eax,%eax
80106bb8:	74 17                	je     80106bd1 <trap+0x1f7>
80106bba:	8b 45 08             	mov    0x8(%ebp),%eax
80106bbd:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106bc1:	0f b7 c0             	movzwl %ax,%eax
80106bc4:	83 e0 03             	and    $0x3,%eax
80106bc7:	83 f8 03             	cmp    $0x3,%eax
80106bca:	75 05                	jne    80106bd1 <trap+0x1f7>
    exit();
80106bcc:	e8 5a db ff ff       	call   8010472b <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106bd1:	e8 c3 d6 ff ff       	call   80104299 <myproc>
80106bd6:	85 c0                	test   %eax,%eax
80106bd8:	74 1d                	je     80106bf7 <trap+0x21d>
80106bda:	e8 ba d6 ff ff       	call   80104299 <myproc>
80106bdf:	8b 40 0c             	mov    0xc(%eax),%eax
80106be2:	83 f8 04             	cmp    $0x4,%eax
80106be5:	75 10                	jne    80106bf7 <trap+0x21d>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106be7:	8b 45 08             	mov    0x8(%ebp),%eax
80106bea:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80106bed:	83 f8 20             	cmp    $0x20,%eax
80106bf0:	75 05                	jne    80106bf7 <trap+0x21d>
    yield();
80106bf2:	e8 98 df ff ff       	call   80104b8f <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106bf7:	e8 9d d6 ff ff       	call   80104299 <myproc>
80106bfc:	85 c0                	test   %eax,%eax
80106bfe:	74 26                	je     80106c26 <trap+0x24c>
80106c00:	e8 94 d6 ff ff       	call   80104299 <myproc>
80106c05:	8b 40 24             	mov    0x24(%eax),%eax
80106c08:	85 c0                	test   %eax,%eax
80106c0a:	74 1a                	je     80106c26 <trap+0x24c>
80106c0c:	8b 45 08             	mov    0x8(%ebp),%eax
80106c0f:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106c13:	0f b7 c0             	movzwl %ax,%eax
80106c16:	83 e0 03             	and    $0x3,%eax
80106c19:	83 f8 03             	cmp    $0x3,%eax
80106c1c:	75 08                	jne    80106c26 <trap+0x24c>
    exit();
80106c1e:	e8 08 db ff ff       	call   8010472b <exit>
80106c23:	eb 01                	jmp    80106c26 <trap+0x24c>
    return;
80106c25:	90                   	nop
}
80106c26:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106c29:	5b                   	pop    %ebx
80106c2a:	5e                   	pop    %esi
80106c2b:	5f                   	pop    %edi
80106c2c:	5d                   	pop    %ebp
80106c2d:	c3                   	ret    

80106c2e <inb>:
{
80106c2e:	55                   	push   %ebp
80106c2f:	89 e5                	mov    %esp,%ebp
80106c31:	83 ec 14             	sub    $0x14,%esp
80106c34:	8b 45 08             	mov    0x8(%ebp),%eax
80106c37:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106c3b:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106c3f:	89 c2                	mov    %eax,%edx
80106c41:	ec                   	in     (%dx),%al
80106c42:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106c45:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106c49:	c9                   	leave  
80106c4a:	c3                   	ret    

80106c4b <outb>:
{
80106c4b:	55                   	push   %ebp
80106c4c:	89 e5                	mov    %esp,%ebp
80106c4e:	83 ec 08             	sub    $0x8,%esp
80106c51:	8b 45 08             	mov    0x8(%ebp),%eax
80106c54:	8b 55 0c             	mov    0xc(%ebp),%edx
80106c57:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106c5b:	89 d0                	mov    %edx,%eax
80106c5d:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106c60:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106c64:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106c68:	ee                   	out    %al,(%dx)
}
80106c69:	90                   	nop
80106c6a:	c9                   	leave  
80106c6b:	c3                   	ret    

80106c6c <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106c6c:	55                   	push   %ebp
80106c6d:	89 e5                	mov    %esp,%ebp
80106c6f:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106c72:	6a 00                	push   $0x0
80106c74:	68 fa 03 00 00       	push   $0x3fa
80106c79:	e8 cd ff ff ff       	call   80106c4b <outb>
80106c7e:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106c81:	68 80 00 00 00       	push   $0x80
80106c86:	68 fb 03 00 00       	push   $0x3fb
80106c8b:	e8 bb ff ff ff       	call   80106c4b <outb>
80106c90:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106c93:	6a 0c                	push   $0xc
80106c95:	68 f8 03 00 00       	push   $0x3f8
80106c9a:	e8 ac ff ff ff       	call   80106c4b <outb>
80106c9f:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106ca2:	6a 00                	push   $0x0
80106ca4:	68 f9 03 00 00       	push   $0x3f9
80106ca9:	e8 9d ff ff ff       	call   80106c4b <outb>
80106cae:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106cb1:	6a 03                	push   $0x3
80106cb3:	68 fb 03 00 00       	push   $0x3fb
80106cb8:	e8 8e ff ff ff       	call   80106c4b <outb>
80106cbd:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106cc0:	6a 00                	push   $0x0
80106cc2:	68 fc 03 00 00       	push   $0x3fc
80106cc7:	e8 7f ff ff ff       	call   80106c4b <outb>
80106ccc:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106ccf:	6a 01                	push   $0x1
80106cd1:	68 f9 03 00 00       	push   $0x3f9
80106cd6:	e8 70 ff ff ff       	call   80106c4b <outb>
80106cdb:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106cde:	68 fd 03 00 00       	push   $0x3fd
80106ce3:	e8 46 ff ff ff       	call   80106c2e <inb>
80106ce8:	83 c4 04             	add    $0x4,%esp
80106ceb:	3c ff                	cmp    $0xff,%al
80106ced:	74 61                	je     80106d50 <uartinit+0xe4>
    return;
  uart = 1;
80106cef:	c7 05 d8 59 11 80 01 	movl   $0x1,0x801159d8
80106cf6:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106cf9:	68 fa 03 00 00       	push   $0x3fa
80106cfe:	e8 2b ff ff ff       	call   80106c2e <inb>
80106d03:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106d06:	68 f8 03 00 00       	push   $0x3f8
80106d0b:	e8 1e ff ff ff       	call   80106c2e <inb>
80106d10:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80106d13:	83 ec 08             	sub    $0x8,%esp
80106d16:	6a 00                	push   $0x0
80106d18:	6a 04                	push   $0x4
80106d1a:	e8 05 be ff ff       	call   80102b24 <ioapicenable>
80106d1f:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106d22:	c7 45 f4 ac 8b 10 80 	movl   $0x80108bac,-0xc(%ebp)
80106d29:	eb 19                	jmp    80106d44 <uartinit+0xd8>
    uartputc(*p);
80106d2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d2e:	0f b6 00             	movzbl (%eax),%eax
80106d31:	0f be c0             	movsbl %al,%eax
80106d34:	83 ec 0c             	sub    $0xc,%esp
80106d37:	50                   	push   %eax
80106d38:	e8 16 00 00 00       	call   80106d53 <uartputc>
80106d3d:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106d40:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106d44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d47:	0f b6 00             	movzbl (%eax),%eax
80106d4a:	84 c0                	test   %al,%al
80106d4c:	75 dd                	jne    80106d2b <uartinit+0xbf>
80106d4e:	eb 01                	jmp    80106d51 <uartinit+0xe5>
    return;
80106d50:	90                   	nop
}
80106d51:	c9                   	leave  
80106d52:	c3                   	ret    

80106d53 <uartputc>:

void
uartputc(int c)
{
80106d53:	55                   	push   %ebp
80106d54:	89 e5                	mov    %esp,%ebp
80106d56:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106d59:	a1 d8 59 11 80       	mov    0x801159d8,%eax
80106d5e:	85 c0                	test   %eax,%eax
80106d60:	74 53                	je     80106db5 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106d62:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106d69:	eb 11                	jmp    80106d7c <uartputc+0x29>
    microdelay(10);
80106d6b:	83 ec 0c             	sub    $0xc,%esp
80106d6e:	6a 0a                	push   $0xa
80106d70:	e8 b8 c2 ff ff       	call   8010302d <microdelay>
80106d75:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106d78:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106d7c:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106d80:	7f 1a                	jg     80106d9c <uartputc+0x49>
80106d82:	83 ec 0c             	sub    $0xc,%esp
80106d85:	68 fd 03 00 00       	push   $0x3fd
80106d8a:	e8 9f fe ff ff       	call   80106c2e <inb>
80106d8f:	83 c4 10             	add    $0x10,%esp
80106d92:	0f b6 c0             	movzbl %al,%eax
80106d95:	83 e0 20             	and    $0x20,%eax
80106d98:	85 c0                	test   %eax,%eax
80106d9a:	74 cf                	je     80106d6b <uartputc+0x18>
  outb(COM1+0, c);
80106d9c:	8b 45 08             	mov    0x8(%ebp),%eax
80106d9f:	0f b6 c0             	movzbl %al,%eax
80106da2:	83 ec 08             	sub    $0x8,%esp
80106da5:	50                   	push   %eax
80106da6:	68 f8 03 00 00       	push   $0x3f8
80106dab:	e8 9b fe ff ff       	call   80106c4b <outb>
80106db0:	83 c4 10             	add    $0x10,%esp
80106db3:	eb 01                	jmp    80106db6 <uartputc+0x63>
    return;
80106db5:	90                   	nop
}
80106db6:	c9                   	leave  
80106db7:	c3                   	ret    

80106db8 <uartgetc>:

static int
uartgetc(void)
{
80106db8:	55                   	push   %ebp
80106db9:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106dbb:	a1 d8 59 11 80       	mov    0x801159d8,%eax
80106dc0:	85 c0                	test   %eax,%eax
80106dc2:	75 07                	jne    80106dcb <uartgetc+0x13>
    return -1;
80106dc4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106dc9:	eb 2e                	jmp    80106df9 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106dcb:	68 fd 03 00 00       	push   $0x3fd
80106dd0:	e8 59 fe ff ff       	call   80106c2e <inb>
80106dd5:	83 c4 04             	add    $0x4,%esp
80106dd8:	0f b6 c0             	movzbl %al,%eax
80106ddb:	83 e0 01             	and    $0x1,%eax
80106dde:	85 c0                	test   %eax,%eax
80106de0:	75 07                	jne    80106de9 <uartgetc+0x31>
    return -1;
80106de2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106de7:	eb 10                	jmp    80106df9 <uartgetc+0x41>
  return inb(COM1+0);
80106de9:	68 f8 03 00 00       	push   $0x3f8
80106dee:	e8 3b fe ff ff       	call   80106c2e <inb>
80106df3:	83 c4 04             	add    $0x4,%esp
80106df6:	0f b6 c0             	movzbl %al,%eax
}
80106df9:	c9                   	leave  
80106dfa:	c3                   	ret    

80106dfb <uartintr>:

void
uartintr(void)
{
80106dfb:	55                   	push   %ebp
80106dfc:	89 e5                	mov    %esp,%ebp
80106dfe:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106e01:	83 ec 0c             	sub    $0xc,%esp
80106e04:	68 b8 6d 10 80       	push   $0x80106db8
80106e09:	e8 41 9a ff ff       	call   8010084f <consoleintr>
80106e0e:	83 c4 10             	add    $0x10,%esp
}
80106e11:	90                   	nop
80106e12:	c9                   	leave  
80106e13:	c3                   	ret    

80106e14 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106e14:	6a 00                	push   $0x0
  pushl $0
80106e16:	6a 00                	push   $0x0
  jmp alltraps
80106e18:	e9 d1 f9 ff ff       	jmp    801067ee <alltraps>

80106e1d <vector1>:
.globl vector1
vector1:
  pushl $0
80106e1d:	6a 00                	push   $0x0
  pushl $1
80106e1f:	6a 01                	push   $0x1
  jmp alltraps
80106e21:	e9 c8 f9 ff ff       	jmp    801067ee <alltraps>

80106e26 <vector2>:
.globl vector2
vector2:
  pushl $0
80106e26:	6a 00                	push   $0x0
  pushl $2
80106e28:	6a 02                	push   $0x2
  jmp alltraps
80106e2a:	e9 bf f9 ff ff       	jmp    801067ee <alltraps>

80106e2f <vector3>:
.globl vector3
vector3:
  pushl $0
80106e2f:	6a 00                	push   $0x0
  pushl $3
80106e31:	6a 03                	push   $0x3
  jmp alltraps
80106e33:	e9 b6 f9 ff ff       	jmp    801067ee <alltraps>

80106e38 <vector4>:
.globl vector4
vector4:
  pushl $0
80106e38:	6a 00                	push   $0x0
  pushl $4
80106e3a:	6a 04                	push   $0x4
  jmp alltraps
80106e3c:	e9 ad f9 ff ff       	jmp    801067ee <alltraps>

80106e41 <vector5>:
.globl vector5
vector5:
  pushl $0
80106e41:	6a 00                	push   $0x0
  pushl $5
80106e43:	6a 05                	push   $0x5
  jmp alltraps
80106e45:	e9 a4 f9 ff ff       	jmp    801067ee <alltraps>

80106e4a <vector6>:
.globl vector6
vector6:
  pushl $0
80106e4a:	6a 00                	push   $0x0
  pushl $6
80106e4c:	6a 06                	push   $0x6
  jmp alltraps
80106e4e:	e9 9b f9 ff ff       	jmp    801067ee <alltraps>

80106e53 <vector7>:
.globl vector7
vector7:
  pushl $0
80106e53:	6a 00                	push   $0x0
  pushl $7
80106e55:	6a 07                	push   $0x7
  jmp alltraps
80106e57:	e9 92 f9 ff ff       	jmp    801067ee <alltraps>

80106e5c <vector8>:
.globl vector8
vector8:
  pushl $8
80106e5c:	6a 08                	push   $0x8
  jmp alltraps
80106e5e:	e9 8b f9 ff ff       	jmp    801067ee <alltraps>

80106e63 <vector9>:
.globl vector9
vector9:
  pushl $0
80106e63:	6a 00                	push   $0x0
  pushl $9
80106e65:	6a 09                	push   $0x9
  jmp alltraps
80106e67:	e9 82 f9 ff ff       	jmp    801067ee <alltraps>

80106e6c <vector10>:
.globl vector10
vector10:
  pushl $10
80106e6c:	6a 0a                	push   $0xa
  jmp alltraps
80106e6e:	e9 7b f9 ff ff       	jmp    801067ee <alltraps>

80106e73 <vector11>:
.globl vector11
vector11:
  pushl $11
80106e73:	6a 0b                	push   $0xb
  jmp alltraps
80106e75:	e9 74 f9 ff ff       	jmp    801067ee <alltraps>

80106e7a <vector12>:
.globl vector12
vector12:
  pushl $12
80106e7a:	6a 0c                	push   $0xc
  jmp alltraps
80106e7c:	e9 6d f9 ff ff       	jmp    801067ee <alltraps>

80106e81 <vector13>:
.globl vector13
vector13:
  pushl $13
80106e81:	6a 0d                	push   $0xd
  jmp alltraps
80106e83:	e9 66 f9 ff ff       	jmp    801067ee <alltraps>

80106e88 <vector14>:
.globl vector14
vector14:
  pushl $14
80106e88:	6a 0e                	push   $0xe
  jmp alltraps
80106e8a:	e9 5f f9 ff ff       	jmp    801067ee <alltraps>

80106e8f <vector15>:
.globl vector15
vector15:
  pushl $0
80106e8f:	6a 00                	push   $0x0
  pushl $15
80106e91:	6a 0f                	push   $0xf
  jmp alltraps
80106e93:	e9 56 f9 ff ff       	jmp    801067ee <alltraps>

80106e98 <vector16>:
.globl vector16
vector16:
  pushl $0
80106e98:	6a 00                	push   $0x0
  pushl $16
80106e9a:	6a 10                	push   $0x10
  jmp alltraps
80106e9c:	e9 4d f9 ff ff       	jmp    801067ee <alltraps>

80106ea1 <vector17>:
.globl vector17
vector17:
  pushl $17
80106ea1:	6a 11                	push   $0x11
  jmp alltraps
80106ea3:	e9 46 f9 ff ff       	jmp    801067ee <alltraps>

80106ea8 <vector18>:
.globl vector18
vector18:
  pushl $0
80106ea8:	6a 00                	push   $0x0
  pushl $18
80106eaa:	6a 12                	push   $0x12
  jmp alltraps
80106eac:	e9 3d f9 ff ff       	jmp    801067ee <alltraps>

80106eb1 <vector19>:
.globl vector19
vector19:
  pushl $0
80106eb1:	6a 00                	push   $0x0
  pushl $19
80106eb3:	6a 13                	push   $0x13
  jmp alltraps
80106eb5:	e9 34 f9 ff ff       	jmp    801067ee <alltraps>

80106eba <vector20>:
.globl vector20
vector20:
  pushl $0
80106eba:	6a 00                	push   $0x0
  pushl $20
80106ebc:	6a 14                	push   $0x14
  jmp alltraps
80106ebe:	e9 2b f9 ff ff       	jmp    801067ee <alltraps>

80106ec3 <vector21>:
.globl vector21
vector21:
  pushl $0
80106ec3:	6a 00                	push   $0x0
  pushl $21
80106ec5:	6a 15                	push   $0x15
  jmp alltraps
80106ec7:	e9 22 f9 ff ff       	jmp    801067ee <alltraps>

80106ecc <vector22>:
.globl vector22
vector22:
  pushl $0
80106ecc:	6a 00                	push   $0x0
  pushl $22
80106ece:	6a 16                	push   $0x16
  jmp alltraps
80106ed0:	e9 19 f9 ff ff       	jmp    801067ee <alltraps>

80106ed5 <vector23>:
.globl vector23
vector23:
  pushl $0
80106ed5:	6a 00                	push   $0x0
  pushl $23
80106ed7:	6a 17                	push   $0x17
  jmp alltraps
80106ed9:	e9 10 f9 ff ff       	jmp    801067ee <alltraps>

80106ede <vector24>:
.globl vector24
vector24:
  pushl $0
80106ede:	6a 00                	push   $0x0
  pushl $24
80106ee0:	6a 18                	push   $0x18
  jmp alltraps
80106ee2:	e9 07 f9 ff ff       	jmp    801067ee <alltraps>

80106ee7 <vector25>:
.globl vector25
vector25:
  pushl $0
80106ee7:	6a 00                	push   $0x0
  pushl $25
80106ee9:	6a 19                	push   $0x19
  jmp alltraps
80106eeb:	e9 fe f8 ff ff       	jmp    801067ee <alltraps>

80106ef0 <vector26>:
.globl vector26
vector26:
  pushl $0
80106ef0:	6a 00                	push   $0x0
  pushl $26
80106ef2:	6a 1a                	push   $0x1a
  jmp alltraps
80106ef4:	e9 f5 f8 ff ff       	jmp    801067ee <alltraps>

80106ef9 <vector27>:
.globl vector27
vector27:
  pushl $0
80106ef9:	6a 00                	push   $0x0
  pushl $27
80106efb:	6a 1b                	push   $0x1b
  jmp alltraps
80106efd:	e9 ec f8 ff ff       	jmp    801067ee <alltraps>

80106f02 <vector28>:
.globl vector28
vector28:
  pushl $0
80106f02:	6a 00                	push   $0x0
  pushl $28
80106f04:	6a 1c                	push   $0x1c
  jmp alltraps
80106f06:	e9 e3 f8 ff ff       	jmp    801067ee <alltraps>

80106f0b <vector29>:
.globl vector29
vector29:
  pushl $0
80106f0b:	6a 00                	push   $0x0
  pushl $29
80106f0d:	6a 1d                	push   $0x1d
  jmp alltraps
80106f0f:	e9 da f8 ff ff       	jmp    801067ee <alltraps>

80106f14 <vector30>:
.globl vector30
vector30:
  pushl $0
80106f14:	6a 00                	push   $0x0
  pushl $30
80106f16:	6a 1e                	push   $0x1e
  jmp alltraps
80106f18:	e9 d1 f8 ff ff       	jmp    801067ee <alltraps>

80106f1d <vector31>:
.globl vector31
vector31:
  pushl $0
80106f1d:	6a 00                	push   $0x0
  pushl $31
80106f1f:	6a 1f                	push   $0x1f
  jmp alltraps
80106f21:	e9 c8 f8 ff ff       	jmp    801067ee <alltraps>

80106f26 <vector32>:
.globl vector32
vector32:
  pushl $0
80106f26:	6a 00                	push   $0x0
  pushl $32
80106f28:	6a 20                	push   $0x20
  jmp alltraps
80106f2a:	e9 bf f8 ff ff       	jmp    801067ee <alltraps>

80106f2f <vector33>:
.globl vector33
vector33:
  pushl $0
80106f2f:	6a 00                	push   $0x0
  pushl $33
80106f31:	6a 21                	push   $0x21
  jmp alltraps
80106f33:	e9 b6 f8 ff ff       	jmp    801067ee <alltraps>

80106f38 <vector34>:
.globl vector34
vector34:
  pushl $0
80106f38:	6a 00                	push   $0x0
  pushl $34
80106f3a:	6a 22                	push   $0x22
  jmp alltraps
80106f3c:	e9 ad f8 ff ff       	jmp    801067ee <alltraps>

80106f41 <vector35>:
.globl vector35
vector35:
  pushl $0
80106f41:	6a 00                	push   $0x0
  pushl $35
80106f43:	6a 23                	push   $0x23
  jmp alltraps
80106f45:	e9 a4 f8 ff ff       	jmp    801067ee <alltraps>

80106f4a <vector36>:
.globl vector36
vector36:
  pushl $0
80106f4a:	6a 00                	push   $0x0
  pushl $36
80106f4c:	6a 24                	push   $0x24
  jmp alltraps
80106f4e:	e9 9b f8 ff ff       	jmp    801067ee <alltraps>

80106f53 <vector37>:
.globl vector37
vector37:
  pushl $0
80106f53:	6a 00                	push   $0x0
  pushl $37
80106f55:	6a 25                	push   $0x25
  jmp alltraps
80106f57:	e9 92 f8 ff ff       	jmp    801067ee <alltraps>

80106f5c <vector38>:
.globl vector38
vector38:
  pushl $0
80106f5c:	6a 00                	push   $0x0
  pushl $38
80106f5e:	6a 26                	push   $0x26
  jmp alltraps
80106f60:	e9 89 f8 ff ff       	jmp    801067ee <alltraps>

80106f65 <vector39>:
.globl vector39
vector39:
  pushl $0
80106f65:	6a 00                	push   $0x0
  pushl $39
80106f67:	6a 27                	push   $0x27
  jmp alltraps
80106f69:	e9 80 f8 ff ff       	jmp    801067ee <alltraps>

80106f6e <vector40>:
.globl vector40
vector40:
  pushl $0
80106f6e:	6a 00                	push   $0x0
  pushl $40
80106f70:	6a 28                	push   $0x28
  jmp alltraps
80106f72:	e9 77 f8 ff ff       	jmp    801067ee <alltraps>

80106f77 <vector41>:
.globl vector41
vector41:
  pushl $0
80106f77:	6a 00                	push   $0x0
  pushl $41
80106f79:	6a 29                	push   $0x29
  jmp alltraps
80106f7b:	e9 6e f8 ff ff       	jmp    801067ee <alltraps>

80106f80 <vector42>:
.globl vector42
vector42:
  pushl $0
80106f80:	6a 00                	push   $0x0
  pushl $42
80106f82:	6a 2a                	push   $0x2a
  jmp alltraps
80106f84:	e9 65 f8 ff ff       	jmp    801067ee <alltraps>

80106f89 <vector43>:
.globl vector43
vector43:
  pushl $0
80106f89:	6a 00                	push   $0x0
  pushl $43
80106f8b:	6a 2b                	push   $0x2b
  jmp alltraps
80106f8d:	e9 5c f8 ff ff       	jmp    801067ee <alltraps>

80106f92 <vector44>:
.globl vector44
vector44:
  pushl $0
80106f92:	6a 00                	push   $0x0
  pushl $44
80106f94:	6a 2c                	push   $0x2c
  jmp alltraps
80106f96:	e9 53 f8 ff ff       	jmp    801067ee <alltraps>

80106f9b <vector45>:
.globl vector45
vector45:
  pushl $0
80106f9b:	6a 00                	push   $0x0
  pushl $45
80106f9d:	6a 2d                	push   $0x2d
  jmp alltraps
80106f9f:	e9 4a f8 ff ff       	jmp    801067ee <alltraps>

80106fa4 <vector46>:
.globl vector46
vector46:
  pushl $0
80106fa4:	6a 00                	push   $0x0
  pushl $46
80106fa6:	6a 2e                	push   $0x2e
  jmp alltraps
80106fa8:	e9 41 f8 ff ff       	jmp    801067ee <alltraps>

80106fad <vector47>:
.globl vector47
vector47:
  pushl $0
80106fad:	6a 00                	push   $0x0
  pushl $47
80106faf:	6a 2f                	push   $0x2f
  jmp alltraps
80106fb1:	e9 38 f8 ff ff       	jmp    801067ee <alltraps>

80106fb6 <vector48>:
.globl vector48
vector48:
  pushl $0
80106fb6:	6a 00                	push   $0x0
  pushl $48
80106fb8:	6a 30                	push   $0x30
  jmp alltraps
80106fba:	e9 2f f8 ff ff       	jmp    801067ee <alltraps>

80106fbf <vector49>:
.globl vector49
vector49:
  pushl $0
80106fbf:	6a 00                	push   $0x0
  pushl $49
80106fc1:	6a 31                	push   $0x31
  jmp alltraps
80106fc3:	e9 26 f8 ff ff       	jmp    801067ee <alltraps>

80106fc8 <vector50>:
.globl vector50
vector50:
  pushl $0
80106fc8:	6a 00                	push   $0x0
  pushl $50
80106fca:	6a 32                	push   $0x32
  jmp alltraps
80106fcc:	e9 1d f8 ff ff       	jmp    801067ee <alltraps>

80106fd1 <vector51>:
.globl vector51
vector51:
  pushl $0
80106fd1:	6a 00                	push   $0x0
  pushl $51
80106fd3:	6a 33                	push   $0x33
  jmp alltraps
80106fd5:	e9 14 f8 ff ff       	jmp    801067ee <alltraps>

80106fda <vector52>:
.globl vector52
vector52:
  pushl $0
80106fda:	6a 00                	push   $0x0
  pushl $52
80106fdc:	6a 34                	push   $0x34
  jmp alltraps
80106fde:	e9 0b f8 ff ff       	jmp    801067ee <alltraps>

80106fe3 <vector53>:
.globl vector53
vector53:
  pushl $0
80106fe3:	6a 00                	push   $0x0
  pushl $53
80106fe5:	6a 35                	push   $0x35
  jmp alltraps
80106fe7:	e9 02 f8 ff ff       	jmp    801067ee <alltraps>

80106fec <vector54>:
.globl vector54
vector54:
  pushl $0
80106fec:	6a 00                	push   $0x0
  pushl $54
80106fee:	6a 36                	push   $0x36
  jmp alltraps
80106ff0:	e9 f9 f7 ff ff       	jmp    801067ee <alltraps>

80106ff5 <vector55>:
.globl vector55
vector55:
  pushl $0
80106ff5:	6a 00                	push   $0x0
  pushl $55
80106ff7:	6a 37                	push   $0x37
  jmp alltraps
80106ff9:	e9 f0 f7 ff ff       	jmp    801067ee <alltraps>

80106ffe <vector56>:
.globl vector56
vector56:
  pushl $0
80106ffe:	6a 00                	push   $0x0
  pushl $56
80107000:	6a 38                	push   $0x38
  jmp alltraps
80107002:	e9 e7 f7 ff ff       	jmp    801067ee <alltraps>

80107007 <vector57>:
.globl vector57
vector57:
  pushl $0
80107007:	6a 00                	push   $0x0
  pushl $57
80107009:	6a 39                	push   $0x39
  jmp alltraps
8010700b:	e9 de f7 ff ff       	jmp    801067ee <alltraps>

80107010 <vector58>:
.globl vector58
vector58:
  pushl $0
80107010:	6a 00                	push   $0x0
  pushl $58
80107012:	6a 3a                	push   $0x3a
  jmp alltraps
80107014:	e9 d5 f7 ff ff       	jmp    801067ee <alltraps>

80107019 <vector59>:
.globl vector59
vector59:
  pushl $0
80107019:	6a 00                	push   $0x0
  pushl $59
8010701b:	6a 3b                	push   $0x3b
  jmp alltraps
8010701d:	e9 cc f7 ff ff       	jmp    801067ee <alltraps>

80107022 <vector60>:
.globl vector60
vector60:
  pushl $0
80107022:	6a 00                	push   $0x0
  pushl $60
80107024:	6a 3c                	push   $0x3c
  jmp alltraps
80107026:	e9 c3 f7 ff ff       	jmp    801067ee <alltraps>

8010702b <vector61>:
.globl vector61
vector61:
  pushl $0
8010702b:	6a 00                	push   $0x0
  pushl $61
8010702d:	6a 3d                	push   $0x3d
  jmp alltraps
8010702f:	e9 ba f7 ff ff       	jmp    801067ee <alltraps>

80107034 <vector62>:
.globl vector62
vector62:
  pushl $0
80107034:	6a 00                	push   $0x0
  pushl $62
80107036:	6a 3e                	push   $0x3e
  jmp alltraps
80107038:	e9 b1 f7 ff ff       	jmp    801067ee <alltraps>

8010703d <vector63>:
.globl vector63
vector63:
  pushl $0
8010703d:	6a 00                	push   $0x0
  pushl $63
8010703f:	6a 3f                	push   $0x3f
  jmp alltraps
80107041:	e9 a8 f7 ff ff       	jmp    801067ee <alltraps>

80107046 <vector64>:
.globl vector64
vector64:
  pushl $0
80107046:	6a 00                	push   $0x0
  pushl $64
80107048:	6a 40                	push   $0x40
  jmp alltraps
8010704a:	e9 9f f7 ff ff       	jmp    801067ee <alltraps>

8010704f <vector65>:
.globl vector65
vector65:
  pushl $0
8010704f:	6a 00                	push   $0x0
  pushl $65
80107051:	6a 41                	push   $0x41
  jmp alltraps
80107053:	e9 96 f7 ff ff       	jmp    801067ee <alltraps>

80107058 <vector66>:
.globl vector66
vector66:
  pushl $0
80107058:	6a 00                	push   $0x0
  pushl $66
8010705a:	6a 42                	push   $0x42
  jmp alltraps
8010705c:	e9 8d f7 ff ff       	jmp    801067ee <alltraps>

80107061 <vector67>:
.globl vector67
vector67:
  pushl $0
80107061:	6a 00                	push   $0x0
  pushl $67
80107063:	6a 43                	push   $0x43
  jmp alltraps
80107065:	e9 84 f7 ff ff       	jmp    801067ee <alltraps>

8010706a <vector68>:
.globl vector68
vector68:
  pushl $0
8010706a:	6a 00                	push   $0x0
  pushl $68
8010706c:	6a 44                	push   $0x44
  jmp alltraps
8010706e:	e9 7b f7 ff ff       	jmp    801067ee <alltraps>

80107073 <vector69>:
.globl vector69
vector69:
  pushl $0
80107073:	6a 00                	push   $0x0
  pushl $69
80107075:	6a 45                	push   $0x45
  jmp alltraps
80107077:	e9 72 f7 ff ff       	jmp    801067ee <alltraps>

8010707c <vector70>:
.globl vector70
vector70:
  pushl $0
8010707c:	6a 00                	push   $0x0
  pushl $70
8010707e:	6a 46                	push   $0x46
  jmp alltraps
80107080:	e9 69 f7 ff ff       	jmp    801067ee <alltraps>

80107085 <vector71>:
.globl vector71
vector71:
  pushl $0
80107085:	6a 00                	push   $0x0
  pushl $71
80107087:	6a 47                	push   $0x47
  jmp alltraps
80107089:	e9 60 f7 ff ff       	jmp    801067ee <alltraps>

8010708e <vector72>:
.globl vector72
vector72:
  pushl $0
8010708e:	6a 00                	push   $0x0
  pushl $72
80107090:	6a 48                	push   $0x48
  jmp alltraps
80107092:	e9 57 f7 ff ff       	jmp    801067ee <alltraps>

80107097 <vector73>:
.globl vector73
vector73:
  pushl $0
80107097:	6a 00                	push   $0x0
  pushl $73
80107099:	6a 49                	push   $0x49
  jmp alltraps
8010709b:	e9 4e f7 ff ff       	jmp    801067ee <alltraps>

801070a0 <vector74>:
.globl vector74
vector74:
  pushl $0
801070a0:	6a 00                	push   $0x0
  pushl $74
801070a2:	6a 4a                	push   $0x4a
  jmp alltraps
801070a4:	e9 45 f7 ff ff       	jmp    801067ee <alltraps>

801070a9 <vector75>:
.globl vector75
vector75:
  pushl $0
801070a9:	6a 00                	push   $0x0
  pushl $75
801070ab:	6a 4b                	push   $0x4b
  jmp alltraps
801070ad:	e9 3c f7 ff ff       	jmp    801067ee <alltraps>

801070b2 <vector76>:
.globl vector76
vector76:
  pushl $0
801070b2:	6a 00                	push   $0x0
  pushl $76
801070b4:	6a 4c                	push   $0x4c
  jmp alltraps
801070b6:	e9 33 f7 ff ff       	jmp    801067ee <alltraps>

801070bb <vector77>:
.globl vector77
vector77:
  pushl $0
801070bb:	6a 00                	push   $0x0
  pushl $77
801070bd:	6a 4d                	push   $0x4d
  jmp alltraps
801070bf:	e9 2a f7 ff ff       	jmp    801067ee <alltraps>

801070c4 <vector78>:
.globl vector78
vector78:
  pushl $0
801070c4:	6a 00                	push   $0x0
  pushl $78
801070c6:	6a 4e                	push   $0x4e
  jmp alltraps
801070c8:	e9 21 f7 ff ff       	jmp    801067ee <alltraps>

801070cd <vector79>:
.globl vector79
vector79:
  pushl $0
801070cd:	6a 00                	push   $0x0
  pushl $79
801070cf:	6a 4f                	push   $0x4f
  jmp alltraps
801070d1:	e9 18 f7 ff ff       	jmp    801067ee <alltraps>

801070d6 <vector80>:
.globl vector80
vector80:
  pushl $0
801070d6:	6a 00                	push   $0x0
  pushl $80
801070d8:	6a 50                	push   $0x50
  jmp alltraps
801070da:	e9 0f f7 ff ff       	jmp    801067ee <alltraps>

801070df <vector81>:
.globl vector81
vector81:
  pushl $0
801070df:	6a 00                	push   $0x0
  pushl $81
801070e1:	6a 51                	push   $0x51
  jmp alltraps
801070e3:	e9 06 f7 ff ff       	jmp    801067ee <alltraps>

801070e8 <vector82>:
.globl vector82
vector82:
  pushl $0
801070e8:	6a 00                	push   $0x0
  pushl $82
801070ea:	6a 52                	push   $0x52
  jmp alltraps
801070ec:	e9 fd f6 ff ff       	jmp    801067ee <alltraps>

801070f1 <vector83>:
.globl vector83
vector83:
  pushl $0
801070f1:	6a 00                	push   $0x0
  pushl $83
801070f3:	6a 53                	push   $0x53
  jmp alltraps
801070f5:	e9 f4 f6 ff ff       	jmp    801067ee <alltraps>

801070fa <vector84>:
.globl vector84
vector84:
  pushl $0
801070fa:	6a 00                	push   $0x0
  pushl $84
801070fc:	6a 54                	push   $0x54
  jmp alltraps
801070fe:	e9 eb f6 ff ff       	jmp    801067ee <alltraps>

80107103 <vector85>:
.globl vector85
vector85:
  pushl $0
80107103:	6a 00                	push   $0x0
  pushl $85
80107105:	6a 55                	push   $0x55
  jmp alltraps
80107107:	e9 e2 f6 ff ff       	jmp    801067ee <alltraps>

8010710c <vector86>:
.globl vector86
vector86:
  pushl $0
8010710c:	6a 00                	push   $0x0
  pushl $86
8010710e:	6a 56                	push   $0x56
  jmp alltraps
80107110:	e9 d9 f6 ff ff       	jmp    801067ee <alltraps>

80107115 <vector87>:
.globl vector87
vector87:
  pushl $0
80107115:	6a 00                	push   $0x0
  pushl $87
80107117:	6a 57                	push   $0x57
  jmp alltraps
80107119:	e9 d0 f6 ff ff       	jmp    801067ee <alltraps>

8010711e <vector88>:
.globl vector88
vector88:
  pushl $0
8010711e:	6a 00                	push   $0x0
  pushl $88
80107120:	6a 58                	push   $0x58
  jmp alltraps
80107122:	e9 c7 f6 ff ff       	jmp    801067ee <alltraps>

80107127 <vector89>:
.globl vector89
vector89:
  pushl $0
80107127:	6a 00                	push   $0x0
  pushl $89
80107129:	6a 59                	push   $0x59
  jmp alltraps
8010712b:	e9 be f6 ff ff       	jmp    801067ee <alltraps>

80107130 <vector90>:
.globl vector90
vector90:
  pushl $0
80107130:	6a 00                	push   $0x0
  pushl $90
80107132:	6a 5a                	push   $0x5a
  jmp alltraps
80107134:	e9 b5 f6 ff ff       	jmp    801067ee <alltraps>

80107139 <vector91>:
.globl vector91
vector91:
  pushl $0
80107139:	6a 00                	push   $0x0
  pushl $91
8010713b:	6a 5b                	push   $0x5b
  jmp alltraps
8010713d:	e9 ac f6 ff ff       	jmp    801067ee <alltraps>

80107142 <vector92>:
.globl vector92
vector92:
  pushl $0
80107142:	6a 00                	push   $0x0
  pushl $92
80107144:	6a 5c                	push   $0x5c
  jmp alltraps
80107146:	e9 a3 f6 ff ff       	jmp    801067ee <alltraps>

8010714b <vector93>:
.globl vector93
vector93:
  pushl $0
8010714b:	6a 00                	push   $0x0
  pushl $93
8010714d:	6a 5d                	push   $0x5d
  jmp alltraps
8010714f:	e9 9a f6 ff ff       	jmp    801067ee <alltraps>

80107154 <vector94>:
.globl vector94
vector94:
  pushl $0
80107154:	6a 00                	push   $0x0
  pushl $94
80107156:	6a 5e                	push   $0x5e
  jmp alltraps
80107158:	e9 91 f6 ff ff       	jmp    801067ee <alltraps>

8010715d <vector95>:
.globl vector95
vector95:
  pushl $0
8010715d:	6a 00                	push   $0x0
  pushl $95
8010715f:	6a 5f                	push   $0x5f
  jmp alltraps
80107161:	e9 88 f6 ff ff       	jmp    801067ee <alltraps>

80107166 <vector96>:
.globl vector96
vector96:
  pushl $0
80107166:	6a 00                	push   $0x0
  pushl $96
80107168:	6a 60                	push   $0x60
  jmp alltraps
8010716a:	e9 7f f6 ff ff       	jmp    801067ee <alltraps>

8010716f <vector97>:
.globl vector97
vector97:
  pushl $0
8010716f:	6a 00                	push   $0x0
  pushl $97
80107171:	6a 61                	push   $0x61
  jmp alltraps
80107173:	e9 76 f6 ff ff       	jmp    801067ee <alltraps>

80107178 <vector98>:
.globl vector98
vector98:
  pushl $0
80107178:	6a 00                	push   $0x0
  pushl $98
8010717a:	6a 62                	push   $0x62
  jmp alltraps
8010717c:	e9 6d f6 ff ff       	jmp    801067ee <alltraps>

80107181 <vector99>:
.globl vector99
vector99:
  pushl $0
80107181:	6a 00                	push   $0x0
  pushl $99
80107183:	6a 63                	push   $0x63
  jmp alltraps
80107185:	e9 64 f6 ff ff       	jmp    801067ee <alltraps>

8010718a <vector100>:
.globl vector100
vector100:
  pushl $0
8010718a:	6a 00                	push   $0x0
  pushl $100
8010718c:	6a 64                	push   $0x64
  jmp alltraps
8010718e:	e9 5b f6 ff ff       	jmp    801067ee <alltraps>

80107193 <vector101>:
.globl vector101
vector101:
  pushl $0
80107193:	6a 00                	push   $0x0
  pushl $101
80107195:	6a 65                	push   $0x65
  jmp alltraps
80107197:	e9 52 f6 ff ff       	jmp    801067ee <alltraps>

8010719c <vector102>:
.globl vector102
vector102:
  pushl $0
8010719c:	6a 00                	push   $0x0
  pushl $102
8010719e:	6a 66                	push   $0x66
  jmp alltraps
801071a0:	e9 49 f6 ff ff       	jmp    801067ee <alltraps>

801071a5 <vector103>:
.globl vector103
vector103:
  pushl $0
801071a5:	6a 00                	push   $0x0
  pushl $103
801071a7:	6a 67                	push   $0x67
  jmp alltraps
801071a9:	e9 40 f6 ff ff       	jmp    801067ee <alltraps>

801071ae <vector104>:
.globl vector104
vector104:
  pushl $0
801071ae:	6a 00                	push   $0x0
  pushl $104
801071b0:	6a 68                	push   $0x68
  jmp alltraps
801071b2:	e9 37 f6 ff ff       	jmp    801067ee <alltraps>

801071b7 <vector105>:
.globl vector105
vector105:
  pushl $0
801071b7:	6a 00                	push   $0x0
  pushl $105
801071b9:	6a 69                	push   $0x69
  jmp alltraps
801071bb:	e9 2e f6 ff ff       	jmp    801067ee <alltraps>

801071c0 <vector106>:
.globl vector106
vector106:
  pushl $0
801071c0:	6a 00                	push   $0x0
  pushl $106
801071c2:	6a 6a                	push   $0x6a
  jmp alltraps
801071c4:	e9 25 f6 ff ff       	jmp    801067ee <alltraps>

801071c9 <vector107>:
.globl vector107
vector107:
  pushl $0
801071c9:	6a 00                	push   $0x0
  pushl $107
801071cb:	6a 6b                	push   $0x6b
  jmp alltraps
801071cd:	e9 1c f6 ff ff       	jmp    801067ee <alltraps>

801071d2 <vector108>:
.globl vector108
vector108:
  pushl $0
801071d2:	6a 00                	push   $0x0
  pushl $108
801071d4:	6a 6c                	push   $0x6c
  jmp alltraps
801071d6:	e9 13 f6 ff ff       	jmp    801067ee <alltraps>

801071db <vector109>:
.globl vector109
vector109:
  pushl $0
801071db:	6a 00                	push   $0x0
  pushl $109
801071dd:	6a 6d                	push   $0x6d
  jmp alltraps
801071df:	e9 0a f6 ff ff       	jmp    801067ee <alltraps>

801071e4 <vector110>:
.globl vector110
vector110:
  pushl $0
801071e4:	6a 00                	push   $0x0
  pushl $110
801071e6:	6a 6e                	push   $0x6e
  jmp alltraps
801071e8:	e9 01 f6 ff ff       	jmp    801067ee <alltraps>

801071ed <vector111>:
.globl vector111
vector111:
  pushl $0
801071ed:	6a 00                	push   $0x0
  pushl $111
801071ef:	6a 6f                	push   $0x6f
  jmp alltraps
801071f1:	e9 f8 f5 ff ff       	jmp    801067ee <alltraps>

801071f6 <vector112>:
.globl vector112
vector112:
  pushl $0
801071f6:	6a 00                	push   $0x0
  pushl $112
801071f8:	6a 70                	push   $0x70
  jmp alltraps
801071fa:	e9 ef f5 ff ff       	jmp    801067ee <alltraps>

801071ff <vector113>:
.globl vector113
vector113:
  pushl $0
801071ff:	6a 00                	push   $0x0
  pushl $113
80107201:	6a 71                	push   $0x71
  jmp alltraps
80107203:	e9 e6 f5 ff ff       	jmp    801067ee <alltraps>

80107208 <vector114>:
.globl vector114
vector114:
  pushl $0
80107208:	6a 00                	push   $0x0
  pushl $114
8010720a:	6a 72                	push   $0x72
  jmp alltraps
8010720c:	e9 dd f5 ff ff       	jmp    801067ee <alltraps>

80107211 <vector115>:
.globl vector115
vector115:
  pushl $0
80107211:	6a 00                	push   $0x0
  pushl $115
80107213:	6a 73                	push   $0x73
  jmp alltraps
80107215:	e9 d4 f5 ff ff       	jmp    801067ee <alltraps>

8010721a <vector116>:
.globl vector116
vector116:
  pushl $0
8010721a:	6a 00                	push   $0x0
  pushl $116
8010721c:	6a 74                	push   $0x74
  jmp alltraps
8010721e:	e9 cb f5 ff ff       	jmp    801067ee <alltraps>

80107223 <vector117>:
.globl vector117
vector117:
  pushl $0
80107223:	6a 00                	push   $0x0
  pushl $117
80107225:	6a 75                	push   $0x75
  jmp alltraps
80107227:	e9 c2 f5 ff ff       	jmp    801067ee <alltraps>

8010722c <vector118>:
.globl vector118
vector118:
  pushl $0
8010722c:	6a 00                	push   $0x0
  pushl $118
8010722e:	6a 76                	push   $0x76
  jmp alltraps
80107230:	e9 b9 f5 ff ff       	jmp    801067ee <alltraps>

80107235 <vector119>:
.globl vector119
vector119:
  pushl $0
80107235:	6a 00                	push   $0x0
  pushl $119
80107237:	6a 77                	push   $0x77
  jmp alltraps
80107239:	e9 b0 f5 ff ff       	jmp    801067ee <alltraps>

8010723e <vector120>:
.globl vector120
vector120:
  pushl $0
8010723e:	6a 00                	push   $0x0
  pushl $120
80107240:	6a 78                	push   $0x78
  jmp alltraps
80107242:	e9 a7 f5 ff ff       	jmp    801067ee <alltraps>

80107247 <vector121>:
.globl vector121
vector121:
  pushl $0
80107247:	6a 00                	push   $0x0
  pushl $121
80107249:	6a 79                	push   $0x79
  jmp alltraps
8010724b:	e9 9e f5 ff ff       	jmp    801067ee <alltraps>

80107250 <vector122>:
.globl vector122
vector122:
  pushl $0
80107250:	6a 00                	push   $0x0
  pushl $122
80107252:	6a 7a                	push   $0x7a
  jmp alltraps
80107254:	e9 95 f5 ff ff       	jmp    801067ee <alltraps>

80107259 <vector123>:
.globl vector123
vector123:
  pushl $0
80107259:	6a 00                	push   $0x0
  pushl $123
8010725b:	6a 7b                	push   $0x7b
  jmp alltraps
8010725d:	e9 8c f5 ff ff       	jmp    801067ee <alltraps>

80107262 <vector124>:
.globl vector124
vector124:
  pushl $0
80107262:	6a 00                	push   $0x0
  pushl $124
80107264:	6a 7c                	push   $0x7c
  jmp alltraps
80107266:	e9 83 f5 ff ff       	jmp    801067ee <alltraps>

8010726b <vector125>:
.globl vector125
vector125:
  pushl $0
8010726b:	6a 00                	push   $0x0
  pushl $125
8010726d:	6a 7d                	push   $0x7d
  jmp alltraps
8010726f:	e9 7a f5 ff ff       	jmp    801067ee <alltraps>

80107274 <vector126>:
.globl vector126
vector126:
  pushl $0
80107274:	6a 00                	push   $0x0
  pushl $126
80107276:	6a 7e                	push   $0x7e
  jmp alltraps
80107278:	e9 71 f5 ff ff       	jmp    801067ee <alltraps>

8010727d <vector127>:
.globl vector127
vector127:
  pushl $0
8010727d:	6a 00                	push   $0x0
  pushl $127
8010727f:	6a 7f                	push   $0x7f
  jmp alltraps
80107281:	e9 68 f5 ff ff       	jmp    801067ee <alltraps>

80107286 <vector128>:
.globl vector128
vector128:
  pushl $0
80107286:	6a 00                	push   $0x0
  pushl $128
80107288:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010728d:	e9 5c f5 ff ff       	jmp    801067ee <alltraps>

80107292 <vector129>:
.globl vector129
vector129:
  pushl $0
80107292:	6a 00                	push   $0x0
  pushl $129
80107294:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107299:	e9 50 f5 ff ff       	jmp    801067ee <alltraps>

8010729e <vector130>:
.globl vector130
vector130:
  pushl $0
8010729e:	6a 00                	push   $0x0
  pushl $130
801072a0:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801072a5:	e9 44 f5 ff ff       	jmp    801067ee <alltraps>

801072aa <vector131>:
.globl vector131
vector131:
  pushl $0
801072aa:	6a 00                	push   $0x0
  pushl $131
801072ac:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801072b1:	e9 38 f5 ff ff       	jmp    801067ee <alltraps>

801072b6 <vector132>:
.globl vector132
vector132:
  pushl $0
801072b6:	6a 00                	push   $0x0
  pushl $132
801072b8:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801072bd:	e9 2c f5 ff ff       	jmp    801067ee <alltraps>

801072c2 <vector133>:
.globl vector133
vector133:
  pushl $0
801072c2:	6a 00                	push   $0x0
  pushl $133
801072c4:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801072c9:	e9 20 f5 ff ff       	jmp    801067ee <alltraps>

801072ce <vector134>:
.globl vector134
vector134:
  pushl $0
801072ce:	6a 00                	push   $0x0
  pushl $134
801072d0:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801072d5:	e9 14 f5 ff ff       	jmp    801067ee <alltraps>

801072da <vector135>:
.globl vector135
vector135:
  pushl $0
801072da:	6a 00                	push   $0x0
  pushl $135
801072dc:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801072e1:	e9 08 f5 ff ff       	jmp    801067ee <alltraps>

801072e6 <vector136>:
.globl vector136
vector136:
  pushl $0
801072e6:	6a 00                	push   $0x0
  pushl $136
801072e8:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801072ed:	e9 fc f4 ff ff       	jmp    801067ee <alltraps>

801072f2 <vector137>:
.globl vector137
vector137:
  pushl $0
801072f2:	6a 00                	push   $0x0
  pushl $137
801072f4:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801072f9:	e9 f0 f4 ff ff       	jmp    801067ee <alltraps>

801072fe <vector138>:
.globl vector138
vector138:
  pushl $0
801072fe:	6a 00                	push   $0x0
  pushl $138
80107300:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107305:	e9 e4 f4 ff ff       	jmp    801067ee <alltraps>

8010730a <vector139>:
.globl vector139
vector139:
  pushl $0
8010730a:	6a 00                	push   $0x0
  pushl $139
8010730c:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107311:	e9 d8 f4 ff ff       	jmp    801067ee <alltraps>

80107316 <vector140>:
.globl vector140
vector140:
  pushl $0
80107316:	6a 00                	push   $0x0
  pushl $140
80107318:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
8010731d:	e9 cc f4 ff ff       	jmp    801067ee <alltraps>

80107322 <vector141>:
.globl vector141
vector141:
  pushl $0
80107322:	6a 00                	push   $0x0
  pushl $141
80107324:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107329:	e9 c0 f4 ff ff       	jmp    801067ee <alltraps>

8010732e <vector142>:
.globl vector142
vector142:
  pushl $0
8010732e:	6a 00                	push   $0x0
  pushl $142
80107330:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107335:	e9 b4 f4 ff ff       	jmp    801067ee <alltraps>

8010733a <vector143>:
.globl vector143
vector143:
  pushl $0
8010733a:	6a 00                	push   $0x0
  pushl $143
8010733c:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107341:	e9 a8 f4 ff ff       	jmp    801067ee <alltraps>

80107346 <vector144>:
.globl vector144
vector144:
  pushl $0
80107346:	6a 00                	push   $0x0
  pushl $144
80107348:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010734d:	e9 9c f4 ff ff       	jmp    801067ee <alltraps>

80107352 <vector145>:
.globl vector145
vector145:
  pushl $0
80107352:	6a 00                	push   $0x0
  pushl $145
80107354:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107359:	e9 90 f4 ff ff       	jmp    801067ee <alltraps>

8010735e <vector146>:
.globl vector146
vector146:
  pushl $0
8010735e:	6a 00                	push   $0x0
  pushl $146
80107360:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107365:	e9 84 f4 ff ff       	jmp    801067ee <alltraps>

8010736a <vector147>:
.globl vector147
vector147:
  pushl $0
8010736a:	6a 00                	push   $0x0
  pushl $147
8010736c:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107371:	e9 78 f4 ff ff       	jmp    801067ee <alltraps>

80107376 <vector148>:
.globl vector148
vector148:
  pushl $0
80107376:	6a 00                	push   $0x0
  pushl $148
80107378:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010737d:	e9 6c f4 ff ff       	jmp    801067ee <alltraps>

80107382 <vector149>:
.globl vector149
vector149:
  pushl $0
80107382:	6a 00                	push   $0x0
  pushl $149
80107384:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107389:	e9 60 f4 ff ff       	jmp    801067ee <alltraps>

8010738e <vector150>:
.globl vector150
vector150:
  pushl $0
8010738e:	6a 00                	push   $0x0
  pushl $150
80107390:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107395:	e9 54 f4 ff ff       	jmp    801067ee <alltraps>

8010739a <vector151>:
.globl vector151
vector151:
  pushl $0
8010739a:	6a 00                	push   $0x0
  pushl $151
8010739c:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801073a1:	e9 48 f4 ff ff       	jmp    801067ee <alltraps>

801073a6 <vector152>:
.globl vector152
vector152:
  pushl $0
801073a6:	6a 00                	push   $0x0
  pushl $152
801073a8:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801073ad:	e9 3c f4 ff ff       	jmp    801067ee <alltraps>

801073b2 <vector153>:
.globl vector153
vector153:
  pushl $0
801073b2:	6a 00                	push   $0x0
  pushl $153
801073b4:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801073b9:	e9 30 f4 ff ff       	jmp    801067ee <alltraps>

801073be <vector154>:
.globl vector154
vector154:
  pushl $0
801073be:	6a 00                	push   $0x0
  pushl $154
801073c0:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801073c5:	e9 24 f4 ff ff       	jmp    801067ee <alltraps>

801073ca <vector155>:
.globl vector155
vector155:
  pushl $0
801073ca:	6a 00                	push   $0x0
  pushl $155
801073cc:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801073d1:	e9 18 f4 ff ff       	jmp    801067ee <alltraps>

801073d6 <vector156>:
.globl vector156
vector156:
  pushl $0
801073d6:	6a 00                	push   $0x0
  pushl $156
801073d8:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801073dd:	e9 0c f4 ff ff       	jmp    801067ee <alltraps>

801073e2 <vector157>:
.globl vector157
vector157:
  pushl $0
801073e2:	6a 00                	push   $0x0
  pushl $157
801073e4:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801073e9:	e9 00 f4 ff ff       	jmp    801067ee <alltraps>

801073ee <vector158>:
.globl vector158
vector158:
  pushl $0
801073ee:	6a 00                	push   $0x0
  pushl $158
801073f0:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801073f5:	e9 f4 f3 ff ff       	jmp    801067ee <alltraps>

801073fa <vector159>:
.globl vector159
vector159:
  pushl $0
801073fa:	6a 00                	push   $0x0
  pushl $159
801073fc:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107401:	e9 e8 f3 ff ff       	jmp    801067ee <alltraps>

80107406 <vector160>:
.globl vector160
vector160:
  pushl $0
80107406:	6a 00                	push   $0x0
  pushl $160
80107408:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
8010740d:	e9 dc f3 ff ff       	jmp    801067ee <alltraps>

80107412 <vector161>:
.globl vector161
vector161:
  pushl $0
80107412:	6a 00                	push   $0x0
  pushl $161
80107414:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107419:	e9 d0 f3 ff ff       	jmp    801067ee <alltraps>

8010741e <vector162>:
.globl vector162
vector162:
  pushl $0
8010741e:	6a 00                	push   $0x0
  pushl $162
80107420:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107425:	e9 c4 f3 ff ff       	jmp    801067ee <alltraps>

8010742a <vector163>:
.globl vector163
vector163:
  pushl $0
8010742a:	6a 00                	push   $0x0
  pushl $163
8010742c:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107431:	e9 b8 f3 ff ff       	jmp    801067ee <alltraps>

80107436 <vector164>:
.globl vector164
vector164:
  pushl $0
80107436:	6a 00                	push   $0x0
  pushl $164
80107438:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010743d:	e9 ac f3 ff ff       	jmp    801067ee <alltraps>

80107442 <vector165>:
.globl vector165
vector165:
  pushl $0
80107442:	6a 00                	push   $0x0
  pushl $165
80107444:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107449:	e9 a0 f3 ff ff       	jmp    801067ee <alltraps>

8010744e <vector166>:
.globl vector166
vector166:
  pushl $0
8010744e:	6a 00                	push   $0x0
  pushl $166
80107450:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107455:	e9 94 f3 ff ff       	jmp    801067ee <alltraps>

8010745a <vector167>:
.globl vector167
vector167:
  pushl $0
8010745a:	6a 00                	push   $0x0
  pushl $167
8010745c:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107461:	e9 88 f3 ff ff       	jmp    801067ee <alltraps>

80107466 <vector168>:
.globl vector168
vector168:
  pushl $0
80107466:	6a 00                	push   $0x0
  pushl $168
80107468:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010746d:	e9 7c f3 ff ff       	jmp    801067ee <alltraps>

80107472 <vector169>:
.globl vector169
vector169:
  pushl $0
80107472:	6a 00                	push   $0x0
  pushl $169
80107474:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107479:	e9 70 f3 ff ff       	jmp    801067ee <alltraps>

8010747e <vector170>:
.globl vector170
vector170:
  pushl $0
8010747e:	6a 00                	push   $0x0
  pushl $170
80107480:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107485:	e9 64 f3 ff ff       	jmp    801067ee <alltraps>

8010748a <vector171>:
.globl vector171
vector171:
  pushl $0
8010748a:	6a 00                	push   $0x0
  pushl $171
8010748c:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107491:	e9 58 f3 ff ff       	jmp    801067ee <alltraps>

80107496 <vector172>:
.globl vector172
vector172:
  pushl $0
80107496:	6a 00                	push   $0x0
  pushl $172
80107498:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010749d:	e9 4c f3 ff ff       	jmp    801067ee <alltraps>

801074a2 <vector173>:
.globl vector173
vector173:
  pushl $0
801074a2:	6a 00                	push   $0x0
  pushl $173
801074a4:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801074a9:	e9 40 f3 ff ff       	jmp    801067ee <alltraps>

801074ae <vector174>:
.globl vector174
vector174:
  pushl $0
801074ae:	6a 00                	push   $0x0
  pushl $174
801074b0:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801074b5:	e9 34 f3 ff ff       	jmp    801067ee <alltraps>

801074ba <vector175>:
.globl vector175
vector175:
  pushl $0
801074ba:	6a 00                	push   $0x0
  pushl $175
801074bc:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801074c1:	e9 28 f3 ff ff       	jmp    801067ee <alltraps>

801074c6 <vector176>:
.globl vector176
vector176:
  pushl $0
801074c6:	6a 00                	push   $0x0
  pushl $176
801074c8:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801074cd:	e9 1c f3 ff ff       	jmp    801067ee <alltraps>

801074d2 <vector177>:
.globl vector177
vector177:
  pushl $0
801074d2:	6a 00                	push   $0x0
  pushl $177
801074d4:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801074d9:	e9 10 f3 ff ff       	jmp    801067ee <alltraps>

801074de <vector178>:
.globl vector178
vector178:
  pushl $0
801074de:	6a 00                	push   $0x0
  pushl $178
801074e0:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801074e5:	e9 04 f3 ff ff       	jmp    801067ee <alltraps>

801074ea <vector179>:
.globl vector179
vector179:
  pushl $0
801074ea:	6a 00                	push   $0x0
  pushl $179
801074ec:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801074f1:	e9 f8 f2 ff ff       	jmp    801067ee <alltraps>

801074f6 <vector180>:
.globl vector180
vector180:
  pushl $0
801074f6:	6a 00                	push   $0x0
  pushl $180
801074f8:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801074fd:	e9 ec f2 ff ff       	jmp    801067ee <alltraps>

80107502 <vector181>:
.globl vector181
vector181:
  pushl $0
80107502:	6a 00                	push   $0x0
  pushl $181
80107504:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107509:	e9 e0 f2 ff ff       	jmp    801067ee <alltraps>

8010750e <vector182>:
.globl vector182
vector182:
  pushl $0
8010750e:	6a 00                	push   $0x0
  pushl $182
80107510:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107515:	e9 d4 f2 ff ff       	jmp    801067ee <alltraps>

8010751a <vector183>:
.globl vector183
vector183:
  pushl $0
8010751a:	6a 00                	push   $0x0
  pushl $183
8010751c:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107521:	e9 c8 f2 ff ff       	jmp    801067ee <alltraps>

80107526 <vector184>:
.globl vector184
vector184:
  pushl $0
80107526:	6a 00                	push   $0x0
  pushl $184
80107528:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010752d:	e9 bc f2 ff ff       	jmp    801067ee <alltraps>

80107532 <vector185>:
.globl vector185
vector185:
  pushl $0
80107532:	6a 00                	push   $0x0
  pushl $185
80107534:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107539:	e9 b0 f2 ff ff       	jmp    801067ee <alltraps>

8010753e <vector186>:
.globl vector186
vector186:
  pushl $0
8010753e:	6a 00                	push   $0x0
  pushl $186
80107540:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107545:	e9 a4 f2 ff ff       	jmp    801067ee <alltraps>

8010754a <vector187>:
.globl vector187
vector187:
  pushl $0
8010754a:	6a 00                	push   $0x0
  pushl $187
8010754c:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107551:	e9 98 f2 ff ff       	jmp    801067ee <alltraps>

80107556 <vector188>:
.globl vector188
vector188:
  pushl $0
80107556:	6a 00                	push   $0x0
  pushl $188
80107558:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010755d:	e9 8c f2 ff ff       	jmp    801067ee <alltraps>

80107562 <vector189>:
.globl vector189
vector189:
  pushl $0
80107562:	6a 00                	push   $0x0
  pushl $189
80107564:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107569:	e9 80 f2 ff ff       	jmp    801067ee <alltraps>

8010756e <vector190>:
.globl vector190
vector190:
  pushl $0
8010756e:	6a 00                	push   $0x0
  pushl $190
80107570:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107575:	e9 74 f2 ff ff       	jmp    801067ee <alltraps>

8010757a <vector191>:
.globl vector191
vector191:
  pushl $0
8010757a:	6a 00                	push   $0x0
  pushl $191
8010757c:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107581:	e9 68 f2 ff ff       	jmp    801067ee <alltraps>

80107586 <vector192>:
.globl vector192
vector192:
  pushl $0
80107586:	6a 00                	push   $0x0
  pushl $192
80107588:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010758d:	e9 5c f2 ff ff       	jmp    801067ee <alltraps>

80107592 <vector193>:
.globl vector193
vector193:
  pushl $0
80107592:	6a 00                	push   $0x0
  pushl $193
80107594:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107599:	e9 50 f2 ff ff       	jmp    801067ee <alltraps>

8010759e <vector194>:
.globl vector194
vector194:
  pushl $0
8010759e:	6a 00                	push   $0x0
  pushl $194
801075a0:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801075a5:	e9 44 f2 ff ff       	jmp    801067ee <alltraps>

801075aa <vector195>:
.globl vector195
vector195:
  pushl $0
801075aa:	6a 00                	push   $0x0
  pushl $195
801075ac:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801075b1:	e9 38 f2 ff ff       	jmp    801067ee <alltraps>

801075b6 <vector196>:
.globl vector196
vector196:
  pushl $0
801075b6:	6a 00                	push   $0x0
  pushl $196
801075b8:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801075bd:	e9 2c f2 ff ff       	jmp    801067ee <alltraps>

801075c2 <vector197>:
.globl vector197
vector197:
  pushl $0
801075c2:	6a 00                	push   $0x0
  pushl $197
801075c4:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801075c9:	e9 20 f2 ff ff       	jmp    801067ee <alltraps>

801075ce <vector198>:
.globl vector198
vector198:
  pushl $0
801075ce:	6a 00                	push   $0x0
  pushl $198
801075d0:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801075d5:	e9 14 f2 ff ff       	jmp    801067ee <alltraps>

801075da <vector199>:
.globl vector199
vector199:
  pushl $0
801075da:	6a 00                	push   $0x0
  pushl $199
801075dc:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801075e1:	e9 08 f2 ff ff       	jmp    801067ee <alltraps>

801075e6 <vector200>:
.globl vector200
vector200:
  pushl $0
801075e6:	6a 00                	push   $0x0
  pushl $200
801075e8:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801075ed:	e9 fc f1 ff ff       	jmp    801067ee <alltraps>

801075f2 <vector201>:
.globl vector201
vector201:
  pushl $0
801075f2:	6a 00                	push   $0x0
  pushl $201
801075f4:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801075f9:	e9 f0 f1 ff ff       	jmp    801067ee <alltraps>

801075fe <vector202>:
.globl vector202
vector202:
  pushl $0
801075fe:	6a 00                	push   $0x0
  pushl $202
80107600:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107605:	e9 e4 f1 ff ff       	jmp    801067ee <alltraps>

8010760a <vector203>:
.globl vector203
vector203:
  pushl $0
8010760a:	6a 00                	push   $0x0
  pushl $203
8010760c:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107611:	e9 d8 f1 ff ff       	jmp    801067ee <alltraps>

80107616 <vector204>:
.globl vector204
vector204:
  pushl $0
80107616:	6a 00                	push   $0x0
  pushl $204
80107618:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
8010761d:	e9 cc f1 ff ff       	jmp    801067ee <alltraps>

80107622 <vector205>:
.globl vector205
vector205:
  pushl $0
80107622:	6a 00                	push   $0x0
  pushl $205
80107624:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107629:	e9 c0 f1 ff ff       	jmp    801067ee <alltraps>

8010762e <vector206>:
.globl vector206
vector206:
  pushl $0
8010762e:	6a 00                	push   $0x0
  pushl $206
80107630:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107635:	e9 b4 f1 ff ff       	jmp    801067ee <alltraps>

8010763a <vector207>:
.globl vector207
vector207:
  pushl $0
8010763a:	6a 00                	push   $0x0
  pushl $207
8010763c:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107641:	e9 a8 f1 ff ff       	jmp    801067ee <alltraps>

80107646 <vector208>:
.globl vector208
vector208:
  pushl $0
80107646:	6a 00                	push   $0x0
  pushl $208
80107648:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
8010764d:	e9 9c f1 ff ff       	jmp    801067ee <alltraps>

80107652 <vector209>:
.globl vector209
vector209:
  pushl $0
80107652:	6a 00                	push   $0x0
  pushl $209
80107654:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107659:	e9 90 f1 ff ff       	jmp    801067ee <alltraps>

8010765e <vector210>:
.globl vector210
vector210:
  pushl $0
8010765e:	6a 00                	push   $0x0
  pushl $210
80107660:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107665:	e9 84 f1 ff ff       	jmp    801067ee <alltraps>

8010766a <vector211>:
.globl vector211
vector211:
  pushl $0
8010766a:	6a 00                	push   $0x0
  pushl $211
8010766c:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107671:	e9 78 f1 ff ff       	jmp    801067ee <alltraps>

80107676 <vector212>:
.globl vector212
vector212:
  pushl $0
80107676:	6a 00                	push   $0x0
  pushl $212
80107678:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
8010767d:	e9 6c f1 ff ff       	jmp    801067ee <alltraps>

80107682 <vector213>:
.globl vector213
vector213:
  pushl $0
80107682:	6a 00                	push   $0x0
  pushl $213
80107684:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107689:	e9 60 f1 ff ff       	jmp    801067ee <alltraps>

8010768e <vector214>:
.globl vector214
vector214:
  pushl $0
8010768e:	6a 00                	push   $0x0
  pushl $214
80107690:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107695:	e9 54 f1 ff ff       	jmp    801067ee <alltraps>

8010769a <vector215>:
.globl vector215
vector215:
  pushl $0
8010769a:	6a 00                	push   $0x0
  pushl $215
8010769c:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801076a1:	e9 48 f1 ff ff       	jmp    801067ee <alltraps>

801076a6 <vector216>:
.globl vector216
vector216:
  pushl $0
801076a6:	6a 00                	push   $0x0
  pushl $216
801076a8:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801076ad:	e9 3c f1 ff ff       	jmp    801067ee <alltraps>

801076b2 <vector217>:
.globl vector217
vector217:
  pushl $0
801076b2:	6a 00                	push   $0x0
  pushl $217
801076b4:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801076b9:	e9 30 f1 ff ff       	jmp    801067ee <alltraps>

801076be <vector218>:
.globl vector218
vector218:
  pushl $0
801076be:	6a 00                	push   $0x0
  pushl $218
801076c0:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801076c5:	e9 24 f1 ff ff       	jmp    801067ee <alltraps>

801076ca <vector219>:
.globl vector219
vector219:
  pushl $0
801076ca:	6a 00                	push   $0x0
  pushl $219
801076cc:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801076d1:	e9 18 f1 ff ff       	jmp    801067ee <alltraps>

801076d6 <vector220>:
.globl vector220
vector220:
  pushl $0
801076d6:	6a 00                	push   $0x0
  pushl $220
801076d8:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801076dd:	e9 0c f1 ff ff       	jmp    801067ee <alltraps>

801076e2 <vector221>:
.globl vector221
vector221:
  pushl $0
801076e2:	6a 00                	push   $0x0
  pushl $221
801076e4:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801076e9:	e9 00 f1 ff ff       	jmp    801067ee <alltraps>

801076ee <vector222>:
.globl vector222
vector222:
  pushl $0
801076ee:	6a 00                	push   $0x0
  pushl $222
801076f0:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801076f5:	e9 f4 f0 ff ff       	jmp    801067ee <alltraps>

801076fa <vector223>:
.globl vector223
vector223:
  pushl $0
801076fa:	6a 00                	push   $0x0
  pushl $223
801076fc:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107701:	e9 e8 f0 ff ff       	jmp    801067ee <alltraps>

80107706 <vector224>:
.globl vector224
vector224:
  pushl $0
80107706:	6a 00                	push   $0x0
  pushl $224
80107708:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
8010770d:	e9 dc f0 ff ff       	jmp    801067ee <alltraps>

80107712 <vector225>:
.globl vector225
vector225:
  pushl $0
80107712:	6a 00                	push   $0x0
  pushl $225
80107714:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107719:	e9 d0 f0 ff ff       	jmp    801067ee <alltraps>

8010771e <vector226>:
.globl vector226
vector226:
  pushl $0
8010771e:	6a 00                	push   $0x0
  pushl $226
80107720:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107725:	e9 c4 f0 ff ff       	jmp    801067ee <alltraps>

8010772a <vector227>:
.globl vector227
vector227:
  pushl $0
8010772a:	6a 00                	push   $0x0
  pushl $227
8010772c:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107731:	e9 b8 f0 ff ff       	jmp    801067ee <alltraps>

80107736 <vector228>:
.globl vector228
vector228:
  pushl $0
80107736:	6a 00                	push   $0x0
  pushl $228
80107738:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
8010773d:	e9 ac f0 ff ff       	jmp    801067ee <alltraps>

80107742 <vector229>:
.globl vector229
vector229:
  pushl $0
80107742:	6a 00                	push   $0x0
  pushl $229
80107744:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107749:	e9 a0 f0 ff ff       	jmp    801067ee <alltraps>

8010774e <vector230>:
.globl vector230
vector230:
  pushl $0
8010774e:	6a 00                	push   $0x0
  pushl $230
80107750:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107755:	e9 94 f0 ff ff       	jmp    801067ee <alltraps>

8010775a <vector231>:
.globl vector231
vector231:
  pushl $0
8010775a:	6a 00                	push   $0x0
  pushl $231
8010775c:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107761:	e9 88 f0 ff ff       	jmp    801067ee <alltraps>

80107766 <vector232>:
.globl vector232
vector232:
  pushl $0
80107766:	6a 00                	push   $0x0
  pushl $232
80107768:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
8010776d:	e9 7c f0 ff ff       	jmp    801067ee <alltraps>

80107772 <vector233>:
.globl vector233
vector233:
  pushl $0
80107772:	6a 00                	push   $0x0
  pushl $233
80107774:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107779:	e9 70 f0 ff ff       	jmp    801067ee <alltraps>

8010777e <vector234>:
.globl vector234
vector234:
  pushl $0
8010777e:	6a 00                	push   $0x0
  pushl $234
80107780:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107785:	e9 64 f0 ff ff       	jmp    801067ee <alltraps>

8010778a <vector235>:
.globl vector235
vector235:
  pushl $0
8010778a:	6a 00                	push   $0x0
  pushl $235
8010778c:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107791:	e9 58 f0 ff ff       	jmp    801067ee <alltraps>

80107796 <vector236>:
.globl vector236
vector236:
  pushl $0
80107796:	6a 00                	push   $0x0
  pushl $236
80107798:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
8010779d:	e9 4c f0 ff ff       	jmp    801067ee <alltraps>

801077a2 <vector237>:
.globl vector237
vector237:
  pushl $0
801077a2:	6a 00                	push   $0x0
  pushl $237
801077a4:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801077a9:	e9 40 f0 ff ff       	jmp    801067ee <alltraps>

801077ae <vector238>:
.globl vector238
vector238:
  pushl $0
801077ae:	6a 00                	push   $0x0
  pushl $238
801077b0:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801077b5:	e9 34 f0 ff ff       	jmp    801067ee <alltraps>

801077ba <vector239>:
.globl vector239
vector239:
  pushl $0
801077ba:	6a 00                	push   $0x0
  pushl $239
801077bc:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801077c1:	e9 28 f0 ff ff       	jmp    801067ee <alltraps>

801077c6 <vector240>:
.globl vector240
vector240:
  pushl $0
801077c6:	6a 00                	push   $0x0
  pushl $240
801077c8:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801077cd:	e9 1c f0 ff ff       	jmp    801067ee <alltraps>

801077d2 <vector241>:
.globl vector241
vector241:
  pushl $0
801077d2:	6a 00                	push   $0x0
  pushl $241
801077d4:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801077d9:	e9 10 f0 ff ff       	jmp    801067ee <alltraps>

801077de <vector242>:
.globl vector242
vector242:
  pushl $0
801077de:	6a 00                	push   $0x0
  pushl $242
801077e0:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801077e5:	e9 04 f0 ff ff       	jmp    801067ee <alltraps>

801077ea <vector243>:
.globl vector243
vector243:
  pushl $0
801077ea:	6a 00                	push   $0x0
  pushl $243
801077ec:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801077f1:	e9 f8 ef ff ff       	jmp    801067ee <alltraps>

801077f6 <vector244>:
.globl vector244
vector244:
  pushl $0
801077f6:	6a 00                	push   $0x0
  pushl $244
801077f8:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801077fd:	e9 ec ef ff ff       	jmp    801067ee <alltraps>

80107802 <vector245>:
.globl vector245
vector245:
  pushl $0
80107802:	6a 00                	push   $0x0
  pushl $245
80107804:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107809:	e9 e0 ef ff ff       	jmp    801067ee <alltraps>

8010780e <vector246>:
.globl vector246
vector246:
  pushl $0
8010780e:	6a 00                	push   $0x0
  pushl $246
80107810:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107815:	e9 d4 ef ff ff       	jmp    801067ee <alltraps>

8010781a <vector247>:
.globl vector247
vector247:
  pushl $0
8010781a:	6a 00                	push   $0x0
  pushl $247
8010781c:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107821:	e9 c8 ef ff ff       	jmp    801067ee <alltraps>

80107826 <vector248>:
.globl vector248
vector248:
  pushl $0
80107826:	6a 00                	push   $0x0
  pushl $248
80107828:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010782d:	e9 bc ef ff ff       	jmp    801067ee <alltraps>

80107832 <vector249>:
.globl vector249
vector249:
  pushl $0
80107832:	6a 00                	push   $0x0
  pushl $249
80107834:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107839:	e9 b0 ef ff ff       	jmp    801067ee <alltraps>

8010783e <vector250>:
.globl vector250
vector250:
  pushl $0
8010783e:	6a 00                	push   $0x0
  pushl $250
80107840:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107845:	e9 a4 ef ff ff       	jmp    801067ee <alltraps>

8010784a <vector251>:
.globl vector251
vector251:
  pushl $0
8010784a:	6a 00                	push   $0x0
  pushl $251
8010784c:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107851:	e9 98 ef ff ff       	jmp    801067ee <alltraps>

80107856 <vector252>:
.globl vector252
vector252:
  pushl $0
80107856:	6a 00                	push   $0x0
  pushl $252
80107858:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
8010785d:	e9 8c ef ff ff       	jmp    801067ee <alltraps>

80107862 <vector253>:
.globl vector253
vector253:
  pushl $0
80107862:	6a 00                	push   $0x0
  pushl $253
80107864:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107869:	e9 80 ef ff ff       	jmp    801067ee <alltraps>

8010786e <vector254>:
.globl vector254
vector254:
  pushl $0
8010786e:	6a 00                	push   $0x0
  pushl $254
80107870:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107875:	e9 74 ef ff ff       	jmp    801067ee <alltraps>

8010787a <vector255>:
.globl vector255
vector255:
  pushl $0
8010787a:	6a 00                	push   $0x0
  pushl $255
8010787c:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107881:	e9 68 ef ff ff       	jmp    801067ee <alltraps>

80107886 <lgdt>:
{
80107886:	55                   	push   %ebp
80107887:	89 e5                	mov    %esp,%ebp
80107889:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
8010788c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010788f:	83 e8 01             	sub    $0x1,%eax
80107892:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107896:	8b 45 08             	mov    0x8(%ebp),%eax
80107899:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010789d:	8b 45 08             	mov    0x8(%ebp),%eax
801078a0:	c1 e8 10             	shr    $0x10,%eax
801078a3:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
801078a7:	8d 45 fa             	lea    -0x6(%ebp),%eax
801078aa:	0f 01 10             	lgdtl  (%eax)
}
801078ad:	90                   	nop
801078ae:	c9                   	leave  
801078af:	c3                   	ret    

801078b0 <ltr>:
{
801078b0:	55                   	push   %ebp
801078b1:	89 e5                	mov    %esp,%ebp
801078b3:	83 ec 04             	sub    $0x4,%esp
801078b6:	8b 45 08             	mov    0x8(%ebp),%eax
801078b9:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801078bd:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801078c1:	0f 00 d8             	ltr    %ax
}
801078c4:	90                   	nop
801078c5:	c9                   	leave  
801078c6:	c3                   	ret    

801078c7 <lcr3>:

static inline void
lcr3(uint val)
{
801078c7:	55                   	push   %ebp
801078c8:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801078ca:	8b 45 08             	mov    0x8(%ebp),%eax
801078cd:	0f 22 d8             	mov    %eax,%cr3
}
801078d0:	90                   	nop
801078d1:	5d                   	pop    %ebp
801078d2:	c3                   	ret    

801078d3 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801078d3:	55                   	push   %ebp
801078d4:	89 e5                	mov    %esp,%ebp
801078d6:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
801078d9:	e8 28 c9 ff ff       	call   80104206 <cpuid>
801078de:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801078e4:	05 c0 27 11 80       	add    $0x801127c0,%eax
801078e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801078ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078ef:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801078f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078f8:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801078fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107901:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107905:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107908:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010790c:	83 e2 f0             	and    $0xfffffff0,%edx
8010790f:	83 ca 0a             	or     $0xa,%edx
80107912:	88 50 7d             	mov    %dl,0x7d(%eax)
80107915:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107918:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010791c:	83 ca 10             	or     $0x10,%edx
8010791f:	88 50 7d             	mov    %dl,0x7d(%eax)
80107922:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107925:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107929:	83 e2 9f             	and    $0xffffff9f,%edx
8010792c:	88 50 7d             	mov    %dl,0x7d(%eax)
8010792f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107932:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107936:	83 ca 80             	or     $0xffffff80,%edx
80107939:	88 50 7d             	mov    %dl,0x7d(%eax)
8010793c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010793f:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107943:	83 ca 0f             	or     $0xf,%edx
80107946:	88 50 7e             	mov    %dl,0x7e(%eax)
80107949:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010794c:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107950:	83 e2 ef             	and    $0xffffffef,%edx
80107953:	88 50 7e             	mov    %dl,0x7e(%eax)
80107956:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107959:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010795d:	83 e2 df             	and    $0xffffffdf,%edx
80107960:	88 50 7e             	mov    %dl,0x7e(%eax)
80107963:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107966:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010796a:	83 ca 40             	or     $0x40,%edx
8010796d:	88 50 7e             	mov    %dl,0x7e(%eax)
80107970:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107973:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107977:	83 ca 80             	or     $0xffffff80,%edx
8010797a:	88 50 7e             	mov    %dl,0x7e(%eax)
8010797d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107980:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107984:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107987:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
8010798e:	ff ff 
80107990:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107993:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010799a:	00 00 
8010799c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010799f:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801079a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079a9:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801079b0:	83 e2 f0             	and    $0xfffffff0,%edx
801079b3:	83 ca 02             	or     $0x2,%edx
801079b6:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801079bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079bf:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801079c6:	83 ca 10             	or     $0x10,%edx
801079c9:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801079cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079d2:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801079d9:	83 e2 9f             	and    $0xffffff9f,%edx
801079dc:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801079e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079e5:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801079ec:	83 ca 80             	or     $0xffffff80,%edx
801079ef:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801079f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079f8:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801079ff:	83 ca 0f             	or     $0xf,%edx
80107a02:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a0b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107a12:	83 e2 ef             	and    $0xffffffef,%edx
80107a15:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a1e:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107a25:	83 e2 df             	and    $0xffffffdf,%edx
80107a28:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a31:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107a38:	83 ca 40             	or     $0x40,%edx
80107a3b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a44:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107a4b:	83 ca 80             	or     $0xffffff80,%edx
80107a4e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a57:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107a5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a61:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107a68:	ff ff 
80107a6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a6d:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107a74:	00 00 
80107a76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a79:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107a80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a83:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107a8a:	83 e2 f0             	and    $0xfffffff0,%edx
80107a8d:	83 ca 0a             	or     $0xa,%edx
80107a90:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107a96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a99:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107aa0:	83 ca 10             	or     $0x10,%edx
80107aa3:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107aa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aac:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107ab3:	83 ca 60             	or     $0x60,%edx
80107ab6:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107abc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107abf:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107ac6:	83 ca 80             	or     $0xffffff80,%edx
80107ac9:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107acf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ad2:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107ad9:	83 ca 0f             	or     $0xf,%edx
80107adc:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107ae2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae5:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107aec:	83 e2 ef             	and    $0xffffffef,%edx
80107aef:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107af5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107af8:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107aff:	83 e2 df             	and    $0xffffffdf,%edx
80107b02:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107b08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b0b:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107b12:	83 ca 40             	or     $0x40,%edx
80107b15:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107b1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b1e:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107b25:	83 ca 80             	or     $0xffffff80,%edx
80107b28:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107b2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b31:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107b38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b3b:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107b42:	ff ff 
80107b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b47:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107b4e:	00 00 
80107b50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b53:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b5d:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107b64:	83 e2 f0             	and    $0xfffffff0,%edx
80107b67:	83 ca 02             	or     $0x2,%edx
80107b6a:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107b70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b73:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107b7a:	83 ca 10             	or     $0x10,%edx
80107b7d:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107b83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b86:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107b8d:	83 ca 60             	or     $0x60,%edx
80107b90:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107b96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b99:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107ba0:	83 ca 80             	or     $0xffffff80,%edx
80107ba3:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ba9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bac:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107bb3:	83 ca 0f             	or     $0xf,%edx
80107bb6:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107bbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bbf:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107bc6:	83 e2 ef             	and    $0xffffffef,%edx
80107bc9:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107bcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bd2:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107bd9:	83 e2 df             	and    $0xffffffdf,%edx
80107bdc:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107be2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be5:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107bec:	83 ca 40             	or     $0x40,%edx
80107bef:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107bf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bf8:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107bff:	83 ca 80             	or     $0xffffff80,%edx
80107c02:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c0b:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107c12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c15:	83 c0 70             	add    $0x70,%eax
80107c18:	83 ec 08             	sub    $0x8,%esp
80107c1b:	6a 30                	push   $0x30
80107c1d:	50                   	push   %eax
80107c1e:	e8 63 fc ff ff       	call   80107886 <lgdt>
80107c23:	83 c4 10             	add    $0x10,%esp
}
80107c26:	90                   	nop
80107c27:	c9                   	leave  
80107c28:	c3                   	ret    

80107c29 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107c29:	55                   	push   %ebp
80107c2a:	89 e5                	mov    %esp,%ebp
80107c2c:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107c2f:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c32:	c1 e8 16             	shr    $0x16,%eax
80107c35:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107c3c:	8b 45 08             	mov    0x8(%ebp),%eax
80107c3f:	01 d0                	add    %edx,%eax
80107c41:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107c44:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c47:	8b 00                	mov    (%eax),%eax
80107c49:	83 e0 01             	and    $0x1,%eax
80107c4c:	85 c0                	test   %eax,%eax
80107c4e:	74 14                	je     80107c64 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107c50:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c53:	8b 00                	mov    (%eax),%eax
80107c55:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c5a:	05 00 00 00 80       	add    $0x80000000,%eax
80107c5f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107c62:	eb 42                	jmp    80107ca6 <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107c64:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107c68:	74 0e                	je     80107c78 <walkpgdir+0x4f>
80107c6a:	e8 27 b0 ff ff       	call   80102c96 <kalloc>
80107c6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107c72:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107c76:	75 07                	jne    80107c7f <walkpgdir+0x56>
      return 0;
80107c78:	b8 00 00 00 00       	mov    $0x0,%eax
80107c7d:	eb 3e                	jmp    80107cbd <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107c7f:	83 ec 04             	sub    $0x4,%esp
80107c82:	68 00 10 00 00       	push   $0x1000
80107c87:	6a 00                	push   $0x0
80107c89:	ff 75 f4             	push   -0xc(%ebp)
80107c8c:	e8 54 d7 ff ff       	call   801053e5 <memset>
80107c91:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107c94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c97:	05 00 00 00 80       	add    $0x80000000,%eax
80107c9c:	83 c8 07             	or     $0x7,%eax
80107c9f:	89 c2                	mov    %eax,%edx
80107ca1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ca4:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107ca6:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ca9:	c1 e8 0c             	shr    $0xc,%eax
80107cac:	25 ff 03 00 00       	and    $0x3ff,%eax
80107cb1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107cb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cbb:	01 d0                	add    %edx,%eax
}
80107cbd:	c9                   	leave  
80107cbe:	c3                   	ret    

80107cbf <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107cbf:	55                   	push   %ebp
80107cc0:	89 e5                	mov    %esp,%ebp
80107cc2:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107cc5:	8b 45 0c             	mov    0xc(%ebp),%eax
80107cc8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ccd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107cd0:	8b 55 0c             	mov    0xc(%ebp),%edx
80107cd3:	8b 45 10             	mov    0x10(%ebp),%eax
80107cd6:	01 d0                	add    %edx,%eax
80107cd8:	83 e8 01             	sub    $0x1,%eax
80107cdb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ce0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107ce3:	83 ec 04             	sub    $0x4,%esp
80107ce6:	6a 01                	push   $0x1
80107ce8:	ff 75 f4             	push   -0xc(%ebp)
80107ceb:	ff 75 08             	push   0x8(%ebp)
80107cee:	e8 36 ff ff ff       	call   80107c29 <walkpgdir>
80107cf3:	83 c4 10             	add    $0x10,%esp
80107cf6:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107cf9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107cfd:	75 07                	jne    80107d06 <mappages+0x47>
      return -1;
80107cff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d04:	eb 47                	jmp    80107d4d <mappages+0x8e>
    if(*pte & PTE_P)
80107d06:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d09:	8b 00                	mov    (%eax),%eax
80107d0b:	83 e0 01             	and    $0x1,%eax
80107d0e:	85 c0                	test   %eax,%eax
80107d10:	74 0d                	je     80107d1f <mappages+0x60>
      panic("remap");
80107d12:	83 ec 0c             	sub    $0xc,%esp
80107d15:	68 b4 8b 10 80       	push   $0x80108bb4
80107d1a:	e8 96 88 ff ff       	call   801005b5 <panic>
    *pte = pa | perm | PTE_P;
80107d1f:	8b 45 18             	mov    0x18(%ebp),%eax
80107d22:	0b 45 14             	or     0x14(%ebp),%eax
80107d25:	83 c8 01             	or     $0x1,%eax
80107d28:	89 c2                	mov    %eax,%edx
80107d2a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d2d:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107d2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d32:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107d35:	74 10                	je     80107d47 <mappages+0x88>
      break;
    a += PGSIZE;
80107d37:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107d3e:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107d45:	eb 9c                	jmp    80107ce3 <mappages+0x24>
      break;
80107d47:	90                   	nop
  }
  return 0;
80107d48:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107d4d:	c9                   	leave  
80107d4e:	c3                   	ret    

80107d4f <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107d4f:	55                   	push   %ebp
80107d50:	89 e5                	mov    %esp,%ebp
80107d52:	53                   	push   %ebx
80107d53:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107d56:	e8 3b af ff ff       	call   80102c96 <kalloc>
80107d5b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107d5e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107d62:	75 07                	jne    80107d6b <setupkvm+0x1c>
    return 0;
80107d64:	b8 00 00 00 00       	mov    $0x0,%eax
80107d69:	eb 78                	jmp    80107de3 <setupkvm+0x94>
  memset(pgdir, 0, PGSIZE);
80107d6b:	83 ec 04             	sub    $0x4,%esp
80107d6e:	68 00 10 00 00       	push   $0x1000
80107d73:	6a 00                	push   $0x0
80107d75:	ff 75 f0             	push   -0x10(%ebp)
80107d78:	e8 68 d6 ff ff       	call   801053e5 <memset>
80107d7d:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107d80:	c7 45 f4 80 b4 10 80 	movl   $0x8010b480,-0xc(%ebp)
80107d87:	eb 4e                	jmp    80107dd7 <setupkvm+0x88>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107d89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d8c:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80107d8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d92:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107d95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d98:	8b 58 08             	mov    0x8(%eax),%ebx
80107d9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d9e:	8b 40 04             	mov    0x4(%eax),%eax
80107da1:	29 c3                	sub    %eax,%ebx
80107da3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da6:	8b 00                	mov    (%eax),%eax
80107da8:	83 ec 0c             	sub    $0xc,%esp
80107dab:	51                   	push   %ecx
80107dac:	52                   	push   %edx
80107dad:	53                   	push   %ebx
80107dae:	50                   	push   %eax
80107daf:	ff 75 f0             	push   -0x10(%ebp)
80107db2:	e8 08 ff ff ff       	call   80107cbf <mappages>
80107db7:	83 c4 20             	add    $0x20,%esp
80107dba:	85 c0                	test   %eax,%eax
80107dbc:	79 15                	jns    80107dd3 <setupkvm+0x84>
      freevm(pgdir);
80107dbe:	83 ec 0c             	sub    $0xc,%esp
80107dc1:	ff 75 f0             	push   -0x10(%ebp)
80107dc4:	e8 f5 04 00 00       	call   801082be <freevm>
80107dc9:	83 c4 10             	add    $0x10,%esp
      return 0;
80107dcc:	b8 00 00 00 00       	mov    $0x0,%eax
80107dd1:	eb 10                	jmp    80107de3 <setupkvm+0x94>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107dd3:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107dd7:	81 7d f4 c0 b4 10 80 	cmpl   $0x8010b4c0,-0xc(%ebp)
80107dde:	72 a9                	jb     80107d89 <setupkvm+0x3a>
    }
  return pgdir;
80107de0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107de3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107de6:	c9                   	leave  
80107de7:	c3                   	ret    

80107de8 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107de8:	55                   	push   %ebp
80107de9:	89 e5                	mov    %esp,%ebp
80107deb:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107dee:	e8 5c ff ff ff       	call   80107d4f <setupkvm>
80107df3:	a3 dc 59 11 80       	mov    %eax,0x801159dc
  switchkvm();
80107df8:	e8 03 00 00 00       	call   80107e00 <switchkvm>
}
80107dfd:	90                   	nop
80107dfe:	c9                   	leave  
80107dff:	c3                   	ret    

80107e00 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107e00:	55                   	push   %ebp
80107e01:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107e03:	a1 dc 59 11 80       	mov    0x801159dc,%eax
80107e08:	05 00 00 00 80       	add    $0x80000000,%eax
80107e0d:	50                   	push   %eax
80107e0e:	e8 b4 fa ff ff       	call   801078c7 <lcr3>
80107e13:	83 c4 04             	add    $0x4,%esp
}
80107e16:	90                   	nop
80107e17:	c9                   	leave  
80107e18:	c3                   	ret    

80107e19 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107e19:	55                   	push   %ebp
80107e1a:	89 e5                	mov    %esp,%ebp
80107e1c:	56                   	push   %esi
80107e1d:	53                   	push   %ebx
80107e1e:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107e21:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107e25:	75 0d                	jne    80107e34 <switchuvm+0x1b>
    panic("switchuvm: no process");
80107e27:	83 ec 0c             	sub    $0xc,%esp
80107e2a:	68 ba 8b 10 80       	push   $0x80108bba
80107e2f:	e8 81 87 ff ff       	call   801005b5 <panic>
  if(p->kstack == 0)
80107e34:	8b 45 08             	mov    0x8(%ebp),%eax
80107e37:	8b 40 08             	mov    0x8(%eax),%eax
80107e3a:	85 c0                	test   %eax,%eax
80107e3c:	75 0d                	jne    80107e4b <switchuvm+0x32>
    panic("switchuvm: no kstack");
80107e3e:	83 ec 0c             	sub    $0xc,%esp
80107e41:	68 d0 8b 10 80       	push   $0x80108bd0
80107e46:	e8 6a 87 ff ff       	call   801005b5 <panic>
  if(p->pgdir == 0)
80107e4b:	8b 45 08             	mov    0x8(%ebp),%eax
80107e4e:	8b 40 04             	mov    0x4(%eax),%eax
80107e51:	85 c0                	test   %eax,%eax
80107e53:	75 0d                	jne    80107e62 <switchuvm+0x49>
    panic("switchuvm: no pgdir");
80107e55:	83 ec 0c             	sub    $0xc,%esp
80107e58:	68 e5 8b 10 80       	push   $0x80108be5
80107e5d:	e8 53 87 ff ff       	call   801005b5 <panic>

  pushcli();
80107e62:	e8 73 d4 ff ff       	call   801052da <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107e67:	e8 b5 c3 ff ff       	call   80104221 <mycpu>
80107e6c:	89 c3                	mov    %eax,%ebx
80107e6e:	e8 ae c3 ff ff       	call   80104221 <mycpu>
80107e73:	83 c0 08             	add    $0x8,%eax
80107e76:	89 c6                	mov    %eax,%esi
80107e78:	e8 a4 c3 ff ff       	call   80104221 <mycpu>
80107e7d:	83 c0 08             	add    $0x8,%eax
80107e80:	c1 e8 10             	shr    $0x10,%eax
80107e83:	88 45 f7             	mov    %al,-0x9(%ebp)
80107e86:	e8 96 c3 ff ff       	call   80104221 <mycpu>
80107e8b:	83 c0 08             	add    $0x8,%eax
80107e8e:	c1 e8 18             	shr    $0x18,%eax
80107e91:	89 c2                	mov    %eax,%edx
80107e93:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107e9a:	67 00 
80107e9c:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107ea3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107ea7:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107ead:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107eb4:	83 e0 f0             	and    $0xfffffff0,%eax
80107eb7:	83 c8 09             	or     $0x9,%eax
80107eba:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107ec0:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107ec7:	83 c8 10             	or     $0x10,%eax
80107eca:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107ed0:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107ed7:	83 e0 9f             	and    $0xffffff9f,%eax
80107eda:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107ee0:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107ee7:	83 c8 80             	or     $0xffffff80,%eax
80107eea:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107ef0:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107ef7:	83 e0 f0             	and    $0xfffffff0,%eax
80107efa:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107f00:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107f07:	83 e0 ef             	and    $0xffffffef,%eax
80107f0a:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107f10:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107f17:	83 e0 df             	and    $0xffffffdf,%eax
80107f1a:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107f20:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107f27:	83 c8 40             	or     $0x40,%eax
80107f2a:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107f30:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107f37:	83 e0 7f             	and    $0x7f,%eax
80107f3a:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107f40:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107f46:	e8 d6 c2 ff ff       	call   80104221 <mycpu>
80107f4b:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107f52:	83 e2 ef             	and    $0xffffffef,%edx
80107f55:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107f5b:	e8 c1 c2 ff ff       	call   80104221 <mycpu>
80107f60:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107f66:	8b 45 08             	mov    0x8(%ebp),%eax
80107f69:	8b 40 08             	mov    0x8(%eax),%eax
80107f6c:	89 c3                	mov    %eax,%ebx
80107f6e:	e8 ae c2 ff ff       	call   80104221 <mycpu>
80107f73:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107f79:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107f7c:	e8 a0 c2 ff ff       	call   80104221 <mycpu>
80107f81:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107f87:	83 ec 0c             	sub    $0xc,%esp
80107f8a:	6a 28                	push   $0x28
80107f8c:	e8 1f f9 ff ff       	call   801078b0 <ltr>
80107f91:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107f94:	8b 45 08             	mov    0x8(%ebp),%eax
80107f97:	8b 40 04             	mov    0x4(%eax),%eax
80107f9a:	05 00 00 00 80       	add    $0x80000000,%eax
80107f9f:	83 ec 0c             	sub    $0xc,%esp
80107fa2:	50                   	push   %eax
80107fa3:	e8 1f f9 ff ff       	call   801078c7 <lcr3>
80107fa8:	83 c4 10             	add    $0x10,%esp
  popcli();
80107fab:	e8 77 d3 ff ff       	call   80105327 <popcli>
}
80107fb0:	90                   	nop
80107fb1:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107fb4:	5b                   	pop    %ebx
80107fb5:	5e                   	pop    %esi
80107fb6:	5d                   	pop    %ebp
80107fb7:	c3                   	ret    

80107fb8 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107fb8:	55                   	push   %ebp
80107fb9:	89 e5                	mov    %esp,%ebp
80107fbb:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80107fbe:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107fc5:	76 0d                	jbe    80107fd4 <inituvm+0x1c>
    panic("inituvm: more than a page");
80107fc7:	83 ec 0c             	sub    $0xc,%esp
80107fca:	68 f9 8b 10 80       	push   $0x80108bf9
80107fcf:	e8 e1 85 ff ff       	call   801005b5 <panic>
  mem = kalloc();
80107fd4:	e8 bd ac ff ff       	call   80102c96 <kalloc>
80107fd9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107fdc:	83 ec 04             	sub    $0x4,%esp
80107fdf:	68 00 10 00 00       	push   $0x1000
80107fe4:	6a 00                	push   $0x0
80107fe6:	ff 75 f4             	push   -0xc(%ebp)
80107fe9:	e8 f7 d3 ff ff       	call   801053e5 <memset>
80107fee:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107ff1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ff4:	05 00 00 00 80       	add    $0x80000000,%eax
80107ff9:	83 ec 0c             	sub    $0xc,%esp
80107ffc:	6a 06                	push   $0x6
80107ffe:	50                   	push   %eax
80107fff:	68 00 10 00 00       	push   $0x1000
80108004:	6a 00                	push   $0x0
80108006:	ff 75 08             	push   0x8(%ebp)
80108009:	e8 b1 fc ff ff       	call   80107cbf <mappages>
8010800e:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80108011:	83 ec 04             	sub    $0x4,%esp
80108014:	ff 75 10             	push   0x10(%ebp)
80108017:	ff 75 0c             	push   0xc(%ebp)
8010801a:	ff 75 f4             	push   -0xc(%ebp)
8010801d:	e8 82 d4 ff ff       	call   801054a4 <memmove>
80108022:	83 c4 10             	add    $0x10,%esp
}
80108025:	90                   	nop
80108026:	c9                   	leave  
80108027:	c3                   	ret    

80108028 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108028:	55                   	push   %ebp
80108029:	89 e5                	mov    %esp,%ebp
8010802b:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
8010802e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108031:	25 ff 0f 00 00       	and    $0xfff,%eax
80108036:	85 c0                	test   %eax,%eax
80108038:	74 0d                	je     80108047 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
8010803a:	83 ec 0c             	sub    $0xc,%esp
8010803d:	68 14 8c 10 80       	push   $0x80108c14
80108042:	e8 6e 85 ff ff       	call   801005b5 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108047:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010804e:	e9 8f 00 00 00       	jmp    801080e2 <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108053:	8b 55 0c             	mov    0xc(%ebp),%edx
80108056:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108059:	01 d0                	add    %edx,%eax
8010805b:	83 ec 04             	sub    $0x4,%esp
8010805e:	6a 00                	push   $0x0
80108060:	50                   	push   %eax
80108061:	ff 75 08             	push   0x8(%ebp)
80108064:	e8 c0 fb ff ff       	call   80107c29 <walkpgdir>
80108069:	83 c4 10             	add    $0x10,%esp
8010806c:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010806f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108073:	75 0d                	jne    80108082 <loaduvm+0x5a>
      panic("loaduvm: address should exist");
80108075:	83 ec 0c             	sub    $0xc,%esp
80108078:	68 37 8c 10 80       	push   $0x80108c37
8010807d:	e8 33 85 ff ff       	call   801005b5 <panic>
    pa = PTE_ADDR(*pte);
80108082:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108085:	8b 00                	mov    (%eax),%eax
80108087:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010808c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
8010808f:	8b 45 18             	mov    0x18(%ebp),%eax
80108092:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108095:	3d ff 0f 00 00       	cmp    $0xfff,%eax
8010809a:	77 0b                	ja     801080a7 <loaduvm+0x7f>
      n = sz - i;
8010809c:	8b 45 18             	mov    0x18(%ebp),%eax
8010809f:	2b 45 f4             	sub    -0xc(%ebp),%eax
801080a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
801080a5:	eb 07                	jmp    801080ae <loaduvm+0x86>
    else
      n = PGSIZE;
801080a7:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
801080ae:	8b 55 14             	mov    0x14(%ebp),%edx
801080b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080b4:	01 d0                	add    %edx,%eax
801080b6:	8b 55 e8             	mov    -0x18(%ebp),%edx
801080b9:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801080bf:	ff 75 f0             	push   -0x10(%ebp)
801080c2:	50                   	push   %eax
801080c3:	52                   	push   %edx
801080c4:	ff 75 10             	push   0x10(%ebp)
801080c7:	e8 3a 9e ff ff       	call   80101f06 <readi>
801080cc:	83 c4 10             	add    $0x10,%esp
801080cf:	39 45 f0             	cmp    %eax,-0x10(%ebp)
801080d2:	74 07                	je     801080db <loaduvm+0xb3>
      return -1;
801080d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801080d9:	eb 18                	jmp    801080f3 <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
801080db:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801080e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080e5:	3b 45 18             	cmp    0x18(%ebp),%eax
801080e8:	0f 82 65 ff ff ff    	jb     80108053 <loaduvm+0x2b>
  }
  return 0;
801080ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
801080f3:	c9                   	leave  
801080f4:	c3                   	ret    

801080f5 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801080f5:	55                   	push   %ebp
801080f6:	89 e5                	mov    %esp,%ebp
801080f8:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
801080fb:	8b 45 10             	mov    0x10(%ebp),%eax
801080fe:	85 c0                	test   %eax,%eax
80108100:	79 0a                	jns    8010810c <allocuvm+0x17>
    return 0;
80108102:	b8 00 00 00 00       	mov    $0x0,%eax
80108107:	e9 ec 00 00 00       	jmp    801081f8 <allocuvm+0x103>
  if(newsz < oldsz)
8010810c:	8b 45 10             	mov    0x10(%ebp),%eax
8010810f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108112:	73 08                	jae    8010811c <allocuvm+0x27>
    return oldsz;
80108114:	8b 45 0c             	mov    0xc(%ebp),%eax
80108117:	e9 dc 00 00 00       	jmp    801081f8 <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
8010811c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010811f:	05 ff 0f 00 00       	add    $0xfff,%eax
80108124:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108129:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
8010812c:	e9 b8 00 00 00       	jmp    801081e9 <allocuvm+0xf4>
    mem = kalloc();
80108131:	e8 60 ab ff ff       	call   80102c96 <kalloc>
80108136:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108139:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010813d:	75 2e                	jne    8010816d <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
8010813f:	83 ec 0c             	sub    $0xc,%esp
80108142:	68 55 8c 10 80       	push   $0x80108c55
80108147:	e8 b4 82 ff ff       	call   80100400 <cprintf>
8010814c:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
8010814f:	83 ec 04             	sub    $0x4,%esp
80108152:	ff 75 0c             	push   0xc(%ebp)
80108155:	ff 75 10             	push   0x10(%ebp)
80108158:	ff 75 08             	push   0x8(%ebp)
8010815b:	e8 9a 00 00 00       	call   801081fa <deallocuvm>
80108160:	83 c4 10             	add    $0x10,%esp
      return 0;
80108163:	b8 00 00 00 00       	mov    $0x0,%eax
80108168:	e9 8b 00 00 00       	jmp    801081f8 <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
8010816d:	83 ec 04             	sub    $0x4,%esp
80108170:	68 00 10 00 00       	push   $0x1000
80108175:	6a 00                	push   $0x0
80108177:	ff 75 f0             	push   -0x10(%ebp)
8010817a:	e8 66 d2 ff ff       	call   801053e5 <memset>
8010817f:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80108182:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108185:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
8010818b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010818e:	83 ec 0c             	sub    $0xc,%esp
80108191:	6a 06                	push   $0x6
80108193:	52                   	push   %edx
80108194:	68 00 10 00 00       	push   $0x1000
80108199:	50                   	push   %eax
8010819a:	ff 75 08             	push   0x8(%ebp)
8010819d:	e8 1d fb ff ff       	call   80107cbf <mappages>
801081a2:	83 c4 20             	add    $0x20,%esp
801081a5:	85 c0                	test   %eax,%eax
801081a7:	79 39                	jns    801081e2 <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
801081a9:	83 ec 0c             	sub    $0xc,%esp
801081ac:	68 6d 8c 10 80       	push   $0x80108c6d
801081b1:	e8 4a 82 ff ff       	call   80100400 <cprintf>
801081b6:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801081b9:	83 ec 04             	sub    $0x4,%esp
801081bc:	ff 75 0c             	push   0xc(%ebp)
801081bf:	ff 75 10             	push   0x10(%ebp)
801081c2:	ff 75 08             	push   0x8(%ebp)
801081c5:	e8 30 00 00 00       	call   801081fa <deallocuvm>
801081ca:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
801081cd:	83 ec 0c             	sub    $0xc,%esp
801081d0:	ff 75 f0             	push   -0x10(%ebp)
801081d3:	e8 24 aa ff ff       	call   80102bfc <kfree>
801081d8:	83 c4 10             	add    $0x10,%esp
      return 0;
801081db:	b8 00 00 00 00       	mov    $0x0,%eax
801081e0:	eb 16                	jmp    801081f8 <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
801081e2:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801081e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081ec:	3b 45 10             	cmp    0x10(%ebp),%eax
801081ef:	0f 82 3c ff ff ff    	jb     80108131 <allocuvm+0x3c>
    }
  }
  return newsz;
801081f5:	8b 45 10             	mov    0x10(%ebp),%eax
}
801081f8:	c9                   	leave  
801081f9:	c3                   	ret    

801081fa <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801081fa:	55                   	push   %ebp
801081fb:	89 e5                	mov    %esp,%ebp
801081fd:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108200:	8b 45 10             	mov    0x10(%ebp),%eax
80108203:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108206:	72 08                	jb     80108210 <deallocuvm+0x16>
    return oldsz;
80108208:	8b 45 0c             	mov    0xc(%ebp),%eax
8010820b:	e9 ac 00 00 00       	jmp    801082bc <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80108210:	8b 45 10             	mov    0x10(%ebp),%eax
80108213:	05 ff 0f 00 00       	add    $0xfff,%eax
80108218:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010821d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108220:	e9 88 00 00 00       	jmp    801082ad <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108225:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108228:	83 ec 04             	sub    $0x4,%esp
8010822b:	6a 00                	push   $0x0
8010822d:	50                   	push   %eax
8010822e:	ff 75 08             	push   0x8(%ebp)
80108231:	e8 f3 f9 ff ff       	call   80107c29 <walkpgdir>
80108236:	83 c4 10             	add    $0x10,%esp
80108239:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
8010823c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108240:	75 16                	jne    80108258 <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80108242:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108245:	c1 e8 16             	shr    $0x16,%eax
80108248:	83 c0 01             	add    $0x1,%eax
8010824b:	c1 e0 16             	shl    $0x16,%eax
8010824e:	2d 00 10 00 00       	sub    $0x1000,%eax
80108253:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108256:	eb 4e                	jmp    801082a6 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
80108258:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010825b:	8b 00                	mov    (%eax),%eax
8010825d:	83 e0 01             	and    $0x1,%eax
80108260:	85 c0                	test   %eax,%eax
80108262:	74 42                	je     801082a6 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80108264:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108267:	8b 00                	mov    (%eax),%eax
80108269:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010826e:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108271:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108275:	75 0d                	jne    80108284 <deallocuvm+0x8a>
        panic("kfree");
80108277:	83 ec 0c             	sub    $0xc,%esp
8010827a:	68 89 8c 10 80       	push   $0x80108c89
8010827f:	e8 31 83 ff ff       	call   801005b5 <panic>
      char *v = P2V(pa);
80108284:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108287:	05 00 00 00 80       	add    $0x80000000,%eax
8010828c:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
8010828f:	83 ec 0c             	sub    $0xc,%esp
80108292:	ff 75 e8             	push   -0x18(%ebp)
80108295:	e8 62 a9 ff ff       	call   80102bfc <kfree>
8010829a:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
8010829d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082a0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
801082a6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801082ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082b0:	3b 45 0c             	cmp    0xc(%ebp),%eax
801082b3:	0f 82 6c ff ff ff    	jb     80108225 <deallocuvm+0x2b>
    }
  }
  return newsz;
801082b9:	8b 45 10             	mov    0x10(%ebp),%eax
}
801082bc:	c9                   	leave  
801082bd:	c3                   	ret    

801082be <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801082be:	55                   	push   %ebp
801082bf:	89 e5                	mov    %esp,%ebp
801082c1:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
801082c4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801082c8:	75 0d                	jne    801082d7 <freevm+0x19>
    panic("freevm: no pgdir");
801082ca:	83 ec 0c             	sub    $0xc,%esp
801082cd:	68 8f 8c 10 80       	push   $0x80108c8f
801082d2:	e8 de 82 ff ff       	call   801005b5 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801082d7:	83 ec 04             	sub    $0x4,%esp
801082da:	6a 00                	push   $0x0
801082dc:	68 00 00 00 80       	push   $0x80000000
801082e1:	ff 75 08             	push   0x8(%ebp)
801082e4:	e8 11 ff ff ff       	call   801081fa <deallocuvm>
801082e9:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801082ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801082f3:	eb 48                	jmp    8010833d <freevm+0x7f>
    if(pgdir[i] & PTE_P){
801082f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082f8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801082ff:	8b 45 08             	mov    0x8(%ebp),%eax
80108302:	01 d0                	add    %edx,%eax
80108304:	8b 00                	mov    (%eax),%eax
80108306:	83 e0 01             	and    $0x1,%eax
80108309:	85 c0                	test   %eax,%eax
8010830b:	74 2c                	je     80108339 <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
8010830d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108310:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108317:	8b 45 08             	mov    0x8(%ebp),%eax
8010831a:	01 d0                	add    %edx,%eax
8010831c:	8b 00                	mov    (%eax),%eax
8010831e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108323:	05 00 00 00 80       	add    $0x80000000,%eax
80108328:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
8010832b:	83 ec 0c             	sub    $0xc,%esp
8010832e:	ff 75 f0             	push   -0x10(%ebp)
80108331:	e8 c6 a8 ff ff       	call   80102bfc <kfree>
80108336:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108339:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010833d:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108344:	76 af                	jbe    801082f5 <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
80108346:	83 ec 0c             	sub    $0xc,%esp
80108349:	ff 75 08             	push   0x8(%ebp)
8010834c:	e8 ab a8 ff ff       	call   80102bfc <kfree>
80108351:	83 c4 10             	add    $0x10,%esp
}
80108354:	90                   	nop
80108355:	c9                   	leave  
80108356:	c3                   	ret    

80108357 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108357:	55                   	push   %ebp
80108358:	89 e5                	mov    %esp,%ebp
8010835a:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010835d:	83 ec 04             	sub    $0x4,%esp
80108360:	6a 00                	push   $0x0
80108362:	ff 75 0c             	push   0xc(%ebp)
80108365:	ff 75 08             	push   0x8(%ebp)
80108368:	e8 bc f8 ff ff       	call   80107c29 <walkpgdir>
8010836d:	83 c4 10             	add    $0x10,%esp
80108370:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108373:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108377:	75 0d                	jne    80108386 <clearpteu+0x2f>
    panic("clearpteu");
80108379:	83 ec 0c             	sub    $0xc,%esp
8010837c:	68 a0 8c 10 80       	push   $0x80108ca0
80108381:	e8 2f 82 ff ff       	call   801005b5 <panic>
  *pte &= ~PTE_U;
80108386:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108389:	8b 00                	mov    (%eax),%eax
8010838b:	83 e0 fb             	and    $0xfffffffb,%eax
8010838e:	89 c2                	mov    %eax,%edx
80108390:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108393:	89 10                	mov    %edx,(%eax)
}
80108395:	90                   	nop
80108396:	c9                   	leave  
80108397:	c3                   	ret    

80108398 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108398:	55                   	push   %ebp
80108399:	89 e5                	mov    %esp,%ebp
8010839b:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
8010839e:	e8 ac f9 ff ff       	call   80107d4f <setupkvm>
801083a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
801083a6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801083aa:	75 0a                	jne    801083b6 <copyuvm+0x1e>
    return 0;
801083ac:	b8 00 00 00 00       	mov    $0x0,%eax
801083b1:	e9 f8 00 00 00       	jmp    801084ae <copyuvm+0x116>
  for(i = 0; i < sz; i += PGSIZE){
801083b6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801083bd:	e9 c7 00 00 00       	jmp    80108489 <copyuvm+0xf1>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801083c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083c5:	83 ec 04             	sub    $0x4,%esp
801083c8:	6a 00                	push   $0x0
801083ca:	50                   	push   %eax
801083cb:	ff 75 08             	push   0x8(%ebp)
801083ce:	e8 56 f8 ff ff       	call   80107c29 <walkpgdir>
801083d3:	83 c4 10             	add    $0x10,%esp
801083d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
801083d9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801083dd:	75 0d                	jne    801083ec <copyuvm+0x54>
      panic("copyuvm: pte should exist");
801083df:	83 ec 0c             	sub    $0xc,%esp
801083e2:	68 aa 8c 10 80       	push   $0x80108caa
801083e7:	e8 c9 81 ff ff       	call   801005b5 <panic>
    if(!(*pte & PTE_P))
801083ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083ef:	8b 00                	mov    (%eax),%eax
801083f1:	83 e0 01             	and    $0x1,%eax
801083f4:	85 c0                	test   %eax,%eax
801083f6:	75 0d                	jne    80108405 <copyuvm+0x6d>
      panic("copyuvm: page not present");
801083f8:	83 ec 0c             	sub    $0xc,%esp
801083fb:	68 c4 8c 10 80       	push   $0x80108cc4
80108400:	e8 b0 81 ff ff       	call   801005b5 <panic>
    pa = PTE_ADDR(*pte);
80108405:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108408:	8b 00                	mov    (%eax),%eax
8010840a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010840f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108412:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108415:	8b 00                	mov    (%eax),%eax
80108417:	25 ff 0f 00 00       	and    $0xfff,%eax
8010841c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
8010841f:	e8 72 a8 ff ff       	call   80102c96 <kalloc>
80108424:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108427:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010842b:	74 6d                	je     8010849a <copyuvm+0x102>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
8010842d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108430:	05 00 00 00 80       	add    $0x80000000,%eax
80108435:	83 ec 04             	sub    $0x4,%esp
80108438:	68 00 10 00 00       	push   $0x1000
8010843d:	50                   	push   %eax
8010843e:	ff 75 e0             	push   -0x20(%ebp)
80108441:	e8 5e d0 ff ff       	call   801054a4 <memmove>
80108446:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
80108449:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010844c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010844f:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80108455:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108458:	83 ec 0c             	sub    $0xc,%esp
8010845b:	52                   	push   %edx
8010845c:	51                   	push   %ecx
8010845d:	68 00 10 00 00       	push   $0x1000
80108462:	50                   	push   %eax
80108463:	ff 75 f0             	push   -0x10(%ebp)
80108466:	e8 54 f8 ff ff       	call   80107cbf <mappages>
8010846b:	83 c4 20             	add    $0x20,%esp
8010846e:	85 c0                	test   %eax,%eax
80108470:	79 10                	jns    80108482 <copyuvm+0xea>
      kfree(mem);
80108472:	83 ec 0c             	sub    $0xc,%esp
80108475:	ff 75 e0             	push   -0x20(%ebp)
80108478:	e8 7f a7 ff ff       	call   80102bfc <kfree>
8010847d:	83 c4 10             	add    $0x10,%esp
      goto bad;
80108480:	eb 19                	jmp    8010849b <copyuvm+0x103>
  for(i = 0; i < sz; i += PGSIZE){
80108482:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108489:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010848c:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010848f:	0f 82 2d ff ff ff    	jb     801083c2 <copyuvm+0x2a>
    }
  }
  return d;
80108495:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108498:	eb 14                	jmp    801084ae <copyuvm+0x116>
      goto bad;
8010849a:	90                   	nop

bad:
  freevm(d);
8010849b:	83 ec 0c             	sub    $0xc,%esp
8010849e:	ff 75 f0             	push   -0x10(%ebp)
801084a1:	e8 18 fe ff ff       	call   801082be <freevm>
801084a6:	83 c4 10             	add    $0x10,%esp
  return 0;
801084a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801084ae:	c9                   	leave  
801084af:	c3                   	ret    

801084b0 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801084b0:	55                   	push   %ebp
801084b1:	89 e5                	mov    %esp,%ebp
801084b3:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801084b6:	83 ec 04             	sub    $0x4,%esp
801084b9:	6a 00                	push   $0x0
801084bb:	ff 75 0c             	push   0xc(%ebp)
801084be:	ff 75 08             	push   0x8(%ebp)
801084c1:	e8 63 f7 ff ff       	call   80107c29 <walkpgdir>
801084c6:	83 c4 10             	add    $0x10,%esp
801084c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801084cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084cf:	8b 00                	mov    (%eax),%eax
801084d1:	83 e0 01             	and    $0x1,%eax
801084d4:	85 c0                	test   %eax,%eax
801084d6:	75 07                	jne    801084df <uva2ka+0x2f>
    return 0;
801084d8:	b8 00 00 00 00       	mov    $0x0,%eax
801084dd:	eb 22                	jmp    80108501 <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
801084df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084e2:	8b 00                	mov    (%eax),%eax
801084e4:	83 e0 04             	and    $0x4,%eax
801084e7:	85 c0                	test   %eax,%eax
801084e9:	75 07                	jne    801084f2 <uva2ka+0x42>
    return 0;
801084eb:	b8 00 00 00 00       	mov    $0x0,%eax
801084f0:	eb 0f                	jmp    80108501 <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
801084f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084f5:	8b 00                	mov    (%eax),%eax
801084f7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084fc:	05 00 00 00 80       	add    $0x80000000,%eax
}
80108501:	c9                   	leave  
80108502:	c3                   	ret    

80108503 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108503:	55                   	push   %ebp
80108504:	89 e5                	mov    %esp,%ebp
80108506:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108509:	8b 45 10             	mov    0x10(%ebp),%eax
8010850c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
8010850f:	eb 7f                	jmp    80108590 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80108511:	8b 45 0c             	mov    0xc(%ebp),%eax
80108514:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108519:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
8010851c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010851f:	83 ec 08             	sub    $0x8,%esp
80108522:	50                   	push   %eax
80108523:	ff 75 08             	push   0x8(%ebp)
80108526:	e8 85 ff ff ff       	call   801084b0 <uva2ka>
8010852b:	83 c4 10             	add    $0x10,%esp
8010852e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108531:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108535:	75 07                	jne    8010853e <copyout+0x3b>
      return -1;
80108537:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010853c:	eb 61                	jmp    8010859f <copyout+0x9c>
    n = PGSIZE - (va - va0);
8010853e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108541:	2b 45 0c             	sub    0xc(%ebp),%eax
80108544:	05 00 10 00 00       	add    $0x1000,%eax
80108549:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010854c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010854f:	3b 45 14             	cmp    0x14(%ebp),%eax
80108552:	76 06                	jbe    8010855a <copyout+0x57>
      n = len;
80108554:	8b 45 14             	mov    0x14(%ebp),%eax
80108557:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
8010855a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010855d:	2b 45 ec             	sub    -0x14(%ebp),%eax
80108560:	89 c2                	mov    %eax,%edx
80108562:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108565:	01 d0                	add    %edx,%eax
80108567:	83 ec 04             	sub    $0x4,%esp
8010856a:	ff 75 f0             	push   -0x10(%ebp)
8010856d:	ff 75 f4             	push   -0xc(%ebp)
80108570:	50                   	push   %eax
80108571:	e8 2e cf ff ff       	call   801054a4 <memmove>
80108576:	83 c4 10             	add    $0x10,%esp
    len -= n;
80108579:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010857c:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
8010857f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108582:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108585:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108588:	05 00 10 00 00       	add    $0x1000,%eax
8010858d:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80108590:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108594:	0f 85 77 ff ff ff    	jne    80108511 <copyout+0xe>
  }
  return 0;
8010859a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010859f:	c9                   	leave  
801085a0:	c3                   	ret    
