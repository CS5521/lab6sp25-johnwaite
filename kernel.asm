
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
80100028:	bc 30 c6 10 80       	mov    $0x8010c630,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 74 37 10 80       	mov    $0x80103774,%eax
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
80100037:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	c7 44 24 04 5c 82 10 	movl   $0x8010825c,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 40 c6 10 80 	movl   $0x8010c640,(%esp)
80100049:	e8 4f 4d 00 00       	call   80104d9d <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 8c 0d 11 80 3c 	movl   $0x80110d3c,0x80110d8c
80100055:	0d 11 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 90 0d 11 80 3c 	movl   $0x80110d3c,0x80110d90
8010005f:	0d 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 74 c6 10 80 	movl   $0x8010c674,-0xc(%ebp)
80100069:	eb 46                	jmp    801000b1 <binit+0x7d>
    b->next = bcache.head.next;
8010006b:	8b 15 90 0d 11 80    	mov    0x80110d90,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 50 3c 0d 11 80 	movl   $0x80110d3c,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	83 c0 0c             	add    $0xc,%eax
80100087:	c7 44 24 04 63 82 10 	movl   $0x80108263,0x4(%esp)
8010008e:	80 
8010008f:	89 04 24             	mov    %eax,(%esp)
80100092:	e8 a3 4b 00 00       	call   80104c3a <initsleeplock>
    bcache.head.next->prev = b;
80100097:	a1 90 0d 11 80       	mov    0x80110d90,%eax
8010009c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010009f:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000a5:	a3 90 0d 11 80       	mov    %eax,0x80110d90
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000aa:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000b1:	81 7d f4 3c 0d 11 80 	cmpl   $0x80110d3c,-0xc(%ebp)
801000b8:	72 b1                	jb     8010006b <binit+0x37>
  }
}
801000ba:	c9                   	leave  
801000bb:	c3                   	ret    

801000bc <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000bc:	55                   	push   %ebp
801000bd:	89 e5                	mov    %esp,%ebp
801000bf:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000c2:	c7 04 24 40 c6 10 80 	movl   $0x8010c640,(%esp)
801000c9:	e8 f0 4c 00 00       	call   80104dbe <acquire>

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000ce:	a1 90 0d 11 80       	mov    0x80110d90,%eax
801000d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000d6:	eb 50                	jmp    80100128 <bget+0x6c>
    if(b->dev == dev && b->blockno == blockno){
801000d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000db:	8b 40 04             	mov    0x4(%eax),%eax
801000de:	3b 45 08             	cmp    0x8(%ebp),%eax
801000e1:	75 3c                	jne    8010011f <bget+0x63>
801000e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e6:	8b 40 08             	mov    0x8(%eax),%eax
801000e9:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000ec:	75 31                	jne    8010011f <bget+0x63>
      b->refcnt++;
801000ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f1:	8b 40 4c             	mov    0x4c(%eax),%eax
801000f4:	8d 50 01             	lea    0x1(%eax),%edx
801000f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000fa:	89 50 4c             	mov    %edx,0x4c(%eax)
      release(&bcache.lock);
801000fd:	c7 04 24 40 c6 10 80 	movl   $0x8010c640,(%esp)
80100104:	e8 1d 4d 00 00       	call   80104e26 <release>
      acquiresleep(&b->lock);
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	83 c0 0c             	add    $0xc,%eax
8010010f:	89 04 24             	mov    %eax,(%esp)
80100112:	e8 5d 4b 00 00       	call   80104c74 <acquiresleep>
      return b;
80100117:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011a:	e9 94 00 00 00       	jmp    801001b3 <bget+0xf7>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
8010011f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100122:	8b 40 54             	mov    0x54(%eax),%eax
80100125:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100128:	81 7d f4 3c 0d 11 80 	cmpl   $0x80110d3c,-0xc(%ebp)
8010012f:	75 a7                	jne    801000d8 <bget+0x1c>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100131:	a1 8c 0d 11 80       	mov    0x80110d8c,%eax
80100136:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100139:	eb 63                	jmp    8010019e <bget+0xe2>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
8010013b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010013e:	8b 40 4c             	mov    0x4c(%eax),%eax
80100141:	85 c0                	test   %eax,%eax
80100143:	75 50                	jne    80100195 <bget+0xd9>
80100145:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100148:	8b 00                	mov    (%eax),%eax
8010014a:	83 e0 04             	and    $0x4,%eax
8010014d:	85 c0                	test   %eax,%eax
8010014f:	75 44                	jne    80100195 <bget+0xd9>
      b->dev = dev;
80100151:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100154:	8b 55 08             	mov    0x8(%ebp),%edx
80100157:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	8b 55 0c             	mov    0xc(%ebp),%edx
80100160:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = 0;
80100163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100166:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      b->refcnt = 1;
8010016c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016f:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
      release(&bcache.lock);
80100176:	c7 04 24 40 c6 10 80 	movl   $0x8010c640,(%esp)
8010017d:	e8 a4 4c 00 00       	call   80104e26 <release>
      acquiresleep(&b->lock);
80100182:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100185:	83 c0 0c             	add    $0xc,%eax
80100188:	89 04 24             	mov    %eax,(%esp)
8010018b:	e8 e4 4a 00 00       	call   80104c74 <acquiresleep>
      return b;
80100190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100193:	eb 1e                	jmp    801001b3 <bget+0xf7>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100198:	8b 40 50             	mov    0x50(%eax),%eax
8010019b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010019e:	81 7d f4 3c 0d 11 80 	cmpl   $0x80110d3c,-0xc(%ebp)
801001a5:	75 94                	jne    8010013b <bget+0x7f>
    }
  }
  panic("bget: no buffers");
801001a7:	c7 04 24 6a 82 10 80 	movl   $0x8010826a,(%esp)
801001ae:	e8 af 03 00 00       	call   80100562 <panic>
}
801001b3:	c9                   	leave  
801001b4:	c3                   	ret    

801001b5 <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001b5:	55                   	push   %ebp
801001b6:	89 e5                	mov    %esp,%ebp
801001b8:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001bb:	8b 45 0c             	mov    0xc(%ebp),%eax
801001be:	89 44 24 04          	mov    %eax,0x4(%esp)
801001c2:	8b 45 08             	mov    0x8(%ebp),%eax
801001c5:	89 04 24             	mov    %eax,(%esp)
801001c8:	e8 ef fe ff ff       	call   801000bc <bget>
801001cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((b->flags & B_VALID) == 0) {
801001d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d3:	8b 00                	mov    (%eax),%eax
801001d5:	83 e0 02             	and    $0x2,%eax
801001d8:	85 c0                	test   %eax,%eax
801001da:	75 0b                	jne    801001e7 <bread+0x32>
    iderw(b);
801001dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001df:	89 04 24             	mov    %eax,(%esp)
801001e2:	e8 a4 26 00 00       	call   8010288b <iderw>
  }
  return b;
801001e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001ea:	c9                   	leave  
801001eb:	c3                   	ret    

801001ec <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
801001ec:	55                   	push   %ebp
801001ed:	89 e5                	mov    %esp,%ebp
801001ef:	83 ec 18             	sub    $0x18,%esp
  if(!holdingsleep(&b->lock))
801001f2:	8b 45 08             	mov    0x8(%ebp),%eax
801001f5:	83 c0 0c             	add    $0xc,%eax
801001f8:	89 04 24             	mov    %eax,(%esp)
801001fb:	e8 11 4b 00 00       	call   80104d11 <holdingsleep>
80100200:	85 c0                	test   %eax,%eax
80100202:	75 0c                	jne    80100210 <bwrite+0x24>
    panic("bwrite");
80100204:	c7 04 24 7b 82 10 80 	movl   $0x8010827b,(%esp)
8010020b:	e8 52 03 00 00       	call   80100562 <panic>
  b->flags |= B_DIRTY;
80100210:	8b 45 08             	mov    0x8(%ebp),%eax
80100213:	8b 00                	mov    (%eax),%eax
80100215:	83 c8 04             	or     $0x4,%eax
80100218:	89 c2                	mov    %eax,%edx
8010021a:	8b 45 08             	mov    0x8(%ebp),%eax
8010021d:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010021f:	8b 45 08             	mov    0x8(%ebp),%eax
80100222:	89 04 24             	mov    %eax,(%esp)
80100225:	e8 61 26 00 00       	call   8010288b <iderw>
}
8010022a:	c9                   	leave  
8010022b:	c3                   	ret    

8010022c <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
8010022c:	55                   	push   %ebp
8010022d:	89 e5                	mov    %esp,%ebp
8010022f:	83 ec 18             	sub    $0x18,%esp
  if(!holdingsleep(&b->lock))
80100232:	8b 45 08             	mov    0x8(%ebp),%eax
80100235:	83 c0 0c             	add    $0xc,%eax
80100238:	89 04 24             	mov    %eax,(%esp)
8010023b:	e8 d1 4a 00 00       	call   80104d11 <holdingsleep>
80100240:	85 c0                	test   %eax,%eax
80100242:	75 0c                	jne    80100250 <brelse+0x24>
    panic("brelse");
80100244:	c7 04 24 82 82 10 80 	movl   $0x80108282,(%esp)
8010024b:	e8 12 03 00 00       	call   80100562 <panic>

  releasesleep(&b->lock);
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	83 c0 0c             	add    $0xc,%eax
80100256:	89 04 24             	mov    %eax,(%esp)
80100259:	e8 71 4a 00 00       	call   80104ccf <releasesleep>

  acquire(&bcache.lock);
8010025e:	c7 04 24 40 c6 10 80 	movl   $0x8010c640,(%esp)
80100265:	e8 54 4b 00 00       	call   80104dbe <acquire>
  b->refcnt--;
8010026a:	8b 45 08             	mov    0x8(%ebp),%eax
8010026d:	8b 40 4c             	mov    0x4c(%eax),%eax
80100270:	8d 50 ff             	lea    -0x1(%eax),%edx
80100273:	8b 45 08             	mov    0x8(%ebp),%eax
80100276:	89 50 4c             	mov    %edx,0x4c(%eax)
  if (b->refcnt == 0) {
80100279:	8b 45 08             	mov    0x8(%ebp),%eax
8010027c:	8b 40 4c             	mov    0x4c(%eax),%eax
8010027f:	85 c0                	test   %eax,%eax
80100281:	75 47                	jne    801002ca <brelse+0x9e>
    // no one is waiting for it.
    b->next->prev = b->prev;
80100283:	8b 45 08             	mov    0x8(%ebp),%eax
80100286:	8b 40 54             	mov    0x54(%eax),%eax
80100289:	8b 55 08             	mov    0x8(%ebp),%edx
8010028c:	8b 52 50             	mov    0x50(%edx),%edx
8010028f:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
80100292:	8b 45 08             	mov    0x8(%ebp),%eax
80100295:	8b 40 50             	mov    0x50(%eax),%eax
80100298:	8b 55 08             	mov    0x8(%ebp),%edx
8010029b:	8b 52 54             	mov    0x54(%edx),%edx
8010029e:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
801002a1:	8b 15 90 0d 11 80    	mov    0x80110d90,%edx
801002a7:	8b 45 08             	mov    0x8(%ebp),%eax
801002aa:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801002ad:	8b 45 08             	mov    0x8(%ebp),%eax
801002b0:	c7 40 50 3c 0d 11 80 	movl   $0x80110d3c,0x50(%eax)
    bcache.head.next->prev = b;
801002b7:	a1 90 0d 11 80       	mov    0x80110d90,%eax
801002bc:	8b 55 08             	mov    0x8(%ebp),%edx
801002bf:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801002c2:	8b 45 08             	mov    0x8(%ebp),%eax
801002c5:	a3 90 0d 11 80       	mov    %eax,0x80110d90
  }
  
  release(&bcache.lock);
801002ca:	c7 04 24 40 c6 10 80 	movl   $0x8010c640,(%esp)
801002d1:	e8 50 4b 00 00       	call   80104e26 <release>
}
801002d6:	c9                   	leave  
801002d7:	c3                   	ret    

801002d8 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002d8:	55                   	push   %ebp
801002d9:	89 e5                	mov    %esp,%ebp
801002db:	83 ec 14             	sub    $0x14,%esp
801002de:	8b 45 08             	mov    0x8(%ebp),%eax
801002e1:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002e5:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002e9:	89 c2                	mov    %eax,%edx
801002eb:	ec                   	in     (%dx),%al
801002ec:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002ef:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002f3:	c9                   	leave  
801002f4:	c3                   	ret    

801002f5 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002f5:	55                   	push   %ebp
801002f6:	89 e5                	mov    %esp,%ebp
801002f8:	83 ec 08             	sub    $0x8,%esp
801002fb:	8b 55 08             	mov    0x8(%ebp),%edx
801002fe:	8b 45 0c             	mov    0xc(%ebp),%eax
80100301:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80100305:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100308:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010030c:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80100310:	ee                   	out    %al,(%dx)
}
80100311:	c9                   	leave  
80100312:	c3                   	ret    

80100313 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100313:	55                   	push   %ebp
80100314:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100316:	fa                   	cli    
}
80100317:	5d                   	pop    %ebp
80100318:	c3                   	ret    

80100319 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100319:	55                   	push   %ebp
8010031a:	89 e5                	mov    %esp,%ebp
8010031c:	56                   	push   %esi
8010031d:	53                   	push   %ebx
8010031e:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
80100321:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100325:	74 1c                	je     80100343 <printint+0x2a>
80100327:	8b 45 08             	mov    0x8(%ebp),%eax
8010032a:	c1 e8 1f             	shr    $0x1f,%eax
8010032d:	0f b6 c0             	movzbl %al,%eax
80100330:	89 45 10             	mov    %eax,0x10(%ebp)
80100333:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100337:	74 0a                	je     80100343 <printint+0x2a>
    x = -xx;
80100339:	8b 45 08             	mov    0x8(%ebp),%eax
8010033c:	f7 d8                	neg    %eax
8010033e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100341:	eb 06                	jmp    80100349 <printint+0x30>
  else
    x = xx;
80100343:	8b 45 08             	mov    0x8(%ebp),%eax
80100346:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100349:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100350:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100353:	8d 41 01             	lea    0x1(%ecx),%eax
80100356:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100359:	8b 5d 0c             	mov    0xc(%ebp),%ebx
8010035c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010035f:	ba 00 00 00 00       	mov    $0x0,%edx
80100364:	f7 f3                	div    %ebx
80100366:	89 d0                	mov    %edx,%eax
80100368:	0f b6 80 04 90 10 80 	movzbl -0x7fef6ffc(%eax),%eax
8010036f:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
80100373:	8b 75 0c             	mov    0xc(%ebp),%esi
80100376:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100379:	ba 00 00 00 00       	mov    $0x0,%edx
8010037e:	f7 f6                	div    %esi
80100380:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100383:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100387:	75 c7                	jne    80100350 <printint+0x37>

  if(sign)
80100389:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010038d:	74 10                	je     8010039f <printint+0x86>
    buf[i++] = '-';
8010038f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100392:	8d 50 01             	lea    0x1(%eax),%edx
80100395:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100398:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
8010039d:	eb 18                	jmp    801003b7 <printint+0x9e>
8010039f:	eb 16                	jmp    801003b7 <printint+0x9e>
    consputc(buf[i]);
801003a1:	8d 55 e0             	lea    -0x20(%ebp),%edx
801003a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003a7:	01 d0                	add    %edx,%eax
801003a9:	0f b6 00             	movzbl (%eax),%eax
801003ac:	0f be c0             	movsbl %al,%eax
801003af:	89 04 24             	mov    %eax,(%esp)
801003b2:	e8 d5 03 00 00       	call   8010078c <consputc>
  while(--i >= 0)
801003b7:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003bb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003bf:	79 e0                	jns    801003a1 <printint+0x88>
}
801003c1:	83 c4 30             	add    $0x30,%esp
801003c4:	5b                   	pop    %ebx
801003c5:	5e                   	pop    %esi
801003c6:	5d                   	pop    %ebp
801003c7:	c3                   	ret    

801003c8 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003c8:	55                   	push   %ebp
801003c9:	89 e5                	mov    %esp,%ebp
801003cb:	83 ec 38             	sub    $0x38,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003ce:	a1 d4 b5 10 80       	mov    0x8010b5d4,%eax
801003d3:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003d6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003da:	74 0c                	je     801003e8 <cprintf+0x20>
    acquire(&cons.lock);
801003dc:	c7 04 24 a0 b5 10 80 	movl   $0x8010b5a0,(%esp)
801003e3:	e8 d6 49 00 00       	call   80104dbe <acquire>

  if (fmt == 0)
801003e8:	8b 45 08             	mov    0x8(%ebp),%eax
801003eb:	85 c0                	test   %eax,%eax
801003ed:	75 0c                	jne    801003fb <cprintf+0x33>
    panic("null fmt");
801003ef:	c7 04 24 89 82 10 80 	movl   $0x80108289,(%esp)
801003f6:	e8 67 01 00 00       	call   80100562 <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003fb:	8d 45 0c             	lea    0xc(%ebp),%eax
801003fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100401:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100408:	e9 21 01 00 00       	jmp    8010052e <cprintf+0x166>
    if(c != '%'){
8010040d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100411:	74 10                	je     80100423 <cprintf+0x5b>
      consputc(c);
80100413:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100416:	89 04 24             	mov    %eax,(%esp)
80100419:	e8 6e 03 00 00       	call   8010078c <consputc>
      continue;
8010041e:	e9 07 01 00 00       	jmp    8010052a <cprintf+0x162>
    }
    c = fmt[++i] & 0xff;
80100423:	8b 55 08             	mov    0x8(%ebp),%edx
80100426:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010042a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010042d:	01 d0                	add    %edx,%eax
8010042f:	0f b6 00             	movzbl (%eax),%eax
80100432:	0f be c0             	movsbl %al,%eax
80100435:	25 ff 00 00 00       	and    $0xff,%eax
8010043a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
8010043d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100441:	75 05                	jne    80100448 <cprintf+0x80>
      break;
80100443:	e9 06 01 00 00       	jmp    8010054e <cprintf+0x186>
    switch(c){
80100448:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010044b:	83 f8 70             	cmp    $0x70,%eax
8010044e:	74 4f                	je     8010049f <cprintf+0xd7>
80100450:	83 f8 70             	cmp    $0x70,%eax
80100453:	7f 13                	jg     80100468 <cprintf+0xa0>
80100455:	83 f8 25             	cmp    $0x25,%eax
80100458:	0f 84 a6 00 00 00    	je     80100504 <cprintf+0x13c>
8010045e:	83 f8 64             	cmp    $0x64,%eax
80100461:	74 14                	je     80100477 <cprintf+0xaf>
80100463:	e9 aa 00 00 00       	jmp    80100512 <cprintf+0x14a>
80100468:	83 f8 73             	cmp    $0x73,%eax
8010046b:	74 57                	je     801004c4 <cprintf+0xfc>
8010046d:	83 f8 78             	cmp    $0x78,%eax
80100470:	74 2d                	je     8010049f <cprintf+0xd7>
80100472:	e9 9b 00 00 00       	jmp    80100512 <cprintf+0x14a>
    case 'd':
      printint(*argp++, 10, 1);
80100477:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010047a:	8d 50 04             	lea    0x4(%eax),%edx
8010047d:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100480:	8b 00                	mov    (%eax),%eax
80100482:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80100489:	00 
8010048a:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80100491:	00 
80100492:	89 04 24             	mov    %eax,(%esp)
80100495:	e8 7f fe ff ff       	call   80100319 <printint>
      break;
8010049a:	e9 8b 00 00 00       	jmp    8010052a <cprintf+0x162>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
8010049f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004a2:	8d 50 04             	lea    0x4(%eax),%edx
801004a5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004a8:	8b 00                	mov    (%eax),%eax
801004aa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801004b1:	00 
801004b2:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
801004b9:	00 
801004ba:	89 04 24             	mov    %eax,(%esp)
801004bd:	e8 57 fe ff ff       	call   80100319 <printint>
      break;
801004c2:	eb 66                	jmp    8010052a <cprintf+0x162>
    case 's':
      if((s = (char*)*argp++) == 0)
801004c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004c7:	8d 50 04             	lea    0x4(%eax),%edx
801004ca:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004cd:	8b 00                	mov    (%eax),%eax
801004cf:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004d2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004d6:	75 09                	jne    801004e1 <cprintf+0x119>
        s = "(null)";
801004d8:	c7 45 ec 92 82 10 80 	movl   $0x80108292,-0x14(%ebp)
      for(; *s; s++)
801004df:	eb 17                	jmp    801004f8 <cprintf+0x130>
801004e1:	eb 15                	jmp    801004f8 <cprintf+0x130>
        consputc(*s);
801004e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004e6:	0f b6 00             	movzbl (%eax),%eax
801004e9:	0f be c0             	movsbl %al,%eax
801004ec:	89 04 24             	mov    %eax,(%esp)
801004ef:	e8 98 02 00 00       	call   8010078c <consputc>
      for(; *s; s++)
801004f4:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004fb:	0f b6 00             	movzbl (%eax),%eax
801004fe:	84 c0                	test   %al,%al
80100500:	75 e1                	jne    801004e3 <cprintf+0x11b>
      break;
80100502:	eb 26                	jmp    8010052a <cprintf+0x162>
    case '%':
      consputc('%');
80100504:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
8010050b:	e8 7c 02 00 00       	call   8010078c <consputc>
      break;
80100510:	eb 18                	jmp    8010052a <cprintf+0x162>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
80100512:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
80100519:	e8 6e 02 00 00       	call   8010078c <consputc>
      consputc(c);
8010051e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100521:	89 04 24             	mov    %eax,(%esp)
80100524:	e8 63 02 00 00       	call   8010078c <consputc>
      break;
80100529:	90                   	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010052a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010052e:	8b 55 08             	mov    0x8(%ebp),%edx
80100531:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100534:	01 d0                	add    %edx,%eax
80100536:	0f b6 00             	movzbl (%eax),%eax
80100539:	0f be c0             	movsbl %al,%eax
8010053c:	25 ff 00 00 00       	and    $0xff,%eax
80100541:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100544:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100548:	0f 85 bf fe ff ff    	jne    8010040d <cprintf+0x45>
    }
  }

  if(locking)
8010054e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100552:	74 0c                	je     80100560 <cprintf+0x198>
    release(&cons.lock);
80100554:	c7 04 24 a0 b5 10 80 	movl   $0x8010b5a0,(%esp)
8010055b:	e8 c6 48 00 00       	call   80104e26 <release>
}
80100560:	c9                   	leave  
80100561:	c3                   	ret    

80100562 <panic>:

void
panic(char *s)
{
80100562:	55                   	push   %ebp
80100563:	89 e5                	mov    %esp,%ebp
80100565:	83 ec 48             	sub    $0x48,%esp
  int i;
  uint pcs[10];

  cli();
80100568:	e8 a6 fd ff ff       	call   80100313 <cli>
  cons.locking = 0;
8010056d:	c7 05 d4 b5 10 80 00 	movl   $0x0,0x8010b5d4
80100574:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
80100577:	e8 b3 29 00 00       	call   80102f2f <lapicid>
8010057c:	89 44 24 04          	mov    %eax,0x4(%esp)
80100580:	c7 04 24 99 82 10 80 	movl   $0x80108299,(%esp)
80100587:	e8 3c fe ff ff       	call   801003c8 <cprintf>
  cprintf(s);
8010058c:	8b 45 08             	mov    0x8(%ebp),%eax
8010058f:	89 04 24             	mov    %eax,(%esp)
80100592:	e8 31 fe ff ff       	call   801003c8 <cprintf>
  cprintf("\n");
80100597:	c7 04 24 ad 82 10 80 	movl   $0x801082ad,(%esp)
8010059e:	e8 25 fe ff ff       	call   801003c8 <cprintf>
  getcallerpcs(&s, pcs);
801005a3:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005a6:	89 44 24 04          	mov    %eax,0x4(%esp)
801005aa:	8d 45 08             	lea    0x8(%ebp),%eax
801005ad:	89 04 24             	mov    %eax,(%esp)
801005b0:	e8 bc 48 00 00       	call   80104e71 <getcallerpcs>
  for(i=0; i<10; i++)
801005b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005bc:	eb 1b                	jmp    801005d9 <panic+0x77>
    cprintf(" %p", pcs[i]);
801005be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005c1:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005c5:	89 44 24 04          	mov    %eax,0x4(%esp)
801005c9:	c7 04 24 af 82 10 80 	movl   $0x801082af,(%esp)
801005d0:	e8 f3 fd ff ff       	call   801003c8 <cprintf>
  for(i=0; i<10; i++)
801005d5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005d9:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005dd:	7e df                	jle    801005be <panic+0x5c>
  panicked = 1; // freeze other CPU
801005df:	c7 05 80 b5 10 80 01 	movl   $0x1,0x8010b580
801005e6:	00 00 00 
  for(;;)
    ;
801005e9:	eb fe                	jmp    801005e9 <panic+0x87>

801005eb <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801005eb:	55                   	push   %ebp
801005ec:	89 e5                	mov    %esp,%ebp
801005ee:	83 ec 28             	sub    $0x28,%esp
  int pos;

  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801005f1:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801005f8:	00 
801005f9:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100600:	e8 f0 fc ff ff       	call   801002f5 <outb>
  pos = inb(CRTPORT+1) << 8;
80100605:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
8010060c:	e8 c7 fc ff ff       	call   801002d8 <inb>
80100611:	0f b6 c0             	movzbl %al,%eax
80100614:	c1 e0 08             	shl    $0x8,%eax
80100617:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
8010061a:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100621:	00 
80100622:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100629:	e8 c7 fc ff ff       	call   801002f5 <outb>
  pos |= inb(CRTPORT+1);
8010062e:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100635:	e8 9e fc ff ff       	call   801002d8 <inb>
8010063a:	0f b6 c0             	movzbl %al,%eax
8010063d:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
80100640:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100644:	75 30                	jne    80100676 <cgaputc+0x8b>
    pos += 80 - pos%80;
80100646:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100649:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010064e:	89 c8                	mov    %ecx,%eax
80100650:	f7 ea                	imul   %edx
80100652:	c1 fa 05             	sar    $0x5,%edx
80100655:	89 c8                	mov    %ecx,%eax
80100657:	c1 f8 1f             	sar    $0x1f,%eax
8010065a:	29 c2                	sub    %eax,%edx
8010065c:	89 d0                	mov    %edx,%eax
8010065e:	c1 e0 02             	shl    $0x2,%eax
80100661:	01 d0                	add    %edx,%eax
80100663:	c1 e0 04             	shl    $0x4,%eax
80100666:	29 c1                	sub    %eax,%ecx
80100668:	89 ca                	mov    %ecx,%edx
8010066a:	b8 50 00 00 00       	mov    $0x50,%eax
8010066f:	29 d0                	sub    %edx,%eax
80100671:	01 45 f4             	add    %eax,-0xc(%ebp)
80100674:	eb 35                	jmp    801006ab <cgaputc+0xc0>
  else if(c == BACKSPACE){
80100676:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010067d:	75 0c                	jne    8010068b <cgaputc+0xa0>
    if(pos > 0) --pos;
8010067f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100683:	7e 26                	jle    801006ab <cgaputc+0xc0>
80100685:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100689:	eb 20                	jmp    801006ab <cgaputc+0xc0>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010068b:	8b 0d 00 90 10 80    	mov    0x80109000,%ecx
80100691:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100694:	8d 50 01             	lea    0x1(%eax),%edx
80100697:	89 55 f4             	mov    %edx,-0xc(%ebp)
8010069a:	01 c0                	add    %eax,%eax
8010069c:	8d 14 01             	lea    (%ecx,%eax,1),%edx
8010069f:	8b 45 08             	mov    0x8(%ebp),%eax
801006a2:	0f b6 c0             	movzbl %al,%eax
801006a5:	80 cc 07             	or     $0x7,%ah
801006a8:	66 89 02             	mov    %ax,(%edx)

  if(pos < 0 || pos > 25*80)
801006ab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801006af:	78 09                	js     801006ba <cgaputc+0xcf>
801006b1:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
801006b8:	7e 0c                	jle    801006c6 <cgaputc+0xdb>
    panic("pos under/overflow");
801006ba:	c7 04 24 b3 82 10 80 	movl   $0x801082b3,(%esp)
801006c1:	e8 9c fe ff ff       	call   80100562 <panic>

  if((pos/80) >= 24){  // Scroll up.
801006c6:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006cd:	7e 53                	jle    80100722 <cgaputc+0x137>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006cf:	a1 00 90 10 80       	mov    0x80109000,%eax
801006d4:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006da:	a1 00 90 10 80       	mov    0x80109000,%eax
801006df:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
801006e6:	00 
801006e7:	89 54 24 04          	mov    %edx,0x4(%esp)
801006eb:	89 04 24             	mov    %eax,(%esp)
801006ee:	e8 0c 4a 00 00       	call   801050ff <memmove>
    pos -= 80;
801006f3:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006f7:	b8 80 07 00 00       	mov    $0x780,%eax
801006fc:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006ff:	8d 14 00             	lea    (%eax,%eax,1),%edx
80100702:	a1 00 90 10 80       	mov    0x80109000,%eax
80100707:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010070a:	01 c9                	add    %ecx,%ecx
8010070c:	01 c8                	add    %ecx,%eax
8010070e:	89 54 24 08          	mov    %edx,0x8(%esp)
80100712:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100719:	00 
8010071a:	89 04 24             	mov    %eax,(%esp)
8010071d:	e8 0e 49 00 00       	call   80105030 <memset>
  }

  outb(CRTPORT, 14);
80100722:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
80100729:	00 
8010072a:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100731:	e8 bf fb ff ff       	call   801002f5 <outb>
  outb(CRTPORT+1, pos>>8);
80100736:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100739:	c1 f8 08             	sar    $0x8,%eax
8010073c:	0f b6 c0             	movzbl %al,%eax
8010073f:	89 44 24 04          	mov    %eax,0x4(%esp)
80100743:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
8010074a:	e8 a6 fb ff ff       	call   801002f5 <outb>
  outb(CRTPORT, 15);
8010074f:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100756:	00 
80100757:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
8010075e:	e8 92 fb ff ff       	call   801002f5 <outb>
  outb(CRTPORT+1, pos);
80100763:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100766:	0f b6 c0             	movzbl %al,%eax
80100769:	89 44 24 04          	mov    %eax,0x4(%esp)
8010076d:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100774:	e8 7c fb ff ff       	call   801002f5 <outb>
  crt[pos] = ' ' | 0x0700;
80100779:	a1 00 90 10 80       	mov    0x80109000,%eax
8010077e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100781:	01 d2                	add    %edx,%edx
80100783:	01 d0                	add    %edx,%eax
80100785:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
8010078a:	c9                   	leave  
8010078b:	c3                   	ret    

8010078c <consputc>:

void
consputc(int c)
{
8010078c:	55                   	push   %ebp
8010078d:	89 e5                	mov    %esp,%ebp
8010078f:	83 ec 18             	sub    $0x18,%esp
  if(panicked){
80100792:	a1 80 b5 10 80       	mov    0x8010b580,%eax
80100797:	85 c0                	test   %eax,%eax
80100799:	74 07                	je     801007a2 <consputc+0x16>
    cli();
8010079b:	e8 73 fb ff ff       	call   80100313 <cli>
    for(;;)
      ;
801007a0:	eb fe                	jmp    801007a0 <consputc+0x14>
  }

  if(c == BACKSPACE){
801007a2:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801007a9:	75 26                	jne    801007d1 <consputc+0x45>
    uartputc('\b'); uartputc(' '); uartputc('\b');
801007ab:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801007b2:	e8 f1 61 00 00       	call   801069a8 <uartputc>
801007b7:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801007be:	e8 e5 61 00 00       	call   801069a8 <uartputc>
801007c3:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801007ca:	e8 d9 61 00 00       	call   801069a8 <uartputc>
801007cf:	eb 0b                	jmp    801007dc <consputc+0x50>
  } else
    uartputc(c);
801007d1:	8b 45 08             	mov    0x8(%ebp),%eax
801007d4:	89 04 24             	mov    %eax,(%esp)
801007d7:	e8 cc 61 00 00       	call   801069a8 <uartputc>
  cgaputc(c);
801007dc:	8b 45 08             	mov    0x8(%ebp),%eax
801007df:	89 04 24             	mov    %eax,(%esp)
801007e2:	e8 04 fe ff ff       	call   801005eb <cgaputc>
}
801007e7:	c9                   	leave  
801007e8:	c3                   	ret    

801007e9 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007e9:	55                   	push   %ebp
801007ea:	89 e5                	mov    %esp,%ebp
801007ec:	83 ec 28             	sub    $0x28,%esp
  int c, doprocdump = 0;
801007ef:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
801007f6:	c7 04 24 a0 b5 10 80 	movl   $0x8010b5a0,(%esp)
801007fd:	e8 bc 45 00 00       	call   80104dbe <acquire>
  while((c = getc()) >= 0){
80100802:	e9 39 01 00 00       	jmp    80100940 <consoleintr+0x157>
    switch(c){
80100807:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010080a:	83 f8 10             	cmp    $0x10,%eax
8010080d:	74 1e                	je     8010082d <consoleintr+0x44>
8010080f:	83 f8 10             	cmp    $0x10,%eax
80100812:	7f 0a                	jg     8010081e <consoleintr+0x35>
80100814:	83 f8 08             	cmp    $0x8,%eax
80100817:	74 66                	je     8010087f <consoleintr+0x96>
80100819:	e9 93 00 00 00       	jmp    801008b1 <consoleintr+0xc8>
8010081e:	83 f8 15             	cmp    $0x15,%eax
80100821:	74 31                	je     80100854 <consoleintr+0x6b>
80100823:	83 f8 7f             	cmp    $0x7f,%eax
80100826:	74 57                	je     8010087f <consoleintr+0x96>
80100828:	e9 84 00 00 00       	jmp    801008b1 <consoleintr+0xc8>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
8010082d:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100834:	e9 07 01 00 00       	jmp    80100940 <consoleintr+0x157>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100839:	a1 28 10 11 80       	mov    0x80111028,%eax
8010083e:	83 e8 01             	sub    $0x1,%eax
80100841:	a3 28 10 11 80       	mov    %eax,0x80111028
        consputc(BACKSPACE);
80100846:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
8010084d:	e8 3a ff ff ff       	call   8010078c <consputc>
80100852:	eb 01                	jmp    80100855 <consoleintr+0x6c>
      while(input.e != input.w &&
80100854:	90                   	nop
80100855:	8b 15 28 10 11 80    	mov    0x80111028,%edx
8010085b:	a1 24 10 11 80       	mov    0x80111024,%eax
80100860:	39 c2                	cmp    %eax,%edx
80100862:	74 16                	je     8010087a <consoleintr+0x91>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100864:	a1 28 10 11 80       	mov    0x80111028,%eax
80100869:	83 e8 01             	sub    $0x1,%eax
8010086c:	83 e0 7f             	and    $0x7f,%eax
8010086f:	0f b6 80 a0 0f 11 80 	movzbl -0x7feef060(%eax),%eax
      while(input.e != input.w &&
80100876:	3c 0a                	cmp    $0xa,%al
80100878:	75 bf                	jne    80100839 <consoleintr+0x50>
      }
      break;
8010087a:	e9 c1 00 00 00       	jmp    80100940 <consoleintr+0x157>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
8010087f:	8b 15 28 10 11 80    	mov    0x80111028,%edx
80100885:	a1 24 10 11 80       	mov    0x80111024,%eax
8010088a:	39 c2                	cmp    %eax,%edx
8010088c:	74 1e                	je     801008ac <consoleintr+0xc3>
        input.e--;
8010088e:	a1 28 10 11 80       	mov    0x80111028,%eax
80100893:	83 e8 01             	sub    $0x1,%eax
80100896:	a3 28 10 11 80       	mov    %eax,0x80111028
        consputc(BACKSPACE);
8010089b:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
801008a2:	e8 e5 fe ff ff       	call   8010078c <consputc>
      }
      break;
801008a7:	e9 94 00 00 00       	jmp    80100940 <consoleintr+0x157>
801008ac:	e9 8f 00 00 00       	jmp    80100940 <consoleintr+0x157>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008b1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801008b5:	0f 84 84 00 00 00    	je     8010093f <consoleintr+0x156>
801008bb:	8b 15 28 10 11 80    	mov    0x80111028,%edx
801008c1:	a1 20 10 11 80       	mov    0x80111020,%eax
801008c6:	29 c2                	sub    %eax,%edx
801008c8:	89 d0                	mov    %edx,%eax
801008ca:	83 f8 7f             	cmp    $0x7f,%eax
801008cd:	77 70                	ja     8010093f <consoleintr+0x156>
        c = (c == '\r') ? '\n' : c;
801008cf:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801008d3:	74 05                	je     801008da <consoleintr+0xf1>
801008d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008d8:	eb 05                	jmp    801008df <consoleintr+0xf6>
801008da:	b8 0a 00 00 00       	mov    $0xa,%eax
801008df:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008e2:	a1 28 10 11 80       	mov    0x80111028,%eax
801008e7:	8d 50 01             	lea    0x1(%eax),%edx
801008ea:	89 15 28 10 11 80    	mov    %edx,0x80111028
801008f0:	83 e0 7f             	and    $0x7f,%eax
801008f3:	89 c2                	mov    %eax,%edx
801008f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008f8:	88 82 a0 0f 11 80    	mov    %al,-0x7feef060(%edx)
        consputc(c);
801008fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100901:	89 04 24             	mov    %eax,(%esp)
80100904:	e8 83 fe ff ff       	call   8010078c <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100909:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
8010090d:	74 18                	je     80100927 <consoleintr+0x13e>
8010090f:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100913:	74 12                	je     80100927 <consoleintr+0x13e>
80100915:	a1 28 10 11 80       	mov    0x80111028,%eax
8010091a:	8b 15 20 10 11 80    	mov    0x80111020,%edx
80100920:	83 ea 80             	sub    $0xffffff80,%edx
80100923:	39 d0                	cmp    %edx,%eax
80100925:	75 18                	jne    8010093f <consoleintr+0x156>
          input.w = input.e;
80100927:	a1 28 10 11 80       	mov    0x80111028,%eax
8010092c:	a3 24 10 11 80       	mov    %eax,0x80111024
          wakeup(&input.r);
80100931:	c7 04 24 20 10 11 80 	movl   $0x80111020,(%esp)
80100938:	e8 63 41 00 00       	call   80104aa0 <wakeup>
        }
      }
      break;
8010093d:	eb 00                	jmp    8010093f <consoleintr+0x156>
8010093f:	90                   	nop
  while((c = getc()) >= 0){
80100940:	8b 45 08             	mov    0x8(%ebp),%eax
80100943:	ff d0                	call   *%eax
80100945:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100948:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010094c:	0f 89 b5 fe ff ff    	jns    80100807 <consoleintr+0x1e>
    }
  }
  release(&cons.lock);
80100952:	c7 04 24 a0 b5 10 80 	movl   $0x8010b5a0,(%esp)
80100959:	e8 c8 44 00 00       	call   80104e26 <release>
  if(doprocdump) {
8010095e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100962:	74 05                	je     80100969 <consoleintr+0x180>
    procdump();  // now call procdump() wo. cons.lock held
80100964:	e8 da 41 00 00       	call   80104b43 <procdump>
  }
}
80100969:	c9                   	leave  
8010096a:	c3                   	ret    

8010096b <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
8010096b:	55                   	push   %ebp
8010096c:	89 e5                	mov    %esp,%ebp
8010096e:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
80100971:	8b 45 08             	mov    0x8(%ebp),%eax
80100974:	89 04 24             	mov    %eax,(%esp)
80100977:	e8 ee 10 00 00       	call   80101a6a <iunlock>
  target = n;
8010097c:	8b 45 10             	mov    0x10(%ebp),%eax
8010097f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100982:	c7 04 24 a0 b5 10 80 	movl   $0x8010b5a0,(%esp)
80100989:	e8 30 44 00 00       	call   80104dbe <acquire>
  while(n > 0){
8010098e:	e9 a9 00 00 00       	jmp    80100a3c <consoleread+0xd1>
    while(input.r == input.w){
80100993:	eb 41                	jmp    801009d6 <consoleread+0x6b>
      if(myproc()->killed){
80100995:	e8 c7 37 00 00       	call   80104161 <myproc>
8010099a:	8b 40 24             	mov    0x24(%eax),%eax
8010099d:	85 c0                	test   %eax,%eax
8010099f:	74 21                	je     801009c2 <consoleread+0x57>
        release(&cons.lock);
801009a1:	c7 04 24 a0 b5 10 80 	movl   $0x8010b5a0,(%esp)
801009a8:	e8 79 44 00 00       	call   80104e26 <release>
        ilock(ip);
801009ad:	8b 45 08             	mov    0x8(%ebp),%eax
801009b0:	89 04 24             	mov    %eax,(%esp)
801009b3:	e8 a5 0f 00 00       	call   8010195d <ilock>
        return -1;
801009b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009bd:	e9 a5 00 00 00       	jmp    80100a67 <consoleread+0xfc>
      }
      sleep(&input.r, &cons.lock);
801009c2:	c7 44 24 04 a0 b5 10 	movl   $0x8010b5a0,0x4(%esp)
801009c9:	80 
801009ca:	c7 04 24 20 10 11 80 	movl   $0x80111020,(%esp)
801009d1:	e8 f6 3f 00 00       	call   801049cc <sleep>
    while(input.r == input.w){
801009d6:	8b 15 20 10 11 80    	mov    0x80111020,%edx
801009dc:	a1 24 10 11 80       	mov    0x80111024,%eax
801009e1:	39 c2                	cmp    %eax,%edx
801009e3:	74 b0                	je     80100995 <consoleread+0x2a>
    }
    c = input.buf[input.r++ % INPUT_BUF];
801009e5:	a1 20 10 11 80       	mov    0x80111020,%eax
801009ea:	8d 50 01             	lea    0x1(%eax),%edx
801009ed:	89 15 20 10 11 80    	mov    %edx,0x80111020
801009f3:	83 e0 7f             	and    $0x7f,%eax
801009f6:	0f b6 80 a0 0f 11 80 	movzbl -0x7feef060(%eax),%eax
801009fd:	0f be c0             	movsbl %al,%eax
80100a00:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a03:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a07:	75 19                	jne    80100a22 <consoleread+0xb7>
      if(n < target){
80100a09:	8b 45 10             	mov    0x10(%ebp),%eax
80100a0c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100a0f:	73 0f                	jae    80100a20 <consoleread+0xb5>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a11:	a1 20 10 11 80       	mov    0x80111020,%eax
80100a16:	83 e8 01             	sub    $0x1,%eax
80100a19:	a3 20 10 11 80       	mov    %eax,0x80111020
      }
      break;
80100a1e:	eb 26                	jmp    80100a46 <consoleread+0xdb>
80100a20:	eb 24                	jmp    80100a46 <consoleread+0xdb>
    }
    *dst++ = c;
80100a22:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a25:	8d 50 01             	lea    0x1(%eax),%edx
80100a28:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a2b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a2e:	88 10                	mov    %dl,(%eax)
    --n;
80100a30:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a34:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a38:	75 02                	jne    80100a3c <consoleread+0xd1>
      break;
80100a3a:	eb 0a                	jmp    80100a46 <consoleread+0xdb>
  while(n > 0){
80100a3c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a40:	0f 8f 4d ff ff ff    	jg     80100993 <consoleread+0x28>
  }
  release(&cons.lock);
80100a46:	c7 04 24 a0 b5 10 80 	movl   $0x8010b5a0,(%esp)
80100a4d:	e8 d4 43 00 00       	call   80104e26 <release>
  ilock(ip);
80100a52:	8b 45 08             	mov    0x8(%ebp),%eax
80100a55:	89 04 24             	mov    %eax,(%esp)
80100a58:	e8 00 0f 00 00       	call   8010195d <ilock>

  return target - n;
80100a5d:	8b 45 10             	mov    0x10(%ebp),%eax
80100a60:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a63:	29 c2                	sub    %eax,%edx
80100a65:	89 d0                	mov    %edx,%eax
}
80100a67:	c9                   	leave  
80100a68:	c3                   	ret    

80100a69 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a69:	55                   	push   %ebp
80100a6a:	89 e5                	mov    %esp,%ebp
80100a6c:	83 ec 28             	sub    $0x28,%esp
  int i;

  iunlock(ip);
80100a6f:	8b 45 08             	mov    0x8(%ebp),%eax
80100a72:	89 04 24             	mov    %eax,(%esp)
80100a75:	e8 f0 0f 00 00       	call   80101a6a <iunlock>
  acquire(&cons.lock);
80100a7a:	c7 04 24 a0 b5 10 80 	movl   $0x8010b5a0,(%esp)
80100a81:	e8 38 43 00 00       	call   80104dbe <acquire>
  for(i = 0; i < n; i++)
80100a86:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100a8d:	eb 1d                	jmp    80100aac <consolewrite+0x43>
    consputc(buf[i] & 0xff);
80100a8f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a92:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a95:	01 d0                	add    %edx,%eax
80100a97:	0f b6 00             	movzbl (%eax),%eax
80100a9a:	0f be c0             	movsbl %al,%eax
80100a9d:	0f b6 c0             	movzbl %al,%eax
80100aa0:	89 04 24             	mov    %eax,(%esp)
80100aa3:	e8 e4 fc ff ff       	call   8010078c <consputc>
  for(i = 0; i < n; i++)
80100aa8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100aac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100aaf:	3b 45 10             	cmp    0x10(%ebp),%eax
80100ab2:	7c db                	jl     80100a8f <consolewrite+0x26>
  release(&cons.lock);
80100ab4:	c7 04 24 a0 b5 10 80 	movl   $0x8010b5a0,(%esp)
80100abb:	e8 66 43 00 00       	call   80104e26 <release>
  ilock(ip);
80100ac0:	8b 45 08             	mov    0x8(%ebp),%eax
80100ac3:	89 04 24             	mov    %eax,(%esp)
80100ac6:	e8 92 0e 00 00       	call   8010195d <ilock>

  return n;
80100acb:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100ace:	c9                   	leave  
80100acf:	c3                   	ret    

80100ad0 <consoleinit>:

void
consoleinit(void)
{
80100ad0:	55                   	push   %ebp
80100ad1:	89 e5                	mov    %esp,%ebp
80100ad3:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100ad6:	c7 44 24 04 c6 82 10 	movl   $0x801082c6,0x4(%esp)
80100add:	80 
80100ade:	c7 04 24 a0 b5 10 80 	movl   $0x8010b5a0,(%esp)
80100ae5:	e8 b3 42 00 00       	call   80104d9d <initlock>

  devsw[CONSOLE].write = consolewrite;
80100aea:	c7 05 ec 19 11 80 69 	movl   $0x80100a69,0x801119ec
80100af1:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100af4:	c7 05 e8 19 11 80 6b 	movl   $0x8010096b,0x801119e8
80100afb:	09 10 80 
  cons.locking = 1;
80100afe:	c7 05 d4 b5 10 80 01 	movl   $0x1,0x8010b5d4
80100b05:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100b08:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100b0f:	00 
80100b10:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100b17:	e8 23 1f 00 00       	call   80102a3f <ioapicenable>
}
80100b1c:	c9                   	leave  
80100b1d:	c3                   	ret    

80100b1e <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b1e:	55                   	push   %ebp
80100b1f:	89 e5                	mov    %esp,%ebp
80100b21:	81 ec 38 01 00 00    	sub    $0x138,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100b27:	e8 35 36 00 00       	call   80104161 <myproc>
80100b2c:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100b2f:	e8 53 29 00 00       	call   80103487 <begin_op>

  if((ip = namei(path)) == 0){
80100b34:	8b 45 08             	mov    0x8(%ebp),%eax
80100b37:	89 04 24             	mov    %eax,(%esp)
80100b3a:	e8 58 19 00 00       	call   80102497 <namei>
80100b3f:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b42:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b46:	75 1b                	jne    80100b63 <exec+0x45>
    end_op();
80100b48:	e8 be 29 00 00       	call   8010350b <end_op>
    cprintf("exec: fail\n");
80100b4d:	c7 04 24 ce 82 10 80 	movl   $0x801082ce,(%esp)
80100b54:	e8 6f f8 ff ff       	call   801003c8 <cprintf>
    return -1;
80100b59:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100b5e:	e9 04 04 00 00       	jmp    80100f67 <exec+0x449>
  }
  ilock(ip);
80100b63:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b66:	89 04 24             	mov    %eax,(%esp)
80100b69:	e8 ef 0d 00 00       	call   8010195d <ilock>
  pgdir = 0;
80100b6e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100b75:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100b7c:	00 
80100b7d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100b84:	00 
80100b85:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100b8b:	89 44 24 04          	mov    %eax,0x4(%esp)
80100b8f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b92:	89 04 24             	mov    %eax,(%esp)
80100b95:	e8 60 12 00 00       	call   80101dfa <readi>
80100b9a:	83 f8 34             	cmp    $0x34,%eax
80100b9d:	74 05                	je     80100ba4 <exec+0x86>
    goto bad;
80100b9f:	e9 97 03 00 00       	jmp    80100f3b <exec+0x41d>
  if(elf.magic != ELF_MAGIC)
80100ba4:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100baa:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100baf:	74 05                	je     80100bb6 <exec+0x98>
    goto bad;
80100bb1:	e9 85 03 00 00       	jmp    80100f3b <exec+0x41d>

  if((pgdir = setupkvm()) == 0)
80100bb6:	e8 ea 6d 00 00       	call   801079a5 <setupkvm>
80100bbb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100bbe:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100bc2:	75 05                	jne    80100bc9 <exec+0xab>
    goto bad;
80100bc4:	e9 72 03 00 00       	jmp    80100f3b <exec+0x41d>

  // Load program into memory.
  sz = 0;
80100bc9:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100bd0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100bd7:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100bdd:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100be0:	e9 fc 00 00 00       	jmp    80100ce1 <exec+0x1c3>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100be5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100be8:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100bef:	00 
80100bf0:	89 44 24 08          	mov    %eax,0x8(%esp)
80100bf4:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100bfa:	89 44 24 04          	mov    %eax,0x4(%esp)
80100bfe:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100c01:	89 04 24             	mov    %eax,(%esp)
80100c04:	e8 f1 11 00 00       	call   80101dfa <readi>
80100c09:	83 f8 20             	cmp    $0x20,%eax
80100c0c:	74 05                	je     80100c13 <exec+0xf5>
      goto bad;
80100c0e:	e9 28 03 00 00       	jmp    80100f3b <exec+0x41d>
    if(ph.type != ELF_PROG_LOAD)
80100c13:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100c19:	83 f8 01             	cmp    $0x1,%eax
80100c1c:	74 05                	je     80100c23 <exec+0x105>
      continue;
80100c1e:	e9 b1 00 00 00       	jmp    80100cd4 <exec+0x1b6>
    if(ph.memsz < ph.filesz)
80100c23:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100c29:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100c2f:	39 c2                	cmp    %eax,%edx
80100c31:	73 05                	jae    80100c38 <exec+0x11a>
      goto bad;
80100c33:	e9 03 03 00 00       	jmp    80100f3b <exec+0x41d>
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100c38:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c3e:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c44:	01 c2                	add    %eax,%edx
80100c46:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100c4c:	39 c2                	cmp    %eax,%edx
80100c4e:	73 05                	jae    80100c55 <exec+0x137>
      goto bad;
80100c50:	e9 e6 02 00 00       	jmp    80100f3b <exec+0x41d>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c55:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c5b:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c61:	01 d0                	add    %edx,%eax
80100c63:	89 44 24 08          	mov    %eax,0x8(%esp)
80100c67:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c6a:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c6e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c71:	89 04 24             	mov    %eax,(%esp)
80100c74:	e8 02 71 00 00       	call   80107d7b <allocuvm>
80100c79:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c7c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c80:	75 05                	jne    80100c87 <exec+0x169>
      goto bad;
80100c82:	e9 b4 02 00 00       	jmp    80100f3b <exec+0x41d>
    if(ph.vaddr % PGSIZE != 0)
80100c87:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100c8d:	25 ff 0f 00 00       	and    $0xfff,%eax
80100c92:	85 c0                	test   %eax,%eax
80100c94:	74 05                	je     80100c9b <exec+0x17d>
      goto bad;
80100c96:	e9 a0 02 00 00       	jmp    80100f3b <exec+0x41d>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c9b:	8b 8d f8 fe ff ff    	mov    -0x108(%ebp),%ecx
80100ca1:	8b 95 ec fe ff ff    	mov    -0x114(%ebp),%edx
80100ca7:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cad:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100cb1:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100cb5:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100cb8:	89 54 24 08          	mov    %edx,0x8(%esp)
80100cbc:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cc0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100cc3:	89 04 24             	mov    %eax,(%esp)
80100cc6:	e8 cd 6f 00 00       	call   80107c98 <loaduvm>
80100ccb:	85 c0                	test   %eax,%eax
80100ccd:	79 05                	jns    80100cd4 <exec+0x1b6>
      goto bad;
80100ccf:	e9 67 02 00 00       	jmp    80100f3b <exec+0x41d>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100cd4:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100cd8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100cdb:	83 c0 20             	add    $0x20,%eax
80100cde:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100ce1:	0f b7 85 34 ff ff ff 	movzwl -0xcc(%ebp),%eax
80100ce8:	0f b7 c0             	movzwl %ax,%eax
80100ceb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100cee:	0f 8f f1 fe ff ff    	jg     80100be5 <exec+0xc7>
  }
  iunlockput(ip);
80100cf4:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100cf7:	89 04 24             	mov    %eax,(%esp)
80100cfa:	e8 60 0e 00 00       	call   80101b5f <iunlockput>
  end_op();
80100cff:	e8 07 28 00 00       	call   8010350b <end_op>
  ip = 0;
80100d04:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100d0b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d0e:	05 ff 0f 00 00       	add    $0xfff,%eax
80100d13:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d18:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d1b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d1e:	05 00 20 00 00       	add    $0x2000,%eax
80100d23:	89 44 24 08          	mov    %eax,0x8(%esp)
80100d27:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d2a:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d2e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100d31:	89 04 24             	mov    %eax,(%esp)
80100d34:	e8 42 70 00 00       	call   80107d7b <allocuvm>
80100d39:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d3c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d40:	75 05                	jne    80100d47 <exec+0x229>
    goto bad;
80100d42:	e9 f4 01 00 00       	jmp    80100f3b <exec+0x41d>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d47:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d4a:	2d 00 20 00 00       	sub    $0x2000,%eax
80100d4f:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d53:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100d56:	89 04 24             	mov    %eax,(%esp)
80100d59:	e8 90 72 00 00       	call   80107fee <clearpteu>
  sp = sz;
80100d5e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d61:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d64:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d6b:	e9 9a 00 00 00       	jmp    80100e0a <exec+0x2ec>
    if(argc >= MAXARG)
80100d70:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d74:	76 05                	jbe    80100d7b <exec+0x25d>
      goto bad;
80100d76:	e9 c0 01 00 00       	jmp    80100f3b <exec+0x41d>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d7b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d7e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d85:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d88:	01 d0                	add    %edx,%eax
80100d8a:	8b 00                	mov    (%eax),%eax
80100d8c:	89 04 24             	mov    %eax,(%esp)
80100d8f:	e8 06 45 00 00       	call   8010529a <strlen>
80100d94:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100d97:	29 c2                	sub    %eax,%edx
80100d99:	89 d0                	mov    %edx,%eax
80100d9b:	83 e8 01             	sub    $0x1,%eax
80100d9e:	83 e0 fc             	and    $0xfffffffc,%eax
80100da1:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100da4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100da7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dae:	8b 45 0c             	mov    0xc(%ebp),%eax
80100db1:	01 d0                	add    %edx,%eax
80100db3:	8b 00                	mov    (%eax),%eax
80100db5:	89 04 24             	mov    %eax,(%esp)
80100db8:	e8 dd 44 00 00       	call   8010529a <strlen>
80100dbd:	83 c0 01             	add    $0x1,%eax
80100dc0:	89 c2                	mov    %eax,%edx
80100dc2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dc5:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100dcc:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dcf:	01 c8                	add    %ecx,%eax
80100dd1:	8b 00                	mov    (%eax),%eax
80100dd3:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100dd7:	89 44 24 08          	mov    %eax,0x8(%esp)
80100ddb:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dde:	89 44 24 04          	mov    %eax,0x4(%esp)
80100de2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100de5:	89 04 24             	mov    %eax,(%esp)
80100de8:	e8 c4 73 00 00       	call   801081b1 <copyout>
80100ded:	85 c0                	test   %eax,%eax
80100def:	79 05                	jns    80100df6 <exec+0x2d8>
      goto bad;
80100df1:	e9 45 01 00 00       	jmp    80100f3b <exec+0x41d>
    ustack[3+argc] = sp;
80100df6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100df9:	8d 50 03             	lea    0x3(%eax),%edx
80100dfc:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dff:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100e06:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e0a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e0d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e14:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e17:	01 d0                	add    %edx,%eax
80100e19:	8b 00                	mov    (%eax),%eax
80100e1b:	85 c0                	test   %eax,%eax
80100e1d:	0f 85 4d ff ff ff    	jne    80100d70 <exec+0x252>
  }
  ustack[3+argc] = 0;
80100e23:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e26:	83 c0 03             	add    $0x3,%eax
80100e29:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100e30:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100e34:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100e3b:	ff ff ff 
  ustack[1] = argc;
80100e3e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e41:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e4a:	83 c0 01             	add    $0x1,%eax
80100e4d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e54:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e57:	29 d0                	sub    %edx,%eax
80100e59:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100e5f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e62:	83 c0 04             	add    $0x4,%eax
80100e65:	c1 e0 02             	shl    $0x2,%eax
80100e68:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e6b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e6e:	83 c0 04             	add    $0x4,%eax
80100e71:	c1 e0 02             	shl    $0x2,%eax
80100e74:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100e78:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100e7e:	89 44 24 08          	mov    %eax,0x8(%esp)
80100e82:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e85:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e89:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100e8c:	89 04 24             	mov    %eax,(%esp)
80100e8f:	e8 1d 73 00 00       	call   801081b1 <copyout>
80100e94:	85 c0                	test   %eax,%eax
80100e96:	79 05                	jns    80100e9d <exec+0x37f>
    goto bad;
80100e98:	e9 9e 00 00 00       	jmp    80100f3b <exec+0x41d>

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e9d:	8b 45 08             	mov    0x8(%ebp),%eax
80100ea0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100ea3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ea6:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100ea9:	eb 17                	jmp    80100ec2 <exec+0x3a4>
    if(*s == '/')
80100eab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100eae:	0f b6 00             	movzbl (%eax),%eax
80100eb1:	3c 2f                	cmp    $0x2f,%al
80100eb3:	75 09                	jne    80100ebe <exec+0x3a0>
      last = s+1;
80100eb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100eb8:	83 c0 01             	add    $0x1,%eax
80100ebb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100ebe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100ec2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ec5:	0f b6 00             	movzbl (%eax),%eax
80100ec8:	84 c0                	test   %al,%al
80100eca:	75 df                	jne    80100eab <exec+0x38d>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100ecc:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100ecf:	8d 50 6c             	lea    0x6c(%eax),%edx
80100ed2:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80100ed9:	00 
80100eda:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100edd:	89 44 24 04          	mov    %eax,0x4(%esp)
80100ee1:	89 14 24             	mov    %edx,(%esp)
80100ee4:	e8 67 43 00 00       	call   80105250 <safestrcpy>

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100ee9:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100eec:	8b 40 04             	mov    0x4(%eax),%eax
80100eef:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100ef2:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100ef5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100ef8:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100efb:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100efe:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f01:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100f03:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f06:	8b 40 18             	mov    0x18(%eax),%eax
80100f09:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100f0f:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100f12:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f15:	8b 40 18             	mov    0x18(%eax),%eax
80100f18:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f1b:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100f1e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f21:	89 04 24             	mov    %eax,(%esp)
80100f24:	e8 56 6b 00 00       	call   80107a7f <switchuvm>
  freevm(oldpgdir);
80100f29:	8b 45 cc             	mov    -0x34(%ebp),%eax
80100f2c:	89 04 24             	mov    %eax,(%esp)
80100f2f:	e8 23 70 00 00       	call   80107f57 <freevm>
  return 0;
80100f34:	b8 00 00 00 00       	mov    $0x0,%eax
80100f39:	eb 2c                	jmp    80100f67 <exec+0x449>

 bad:
  if(pgdir)
80100f3b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f3f:	74 0b                	je     80100f4c <exec+0x42e>
    freevm(pgdir);
80100f41:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100f44:	89 04 24             	mov    %eax,(%esp)
80100f47:	e8 0b 70 00 00       	call   80107f57 <freevm>
  if(ip){
80100f4c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f50:	74 10                	je     80100f62 <exec+0x444>
    iunlockput(ip);
80100f52:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100f55:	89 04 24             	mov    %eax,(%esp)
80100f58:	e8 02 0c 00 00       	call   80101b5f <iunlockput>
    end_op();
80100f5d:	e8 a9 25 00 00       	call   8010350b <end_op>
  }
  return -1;
80100f62:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100f67:	c9                   	leave  
80100f68:	c3                   	ret    

80100f69 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f69:	55                   	push   %ebp
80100f6a:	89 e5                	mov    %esp,%ebp
80100f6c:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
80100f6f:	c7 44 24 04 da 82 10 	movl   $0x801082da,0x4(%esp)
80100f76:	80 
80100f77:	c7 04 24 40 10 11 80 	movl   $0x80111040,(%esp)
80100f7e:	e8 1a 3e 00 00       	call   80104d9d <initlock>
}
80100f83:	c9                   	leave  
80100f84:	c3                   	ret    

80100f85 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f85:	55                   	push   %ebp
80100f86:	89 e5                	mov    %esp,%ebp
80100f88:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
80100f8b:	c7 04 24 40 10 11 80 	movl   $0x80111040,(%esp)
80100f92:	e8 27 3e 00 00       	call   80104dbe <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f97:	c7 45 f4 74 10 11 80 	movl   $0x80111074,-0xc(%ebp)
80100f9e:	eb 29                	jmp    80100fc9 <filealloc+0x44>
    if(f->ref == 0){
80100fa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fa3:	8b 40 04             	mov    0x4(%eax),%eax
80100fa6:	85 c0                	test   %eax,%eax
80100fa8:	75 1b                	jne    80100fc5 <filealloc+0x40>
      f->ref = 1;
80100faa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fad:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100fb4:	c7 04 24 40 10 11 80 	movl   $0x80111040,(%esp)
80100fbb:	e8 66 3e 00 00       	call   80104e26 <release>
      return f;
80100fc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fc3:	eb 1e                	jmp    80100fe3 <filealloc+0x5e>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100fc5:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100fc9:	81 7d f4 d4 19 11 80 	cmpl   $0x801119d4,-0xc(%ebp)
80100fd0:	72 ce                	jb     80100fa0 <filealloc+0x1b>
    }
  }
  release(&ftable.lock);
80100fd2:	c7 04 24 40 10 11 80 	movl   $0x80111040,(%esp)
80100fd9:	e8 48 3e 00 00       	call   80104e26 <release>
  return 0;
80100fde:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100fe3:	c9                   	leave  
80100fe4:	c3                   	ret    

80100fe5 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100fe5:	55                   	push   %ebp
80100fe6:	89 e5                	mov    %esp,%ebp
80100fe8:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
80100feb:	c7 04 24 40 10 11 80 	movl   $0x80111040,(%esp)
80100ff2:	e8 c7 3d 00 00       	call   80104dbe <acquire>
  if(f->ref < 1)
80100ff7:	8b 45 08             	mov    0x8(%ebp),%eax
80100ffa:	8b 40 04             	mov    0x4(%eax),%eax
80100ffd:	85 c0                	test   %eax,%eax
80100fff:	7f 0c                	jg     8010100d <filedup+0x28>
    panic("filedup");
80101001:	c7 04 24 e1 82 10 80 	movl   $0x801082e1,(%esp)
80101008:	e8 55 f5 ff ff       	call   80100562 <panic>
  f->ref++;
8010100d:	8b 45 08             	mov    0x8(%ebp),%eax
80101010:	8b 40 04             	mov    0x4(%eax),%eax
80101013:	8d 50 01             	lea    0x1(%eax),%edx
80101016:	8b 45 08             	mov    0x8(%ebp),%eax
80101019:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
8010101c:	c7 04 24 40 10 11 80 	movl   $0x80111040,(%esp)
80101023:	e8 fe 3d 00 00       	call   80104e26 <release>
  return f;
80101028:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010102b:	c9                   	leave  
8010102c:	c3                   	ret    

8010102d <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
8010102d:	55                   	push   %ebp
8010102e:	89 e5                	mov    %esp,%ebp
80101030:	83 ec 38             	sub    $0x38,%esp
  struct file ff;

  acquire(&ftable.lock);
80101033:	c7 04 24 40 10 11 80 	movl   $0x80111040,(%esp)
8010103a:	e8 7f 3d 00 00       	call   80104dbe <acquire>
  if(f->ref < 1)
8010103f:	8b 45 08             	mov    0x8(%ebp),%eax
80101042:	8b 40 04             	mov    0x4(%eax),%eax
80101045:	85 c0                	test   %eax,%eax
80101047:	7f 0c                	jg     80101055 <fileclose+0x28>
    panic("fileclose");
80101049:	c7 04 24 e9 82 10 80 	movl   $0x801082e9,(%esp)
80101050:	e8 0d f5 ff ff       	call   80100562 <panic>
  if(--f->ref > 0){
80101055:	8b 45 08             	mov    0x8(%ebp),%eax
80101058:	8b 40 04             	mov    0x4(%eax),%eax
8010105b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010105e:	8b 45 08             	mov    0x8(%ebp),%eax
80101061:	89 50 04             	mov    %edx,0x4(%eax)
80101064:	8b 45 08             	mov    0x8(%ebp),%eax
80101067:	8b 40 04             	mov    0x4(%eax),%eax
8010106a:	85 c0                	test   %eax,%eax
8010106c:	7e 11                	jle    8010107f <fileclose+0x52>
    release(&ftable.lock);
8010106e:	c7 04 24 40 10 11 80 	movl   $0x80111040,(%esp)
80101075:	e8 ac 3d 00 00       	call   80104e26 <release>
8010107a:	e9 82 00 00 00       	jmp    80101101 <fileclose+0xd4>
    return;
  }
  ff = *f;
8010107f:	8b 45 08             	mov    0x8(%ebp),%eax
80101082:	8b 10                	mov    (%eax),%edx
80101084:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101087:	8b 50 04             	mov    0x4(%eax),%edx
8010108a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010108d:	8b 50 08             	mov    0x8(%eax),%edx
80101090:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101093:	8b 50 0c             	mov    0xc(%eax),%edx
80101096:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101099:	8b 50 10             	mov    0x10(%eax),%edx
8010109c:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010109f:	8b 40 14             	mov    0x14(%eax),%eax
801010a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
801010a5:	8b 45 08             	mov    0x8(%ebp),%eax
801010a8:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
801010af:	8b 45 08             	mov    0x8(%ebp),%eax
801010b2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
801010b8:	c7 04 24 40 10 11 80 	movl   $0x80111040,(%esp)
801010bf:	e8 62 3d 00 00       	call   80104e26 <release>

  if(ff.type == FD_PIPE)
801010c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010c7:	83 f8 01             	cmp    $0x1,%eax
801010ca:	75 18                	jne    801010e4 <fileclose+0xb7>
    pipeclose(ff.pipe, ff.writable);
801010cc:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
801010d0:	0f be d0             	movsbl %al,%edx
801010d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801010d6:	89 54 24 04          	mov    %edx,0x4(%esp)
801010da:	89 04 24             	mov    %eax,(%esp)
801010dd:	e8 46 2d 00 00       	call   80103e28 <pipeclose>
801010e2:	eb 1d                	jmp    80101101 <fileclose+0xd4>
  else if(ff.type == FD_INODE){
801010e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010e7:	83 f8 02             	cmp    $0x2,%eax
801010ea:	75 15                	jne    80101101 <fileclose+0xd4>
    begin_op();
801010ec:	e8 96 23 00 00       	call   80103487 <begin_op>
    iput(ff.ip);
801010f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801010f4:	89 04 24             	mov    %eax,(%esp)
801010f7:	e8 b2 09 00 00       	call   80101aae <iput>
    end_op();
801010fc:	e8 0a 24 00 00       	call   8010350b <end_op>
  }
}
80101101:	c9                   	leave  
80101102:	c3                   	ret    

80101103 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101103:	55                   	push   %ebp
80101104:	89 e5                	mov    %esp,%ebp
80101106:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
80101109:	8b 45 08             	mov    0x8(%ebp),%eax
8010110c:	8b 00                	mov    (%eax),%eax
8010110e:	83 f8 02             	cmp    $0x2,%eax
80101111:	75 38                	jne    8010114b <filestat+0x48>
    ilock(f->ip);
80101113:	8b 45 08             	mov    0x8(%ebp),%eax
80101116:	8b 40 10             	mov    0x10(%eax),%eax
80101119:	89 04 24             	mov    %eax,(%esp)
8010111c:	e8 3c 08 00 00       	call   8010195d <ilock>
    stati(f->ip, st);
80101121:	8b 45 08             	mov    0x8(%ebp),%eax
80101124:	8b 40 10             	mov    0x10(%eax),%eax
80101127:	8b 55 0c             	mov    0xc(%ebp),%edx
8010112a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010112e:	89 04 24             	mov    %eax,(%esp)
80101131:	e8 7f 0c 00 00       	call   80101db5 <stati>
    iunlock(f->ip);
80101136:	8b 45 08             	mov    0x8(%ebp),%eax
80101139:	8b 40 10             	mov    0x10(%eax),%eax
8010113c:	89 04 24             	mov    %eax,(%esp)
8010113f:	e8 26 09 00 00       	call   80101a6a <iunlock>
    return 0;
80101144:	b8 00 00 00 00       	mov    $0x0,%eax
80101149:	eb 05                	jmp    80101150 <filestat+0x4d>
  }
  return -1;
8010114b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101150:	c9                   	leave  
80101151:	c3                   	ret    

80101152 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101152:	55                   	push   %ebp
80101153:	89 e5                	mov    %esp,%ebp
80101155:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
80101158:	8b 45 08             	mov    0x8(%ebp),%eax
8010115b:	0f b6 40 08          	movzbl 0x8(%eax),%eax
8010115f:	84 c0                	test   %al,%al
80101161:	75 0a                	jne    8010116d <fileread+0x1b>
    return -1;
80101163:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101168:	e9 9f 00 00 00       	jmp    8010120c <fileread+0xba>
  if(f->type == FD_PIPE)
8010116d:	8b 45 08             	mov    0x8(%ebp),%eax
80101170:	8b 00                	mov    (%eax),%eax
80101172:	83 f8 01             	cmp    $0x1,%eax
80101175:	75 1e                	jne    80101195 <fileread+0x43>
    return piperead(f->pipe, addr, n);
80101177:	8b 45 08             	mov    0x8(%ebp),%eax
8010117a:	8b 40 0c             	mov    0xc(%eax),%eax
8010117d:	8b 55 10             	mov    0x10(%ebp),%edx
80101180:	89 54 24 08          	mov    %edx,0x8(%esp)
80101184:	8b 55 0c             	mov    0xc(%ebp),%edx
80101187:	89 54 24 04          	mov    %edx,0x4(%esp)
8010118b:	89 04 24             	mov    %eax,(%esp)
8010118e:	e8 15 2e 00 00       	call   80103fa8 <piperead>
80101193:	eb 77                	jmp    8010120c <fileread+0xba>
  if(f->type == FD_INODE){
80101195:	8b 45 08             	mov    0x8(%ebp),%eax
80101198:	8b 00                	mov    (%eax),%eax
8010119a:	83 f8 02             	cmp    $0x2,%eax
8010119d:	75 61                	jne    80101200 <fileread+0xae>
    ilock(f->ip);
8010119f:	8b 45 08             	mov    0x8(%ebp),%eax
801011a2:	8b 40 10             	mov    0x10(%eax),%eax
801011a5:	89 04 24             	mov    %eax,(%esp)
801011a8:	e8 b0 07 00 00       	call   8010195d <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
801011ad:	8b 4d 10             	mov    0x10(%ebp),%ecx
801011b0:	8b 45 08             	mov    0x8(%ebp),%eax
801011b3:	8b 50 14             	mov    0x14(%eax),%edx
801011b6:	8b 45 08             	mov    0x8(%ebp),%eax
801011b9:	8b 40 10             	mov    0x10(%eax),%eax
801011bc:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801011c0:	89 54 24 08          	mov    %edx,0x8(%esp)
801011c4:	8b 55 0c             	mov    0xc(%ebp),%edx
801011c7:	89 54 24 04          	mov    %edx,0x4(%esp)
801011cb:	89 04 24             	mov    %eax,(%esp)
801011ce:	e8 27 0c 00 00       	call   80101dfa <readi>
801011d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801011d6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801011da:	7e 11                	jle    801011ed <fileread+0x9b>
      f->off += r;
801011dc:	8b 45 08             	mov    0x8(%ebp),%eax
801011df:	8b 50 14             	mov    0x14(%eax),%edx
801011e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011e5:	01 c2                	add    %eax,%edx
801011e7:	8b 45 08             	mov    0x8(%ebp),%eax
801011ea:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801011ed:	8b 45 08             	mov    0x8(%ebp),%eax
801011f0:	8b 40 10             	mov    0x10(%eax),%eax
801011f3:	89 04 24             	mov    %eax,(%esp)
801011f6:	e8 6f 08 00 00       	call   80101a6a <iunlock>
    return r;
801011fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011fe:	eb 0c                	jmp    8010120c <fileread+0xba>
  }
  panic("fileread");
80101200:	c7 04 24 f3 82 10 80 	movl   $0x801082f3,(%esp)
80101207:	e8 56 f3 ff ff       	call   80100562 <panic>
}
8010120c:	c9                   	leave  
8010120d:	c3                   	ret    

8010120e <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
8010120e:	55                   	push   %ebp
8010120f:	89 e5                	mov    %esp,%ebp
80101211:	53                   	push   %ebx
80101212:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
80101215:	8b 45 08             	mov    0x8(%ebp),%eax
80101218:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010121c:	84 c0                	test   %al,%al
8010121e:	75 0a                	jne    8010122a <filewrite+0x1c>
    return -1;
80101220:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101225:	e9 20 01 00 00       	jmp    8010134a <filewrite+0x13c>
  if(f->type == FD_PIPE)
8010122a:	8b 45 08             	mov    0x8(%ebp),%eax
8010122d:	8b 00                	mov    (%eax),%eax
8010122f:	83 f8 01             	cmp    $0x1,%eax
80101232:	75 21                	jne    80101255 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
80101234:	8b 45 08             	mov    0x8(%ebp),%eax
80101237:	8b 40 0c             	mov    0xc(%eax),%eax
8010123a:	8b 55 10             	mov    0x10(%ebp),%edx
8010123d:	89 54 24 08          	mov    %edx,0x8(%esp)
80101241:	8b 55 0c             	mov    0xc(%ebp),%edx
80101244:	89 54 24 04          	mov    %edx,0x4(%esp)
80101248:	89 04 24             	mov    %eax,(%esp)
8010124b:	e8 6a 2c 00 00       	call   80103eba <pipewrite>
80101250:	e9 f5 00 00 00       	jmp    8010134a <filewrite+0x13c>
  if(f->type == FD_INODE){
80101255:	8b 45 08             	mov    0x8(%ebp),%eax
80101258:	8b 00                	mov    (%eax),%eax
8010125a:	83 f8 02             	cmp    $0x2,%eax
8010125d:	0f 85 db 00 00 00    	jne    8010133e <filewrite+0x130>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
80101263:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
8010126a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101271:	e9 a8 00 00 00       	jmp    8010131e <filewrite+0x110>
      int n1 = n - i;
80101276:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101279:	8b 55 10             	mov    0x10(%ebp),%edx
8010127c:	29 c2                	sub    %eax,%edx
8010127e:	89 d0                	mov    %edx,%eax
80101280:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101283:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101286:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101289:	7e 06                	jle    80101291 <filewrite+0x83>
        n1 = max;
8010128b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010128e:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101291:	e8 f1 21 00 00       	call   80103487 <begin_op>
      ilock(f->ip);
80101296:	8b 45 08             	mov    0x8(%ebp),%eax
80101299:	8b 40 10             	mov    0x10(%eax),%eax
8010129c:	89 04 24             	mov    %eax,(%esp)
8010129f:	e8 b9 06 00 00       	call   8010195d <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
801012a4:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801012a7:	8b 45 08             	mov    0x8(%ebp),%eax
801012aa:	8b 50 14             	mov    0x14(%eax),%edx
801012ad:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801012b0:	8b 45 0c             	mov    0xc(%ebp),%eax
801012b3:	01 c3                	add    %eax,%ebx
801012b5:	8b 45 08             	mov    0x8(%ebp),%eax
801012b8:	8b 40 10             	mov    0x10(%eax),%eax
801012bb:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801012bf:	89 54 24 08          	mov    %edx,0x8(%esp)
801012c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
801012c7:	89 04 24             	mov    %eax,(%esp)
801012ca:	e8 8f 0c 00 00       	call   80101f5e <writei>
801012cf:	89 45 e8             	mov    %eax,-0x18(%ebp)
801012d2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801012d6:	7e 11                	jle    801012e9 <filewrite+0xdb>
        f->off += r;
801012d8:	8b 45 08             	mov    0x8(%ebp),%eax
801012db:	8b 50 14             	mov    0x14(%eax),%edx
801012de:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012e1:	01 c2                	add    %eax,%edx
801012e3:	8b 45 08             	mov    0x8(%ebp),%eax
801012e6:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801012e9:	8b 45 08             	mov    0x8(%ebp),%eax
801012ec:	8b 40 10             	mov    0x10(%eax),%eax
801012ef:	89 04 24             	mov    %eax,(%esp)
801012f2:	e8 73 07 00 00       	call   80101a6a <iunlock>
      end_op();
801012f7:	e8 0f 22 00 00       	call   8010350b <end_op>

      if(r < 0)
801012fc:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101300:	79 02                	jns    80101304 <filewrite+0xf6>
        break;
80101302:	eb 26                	jmp    8010132a <filewrite+0x11c>
      if(r != n1)
80101304:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101307:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010130a:	74 0c                	je     80101318 <filewrite+0x10a>
        panic("short filewrite");
8010130c:	c7 04 24 fc 82 10 80 	movl   $0x801082fc,(%esp)
80101313:	e8 4a f2 ff ff       	call   80100562 <panic>
      i += r;
80101318:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010131b:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
8010131e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101321:	3b 45 10             	cmp    0x10(%ebp),%eax
80101324:	0f 8c 4c ff ff ff    	jl     80101276 <filewrite+0x68>
    }
    return i == n ? n : -1;
8010132a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010132d:	3b 45 10             	cmp    0x10(%ebp),%eax
80101330:	75 05                	jne    80101337 <filewrite+0x129>
80101332:	8b 45 10             	mov    0x10(%ebp),%eax
80101335:	eb 05                	jmp    8010133c <filewrite+0x12e>
80101337:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010133c:	eb 0c                	jmp    8010134a <filewrite+0x13c>
  }
  panic("filewrite");
8010133e:	c7 04 24 0c 83 10 80 	movl   $0x8010830c,(%esp)
80101345:	e8 18 f2 ff ff       	call   80100562 <panic>
}
8010134a:	83 c4 24             	add    $0x24,%esp
8010134d:	5b                   	pop    %ebx
8010134e:	5d                   	pop    %ebp
8010134f:	c3                   	ret    

80101350 <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101350:	55                   	push   %ebp
80101351:	89 e5                	mov    %esp,%ebp
80101353:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;

  bp = bread(dev, 1);
80101356:	8b 45 08             	mov    0x8(%ebp),%eax
80101359:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80101360:	00 
80101361:	89 04 24             	mov    %eax,(%esp)
80101364:	e8 4c ee ff ff       	call   801001b5 <bread>
80101369:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
8010136c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010136f:	83 c0 5c             	add    $0x5c,%eax
80101372:	c7 44 24 08 1c 00 00 	movl   $0x1c,0x8(%esp)
80101379:	00 
8010137a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010137e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101381:	89 04 24             	mov    %eax,(%esp)
80101384:	e8 76 3d 00 00       	call   801050ff <memmove>
  brelse(bp);
80101389:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010138c:	89 04 24             	mov    %eax,(%esp)
8010138f:	e8 98 ee ff ff       	call   8010022c <brelse>
}
80101394:	c9                   	leave  
80101395:	c3                   	ret    

80101396 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101396:	55                   	push   %ebp
80101397:	89 e5                	mov    %esp,%ebp
80101399:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;

  bp = bread(dev, bno);
8010139c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010139f:	8b 45 08             	mov    0x8(%ebp),%eax
801013a2:	89 54 24 04          	mov    %edx,0x4(%esp)
801013a6:	89 04 24             	mov    %eax,(%esp)
801013a9:	e8 07 ee ff ff       	call   801001b5 <bread>
801013ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
801013b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013b4:	83 c0 5c             	add    $0x5c,%eax
801013b7:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801013be:	00 
801013bf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801013c6:	00 
801013c7:	89 04 24             	mov    %eax,(%esp)
801013ca:	e8 61 3c 00 00       	call   80105030 <memset>
  log_write(bp);
801013cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013d2:	89 04 24             	mov    %eax,(%esp)
801013d5:	e8 b8 22 00 00       	call   80103692 <log_write>
  brelse(bp);
801013da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013dd:	89 04 24             	mov    %eax,(%esp)
801013e0:	e8 47 ee ff ff       	call   8010022c <brelse>
}
801013e5:	c9                   	leave  
801013e6:	c3                   	ret    

801013e7 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801013e7:	55                   	push   %ebp
801013e8:	89 e5                	mov    %esp,%ebp
801013ea:	83 ec 28             	sub    $0x28,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
801013ed:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
801013f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801013fb:	e9 07 01 00 00       	jmp    80101507 <balloc+0x120>
    bp = bread(dev, BBLOCK(b, sb));
80101400:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101403:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101409:	85 c0                	test   %eax,%eax
8010140b:	0f 48 c2             	cmovs  %edx,%eax
8010140e:	c1 f8 0c             	sar    $0xc,%eax
80101411:	89 c2                	mov    %eax,%edx
80101413:	a1 58 1a 11 80       	mov    0x80111a58,%eax
80101418:	01 d0                	add    %edx,%eax
8010141a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010141e:	8b 45 08             	mov    0x8(%ebp),%eax
80101421:	89 04 24             	mov    %eax,(%esp)
80101424:	e8 8c ed ff ff       	call   801001b5 <bread>
80101429:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010142c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101433:	e9 9d 00 00 00       	jmp    801014d5 <balloc+0xee>
      m = 1 << (bi % 8);
80101438:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010143b:	99                   	cltd   
8010143c:	c1 ea 1d             	shr    $0x1d,%edx
8010143f:	01 d0                	add    %edx,%eax
80101441:	83 e0 07             	and    $0x7,%eax
80101444:	29 d0                	sub    %edx,%eax
80101446:	ba 01 00 00 00       	mov    $0x1,%edx
8010144b:	89 c1                	mov    %eax,%ecx
8010144d:	d3 e2                	shl    %cl,%edx
8010144f:	89 d0                	mov    %edx,%eax
80101451:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101454:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101457:	8d 50 07             	lea    0x7(%eax),%edx
8010145a:	85 c0                	test   %eax,%eax
8010145c:	0f 48 c2             	cmovs  %edx,%eax
8010145f:	c1 f8 03             	sar    $0x3,%eax
80101462:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101465:	0f b6 44 02 5c       	movzbl 0x5c(%edx,%eax,1),%eax
8010146a:	0f b6 c0             	movzbl %al,%eax
8010146d:	23 45 e8             	and    -0x18(%ebp),%eax
80101470:	85 c0                	test   %eax,%eax
80101472:	75 5d                	jne    801014d1 <balloc+0xea>
        bp->data[bi/8] |= m;  // Mark block in use.
80101474:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101477:	8d 50 07             	lea    0x7(%eax),%edx
8010147a:	85 c0                	test   %eax,%eax
8010147c:	0f 48 c2             	cmovs  %edx,%eax
8010147f:	c1 f8 03             	sar    $0x3,%eax
80101482:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101485:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
8010148a:	89 d1                	mov    %edx,%ecx
8010148c:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010148f:	09 ca                	or     %ecx,%edx
80101491:	89 d1                	mov    %edx,%ecx
80101493:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101496:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
8010149a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010149d:	89 04 24             	mov    %eax,(%esp)
801014a0:	e8 ed 21 00 00       	call   80103692 <log_write>
        brelse(bp);
801014a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014a8:	89 04 24             	mov    %eax,(%esp)
801014ab:	e8 7c ed ff ff       	call   8010022c <brelse>
        bzero(dev, b + bi);
801014b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014b6:	01 c2                	add    %eax,%edx
801014b8:	8b 45 08             	mov    0x8(%ebp),%eax
801014bb:	89 54 24 04          	mov    %edx,0x4(%esp)
801014bf:	89 04 24             	mov    %eax,(%esp)
801014c2:	e8 cf fe ff ff       	call   80101396 <bzero>
        return b + bi;
801014c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014cd:	01 d0                	add    %edx,%eax
801014cf:	eb 52                	jmp    80101523 <balloc+0x13c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014d1:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801014d5:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801014dc:	7f 17                	jg     801014f5 <balloc+0x10e>
801014de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014e4:	01 d0                	add    %edx,%eax
801014e6:	89 c2                	mov    %eax,%edx
801014e8:	a1 40 1a 11 80       	mov    0x80111a40,%eax
801014ed:	39 c2                	cmp    %eax,%edx
801014ef:	0f 82 43 ff ff ff    	jb     80101438 <balloc+0x51>
      }
    }
    brelse(bp);
801014f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014f8:	89 04 24             	mov    %eax,(%esp)
801014fb:	e8 2c ed ff ff       	call   8010022c <brelse>
  for(b = 0; b < sb.size; b += BPB){
80101500:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101507:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010150a:	a1 40 1a 11 80       	mov    0x80111a40,%eax
8010150f:	39 c2                	cmp    %eax,%edx
80101511:	0f 82 e9 fe ff ff    	jb     80101400 <balloc+0x19>
  }
  panic("balloc: out of blocks");
80101517:	c7 04 24 18 83 10 80 	movl   $0x80108318,(%esp)
8010151e:	e8 3f f0 ff ff       	call   80100562 <panic>
}
80101523:	c9                   	leave  
80101524:	c3                   	ret    

80101525 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101525:	55                   	push   %ebp
80101526:	89 e5                	mov    %esp,%ebp
80101528:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
8010152b:	c7 44 24 04 40 1a 11 	movl   $0x80111a40,0x4(%esp)
80101532:	80 
80101533:	8b 45 08             	mov    0x8(%ebp),%eax
80101536:	89 04 24             	mov    %eax,(%esp)
80101539:	e8 12 fe ff ff       	call   80101350 <readsb>
  bp = bread(dev, BBLOCK(b, sb));
8010153e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101541:	c1 e8 0c             	shr    $0xc,%eax
80101544:	89 c2                	mov    %eax,%edx
80101546:	a1 58 1a 11 80       	mov    0x80111a58,%eax
8010154b:	01 c2                	add    %eax,%edx
8010154d:	8b 45 08             	mov    0x8(%ebp),%eax
80101550:	89 54 24 04          	mov    %edx,0x4(%esp)
80101554:	89 04 24             	mov    %eax,(%esp)
80101557:	e8 59 ec ff ff       	call   801001b5 <bread>
8010155c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
8010155f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101562:	25 ff 0f 00 00       	and    $0xfff,%eax
80101567:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
8010156a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010156d:	99                   	cltd   
8010156e:	c1 ea 1d             	shr    $0x1d,%edx
80101571:	01 d0                	add    %edx,%eax
80101573:	83 e0 07             	and    $0x7,%eax
80101576:	29 d0                	sub    %edx,%eax
80101578:	ba 01 00 00 00       	mov    $0x1,%edx
8010157d:	89 c1                	mov    %eax,%ecx
8010157f:	d3 e2                	shl    %cl,%edx
80101581:	89 d0                	mov    %edx,%eax
80101583:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101586:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101589:	8d 50 07             	lea    0x7(%eax),%edx
8010158c:	85 c0                	test   %eax,%eax
8010158e:	0f 48 c2             	cmovs  %edx,%eax
80101591:	c1 f8 03             	sar    $0x3,%eax
80101594:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101597:	0f b6 44 02 5c       	movzbl 0x5c(%edx,%eax,1),%eax
8010159c:	0f b6 c0             	movzbl %al,%eax
8010159f:	23 45 ec             	and    -0x14(%ebp),%eax
801015a2:	85 c0                	test   %eax,%eax
801015a4:	75 0c                	jne    801015b2 <bfree+0x8d>
    panic("freeing free block");
801015a6:	c7 04 24 2e 83 10 80 	movl   $0x8010832e,(%esp)
801015ad:	e8 b0 ef ff ff       	call   80100562 <panic>
  bp->data[bi/8] &= ~m;
801015b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015b5:	8d 50 07             	lea    0x7(%eax),%edx
801015b8:	85 c0                	test   %eax,%eax
801015ba:	0f 48 c2             	cmovs  %edx,%eax
801015bd:	c1 f8 03             	sar    $0x3,%eax
801015c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015c3:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
801015c8:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801015cb:	f7 d1                	not    %ecx
801015cd:	21 ca                	and    %ecx,%edx
801015cf:	89 d1                	mov    %edx,%ecx
801015d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015d4:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
801015d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015db:	89 04 24             	mov    %eax,(%esp)
801015de:	e8 af 20 00 00       	call   80103692 <log_write>
  brelse(bp);
801015e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015e6:	89 04 24             	mov    %eax,(%esp)
801015e9:	e8 3e ec ff ff       	call   8010022c <brelse>
}
801015ee:	c9                   	leave  
801015ef:	c3                   	ret    

801015f0 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
801015f0:	55                   	push   %ebp
801015f1:	89 e5                	mov    %esp,%ebp
801015f3:	57                   	push   %edi
801015f4:	56                   	push   %esi
801015f5:	53                   	push   %ebx
801015f6:	83 ec 4c             	sub    $0x4c,%esp
  int i = 0;
801015f9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
80101600:	c7 44 24 04 41 83 10 	movl   $0x80108341,0x4(%esp)
80101607:	80 
80101608:	c7 04 24 60 1a 11 80 	movl   $0x80111a60,(%esp)
8010160f:	e8 89 37 00 00       	call   80104d9d <initlock>
  for(i = 0; i < NINODE; i++) {
80101614:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010161b:	eb 2c                	jmp    80101649 <iinit+0x59>
    initsleeplock(&icache.inode[i].lock, "inode");
8010161d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101620:	89 d0                	mov    %edx,%eax
80101622:	c1 e0 03             	shl    $0x3,%eax
80101625:	01 d0                	add    %edx,%eax
80101627:	c1 e0 04             	shl    $0x4,%eax
8010162a:	83 c0 30             	add    $0x30,%eax
8010162d:	05 60 1a 11 80       	add    $0x80111a60,%eax
80101632:	83 c0 10             	add    $0x10,%eax
80101635:	c7 44 24 04 48 83 10 	movl   $0x80108348,0x4(%esp)
8010163c:	80 
8010163d:	89 04 24             	mov    %eax,(%esp)
80101640:	e8 f5 35 00 00       	call   80104c3a <initsleeplock>
  for(i = 0; i < NINODE; i++) {
80101645:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80101649:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
8010164d:	7e ce                	jle    8010161d <iinit+0x2d>
  }

  readsb(dev, &sb);
8010164f:	c7 44 24 04 40 1a 11 	movl   $0x80111a40,0x4(%esp)
80101656:	80 
80101657:	8b 45 08             	mov    0x8(%ebp),%eax
8010165a:	89 04 24             	mov    %eax,(%esp)
8010165d:	e8 ee fc ff ff       	call   80101350 <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
80101662:	a1 58 1a 11 80       	mov    0x80111a58,%eax
80101667:	8b 3d 54 1a 11 80    	mov    0x80111a54,%edi
8010166d:	8b 35 50 1a 11 80    	mov    0x80111a50,%esi
80101673:	8b 1d 4c 1a 11 80    	mov    0x80111a4c,%ebx
80101679:	8b 0d 48 1a 11 80    	mov    0x80111a48,%ecx
8010167f:	8b 15 44 1a 11 80    	mov    0x80111a44,%edx
80101685:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80101688:	8b 15 40 1a 11 80    	mov    0x80111a40,%edx
8010168e:	89 44 24 1c          	mov    %eax,0x1c(%esp)
80101692:	89 7c 24 18          	mov    %edi,0x18(%esp)
80101696:	89 74 24 14          	mov    %esi,0x14(%esp)
8010169a:	89 5c 24 10          	mov    %ebx,0x10(%esp)
8010169e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801016a2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801016a5:	89 44 24 08          	mov    %eax,0x8(%esp)
801016a9:	89 d0                	mov    %edx,%eax
801016ab:	89 44 24 04          	mov    %eax,0x4(%esp)
801016af:	c7 04 24 50 83 10 80 	movl   $0x80108350,(%esp)
801016b6:	e8 0d ed ff ff       	call   801003c8 <cprintf>
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
801016bb:	83 c4 4c             	add    $0x4c,%esp
801016be:	5b                   	pop    %ebx
801016bf:	5e                   	pop    %esi
801016c0:	5f                   	pop    %edi
801016c1:	5d                   	pop    %ebp
801016c2:	c3                   	ret    

801016c3 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
801016c3:	55                   	push   %ebp
801016c4:	89 e5                	mov    %esp,%ebp
801016c6:	83 ec 28             	sub    $0x28,%esp
801016c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801016cc:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801016d0:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801016d7:	e9 9e 00 00 00       	jmp    8010177a <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
801016dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016df:	c1 e8 03             	shr    $0x3,%eax
801016e2:	89 c2                	mov    %eax,%edx
801016e4:	a1 54 1a 11 80       	mov    0x80111a54,%eax
801016e9:	01 d0                	add    %edx,%eax
801016eb:	89 44 24 04          	mov    %eax,0x4(%esp)
801016ef:	8b 45 08             	mov    0x8(%ebp),%eax
801016f2:	89 04 24             	mov    %eax,(%esp)
801016f5:	e8 bb ea ff ff       	call   801001b5 <bread>
801016fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801016fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101700:	8d 50 5c             	lea    0x5c(%eax),%edx
80101703:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101706:	83 e0 07             	and    $0x7,%eax
80101709:	c1 e0 06             	shl    $0x6,%eax
8010170c:	01 d0                	add    %edx,%eax
8010170e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101711:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101714:	0f b7 00             	movzwl (%eax),%eax
80101717:	66 85 c0             	test   %ax,%ax
8010171a:	75 4f                	jne    8010176b <ialloc+0xa8>
      memset(dip, 0, sizeof(*dip));
8010171c:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
80101723:	00 
80101724:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010172b:	00 
8010172c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010172f:	89 04 24             	mov    %eax,(%esp)
80101732:	e8 f9 38 00 00       	call   80105030 <memset>
      dip->type = type;
80101737:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010173a:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
8010173e:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101741:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101744:	89 04 24             	mov    %eax,(%esp)
80101747:	e8 46 1f 00 00       	call   80103692 <log_write>
      brelse(bp);
8010174c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010174f:	89 04 24             	mov    %eax,(%esp)
80101752:	e8 d5 ea ff ff       	call   8010022c <brelse>
      return iget(dev, inum);
80101757:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010175a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010175e:	8b 45 08             	mov    0x8(%ebp),%eax
80101761:	89 04 24             	mov    %eax,(%esp)
80101764:	e8 ed 00 00 00       	call   80101856 <iget>
80101769:	eb 2b                	jmp    80101796 <ialloc+0xd3>
    }
    brelse(bp);
8010176b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010176e:	89 04 24             	mov    %eax,(%esp)
80101771:	e8 b6 ea ff ff       	call   8010022c <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
80101776:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010177a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010177d:	a1 48 1a 11 80       	mov    0x80111a48,%eax
80101782:	39 c2                	cmp    %eax,%edx
80101784:	0f 82 52 ff ff ff    	jb     801016dc <ialloc+0x19>
  }
  panic("ialloc: no inodes");
8010178a:	c7 04 24 a3 83 10 80 	movl   $0x801083a3,(%esp)
80101791:	e8 cc ed ff ff       	call   80100562 <panic>
}
80101796:	c9                   	leave  
80101797:	c3                   	ret    

80101798 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
80101798:	55                   	push   %ebp
80101799:	89 e5                	mov    %esp,%ebp
8010179b:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010179e:	8b 45 08             	mov    0x8(%ebp),%eax
801017a1:	8b 40 04             	mov    0x4(%eax),%eax
801017a4:	c1 e8 03             	shr    $0x3,%eax
801017a7:	89 c2                	mov    %eax,%edx
801017a9:	a1 54 1a 11 80       	mov    0x80111a54,%eax
801017ae:	01 c2                	add    %eax,%edx
801017b0:	8b 45 08             	mov    0x8(%ebp),%eax
801017b3:	8b 00                	mov    (%eax),%eax
801017b5:	89 54 24 04          	mov    %edx,0x4(%esp)
801017b9:	89 04 24             	mov    %eax,(%esp)
801017bc:	e8 f4 e9 ff ff       	call   801001b5 <bread>
801017c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801017c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017c7:	8d 50 5c             	lea    0x5c(%eax),%edx
801017ca:	8b 45 08             	mov    0x8(%ebp),%eax
801017cd:	8b 40 04             	mov    0x4(%eax),%eax
801017d0:	83 e0 07             	and    $0x7,%eax
801017d3:	c1 e0 06             	shl    $0x6,%eax
801017d6:	01 d0                	add    %edx,%eax
801017d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801017db:	8b 45 08             	mov    0x8(%ebp),%eax
801017de:	0f b7 50 50          	movzwl 0x50(%eax),%edx
801017e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017e5:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801017e8:	8b 45 08             	mov    0x8(%ebp),%eax
801017eb:	0f b7 50 52          	movzwl 0x52(%eax),%edx
801017ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017f2:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
801017f6:	8b 45 08             	mov    0x8(%ebp),%eax
801017f9:	0f b7 50 54          	movzwl 0x54(%eax),%edx
801017fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101800:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101804:	8b 45 08             	mov    0x8(%ebp),%eax
80101807:	0f b7 50 56          	movzwl 0x56(%eax),%edx
8010180b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010180e:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101812:	8b 45 08             	mov    0x8(%ebp),%eax
80101815:	8b 50 58             	mov    0x58(%eax),%edx
80101818:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010181b:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010181e:	8b 45 08             	mov    0x8(%ebp),%eax
80101821:	8d 50 5c             	lea    0x5c(%eax),%edx
80101824:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101827:	83 c0 0c             	add    $0xc,%eax
8010182a:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101831:	00 
80101832:	89 54 24 04          	mov    %edx,0x4(%esp)
80101836:	89 04 24             	mov    %eax,(%esp)
80101839:	e8 c1 38 00 00       	call   801050ff <memmove>
  log_write(bp);
8010183e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101841:	89 04 24             	mov    %eax,(%esp)
80101844:	e8 49 1e 00 00       	call   80103692 <log_write>
  brelse(bp);
80101849:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010184c:	89 04 24             	mov    %eax,(%esp)
8010184f:	e8 d8 e9 ff ff       	call   8010022c <brelse>
}
80101854:	c9                   	leave  
80101855:	c3                   	ret    

80101856 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101856:	55                   	push   %ebp
80101857:	89 e5                	mov    %esp,%ebp
80101859:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
8010185c:	c7 04 24 60 1a 11 80 	movl   $0x80111a60,(%esp)
80101863:	e8 56 35 00 00       	call   80104dbe <acquire>

  // Is the inode already cached?
  empty = 0;
80101868:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010186f:	c7 45 f4 94 1a 11 80 	movl   $0x80111a94,-0xc(%ebp)
80101876:	eb 5c                	jmp    801018d4 <iget+0x7e>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101878:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010187b:	8b 40 08             	mov    0x8(%eax),%eax
8010187e:	85 c0                	test   %eax,%eax
80101880:	7e 35                	jle    801018b7 <iget+0x61>
80101882:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101885:	8b 00                	mov    (%eax),%eax
80101887:	3b 45 08             	cmp    0x8(%ebp),%eax
8010188a:	75 2b                	jne    801018b7 <iget+0x61>
8010188c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010188f:	8b 40 04             	mov    0x4(%eax),%eax
80101892:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101895:	75 20                	jne    801018b7 <iget+0x61>
      ip->ref++;
80101897:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010189a:	8b 40 08             	mov    0x8(%eax),%eax
8010189d:	8d 50 01             	lea    0x1(%eax),%edx
801018a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018a3:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
801018a6:	c7 04 24 60 1a 11 80 	movl   $0x80111a60,(%esp)
801018ad:	e8 74 35 00 00       	call   80104e26 <release>
      return ip;
801018b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018b5:	eb 72                	jmp    80101929 <iget+0xd3>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801018b7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801018bb:	75 10                	jne    801018cd <iget+0x77>
801018bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018c0:	8b 40 08             	mov    0x8(%eax),%eax
801018c3:	85 c0                	test   %eax,%eax
801018c5:	75 06                	jne    801018cd <iget+0x77>
      empty = ip;
801018c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018cd:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
801018d4:	81 7d f4 b4 36 11 80 	cmpl   $0x801136b4,-0xc(%ebp)
801018db:	72 9b                	jb     80101878 <iget+0x22>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801018dd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801018e1:	75 0c                	jne    801018ef <iget+0x99>
    panic("iget: no inodes");
801018e3:	c7 04 24 b5 83 10 80 	movl   $0x801083b5,(%esp)
801018ea:	e8 73 ec ff ff       	call   80100562 <panic>

  ip = empty;
801018ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
801018f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018f8:	8b 55 08             	mov    0x8(%ebp),%edx
801018fb:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
801018fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101900:	8b 55 0c             	mov    0xc(%ebp),%edx
80101903:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101906:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101909:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101910:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101913:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
8010191a:	c7 04 24 60 1a 11 80 	movl   $0x80111a60,(%esp)
80101921:	e8 00 35 00 00       	call   80104e26 <release>

  return ip;
80101926:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101929:	c9                   	leave  
8010192a:	c3                   	ret    

8010192b <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
8010192b:	55                   	push   %ebp
8010192c:	89 e5                	mov    %esp,%ebp
8010192e:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101931:	c7 04 24 60 1a 11 80 	movl   $0x80111a60,(%esp)
80101938:	e8 81 34 00 00       	call   80104dbe <acquire>
  ip->ref++;
8010193d:	8b 45 08             	mov    0x8(%ebp),%eax
80101940:	8b 40 08             	mov    0x8(%eax),%eax
80101943:	8d 50 01             	lea    0x1(%eax),%edx
80101946:	8b 45 08             	mov    0x8(%ebp),%eax
80101949:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
8010194c:	c7 04 24 60 1a 11 80 	movl   $0x80111a60,(%esp)
80101953:	e8 ce 34 00 00       	call   80104e26 <release>
  return ip;
80101958:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010195b:	c9                   	leave  
8010195c:	c3                   	ret    

8010195d <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
8010195d:	55                   	push   %ebp
8010195e:	89 e5                	mov    %esp,%ebp
80101960:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101963:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101967:	74 0a                	je     80101973 <ilock+0x16>
80101969:	8b 45 08             	mov    0x8(%ebp),%eax
8010196c:	8b 40 08             	mov    0x8(%eax),%eax
8010196f:	85 c0                	test   %eax,%eax
80101971:	7f 0c                	jg     8010197f <ilock+0x22>
    panic("ilock");
80101973:	c7 04 24 c5 83 10 80 	movl   $0x801083c5,(%esp)
8010197a:	e8 e3 eb ff ff       	call   80100562 <panic>

  acquiresleep(&ip->lock);
8010197f:	8b 45 08             	mov    0x8(%ebp),%eax
80101982:	83 c0 0c             	add    $0xc,%eax
80101985:	89 04 24             	mov    %eax,(%esp)
80101988:	e8 e7 32 00 00       	call   80104c74 <acquiresleep>

  if(ip->valid == 0){
8010198d:	8b 45 08             	mov    0x8(%ebp),%eax
80101990:	8b 40 4c             	mov    0x4c(%eax),%eax
80101993:	85 c0                	test   %eax,%eax
80101995:	0f 85 cd 00 00 00    	jne    80101a68 <ilock+0x10b>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010199b:	8b 45 08             	mov    0x8(%ebp),%eax
8010199e:	8b 40 04             	mov    0x4(%eax),%eax
801019a1:	c1 e8 03             	shr    $0x3,%eax
801019a4:	89 c2                	mov    %eax,%edx
801019a6:	a1 54 1a 11 80       	mov    0x80111a54,%eax
801019ab:	01 c2                	add    %eax,%edx
801019ad:	8b 45 08             	mov    0x8(%ebp),%eax
801019b0:	8b 00                	mov    (%eax),%eax
801019b2:	89 54 24 04          	mov    %edx,0x4(%esp)
801019b6:	89 04 24             	mov    %eax,(%esp)
801019b9:	e8 f7 e7 ff ff       	call   801001b5 <bread>
801019be:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
801019c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019c4:	8d 50 5c             	lea    0x5c(%eax),%edx
801019c7:	8b 45 08             	mov    0x8(%ebp),%eax
801019ca:	8b 40 04             	mov    0x4(%eax),%eax
801019cd:	83 e0 07             	and    $0x7,%eax
801019d0:	c1 e0 06             	shl    $0x6,%eax
801019d3:	01 d0                	add    %edx,%eax
801019d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
801019d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019db:	0f b7 10             	movzwl (%eax),%edx
801019de:	8b 45 08             	mov    0x8(%ebp),%eax
801019e1:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
801019e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019e8:	0f b7 50 02          	movzwl 0x2(%eax),%edx
801019ec:	8b 45 08             	mov    0x8(%ebp),%eax
801019ef:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
801019f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019f6:	0f b7 50 04          	movzwl 0x4(%eax),%edx
801019fa:	8b 45 08             	mov    0x8(%ebp),%eax
801019fd:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101a01:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a04:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101a08:	8b 45 08             	mov    0x8(%ebp),%eax
80101a0b:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101a0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a12:	8b 50 08             	mov    0x8(%eax),%edx
80101a15:	8b 45 08             	mov    0x8(%ebp),%eax
80101a18:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101a1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a1e:	8d 50 0c             	lea    0xc(%eax),%edx
80101a21:	8b 45 08             	mov    0x8(%ebp),%eax
80101a24:	83 c0 5c             	add    $0x5c,%eax
80101a27:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101a2e:	00 
80101a2f:	89 54 24 04          	mov    %edx,0x4(%esp)
80101a33:	89 04 24             	mov    %eax,(%esp)
80101a36:	e8 c4 36 00 00       	call   801050ff <memmove>
    brelse(bp);
80101a3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a3e:	89 04 24             	mov    %eax,(%esp)
80101a41:	e8 e6 e7 ff ff       	call   8010022c <brelse>
    ip->valid = 1;
80101a46:	8b 45 08             	mov    0x8(%ebp),%eax
80101a49:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101a50:	8b 45 08             	mov    0x8(%ebp),%eax
80101a53:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101a57:	66 85 c0             	test   %ax,%ax
80101a5a:	75 0c                	jne    80101a68 <ilock+0x10b>
      panic("ilock: no type");
80101a5c:	c7 04 24 cb 83 10 80 	movl   $0x801083cb,(%esp)
80101a63:	e8 fa ea ff ff       	call   80100562 <panic>
  }
}
80101a68:	c9                   	leave  
80101a69:	c3                   	ret    

80101a6a <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101a6a:	55                   	push   %ebp
80101a6b:	89 e5                	mov    %esp,%ebp
80101a6d:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101a70:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101a74:	74 1c                	je     80101a92 <iunlock+0x28>
80101a76:	8b 45 08             	mov    0x8(%ebp),%eax
80101a79:	83 c0 0c             	add    $0xc,%eax
80101a7c:	89 04 24             	mov    %eax,(%esp)
80101a7f:	e8 8d 32 00 00       	call   80104d11 <holdingsleep>
80101a84:	85 c0                	test   %eax,%eax
80101a86:	74 0a                	je     80101a92 <iunlock+0x28>
80101a88:	8b 45 08             	mov    0x8(%ebp),%eax
80101a8b:	8b 40 08             	mov    0x8(%eax),%eax
80101a8e:	85 c0                	test   %eax,%eax
80101a90:	7f 0c                	jg     80101a9e <iunlock+0x34>
    panic("iunlock");
80101a92:	c7 04 24 da 83 10 80 	movl   $0x801083da,(%esp)
80101a99:	e8 c4 ea ff ff       	call   80100562 <panic>

  releasesleep(&ip->lock);
80101a9e:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa1:	83 c0 0c             	add    $0xc,%eax
80101aa4:	89 04 24             	mov    %eax,(%esp)
80101aa7:	e8 23 32 00 00       	call   80104ccf <releasesleep>
}
80101aac:	c9                   	leave  
80101aad:	c3                   	ret    

80101aae <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101aae:	55                   	push   %ebp
80101aaf:	89 e5                	mov    %esp,%ebp
80101ab1:	83 ec 28             	sub    $0x28,%esp
  acquiresleep(&ip->lock);
80101ab4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab7:	83 c0 0c             	add    $0xc,%eax
80101aba:	89 04 24             	mov    %eax,(%esp)
80101abd:	e8 b2 31 00 00       	call   80104c74 <acquiresleep>
  if(ip->valid && ip->nlink == 0){
80101ac2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac5:	8b 40 4c             	mov    0x4c(%eax),%eax
80101ac8:	85 c0                	test   %eax,%eax
80101aca:	74 5c                	je     80101b28 <iput+0x7a>
80101acc:	8b 45 08             	mov    0x8(%ebp),%eax
80101acf:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101ad3:	66 85 c0             	test   %ax,%ax
80101ad6:	75 50                	jne    80101b28 <iput+0x7a>
    acquire(&icache.lock);
80101ad8:	c7 04 24 60 1a 11 80 	movl   $0x80111a60,(%esp)
80101adf:	e8 da 32 00 00       	call   80104dbe <acquire>
    int r = ip->ref;
80101ae4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae7:	8b 40 08             	mov    0x8(%eax),%eax
80101aea:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101aed:	c7 04 24 60 1a 11 80 	movl   $0x80111a60,(%esp)
80101af4:	e8 2d 33 00 00       	call   80104e26 <release>
    if(r == 1){
80101af9:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101afd:	75 29                	jne    80101b28 <iput+0x7a>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101aff:	8b 45 08             	mov    0x8(%ebp),%eax
80101b02:	89 04 24             	mov    %eax,(%esp)
80101b05:	e8 86 01 00 00       	call   80101c90 <itrunc>
      ip->type = 0;
80101b0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0d:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101b13:	8b 45 08             	mov    0x8(%ebp),%eax
80101b16:	89 04 24             	mov    %eax,(%esp)
80101b19:	e8 7a fc ff ff       	call   80101798 <iupdate>
      ip->valid = 0;
80101b1e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b21:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101b28:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2b:	83 c0 0c             	add    $0xc,%eax
80101b2e:	89 04 24             	mov    %eax,(%esp)
80101b31:	e8 99 31 00 00       	call   80104ccf <releasesleep>

  acquire(&icache.lock);
80101b36:	c7 04 24 60 1a 11 80 	movl   $0x80111a60,(%esp)
80101b3d:	e8 7c 32 00 00       	call   80104dbe <acquire>
  ip->ref--;
80101b42:	8b 45 08             	mov    0x8(%ebp),%eax
80101b45:	8b 40 08             	mov    0x8(%eax),%eax
80101b48:	8d 50 ff             	lea    -0x1(%eax),%edx
80101b4b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b4e:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101b51:	c7 04 24 60 1a 11 80 	movl   $0x80111a60,(%esp)
80101b58:	e8 c9 32 00 00       	call   80104e26 <release>
}
80101b5d:	c9                   	leave  
80101b5e:	c3                   	ret    

80101b5f <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101b5f:	55                   	push   %ebp
80101b60:	89 e5                	mov    %esp,%ebp
80101b62:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101b65:	8b 45 08             	mov    0x8(%ebp),%eax
80101b68:	89 04 24             	mov    %eax,(%esp)
80101b6b:	e8 fa fe ff ff       	call   80101a6a <iunlock>
  iput(ip);
80101b70:	8b 45 08             	mov    0x8(%ebp),%eax
80101b73:	89 04 24             	mov    %eax,(%esp)
80101b76:	e8 33 ff ff ff       	call   80101aae <iput>
}
80101b7b:	c9                   	leave  
80101b7c:	c3                   	ret    

80101b7d <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101b7d:	55                   	push   %ebp
80101b7e:	89 e5                	mov    %esp,%ebp
80101b80:	53                   	push   %ebx
80101b81:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101b84:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101b88:	77 3e                	ja     80101bc8 <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101b8a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8d:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b90:	83 c2 14             	add    $0x14,%edx
80101b93:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101b97:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b9a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b9e:	75 20                	jne    80101bc0 <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101ba0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba3:	8b 00                	mov    (%eax),%eax
80101ba5:	89 04 24             	mov    %eax,(%esp)
80101ba8:	e8 3a f8 ff ff       	call   801013e7 <balloc>
80101bad:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bb0:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb3:	8b 55 0c             	mov    0xc(%ebp),%edx
80101bb6:	8d 4a 14             	lea    0x14(%edx),%ecx
80101bb9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101bbc:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101bc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bc3:	e9 c2 00 00 00       	jmp    80101c8a <bmap+0x10d>
  }
  bn -= NDIRECT;
80101bc8:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101bcc:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101bd0:	0f 87 a8 00 00 00    	ja     80101c7e <bmap+0x101>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101bd6:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd9:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101bdf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101be2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101be6:	75 1c                	jne    80101c04 <bmap+0x87>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101be8:	8b 45 08             	mov    0x8(%ebp),%eax
80101beb:	8b 00                	mov    (%eax),%eax
80101bed:	89 04 24             	mov    %eax,(%esp)
80101bf0:	e8 f2 f7 ff ff       	call   801013e7 <balloc>
80101bf5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bf8:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101bfe:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101c04:	8b 45 08             	mov    0x8(%ebp),%eax
80101c07:	8b 00                	mov    (%eax),%eax
80101c09:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c0c:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c10:	89 04 24             	mov    %eax,(%esp)
80101c13:	e8 9d e5 ff ff       	call   801001b5 <bread>
80101c18:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101c1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c1e:	83 c0 5c             	add    $0x5c,%eax
80101c21:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101c24:	8b 45 0c             	mov    0xc(%ebp),%eax
80101c27:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101c2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101c31:	01 d0                	add    %edx,%eax
80101c33:	8b 00                	mov    (%eax),%eax
80101c35:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c38:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c3c:	75 30                	jne    80101c6e <bmap+0xf1>
      a[bn] = addr = balloc(ip->dev);
80101c3e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101c41:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101c48:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101c4b:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101c4e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c51:	8b 00                	mov    (%eax),%eax
80101c53:	89 04 24             	mov    %eax,(%esp)
80101c56:	e8 8c f7 ff ff       	call   801013e7 <balloc>
80101c5b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c61:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101c63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c66:	89 04 24             	mov    %eax,(%esp)
80101c69:	e8 24 1a 00 00       	call   80103692 <log_write>
    }
    brelse(bp);
80101c6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c71:	89 04 24             	mov    %eax,(%esp)
80101c74:	e8 b3 e5 ff ff       	call   8010022c <brelse>
    return addr;
80101c79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c7c:	eb 0c                	jmp    80101c8a <bmap+0x10d>
  }

  panic("bmap: out of range");
80101c7e:	c7 04 24 e2 83 10 80 	movl   $0x801083e2,(%esp)
80101c85:	e8 d8 e8 ff ff       	call   80100562 <panic>
}
80101c8a:	83 c4 24             	add    $0x24,%esp
80101c8d:	5b                   	pop    %ebx
80101c8e:	5d                   	pop    %ebp
80101c8f:	c3                   	ret    

80101c90 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101c90:	55                   	push   %ebp
80101c91:	89 e5                	mov    %esp,%ebp
80101c93:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101c96:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101c9d:	eb 44                	jmp    80101ce3 <itrunc+0x53>
    if(ip->addrs[i]){
80101c9f:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ca5:	83 c2 14             	add    $0x14,%edx
80101ca8:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101cac:	85 c0                	test   %eax,%eax
80101cae:	74 2f                	je     80101cdf <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101cb0:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cb6:	83 c2 14             	add    $0x14,%edx
80101cb9:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101cbd:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc0:	8b 00                	mov    (%eax),%eax
80101cc2:	89 54 24 04          	mov    %edx,0x4(%esp)
80101cc6:	89 04 24             	mov    %eax,(%esp)
80101cc9:	e8 57 f8 ff ff       	call   80101525 <bfree>
      ip->addrs[i] = 0;
80101cce:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cd4:	83 c2 14             	add    $0x14,%edx
80101cd7:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101cde:	00 
  for(i = 0; i < NDIRECT; i++){
80101cdf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101ce3:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101ce7:	7e b6                	jle    80101c9f <itrunc+0xf>
    }
  }

  if(ip->addrs[NDIRECT]){
80101ce9:	8b 45 08             	mov    0x8(%ebp),%eax
80101cec:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101cf2:	85 c0                	test   %eax,%eax
80101cf4:	0f 84 a4 00 00 00    	je     80101d9e <itrunc+0x10e>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101cfa:	8b 45 08             	mov    0x8(%ebp),%eax
80101cfd:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101d03:	8b 45 08             	mov    0x8(%ebp),%eax
80101d06:	8b 00                	mov    (%eax),%eax
80101d08:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d0c:	89 04 24             	mov    %eax,(%esp)
80101d0f:	e8 a1 e4 ff ff       	call   801001b5 <bread>
80101d14:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101d17:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d1a:	83 c0 5c             	add    $0x5c,%eax
80101d1d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101d20:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101d27:	eb 3b                	jmp    80101d64 <itrunc+0xd4>
      if(a[j])
80101d29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d2c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d33:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101d36:	01 d0                	add    %edx,%eax
80101d38:	8b 00                	mov    (%eax),%eax
80101d3a:	85 c0                	test   %eax,%eax
80101d3c:	74 22                	je     80101d60 <itrunc+0xd0>
        bfree(ip->dev, a[j]);
80101d3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d41:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d48:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101d4b:	01 d0                	add    %edx,%eax
80101d4d:	8b 10                	mov    (%eax),%edx
80101d4f:	8b 45 08             	mov    0x8(%ebp),%eax
80101d52:	8b 00                	mov    (%eax),%eax
80101d54:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d58:	89 04 24             	mov    %eax,(%esp)
80101d5b:	e8 c5 f7 ff ff       	call   80101525 <bfree>
    for(j = 0; j < NINDIRECT; j++){
80101d60:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101d64:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d67:	83 f8 7f             	cmp    $0x7f,%eax
80101d6a:	76 bd                	jbe    80101d29 <itrunc+0x99>
    }
    brelse(bp);
80101d6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d6f:	89 04 24             	mov    %eax,(%esp)
80101d72:	e8 b5 e4 ff ff       	call   8010022c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101d77:	8b 45 08             	mov    0x8(%ebp),%eax
80101d7a:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101d80:	8b 45 08             	mov    0x8(%ebp),%eax
80101d83:	8b 00                	mov    (%eax),%eax
80101d85:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d89:	89 04 24             	mov    %eax,(%esp)
80101d8c:	e8 94 f7 ff ff       	call   80101525 <bfree>
    ip->addrs[NDIRECT] = 0;
80101d91:	8b 45 08             	mov    0x8(%ebp),%eax
80101d94:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101d9b:	00 00 00 
  }

  ip->size = 0;
80101d9e:	8b 45 08             	mov    0x8(%ebp),%eax
80101da1:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101da8:	8b 45 08             	mov    0x8(%ebp),%eax
80101dab:	89 04 24             	mov    %eax,(%esp)
80101dae:	e8 e5 f9 ff ff       	call   80101798 <iupdate>
}
80101db3:	c9                   	leave  
80101db4:	c3                   	ret    

80101db5 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101db5:	55                   	push   %ebp
80101db6:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101db8:	8b 45 08             	mov    0x8(%ebp),%eax
80101dbb:	8b 00                	mov    (%eax),%eax
80101dbd:	89 c2                	mov    %eax,%edx
80101dbf:	8b 45 0c             	mov    0xc(%ebp),%eax
80101dc2:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101dc5:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc8:	8b 50 04             	mov    0x4(%eax),%edx
80101dcb:	8b 45 0c             	mov    0xc(%ebp),%eax
80101dce:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101dd1:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd4:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101dd8:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ddb:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101dde:	8b 45 08             	mov    0x8(%ebp),%eax
80101de1:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101de5:	8b 45 0c             	mov    0xc(%ebp),%eax
80101de8:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101dec:	8b 45 08             	mov    0x8(%ebp),%eax
80101def:	8b 50 58             	mov    0x58(%eax),%edx
80101df2:	8b 45 0c             	mov    0xc(%ebp),%eax
80101df5:	89 50 10             	mov    %edx,0x10(%eax)
}
80101df8:	5d                   	pop    %ebp
80101df9:	c3                   	ret    

80101dfa <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101dfa:	55                   	push   %ebp
80101dfb:	89 e5                	mov    %esp,%ebp
80101dfd:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101e00:	8b 45 08             	mov    0x8(%ebp),%eax
80101e03:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101e07:	66 83 f8 03          	cmp    $0x3,%ax
80101e0b:	75 60                	jne    80101e6d <readi+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101e0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e10:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101e14:	66 85 c0             	test   %ax,%ax
80101e17:	78 20                	js     80101e39 <readi+0x3f>
80101e19:	8b 45 08             	mov    0x8(%ebp),%eax
80101e1c:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101e20:	66 83 f8 09          	cmp    $0x9,%ax
80101e24:	7f 13                	jg     80101e39 <readi+0x3f>
80101e26:	8b 45 08             	mov    0x8(%ebp),%eax
80101e29:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101e2d:	98                   	cwtl   
80101e2e:	8b 04 c5 e0 19 11 80 	mov    -0x7feee620(,%eax,8),%eax
80101e35:	85 c0                	test   %eax,%eax
80101e37:	75 0a                	jne    80101e43 <readi+0x49>
      return -1;
80101e39:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101e3e:	e9 19 01 00 00       	jmp    80101f5c <readi+0x162>
    return devsw[ip->major].read(ip, dst, n);
80101e43:	8b 45 08             	mov    0x8(%ebp),%eax
80101e46:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101e4a:	98                   	cwtl   
80101e4b:	8b 04 c5 e0 19 11 80 	mov    -0x7feee620(,%eax,8),%eax
80101e52:	8b 55 14             	mov    0x14(%ebp),%edx
80101e55:	89 54 24 08          	mov    %edx,0x8(%esp)
80101e59:	8b 55 0c             	mov    0xc(%ebp),%edx
80101e5c:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e60:	8b 55 08             	mov    0x8(%ebp),%edx
80101e63:	89 14 24             	mov    %edx,(%esp)
80101e66:	ff d0                	call   *%eax
80101e68:	e9 ef 00 00 00       	jmp    80101f5c <readi+0x162>
  }

  if(off > ip->size || off + n < off)
80101e6d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e70:	8b 40 58             	mov    0x58(%eax),%eax
80101e73:	3b 45 10             	cmp    0x10(%ebp),%eax
80101e76:	72 0d                	jb     80101e85 <readi+0x8b>
80101e78:	8b 45 14             	mov    0x14(%ebp),%eax
80101e7b:	8b 55 10             	mov    0x10(%ebp),%edx
80101e7e:	01 d0                	add    %edx,%eax
80101e80:	3b 45 10             	cmp    0x10(%ebp),%eax
80101e83:	73 0a                	jae    80101e8f <readi+0x95>
    return -1;
80101e85:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101e8a:	e9 cd 00 00 00       	jmp    80101f5c <readi+0x162>
  if(off + n > ip->size)
80101e8f:	8b 45 14             	mov    0x14(%ebp),%eax
80101e92:	8b 55 10             	mov    0x10(%ebp),%edx
80101e95:	01 c2                	add    %eax,%edx
80101e97:	8b 45 08             	mov    0x8(%ebp),%eax
80101e9a:	8b 40 58             	mov    0x58(%eax),%eax
80101e9d:	39 c2                	cmp    %eax,%edx
80101e9f:	76 0c                	jbe    80101ead <readi+0xb3>
    n = ip->size - off;
80101ea1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea4:	8b 40 58             	mov    0x58(%eax),%eax
80101ea7:	2b 45 10             	sub    0x10(%ebp),%eax
80101eaa:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101ead:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101eb4:	e9 94 00 00 00       	jmp    80101f4d <readi+0x153>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101eb9:	8b 45 10             	mov    0x10(%ebp),%eax
80101ebc:	c1 e8 09             	shr    $0x9,%eax
80101ebf:	89 44 24 04          	mov    %eax,0x4(%esp)
80101ec3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec6:	89 04 24             	mov    %eax,(%esp)
80101ec9:	e8 af fc ff ff       	call   80101b7d <bmap>
80101ece:	8b 55 08             	mov    0x8(%ebp),%edx
80101ed1:	8b 12                	mov    (%edx),%edx
80101ed3:	89 44 24 04          	mov    %eax,0x4(%esp)
80101ed7:	89 14 24             	mov    %edx,(%esp)
80101eda:	e8 d6 e2 ff ff       	call   801001b5 <bread>
80101edf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101ee2:	8b 45 10             	mov    0x10(%ebp),%eax
80101ee5:	25 ff 01 00 00       	and    $0x1ff,%eax
80101eea:	89 c2                	mov    %eax,%edx
80101eec:	b8 00 02 00 00       	mov    $0x200,%eax
80101ef1:	29 d0                	sub    %edx,%eax
80101ef3:	89 c2                	mov    %eax,%edx
80101ef5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ef8:	8b 4d 14             	mov    0x14(%ebp),%ecx
80101efb:	29 c1                	sub    %eax,%ecx
80101efd:	89 c8                	mov    %ecx,%eax
80101eff:	39 c2                	cmp    %eax,%edx
80101f01:	0f 46 c2             	cmovbe %edx,%eax
80101f04:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101f07:	8b 45 10             	mov    0x10(%ebp),%eax
80101f0a:	25 ff 01 00 00       	and    $0x1ff,%eax
80101f0f:	8d 50 50             	lea    0x50(%eax),%edx
80101f12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f15:	01 d0                	add    %edx,%eax
80101f17:	8d 50 0c             	lea    0xc(%eax),%edx
80101f1a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f1d:	89 44 24 08          	mov    %eax,0x8(%esp)
80101f21:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f25:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f28:	89 04 24             	mov    %eax,(%esp)
80101f2b:	e8 cf 31 00 00       	call   801050ff <memmove>
    brelse(bp);
80101f30:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f33:	89 04 24             	mov    %eax,(%esp)
80101f36:	e8 f1 e2 ff ff       	call   8010022c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f3b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f3e:	01 45 f4             	add    %eax,-0xc(%ebp)
80101f41:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f44:	01 45 10             	add    %eax,0x10(%ebp)
80101f47:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f4a:	01 45 0c             	add    %eax,0xc(%ebp)
80101f4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f50:	3b 45 14             	cmp    0x14(%ebp),%eax
80101f53:	0f 82 60 ff ff ff    	jb     80101eb9 <readi+0xbf>
  }
  return n;
80101f59:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101f5c:	c9                   	leave  
80101f5d:	c3                   	ret    

80101f5e <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101f5e:	55                   	push   %ebp
80101f5f:	89 e5                	mov    %esp,%ebp
80101f61:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101f64:	8b 45 08             	mov    0x8(%ebp),%eax
80101f67:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101f6b:	66 83 f8 03          	cmp    $0x3,%ax
80101f6f:	75 60                	jne    80101fd1 <writei+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101f71:	8b 45 08             	mov    0x8(%ebp),%eax
80101f74:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f78:	66 85 c0             	test   %ax,%ax
80101f7b:	78 20                	js     80101f9d <writei+0x3f>
80101f7d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f80:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f84:	66 83 f8 09          	cmp    $0x9,%ax
80101f88:	7f 13                	jg     80101f9d <writei+0x3f>
80101f8a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f8d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f91:	98                   	cwtl   
80101f92:	8b 04 c5 e4 19 11 80 	mov    -0x7feee61c(,%eax,8),%eax
80101f99:	85 c0                	test   %eax,%eax
80101f9b:	75 0a                	jne    80101fa7 <writei+0x49>
      return -1;
80101f9d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fa2:	e9 44 01 00 00       	jmp    801020eb <writei+0x18d>
    return devsw[ip->major].write(ip, src, n);
80101fa7:	8b 45 08             	mov    0x8(%ebp),%eax
80101faa:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fae:	98                   	cwtl   
80101faf:	8b 04 c5 e4 19 11 80 	mov    -0x7feee61c(,%eax,8),%eax
80101fb6:	8b 55 14             	mov    0x14(%ebp),%edx
80101fb9:	89 54 24 08          	mov    %edx,0x8(%esp)
80101fbd:	8b 55 0c             	mov    0xc(%ebp),%edx
80101fc0:	89 54 24 04          	mov    %edx,0x4(%esp)
80101fc4:	8b 55 08             	mov    0x8(%ebp),%edx
80101fc7:	89 14 24             	mov    %edx,(%esp)
80101fca:	ff d0                	call   *%eax
80101fcc:	e9 1a 01 00 00       	jmp    801020eb <writei+0x18d>
  }

  if(off > ip->size || off + n < off)
80101fd1:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd4:	8b 40 58             	mov    0x58(%eax),%eax
80101fd7:	3b 45 10             	cmp    0x10(%ebp),%eax
80101fda:	72 0d                	jb     80101fe9 <writei+0x8b>
80101fdc:	8b 45 14             	mov    0x14(%ebp),%eax
80101fdf:	8b 55 10             	mov    0x10(%ebp),%edx
80101fe2:	01 d0                	add    %edx,%eax
80101fe4:	3b 45 10             	cmp    0x10(%ebp),%eax
80101fe7:	73 0a                	jae    80101ff3 <writei+0x95>
    return -1;
80101fe9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fee:	e9 f8 00 00 00       	jmp    801020eb <writei+0x18d>
  if(off + n > MAXFILE*BSIZE)
80101ff3:	8b 45 14             	mov    0x14(%ebp),%eax
80101ff6:	8b 55 10             	mov    0x10(%ebp),%edx
80101ff9:	01 d0                	add    %edx,%eax
80101ffb:	3d 00 18 01 00       	cmp    $0x11800,%eax
80102000:	76 0a                	jbe    8010200c <writei+0xae>
    return -1;
80102002:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102007:	e9 df 00 00 00       	jmp    801020eb <writei+0x18d>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010200c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102013:	e9 9f 00 00 00       	jmp    801020b7 <writei+0x159>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102018:	8b 45 10             	mov    0x10(%ebp),%eax
8010201b:	c1 e8 09             	shr    $0x9,%eax
8010201e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102022:	8b 45 08             	mov    0x8(%ebp),%eax
80102025:	89 04 24             	mov    %eax,(%esp)
80102028:	e8 50 fb ff ff       	call   80101b7d <bmap>
8010202d:	8b 55 08             	mov    0x8(%ebp),%edx
80102030:	8b 12                	mov    (%edx),%edx
80102032:	89 44 24 04          	mov    %eax,0x4(%esp)
80102036:	89 14 24             	mov    %edx,(%esp)
80102039:	e8 77 e1 ff ff       	call   801001b5 <bread>
8010203e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102041:	8b 45 10             	mov    0x10(%ebp),%eax
80102044:	25 ff 01 00 00       	and    $0x1ff,%eax
80102049:	89 c2                	mov    %eax,%edx
8010204b:	b8 00 02 00 00       	mov    $0x200,%eax
80102050:	29 d0                	sub    %edx,%eax
80102052:	89 c2                	mov    %eax,%edx
80102054:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102057:	8b 4d 14             	mov    0x14(%ebp),%ecx
8010205a:	29 c1                	sub    %eax,%ecx
8010205c:	89 c8                	mov    %ecx,%eax
8010205e:	39 c2                	cmp    %eax,%edx
80102060:	0f 46 c2             	cmovbe %edx,%eax
80102063:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102066:	8b 45 10             	mov    0x10(%ebp),%eax
80102069:	25 ff 01 00 00       	and    $0x1ff,%eax
8010206e:	8d 50 50             	lea    0x50(%eax),%edx
80102071:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102074:	01 d0                	add    %edx,%eax
80102076:	8d 50 0c             	lea    0xc(%eax),%edx
80102079:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010207c:	89 44 24 08          	mov    %eax,0x8(%esp)
80102080:	8b 45 0c             	mov    0xc(%ebp),%eax
80102083:	89 44 24 04          	mov    %eax,0x4(%esp)
80102087:	89 14 24             	mov    %edx,(%esp)
8010208a:	e8 70 30 00 00       	call   801050ff <memmove>
    log_write(bp);
8010208f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102092:	89 04 24             	mov    %eax,(%esp)
80102095:	e8 f8 15 00 00       	call   80103692 <log_write>
    brelse(bp);
8010209a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010209d:	89 04 24             	mov    %eax,(%esp)
801020a0:	e8 87 e1 ff ff       	call   8010022c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020a8:	01 45 f4             	add    %eax,-0xc(%ebp)
801020ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020ae:	01 45 10             	add    %eax,0x10(%ebp)
801020b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020b4:	01 45 0c             	add    %eax,0xc(%ebp)
801020b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020ba:	3b 45 14             	cmp    0x14(%ebp),%eax
801020bd:	0f 82 55 ff ff ff    	jb     80102018 <writei+0xba>
  }

  if(n > 0 && off > ip->size){
801020c3:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801020c7:	74 1f                	je     801020e8 <writei+0x18a>
801020c9:	8b 45 08             	mov    0x8(%ebp),%eax
801020cc:	8b 40 58             	mov    0x58(%eax),%eax
801020cf:	3b 45 10             	cmp    0x10(%ebp),%eax
801020d2:	73 14                	jae    801020e8 <writei+0x18a>
    ip->size = off;
801020d4:	8b 45 08             	mov    0x8(%ebp),%eax
801020d7:	8b 55 10             	mov    0x10(%ebp),%edx
801020da:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
801020dd:	8b 45 08             	mov    0x8(%ebp),%eax
801020e0:	89 04 24             	mov    %eax,(%esp)
801020e3:	e8 b0 f6 ff ff       	call   80101798 <iupdate>
  }
  return n;
801020e8:	8b 45 14             	mov    0x14(%ebp),%eax
}
801020eb:	c9                   	leave  
801020ec:	c3                   	ret    

801020ed <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801020ed:	55                   	push   %ebp
801020ee:	89 e5                	mov    %esp,%ebp
801020f0:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
801020f3:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801020fa:	00 
801020fb:	8b 45 0c             	mov    0xc(%ebp),%eax
801020fe:	89 44 24 04          	mov    %eax,0x4(%esp)
80102102:	8b 45 08             	mov    0x8(%ebp),%eax
80102105:	89 04 24             	mov    %eax,(%esp)
80102108:	e8 95 30 00 00       	call   801051a2 <strncmp>
}
8010210d:	c9                   	leave  
8010210e:	c3                   	ret    

8010210f <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
8010210f:	55                   	push   %ebp
80102110:	89 e5                	mov    %esp,%ebp
80102112:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102115:	8b 45 08             	mov    0x8(%ebp),%eax
80102118:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010211c:	66 83 f8 01          	cmp    $0x1,%ax
80102120:	74 0c                	je     8010212e <dirlookup+0x1f>
    panic("dirlookup not DIR");
80102122:	c7 04 24 f5 83 10 80 	movl   $0x801083f5,(%esp)
80102129:	e8 34 e4 ff ff       	call   80100562 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
8010212e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102135:	e9 88 00 00 00       	jmp    801021c2 <dirlookup+0xb3>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010213a:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102141:	00 
80102142:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102145:	89 44 24 08          	mov    %eax,0x8(%esp)
80102149:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010214c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102150:	8b 45 08             	mov    0x8(%ebp),%eax
80102153:	89 04 24             	mov    %eax,(%esp)
80102156:	e8 9f fc ff ff       	call   80101dfa <readi>
8010215b:	83 f8 10             	cmp    $0x10,%eax
8010215e:	74 0c                	je     8010216c <dirlookup+0x5d>
      panic("dirlookup read");
80102160:	c7 04 24 07 84 10 80 	movl   $0x80108407,(%esp)
80102167:	e8 f6 e3 ff ff       	call   80100562 <panic>
    if(de.inum == 0)
8010216c:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102170:	66 85 c0             	test   %ax,%ax
80102173:	75 02                	jne    80102177 <dirlookup+0x68>
      continue;
80102175:	eb 47                	jmp    801021be <dirlookup+0xaf>
    if(namecmp(name, de.name) == 0){
80102177:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010217a:	83 c0 02             	add    $0x2,%eax
8010217d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102181:	8b 45 0c             	mov    0xc(%ebp),%eax
80102184:	89 04 24             	mov    %eax,(%esp)
80102187:	e8 61 ff ff ff       	call   801020ed <namecmp>
8010218c:	85 c0                	test   %eax,%eax
8010218e:	75 2e                	jne    801021be <dirlookup+0xaf>
      // entry matches path element
      if(poff)
80102190:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102194:	74 08                	je     8010219e <dirlookup+0x8f>
        *poff = off;
80102196:	8b 45 10             	mov    0x10(%ebp),%eax
80102199:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010219c:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010219e:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801021a2:	0f b7 c0             	movzwl %ax,%eax
801021a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
801021a8:	8b 45 08             	mov    0x8(%ebp),%eax
801021ab:	8b 00                	mov    (%eax),%eax
801021ad:	8b 55 f0             	mov    -0x10(%ebp),%edx
801021b0:	89 54 24 04          	mov    %edx,0x4(%esp)
801021b4:	89 04 24             	mov    %eax,(%esp)
801021b7:	e8 9a f6 ff ff       	call   80101856 <iget>
801021bc:	eb 18                	jmp    801021d6 <dirlookup+0xc7>
  for(off = 0; off < dp->size; off += sizeof(de)){
801021be:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801021c2:	8b 45 08             	mov    0x8(%ebp),%eax
801021c5:	8b 40 58             	mov    0x58(%eax),%eax
801021c8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801021cb:	0f 87 69 ff ff ff    	ja     8010213a <dirlookup+0x2b>
    }
  }

  return 0;
801021d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801021d6:	c9                   	leave  
801021d7:	c3                   	ret    

801021d8 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
801021d8:	55                   	push   %ebp
801021d9:	89 e5                	mov    %esp,%ebp
801021db:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801021de:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801021e5:	00 
801021e6:	8b 45 0c             	mov    0xc(%ebp),%eax
801021e9:	89 44 24 04          	mov    %eax,0x4(%esp)
801021ed:	8b 45 08             	mov    0x8(%ebp),%eax
801021f0:	89 04 24             	mov    %eax,(%esp)
801021f3:	e8 17 ff ff ff       	call   8010210f <dirlookup>
801021f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801021fb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801021ff:	74 15                	je     80102216 <dirlink+0x3e>
    iput(ip);
80102201:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102204:	89 04 24             	mov    %eax,(%esp)
80102207:	e8 a2 f8 ff ff       	call   80101aae <iput>
    return -1;
8010220c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102211:	e9 b7 00 00 00       	jmp    801022cd <dirlink+0xf5>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102216:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010221d:	eb 46                	jmp    80102265 <dirlink+0x8d>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010221f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102222:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102229:	00 
8010222a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010222e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102231:	89 44 24 04          	mov    %eax,0x4(%esp)
80102235:	8b 45 08             	mov    0x8(%ebp),%eax
80102238:	89 04 24             	mov    %eax,(%esp)
8010223b:	e8 ba fb ff ff       	call   80101dfa <readi>
80102240:	83 f8 10             	cmp    $0x10,%eax
80102243:	74 0c                	je     80102251 <dirlink+0x79>
      panic("dirlink read");
80102245:	c7 04 24 16 84 10 80 	movl   $0x80108416,(%esp)
8010224c:	e8 11 e3 ff ff       	call   80100562 <panic>
    if(de.inum == 0)
80102251:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102255:	66 85 c0             	test   %ax,%ax
80102258:	75 02                	jne    8010225c <dirlink+0x84>
      break;
8010225a:	eb 16                	jmp    80102272 <dirlink+0x9a>
  for(off = 0; off < dp->size; off += sizeof(de)){
8010225c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010225f:	83 c0 10             	add    $0x10,%eax
80102262:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102265:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102268:	8b 45 08             	mov    0x8(%ebp),%eax
8010226b:	8b 40 58             	mov    0x58(%eax),%eax
8010226e:	39 c2                	cmp    %eax,%edx
80102270:	72 ad                	jb     8010221f <dirlink+0x47>
  }

  strncpy(de.name, name, DIRSIZ);
80102272:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102279:	00 
8010227a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010227d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102281:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102284:	83 c0 02             	add    $0x2,%eax
80102287:	89 04 24             	mov    %eax,(%esp)
8010228a:	e8 69 2f 00 00       	call   801051f8 <strncpy>
  de.inum = inum;
8010228f:	8b 45 10             	mov    0x10(%ebp),%eax
80102292:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102296:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102299:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801022a0:	00 
801022a1:	89 44 24 08          	mov    %eax,0x8(%esp)
801022a5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022a8:	89 44 24 04          	mov    %eax,0x4(%esp)
801022ac:	8b 45 08             	mov    0x8(%ebp),%eax
801022af:	89 04 24             	mov    %eax,(%esp)
801022b2:	e8 a7 fc ff ff       	call   80101f5e <writei>
801022b7:	83 f8 10             	cmp    $0x10,%eax
801022ba:	74 0c                	je     801022c8 <dirlink+0xf0>
    panic("dirlink");
801022bc:	c7 04 24 23 84 10 80 	movl   $0x80108423,(%esp)
801022c3:	e8 9a e2 ff ff       	call   80100562 <panic>

  return 0;
801022c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801022cd:	c9                   	leave  
801022ce:	c3                   	ret    

801022cf <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
801022cf:	55                   	push   %ebp
801022d0:	89 e5                	mov    %esp,%ebp
801022d2:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
801022d5:	eb 04                	jmp    801022db <skipelem+0xc>
    path++;
801022d7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801022db:	8b 45 08             	mov    0x8(%ebp),%eax
801022de:	0f b6 00             	movzbl (%eax),%eax
801022e1:	3c 2f                	cmp    $0x2f,%al
801022e3:	74 f2                	je     801022d7 <skipelem+0x8>
  if(*path == 0)
801022e5:	8b 45 08             	mov    0x8(%ebp),%eax
801022e8:	0f b6 00             	movzbl (%eax),%eax
801022eb:	84 c0                	test   %al,%al
801022ed:	75 0a                	jne    801022f9 <skipelem+0x2a>
    return 0;
801022ef:	b8 00 00 00 00       	mov    $0x0,%eax
801022f4:	e9 86 00 00 00       	jmp    8010237f <skipelem+0xb0>
  s = path;
801022f9:	8b 45 08             	mov    0x8(%ebp),%eax
801022fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801022ff:	eb 04                	jmp    80102305 <skipelem+0x36>
    path++;
80102301:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
80102305:	8b 45 08             	mov    0x8(%ebp),%eax
80102308:	0f b6 00             	movzbl (%eax),%eax
8010230b:	3c 2f                	cmp    $0x2f,%al
8010230d:	74 0a                	je     80102319 <skipelem+0x4a>
8010230f:	8b 45 08             	mov    0x8(%ebp),%eax
80102312:	0f b6 00             	movzbl (%eax),%eax
80102315:	84 c0                	test   %al,%al
80102317:	75 e8                	jne    80102301 <skipelem+0x32>
  len = path - s;
80102319:	8b 55 08             	mov    0x8(%ebp),%edx
8010231c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010231f:	29 c2                	sub    %eax,%edx
80102321:	89 d0                	mov    %edx,%eax
80102323:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102326:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
8010232a:	7e 1c                	jle    80102348 <skipelem+0x79>
    memmove(name, s, DIRSIZ);
8010232c:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102333:	00 
80102334:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102337:	89 44 24 04          	mov    %eax,0x4(%esp)
8010233b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010233e:	89 04 24             	mov    %eax,(%esp)
80102341:	e8 b9 2d 00 00       	call   801050ff <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102346:	eb 2a                	jmp    80102372 <skipelem+0xa3>
    memmove(name, s, len);
80102348:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010234b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010234f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102352:	89 44 24 04          	mov    %eax,0x4(%esp)
80102356:	8b 45 0c             	mov    0xc(%ebp),%eax
80102359:	89 04 24             	mov    %eax,(%esp)
8010235c:	e8 9e 2d 00 00       	call   801050ff <memmove>
    name[len] = 0;
80102361:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102364:	8b 45 0c             	mov    0xc(%ebp),%eax
80102367:	01 d0                	add    %edx,%eax
80102369:	c6 00 00             	movb   $0x0,(%eax)
  while(*path == '/')
8010236c:	eb 04                	jmp    80102372 <skipelem+0xa3>
    path++;
8010236e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
80102372:	8b 45 08             	mov    0x8(%ebp),%eax
80102375:	0f b6 00             	movzbl (%eax),%eax
80102378:	3c 2f                	cmp    $0x2f,%al
8010237a:	74 f2                	je     8010236e <skipelem+0x9f>
  return path;
8010237c:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010237f:	c9                   	leave  
80102380:	c3                   	ret    

80102381 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102381:	55                   	push   %ebp
80102382:	89 e5                	mov    %esp,%ebp
80102384:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102387:	8b 45 08             	mov    0x8(%ebp),%eax
8010238a:	0f b6 00             	movzbl (%eax),%eax
8010238d:	3c 2f                	cmp    $0x2f,%al
8010238f:	75 1c                	jne    801023ad <namex+0x2c>
    ip = iget(ROOTDEV, ROOTINO);
80102391:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102398:	00 
80102399:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801023a0:	e8 b1 f4 ff ff       	call   80101856 <iget>
801023a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(myproc()->cwd);

  while((path = skipelem(path, name)) != 0){
801023a8:	e9 ae 00 00 00       	jmp    8010245b <namex+0xda>
    ip = idup(myproc()->cwd);
801023ad:	e8 af 1d 00 00       	call   80104161 <myproc>
801023b2:	8b 40 68             	mov    0x68(%eax),%eax
801023b5:	89 04 24             	mov    %eax,(%esp)
801023b8:	e8 6e f5 ff ff       	call   8010192b <idup>
801023bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
801023c0:	e9 96 00 00 00       	jmp    8010245b <namex+0xda>
    ilock(ip);
801023c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023c8:	89 04 24             	mov    %eax,(%esp)
801023cb:	e8 8d f5 ff ff       	call   8010195d <ilock>
    if(ip->type != T_DIR){
801023d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023d3:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801023d7:	66 83 f8 01          	cmp    $0x1,%ax
801023db:	74 15                	je     801023f2 <namex+0x71>
      iunlockput(ip);
801023dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023e0:	89 04 24             	mov    %eax,(%esp)
801023e3:	e8 77 f7 ff ff       	call   80101b5f <iunlockput>
      return 0;
801023e8:	b8 00 00 00 00       	mov    $0x0,%eax
801023ed:	e9 a3 00 00 00       	jmp    80102495 <namex+0x114>
    }
    if(nameiparent && *path == '\0'){
801023f2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801023f6:	74 1d                	je     80102415 <namex+0x94>
801023f8:	8b 45 08             	mov    0x8(%ebp),%eax
801023fb:	0f b6 00             	movzbl (%eax),%eax
801023fe:	84 c0                	test   %al,%al
80102400:	75 13                	jne    80102415 <namex+0x94>
      // Stop one level early.
      iunlock(ip);
80102402:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102405:	89 04 24             	mov    %eax,(%esp)
80102408:	e8 5d f6 ff ff       	call   80101a6a <iunlock>
      return ip;
8010240d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102410:	e9 80 00 00 00       	jmp    80102495 <namex+0x114>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102415:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010241c:	00 
8010241d:	8b 45 10             	mov    0x10(%ebp),%eax
80102420:	89 44 24 04          	mov    %eax,0x4(%esp)
80102424:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102427:	89 04 24             	mov    %eax,(%esp)
8010242a:	e8 e0 fc ff ff       	call   8010210f <dirlookup>
8010242f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102432:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102436:	75 12                	jne    8010244a <namex+0xc9>
      iunlockput(ip);
80102438:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010243b:	89 04 24             	mov    %eax,(%esp)
8010243e:	e8 1c f7 ff ff       	call   80101b5f <iunlockput>
      return 0;
80102443:	b8 00 00 00 00       	mov    $0x0,%eax
80102448:	eb 4b                	jmp    80102495 <namex+0x114>
    }
    iunlockput(ip);
8010244a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010244d:	89 04 24             	mov    %eax,(%esp)
80102450:	e8 0a f7 ff ff       	call   80101b5f <iunlockput>
    ip = next;
80102455:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102458:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
8010245b:	8b 45 10             	mov    0x10(%ebp),%eax
8010245e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102462:	8b 45 08             	mov    0x8(%ebp),%eax
80102465:	89 04 24             	mov    %eax,(%esp)
80102468:	e8 62 fe ff ff       	call   801022cf <skipelem>
8010246d:	89 45 08             	mov    %eax,0x8(%ebp)
80102470:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102474:	0f 85 4b ff ff ff    	jne    801023c5 <namex+0x44>
  }
  if(nameiparent){
8010247a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010247e:	74 12                	je     80102492 <namex+0x111>
    iput(ip);
80102480:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102483:	89 04 24             	mov    %eax,(%esp)
80102486:	e8 23 f6 ff ff       	call   80101aae <iput>
    return 0;
8010248b:	b8 00 00 00 00       	mov    $0x0,%eax
80102490:	eb 03                	jmp    80102495 <namex+0x114>
  }
  return ip;
80102492:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102495:	c9                   	leave  
80102496:	c3                   	ret    

80102497 <namei>:

struct inode*
namei(char *path)
{
80102497:	55                   	push   %ebp
80102498:	89 e5                	mov    %esp,%ebp
8010249a:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
8010249d:	8d 45 ea             	lea    -0x16(%ebp),%eax
801024a0:	89 44 24 08          	mov    %eax,0x8(%esp)
801024a4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801024ab:	00 
801024ac:	8b 45 08             	mov    0x8(%ebp),%eax
801024af:	89 04 24             	mov    %eax,(%esp)
801024b2:	e8 ca fe ff ff       	call   80102381 <namex>
}
801024b7:	c9                   	leave  
801024b8:	c3                   	ret    

801024b9 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801024b9:	55                   	push   %ebp
801024ba:	89 e5                	mov    %esp,%ebp
801024bc:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
801024bf:	8b 45 0c             	mov    0xc(%ebp),%eax
801024c2:	89 44 24 08          	mov    %eax,0x8(%esp)
801024c6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801024cd:	00 
801024ce:	8b 45 08             	mov    0x8(%ebp),%eax
801024d1:	89 04 24             	mov    %eax,(%esp)
801024d4:	e8 a8 fe ff ff       	call   80102381 <namex>
}
801024d9:	c9                   	leave  
801024da:	c3                   	ret    

801024db <inb>:
{
801024db:	55                   	push   %ebp
801024dc:	89 e5                	mov    %esp,%ebp
801024de:	83 ec 14             	sub    $0x14,%esp
801024e1:	8b 45 08             	mov    0x8(%ebp),%eax
801024e4:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801024e8:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801024ec:	89 c2                	mov    %eax,%edx
801024ee:	ec                   	in     (%dx),%al
801024ef:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801024f2:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801024f6:	c9                   	leave  
801024f7:	c3                   	ret    

801024f8 <insl>:
{
801024f8:	55                   	push   %ebp
801024f9:	89 e5                	mov    %esp,%ebp
801024fb:	57                   	push   %edi
801024fc:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
801024fd:	8b 55 08             	mov    0x8(%ebp),%edx
80102500:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102503:	8b 45 10             	mov    0x10(%ebp),%eax
80102506:	89 cb                	mov    %ecx,%ebx
80102508:	89 df                	mov    %ebx,%edi
8010250a:	89 c1                	mov    %eax,%ecx
8010250c:	fc                   	cld    
8010250d:	f3 6d                	rep insl (%dx),%es:(%edi)
8010250f:	89 c8                	mov    %ecx,%eax
80102511:	89 fb                	mov    %edi,%ebx
80102513:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102516:	89 45 10             	mov    %eax,0x10(%ebp)
}
80102519:	5b                   	pop    %ebx
8010251a:	5f                   	pop    %edi
8010251b:	5d                   	pop    %ebp
8010251c:	c3                   	ret    

8010251d <outb>:
{
8010251d:	55                   	push   %ebp
8010251e:	89 e5                	mov    %esp,%ebp
80102520:	83 ec 08             	sub    $0x8,%esp
80102523:	8b 55 08             	mov    0x8(%ebp),%edx
80102526:	8b 45 0c             	mov    0xc(%ebp),%eax
80102529:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010252d:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102530:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102534:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102538:	ee                   	out    %al,(%dx)
}
80102539:	c9                   	leave  
8010253a:	c3                   	ret    

8010253b <outsl>:
{
8010253b:	55                   	push   %ebp
8010253c:	89 e5                	mov    %esp,%ebp
8010253e:	56                   	push   %esi
8010253f:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102540:	8b 55 08             	mov    0x8(%ebp),%edx
80102543:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102546:	8b 45 10             	mov    0x10(%ebp),%eax
80102549:	89 cb                	mov    %ecx,%ebx
8010254b:	89 de                	mov    %ebx,%esi
8010254d:	89 c1                	mov    %eax,%ecx
8010254f:	fc                   	cld    
80102550:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102552:	89 c8                	mov    %ecx,%eax
80102554:	89 f3                	mov    %esi,%ebx
80102556:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102559:	89 45 10             	mov    %eax,0x10(%ebp)
}
8010255c:	5b                   	pop    %ebx
8010255d:	5e                   	pop    %esi
8010255e:	5d                   	pop    %ebp
8010255f:	c3                   	ret    

80102560 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102560:	55                   	push   %ebp
80102561:	89 e5                	mov    %esp,%ebp
80102563:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80102566:	90                   	nop
80102567:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
8010256e:	e8 68 ff ff ff       	call   801024db <inb>
80102573:	0f b6 c0             	movzbl %al,%eax
80102576:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102579:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010257c:	25 c0 00 00 00       	and    $0xc0,%eax
80102581:	83 f8 40             	cmp    $0x40,%eax
80102584:	75 e1                	jne    80102567 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102586:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010258a:	74 11                	je     8010259d <idewait+0x3d>
8010258c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010258f:	83 e0 21             	and    $0x21,%eax
80102592:	85 c0                	test   %eax,%eax
80102594:	74 07                	je     8010259d <idewait+0x3d>
    return -1;
80102596:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010259b:	eb 05                	jmp    801025a2 <idewait+0x42>
  return 0;
8010259d:	b8 00 00 00 00       	mov    $0x0,%eax
}
801025a2:	c9                   	leave  
801025a3:	c3                   	ret    

801025a4 <ideinit>:

void
ideinit(void)
{
801025a4:	55                   	push   %ebp
801025a5:	89 e5                	mov    %esp,%ebp
801025a7:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
801025aa:	c7 44 24 04 2b 84 10 	movl   $0x8010842b,0x4(%esp)
801025b1:	80 
801025b2:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
801025b9:	e8 df 27 00 00       	call   80104d9d <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
801025be:	a1 80 3d 11 80       	mov    0x80113d80,%eax
801025c3:	83 e8 01             	sub    $0x1,%eax
801025c6:	89 44 24 04          	mov    %eax,0x4(%esp)
801025ca:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
801025d1:	e8 69 04 00 00       	call   80102a3f <ioapicenable>
  idewait(0);
801025d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801025dd:	e8 7e ff ff ff       	call   80102560 <idewait>

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
801025e2:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
801025e9:	00 
801025ea:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801025f1:	e8 27 ff ff ff       	call   8010251d <outb>
  for(i=0; i<1000; i++){
801025f6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801025fd:	eb 20                	jmp    8010261f <ideinit+0x7b>
    if(inb(0x1f7) != 0){
801025ff:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102606:	e8 d0 fe ff ff       	call   801024db <inb>
8010260b:	84 c0                	test   %al,%al
8010260d:	74 0c                	je     8010261b <ideinit+0x77>
      havedisk1 = 1;
8010260f:	c7 05 18 b6 10 80 01 	movl   $0x1,0x8010b618
80102616:	00 00 00 
      break;
80102619:	eb 0d                	jmp    80102628 <ideinit+0x84>
  for(i=0; i<1000; i++){
8010261b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010261f:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102626:	7e d7                	jle    801025ff <ideinit+0x5b>
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102628:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
8010262f:	00 
80102630:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102637:	e8 e1 fe ff ff       	call   8010251d <outb>
}
8010263c:	c9                   	leave  
8010263d:	c3                   	ret    

8010263e <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
8010263e:	55                   	push   %ebp
8010263f:	89 e5                	mov    %esp,%ebp
80102641:	83 ec 28             	sub    $0x28,%esp
  if(b == 0)
80102644:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102648:	75 0c                	jne    80102656 <idestart+0x18>
    panic("idestart");
8010264a:	c7 04 24 2f 84 10 80 	movl   $0x8010842f,(%esp)
80102651:	e8 0c df ff ff       	call   80100562 <panic>
  if(b->blockno >= FSSIZE)
80102656:	8b 45 08             	mov    0x8(%ebp),%eax
80102659:	8b 40 08             	mov    0x8(%eax),%eax
8010265c:	3d e7 03 00 00       	cmp    $0x3e7,%eax
80102661:	76 0c                	jbe    8010266f <idestart+0x31>
    panic("incorrect blockno");
80102663:	c7 04 24 38 84 10 80 	movl   $0x80108438,(%esp)
8010266a:	e8 f3 de ff ff       	call   80100562 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
8010266f:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102676:	8b 45 08             	mov    0x8(%ebp),%eax
80102679:	8b 50 08             	mov    0x8(%eax),%edx
8010267c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010267f:	0f af c2             	imul   %edx,%eax
80102682:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
80102685:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102689:	75 07                	jne    80102692 <idestart+0x54>
8010268b:	b8 20 00 00 00       	mov    $0x20,%eax
80102690:	eb 05                	jmp    80102697 <idestart+0x59>
80102692:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102697:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
8010269a:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
8010269e:	75 07                	jne    801026a7 <idestart+0x69>
801026a0:	b8 30 00 00 00       	mov    $0x30,%eax
801026a5:	eb 05                	jmp    801026ac <idestart+0x6e>
801026a7:	b8 c5 00 00 00       	mov    $0xc5,%eax
801026ac:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
801026af:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
801026b3:	7e 0c                	jle    801026c1 <idestart+0x83>
801026b5:	c7 04 24 2f 84 10 80 	movl   $0x8010842f,(%esp)
801026bc:	e8 a1 de ff ff       	call   80100562 <panic>

  idewait(0);
801026c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801026c8:	e8 93 fe ff ff       	call   80102560 <idewait>
  outb(0x3f6, 0);  // generate interrupt
801026cd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801026d4:	00 
801026d5:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
801026dc:	e8 3c fe ff ff       	call   8010251d <outb>
  outb(0x1f2, sector_per_block);  // number of sectors
801026e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026e4:	0f b6 c0             	movzbl %al,%eax
801026e7:	89 44 24 04          	mov    %eax,0x4(%esp)
801026eb:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
801026f2:	e8 26 fe ff ff       	call   8010251d <outb>
  outb(0x1f3, sector & 0xff);
801026f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801026fa:	0f b6 c0             	movzbl %al,%eax
801026fd:	89 44 24 04          	mov    %eax,0x4(%esp)
80102701:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
80102708:	e8 10 fe ff ff       	call   8010251d <outb>
  outb(0x1f4, (sector >> 8) & 0xff);
8010270d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102710:	c1 f8 08             	sar    $0x8,%eax
80102713:	0f b6 c0             	movzbl %al,%eax
80102716:	89 44 24 04          	mov    %eax,0x4(%esp)
8010271a:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
80102721:	e8 f7 fd ff ff       	call   8010251d <outb>
  outb(0x1f5, (sector >> 16) & 0xff);
80102726:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102729:	c1 f8 10             	sar    $0x10,%eax
8010272c:	0f b6 c0             	movzbl %al,%eax
8010272f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102733:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
8010273a:	e8 de fd ff ff       	call   8010251d <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
8010273f:	8b 45 08             	mov    0x8(%ebp),%eax
80102742:	8b 40 04             	mov    0x4(%eax),%eax
80102745:	83 e0 01             	and    $0x1,%eax
80102748:	c1 e0 04             	shl    $0x4,%eax
8010274b:	89 c2                	mov    %eax,%edx
8010274d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102750:	c1 f8 18             	sar    $0x18,%eax
80102753:	83 e0 0f             	and    $0xf,%eax
80102756:	09 d0                	or     %edx,%eax
80102758:	83 c8 e0             	or     $0xffffffe0,%eax
8010275b:	0f b6 c0             	movzbl %al,%eax
8010275e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102762:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102769:	e8 af fd ff ff       	call   8010251d <outb>
  if(b->flags & B_DIRTY){
8010276e:	8b 45 08             	mov    0x8(%ebp),%eax
80102771:	8b 00                	mov    (%eax),%eax
80102773:	83 e0 04             	and    $0x4,%eax
80102776:	85 c0                	test   %eax,%eax
80102778:	74 36                	je     801027b0 <idestart+0x172>
    outb(0x1f7, write_cmd);
8010277a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010277d:	0f b6 c0             	movzbl %al,%eax
80102780:	89 44 24 04          	mov    %eax,0x4(%esp)
80102784:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
8010278b:	e8 8d fd ff ff       	call   8010251d <outb>
    outsl(0x1f0, b->data, BSIZE/4);
80102790:	8b 45 08             	mov    0x8(%ebp),%eax
80102793:	83 c0 5c             	add    $0x5c,%eax
80102796:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
8010279d:	00 
8010279e:	89 44 24 04          	mov    %eax,0x4(%esp)
801027a2:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
801027a9:	e8 8d fd ff ff       	call   8010253b <outsl>
801027ae:	eb 16                	jmp    801027c6 <idestart+0x188>
  } else {
    outb(0x1f7, read_cmd);
801027b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801027b3:	0f b6 c0             	movzbl %al,%eax
801027b6:	89 44 24 04          	mov    %eax,0x4(%esp)
801027ba:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801027c1:	e8 57 fd ff ff       	call   8010251d <outb>
  }
}
801027c6:	c9                   	leave  
801027c7:	c3                   	ret    

801027c8 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
801027c8:	55                   	push   %ebp
801027c9:	89 e5                	mov    %esp,%ebp
801027cb:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
801027ce:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
801027d5:	e8 e4 25 00 00       	call   80104dbe <acquire>

  if((b = idequeue) == 0){
801027da:	a1 14 b6 10 80       	mov    0x8010b614,%eax
801027df:	89 45 f4             	mov    %eax,-0xc(%ebp)
801027e2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801027e6:	75 11                	jne    801027f9 <ideintr+0x31>
    release(&idelock);
801027e8:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
801027ef:	e8 32 26 00 00       	call   80104e26 <release>
    return;
801027f4:	e9 90 00 00 00       	jmp    80102889 <ideintr+0xc1>
  }
  idequeue = b->qnext;
801027f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027fc:	8b 40 58             	mov    0x58(%eax),%eax
801027ff:	a3 14 b6 10 80       	mov    %eax,0x8010b614

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102804:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102807:	8b 00                	mov    (%eax),%eax
80102809:	83 e0 04             	and    $0x4,%eax
8010280c:	85 c0                	test   %eax,%eax
8010280e:	75 2e                	jne    8010283e <ideintr+0x76>
80102810:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102817:	e8 44 fd ff ff       	call   80102560 <idewait>
8010281c:	85 c0                	test   %eax,%eax
8010281e:	78 1e                	js     8010283e <ideintr+0x76>
    insl(0x1f0, b->data, BSIZE/4);
80102820:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102823:	83 c0 5c             	add    $0x5c,%eax
80102826:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
8010282d:	00 
8010282e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102832:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102839:	e8 ba fc ff ff       	call   801024f8 <insl>

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
8010283e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102841:	8b 00                	mov    (%eax),%eax
80102843:	83 c8 02             	or     $0x2,%eax
80102846:	89 c2                	mov    %eax,%edx
80102848:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010284b:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
8010284d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102850:	8b 00                	mov    (%eax),%eax
80102852:	83 e0 fb             	and    $0xfffffffb,%eax
80102855:	89 c2                	mov    %eax,%edx
80102857:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010285a:	89 10                	mov    %edx,(%eax)
  wakeup(b);
8010285c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010285f:	89 04 24             	mov    %eax,(%esp)
80102862:	e8 39 22 00 00       	call   80104aa0 <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80102867:	a1 14 b6 10 80       	mov    0x8010b614,%eax
8010286c:	85 c0                	test   %eax,%eax
8010286e:	74 0d                	je     8010287d <ideintr+0xb5>
    idestart(idequeue);
80102870:	a1 14 b6 10 80       	mov    0x8010b614,%eax
80102875:	89 04 24             	mov    %eax,(%esp)
80102878:	e8 c1 fd ff ff       	call   8010263e <idestart>

  release(&idelock);
8010287d:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80102884:	e8 9d 25 00 00       	call   80104e26 <release>
}
80102889:	c9                   	leave  
8010288a:	c3                   	ret    

8010288b <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010288b:	55                   	push   %ebp
8010288c:	89 e5                	mov    %esp,%ebp
8010288e:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80102891:	8b 45 08             	mov    0x8(%ebp),%eax
80102894:	83 c0 0c             	add    $0xc,%eax
80102897:	89 04 24             	mov    %eax,(%esp)
8010289a:	e8 72 24 00 00       	call   80104d11 <holdingsleep>
8010289f:	85 c0                	test   %eax,%eax
801028a1:	75 0c                	jne    801028af <iderw+0x24>
    panic("iderw: buf not locked");
801028a3:	c7 04 24 4a 84 10 80 	movl   $0x8010844a,(%esp)
801028aa:	e8 b3 dc ff ff       	call   80100562 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801028af:	8b 45 08             	mov    0x8(%ebp),%eax
801028b2:	8b 00                	mov    (%eax),%eax
801028b4:	83 e0 06             	and    $0x6,%eax
801028b7:	83 f8 02             	cmp    $0x2,%eax
801028ba:	75 0c                	jne    801028c8 <iderw+0x3d>
    panic("iderw: nothing to do");
801028bc:	c7 04 24 60 84 10 80 	movl   $0x80108460,(%esp)
801028c3:	e8 9a dc ff ff       	call   80100562 <panic>
  if(b->dev != 0 && !havedisk1)
801028c8:	8b 45 08             	mov    0x8(%ebp),%eax
801028cb:	8b 40 04             	mov    0x4(%eax),%eax
801028ce:	85 c0                	test   %eax,%eax
801028d0:	74 15                	je     801028e7 <iderw+0x5c>
801028d2:	a1 18 b6 10 80       	mov    0x8010b618,%eax
801028d7:	85 c0                	test   %eax,%eax
801028d9:	75 0c                	jne    801028e7 <iderw+0x5c>
    panic("iderw: ide disk 1 not present");
801028db:	c7 04 24 75 84 10 80 	movl   $0x80108475,(%esp)
801028e2:	e8 7b dc ff ff       	call   80100562 <panic>

  acquire(&idelock);  //DOC:acquire-lock
801028e7:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
801028ee:	e8 cb 24 00 00       	call   80104dbe <acquire>

  // Append b to idequeue.
  b->qnext = 0;
801028f3:	8b 45 08             	mov    0x8(%ebp),%eax
801028f6:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801028fd:	c7 45 f4 14 b6 10 80 	movl   $0x8010b614,-0xc(%ebp)
80102904:	eb 0b                	jmp    80102911 <iderw+0x86>
80102906:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102909:	8b 00                	mov    (%eax),%eax
8010290b:	83 c0 58             	add    $0x58,%eax
8010290e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102911:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102914:	8b 00                	mov    (%eax),%eax
80102916:	85 c0                	test   %eax,%eax
80102918:	75 ec                	jne    80102906 <iderw+0x7b>
    ;
  *pp = b;
8010291a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010291d:	8b 55 08             	mov    0x8(%ebp),%edx
80102920:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
80102922:	a1 14 b6 10 80       	mov    0x8010b614,%eax
80102927:	3b 45 08             	cmp    0x8(%ebp),%eax
8010292a:	75 0d                	jne    80102939 <iderw+0xae>
    idestart(b);
8010292c:	8b 45 08             	mov    0x8(%ebp),%eax
8010292f:	89 04 24             	mov    %eax,(%esp)
80102932:	e8 07 fd ff ff       	call   8010263e <idestart>

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102937:	eb 15                	jmp    8010294e <iderw+0xc3>
80102939:	eb 13                	jmp    8010294e <iderw+0xc3>
    sleep(b, &idelock);
8010293b:	c7 44 24 04 e0 b5 10 	movl   $0x8010b5e0,0x4(%esp)
80102942:	80 
80102943:	8b 45 08             	mov    0x8(%ebp),%eax
80102946:	89 04 24             	mov    %eax,(%esp)
80102949:	e8 7e 20 00 00       	call   801049cc <sleep>
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010294e:	8b 45 08             	mov    0x8(%ebp),%eax
80102951:	8b 00                	mov    (%eax),%eax
80102953:	83 e0 06             	and    $0x6,%eax
80102956:	83 f8 02             	cmp    $0x2,%eax
80102959:	75 e0                	jne    8010293b <iderw+0xb0>
  }


  release(&idelock);
8010295b:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80102962:	e8 bf 24 00 00       	call   80104e26 <release>
}
80102967:	c9                   	leave  
80102968:	c3                   	ret    

80102969 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102969:	55                   	push   %ebp
8010296a:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010296c:	a1 b4 36 11 80       	mov    0x801136b4,%eax
80102971:	8b 55 08             	mov    0x8(%ebp),%edx
80102974:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102976:	a1 b4 36 11 80       	mov    0x801136b4,%eax
8010297b:	8b 40 10             	mov    0x10(%eax),%eax
}
8010297e:	5d                   	pop    %ebp
8010297f:	c3                   	ret    

80102980 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102980:	55                   	push   %ebp
80102981:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102983:	a1 b4 36 11 80       	mov    0x801136b4,%eax
80102988:	8b 55 08             	mov    0x8(%ebp),%edx
8010298b:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
8010298d:	a1 b4 36 11 80       	mov    0x801136b4,%eax
80102992:	8b 55 0c             	mov    0xc(%ebp),%edx
80102995:	89 50 10             	mov    %edx,0x10(%eax)
}
80102998:	5d                   	pop    %ebp
80102999:	c3                   	ret    

8010299a <ioapicinit>:

void
ioapicinit(void)
{
8010299a:	55                   	push   %ebp
8010299b:	89 e5                	mov    %esp,%ebp
8010299d:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
801029a0:	c7 05 b4 36 11 80 00 	movl   $0xfec00000,0x801136b4
801029a7:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
801029aa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801029b1:	e8 b3 ff ff ff       	call   80102969 <ioapicread>
801029b6:	c1 e8 10             	shr    $0x10,%eax
801029b9:	25 ff 00 00 00       	and    $0xff,%eax
801029be:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801029c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801029c8:	e8 9c ff ff ff       	call   80102969 <ioapicread>
801029cd:	c1 e8 18             	shr    $0x18,%eax
801029d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801029d3:	0f b6 05 e0 37 11 80 	movzbl 0x801137e0,%eax
801029da:	0f b6 c0             	movzbl %al,%eax
801029dd:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801029e0:	74 0c                	je     801029ee <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801029e2:	c7 04 24 94 84 10 80 	movl   $0x80108494,(%esp)
801029e9:	e8 da d9 ff ff       	call   801003c8 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801029ee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801029f5:	eb 3e                	jmp    80102a35 <ioapicinit+0x9b>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801029f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029fa:	83 c0 20             	add    $0x20,%eax
801029fd:	0d 00 00 01 00       	or     $0x10000,%eax
80102a02:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102a05:	83 c2 08             	add    $0x8,%edx
80102a08:	01 d2                	add    %edx,%edx
80102a0a:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a0e:	89 14 24             	mov    %edx,(%esp)
80102a11:	e8 6a ff ff ff       	call   80102980 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102a16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a19:	83 c0 08             	add    $0x8,%eax
80102a1c:	01 c0                	add    %eax,%eax
80102a1e:	83 c0 01             	add    $0x1,%eax
80102a21:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102a28:	00 
80102a29:	89 04 24             	mov    %eax,(%esp)
80102a2c:	e8 4f ff ff ff       	call   80102980 <ioapicwrite>
  for(i = 0; i <= maxintr; i++){
80102a31:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102a35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a38:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102a3b:	7e ba                	jle    801029f7 <ioapicinit+0x5d>
  }
}
80102a3d:	c9                   	leave  
80102a3e:	c3                   	ret    

80102a3f <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102a3f:	55                   	push   %ebp
80102a40:	89 e5                	mov    %esp,%ebp
80102a42:	83 ec 08             	sub    $0x8,%esp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102a45:	8b 45 08             	mov    0x8(%ebp),%eax
80102a48:	83 c0 20             	add    $0x20,%eax
80102a4b:	8b 55 08             	mov    0x8(%ebp),%edx
80102a4e:	83 c2 08             	add    $0x8,%edx
80102a51:	01 d2                	add    %edx,%edx
80102a53:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a57:	89 14 24             	mov    %edx,(%esp)
80102a5a:	e8 21 ff ff ff       	call   80102980 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102a5f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a62:	c1 e0 18             	shl    $0x18,%eax
80102a65:	8b 55 08             	mov    0x8(%ebp),%edx
80102a68:	83 c2 08             	add    $0x8,%edx
80102a6b:	01 d2                	add    %edx,%edx
80102a6d:	83 c2 01             	add    $0x1,%edx
80102a70:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a74:	89 14 24             	mov    %edx,(%esp)
80102a77:	e8 04 ff ff ff       	call   80102980 <ioapicwrite>
}
80102a7c:	c9                   	leave  
80102a7d:	c3                   	ret    

80102a7e <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102a7e:	55                   	push   %ebp
80102a7f:	89 e5                	mov    %esp,%ebp
80102a81:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102a84:	c7 44 24 04 c6 84 10 	movl   $0x801084c6,0x4(%esp)
80102a8b:	80 
80102a8c:	c7 04 24 c0 36 11 80 	movl   $0x801136c0,(%esp)
80102a93:	e8 05 23 00 00       	call   80104d9d <initlock>
  kmem.use_lock = 0;
80102a98:	c7 05 f4 36 11 80 00 	movl   $0x0,0x801136f4
80102a9f:	00 00 00 
  freerange(vstart, vend);
80102aa2:	8b 45 0c             	mov    0xc(%ebp),%eax
80102aa5:	89 44 24 04          	mov    %eax,0x4(%esp)
80102aa9:	8b 45 08             	mov    0x8(%ebp),%eax
80102aac:	89 04 24             	mov    %eax,(%esp)
80102aaf:	e8 26 00 00 00       	call   80102ada <freerange>
}
80102ab4:	c9                   	leave  
80102ab5:	c3                   	ret    

80102ab6 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102ab6:	55                   	push   %ebp
80102ab7:	89 e5                	mov    %esp,%ebp
80102ab9:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102abc:	8b 45 0c             	mov    0xc(%ebp),%eax
80102abf:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ac3:	8b 45 08             	mov    0x8(%ebp),%eax
80102ac6:	89 04 24             	mov    %eax,(%esp)
80102ac9:	e8 0c 00 00 00       	call   80102ada <freerange>
  kmem.use_lock = 1;
80102ace:	c7 05 f4 36 11 80 01 	movl   $0x1,0x801136f4
80102ad5:	00 00 00 
}
80102ad8:	c9                   	leave  
80102ad9:	c3                   	ret    

80102ada <freerange>:

void
freerange(void *vstart, void *vend)
{
80102ada:	55                   	push   %ebp
80102adb:	89 e5                	mov    %esp,%ebp
80102add:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102ae0:	8b 45 08             	mov    0x8(%ebp),%eax
80102ae3:	05 ff 0f 00 00       	add    $0xfff,%eax
80102ae8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102aed:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102af0:	eb 12                	jmp    80102b04 <freerange+0x2a>
    kfree(p);
80102af2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102af5:	89 04 24             	mov    %eax,(%esp)
80102af8:	e8 16 00 00 00       	call   80102b13 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102afd:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102b04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b07:	05 00 10 00 00       	add    $0x1000,%eax
80102b0c:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102b0f:	76 e1                	jbe    80102af2 <freerange+0x18>
}
80102b11:	c9                   	leave  
80102b12:	c3                   	ret    

80102b13 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102b13:	55                   	push   %ebp
80102b14:	89 e5                	mov    %esp,%ebp
80102b16:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102b19:	8b 45 08             	mov    0x8(%ebp),%eax
80102b1c:	25 ff 0f 00 00       	and    $0xfff,%eax
80102b21:	85 c0                	test   %eax,%eax
80102b23:	75 18                	jne    80102b3d <kfree+0x2a>
80102b25:	81 7d 08 28 65 11 80 	cmpl   $0x80116528,0x8(%ebp)
80102b2c:	72 0f                	jb     80102b3d <kfree+0x2a>
80102b2e:	8b 45 08             	mov    0x8(%ebp),%eax
80102b31:	05 00 00 00 80       	add    $0x80000000,%eax
80102b36:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102b3b:	76 0c                	jbe    80102b49 <kfree+0x36>
    panic("kfree");
80102b3d:	c7 04 24 cb 84 10 80 	movl   $0x801084cb,(%esp)
80102b44:	e8 19 da ff ff       	call   80100562 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102b49:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102b50:	00 
80102b51:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102b58:	00 
80102b59:	8b 45 08             	mov    0x8(%ebp),%eax
80102b5c:	89 04 24             	mov    %eax,(%esp)
80102b5f:	e8 cc 24 00 00       	call   80105030 <memset>

  if(kmem.use_lock)
80102b64:	a1 f4 36 11 80       	mov    0x801136f4,%eax
80102b69:	85 c0                	test   %eax,%eax
80102b6b:	74 0c                	je     80102b79 <kfree+0x66>
    acquire(&kmem.lock);
80102b6d:	c7 04 24 c0 36 11 80 	movl   $0x801136c0,(%esp)
80102b74:	e8 45 22 00 00       	call   80104dbe <acquire>
  r = (struct run*)v;
80102b79:	8b 45 08             	mov    0x8(%ebp),%eax
80102b7c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102b7f:	8b 15 f8 36 11 80    	mov    0x801136f8,%edx
80102b85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b88:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102b8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b8d:	a3 f8 36 11 80       	mov    %eax,0x801136f8
  if(kmem.use_lock)
80102b92:	a1 f4 36 11 80       	mov    0x801136f4,%eax
80102b97:	85 c0                	test   %eax,%eax
80102b99:	74 0c                	je     80102ba7 <kfree+0x94>
    release(&kmem.lock);
80102b9b:	c7 04 24 c0 36 11 80 	movl   $0x801136c0,(%esp)
80102ba2:	e8 7f 22 00 00       	call   80104e26 <release>
}
80102ba7:	c9                   	leave  
80102ba8:	c3                   	ret    

80102ba9 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102ba9:	55                   	push   %ebp
80102baa:	89 e5                	mov    %esp,%ebp
80102bac:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102baf:	a1 f4 36 11 80       	mov    0x801136f4,%eax
80102bb4:	85 c0                	test   %eax,%eax
80102bb6:	74 0c                	je     80102bc4 <kalloc+0x1b>
    acquire(&kmem.lock);
80102bb8:	c7 04 24 c0 36 11 80 	movl   $0x801136c0,(%esp)
80102bbf:	e8 fa 21 00 00       	call   80104dbe <acquire>
  r = kmem.freelist;
80102bc4:	a1 f8 36 11 80       	mov    0x801136f8,%eax
80102bc9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102bcc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102bd0:	74 0a                	je     80102bdc <kalloc+0x33>
    kmem.freelist = r->next;
80102bd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bd5:	8b 00                	mov    (%eax),%eax
80102bd7:	a3 f8 36 11 80       	mov    %eax,0x801136f8
  if(kmem.use_lock)
80102bdc:	a1 f4 36 11 80       	mov    0x801136f4,%eax
80102be1:	85 c0                	test   %eax,%eax
80102be3:	74 0c                	je     80102bf1 <kalloc+0x48>
    release(&kmem.lock);
80102be5:	c7 04 24 c0 36 11 80 	movl   $0x801136c0,(%esp)
80102bec:	e8 35 22 00 00       	call   80104e26 <release>
  return (char*)r;
80102bf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102bf4:	c9                   	leave  
80102bf5:	c3                   	ret    

80102bf6 <inb>:
{
80102bf6:	55                   	push   %ebp
80102bf7:	89 e5                	mov    %esp,%ebp
80102bf9:	83 ec 14             	sub    $0x14,%esp
80102bfc:	8b 45 08             	mov    0x8(%ebp),%eax
80102bff:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c03:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102c07:	89 c2                	mov    %eax,%edx
80102c09:	ec                   	in     (%dx),%al
80102c0a:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102c0d:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102c11:	c9                   	leave  
80102c12:	c3                   	ret    

80102c13 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102c13:	55                   	push   %ebp
80102c14:	89 e5                	mov    %esp,%ebp
80102c16:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102c19:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102c20:	e8 d1 ff ff ff       	call   80102bf6 <inb>
80102c25:	0f b6 c0             	movzbl %al,%eax
80102c28:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102c2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c2e:	83 e0 01             	and    $0x1,%eax
80102c31:	85 c0                	test   %eax,%eax
80102c33:	75 0a                	jne    80102c3f <kbdgetc+0x2c>
    return -1;
80102c35:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102c3a:	e9 25 01 00 00       	jmp    80102d64 <kbdgetc+0x151>
  data = inb(KBDATAP);
80102c3f:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102c46:	e8 ab ff ff ff       	call   80102bf6 <inb>
80102c4b:	0f b6 c0             	movzbl %al,%eax
80102c4e:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102c51:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102c58:	75 17                	jne    80102c71 <kbdgetc+0x5e>
    shift |= E0ESC;
80102c5a:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102c5f:	83 c8 40             	or     $0x40,%eax
80102c62:	a3 1c b6 10 80       	mov    %eax,0x8010b61c
    return 0;
80102c67:	b8 00 00 00 00       	mov    $0x0,%eax
80102c6c:	e9 f3 00 00 00       	jmp    80102d64 <kbdgetc+0x151>
  } else if(data & 0x80){
80102c71:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c74:	25 80 00 00 00       	and    $0x80,%eax
80102c79:	85 c0                	test   %eax,%eax
80102c7b:	74 45                	je     80102cc2 <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102c7d:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102c82:	83 e0 40             	and    $0x40,%eax
80102c85:	85 c0                	test   %eax,%eax
80102c87:	75 08                	jne    80102c91 <kbdgetc+0x7e>
80102c89:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c8c:	83 e0 7f             	and    $0x7f,%eax
80102c8f:	eb 03                	jmp    80102c94 <kbdgetc+0x81>
80102c91:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c94:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102c97:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c9a:	05 20 90 10 80       	add    $0x80109020,%eax
80102c9f:	0f b6 00             	movzbl (%eax),%eax
80102ca2:	83 c8 40             	or     $0x40,%eax
80102ca5:	0f b6 c0             	movzbl %al,%eax
80102ca8:	f7 d0                	not    %eax
80102caa:	89 c2                	mov    %eax,%edx
80102cac:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102cb1:	21 d0                	and    %edx,%eax
80102cb3:	a3 1c b6 10 80       	mov    %eax,0x8010b61c
    return 0;
80102cb8:	b8 00 00 00 00       	mov    $0x0,%eax
80102cbd:	e9 a2 00 00 00       	jmp    80102d64 <kbdgetc+0x151>
  } else if(shift & E0ESC){
80102cc2:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102cc7:	83 e0 40             	and    $0x40,%eax
80102cca:	85 c0                	test   %eax,%eax
80102ccc:	74 14                	je     80102ce2 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102cce:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102cd5:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102cda:	83 e0 bf             	and    $0xffffffbf,%eax
80102cdd:	a3 1c b6 10 80       	mov    %eax,0x8010b61c
  }

  shift |= shiftcode[data];
80102ce2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ce5:	05 20 90 10 80       	add    $0x80109020,%eax
80102cea:	0f b6 00             	movzbl (%eax),%eax
80102ced:	0f b6 d0             	movzbl %al,%edx
80102cf0:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102cf5:	09 d0                	or     %edx,%eax
80102cf7:	a3 1c b6 10 80       	mov    %eax,0x8010b61c
  shift ^= togglecode[data];
80102cfc:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102cff:	05 20 91 10 80       	add    $0x80109120,%eax
80102d04:	0f b6 00             	movzbl (%eax),%eax
80102d07:	0f b6 d0             	movzbl %al,%edx
80102d0a:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102d0f:	31 d0                	xor    %edx,%eax
80102d11:	a3 1c b6 10 80       	mov    %eax,0x8010b61c
  c = charcode[shift & (CTL | SHIFT)][data];
80102d16:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102d1b:	83 e0 03             	and    $0x3,%eax
80102d1e:	8b 14 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%edx
80102d25:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d28:	01 d0                	add    %edx,%eax
80102d2a:	0f b6 00             	movzbl (%eax),%eax
80102d2d:	0f b6 c0             	movzbl %al,%eax
80102d30:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102d33:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102d38:	83 e0 08             	and    $0x8,%eax
80102d3b:	85 c0                	test   %eax,%eax
80102d3d:	74 22                	je     80102d61 <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80102d3f:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102d43:	76 0c                	jbe    80102d51 <kbdgetc+0x13e>
80102d45:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102d49:	77 06                	ja     80102d51 <kbdgetc+0x13e>
      c += 'A' - 'a';
80102d4b:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102d4f:	eb 10                	jmp    80102d61 <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80102d51:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102d55:	76 0a                	jbe    80102d61 <kbdgetc+0x14e>
80102d57:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102d5b:	77 04                	ja     80102d61 <kbdgetc+0x14e>
      c += 'a' - 'A';
80102d5d:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102d61:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102d64:	c9                   	leave  
80102d65:	c3                   	ret    

80102d66 <kbdintr>:

void
kbdintr(void)
{
80102d66:	55                   	push   %ebp
80102d67:	89 e5                	mov    %esp,%ebp
80102d69:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102d6c:	c7 04 24 13 2c 10 80 	movl   $0x80102c13,(%esp)
80102d73:	e8 71 da ff ff       	call   801007e9 <consoleintr>
}
80102d78:	c9                   	leave  
80102d79:	c3                   	ret    

80102d7a <inb>:
{
80102d7a:	55                   	push   %ebp
80102d7b:	89 e5                	mov    %esp,%ebp
80102d7d:	83 ec 14             	sub    $0x14,%esp
80102d80:	8b 45 08             	mov    0x8(%ebp),%eax
80102d83:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d87:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102d8b:	89 c2                	mov    %eax,%edx
80102d8d:	ec                   	in     (%dx),%al
80102d8e:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102d91:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102d95:	c9                   	leave  
80102d96:	c3                   	ret    

80102d97 <outb>:
{
80102d97:	55                   	push   %ebp
80102d98:	89 e5                	mov    %esp,%ebp
80102d9a:	83 ec 08             	sub    $0x8,%esp
80102d9d:	8b 55 08             	mov    0x8(%ebp),%edx
80102da0:	8b 45 0c             	mov    0xc(%ebp),%eax
80102da3:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102da7:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102daa:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102dae:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102db2:	ee                   	out    %al,(%dx)
}
80102db3:	c9                   	leave  
80102db4:	c3                   	ret    

80102db5 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102db5:	55                   	push   %ebp
80102db6:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102db8:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102dbd:	8b 55 08             	mov    0x8(%ebp),%edx
80102dc0:	c1 e2 02             	shl    $0x2,%edx
80102dc3:	01 c2                	add    %eax,%edx
80102dc5:	8b 45 0c             	mov    0xc(%ebp),%eax
80102dc8:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102dca:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102dcf:	83 c0 20             	add    $0x20,%eax
80102dd2:	8b 00                	mov    (%eax),%eax
}
80102dd4:	5d                   	pop    %ebp
80102dd5:	c3                   	ret    

80102dd6 <lapicinit>:

void
lapicinit(void)
{
80102dd6:	55                   	push   %ebp
80102dd7:	89 e5                	mov    %esp,%ebp
80102dd9:	83 ec 08             	sub    $0x8,%esp
  if(!lapic)
80102ddc:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102de1:	85 c0                	test   %eax,%eax
80102de3:	75 05                	jne    80102dea <lapicinit+0x14>
    return;
80102de5:	e9 43 01 00 00       	jmp    80102f2d <lapicinit+0x157>

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102dea:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80102df1:	00 
80102df2:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80102df9:	e8 b7 ff ff ff       	call   80102db5 <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102dfe:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80102e05:	00 
80102e06:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80102e0d:	e8 a3 ff ff ff       	call   80102db5 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102e12:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80102e19:	00 
80102e1a:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102e21:	e8 8f ff ff ff       	call   80102db5 <lapicw>
  lapicw(TICR, 10000000);
80102e26:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80102e2d:	00 
80102e2e:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
80102e35:	e8 7b ff ff ff       	call   80102db5 <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102e3a:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102e41:	00 
80102e42:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
80102e49:	e8 67 ff ff ff       	call   80102db5 <lapicw>
  lapicw(LINT1, MASKED);
80102e4e:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102e55:	00 
80102e56:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80102e5d:	e8 53 ff ff ff       	call   80102db5 <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102e62:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102e67:	83 c0 30             	add    $0x30,%eax
80102e6a:	8b 00                	mov    (%eax),%eax
80102e6c:	c1 e8 10             	shr    $0x10,%eax
80102e6f:	0f b6 c0             	movzbl %al,%eax
80102e72:	83 f8 03             	cmp    $0x3,%eax
80102e75:	76 14                	jbe    80102e8b <lapicinit+0xb5>
    lapicw(PCINT, MASKED);
80102e77:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102e7e:	00 
80102e7f:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80102e86:	e8 2a ff ff ff       	call   80102db5 <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102e8b:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80102e92:	00 
80102e93:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80102e9a:	e8 16 ff ff ff       	call   80102db5 <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102e9f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102ea6:	00 
80102ea7:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102eae:	e8 02 ff ff ff       	call   80102db5 <lapicw>
  lapicw(ESR, 0);
80102eb3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102eba:	00 
80102ebb:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102ec2:	e8 ee fe ff ff       	call   80102db5 <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102ec7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102ece:	00 
80102ecf:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102ed6:	e8 da fe ff ff       	call   80102db5 <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102edb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102ee2:	00 
80102ee3:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102eea:	e8 c6 fe ff ff       	call   80102db5 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102eef:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80102ef6:	00 
80102ef7:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102efe:	e8 b2 fe ff ff       	call   80102db5 <lapicw>
  while(lapic[ICRLO] & DELIVS)
80102f03:	90                   	nop
80102f04:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102f09:	05 00 03 00 00       	add    $0x300,%eax
80102f0e:	8b 00                	mov    (%eax),%eax
80102f10:	25 00 10 00 00       	and    $0x1000,%eax
80102f15:	85 c0                	test   %eax,%eax
80102f17:	75 eb                	jne    80102f04 <lapicinit+0x12e>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102f19:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102f20:	00 
80102f21:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80102f28:	e8 88 fe ff ff       	call   80102db5 <lapicw>
}
80102f2d:	c9                   	leave  
80102f2e:	c3                   	ret    

80102f2f <lapicid>:

int
lapicid(void)
{
80102f2f:	55                   	push   %ebp
80102f30:	89 e5                	mov    %esp,%ebp
  if (!lapic)
80102f32:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102f37:	85 c0                	test   %eax,%eax
80102f39:	75 07                	jne    80102f42 <lapicid+0x13>
    return 0;
80102f3b:	b8 00 00 00 00       	mov    $0x0,%eax
80102f40:	eb 0d                	jmp    80102f4f <lapicid+0x20>
  return lapic[ID] >> 24;
80102f42:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102f47:	83 c0 20             	add    $0x20,%eax
80102f4a:	8b 00                	mov    (%eax),%eax
80102f4c:	c1 e8 18             	shr    $0x18,%eax
}
80102f4f:	5d                   	pop    %ebp
80102f50:	c3                   	ret    

80102f51 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102f51:	55                   	push   %ebp
80102f52:	89 e5                	mov    %esp,%ebp
80102f54:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80102f57:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102f5c:	85 c0                	test   %eax,%eax
80102f5e:	74 14                	je     80102f74 <lapiceoi+0x23>
    lapicw(EOI, 0);
80102f60:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102f67:	00 
80102f68:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102f6f:	e8 41 fe ff ff       	call   80102db5 <lapicw>
}
80102f74:	c9                   	leave  
80102f75:	c3                   	ret    

80102f76 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102f76:	55                   	push   %ebp
80102f77:	89 e5                	mov    %esp,%ebp
}
80102f79:	5d                   	pop    %ebp
80102f7a:	c3                   	ret    

80102f7b <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102f7b:	55                   	push   %ebp
80102f7c:	89 e5                	mov    %esp,%ebp
80102f7e:	83 ec 1c             	sub    $0x1c,%esp
80102f81:	8b 45 08             	mov    0x8(%ebp),%eax
80102f84:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102f87:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80102f8e:	00 
80102f8f:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80102f96:	e8 fc fd ff ff       	call   80102d97 <outb>
  outb(CMOS_PORT+1, 0x0A);
80102f9b:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80102fa2:	00 
80102fa3:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80102faa:	e8 e8 fd ff ff       	call   80102d97 <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102faf:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102fb6:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102fb9:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102fbe:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102fc1:	8d 50 02             	lea    0x2(%eax),%edx
80102fc4:	8b 45 0c             	mov    0xc(%ebp),%eax
80102fc7:	c1 e8 04             	shr    $0x4,%eax
80102fca:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102fcd:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102fd1:	c1 e0 18             	shl    $0x18,%eax
80102fd4:	89 44 24 04          	mov    %eax,0x4(%esp)
80102fd8:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102fdf:	e8 d1 fd ff ff       	call   80102db5 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102fe4:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
80102feb:	00 
80102fec:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102ff3:	e8 bd fd ff ff       	call   80102db5 <lapicw>
  microdelay(200);
80102ff8:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102fff:	e8 72 ff ff ff       	call   80102f76 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
80103004:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
8010300b:	00 
8010300c:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103013:	e8 9d fd ff ff       	call   80102db5 <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80103018:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
8010301f:	e8 52 ff ff ff       	call   80102f76 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103024:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010302b:	eb 40                	jmp    8010306d <lapicstartap+0xf2>
    lapicw(ICRHI, apicid<<24);
8010302d:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103031:	c1 e0 18             	shl    $0x18,%eax
80103034:	89 44 24 04          	mov    %eax,0x4(%esp)
80103038:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
8010303f:	e8 71 fd ff ff       	call   80102db5 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80103044:	8b 45 0c             	mov    0xc(%ebp),%eax
80103047:	c1 e8 0c             	shr    $0xc,%eax
8010304a:	80 cc 06             	or     $0x6,%ah
8010304d:	89 44 24 04          	mov    %eax,0x4(%esp)
80103051:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103058:	e8 58 fd ff ff       	call   80102db5 <lapicw>
    microdelay(200);
8010305d:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103064:	e8 0d ff ff ff       	call   80102f76 <microdelay>
  for(i = 0; i < 2; i++){
80103069:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010306d:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103071:	7e ba                	jle    8010302d <lapicstartap+0xb2>
  }
}
80103073:	c9                   	leave  
80103074:	c3                   	ret    

80103075 <cmos_read>:
#define MONTH   0x08
#define YEAR    0x09

static uint
cmos_read(uint reg)
{
80103075:	55                   	push   %ebp
80103076:	89 e5                	mov    %esp,%ebp
80103078:	83 ec 08             	sub    $0x8,%esp
  outb(CMOS_PORT,  reg);
8010307b:	8b 45 08             	mov    0x8(%ebp),%eax
8010307e:	0f b6 c0             	movzbl %al,%eax
80103081:	89 44 24 04          	mov    %eax,0x4(%esp)
80103085:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
8010308c:	e8 06 fd ff ff       	call   80102d97 <outb>
  microdelay(200);
80103091:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103098:	e8 d9 fe ff ff       	call   80102f76 <microdelay>

  return inb(CMOS_RETURN);
8010309d:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
801030a4:	e8 d1 fc ff ff       	call   80102d7a <inb>
801030a9:	0f b6 c0             	movzbl %al,%eax
}
801030ac:	c9                   	leave  
801030ad:	c3                   	ret    

801030ae <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
801030ae:	55                   	push   %ebp
801030af:	89 e5                	mov    %esp,%ebp
801030b1:	83 ec 04             	sub    $0x4,%esp
  r->second = cmos_read(SECS);
801030b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801030bb:	e8 b5 ff ff ff       	call   80103075 <cmos_read>
801030c0:	8b 55 08             	mov    0x8(%ebp),%edx
801030c3:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
801030c5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801030cc:	e8 a4 ff ff ff       	call   80103075 <cmos_read>
801030d1:	8b 55 08             	mov    0x8(%ebp),%edx
801030d4:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
801030d7:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
801030de:	e8 92 ff ff ff       	call   80103075 <cmos_read>
801030e3:	8b 55 08             	mov    0x8(%ebp),%edx
801030e6:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
801030e9:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
801030f0:	e8 80 ff ff ff       	call   80103075 <cmos_read>
801030f5:	8b 55 08             	mov    0x8(%ebp),%edx
801030f8:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
801030fb:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80103102:	e8 6e ff ff ff       	call   80103075 <cmos_read>
80103107:	8b 55 08             	mov    0x8(%ebp),%edx
8010310a:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
8010310d:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
80103114:	e8 5c ff ff ff       	call   80103075 <cmos_read>
80103119:	8b 55 08             	mov    0x8(%ebp),%edx
8010311c:	89 42 14             	mov    %eax,0x14(%edx)
}
8010311f:	c9                   	leave  
80103120:	c3                   	ret    

80103121 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
80103121:	55                   	push   %ebp
80103122:	89 e5                	mov    %esp,%ebp
80103124:	83 ec 58             	sub    $0x58,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80103127:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
8010312e:	e8 42 ff ff ff       	call   80103075 <cmos_read>
80103133:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80103136:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103139:	83 e0 04             	and    $0x4,%eax
8010313c:	85 c0                	test   %eax,%eax
8010313e:	0f 94 c0             	sete   %al
80103141:	0f b6 c0             	movzbl %al,%eax
80103144:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80103147:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010314a:	89 04 24             	mov    %eax,(%esp)
8010314d:	e8 5c ff ff ff       	call   801030ae <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80103152:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80103159:	e8 17 ff ff ff       	call   80103075 <cmos_read>
8010315e:	25 80 00 00 00       	and    $0x80,%eax
80103163:	85 c0                	test   %eax,%eax
80103165:	74 02                	je     80103169 <cmostime+0x48>
        continue;
80103167:	eb 36                	jmp    8010319f <cmostime+0x7e>
    fill_rtcdate(&t2);
80103169:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010316c:	89 04 24             	mov    %eax,(%esp)
8010316f:	e8 3a ff ff ff       	call   801030ae <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80103174:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
8010317b:	00 
8010317c:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010317f:	89 44 24 04          	mov    %eax,0x4(%esp)
80103183:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103186:	89 04 24             	mov    %eax,(%esp)
80103189:	e8 19 1f 00 00       	call   801050a7 <memcmp>
8010318e:	85 c0                	test   %eax,%eax
80103190:	75 0d                	jne    8010319f <cmostime+0x7e>
      break;
80103192:	90                   	nop
  }

  // convert
  if(bcd) {
80103193:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103197:	0f 84 ac 00 00 00    	je     80103249 <cmostime+0x128>
8010319d:	eb 02                	jmp    801031a1 <cmostime+0x80>
  }
8010319f:	eb a6                	jmp    80103147 <cmostime+0x26>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801031a1:	8b 45 d8             	mov    -0x28(%ebp),%eax
801031a4:	c1 e8 04             	shr    $0x4,%eax
801031a7:	89 c2                	mov    %eax,%edx
801031a9:	89 d0                	mov    %edx,%eax
801031ab:	c1 e0 02             	shl    $0x2,%eax
801031ae:	01 d0                	add    %edx,%eax
801031b0:	01 c0                	add    %eax,%eax
801031b2:	8b 55 d8             	mov    -0x28(%ebp),%edx
801031b5:	83 e2 0f             	and    $0xf,%edx
801031b8:	01 d0                	add    %edx,%eax
801031ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
801031bd:	8b 45 dc             	mov    -0x24(%ebp),%eax
801031c0:	c1 e8 04             	shr    $0x4,%eax
801031c3:	89 c2                	mov    %eax,%edx
801031c5:	89 d0                	mov    %edx,%eax
801031c7:	c1 e0 02             	shl    $0x2,%eax
801031ca:	01 d0                	add    %edx,%eax
801031cc:	01 c0                	add    %eax,%eax
801031ce:	8b 55 dc             	mov    -0x24(%ebp),%edx
801031d1:	83 e2 0f             	and    $0xf,%edx
801031d4:	01 d0                	add    %edx,%eax
801031d6:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
801031d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801031dc:	c1 e8 04             	shr    $0x4,%eax
801031df:	89 c2                	mov    %eax,%edx
801031e1:	89 d0                	mov    %edx,%eax
801031e3:	c1 e0 02             	shl    $0x2,%eax
801031e6:	01 d0                	add    %edx,%eax
801031e8:	01 c0                	add    %eax,%eax
801031ea:	8b 55 e0             	mov    -0x20(%ebp),%edx
801031ed:	83 e2 0f             	and    $0xf,%edx
801031f0:	01 d0                	add    %edx,%eax
801031f2:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
801031f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801031f8:	c1 e8 04             	shr    $0x4,%eax
801031fb:	89 c2                	mov    %eax,%edx
801031fd:	89 d0                	mov    %edx,%eax
801031ff:	c1 e0 02             	shl    $0x2,%eax
80103202:	01 d0                	add    %edx,%eax
80103204:	01 c0                	add    %eax,%eax
80103206:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103209:	83 e2 0f             	and    $0xf,%edx
8010320c:	01 d0                	add    %edx,%eax
8010320e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80103211:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103214:	c1 e8 04             	shr    $0x4,%eax
80103217:	89 c2                	mov    %eax,%edx
80103219:	89 d0                	mov    %edx,%eax
8010321b:	c1 e0 02             	shl    $0x2,%eax
8010321e:	01 d0                	add    %edx,%eax
80103220:	01 c0                	add    %eax,%eax
80103222:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103225:	83 e2 0f             	and    $0xf,%edx
80103228:	01 d0                	add    %edx,%eax
8010322a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
8010322d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103230:	c1 e8 04             	shr    $0x4,%eax
80103233:	89 c2                	mov    %eax,%edx
80103235:	89 d0                	mov    %edx,%eax
80103237:	c1 e0 02             	shl    $0x2,%eax
8010323a:	01 d0                	add    %edx,%eax
8010323c:	01 c0                	add    %eax,%eax
8010323e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103241:	83 e2 0f             	and    $0xf,%edx
80103244:	01 d0                	add    %edx,%eax
80103246:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80103249:	8b 45 08             	mov    0x8(%ebp),%eax
8010324c:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010324f:	89 10                	mov    %edx,(%eax)
80103251:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103254:	89 50 04             	mov    %edx,0x4(%eax)
80103257:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010325a:	89 50 08             	mov    %edx,0x8(%eax)
8010325d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103260:	89 50 0c             	mov    %edx,0xc(%eax)
80103263:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103266:	89 50 10             	mov    %edx,0x10(%eax)
80103269:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010326c:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
8010326f:	8b 45 08             	mov    0x8(%ebp),%eax
80103272:	8b 40 14             	mov    0x14(%eax),%eax
80103275:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
8010327b:	8b 45 08             	mov    0x8(%ebp),%eax
8010327e:	89 50 14             	mov    %edx,0x14(%eax)
}
80103281:	c9                   	leave  
80103282:	c3                   	ret    

80103283 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80103283:	55                   	push   %ebp
80103284:	89 e5                	mov    %esp,%ebp
80103286:	83 ec 38             	sub    $0x38,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103289:	c7 44 24 04 d1 84 10 	movl   $0x801084d1,0x4(%esp)
80103290:	80 
80103291:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
80103298:	e8 00 1b 00 00       	call   80104d9d <initlock>
  readsb(dev, &sb);
8010329d:	8d 45 dc             	lea    -0x24(%ebp),%eax
801032a0:	89 44 24 04          	mov    %eax,0x4(%esp)
801032a4:	8b 45 08             	mov    0x8(%ebp),%eax
801032a7:	89 04 24             	mov    %eax,(%esp)
801032aa:	e8 a1 e0 ff ff       	call   80101350 <readsb>
  log.start = sb.logstart;
801032af:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032b2:	a3 34 37 11 80       	mov    %eax,0x80113734
  log.size = sb.nlog;
801032b7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032ba:	a3 38 37 11 80       	mov    %eax,0x80113738
  log.dev = dev;
801032bf:	8b 45 08             	mov    0x8(%ebp),%eax
801032c2:	a3 44 37 11 80       	mov    %eax,0x80113744
  recover_from_log();
801032c7:	e8 9a 01 00 00       	call   80103466 <recover_from_log>
}
801032cc:	c9                   	leave  
801032cd:	c3                   	ret    

801032ce <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
801032ce:	55                   	push   %ebp
801032cf:	89 e5                	mov    %esp,%ebp
801032d1:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801032d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032db:	e9 8c 00 00 00       	jmp    8010336c <install_trans+0x9e>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801032e0:	8b 15 34 37 11 80    	mov    0x80113734,%edx
801032e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032e9:	01 d0                	add    %edx,%eax
801032eb:	83 c0 01             	add    $0x1,%eax
801032ee:	89 c2                	mov    %eax,%edx
801032f0:	a1 44 37 11 80       	mov    0x80113744,%eax
801032f5:	89 54 24 04          	mov    %edx,0x4(%esp)
801032f9:	89 04 24             	mov    %eax,(%esp)
801032fc:	e8 b4 ce ff ff       	call   801001b5 <bread>
80103301:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103304:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103307:	83 c0 10             	add    $0x10,%eax
8010330a:	8b 04 85 0c 37 11 80 	mov    -0x7feec8f4(,%eax,4),%eax
80103311:	89 c2                	mov    %eax,%edx
80103313:	a1 44 37 11 80       	mov    0x80113744,%eax
80103318:	89 54 24 04          	mov    %edx,0x4(%esp)
8010331c:	89 04 24             	mov    %eax,(%esp)
8010331f:	e8 91 ce ff ff       	call   801001b5 <bread>
80103324:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103327:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010332a:	8d 50 5c             	lea    0x5c(%eax),%edx
8010332d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103330:	83 c0 5c             	add    $0x5c,%eax
80103333:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010333a:	00 
8010333b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010333f:	89 04 24             	mov    %eax,(%esp)
80103342:	e8 b8 1d 00 00       	call   801050ff <memmove>
    bwrite(dbuf);  // write dst to disk
80103347:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010334a:	89 04 24             	mov    %eax,(%esp)
8010334d:	e8 9a ce ff ff       	call   801001ec <bwrite>
    brelse(lbuf);
80103352:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103355:	89 04 24             	mov    %eax,(%esp)
80103358:	e8 cf ce ff ff       	call   8010022c <brelse>
    brelse(dbuf);
8010335d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103360:	89 04 24             	mov    %eax,(%esp)
80103363:	e8 c4 ce ff ff       	call   8010022c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80103368:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010336c:	a1 48 37 11 80       	mov    0x80113748,%eax
80103371:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103374:	0f 8f 66 ff ff ff    	jg     801032e0 <install_trans+0x12>
  }
}
8010337a:	c9                   	leave  
8010337b:	c3                   	ret    

8010337c <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
8010337c:	55                   	push   %ebp
8010337d:	89 e5                	mov    %esp,%ebp
8010337f:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103382:	a1 34 37 11 80       	mov    0x80113734,%eax
80103387:	89 c2                	mov    %eax,%edx
80103389:	a1 44 37 11 80       	mov    0x80113744,%eax
8010338e:	89 54 24 04          	mov    %edx,0x4(%esp)
80103392:	89 04 24             	mov    %eax,(%esp)
80103395:	e8 1b ce ff ff       	call   801001b5 <bread>
8010339a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
8010339d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033a0:	83 c0 5c             	add    $0x5c,%eax
801033a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
801033a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033a9:	8b 00                	mov    (%eax),%eax
801033ab:	a3 48 37 11 80       	mov    %eax,0x80113748
  for (i = 0; i < log.lh.n; i++) {
801033b0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801033b7:	eb 1b                	jmp    801033d4 <read_head+0x58>
    log.lh.block[i] = lh->block[i];
801033b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801033bf:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
801033c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801033c6:	83 c2 10             	add    $0x10,%edx
801033c9:	89 04 95 0c 37 11 80 	mov    %eax,-0x7feec8f4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
801033d0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801033d4:	a1 48 37 11 80       	mov    0x80113748,%eax
801033d9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801033dc:	7f db                	jg     801033b9 <read_head+0x3d>
  }
  brelse(buf);
801033de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033e1:	89 04 24             	mov    %eax,(%esp)
801033e4:	e8 43 ce ff ff       	call   8010022c <brelse>
}
801033e9:	c9                   	leave  
801033ea:	c3                   	ret    

801033eb <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801033eb:	55                   	push   %ebp
801033ec:	89 e5                	mov    %esp,%ebp
801033ee:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
801033f1:	a1 34 37 11 80       	mov    0x80113734,%eax
801033f6:	89 c2                	mov    %eax,%edx
801033f8:	a1 44 37 11 80       	mov    0x80113744,%eax
801033fd:	89 54 24 04          	mov    %edx,0x4(%esp)
80103401:	89 04 24             	mov    %eax,(%esp)
80103404:	e8 ac cd ff ff       	call   801001b5 <bread>
80103409:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
8010340c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010340f:	83 c0 5c             	add    $0x5c,%eax
80103412:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103415:	8b 15 48 37 11 80    	mov    0x80113748,%edx
8010341b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010341e:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103420:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103427:	eb 1b                	jmp    80103444 <write_head+0x59>
    hb->block[i] = log.lh.block[i];
80103429:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010342c:	83 c0 10             	add    $0x10,%eax
8010342f:	8b 0c 85 0c 37 11 80 	mov    -0x7feec8f4(,%eax,4),%ecx
80103436:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103439:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010343c:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80103440:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103444:	a1 48 37 11 80       	mov    0x80113748,%eax
80103449:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010344c:	7f db                	jg     80103429 <write_head+0x3e>
  }
  bwrite(buf);
8010344e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103451:	89 04 24             	mov    %eax,(%esp)
80103454:	e8 93 cd ff ff       	call   801001ec <bwrite>
  brelse(buf);
80103459:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010345c:	89 04 24             	mov    %eax,(%esp)
8010345f:	e8 c8 cd ff ff       	call   8010022c <brelse>
}
80103464:	c9                   	leave  
80103465:	c3                   	ret    

80103466 <recover_from_log>:

static void
recover_from_log(void)
{
80103466:	55                   	push   %ebp
80103467:	89 e5                	mov    %esp,%ebp
80103469:	83 ec 08             	sub    $0x8,%esp
  read_head();
8010346c:	e8 0b ff ff ff       	call   8010337c <read_head>
  install_trans(); // if committed, copy from log to disk
80103471:	e8 58 fe ff ff       	call   801032ce <install_trans>
  log.lh.n = 0;
80103476:	c7 05 48 37 11 80 00 	movl   $0x0,0x80113748
8010347d:	00 00 00 
  write_head(); // clear the log
80103480:	e8 66 ff ff ff       	call   801033eb <write_head>
}
80103485:	c9                   	leave  
80103486:	c3                   	ret    

80103487 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103487:	55                   	push   %ebp
80103488:	89 e5                	mov    %esp,%ebp
8010348a:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
8010348d:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
80103494:	e8 25 19 00 00       	call   80104dbe <acquire>
  while(1){
    if(log.committing){
80103499:	a1 40 37 11 80       	mov    0x80113740,%eax
8010349e:	85 c0                	test   %eax,%eax
801034a0:	74 16                	je     801034b8 <begin_op+0x31>
      sleep(&log, &log.lock);
801034a2:	c7 44 24 04 00 37 11 	movl   $0x80113700,0x4(%esp)
801034a9:	80 
801034aa:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
801034b1:	e8 16 15 00 00       	call   801049cc <sleep>
801034b6:	eb 4f                	jmp    80103507 <begin_op+0x80>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801034b8:	8b 0d 48 37 11 80    	mov    0x80113748,%ecx
801034be:	a1 3c 37 11 80       	mov    0x8011373c,%eax
801034c3:	8d 50 01             	lea    0x1(%eax),%edx
801034c6:	89 d0                	mov    %edx,%eax
801034c8:	c1 e0 02             	shl    $0x2,%eax
801034cb:	01 d0                	add    %edx,%eax
801034cd:	01 c0                	add    %eax,%eax
801034cf:	01 c8                	add    %ecx,%eax
801034d1:	83 f8 1e             	cmp    $0x1e,%eax
801034d4:	7e 16                	jle    801034ec <begin_op+0x65>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801034d6:	c7 44 24 04 00 37 11 	movl   $0x80113700,0x4(%esp)
801034dd:	80 
801034de:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
801034e5:	e8 e2 14 00 00       	call   801049cc <sleep>
801034ea:	eb 1b                	jmp    80103507 <begin_op+0x80>
    } else {
      log.outstanding += 1;
801034ec:	a1 3c 37 11 80       	mov    0x8011373c,%eax
801034f1:	83 c0 01             	add    $0x1,%eax
801034f4:	a3 3c 37 11 80       	mov    %eax,0x8011373c
      release(&log.lock);
801034f9:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
80103500:	e8 21 19 00 00       	call   80104e26 <release>
      break;
80103505:	eb 02                	jmp    80103509 <begin_op+0x82>
    }
  }
80103507:	eb 90                	jmp    80103499 <begin_op+0x12>
}
80103509:	c9                   	leave  
8010350a:	c3                   	ret    

8010350b <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
8010350b:	55                   	push   %ebp
8010350c:	89 e5                	mov    %esp,%ebp
8010350e:	83 ec 28             	sub    $0x28,%esp
  int do_commit = 0;
80103511:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103518:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
8010351f:	e8 9a 18 00 00       	call   80104dbe <acquire>
  log.outstanding -= 1;
80103524:	a1 3c 37 11 80       	mov    0x8011373c,%eax
80103529:	83 e8 01             	sub    $0x1,%eax
8010352c:	a3 3c 37 11 80       	mov    %eax,0x8011373c
  if(log.committing)
80103531:	a1 40 37 11 80       	mov    0x80113740,%eax
80103536:	85 c0                	test   %eax,%eax
80103538:	74 0c                	je     80103546 <end_op+0x3b>
    panic("log.committing");
8010353a:	c7 04 24 d5 84 10 80 	movl   $0x801084d5,(%esp)
80103541:	e8 1c d0 ff ff       	call   80100562 <panic>
  if(log.outstanding == 0){
80103546:	a1 3c 37 11 80       	mov    0x8011373c,%eax
8010354b:	85 c0                	test   %eax,%eax
8010354d:	75 13                	jne    80103562 <end_op+0x57>
    do_commit = 1;
8010354f:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103556:	c7 05 40 37 11 80 01 	movl   $0x1,0x80113740
8010355d:	00 00 00 
80103560:	eb 0c                	jmp    8010356e <end_op+0x63>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103562:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
80103569:	e8 32 15 00 00       	call   80104aa0 <wakeup>
  }
  release(&log.lock);
8010356e:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
80103575:	e8 ac 18 00 00       	call   80104e26 <release>

  if(do_commit){
8010357a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010357e:	74 33                	je     801035b3 <end_op+0xa8>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103580:	e8 de 00 00 00       	call   80103663 <commit>
    acquire(&log.lock);
80103585:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
8010358c:	e8 2d 18 00 00       	call   80104dbe <acquire>
    log.committing = 0;
80103591:	c7 05 40 37 11 80 00 	movl   $0x0,0x80113740
80103598:	00 00 00 
    wakeup(&log);
8010359b:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
801035a2:	e8 f9 14 00 00       	call   80104aa0 <wakeup>
    release(&log.lock);
801035a7:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
801035ae:	e8 73 18 00 00       	call   80104e26 <release>
  }
}
801035b3:	c9                   	leave  
801035b4:	c3                   	ret    

801035b5 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
801035b5:	55                   	push   %ebp
801035b6:	89 e5                	mov    %esp,%ebp
801035b8:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801035bb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801035c2:	e9 8c 00 00 00       	jmp    80103653 <write_log+0x9e>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801035c7:	8b 15 34 37 11 80    	mov    0x80113734,%edx
801035cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035d0:	01 d0                	add    %edx,%eax
801035d2:	83 c0 01             	add    $0x1,%eax
801035d5:	89 c2                	mov    %eax,%edx
801035d7:	a1 44 37 11 80       	mov    0x80113744,%eax
801035dc:	89 54 24 04          	mov    %edx,0x4(%esp)
801035e0:	89 04 24             	mov    %eax,(%esp)
801035e3:	e8 cd cb ff ff       	call   801001b5 <bread>
801035e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801035eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035ee:	83 c0 10             	add    $0x10,%eax
801035f1:	8b 04 85 0c 37 11 80 	mov    -0x7feec8f4(,%eax,4),%eax
801035f8:	89 c2                	mov    %eax,%edx
801035fa:	a1 44 37 11 80       	mov    0x80113744,%eax
801035ff:	89 54 24 04          	mov    %edx,0x4(%esp)
80103603:	89 04 24             	mov    %eax,(%esp)
80103606:	e8 aa cb ff ff       	call   801001b5 <bread>
8010360b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
8010360e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103611:	8d 50 5c             	lea    0x5c(%eax),%edx
80103614:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103617:	83 c0 5c             	add    $0x5c,%eax
8010361a:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103621:	00 
80103622:	89 54 24 04          	mov    %edx,0x4(%esp)
80103626:	89 04 24             	mov    %eax,(%esp)
80103629:	e8 d1 1a 00 00       	call   801050ff <memmove>
    bwrite(to);  // write the log
8010362e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103631:	89 04 24             	mov    %eax,(%esp)
80103634:	e8 b3 cb ff ff       	call   801001ec <bwrite>
    brelse(from);
80103639:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010363c:	89 04 24             	mov    %eax,(%esp)
8010363f:	e8 e8 cb ff ff       	call   8010022c <brelse>
    brelse(to);
80103644:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103647:	89 04 24             	mov    %eax,(%esp)
8010364a:	e8 dd cb ff ff       	call   8010022c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
8010364f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103653:	a1 48 37 11 80       	mov    0x80113748,%eax
80103658:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010365b:	0f 8f 66 ff ff ff    	jg     801035c7 <write_log+0x12>
  }
}
80103661:	c9                   	leave  
80103662:	c3                   	ret    

80103663 <commit>:

static void
commit()
{
80103663:	55                   	push   %ebp
80103664:	89 e5                	mov    %esp,%ebp
80103666:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103669:	a1 48 37 11 80       	mov    0x80113748,%eax
8010366e:	85 c0                	test   %eax,%eax
80103670:	7e 1e                	jle    80103690 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103672:	e8 3e ff ff ff       	call   801035b5 <write_log>
    write_head();    // Write header to disk -- the real commit
80103677:	e8 6f fd ff ff       	call   801033eb <write_head>
    install_trans(); // Now install writes to home locations
8010367c:	e8 4d fc ff ff       	call   801032ce <install_trans>
    log.lh.n = 0;
80103681:	c7 05 48 37 11 80 00 	movl   $0x0,0x80113748
80103688:	00 00 00 
    write_head();    // Erase the transaction from the log
8010368b:	e8 5b fd ff ff       	call   801033eb <write_head>
  }
}
80103690:	c9                   	leave  
80103691:	c3                   	ret    

80103692 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103692:	55                   	push   %ebp
80103693:	89 e5                	mov    %esp,%ebp
80103695:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103698:	a1 48 37 11 80       	mov    0x80113748,%eax
8010369d:	83 f8 1d             	cmp    $0x1d,%eax
801036a0:	7f 12                	jg     801036b4 <log_write+0x22>
801036a2:	a1 48 37 11 80       	mov    0x80113748,%eax
801036a7:	8b 15 38 37 11 80    	mov    0x80113738,%edx
801036ad:	83 ea 01             	sub    $0x1,%edx
801036b0:	39 d0                	cmp    %edx,%eax
801036b2:	7c 0c                	jl     801036c0 <log_write+0x2e>
    panic("too big a transaction");
801036b4:	c7 04 24 e4 84 10 80 	movl   $0x801084e4,(%esp)
801036bb:	e8 a2 ce ff ff       	call   80100562 <panic>
  if (log.outstanding < 1)
801036c0:	a1 3c 37 11 80       	mov    0x8011373c,%eax
801036c5:	85 c0                	test   %eax,%eax
801036c7:	7f 0c                	jg     801036d5 <log_write+0x43>
    panic("log_write outside of trans");
801036c9:	c7 04 24 fa 84 10 80 	movl   $0x801084fa,(%esp)
801036d0:	e8 8d ce ff ff       	call   80100562 <panic>

  acquire(&log.lock);
801036d5:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
801036dc:	e8 dd 16 00 00       	call   80104dbe <acquire>
  for (i = 0; i < log.lh.n; i++) {
801036e1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801036e8:	eb 1f                	jmp    80103709 <log_write+0x77>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801036ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036ed:	83 c0 10             	add    $0x10,%eax
801036f0:	8b 04 85 0c 37 11 80 	mov    -0x7feec8f4(,%eax,4),%eax
801036f7:	89 c2                	mov    %eax,%edx
801036f9:	8b 45 08             	mov    0x8(%ebp),%eax
801036fc:	8b 40 08             	mov    0x8(%eax),%eax
801036ff:	39 c2                	cmp    %eax,%edx
80103701:	75 02                	jne    80103705 <log_write+0x73>
      break;
80103703:	eb 0e                	jmp    80103713 <log_write+0x81>
  for (i = 0; i < log.lh.n; i++) {
80103705:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103709:	a1 48 37 11 80       	mov    0x80113748,%eax
8010370e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103711:	7f d7                	jg     801036ea <log_write+0x58>
  }
  log.lh.block[i] = b->blockno;
80103713:	8b 45 08             	mov    0x8(%ebp),%eax
80103716:	8b 40 08             	mov    0x8(%eax),%eax
80103719:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010371c:	83 c2 10             	add    $0x10,%edx
8010371f:	89 04 95 0c 37 11 80 	mov    %eax,-0x7feec8f4(,%edx,4)
  if (i == log.lh.n)
80103726:	a1 48 37 11 80       	mov    0x80113748,%eax
8010372b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010372e:	75 0d                	jne    8010373d <log_write+0xab>
    log.lh.n++;
80103730:	a1 48 37 11 80       	mov    0x80113748,%eax
80103735:	83 c0 01             	add    $0x1,%eax
80103738:	a3 48 37 11 80       	mov    %eax,0x80113748
  b->flags |= B_DIRTY; // prevent eviction
8010373d:	8b 45 08             	mov    0x8(%ebp),%eax
80103740:	8b 00                	mov    (%eax),%eax
80103742:	83 c8 04             	or     $0x4,%eax
80103745:	89 c2                	mov    %eax,%edx
80103747:	8b 45 08             	mov    0x8(%ebp),%eax
8010374a:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
8010374c:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
80103753:	e8 ce 16 00 00       	call   80104e26 <release>
}
80103758:	c9                   	leave  
80103759:	c3                   	ret    

8010375a <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010375a:	55                   	push   %ebp
8010375b:	89 e5                	mov    %esp,%ebp
8010375d:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103760:	8b 55 08             	mov    0x8(%ebp),%edx
80103763:	8b 45 0c             	mov    0xc(%ebp),%eax
80103766:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103769:	f0 87 02             	lock xchg %eax,(%edx)
8010376c:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
8010376f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103772:	c9                   	leave  
80103773:	c3                   	ret    

80103774 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103774:	55                   	push   %ebp
80103775:	89 e5                	mov    %esp,%ebp
80103777:	83 e4 f0             	and    $0xfffffff0,%esp
8010377a:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010377d:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
80103784:	80 
80103785:	c7 04 24 28 65 11 80 	movl   $0x80116528,(%esp)
8010378c:	e8 ed f2 ff ff       	call   80102a7e <kinit1>
  kvmalloc();      // kernel page table
80103791:	e8 b8 42 00 00       	call   80107a4e <kvmalloc>
  mpinit();        // detect other processors
80103796:	e8 cb 03 00 00       	call   80103b66 <mpinit>
  lapicinit();     // interrupt controller
8010379b:	e8 36 f6 ff ff       	call   80102dd6 <lapicinit>
  seginit();       // segment descriptors
801037a0:	e8 75 3d 00 00       	call   8010751a <seginit>
  picinit();       // disable pic
801037a5:	e8 0b 05 00 00       	call   80103cb5 <picinit>
  ioapicinit();    // another interrupt controller
801037aa:	e8 eb f1 ff ff       	call   8010299a <ioapicinit>
  consoleinit();   // console hardware
801037af:	e8 1c d3 ff ff       	call   80100ad0 <consoleinit>
  uartinit();      // serial port
801037b4:	e8 eb 30 00 00       	call   801068a4 <uartinit>
  pinit();         // process table
801037b9:	e8 f0 08 00 00       	call   801040ae <pinit>
  tvinit();        // trap vectors
801037be:	e8 aa 2c 00 00       	call   8010646d <tvinit>
  binit();         // buffer cache
801037c3:	e8 6c c8 ff ff       	call   80100034 <binit>
  fileinit();      // file table
801037c8:	e8 9c d7 ff ff       	call   80100f69 <fileinit>
  ideinit();       // disk 
801037cd:	e8 d2 ed ff ff       	call   801025a4 <ideinit>
  startothers();   // start other processors
801037d2:	e8 83 00 00 00       	call   8010385a <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801037d7:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
801037de:	8e 
801037df:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
801037e6:	e8 cb f2 ff ff       	call   80102ab6 <kinit2>
  userinit();      // first user process
801037eb:	e8 99 0a 00 00       	call   80104289 <userinit>
  mpmain();        // finish this processor's setup
801037f0:	e8 1a 00 00 00       	call   8010380f <mpmain>

801037f5 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801037f5:	55                   	push   %ebp
801037f6:	89 e5                	mov    %esp,%ebp
801037f8:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
801037fb:	e8 65 42 00 00       	call   80107a65 <switchkvm>
  seginit();
80103800:	e8 15 3d 00 00       	call   8010751a <seginit>
  lapicinit();
80103805:	e8 cc f5 ff ff       	call   80102dd6 <lapicinit>
  mpmain();
8010380a:	e8 00 00 00 00       	call   8010380f <mpmain>

8010380f <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
8010380f:	55                   	push   %ebp
80103810:	89 e5                	mov    %esp,%ebp
80103812:	53                   	push   %ebx
80103813:	83 ec 14             	sub    $0x14,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103816:	e8 af 08 00 00       	call   801040ca <cpuid>
8010381b:	89 c3                	mov    %eax,%ebx
8010381d:	e8 a8 08 00 00       	call   801040ca <cpuid>
80103822:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80103826:	89 44 24 04          	mov    %eax,0x4(%esp)
8010382a:	c7 04 24 15 85 10 80 	movl   $0x80108515,(%esp)
80103831:	e8 92 cb ff ff       	call   801003c8 <cprintf>
  idtinit();       // load idt register
80103836:	e8 a6 2d 00 00       	call   801065e1 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
8010383b:	e8 ab 08 00 00       	call   801040eb <mycpu>
80103840:	05 a0 00 00 00       	add    $0xa0,%eax
80103845:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010384c:	00 
8010384d:	89 04 24             	mov    %eax,(%esp)
80103850:	e8 05 ff ff ff       	call   8010375a <xchg>
  scheduler();     // start running processes
80103855:	e8 a8 0f 00 00       	call   80104802 <scheduler>

8010385a <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
8010385a:	55                   	push   %ebp
8010385b:	89 e5                	mov    %esp,%ebp
8010385d:	83 ec 28             	sub    $0x28,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103860:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103867:	b8 8a 00 00 00       	mov    $0x8a,%eax
8010386c:	89 44 24 08          	mov    %eax,0x8(%esp)
80103870:	c7 44 24 04 ec b4 10 	movl   $0x8010b4ec,0x4(%esp)
80103877:	80 
80103878:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010387b:	89 04 24             	mov    %eax,(%esp)
8010387e:	e8 7c 18 00 00       	call   801050ff <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80103883:	c7 45 f4 00 38 11 80 	movl   $0x80113800,-0xc(%ebp)
8010388a:	eb 76                	jmp    80103902 <startothers+0xa8>
    if(c == mycpu())  // We've started already.
8010388c:	e8 5a 08 00 00       	call   801040eb <mycpu>
80103891:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103894:	75 02                	jne    80103898 <startothers+0x3e>
      continue;
80103896:	eb 63                	jmp    801038fb <startothers+0xa1>

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103898:	e8 0c f3 ff ff       	call   80102ba9 <kalloc>
8010389d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801038a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038a3:	83 e8 04             	sub    $0x4,%eax
801038a6:	8b 55 ec             	mov    -0x14(%ebp),%edx
801038a9:	81 c2 00 10 00 00    	add    $0x1000,%edx
801038af:	89 10                	mov    %edx,(%eax)
    *(void(**)(void))(code-8) = mpenter;
801038b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038b4:	83 e8 08             	sub    $0x8,%eax
801038b7:	c7 00 f5 37 10 80    	movl   $0x801037f5,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801038bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038c0:	8d 50 f4             	lea    -0xc(%eax),%edx
801038c3:	b8 00 a0 10 80       	mov    $0x8010a000,%eax
801038c8:	05 00 00 00 80       	add    $0x80000000,%eax
801038cd:	89 02                	mov    %eax,(%edx)

    lapicstartap(c->apicid, V2P(code));
801038cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038d2:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801038d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038db:	0f b6 00             	movzbl (%eax),%eax
801038de:	0f b6 c0             	movzbl %al,%eax
801038e1:	89 54 24 04          	mov    %edx,0x4(%esp)
801038e5:	89 04 24             	mov    %eax,(%esp)
801038e8:	e8 8e f6 ff ff       	call   80102f7b <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801038ed:	90                   	nop
801038ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038f1:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801038f7:	85 c0                	test   %eax,%eax
801038f9:	74 f3                	je     801038ee <startothers+0x94>
  for(c = cpus; c < cpus+ncpu; c++){
801038fb:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103902:	a1 80 3d 11 80       	mov    0x80113d80,%eax
80103907:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
8010390d:	05 00 38 11 80       	add    $0x80113800,%eax
80103912:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103915:	0f 87 71 ff ff ff    	ja     8010388c <startothers+0x32>
      ;
  }
}
8010391b:	c9                   	leave  
8010391c:	c3                   	ret    

8010391d <inb>:
{
8010391d:	55                   	push   %ebp
8010391e:	89 e5                	mov    %esp,%ebp
80103920:	83 ec 14             	sub    $0x14,%esp
80103923:	8b 45 08             	mov    0x8(%ebp),%eax
80103926:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010392a:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010392e:	89 c2                	mov    %eax,%edx
80103930:	ec                   	in     (%dx),%al
80103931:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103934:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103938:	c9                   	leave  
80103939:	c3                   	ret    

8010393a <outb>:
{
8010393a:	55                   	push   %ebp
8010393b:	89 e5                	mov    %esp,%ebp
8010393d:	83 ec 08             	sub    $0x8,%esp
80103940:	8b 55 08             	mov    0x8(%ebp),%edx
80103943:	8b 45 0c             	mov    0xc(%ebp),%eax
80103946:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010394a:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010394d:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103951:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103955:	ee                   	out    %al,(%dx)
}
80103956:	c9                   	leave  
80103957:	c3                   	ret    

80103958 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80103958:	55                   	push   %ebp
80103959:	89 e5                	mov    %esp,%ebp
8010395b:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
8010395e:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103965:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010396c:	eb 15                	jmp    80103983 <sum+0x2b>
    sum += addr[i];
8010396e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103971:	8b 45 08             	mov    0x8(%ebp),%eax
80103974:	01 d0                	add    %edx,%eax
80103976:	0f b6 00             	movzbl (%eax),%eax
80103979:	0f b6 c0             	movzbl %al,%eax
8010397c:	01 45 f8             	add    %eax,-0x8(%ebp)
  for(i=0; i<len; i++)
8010397f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103983:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103986:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103989:	7c e3                	jl     8010396e <sum+0x16>
  return sum;
8010398b:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010398e:	c9                   	leave  
8010398f:	c3                   	ret    

80103990 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103990:	55                   	push   %ebp
80103991:	89 e5                	mov    %esp,%ebp
80103993:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103996:	8b 45 08             	mov    0x8(%ebp),%eax
80103999:	05 00 00 00 80       	add    $0x80000000,%eax
8010399e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
801039a1:	8b 55 0c             	mov    0xc(%ebp),%edx
801039a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039a7:	01 d0                	add    %edx,%eax
801039a9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
801039ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039af:	89 45 f4             	mov    %eax,-0xc(%ebp)
801039b2:	eb 3f                	jmp    801039f3 <mpsearch1+0x63>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801039b4:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801039bb:	00 
801039bc:	c7 44 24 04 2c 85 10 	movl   $0x8010852c,0x4(%esp)
801039c3:	80 
801039c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039c7:	89 04 24             	mov    %eax,(%esp)
801039ca:	e8 d8 16 00 00       	call   801050a7 <memcmp>
801039cf:	85 c0                	test   %eax,%eax
801039d1:	75 1c                	jne    801039ef <mpsearch1+0x5f>
801039d3:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
801039da:	00 
801039db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039de:	89 04 24             	mov    %eax,(%esp)
801039e1:	e8 72 ff ff ff       	call   80103958 <sum>
801039e6:	84 c0                	test   %al,%al
801039e8:	75 05                	jne    801039ef <mpsearch1+0x5f>
      return (struct mp*)p;
801039ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039ed:	eb 11                	jmp    80103a00 <mpsearch1+0x70>
  for(p = addr; p < e; p += sizeof(struct mp))
801039ef:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801039f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039f6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801039f9:	72 b9                	jb     801039b4 <mpsearch1+0x24>
  return 0;
801039fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103a00:	c9                   	leave  
80103a01:	c3                   	ret    

80103a02 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103a02:	55                   	push   %ebp
80103a03:	89 e5                	mov    %esp,%ebp
80103a05:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103a08:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103a0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a12:	83 c0 0f             	add    $0xf,%eax
80103a15:	0f b6 00             	movzbl (%eax),%eax
80103a18:	0f b6 c0             	movzbl %al,%eax
80103a1b:	c1 e0 08             	shl    $0x8,%eax
80103a1e:	89 c2                	mov    %eax,%edx
80103a20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a23:	83 c0 0e             	add    $0xe,%eax
80103a26:	0f b6 00             	movzbl (%eax),%eax
80103a29:	0f b6 c0             	movzbl %al,%eax
80103a2c:	09 d0                	or     %edx,%eax
80103a2e:	c1 e0 04             	shl    $0x4,%eax
80103a31:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103a34:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103a38:	74 21                	je     80103a5b <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103a3a:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103a41:	00 
80103a42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a45:	89 04 24             	mov    %eax,(%esp)
80103a48:	e8 43 ff ff ff       	call   80103990 <mpsearch1>
80103a4d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103a50:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103a54:	74 50                	je     80103aa6 <mpsearch+0xa4>
      return mp;
80103a56:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103a59:	eb 5f                	jmp    80103aba <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103a5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a5e:	83 c0 14             	add    $0x14,%eax
80103a61:	0f b6 00             	movzbl (%eax),%eax
80103a64:	0f b6 c0             	movzbl %al,%eax
80103a67:	c1 e0 08             	shl    $0x8,%eax
80103a6a:	89 c2                	mov    %eax,%edx
80103a6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a6f:	83 c0 13             	add    $0x13,%eax
80103a72:	0f b6 00             	movzbl (%eax),%eax
80103a75:	0f b6 c0             	movzbl %al,%eax
80103a78:	09 d0                	or     %edx,%eax
80103a7a:	c1 e0 0a             	shl    $0xa,%eax
80103a7d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103a80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a83:	2d 00 04 00 00       	sub    $0x400,%eax
80103a88:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103a8f:	00 
80103a90:	89 04 24             	mov    %eax,(%esp)
80103a93:	e8 f8 fe ff ff       	call   80103990 <mpsearch1>
80103a98:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103a9b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103a9f:	74 05                	je     80103aa6 <mpsearch+0xa4>
      return mp;
80103aa1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103aa4:	eb 14                	jmp    80103aba <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
80103aa6:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103aad:	00 
80103aae:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103ab5:	e8 d6 fe ff ff       	call   80103990 <mpsearch1>
}
80103aba:	c9                   	leave  
80103abb:	c3                   	ret    

80103abc <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103abc:	55                   	push   %ebp
80103abd:	89 e5                	mov    %esp,%ebp
80103abf:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103ac2:	e8 3b ff ff ff       	call   80103a02 <mpsearch>
80103ac7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103aca:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103ace:	74 0a                	je     80103ada <mpconfig+0x1e>
80103ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ad3:	8b 40 04             	mov    0x4(%eax),%eax
80103ad6:	85 c0                	test   %eax,%eax
80103ad8:	75 0a                	jne    80103ae4 <mpconfig+0x28>
    return 0;
80103ada:	b8 00 00 00 00       	mov    $0x0,%eax
80103adf:	e9 80 00 00 00       	jmp    80103b64 <mpconfig+0xa8>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ae7:	8b 40 04             	mov    0x4(%eax),%eax
80103aea:	05 00 00 00 80       	add    $0x80000000,%eax
80103aef:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103af2:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103af9:	00 
80103afa:	c7 44 24 04 31 85 10 	movl   $0x80108531,0x4(%esp)
80103b01:	80 
80103b02:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b05:	89 04 24             	mov    %eax,(%esp)
80103b08:	e8 9a 15 00 00       	call   801050a7 <memcmp>
80103b0d:	85 c0                	test   %eax,%eax
80103b0f:	74 07                	je     80103b18 <mpconfig+0x5c>
    return 0;
80103b11:	b8 00 00 00 00       	mov    $0x0,%eax
80103b16:	eb 4c                	jmp    80103b64 <mpconfig+0xa8>
  if(conf->version != 1 && conf->version != 4)
80103b18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b1b:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103b1f:	3c 01                	cmp    $0x1,%al
80103b21:	74 12                	je     80103b35 <mpconfig+0x79>
80103b23:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b26:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103b2a:	3c 04                	cmp    $0x4,%al
80103b2c:	74 07                	je     80103b35 <mpconfig+0x79>
    return 0;
80103b2e:	b8 00 00 00 00       	mov    $0x0,%eax
80103b33:	eb 2f                	jmp    80103b64 <mpconfig+0xa8>
  if(sum((uchar*)conf, conf->length) != 0)
80103b35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b38:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103b3c:	0f b7 c0             	movzwl %ax,%eax
80103b3f:	89 44 24 04          	mov    %eax,0x4(%esp)
80103b43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b46:	89 04 24             	mov    %eax,(%esp)
80103b49:	e8 0a fe ff ff       	call   80103958 <sum>
80103b4e:	84 c0                	test   %al,%al
80103b50:	74 07                	je     80103b59 <mpconfig+0x9d>
    return 0;
80103b52:	b8 00 00 00 00       	mov    $0x0,%eax
80103b57:	eb 0b                	jmp    80103b64 <mpconfig+0xa8>
  *pmp = mp;
80103b59:	8b 45 08             	mov    0x8(%ebp),%eax
80103b5c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b5f:	89 10                	mov    %edx,(%eax)
  return conf;
80103b61:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103b64:	c9                   	leave  
80103b65:	c3                   	ret    

80103b66 <mpinit>:

void
mpinit(void)
{
80103b66:	55                   	push   %ebp
80103b67:	89 e5                	mov    %esp,%ebp
80103b69:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103b6c:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103b6f:	89 04 24             	mov    %eax,(%esp)
80103b72:	e8 45 ff ff ff       	call   80103abc <mpconfig>
80103b77:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b7a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b7e:	75 0c                	jne    80103b8c <mpinit+0x26>
    panic("Expect to run on an SMP");
80103b80:	c7 04 24 36 85 10 80 	movl   $0x80108536,(%esp)
80103b87:	e8 d6 c9 ff ff       	call   80100562 <panic>
  ismp = 1;
80103b8c:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80103b93:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b96:	8b 40 24             	mov    0x24(%eax),%eax
80103b99:	a3 fc 36 11 80       	mov    %eax,0x801136fc
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103b9e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ba1:	83 c0 2c             	add    $0x2c,%eax
80103ba4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103ba7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103baa:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103bae:	0f b7 d0             	movzwl %ax,%edx
80103bb1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103bb4:	01 d0                	add    %edx,%eax
80103bb6:	89 45 e8             	mov    %eax,-0x18(%ebp)
80103bb9:	eb 7b                	jmp    80103c36 <mpinit+0xd0>
    switch(*p){
80103bbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bbe:	0f b6 00             	movzbl (%eax),%eax
80103bc1:	0f b6 c0             	movzbl %al,%eax
80103bc4:	83 f8 04             	cmp    $0x4,%eax
80103bc7:	77 65                	ja     80103c2e <mpinit+0xc8>
80103bc9:	8b 04 85 70 85 10 80 	mov    -0x7fef7a90(,%eax,4),%eax
80103bd0:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103bd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bd5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(ncpu < NCPU) {
80103bd8:	a1 80 3d 11 80       	mov    0x80113d80,%eax
80103bdd:	83 f8 07             	cmp    $0x7,%eax
80103be0:	7f 28                	jg     80103c0a <mpinit+0xa4>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103be2:	8b 15 80 3d 11 80    	mov    0x80113d80,%edx
80103be8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103beb:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103bef:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80103bf5:	81 c2 00 38 11 80    	add    $0x80113800,%edx
80103bfb:	88 02                	mov    %al,(%edx)
        ncpu++;
80103bfd:	a1 80 3d 11 80       	mov    0x80113d80,%eax
80103c02:	83 c0 01             	add    $0x1,%eax
80103c05:	a3 80 3d 11 80       	mov    %eax,0x80113d80
      }
      p += sizeof(struct mpproc);
80103c0a:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103c0e:	eb 26                	jmp    80103c36 <mpinit+0xd0>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103c10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c13:	89 45 e0             	mov    %eax,-0x20(%ebp)
      ioapicid = ioapic->apicno;
80103c16:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103c19:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c1d:	a2 e0 37 11 80       	mov    %al,0x801137e0
      p += sizeof(struct mpioapic);
80103c22:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103c26:	eb 0e                	jmp    80103c36 <mpinit+0xd0>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103c28:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103c2c:	eb 08                	jmp    80103c36 <mpinit+0xd0>
    default:
      ismp = 0;
80103c2e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
80103c35:	90                   	nop
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103c36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c39:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80103c3c:	0f 82 79 ff ff ff    	jb     80103bbb <mpinit+0x55>
    }
  }
  if(!ismp)
80103c42:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103c46:	75 0c                	jne    80103c54 <mpinit+0xee>
    panic("Didn't find a suitable machine");
80103c48:	c7 04 24 50 85 10 80 	movl   $0x80108550,(%esp)
80103c4f:	e8 0e c9 ff ff       	call   80100562 <panic>

  if(mp->imcrp){
80103c54:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103c57:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103c5b:	84 c0                	test   %al,%al
80103c5d:	74 36                	je     80103c95 <mpinit+0x12f>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103c5f:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103c66:	00 
80103c67:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103c6e:	e8 c7 fc ff ff       	call   8010393a <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103c73:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103c7a:	e8 9e fc ff ff       	call   8010391d <inb>
80103c7f:	83 c8 01             	or     $0x1,%eax
80103c82:	0f b6 c0             	movzbl %al,%eax
80103c85:	89 44 24 04          	mov    %eax,0x4(%esp)
80103c89:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103c90:	e8 a5 fc ff ff       	call   8010393a <outb>
  }
}
80103c95:	c9                   	leave  
80103c96:	c3                   	ret    

80103c97 <outb>:
{
80103c97:	55                   	push   %ebp
80103c98:	89 e5                	mov    %esp,%ebp
80103c9a:	83 ec 08             	sub    $0x8,%esp
80103c9d:	8b 55 08             	mov    0x8(%ebp),%edx
80103ca0:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ca3:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103ca7:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103caa:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103cae:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103cb2:	ee                   	out    %al,(%dx)
}
80103cb3:	c9                   	leave  
80103cb4:	c3                   	ret    

80103cb5 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103cb5:	55                   	push   %ebp
80103cb6:	89 e5                	mov    %esp,%ebp
80103cb8:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103cbb:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103cc2:	00 
80103cc3:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103cca:	e8 c8 ff ff ff       	call   80103c97 <outb>
  outb(IO_PIC2+1, 0xFF);
80103ccf:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103cd6:	00 
80103cd7:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103cde:	e8 b4 ff ff ff       	call   80103c97 <outb>
}
80103ce3:	c9                   	leave  
80103ce4:	c3                   	ret    

80103ce5 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103ce5:	55                   	push   %ebp
80103ce6:	89 e5                	mov    %esp,%ebp
80103ce8:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103ceb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103cf2:	8b 45 0c             	mov    0xc(%ebp),%eax
80103cf5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103cfb:	8b 45 0c             	mov    0xc(%ebp),%eax
80103cfe:	8b 10                	mov    (%eax),%edx
80103d00:	8b 45 08             	mov    0x8(%ebp),%eax
80103d03:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103d05:	e8 7b d2 ff ff       	call   80100f85 <filealloc>
80103d0a:	8b 55 08             	mov    0x8(%ebp),%edx
80103d0d:	89 02                	mov    %eax,(%edx)
80103d0f:	8b 45 08             	mov    0x8(%ebp),%eax
80103d12:	8b 00                	mov    (%eax),%eax
80103d14:	85 c0                	test   %eax,%eax
80103d16:	0f 84 c8 00 00 00    	je     80103de4 <pipealloc+0xff>
80103d1c:	e8 64 d2 ff ff       	call   80100f85 <filealloc>
80103d21:	8b 55 0c             	mov    0xc(%ebp),%edx
80103d24:	89 02                	mov    %eax,(%edx)
80103d26:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d29:	8b 00                	mov    (%eax),%eax
80103d2b:	85 c0                	test   %eax,%eax
80103d2d:	0f 84 b1 00 00 00    	je     80103de4 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103d33:	e8 71 ee ff ff       	call   80102ba9 <kalloc>
80103d38:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d3b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d3f:	75 05                	jne    80103d46 <pipealloc+0x61>
    goto bad;
80103d41:	e9 9e 00 00 00       	jmp    80103de4 <pipealloc+0xff>
  p->readopen = 1;
80103d46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d49:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103d50:	00 00 00 
  p->writeopen = 1;
80103d53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d56:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103d5d:	00 00 00 
  p->nwrite = 0;
80103d60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d63:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103d6a:	00 00 00 
  p->nread = 0;
80103d6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d70:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103d77:	00 00 00 
  initlock(&p->lock, "pipe");
80103d7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d7d:	c7 44 24 04 84 85 10 	movl   $0x80108584,0x4(%esp)
80103d84:	80 
80103d85:	89 04 24             	mov    %eax,(%esp)
80103d88:	e8 10 10 00 00       	call   80104d9d <initlock>
  (*f0)->type = FD_PIPE;
80103d8d:	8b 45 08             	mov    0x8(%ebp),%eax
80103d90:	8b 00                	mov    (%eax),%eax
80103d92:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103d98:	8b 45 08             	mov    0x8(%ebp),%eax
80103d9b:	8b 00                	mov    (%eax),%eax
80103d9d:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103da1:	8b 45 08             	mov    0x8(%ebp),%eax
80103da4:	8b 00                	mov    (%eax),%eax
80103da6:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103daa:	8b 45 08             	mov    0x8(%ebp),%eax
80103dad:	8b 00                	mov    (%eax),%eax
80103daf:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103db2:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103db5:	8b 45 0c             	mov    0xc(%ebp),%eax
80103db8:	8b 00                	mov    (%eax),%eax
80103dba:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103dc0:	8b 45 0c             	mov    0xc(%ebp),%eax
80103dc3:	8b 00                	mov    (%eax),%eax
80103dc5:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103dc9:	8b 45 0c             	mov    0xc(%ebp),%eax
80103dcc:	8b 00                	mov    (%eax),%eax
80103dce:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103dd2:	8b 45 0c             	mov    0xc(%ebp),%eax
80103dd5:	8b 00                	mov    (%eax),%eax
80103dd7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103dda:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103ddd:	b8 00 00 00 00       	mov    $0x0,%eax
80103de2:	eb 42                	jmp    80103e26 <pipealloc+0x141>

//PAGEBREAK: 20
 bad:
  if(p)
80103de4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103de8:	74 0b                	je     80103df5 <pipealloc+0x110>
    kfree((char*)p);
80103dea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ded:	89 04 24             	mov    %eax,(%esp)
80103df0:	e8 1e ed ff ff       	call   80102b13 <kfree>
  if(*f0)
80103df5:	8b 45 08             	mov    0x8(%ebp),%eax
80103df8:	8b 00                	mov    (%eax),%eax
80103dfa:	85 c0                	test   %eax,%eax
80103dfc:	74 0d                	je     80103e0b <pipealloc+0x126>
    fileclose(*f0);
80103dfe:	8b 45 08             	mov    0x8(%ebp),%eax
80103e01:	8b 00                	mov    (%eax),%eax
80103e03:	89 04 24             	mov    %eax,(%esp)
80103e06:	e8 22 d2 ff ff       	call   8010102d <fileclose>
  if(*f1)
80103e0b:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e0e:	8b 00                	mov    (%eax),%eax
80103e10:	85 c0                	test   %eax,%eax
80103e12:	74 0d                	je     80103e21 <pipealloc+0x13c>
    fileclose(*f1);
80103e14:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e17:	8b 00                	mov    (%eax),%eax
80103e19:	89 04 24             	mov    %eax,(%esp)
80103e1c:	e8 0c d2 ff ff       	call   8010102d <fileclose>
  return -1;
80103e21:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103e26:	c9                   	leave  
80103e27:	c3                   	ret    

80103e28 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103e28:	55                   	push   %ebp
80103e29:	89 e5                	mov    %esp,%ebp
80103e2b:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
80103e2e:	8b 45 08             	mov    0x8(%ebp),%eax
80103e31:	89 04 24             	mov    %eax,(%esp)
80103e34:	e8 85 0f 00 00       	call   80104dbe <acquire>
  if(writable){
80103e39:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103e3d:	74 1f                	je     80103e5e <pipeclose+0x36>
    p->writeopen = 0;
80103e3f:	8b 45 08             	mov    0x8(%ebp),%eax
80103e42:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103e49:	00 00 00 
    wakeup(&p->nread);
80103e4c:	8b 45 08             	mov    0x8(%ebp),%eax
80103e4f:	05 34 02 00 00       	add    $0x234,%eax
80103e54:	89 04 24             	mov    %eax,(%esp)
80103e57:	e8 44 0c 00 00       	call   80104aa0 <wakeup>
80103e5c:	eb 1d                	jmp    80103e7b <pipeclose+0x53>
  } else {
    p->readopen = 0;
80103e5e:	8b 45 08             	mov    0x8(%ebp),%eax
80103e61:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103e68:	00 00 00 
    wakeup(&p->nwrite);
80103e6b:	8b 45 08             	mov    0x8(%ebp),%eax
80103e6e:	05 38 02 00 00       	add    $0x238,%eax
80103e73:	89 04 24             	mov    %eax,(%esp)
80103e76:	e8 25 0c 00 00       	call   80104aa0 <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103e7b:	8b 45 08             	mov    0x8(%ebp),%eax
80103e7e:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103e84:	85 c0                	test   %eax,%eax
80103e86:	75 25                	jne    80103ead <pipeclose+0x85>
80103e88:	8b 45 08             	mov    0x8(%ebp),%eax
80103e8b:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103e91:	85 c0                	test   %eax,%eax
80103e93:	75 18                	jne    80103ead <pipeclose+0x85>
    release(&p->lock);
80103e95:	8b 45 08             	mov    0x8(%ebp),%eax
80103e98:	89 04 24             	mov    %eax,(%esp)
80103e9b:	e8 86 0f 00 00       	call   80104e26 <release>
    kfree((char*)p);
80103ea0:	8b 45 08             	mov    0x8(%ebp),%eax
80103ea3:	89 04 24             	mov    %eax,(%esp)
80103ea6:	e8 68 ec ff ff       	call   80102b13 <kfree>
80103eab:	eb 0b                	jmp    80103eb8 <pipeclose+0x90>
  } else
    release(&p->lock);
80103ead:	8b 45 08             	mov    0x8(%ebp),%eax
80103eb0:	89 04 24             	mov    %eax,(%esp)
80103eb3:	e8 6e 0f 00 00       	call   80104e26 <release>
}
80103eb8:	c9                   	leave  
80103eb9:	c3                   	ret    

80103eba <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103eba:	55                   	push   %ebp
80103ebb:	89 e5                	mov    %esp,%ebp
80103ebd:	83 ec 28             	sub    $0x28,%esp
  int i;

  acquire(&p->lock);
80103ec0:	8b 45 08             	mov    0x8(%ebp),%eax
80103ec3:	89 04 24             	mov    %eax,(%esp)
80103ec6:	e8 f3 0e 00 00       	call   80104dbe <acquire>
  for(i = 0; i < n; i++){
80103ecb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103ed2:	e9 a5 00 00 00       	jmp    80103f7c <pipewrite+0xc2>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103ed7:	eb 56                	jmp    80103f2f <pipewrite+0x75>
      if(p->readopen == 0 || myproc()->killed){
80103ed9:	8b 45 08             	mov    0x8(%ebp),%eax
80103edc:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103ee2:	85 c0                	test   %eax,%eax
80103ee4:	74 0c                	je     80103ef2 <pipewrite+0x38>
80103ee6:	e8 76 02 00 00       	call   80104161 <myproc>
80103eeb:	8b 40 24             	mov    0x24(%eax),%eax
80103eee:	85 c0                	test   %eax,%eax
80103ef0:	74 15                	je     80103f07 <pipewrite+0x4d>
        release(&p->lock);
80103ef2:	8b 45 08             	mov    0x8(%ebp),%eax
80103ef5:	89 04 24             	mov    %eax,(%esp)
80103ef8:	e8 29 0f 00 00       	call   80104e26 <release>
        return -1;
80103efd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f02:	e9 9f 00 00 00       	jmp    80103fa6 <pipewrite+0xec>
      }
      wakeup(&p->nread);
80103f07:	8b 45 08             	mov    0x8(%ebp),%eax
80103f0a:	05 34 02 00 00       	add    $0x234,%eax
80103f0f:	89 04 24             	mov    %eax,(%esp)
80103f12:	e8 89 0b 00 00       	call   80104aa0 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103f17:	8b 45 08             	mov    0x8(%ebp),%eax
80103f1a:	8b 55 08             	mov    0x8(%ebp),%edx
80103f1d:	81 c2 38 02 00 00    	add    $0x238,%edx
80103f23:	89 44 24 04          	mov    %eax,0x4(%esp)
80103f27:	89 14 24             	mov    %edx,(%esp)
80103f2a:	e8 9d 0a 00 00       	call   801049cc <sleep>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103f2f:	8b 45 08             	mov    0x8(%ebp),%eax
80103f32:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80103f38:	8b 45 08             	mov    0x8(%ebp),%eax
80103f3b:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103f41:	05 00 02 00 00       	add    $0x200,%eax
80103f46:	39 c2                	cmp    %eax,%edx
80103f48:	74 8f                	je     80103ed9 <pipewrite+0x1f>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103f4a:	8b 45 08             	mov    0x8(%ebp),%eax
80103f4d:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103f53:	8d 48 01             	lea    0x1(%eax),%ecx
80103f56:	8b 55 08             	mov    0x8(%ebp),%edx
80103f59:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80103f5f:	25 ff 01 00 00       	and    $0x1ff,%eax
80103f64:	89 c1                	mov    %eax,%ecx
80103f66:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103f69:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f6c:	01 d0                	add    %edx,%eax
80103f6e:	0f b6 10             	movzbl (%eax),%edx
80103f71:	8b 45 08             	mov    0x8(%ebp),%eax
80103f74:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80103f78:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103f7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f7f:	3b 45 10             	cmp    0x10(%ebp),%eax
80103f82:	0f 8c 4f ff ff ff    	jl     80103ed7 <pipewrite+0x1d>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103f88:	8b 45 08             	mov    0x8(%ebp),%eax
80103f8b:	05 34 02 00 00       	add    $0x234,%eax
80103f90:	89 04 24             	mov    %eax,(%esp)
80103f93:	e8 08 0b 00 00       	call   80104aa0 <wakeup>
  release(&p->lock);
80103f98:	8b 45 08             	mov    0x8(%ebp),%eax
80103f9b:	89 04 24             	mov    %eax,(%esp)
80103f9e:	e8 83 0e 00 00       	call   80104e26 <release>
  return n;
80103fa3:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103fa6:	c9                   	leave  
80103fa7:	c3                   	ret    

80103fa8 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80103fa8:	55                   	push   %ebp
80103fa9:	89 e5                	mov    %esp,%ebp
80103fab:	53                   	push   %ebx
80103fac:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80103faf:	8b 45 08             	mov    0x8(%ebp),%eax
80103fb2:	89 04 24             	mov    %eax,(%esp)
80103fb5:	e8 04 0e 00 00       	call   80104dbe <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103fba:	eb 39                	jmp    80103ff5 <piperead+0x4d>
    if(myproc()->killed){
80103fbc:	e8 a0 01 00 00       	call   80104161 <myproc>
80103fc1:	8b 40 24             	mov    0x24(%eax),%eax
80103fc4:	85 c0                	test   %eax,%eax
80103fc6:	74 15                	je     80103fdd <piperead+0x35>
      release(&p->lock);
80103fc8:	8b 45 08             	mov    0x8(%ebp),%eax
80103fcb:	89 04 24             	mov    %eax,(%esp)
80103fce:	e8 53 0e 00 00       	call   80104e26 <release>
      return -1;
80103fd3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103fd8:	e9 b5 00 00 00       	jmp    80104092 <piperead+0xea>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103fdd:	8b 45 08             	mov    0x8(%ebp),%eax
80103fe0:	8b 55 08             	mov    0x8(%ebp),%edx
80103fe3:	81 c2 34 02 00 00    	add    $0x234,%edx
80103fe9:	89 44 24 04          	mov    %eax,0x4(%esp)
80103fed:	89 14 24             	mov    %edx,(%esp)
80103ff0:	e8 d7 09 00 00       	call   801049cc <sleep>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103ff5:	8b 45 08             	mov    0x8(%ebp),%eax
80103ff8:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103ffe:	8b 45 08             	mov    0x8(%ebp),%eax
80104001:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104007:	39 c2                	cmp    %eax,%edx
80104009:	75 0d                	jne    80104018 <piperead+0x70>
8010400b:	8b 45 08             	mov    0x8(%ebp),%eax
8010400e:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104014:	85 c0                	test   %eax,%eax
80104016:	75 a4                	jne    80103fbc <piperead+0x14>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104018:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010401f:	eb 4b                	jmp    8010406c <piperead+0xc4>
    if(p->nread == p->nwrite)
80104021:	8b 45 08             	mov    0x8(%ebp),%eax
80104024:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010402a:	8b 45 08             	mov    0x8(%ebp),%eax
8010402d:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104033:	39 c2                	cmp    %eax,%edx
80104035:	75 02                	jne    80104039 <piperead+0x91>
      break;
80104037:	eb 3b                	jmp    80104074 <piperead+0xcc>
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104039:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010403c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010403f:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104042:	8b 45 08             	mov    0x8(%ebp),%eax
80104045:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010404b:	8d 48 01             	lea    0x1(%eax),%ecx
8010404e:	8b 55 08             	mov    0x8(%ebp),%edx
80104051:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104057:	25 ff 01 00 00       	and    $0x1ff,%eax
8010405c:	89 c2                	mov    %eax,%edx
8010405e:	8b 45 08             	mov    0x8(%ebp),%eax
80104061:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
80104066:	88 03                	mov    %al,(%ebx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104068:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010406c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010406f:	3b 45 10             	cmp    0x10(%ebp),%eax
80104072:	7c ad                	jl     80104021 <piperead+0x79>
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104074:	8b 45 08             	mov    0x8(%ebp),%eax
80104077:	05 38 02 00 00       	add    $0x238,%eax
8010407c:	89 04 24             	mov    %eax,(%esp)
8010407f:	e8 1c 0a 00 00       	call   80104aa0 <wakeup>
  release(&p->lock);
80104084:	8b 45 08             	mov    0x8(%ebp),%eax
80104087:	89 04 24             	mov    %eax,(%esp)
8010408a:	e8 97 0d 00 00       	call   80104e26 <release>
  return i;
8010408f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104092:	83 c4 24             	add    $0x24,%esp
80104095:	5b                   	pop    %ebx
80104096:	5d                   	pop    %ebp
80104097:	c3                   	ret    

80104098 <readeflags>:
{
80104098:	55                   	push   %ebp
80104099:	89 e5                	mov    %esp,%ebp
8010409b:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010409e:	9c                   	pushf  
8010409f:	58                   	pop    %eax
801040a0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801040a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801040a6:	c9                   	leave  
801040a7:	c3                   	ret    

801040a8 <sti>:
{
801040a8:	55                   	push   %ebp
801040a9:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801040ab:	fb                   	sti    
}
801040ac:	5d                   	pop    %ebp
801040ad:	c3                   	ret    

801040ae <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
801040ae:	55                   	push   %ebp
801040af:	89 e5                	mov    %esp,%ebp
801040b1:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
801040b4:	c7 44 24 04 8c 85 10 	movl   $0x8010858c,0x4(%esp)
801040bb:	80 
801040bc:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
801040c3:	e8 d5 0c 00 00       	call   80104d9d <initlock>
}
801040c8:	c9                   	leave  
801040c9:	c3                   	ret    

801040ca <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
801040ca:	55                   	push   %ebp
801040cb:	89 e5                	mov    %esp,%ebp
801040cd:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
801040d0:	e8 16 00 00 00       	call   801040eb <mycpu>
801040d5:	89 c2                	mov    %eax,%edx
801040d7:	b8 00 38 11 80       	mov    $0x80113800,%eax
801040dc:	29 c2                	sub    %eax,%edx
801040de:	89 d0                	mov    %edx,%eax
801040e0:	c1 f8 04             	sar    $0x4,%eax
801040e3:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
801040e9:	c9                   	leave  
801040ea:	c3                   	ret    

801040eb <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
801040eb:	55                   	push   %ebp
801040ec:	89 e5                	mov    %esp,%ebp
801040ee:	83 ec 28             	sub    $0x28,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF)
801040f1:	e8 a2 ff ff ff       	call   80104098 <readeflags>
801040f6:	25 00 02 00 00       	and    $0x200,%eax
801040fb:	85 c0                	test   %eax,%eax
801040fd:	74 0c                	je     8010410b <mycpu+0x20>
    panic("mycpu called with interrupts enabled\n");
801040ff:	c7 04 24 94 85 10 80 	movl   $0x80108594,(%esp)
80104106:	e8 57 c4 ff ff       	call   80100562 <panic>
  
  apicid = lapicid();
8010410b:	e8 1f ee ff ff       	call   80102f2f <lapicid>
80104110:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80104113:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010411a:	eb 2d                	jmp    80104149 <mycpu+0x5e>
    if (cpus[i].apicid == apicid)
8010411c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010411f:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80104125:	05 00 38 11 80       	add    $0x80113800,%eax
8010412a:	0f b6 00             	movzbl (%eax),%eax
8010412d:	0f b6 c0             	movzbl %al,%eax
80104130:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80104133:	75 10                	jne    80104145 <mycpu+0x5a>
      return &cpus[i];
80104135:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104138:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
8010413e:	05 00 38 11 80       	add    $0x80113800,%eax
80104143:	eb 1a                	jmp    8010415f <mycpu+0x74>
  for (i = 0; i < ncpu; ++i) {
80104145:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104149:	a1 80 3d 11 80       	mov    0x80113d80,%eax
8010414e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80104151:	7c c9                	jl     8010411c <mycpu+0x31>
  }
  panic("unknown apicid\n");
80104153:	c7 04 24 ba 85 10 80 	movl   $0x801085ba,(%esp)
8010415a:	e8 03 c4 ff ff       	call   80100562 <panic>
}
8010415f:	c9                   	leave  
80104160:	c3                   	ret    

80104161 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80104161:	55                   	push   %ebp
80104162:	89 e5                	mov    %esp,%ebp
80104164:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80104167:	e8 bf 0d 00 00       	call   80104f2b <pushcli>
  c = mycpu();
8010416c:	e8 7a ff ff ff       	call   801040eb <mycpu>
80104171:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80104174:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104177:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010417d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80104180:	e8 f2 0d 00 00       	call   80104f77 <popcli>
  return p;
80104185:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80104188:	c9                   	leave  
80104189:	c3                   	ret    

8010418a <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
8010418a:	55                   	push   %ebp
8010418b:	89 e5                	mov    %esp,%ebp
8010418d:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104190:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
80104197:	e8 22 0c 00 00       	call   80104dbe <acquire>

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010419c:	c7 45 f4 d4 3d 11 80 	movl   $0x80113dd4,-0xc(%ebp)
801041a3:	eb 50                	jmp    801041f5 <allocproc+0x6b>
    if(p->state == UNUSED)
801041a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041a8:	8b 40 0c             	mov    0xc(%eax),%eax
801041ab:	85 c0                	test   %eax,%eax
801041ad:	75 42                	jne    801041f1 <allocproc+0x67>
      goto found;
801041af:	90                   	nop

  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
801041b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041b3:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801041ba:	a1 00 b0 10 80       	mov    0x8010b000,%eax
801041bf:	8d 50 01             	lea    0x1(%eax),%edx
801041c2:	89 15 00 b0 10 80    	mov    %edx,0x8010b000
801041c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041cb:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
801041ce:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
801041d5:	e8 4c 0c 00 00       	call   80104e26 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801041da:	e8 ca e9 ff ff       	call   80102ba9 <kalloc>
801041df:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041e2:	89 42 08             	mov    %eax,0x8(%edx)
801041e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041e8:	8b 40 08             	mov    0x8(%eax),%eax
801041eb:	85 c0                	test   %eax,%eax
801041ed:	75 33                	jne    80104222 <allocproc+0x98>
801041ef:	eb 20                	jmp    80104211 <allocproc+0x87>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801041f1:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801041f5:	81 7d f4 d4 5c 11 80 	cmpl   $0x80115cd4,-0xc(%ebp)
801041fc:	72 a7                	jb     801041a5 <allocproc+0x1b>
  release(&ptable.lock);
801041fe:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
80104205:	e8 1c 0c 00 00       	call   80104e26 <release>
  return 0;
8010420a:	b8 00 00 00 00       	mov    $0x0,%eax
8010420f:	eb 76                	jmp    80104287 <allocproc+0xfd>
    p->state = UNUSED;
80104211:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104214:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
8010421b:	b8 00 00 00 00       	mov    $0x0,%eax
80104220:	eb 65                	jmp    80104287 <allocproc+0xfd>
  }
  sp = p->kstack + KSTACKSIZE;
80104222:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104225:	8b 40 08             	mov    0x8(%eax),%eax
80104228:	05 00 10 00 00       	add    $0x1000,%eax
8010422d:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104230:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104234:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104237:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010423a:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
8010423d:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104241:	ba 28 64 10 80       	mov    $0x80106428,%edx
80104246:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104249:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
8010424b:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
8010424f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104252:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104255:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104258:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010425b:	8b 40 1c             	mov    0x1c(%eax),%eax
8010425e:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80104265:	00 
80104266:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010426d:	00 
8010426e:	89 04 24             	mov    %eax,(%esp)
80104271:	e8 ba 0d 00 00       	call   80105030 <memset>
  p->context->eip = (uint)forkret;
80104276:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104279:	8b 40 1c             	mov    0x1c(%eax),%eax
8010427c:	ba 8d 49 10 80       	mov    $0x8010498d,%edx
80104281:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80104284:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104287:	c9                   	leave  
80104288:	c3                   	ret    

80104289 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104289:	55                   	push   %ebp
8010428a:	89 e5                	mov    %esp,%ebp
8010428c:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
8010428f:	e8 f6 fe ff ff       	call   8010418a <allocproc>
80104294:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80104297:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010429a:	a3 20 b6 10 80       	mov    %eax,0x8010b620
  if((p->pgdir = setupkvm()) == 0)
8010429f:	e8 01 37 00 00       	call   801079a5 <setupkvm>
801042a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042a7:	89 42 04             	mov    %eax,0x4(%edx)
801042aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042ad:	8b 40 04             	mov    0x4(%eax),%eax
801042b0:	85 c0                	test   %eax,%eax
801042b2:	75 0c                	jne    801042c0 <userinit+0x37>
    panic("userinit: out of memory?");
801042b4:	c7 04 24 ca 85 10 80 	movl   $0x801085ca,(%esp)
801042bb:	e8 a2 c2 ff ff       	call   80100562 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801042c0:	ba 2c 00 00 00       	mov    $0x2c,%edx
801042c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042c8:	8b 40 04             	mov    0x4(%eax),%eax
801042cb:	89 54 24 08          	mov    %edx,0x8(%esp)
801042cf:	c7 44 24 04 c0 b4 10 	movl   $0x8010b4c0,0x4(%esp)
801042d6:	80 
801042d7:	89 04 24             	mov    %eax,(%esp)
801042da:	e8 31 39 00 00       	call   80107c10 <inituvm>
  p->sz = PGSIZE;
801042df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042e2:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801042e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042eb:	8b 40 18             	mov    0x18(%eax),%eax
801042ee:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
801042f5:	00 
801042f6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801042fd:	00 
801042fe:	89 04 24             	mov    %eax,(%esp)
80104301:	e8 2a 0d 00 00       	call   80105030 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104306:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104309:	8b 40 18             	mov    0x18(%eax),%eax
8010430c:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104312:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104315:	8b 40 18             	mov    0x18(%eax),%eax
80104318:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010431e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104321:	8b 40 18             	mov    0x18(%eax),%eax
80104324:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104327:	8b 52 18             	mov    0x18(%edx),%edx
8010432a:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010432e:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104332:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104335:	8b 40 18             	mov    0x18(%eax),%eax
80104338:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010433b:	8b 52 18             	mov    0x18(%edx),%edx
8010433e:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104342:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104346:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104349:	8b 40 18             	mov    0x18(%eax),%eax
8010434c:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104353:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104356:	8b 40 18             	mov    0x18(%eax),%eax
80104359:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104360:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104363:	8b 40 18             	mov    0x18(%eax),%eax
80104366:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
8010436d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104370:	83 c0 6c             	add    $0x6c,%eax
80104373:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010437a:	00 
8010437b:	c7 44 24 04 e3 85 10 	movl   $0x801085e3,0x4(%esp)
80104382:	80 
80104383:	89 04 24             	mov    %eax,(%esp)
80104386:	e8 c5 0e 00 00       	call   80105250 <safestrcpy>
  p->cwd = namei("/");
8010438b:	c7 04 24 ec 85 10 80 	movl   $0x801085ec,(%esp)
80104392:	e8 00 e1 ff ff       	call   80102497 <namei>
80104397:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010439a:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
8010439d:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
801043a4:	e8 15 0a 00 00       	call   80104dbe <acquire>

  p->state = RUNNABLE;
801043a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ac:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
801043b3:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
801043ba:	e8 67 0a 00 00       	call   80104e26 <release>
}
801043bf:	c9                   	leave  
801043c0:	c3                   	ret    

801043c1 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801043c1:	55                   	push   %ebp
801043c2:	89 e5                	mov    %esp,%ebp
801043c4:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  struct proc *curproc = myproc();
801043c7:	e8 95 fd ff ff       	call   80104161 <myproc>
801043cc:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
801043cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043d2:	8b 00                	mov    (%eax),%eax
801043d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801043d7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801043db:	7e 31                	jle    8010440e <growproc+0x4d>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
801043dd:	8b 55 08             	mov    0x8(%ebp),%edx
801043e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043e3:	01 c2                	add    %eax,%edx
801043e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043e8:	8b 40 04             	mov    0x4(%eax),%eax
801043eb:	89 54 24 08          	mov    %edx,0x8(%esp)
801043ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043f2:	89 54 24 04          	mov    %edx,0x4(%esp)
801043f6:	89 04 24             	mov    %eax,(%esp)
801043f9:	e8 7d 39 00 00       	call   80107d7b <allocuvm>
801043fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104401:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104405:	75 3e                	jne    80104445 <growproc+0x84>
      return -1;
80104407:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010440c:	eb 4f                	jmp    8010445d <growproc+0x9c>
  } else if(n < 0){
8010440e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104412:	79 31                	jns    80104445 <growproc+0x84>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104414:	8b 55 08             	mov    0x8(%ebp),%edx
80104417:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010441a:	01 c2                	add    %eax,%edx
8010441c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010441f:	8b 40 04             	mov    0x4(%eax),%eax
80104422:	89 54 24 08          	mov    %edx,0x8(%esp)
80104426:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104429:	89 54 24 04          	mov    %edx,0x4(%esp)
8010442d:	89 04 24             	mov    %eax,(%esp)
80104430:	e8 5c 3a 00 00       	call   80107e91 <deallocuvm>
80104435:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104438:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010443c:	75 07                	jne    80104445 <growproc+0x84>
      return -1;
8010443e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104443:	eb 18                	jmp    8010445d <growproc+0x9c>
  }
  curproc->sz = sz;
80104445:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104448:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010444b:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
8010444d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104450:	89 04 24             	mov    %eax,(%esp)
80104453:	e8 27 36 00 00       	call   80107a7f <switchuvm>
  return 0;
80104458:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010445d:	c9                   	leave  
8010445e:	c3                   	ret    

8010445f <get_fork_count>:


// Function to get the current fork count
int
get_fork_count(void)
{
8010445f:	55                   	push   %ebp
80104460:	89 e5                	mov    %esp,%ebp
  return fork_count;
80104462:	a1 24 b6 10 80       	mov    0x8010b624,%eax
}
80104467:	5d                   	pop    %ebp
80104468:	c3                   	ret    

80104469 <reset_fork_count>:

// Function to reset the fork count
void
reset_fork_count(void)
{
80104469:	55                   	push   %ebp
8010446a:	89 e5                	mov    %esp,%ebp
  fork_count = 0;
8010446c:	c7 05 24 b6 10 80 00 	movl   $0x0,0x8010b624
80104473:	00 00 00 
}
80104476:	5d                   	pop    %ebp
80104477:	c3                   	ret    

80104478 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104478:	55                   	push   %ebp
80104479:	89 e5                	mov    %esp,%ebp
8010447b:	57                   	push   %edi
8010447c:	56                   	push   %esi
8010447d:	53                   	push   %ebx
8010447e:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80104481:	e8 db fc ff ff       	call   80104161 <myproc>
80104486:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80104489:	e8 fc fc ff ff       	call   8010418a <allocproc>
8010448e:	89 45 dc             	mov    %eax,-0x24(%ebp)
80104491:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80104495:	75 0a                	jne    801044a1 <fork+0x29>
    return -1;
80104497:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010449c:	e9 43 01 00 00       	jmp    801045e4 <fork+0x16c>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
801044a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801044a4:	8b 10                	mov    (%eax),%edx
801044a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801044a9:	8b 40 04             	mov    0x4(%eax),%eax
801044ac:	89 54 24 04          	mov    %edx,0x4(%esp)
801044b0:	89 04 24             	mov    %eax,(%esp)
801044b3:	e8 7c 3b 00 00       	call   80108034 <copyuvm>
801044b8:	8b 55 dc             	mov    -0x24(%ebp),%edx
801044bb:	89 42 04             	mov    %eax,0x4(%edx)
801044be:	8b 45 dc             	mov    -0x24(%ebp),%eax
801044c1:	8b 40 04             	mov    0x4(%eax),%eax
801044c4:	85 c0                	test   %eax,%eax
801044c6:	75 2c                	jne    801044f4 <fork+0x7c>
    kfree(np->kstack);
801044c8:	8b 45 dc             	mov    -0x24(%ebp),%eax
801044cb:	8b 40 08             	mov    0x8(%eax),%eax
801044ce:	89 04 24             	mov    %eax,(%esp)
801044d1:	e8 3d e6 ff ff       	call   80102b13 <kfree>
    np->kstack = 0;
801044d6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801044d9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801044e0:	8b 45 dc             	mov    -0x24(%ebp),%eax
801044e3:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801044ea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044ef:	e9 f0 00 00 00       	jmp    801045e4 <fork+0x16c>
  }
  np->sz = curproc->sz;
801044f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801044f7:	8b 10                	mov    (%eax),%edx
801044f9:	8b 45 dc             	mov    -0x24(%ebp),%eax
801044fc:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
801044fe:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104501:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104504:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80104507:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010450a:	8b 50 18             	mov    0x18(%eax),%edx
8010450d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104510:	8b 40 18             	mov    0x18(%eax),%eax
80104513:	89 c3                	mov    %eax,%ebx
80104515:	b8 13 00 00 00       	mov    $0x13,%eax
8010451a:	89 d7                	mov    %edx,%edi
8010451c:	89 de                	mov    %ebx,%esi
8010451e:	89 c1                	mov    %eax,%ecx
80104520:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104522:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104525:	8b 40 18             	mov    0x18(%eax),%eax
80104528:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
8010452f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104536:	eb 37                	jmp    8010456f <fork+0xf7>
    if(curproc->ofile[i])
80104538:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010453b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010453e:	83 c2 08             	add    $0x8,%edx
80104541:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104545:	85 c0                	test   %eax,%eax
80104547:	74 22                	je     8010456b <fork+0xf3>
      np->ofile[i] = filedup(curproc->ofile[i]);
80104549:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010454c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010454f:	83 c2 08             	add    $0x8,%edx
80104552:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104556:	89 04 24             	mov    %eax,(%esp)
80104559:	e8 87 ca ff ff       	call   80100fe5 <filedup>
8010455e:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104561:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104564:	83 c1 08             	add    $0x8,%ecx
80104567:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
8010456b:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010456f:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104573:	7e c3                	jle    80104538 <fork+0xc0>
  np->cwd = idup(curproc->cwd);
80104575:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104578:	8b 40 68             	mov    0x68(%eax),%eax
8010457b:	89 04 24             	mov    %eax,(%esp)
8010457e:	e8 a8 d3 ff ff       	call   8010192b <idup>
80104583:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104586:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80104589:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010458c:	8d 50 6c             	lea    0x6c(%eax),%edx
8010458f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104592:	83 c0 6c             	add    $0x6c,%eax
80104595:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010459c:	00 
8010459d:	89 54 24 04          	mov    %edx,0x4(%esp)
801045a1:	89 04 24             	mov    %eax,(%esp)
801045a4:	e8 a7 0c 00 00       	call   80105250 <safestrcpy>

  pid = np->pid;
801045a9:	8b 45 dc             	mov    -0x24(%ebp),%eax
801045ac:	8b 40 10             	mov    0x10(%eax),%eax
801045af:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
801045b2:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
801045b9:	e8 00 08 00 00       	call   80104dbe <acquire>

  np->state = RUNNABLE;
801045be:	8b 45 dc             	mov    -0x24(%ebp),%eax
801045c1:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
801045c8:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
801045cf:	e8 52 08 00 00       	call   80104e26 <release>

  fork_count++;
801045d4:	a1 24 b6 10 80       	mov    0x8010b624,%eax
801045d9:	83 c0 01             	add    $0x1,%eax
801045dc:	a3 24 b6 10 80       	mov    %eax,0x8010b624

  return pid;
801045e1:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
801045e4:	83 c4 2c             	add    $0x2c,%esp
801045e7:	5b                   	pop    %ebx
801045e8:	5e                   	pop    %esi
801045e9:	5f                   	pop    %edi
801045ea:	5d                   	pop    %ebp
801045eb:	c3                   	ret    

801045ec <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801045ec:	55                   	push   %ebp
801045ed:	89 e5                	mov    %esp,%ebp
801045ef:	83 ec 28             	sub    $0x28,%esp
  struct proc *curproc = myproc();
801045f2:	e8 6a fb ff ff       	call   80104161 <myproc>
801045f7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
801045fa:	a1 20 b6 10 80       	mov    0x8010b620,%eax
801045ff:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104602:	75 0c                	jne    80104610 <exit+0x24>
    panic("init exiting");
80104604:	c7 04 24 ee 85 10 80 	movl   $0x801085ee,(%esp)
8010460b:	e8 52 bf ff ff       	call   80100562 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104610:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104617:	eb 3b                	jmp    80104654 <exit+0x68>
    if(curproc->ofile[fd]){
80104619:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010461c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010461f:	83 c2 08             	add    $0x8,%edx
80104622:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104626:	85 c0                	test   %eax,%eax
80104628:	74 26                	je     80104650 <exit+0x64>
      fileclose(curproc->ofile[fd]);
8010462a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010462d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104630:	83 c2 08             	add    $0x8,%edx
80104633:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104637:	89 04 24             	mov    %eax,(%esp)
8010463a:	e8 ee c9 ff ff       	call   8010102d <fileclose>
      curproc->ofile[fd] = 0;
8010463f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104642:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104645:	83 c2 08             	add    $0x8,%edx
80104648:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010464f:	00 
  for(fd = 0; fd < NOFILE; fd++){
80104650:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104654:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104658:	7e bf                	jle    80104619 <exit+0x2d>
    }
  }

  begin_op();
8010465a:	e8 28 ee ff ff       	call   80103487 <begin_op>
  iput(curproc->cwd);
8010465f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104662:	8b 40 68             	mov    0x68(%eax),%eax
80104665:	89 04 24             	mov    %eax,(%esp)
80104668:	e8 41 d4 ff ff       	call   80101aae <iput>
  end_op();
8010466d:	e8 99 ee ff ff       	call   8010350b <end_op>
  curproc->cwd = 0;
80104672:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104675:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
8010467c:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
80104683:	e8 36 07 00 00       	call   80104dbe <acquire>

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104688:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010468b:	8b 40 14             	mov    0x14(%eax),%eax
8010468e:	89 04 24             	mov    %eax,(%esp)
80104691:	e8 cc 03 00 00       	call   80104a62 <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104696:	c7 45 f4 d4 3d 11 80 	movl   $0x80113dd4,-0xc(%ebp)
8010469d:	eb 33                	jmp    801046d2 <exit+0xe6>
    if(p->parent == curproc){
8010469f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046a2:	8b 40 14             	mov    0x14(%eax),%eax
801046a5:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801046a8:	75 24                	jne    801046ce <exit+0xe2>
      p->parent = initproc;
801046aa:	8b 15 20 b6 10 80    	mov    0x8010b620,%edx
801046b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046b3:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801046b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046b9:	8b 40 0c             	mov    0xc(%eax),%eax
801046bc:	83 f8 05             	cmp    $0x5,%eax
801046bf:	75 0d                	jne    801046ce <exit+0xe2>
        wakeup1(initproc);
801046c1:	a1 20 b6 10 80       	mov    0x8010b620,%eax
801046c6:	89 04 24             	mov    %eax,(%esp)
801046c9:	e8 94 03 00 00       	call   80104a62 <wakeup1>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801046ce:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801046d2:	81 7d f4 d4 5c 11 80 	cmpl   $0x80115cd4,-0xc(%ebp)
801046d9:	72 c4                	jb     8010469f <exit+0xb3>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
801046db:	8b 45 ec             	mov    -0x14(%ebp),%eax
801046de:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801046e5:	e8 c3 01 00 00       	call   801048ad <sched>
  panic("zombie exit");
801046ea:	c7 04 24 fb 85 10 80 	movl   $0x801085fb,(%esp)
801046f1:	e8 6c be ff ff       	call   80100562 <panic>

801046f6 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801046f6:	55                   	push   %ebp
801046f7:	89 e5                	mov    %esp,%ebp
801046f9:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
801046fc:	e8 60 fa ff ff       	call   80104161 <myproc>
80104701:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80104704:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
8010470b:	e8 ae 06 00 00       	call   80104dbe <acquire>
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104710:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104717:	c7 45 f4 d4 3d 11 80 	movl   $0x80113dd4,-0xc(%ebp)
8010471e:	e9 95 00 00 00       	jmp    801047b8 <wait+0xc2>
      if(p->parent != curproc)
80104723:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104726:	8b 40 14             	mov    0x14(%eax),%eax
80104729:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010472c:	74 05                	je     80104733 <wait+0x3d>
        continue;
8010472e:	e9 81 00 00 00       	jmp    801047b4 <wait+0xbe>
      havekids = 1;
80104733:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
8010473a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010473d:	8b 40 0c             	mov    0xc(%eax),%eax
80104740:	83 f8 05             	cmp    $0x5,%eax
80104743:	75 6f                	jne    801047b4 <wait+0xbe>
        // Found one.
        pid = p->pid;
80104745:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104748:	8b 40 10             	mov    0x10(%eax),%eax
8010474b:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
8010474e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104751:	8b 40 08             	mov    0x8(%eax),%eax
80104754:	89 04 24             	mov    %eax,(%esp)
80104757:	e8 b7 e3 ff ff       	call   80102b13 <kfree>
        p->kstack = 0;
8010475c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010475f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104766:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104769:	8b 40 04             	mov    0x4(%eax),%eax
8010476c:	89 04 24             	mov    %eax,(%esp)
8010476f:	e8 e3 37 00 00       	call   80107f57 <freevm>
        p->pid = 0;
80104774:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104777:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
8010477e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104781:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104788:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010478b:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010478f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104792:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104799:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010479c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
801047a3:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
801047aa:	e8 77 06 00 00       	call   80104e26 <release>
        return pid;
801047af:	8b 45 e8             	mov    -0x18(%ebp),%eax
801047b2:	eb 4c                	jmp    80104800 <wait+0x10a>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801047b4:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801047b8:	81 7d f4 d4 5c 11 80 	cmpl   $0x80115cd4,-0xc(%ebp)
801047bf:	0f 82 5e ff ff ff    	jb     80104723 <wait+0x2d>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
801047c5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801047c9:	74 0a                	je     801047d5 <wait+0xdf>
801047cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047ce:	8b 40 24             	mov    0x24(%eax),%eax
801047d1:	85 c0                	test   %eax,%eax
801047d3:	74 13                	je     801047e8 <wait+0xf2>
      release(&ptable.lock);
801047d5:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
801047dc:	e8 45 06 00 00       	call   80104e26 <release>
      return -1;
801047e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047e6:	eb 18                	jmp    80104800 <wait+0x10a>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801047e8:	c7 44 24 04 a0 3d 11 	movl   $0x80113da0,0x4(%esp)
801047ef:	80 
801047f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047f3:	89 04 24             	mov    %eax,(%esp)
801047f6:	e8 d1 01 00 00       	call   801049cc <sleep>
  }
801047fb:	e9 10 ff ff ff       	jmp    80104710 <wait+0x1a>
}
80104800:	c9                   	leave  
80104801:	c3                   	ret    

80104802 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104802:	55                   	push   %ebp
80104803:	89 e5                	mov    %esp,%ebp
80104805:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104808:	e8 de f8 ff ff       	call   801040eb <mycpu>
8010480d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104810:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104813:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010481a:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
8010481d:	e8 86 f8 ff ff       	call   801040a8 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104822:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
80104829:	e8 90 05 00 00       	call   80104dbe <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010482e:	c7 45 f4 d4 3d 11 80 	movl   $0x80113dd4,-0xc(%ebp)
80104835:	eb 5c                	jmp    80104893 <scheduler+0x91>
      if(p->state != RUNNABLE)
80104837:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010483a:	8b 40 0c             	mov    0xc(%eax),%eax
8010483d:	83 f8 03             	cmp    $0x3,%eax
80104840:	74 02                	je     80104844 <scheduler+0x42>
        continue;
80104842:	eb 4b                	jmp    8010488f <scheduler+0x8d>

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104844:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104847:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010484a:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104850:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104853:	89 04 24             	mov    %eax,(%esp)
80104856:	e8 24 32 00 00       	call   80107a7f <switchuvm>
      p->state = RUNNING;
8010485b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010485e:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104865:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104868:	8b 40 1c             	mov    0x1c(%eax),%eax
8010486b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010486e:	83 c2 04             	add    $0x4,%edx
80104871:	89 44 24 04          	mov    %eax,0x4(%esp)
80104875:	89 14 24             	mov    %edx,(%esp)
80104878:	e8 44 0a 00 00       	call   801052c1 <swtch>
      switchkvm();
8010487d:	e8 e3 31 00 00       	call   80107a65 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104882:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104885:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010488c:	00 00 00 
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010488f:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104893:	81 7d f4 d4 5c 11 80 	cmpl   $0x80115cd4,-0xc(%ebp)
8010489a:	72 9b                	jb     80104837 <scheduler+0x35>
    }
    release(&ptable.lock);
8010489c:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
801048a3:	e8 7e 05 00 00       	call   80104e26 <release>

  }
801048a8:	e9 70 ff ff ff       	jmp    8010481d <scheduler+0x1b>

801048ad <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
801048ad:	55                   	push   %ebp
801048ae:	89 e5                	mov    %esp,%ebp
801048b0:	83 ec 28             	sub    $0x28,%esp
  int intena;
  struct proc *p = myproc();
801048b3:	e8 a9 f8 ff ff       	call   80104161 <myproc>
801048b8:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
801048bb:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
801048c2:	e8 23 06 00 00       	call   80104eea <holding>
801048c7:	85 c0                	test   %eax,%eax
801048c9:	75 0c                	jne    801048d7 <sched+0x2a>
    panic("sched ptable.lock");
801048cb:	c7 04 24 07 86 10 80 	movl   $0x80108607,(%esp)
801048d2:	e8 8b bc ff ff       	call   80100562 <panic>
  if(mycpu()->ncli != 1)
801048d7:	e8 0f f8 ff ff       	call   801040eb <mycpu>
801048dc:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801048e2:	83 f8 01             	cmp    $0x1,%eax
801048e5:	74 0c                	je     801048f3 <sched+0x46>
    panic("sched locks");
801048e7:	c7 04 24 19 86 10 80 	movl   $0x80108619,(%esp)
801048ee:	e8 6f bc ff ff       	call   80100562 <panic>
  if(p->state == RUNNING)
801048f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048f6:	8b 40 0c             	mov    0xc(%eax),%eax
801048f9:	83 f8 04             	cmp    $0x4,%eax
801048fc:	75 0c                	jne    8010490a <sched+0x5d>
    panic("sched running");
801048fe:	c7 04 24 25 86 10 80 	movl   $0x80108625,(%esp)
80104905:	e8 58 bc ff ff       	call   80100562 <panic>
  if(readeflags()&FL_IF)
8010490a:	e8 89 f7 ff ff       	call   80104098 <readeflags>
8010490f:	25 00 02 00 00       	and    $0x200,%eax
80104914:	85 c0                	test   %eax,%eax
80104916:	74 0c                	je     80104924 <sched+0x77>
    panic("sched interruptible");
80104918:	c7 04 24 33 86 10 80 	movl   $0x80108633,(%esp)
8010491f:	e8 3e bc ff ff       	call   80100562 <panic>
  intena = mycpu()->intena;
80104924:	e8 c2 f7 ff ff       	call   801040eb <mycpu>
80104929:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010492f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104932:	e8 b4 f7 ff ff       	call   801040eb <mycpu>
80104937:	8b 40 04             	mov    0x4(%eax),%eax
8010493a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010493d:	83 c2 1c             	add    $0x1c,%edx
80104940:	89 44 24 04          	mov    %eax,0x4(%esp)
80104944:	89 14 24             	mov    %edx,(%esp)
80104947:	e8 75 09 00 00       	call   801052c1 <swtch>
  mycpu()->intena = intena;
8010494c:	e8 9a f7 ff ff       	call   801040eb <mycpu>
80104951:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104954:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
8010495a:	c9                   	leave  
8010495b:	c3                   	ret    

8010495c <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
8010495c:	55                   	push   %ebp
8010495d:	89 e5                	mov    %esp,%ebp
8010495f:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104962:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
80104969:	e8 50 04 00 00       	call   80104dbe <acquire>
  myproc()->state = RUNNABLE;
8010496e:	e8 ee f7 ff ff       	call   80104161 <myproc>
80104973:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
8010497a:	e8 2e ff ff ff       	call   801048ad <sched>
  release(&ptable.lock);
8010497f:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
80104986:	e8 9b 04 00 00       	call   80104e26 <release>
}
8010498b:	c9                   	leave  
8010498c:	c3                   	ret    

8010498d <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
8010498d:	55                   	push   %ebp
8010498e:	89 e5                	mov    %esp,%ebp
80104990:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104993:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
8010499a:	e8 87 04 00 00       	call   80104e26 <release>

  if (first) {
8010499f:	a1 04 b0 10 80       	mov    0x8010b004,%eax
801049a4:	85 c0                	test   %eax,%eax
801049a6:	74 22                	je     801049ca <forkret+0x3d>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
801049a8:	c7 05 04 b0 10 80 00 	movl   $0x0,0x8010b004
801049af:	00 00 00 
    iinit(ROOTDEV);
801049b2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801049b9:	e8 32 cc ff ff       	call   801015f0 <iinit>
    initlog(ROOTDEV);
801049be:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801049c5:	e8 b9 e8 ff ff       	call   80103283 <initlog>
  }

  // Return to "caller", actually trapret (see allocproc).
}
801049ca:	c9                   	leave  
801049cb:	c3                   	ret    

801049cc <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801049cc:	55                   	push   %ebp
801049cd:	89 e5                	mov    %esp,%ebp
801049cf:	83 ec 28             	sub    $0x28,%esp
  struct proc *p = myproc();
801049d2:	e8 8a f7 ff ff       	call   80104161 <myproc>
801049d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
801049da:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801049de:	75 0c                	jne    801049ec <sleep+0x20>
    panic("sleep");
801049e0:	c7 04 24 47 86 10 80 	movl   $0x80108647,(%esp)
801049e7:	e8 76 bb ff ff       	call   80100562 <panic>

  if(lk == 0)
801049ec:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801049f0:	75 0c                	jne    801049fe <sleep+0x32>
    panic("sleep without lk");
801049f2:	c7 04 24 4d 86 10 80 	movl   $0x8010864d,(%esp)
801049f9:	e8 64 bb ff ff       	call   80100562 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801049fe:	81 7d 0c a0 3d 11 80 	cmpl   $0x80113da0,0xc(%ebp)
80104a05:	74 17                	je     80104a1e <sleep+0x52>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104a07:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
80104a0e:	e8 ab 03 00 00       	call   80104dbe <acquire>
    release(lk);
80104a13:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a16:	89 04 24             	mov    %eax,(%esp)
80104a19:	e8 08 04 00 00       	call   80104e26 <release>
  }
  // Go to sleep.
  p->chan = chan;
80104a1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a21:	8b 55 08             	mov    0x8(%ebp),%edx
80104a24:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104a27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a2a:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104a31:	e8 77 fe ff ff       	call   801048ad <sched>

  // Tidy up.
  p->chan = 0;
80104a36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a39:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104a40:	81 7d 0c a0 3d 11 80 	cmpl   $0x80113da0,0xc(%ebp)
80104a47:	74 17                	je     80104a60 <sleep+0x94>
    release(&ptable.lock);
80104a49:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
80104a50:	e8 d1 03 00 00       	call   80104e26 <release>
    acquire(lk);
80104a55:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a58:	89 04 24             	mov    %eax,(%esp)
80104a5b:	e8 5e 03 00 00       	call   80104dbe <acquire>
  }
}
80104a60:	c9                   	leave  
80104a61:	c3                   	ret    

80104a62 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104a62:	55                   	push   %ebp
80104a63:	89 e5                	mov    %esp,%ebp
80104a65:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104a68:	c7 45 fc d4 3d 11 80 	movl   $0x80113dd4,-0x4(%ebp)
80104a6f:	eb 24                	jmp    80104a95 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104a71:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a74:	8b 40 0c             	mov    0xc(%eax),%eax
80104a77:	83 f8 02             	cmp    $0x2,%eax
80104a7a:	75 15                	jne    80104a91 <wakeup1+0x2f>
80104a7c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a7f:	8b 40 20             	mov    0x20(%eax),%eax
80104a82:	3b 45 08             	cmp    0x8(%ebp),%eax
80104a85:	75 0a                	jne    80104a91 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104a87:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a8a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104a91:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
80104a95:	81 7d fc d4 5c 11 80 	cmpl   $0x80115cd4,-0x4(%ebp)
80104a9c:	72 d3                	jb     80104a71 <wakeup1+0xf>
}
80104a9e:	c9                   	leave  
80104a9f:	c3                   	ret    

80104aa0 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104aa0:	55                   	push   %ebp
80104aa1:	89 e5                	mov    %esp,%ebp
80104aa3:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104aa6:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
80104aad:	e8 0c 03 00 00       	call   80104dbe <acquire>
  wakeup1(chan);
80104ab2:	8b 45 08             	mov    0x8(%ebp),%eax
80104ab5:	89 04 24             	mov    %eax,(%esp)
80104ab8:	e8 a5 ff ff ff       	call   80104a62 <wakeup1>
  release(&ptable.lock);
80104abd:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
80104ac4:	e8 5d 03 00 00       	call   80104e26 <release>
}
80104ac9:	c9                   	leave  
80104aca:	c3                   	ret    

80104acb <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104acb:	55                   	push   %ebp
80104acc:	89 e5                	mov    %esp,%ebp
80104ace:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104ad1:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
80104ad8:	e8 e1 02 00 00       	call   80104dbe <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104add:	c7 45 f4 d4 3d 11 80 	movl   $0x80113dd4,-0xc(%ebp)
80104ae4:	eb 41                	jmp    80104b27 <kill+0x5c>
    if(p->pid == pid){
80104ae6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ae9:	8b 40 10             	mov    0x10(%eax),%eax
80104aec:	3b 45 08             	cmp    0x8(%ebp),%eax
80104aef:	75 32                	jne    80104b23 <kill+0x58>
      p->killed = 1;
80104af1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104af4:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104afb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104afe:	8b 40 0c             	mov    0xc(%eax),%eax
80104b01:	83 f8 02             	cmp    $0x2,%eax
80104b04:	75 0a                	jne    80104b10 <kill+0x45>
        p->state = RUNNABLE;
80104b06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b09:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104b10:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
80104b17:	e8 0a 03 00 00       	call   80104e26 <release>
      return 0;
80104b1c:	b8 00 00 00 00       	mov    $0x0,%eax
80104b21:	eb 1e                	jmp    80104b41 <kill+0x76>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b23:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104b27:	81 7d f4 d4 5c 11 80 	cmpl   $0x80115cd4,-0xc(%ebp)
80104b2e:	72 b6                	jb     80104ae6 <kill+0x1b>
    }
  }
  release(&ptable.lock);
80104b30:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
80104b37:	e8 ea 02 00 00       	call   80104e26 <release>
  return -1;
80104b3c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104b41:	c9                   	leave  
80104b42:	c3                   	ret    

80104b43 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104b43:	55                   	push   %ebp
80104b44:	89 e5                	mov    %esp,%ebp
80104b46:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b49:	c7 45 f0 d4 3d 11 80 	movl   $0x80113dd4,-0x10(%ebp)
80104b50:	e9 d6 00 00 00       	jmp    80104c2b <procdump+0xe8>
    if(p->state == UNUSED)
80104b55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b58:	8b 40 0c             	mov    0xc(%eax),%eax
80104b5b:	85 c0                	test   %eax,%eax
80104b5d:	75 05                	jne    80104b64 <procdump+0x21>
      continue;
80104b5f:	e9 c3 00 00 00       	jmp    80104c27 <procdump+0xe4>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104b64:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b67:	8b 40 0c             	mov    0xc(%eax),%eax
80104b6a:	83 f8 05             	cmp    $0x5,%eax
80104b6d:	77 23                	ja     80104b92 <procdump+0x4f>
80104b6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b72:	8b 40 0c             	mov    0xc(%eax),%eax
80104b75:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104b7c:	85 c0                	test   %eax,%eax
80104b7e:	74 12                	je     80104b92 <procdump+0x4f>
      state = states[p->state];
80104b80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b83:	8b 40 0c             	mov    0xc(%eax),%eax
80104b86:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104b8d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104b90:	eb 07                	jmp    80104b99 <procdump+0x56>
    else
      state = "???";
80104b92:	c7 45 ec 5e 86 10 80 	movl   $0x8010865e,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104b99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b9c:	8d 50 6c             	lea    0x6c(%eax),%edx
80104b9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ba2:	8b 40 10             	mov    0x10(%eax),%eax
80104ba5:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104ba9:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104bac:	89 54 24 08          	mov    %edx,0x8(%esp)
80104bb0:	89 44 24 04          	mov    %eax,0x4(%esp)
80104bb4:	c7 04 24 62 86 10 80 	movl   $0x80108662,(%esp)
80104bbb:	e8 08 b8 ff ff       	call   801003c8 <cprintf>
    if(p->state == SLEEPING){
80104bc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104bc3:	8b 40 0c             	mov    0xc(%eax),%eax
80104bc6:	83 f8 02             	cmp    $0x2,%eax
80104bc9:	75 50                	jne    80104c1b <procdump+0xd8>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104bcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104bce:	8b 40 1c             	mov    0x1c(%eax),%eax
80104bd1:	8b 40 0c             	mov    0xc(%eax),%eax
80104bd4:	83 c0 08             	add    $0x8,%eax
80104bd7:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80104bda:	89 54 24 04          	mov    %edx,0x4(%esp)
80104bde:	89 04 24             	mov    %eax,(%esp)
80104be1:	e8 8b 02 00 00       	call   80104e71 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104be6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104bed:	eb 1b                	jmp    80104c0a <procdump+0xc7>
        cprintf(" %p", pc[i]);
80104bef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bf2:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104bf6:	89 44 24 04          	mov    %eax,0x4(%esp)
80104bfa:	c7 04 24 6b 86 10 80 	movl   $0x8010866b,(%esp)
80104c01:	e8 c2 b7 ff ff       	call   801003c8 <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
80104c06:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104c0a:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104c0e:	7f 0b                	jg     80104c1b <procdump+0xd8>
80104c10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c13:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104c17:	85 c0                	test   %eax,%eax
80104c19:	75 d4                	jne    80104bef <procdump+0xac>
    }
    cprintf("\n");
80104c1b:	c7 04 24 6f 86 10 80 	movl   $0x8010866f,(%esp)
80104c22:	e8 a1 b7 ff ff       	call   801003c8 <cprintf>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c27:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
80104c2b:	81 7d f0 d4 5c 11 80 	cmpl   $0x80115cd4,-0x10(%ebp)
80104c32:	0f 82 1d ff ff ff    	jb     80104b55 <procdump+0x12>
  }
}
80104c38:	c9                   	leave  
80104c39:	c3                   	ret    

80104c3a <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104c3a:	55                   	push   %ebp
80104c3b:	89 e5                	mov    %esp,%ebp
80104c3d:	83 ec 18             	sub    $0x18,%esp
  initlock(&lk->lk, "sleep lock");
80104c40:	8b 45 08             	mov    0x8(%ebp),%eax
80104c43:	83 c0 04             	add    $0x4,%eax
80104c46:	c7 44 24 04 9b 86 10 	movl   $0x8010869b,0x4(%esp)
80104c4d:	80 
80104c4e:	89 04 24             	mov    %eax,(%esp)
80104c51:	e8 47 01 00 00       	call   80104d9d <initlock>
  lk->name = name;
80104c56:	8b 45 08             	mov    0x8(%ebp),%eax
80104c59:	8b 55 0c             	mov    0xc(%ebp),%edx
80104c5c:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104c5f:	8b 45 08             	mov    0x8(%ebp),%eax
80104c62:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104c68:	8b 45 08             	mov    0x8(%ebp),%eax
80104c6b:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104c72:	c9                   	leave  
80104c73:	c3                   	ret    

80104c74 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104c74:	55                   	push   %ebp
80104c75:	89 e5                	mov    %esp,%ebp
80104c77:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
80104c7a:	8b 45 08             	mov    0x8(%ebp),%eax
80104c7d:	83 c0 04             	add    $0x4,%eax
80104c80:	89 04 24             	mov    %eax,(%esp)
80104c83:	e8 36 01 00 00       	call   80104dbe <acquire>
  while (lk->locked) {
80104c88:	eb 15                	jmp    80104c9f <acquiresleep+0x2b>
    sleep(lk, &lk->lk);
80104c8a:	8b 45 08             	mov    0x8(%ebp),%eax
80104c8d:	83 c0 04             	add    $0x4,%eax
80104c90:	89 44 24 04          	mov    %eax,0x4(%esp)
80104c94:	8b 45 08             	mov    0x8(%ebp),%eax
80104c97:	89 04 24             	mov    %eax,(%esp)
80104c9a:	e8 2d fd ff ff       	call   801049cc <sleep>
  while (lk->locked) {
80104c9f:	8b 45 08             	mov    0x8(%ebp),%eax
80104ca2:	8b 00                	mov    (%eax),%eax
80104ca4:	85 c0                	test   %eax,%eax
80104ca6:	75 e2                	jne    80104c8a <acquiresleep+0x16>
  }
  lk->locked = 1;
80104ca8:	8b 45 08             	mov    0x8(%ebp),%eax
80104cab:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104cb1:	e8 ab f4 ff ff       	call   80104161 <myproc>
80104cb6:	8b 50 10             	mov    0x10(%eax),%edx
80104cb9:	8b 45 08             	mov    0x8(%ebp),%eax
80104cbc:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104cbf:	8b 45 08             	mov    0x8(%ebp),%eax
80104cc2:	83 c0 04             	add    $0x4,%eax
80104cc5:	89 04 24             	mov    %eax,(%esp)
80104cc8:	e8 59 01 00 00       	call   80104e26 <release>
}
80104ccd:	c9                   	leave  
80104cce:	c3                   	ret    

80104ccf <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104ccf:	55                   	push   %ebp
80104cd0:	89 e5                	mov    %esp,%ebp
80104cd2:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
80104cd5:	8b 45 08             	mov    0x8(%ebp),%eax
80104cd8:	83 c0 04             	add    $0x4,%eax
80104cdb:	89 04 24             	mov    %eax,(%esp)
80104cde:	e8 db 00 00 00       	call   80104dbe <acquire>
  lk->locked = 0;
80104ce3:	8b 45 08             	mov    0x8(%ebp),%eax
80104ce6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104cec:	8b 45 08             	mov    0x8(%ebp),%eax
80104cef:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104cf6:	8b 45 08             	mov    0x8(%ebp),%eax
80104cf9:	89 04 24             	mov    %eax,(%esp)
80104cfc:	e8 9f fd ff ff       	call   80104aa0 <wakeup>
  release(&lk->lk);
80104d01:	8b 45 08             	mov    0x8(%ebp),%eax
80104d04:	83 c0 04             	add    $0x4,%eax
80104d07:	89 04 24             	mov    %eax,(%esp)
80104d0a:	e8 17 01 00 00       	call   80104e26 <release>
}
80104d0f:	c9                   	leave  
80104d10:	c3                   	ret    

80104d11 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104d11:	55                   	push   %ebp
80104d12:	89 e5                	mov    %esp,%ebp
80104d14:	53                   	push   %ebx
80104d15:	83 ec 24             	sub    $0x24,%esp
  int r;
  
  acquire(&lk->lk);
80104d18:	8b 45 08             	mov    0x8(%ebp),%eax
80104d1b:	83 c0 04             	add    $0x4,%eax
80104d1e:	89 04 24             	mov    %eax,(%esp)
80104d21:	e8 98 00 00 00       	call   80104dbe <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
80104d26:	8b 45 08             	mov    0x8(%ebp),%eax
80104d29:	8b 00                	mov    (%eax),%eax
80104d2b:	85 c0                	test   %eax,%eax
80104d2d:	74 19                	je     80104d48 <holdingsleep+0x37>
80104d2f:	8b 45 08             	mov    0x8(%ebp),%eax
80104d32:	8b 58 3c             	mov    0x3c(%eax),%ebx
80104d35:	e8 27 f4 ff ff       	call   80104161 <myproc>
80104d3a:	8b 40 10             	mov    0x10(%eax),%eax
80104d3d:	39 c3                	cmp    %eax,%ebx
80104d3f:	75 07                	jne    80104d48 <holdingsleep+0x37>
80104d41:	b8 01 00 00 00       	mov    $0x1,%eax
80104d46:	eb 05                	jmp    80104d4d <holdingsleep+0x3c>
80104d48:	b8 00 00 00 00       	mov    $0x0,%eax
80104d4d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104d50:	8b 45 08             	mov    0x8(%ebp),%eax
80104d53:	83 c0 04             	add    $0x4,%eax
80104d56:	89 04 24             	mov    %eax,(%esp)
80104d59:	e8 c8 00 00 00       	call   80104e26 <release>
  return r;
80104d5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104d61:	83 c4 24             	add    $0x24,%esp
80104d64:	5b                   	pop    %ebx
80104d65:	5d                   	pop    %ebp
80104d66:	c3                   	ret    

80104d67 <readeflags>:
{
80104d67:	55                   	push   %ebp
80104d68:	89 e5                	mov    %esp,%ebp
80104d6a:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104d6d:	9c                   	pushf  
80104d6e:	58                   	pop    %eax
80104d6f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104d72:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104d75:	c9                   	leave  
80104d76:	c3                   	ret    

80104d77 <cli>:
{
80104d77:	55                   	push   %ebp
80104d78:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104d7a:	fa                   	cli    
}
80104d7b:	5d                   	pop    %ebp
80104d7c:	c3                   	ret    

80104d7d <sti>:
{
80104d7d:	55                   	push   %ebp
80104d7e:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104d80:	fb                   	sti    
}
80104d81:	5d                   	pop    %ebp
80104d82:	c3                   	ret    

80104d83 <xchg>:
{
80104d83:	55                   	push   %ebp
80104d84:	89 e5                	mov    %esp,%ebp
80104d86:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80104d89:	8b 55 08             	mov    0x8(%ebp),%edx
80104d8c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d8f:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104d92:	f0 87 02             	lock xchg %eax,(%edx)
80104d95:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80104d98:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104d9b:	c9                   	leave  
80104d9c:	c3                   	ret    

80104d9d <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104d9d:	55                   	push   %ebp
80104d9e:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104da0:	8b 45 08             	mov    0x8(%ebp),%eax
80104da3:	8b 55 0c             	mov    0xc(%ebp),%edx
80104da6:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104da9:	8b 45 08             	mov    0x8(%ebp),%eax
80104dac:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104db2:	8b 45 08             	mov    0x8(%ebp),%eax
80104db5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104dbc:	5d                   	pop    %ebp
80104dbd:	c3                   	ret    

80104dbe <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104dbe:	55                   	push   %ebp
80104dbf:	89 e5                	mov    %esp,%ebp
80104dc1:	53                   	push   %ebx
80104dc2:	83 ec 14             	sub    $0x14,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104dc5:	e8 61 01 00 00       	call   80104f2b <pushcli>
  if(holding(lk))
80104dca:	8b 45 08             	mov    0x8(%ebp),%eax
80104dcd:	89 04 24             	mov    %eax,(%esp)
80104dd0:	e8 15 01 00 00       	call   80104eea <holding>
80104dd5:	85 c0                	test   %eax,%eax
80104dd7:	74 0c                	je     80104de5 <acquire+0x27>
    panic("acquire");
80104dd9:	c7 04 24 a6 86 10 80 	movl   $0x801086a6,(%esp)
80104de0:	e8 7d b7 ff ff       	call   80100562 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104de5:	90                   	nop
80104de6:	8b 45 08             	mov    0x8(%ebp),%eax
80104de9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80104df0:	00 
80104df1:	89 04 24             	mov    %eax,(%esp)
80104df4:	e8 8a ff ff ff       	call   80104d83 <xchg>
80104df9:	85 c0                	test   %eax,%eax
80104dfb:	75 e9                	jne    80104de6 <acquire+0x28>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104dfd:	0f ae f0             	mfence 

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104e00:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104e03:	e8 e3 f2 ff ff       	call   801040eb <mycpu>
80104e08:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104e0b:	8b 45 08             	mov    0x8(%ebp),%eax
80104e0e:	83 c0 0c             	add    $0xc,%eax
80104e11:	89 44 24 04          	mov    %eax,0x4(%esp)
80104e15:	8d 45 08             	lea    0x8(%ebp),%eax
80104e18:	89 04 24             	mov    %eax,(%esp)
80104e1b:	e8 51 00 00 00       	call   80104e71 <getcallerpcs>
}
80104e20:	83 c4 14             	add    $0x14,%esp
80104e23:	5b                   	pop    %ebx
80104e24:	5d                   	pop    %ebp
80104e25:	c3                   	ret    

80104e26 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104e26:	55                   	push   %ebp
80104e27:	89 e5                	mov    %esp,%ebp
80104e29:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80104e2c:	8b 45 08             	mov    0x8(%ebp),%eax
80104e2f:	89 04 24             	mov    %eax,(%esp)
80104e32:	e8 b3 00 00 00       	call   80104eea <holding>
80104e37:	85 c0                	test   %eax,%eax
80104e39:	75 0c                	jne    80104e47 <release+0x21>
    panic("release");
80104e3b:	c7 04 24 ae 86 10 80 	movl   $0x801086ae,(%esp)
80104e42:	e8 1b b7 ff ff       	call   80100562 <panic>

  lk->pcs[0] = 0;
80104e47:	8b 45 08             	mov    0x8(%ebp),%eax
80104e4a:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104e51:	8b 45 08             	mov    0x8(%ebp),%eax
80104e54:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104e5b:	0f ae f0             	mfence 

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104e5e:	8b 45 08             	mov    0x8(%ebp),%eax
80104e61:	8b 55 08             	mov    0x8(%ebp),%edx
80104e64:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104e6a:	e8 08 01 00 00       	call   80104f77 <popcli>
}
80104e6f:	c9                   	leave  
80104e70:	c3                   	ret    

80104e71 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104e71:	55                   	push   %ebp
80104e72:	89 e5                	mov    %esp,%ebp
80104e74:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104e77:	8b 45 08             	mov    0x8(%ebp),%eax
80104e7a:	83 e8 08             	sub    $0x8,%eax
80104e7d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104e80:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104e87:	eb 38                	jmp    80104ec1 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104e89:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104e8d:	74 38                	je     80104ec7 <getcallerpcs+0x56>
80104e8f:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104e96:	76 2f                	jbe    80104ec7 <getcallerpcs+0x56>
80104e98:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104e9c:	74 29                	je     80104ec7 <getcallerpcs+0x56>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104e9e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ea1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104ea8:	8b 45 0c             	mov    0xc(%ebp),%eax
80104eab:	01 c2                	add    %eax,%edx
80104ead:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104eb0:	8b 40 04             	mov    0x4(%eax),%eax
80104eb3:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104eb5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104eb8:	8b 00                	mov    (%eax),%eax
80104eba:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104ebd:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104ec1:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104ec5:	7e c2                	jle    80104e89 <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
80104ec7:	eb 19                	jmp    80104ee2 <getcallerpcs+0x71>
    pcs[i] = 0;
80104ec9:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ecc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104ed3:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ed6:	01 d0                	add    %edx,%eax
80104ed8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104ede:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104ee2:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104ee6:	7e e1                	jle    80104ec9 <getcallerpcs+0x58>
}
80104ee8:	c9                   	leave  
80104ee9:	c3                   	ret    

80104eea <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104eea:	55                   	push   %ebp
80104eeb:	89 e5                	mov    %esp,%ebp
80104eed:	53                   	push   %ebx
80104eee:	83 ec 14             	sub    $0x14,%esp
  int r;
  pushcli();
80104ef1:	e8 35 00 00 00       	call   80104f2b <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80104ef6:	8b 45 08             	mov    0x8(%ebp),%eax
80104ef9:	8b 00                	mov    (%eax),%eax
80104efb:	85 c0                	test   %eax,%eax
80104efd:	74 16                	je     80104f15 <holding+0x2b>
80104eff:	8b 45 08             	mov    0x8(%ebp),%eax
80104f02:	8b 58 08             	mov    0x8(%eax),%ebx
80104f05:	e8 e1 f1 ff ff       	call   801040eb <mycpu>
80104f0a:	39 c3                	cmp    %eax,%ebx
80104f0c:	75 07                	jne    80104f15 <holding+0x2b>
80104f0e:	b8 01 00 00 00       	mov    $0x1,%eax
80104f13:	eb 05                	jmp    80104f1a <holding+0x30>
80104f15:	b8 00 00 00 00       	mov    $0x0,%eax
80104f1a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  popcli();
80104f1d:	e8 55 00 00 00       	call   80104f77 <popcli>
  return r;
80104f22:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104f25:	83 c4 14             	add    $0x14,%esp
80104f28:	5b                   	pop    %ebx
80104f29:	5d                   	pop    %ebp
80104f2a:	c3                   	ret    

80104f2b <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104f2b:	55                   	push   %ebp
80104f2c:	89 e5                	mov    %esp,%ebp
80104f2e:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104f31:	e8 31 fe ff ff       	call   80104d67 <readeflags>
80104f36:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104f39:	e8 39 fe ff ff       	call   80104d77 <cli>
  if(mycpu()->ncli == 0)
80104f3e:	e8 a8 f1 ff ff       	call   801040eb <mycpu>
80104f43:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104f49:	85 c0                	test   %eax,%eax
80104f4b:	75 14                	jne    80104f61 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80104f4d:	e8 99 f1 ff ff       	call   801040eb <mycpu>
80104f52:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f55:	81 e2 00 02 00 00    	and    $0x200,%edx
80104f5b:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104f61:	e8 85 f1 ff ff       	call   801040eb <mycpu>
80104f66:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104f6c:	83 c2 01             	add    $0x1,%edx
80104f6f:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104f75:	c9                   	leave  
80104f76:	c3                   	ret    

80104f77 <popcli>:

void
popcli(void)
{
80104f77:	55                   	push   %ebp
80104f78:	89 e5                	mov    %esp,%ebp
80104f7a:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
80104f7d:	e8 e5 fd ff ff       	call   80104d67 <readeflags>
80104f82:	25 00 02 00 00       	and    $0x200,%eax
80104f87:	85 c0                	test   %eax,%eax
80104f89:	74 0c                	je     80104f97 <popcli+0x20>
    panic("popcli - interruptible");
80104f8b:	c7 04 24 b6 86 10 80 	movl   $0x801086b6,(%esp)
80104f92:	e8 cb b5 ff ff       	call   80100562 <panic>
  if(--mycpu()->ncli < 0)
80104f97:	e8 4f f1 ff ff       	call   801040eb <mycpu>
80104f9c:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104fa2:	83 ea 01             	sub    $0x1,%edx
80104fa5:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104fab:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104fb1:	85 c0                	test   %eax,%eax
80104fb3:	79 0c                	jns    80104fc1 <popcli+0x4a>
    panic("popcli");
80104fb5:	c7 04 24 cd 86 10 80 	movl   $0x801086cd,(%esp)
80104fbc:	e8 a1 b5 ff ff       	call   80100562 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104fc1:	e8 25 f1 ff ff       	call   801040eb <mycpu>
80104fc6:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104fcc:	85 c0                	test   %eax,%eax
80104fce:	75 14                	jne    80104fe4 <popcli+0x6d>
80104fd0:	e8 16 f1 ff ff       	call   801040eb <mycpu>
80104fd5:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104fdb:	85 c0                	test   %eax,%eax
80104fdd:	74 05                	je     80104fe4 <popcli+0x6d>
    sti();
80104fdf:	e8 99 fd ff ff       	call   80104d7d <sti>
}
80104fe4:	c9                   	leave  
80104fe5:	c3                   	ret    

80104fe6 <stosb>:
{
80104fe6:	55                   	push   %ebp
80104fe7:	89 e5                	mov    %esp,%ebp
80104fe9:	57                   	push   %edi
80104fea:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104feb:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104fee:	8b 55 10             	mov    0x10(%ebp),%edx
80104ff1:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ff4:	89 cb                	mov    %ecx,%ebx
80104ff6:	89 df                	mov    %ebx,%edi
80104ff8:	89 d1                	mov    %edx,%ecx
80104ffa:	fc                   	cld    
80104ffb:	f3 aa                	rep stos %al,%es:(%edi)
80104ffd:	89 ca                	mov    %ecx,%edx
80104fff:	89 fb                	mov    %edi,%ebx
80105001:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105004:	89 55 10             	mov    %edx,0x10(%ebp)
}
80105007:	5b                   	pop    %ebx
80105008:	5f                   	pop    %edi
80105009:	5d                   	pop    %ebp
8010500a:	c3                   	ret    

8010500b <stosl>:
{
8010500b:	55                   	push   %ebp
8010500c:	89 e5                	mov    %esp,%ebp
8010500e:	57                   	push   %edi
8010500f:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105010:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105013:	8b 55 10             	mov    0x10(%ebp),%edx
80105016:	8b 45 0c             	mov    0xc(%ebp),%eax
80105019:	89 cb                	mov    %ecx,%ebx
8010501b:	89 df                	mov    %ebx,%edi
8010501d:	89 d1                	mov    %edx,%ecx
8010501f:	fc                   	cld    
80105020:	f3 ab                	rep stos %eax,%es:(%edi)
80105022:	89 ca                	mov    %ecx,%edx
80105024:	89 fb                	mov    %edi,%ebx
80105026:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105029:	89 55 10             	mov    %edx,0x10(%ebp)
}
8010502c:	5b                   	pop    %ebx
8010502d:	5f                   	pop    %edi
8010502e:	5d                   	pop    %ebp
8010502f:	c3                   	ret    

80105030 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105030:	55                   	push   %ebp
80105031:	89 e5                	mov    %esp,%ebp
80105033:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
80105036:	8b 45 08             	mov    0x8(%ebp),%eax
80105039:	83 e0 03             	and    $0x3,%eax
8010503c:	85 c0                	test   %eax,%eax
8010503e:	75 49                	jne    80105089 <memset+0x59>
80105040:	8b 45 10             	mov    0x10(%ebp),%eax
80105043:	83 e0 03             	and    $0x3,%eax
80105046:	85 c0                	test   %eax,%eax
80105048:	75 3f                	jne    80105089 <memset+0x59>
    c &= 0xFF;
8010504a:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105051:	8b 45 10             	mov    0x10(%ebp),%eax
80105054:	c1 e8 02             	shr    $0x2,%eax
80105057:	89 c2                	mov    %eax,%edx
80105059:	8b 45 0c             	mov    0xc(%ebp),%eax
8010505c:	c1 e0 18             	shl    $0x18,%eax
8010505f:	89 c1                	mov    %eax,%ecx
80105061:	8b 45 0c             	mov    0xc(%ebp),%eax
80105064:	c1 e0 10             	shl    $0x10,%eax
80105067:	09 c1                	or     %eax,%ecx
80105069:	8b 45 0c             	mov    0xc(%ebp),%eax
8010506c:	c1 e0 08             	shl    $0x8,%eax
8010506f:	09 c8                	or     %ecx,%eax
80105071:	0b 45 0c             	or     0xc(%ebp),%eax
80105074:	89 54 24 08          	mov    %edx,0x8(%esp)
80105078:	89 44 24 04          	mov    %eax,0x4(%esp)
8010507c:	8b 45 08             	mov    0x8(%ebp),%eax
8010507f:	89 04 24             	mov    %eax,(%esp)
80105082:	e8 84 ff ff ff       	call   8010500b <stosl>
80105087:	eb 19                	jmp    801050a2 <memset+0x72>
  } else
    stosb(dst, c, n);
80105089:	8b 45 10             	mov    0x10(%ebp),%eax
8010508c:	89 44 24 08          	mov    %eax,0x8(%esp)
80105090:	8b 45 0c             	mov    0xc(%ebp),%eax
80105093:	89 44 24 04          	mov    %eax,0x4(%esp)
80105097:	8b 45 08             	mov    0x8(%ebp),%eax
8010509a:	89 04 24             	mov    %eax,(%esp)
8010509d:	e8 44 ff ff ff       	call   80104fe6 <stosb>
  return dst;
801050a2:	8b 45 08             	mov    0x8(%ebp),%eax
}
801050a5:	c9                   	leave  
801050a6:	c3                   	ret    

801050a7 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801050a7:	55                   	push   %ebp
801050a8:	89 e5                	mov    %esp,%ebp
801050aa:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
801050ad:	8b 45 08             	mov    0x8(%ebp),%eax
801050b0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801050b3:	8b 45 0c             	mov    0xc(%ebp),%eax
801050b6:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801050b9:	eb 30                	jmp    801050eb <memcmp+0x44>
    if(*s1 != *s2)
801050bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050be:	0f b6 10             	movzbl (%eax),%edx
801050c1:	8b 45 f8             	mov    -0x8(%ebp),%eax
801050c4:	0f b6 00             	movzbl (%eax),%eax
801050c7:	38 c2                	cmp    %al,%dl
801050c9:	74 18                	je     801050e3 <memcmp+0x3c>
      return *s1 - *s2;
801050cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050ce:	0f b6 00             	movzbl (%eax),%eax
801050d1:	0f b6 d0             	movzbl %al,%edx
801050d4:	8b 45 f8             	mov    -0x8(%ebp),%eax
801050d7:	0f b6 00             	movzbl (%eax),%eax
801050da:	0f b6 c0             	movzbl %al,%eax
801050dd:	29 c2                	sub    %eax,%edx
801050df:	89 d0                	mov    %edx,%eax
801050e1:	eb 1a                	jmp    801050fd <memcmp+0x56>
    s1++, s2++;
801050e3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801050e7:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
801050eb:	8b 45 10             	mov    0x10(%ebp),%eax
801050ee:	8d 50 ff             	lea    -0x1(%eax),%edx
801050f1:	89 55 10             	mov    %edx,0x10(%ebp)
801050f4:	85 c0                	test   %eax,%eax
801050f6:	75 c3                	jne    801050bb <memcmp+0x14>
  }

  return 0;
801050f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801050fd:	c9                   	leave  
801050fe:	c3                   	ret    

801050ff <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801050ff:	55                   	push   %ebp
80105100:	89 e5                	mov    %esp,%ebp
80105102:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105105:	8b 45 0c             	mov    0xc(%ebp),%eax
80105108:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
8010510b:	8b 45 08             	mov    0x8(%ebp),%eax
8010510e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105111:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105114:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105117:	73 3d                	jae    80105156 <memmove+0x57>
80105119:	8b 45 10             	mov    0x10(%ebp),%eax
8010511c:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010511f:	01 d0                	add    %edx,%eax
80105121:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105124:	76 30                	jbe    80105156 <memmove+0x57>
    s += n;
80105126:	8b 45 10             	mov    0x10(%ebp),%eax
80105129:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
8010512c:	8b 45 10             	mov    0x10(%ebp),%eax
8010512f:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105132:	eb 13                	jmp    80105147 <memmove+0x48>
      *--d = *--s;
80105134:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105138:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
8010513c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010513f:	0f b6 10             	movzbl (%eax),%edx
80105142:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105145:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80105147:	8b 45 10             	mov    0x10(%ebp),%eax
8010514a:	8d 50 ff             	lea    -0x1(%eax),%edx
8010514d:	89 55 10             	mov    %edx,0x10(%ebp)
80105150:	85 c0                	test   %eax,%eax
80105152:	75 e0                	jne    80105134 <memmove+0x35>
  if(s < d && s + n > d){
80105154:	eb 26                	jmp    8010517c <memmove+0x7d>
  } else
    while(n-- > 0)
80105156:	eb 17                	jmp    8010516f <memmove+0x70>
      *d++ = *s++;
80105158:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010515b:	8d 50 01             	lea    0x1(%eax),%edx
8010515e:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105161:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105164:	8d 4a 01             	lea    0x1(%edx),%ecx
80105167:	89 4d fc             	mov    %ecx,-0x4(%ebp)
8010516a:	0f b6 12             	movzbl (%edx),%edx
8010516d:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
8010516f:	8b 45 10             	mov    0x10(%ebp),%eax
80105172:	8d 50 ff             	lea    -0x1(%eax),%edx
80105175:	89 55 10             	mov    %edx,0x10(%ebp)
80105178:	85 c0                	test   %eax,%eax
8010517a:	75 dc                	jne    80105158 <memmove+0x59>

  return dst;
8010517c:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010517f:	c9                   	leave  
80105180:	c3                   	ret    

80105181 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105181:	55                   	push   %ebp
80105182:	89 e5                	mov    %esp,%ebp
80105184:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80105187:	8b 45 10             	mov    0x10(%ebp),%eax
8010518a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010518e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105191:	89 44 24 04          	mov    %eax,0x4(%esp)
80105195:	8b 45 08             	mov    0x8(%ebp),%eax
80105198:	89 04 24             	mov    %eax,(%esp)
8010519b:	e8 5f ff ff ff       	call   801050ff <memmove>
}
801051a0:	c9                   	leave  
801051a1:	c3                   	ret    

801051a2 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801051a2:	55                   	push   %ebp
801051a3:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801051a5:	eb 0c                	jmp    801051b3 <strncmp+0x11>
    n--, p++, q++;
801051a7:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801051ab:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801051af:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
801051b3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801051b7:	74 1a                	je     801051d3 <strncmp+0x31>
801051b9:	8b 45 08             	mov    0x8(%ebp),%eax
801051bc:	0f b6 00             	movzbl (%eax),%eax
801051bf:	84 c0                	test   %al,%al
801051c1:	74 10                	je     801051d3 <strncmp+0x31>
801051c3:	8b 45 08             	mov    0x8(%ebp),%eax
801051c6:	0f b6 10             	movzbl (%eax),%edx
801051c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801051cc:	0f b6 00             	movzbl (%eax),%eax
801051cf:	38 c2                	cmp    %al,%dl
801051d1:	74 d4                	je     801051a7 <strncmp+0x5>
  if(n == 0)
801051d3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801051d7:	75 07                	jne    801051e0 <strncmp+0x3e>
    return 0;
801051d9:	b8 00 00 00 00       	mov    $0x0,%eax
801051de:	eb 16                	jmp    801051f6 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
801051e0:	8b 45 08             	mov    0x8(%ebp),%eax
801051e3:	0f b6 00             	movzbl (%eax),%eax
801051e6:	0f b6 d0             	movzbl %al,%edx
801051e9:	8b 45 0c             	mov    0xc(%ebp),%eax
801051ec:	0f b6 00             	movzbl (%eax),%eax
801051ef:	0f b6 c0             	movzbl %al,%eax
801051f2:	29 c2                	sub    %eax,%edx
801051f4:	89 d0                	mov    %edx,%eax
}
801051f6:	5d                   	pop    %ebp
801051f7:	c3                   	ret    

801051f8 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801051f8:	55                   	push   %ebp
801051f9:	89 e5                	mov    %esp,%ebp
801051fb:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801051fe:	8b 45 08             	mov    0x8(%ebp),%eax
80105201:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105204:	90                   	nop
80105205:	8b 45 10             	mov    0x10(%ebp),%eax
80105208:	8d 50 ff             	lea    -0x1(%eax),%edx
8010520b:	89 55 10             	mov    %edx,0x10(%ebp)
8010520e:	85 c0                	test   %eax,%eax
80105210:	7e 1e                	jle    80105230 <strncpy+0x38>
80105212:	8b 45 08             	mov    0x8(%ebp),%eax
80105215:	8d 50 01             	lea    0x1(%eax),%edx
80105218:	89 55 08             	mov    %edx,0x8(%ebp)
8010521b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010521e:	8d 4a 01             	lea    0x1(%edx),%ecx
80105221:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105224:	0f b6 12             	movzbl (%edx),%edx
80105227:	88 10                	mov    %dl,(%eax)
80105229:	0f b6 00             	movzbl (%eax),%eax
8010522c:	84 c0                	test   %al,%al
8010522e:	75 d5                	jne    80105205 <strncpy+0xd>
    ;
  while(n-- > 0)
80105230:	eb 0c                	jmp    8010523e <strncpy+0x46>
    *s++ = 0;
80105232:	8b 45 08             	mov    0x8(%ebp),%eax
80105235:	8d 50 01             	lea    0x1(%eax),%edx
80105238:	89 55 08             	mov    %edx,0x8(%ebp)
8010523b:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
8010523e:	8b 45 10             	mov    0x10(%ebp),%eax
80105241:	8d 50 ff             	lea    -0x1(%eax),%edx
80105244:	89 55 10             	mov    %edx,0x10(%ebp)
80105247:	85 c0                	test   %eax,%eax
80105249:	7f e7                	jg     80105232 <strncpy+0x3a>
  return os;
8010524b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010524e:	c9                   	leave  
8010524f:	c3                   	ret    

80105250 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105250:	55                   	push   %ebp
80105251:	89 e5                	mov    %esp,%ebp
80105253:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105256:	8b 45 08             	mov    0x8(%ebp),%eax
80105259:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
8010525c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105260:	7f 05                	jg     80105267 <safestrcpy+0x17>
    return os;
80105262:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105265:	eb 31                	jmp    80105298 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
80105267:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010526b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010526f:	7e 1e                	jle    8010528f <safestrcpy+0x3f>
80105271:	8b 45 08             	mov    0x8(%ebp),%eax
80105274:	8d 50 01             	lea    0x1(%eax),%edx
80105277:	89 55 08             	mov    %edx,0x8(%ebp)
8010527a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010527d:	8d 4a 01             	lea    0x1(%edx),%ecx
80105280:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105283:	0f b6 12             	movzbl (%edx),%edx
80105286:	88 10                	mov    %dl,(%eax)
80105288:	0f b6 00             	movzbl (%eax),%eax
8010528b:	84 c0                	test   %al,%al
8010528d:	75 d8                	jne    80105267 <safestrcpy+0x17>
    ;
  *s = 0;
8010528f:	8b 45 08             	mov    0x8(%ebp),%eax
80105292:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105295:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105298:	c9                   	leave  
80105299:	c3                   	ret    

8010529a <strlen>:

int
strlen(const char *s)
{
8010529a:	55                   	push   %ebp
8010529b:	89 e5                	mov    %esp,%ebp
8010529d:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801052a0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801052a7:	eb 04                	jmp    801052ad <strlen+0x13>
801052a9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801052ad:	8b 55 fc             	mov    -0x4(%ebp),%edx
801052b0:	8b 45 08             	mov    0x8(%ebp),%eax
801052b3:	01 d0                	add    %edx,%eax
801052b5:	0f b6 00             	movzbl (%eax),%eax
801052b8:	84 c0                	test   %al,%al
801052ba:	75 ed                	jne    801052a9 <strlen+0xf>
    ;
  return n;
801052bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801052bf:	c9                   	leave  
801052c0:	c3                   	ret    

801052c1 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
801052c1:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801052c5:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
801052c9:	55                   	push   %ebp
  pushl %ebx
801052ca:	53                   	push   %ebx
  pushl %esi
801052cb:	56                   	push   %esi
  pushl %edi
801052cc:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801052cd:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801052cf:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
801052d1:	5f                   	pop    %edi
  popl %esi
801052d2:	5e                   	pop    %esi
  popl %ebx
801052d3:	5b                   	pop    %ebx
  popl %ebp
801052d4:	5d                   	pop    %ebp
  ret
801052d5:	c3                   	ret    

801052d6 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801052d6:	55                   	push   %ebp
801052d7:	89 e5                	mov    %esp,%ebp
801052d9:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
801052dc:	e8 80 ee ff ff       	call   80104161 <myproc>
801052e1:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
801052e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052e7:	8b 00                	mov    (%eax),%eax
801052e9:	3b 45 08             	cmp    0x8(%ebp),%eax
801052ec:	76 0f                	jbe    801052fd <fetchint+0x27>
801052ee:	8b 45 08             	mov    0x8(%ebp),%eax
801052f1:	8d 50 04             	lea    0x4(%eax),%edx
801052f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052f7:	8b 00                	mov    (%eax),%eax
801052f9:	39 c2                	cmp    %eax,%edx
801052fb:	76 07                	jbe    80105304 <fetchint+0x2e>
    return -1;
801052fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105302:	eb 0f                	jmp    80105313 <fetchint+0x3d>
  *ip = *(int*)(addr);
80105304:	8b 45 08             	mov    0x8(%ebp),%eax
80105307:	8b 10                	mov    (%eax),%edx
80105309:	8b 45 0c             	mov    0xc(%ebp),%eax
8010530c:	89 10                	mov    %edx,(%eax)
  return 0;
8010530e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105313:	c9                   	leave  
80105314:	c3                   	ret    

80105315 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105315:	55                   	push   %ebp
80105316:	89 e5                	mov    %esp,%ebp
80105318:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
8010531b:	e8 41 ee ff ff       	call   80104161 <myproc>
80105320:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80105323:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105326:	8b 00                	mov    (%eax),%eax
80105328:	3b 45 08             	cmp    0x8(%ebp),%eax
8010532b:	77 07                	ja     80105334 <fetchstr+0x1f>
    return -1;
8010532d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105332:	eb 43                	jmp    80105377 <fetchstr+0x62>
  *pp = (char*)addr;
80105334:	8b 55 08             	mov    0x8(%ebp),%edx
80105337:	8b 45 0c             	mov    0xc(%ebp),%eax
8010533a:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
8010533c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010533f:	8b 00                	mov    (%eax),%eax
80105341:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80105344:	8b 45 0c             	mov    0xc(%ebp),%eax
80105347:	8b 00                	mov    (%eax),%eax
80105349:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010534c:	eb 1c                	jmp    8010536a <fetchstr+0x55>
    if(*s == 0)
8010534e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105351:	0f b6 00             	movzbl (%eax),%eax
80105354:	84 c0                	test   %al,%al
80105356:	75 0e                	jne    80105366 <fetchstr+0x51>
      return s - *pp;
80105358:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010535b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010535e:	8b 00                	mov    (%eax),%eax
80105360:	29 c2                	sub    %eax,%edx
80105362:	89 d0                	mov    %edx,%eax
80105364:	eb 11                	jmp    80105377 <fetchstr+0x62>
  for(s = *pp; s < ep; s++){
80105366:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010536a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010536d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105370:	72 dc                	jb     8010534e <fetchstr+0x39>
  }
  return -1;
80105372:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105377:	c9                   	leave  
80105378:	c3                   	ret    

80105379 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105379:	55                   	push   %ebp
8010537a:	89 e5                	mov    %esp,%ebp
8010537c:	83 ec 18             	sub    $0x18,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
8010537f:	e8 dd ed ff ff       	call   80104161 <myproc>
80105384:	8b 40 18             	mov    0x18(%eax),%eax
80105387:	8b 50 44             	mov    0x44(%eax),%edx
8010538a:	8b 45 08             	mov    0x8(%ebp),%eax
8010538d:	c1 e0 02             	shl    $0x2,%eax
80105390:	01 d0                	add    %edx,%eax
80105392:	8d 50 04             	lea    0x4(%eax),%edx
80105395:	8b 45 0c             	mov    0xc(%ebp),%eax
80105398:	89 44 24 04          	mov    %eax,0x4(%esp)
8010539c:	89 14 24             	mov    %edx,(%esp)
8010539f:	e8 32 ff ff ff       	call   801052d6 <fetchint>
}
801053a4:	c9                   	leave  
801053a5:	c3                   	ret    

801053a6 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801053a6:	55                   	push   %ebp
801053a7:	89 e5                	mov    %esp,%ebp
801053a9:	83 ec 28             	sub    $0x28,%esp
  int i;
  struct proc *curproc = myproc();
801053ac:	e8 b0 ed ff ff       	call   80104161 <myproc>
801053b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
801053b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801053b7:	89 44 24 04          	mov    %eax,0x4(%esp)
801053bb:	8b 45 08             	mov    0x8(%ebp),%eax
801053be:	89 04 24             	mov    %eax,(%esp)
801053c1:	e8 b3 ff ff ff       	call   80105379 <argint>
801053c6:	85 c0                	test   %eax,%eax
801053c8:	79 07                	jns    801053d1 <argptr+0x2b>
    return -1;
801053ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053cf:	eb 3d                	jmp    8010540e <argptr+0x68>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
801053d1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801053d5:	78 21                	js     801053f8 <argptr+0x52>
801053d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053da:	89 c2                	mov    %eax,%edx
801053dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053df:	8b 00                	mov    (%eax),%eax
801053e1:	39 c2                	cmp    %eax,%edx
801053e3:	73 13                	jae    801053f8 <argptr+0x52>
801053e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053e8:	89 c2                	mov    %eax,%edx
801053ea:	8b 45 10             	mov    0x10(%ebp),%eax
801053ed:	01 c2                	add    %eax,%edx
801053ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053f2:	8b 00                	mov    (%eax),%eax
801053f4:	39 c2                	cmp    %eax,%edx
801053f6:	76 07                	jbe    801053ff <argptr+0x59>
    return -1;
801053f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053fd:	eb 0f                	jmp    8010540e <argptr+0x68>
  *pp = (char*)i;
801053ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105402:	89 c2                	mov    %eax,%edx
80105404:	8b 45 0c             	mov    0xc(%ebp),%eax
80105407:	89 10                	mov    %edx,(%eax)
  return 0;
80105409:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010540e:	c9                   	leave  
8010540f:	c3                   	ret    

80105410 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105410:	55                   	push   %ebp
80105411:	89 e5                	mov    %esp,%ebp
80105413:	83 ec 28             	sub    $0x28,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105416:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105419:	89 44 24 04          	mov    %eax,0x4(%esp)
8010541d:	8b 45 08             	mov    0x8(%ebp),%eax
80105420:	89 04 24             	mov    %eax,(%esp)
80105423:	e8 51 ff ff ff       	call   80105379 <argint>
80105428:	85 c0                	test   %eax,%eax
8010542a:	79 07                	jns    80105433 <argstr+0x23>
    return -1;
8010542c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105431:	eb 12                	jmp    80105445 <argstr+0x35>
  return fetchstr(addr, pp);
80105433:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105436:	8b 55 0c             	mov    0xc(%ebp),%edx
80105439:	89 54 24 04          	mov    %edx,0x4(%esp)
8010543d:	89 04 24             	mov    %eax,(%esp)
80105440:	e8 d0 fe ff ff       	call   80105315 <fetchstr>
}
80105445:	c9                   	leave  
80105446:	c3                   	ret    

80105447 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
80105447:	55                   	push   %ebp
80105448:	89 e5                	mov    %esp,%ebp
8010544a:	53                   	push   %ebx
8010544b:	83 ec 24             	sub    $0x24,%esp
  int num;
  struct proc *curproc = myproc();
8010544e:	e8 0e ed ff ff       	call   80104161 <myproc>
80105453:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80105456:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105459:	8b 40 18             	mov    0x18(%eax),%eax
8010545c:	8b 40 1c             	mov    0x1c(%eax),%eax
8010545f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105462:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105466:	7e 2d                	jle    80105495 <syscall+0x4e>
80105468:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010546b:	83 f8 17             	cmp    $0x17,%eax
8010546e:	77 25                	ja     80105495 <syscall+0x4e>
80105470:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105473:	8b 04 85 20 b0 10 80 	mov    -0x7fef4fe0(,%eax,4),%eax
8010547a:	85 c0                	test   %eax,%eax
8010547c:	74 17                	je     80105495 <syscall+0x4e>
    curproc->tf->eax = syscalls[num]();
8010547e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105481:	8b 58 18             	mov    0x18(%eax),%ebx
80105484:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105487:	8b 04 85 20 b0 10 80 	mov    -0x7fef4fe0(,%eax,4),%eax
8010548e:	ff d0                	call   *%eax
80105490:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105493:	eb 34                	jmp    801054c9 <syscall+0x82>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105495:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105498:	8d 48 6c             	lea    0x6c(%eax),%ecx
    cprintf("%d %s: unknown sys call %d\n",
8010549b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010549e:	8b 40 10             	mov    0x10(%eax),%eax
801054a1:	8b 55 f0             	mov    -0x10(%ebp),%edx
801054a4:	89 54 24 0c          	mov    %edx,0xc(%esp)
801054a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801054ac:	89 44 24 04          	mov    %eax,0x4(%esp)
801054b0:	c7 04 24 d4 86 10 80 	movl   $0x801086d4,(%esp)
801054b7:	e8 0c af ff ff       	call   801003c8 <cprintf>
    curproc->tf->eax = -1;
801054bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054bf:	8b 40 18             	mov    0x18(%eax),%eax
801054c2:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801054c9:	83 c4 24             	add    $0x24,%esp
801054cc:	5b                   	pop    %ebx
801054cd:	5d                   	pop    %ebp
801054ce:	c3                   	ret    

801054cf <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801054cf:	55                   	push   %ebp
801054d0:	89 e5                	mov    %esp,%ebp
801054d2:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801054d5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801054d8:	89 44 24 04          	mov    %eax,0x4(%esp)
801054dc:	8b 45 08             	mov    0x8(%ebp),%eax
801054df:	89 04 24             	mov    %eax,(%esp)
801054e2:	e8 92 fe ff ff       	call   80105379 <argint>
801054e7:	85 c0                	test   %eax,%eax
801054e9:	79 07                	jns    801054f2 <argfd+0x23>
    return -1;
801054eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054f0:	eb 4f                	jmp    80105541 <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801054f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054f5:	85 c0                	test   %eax,%eax
801054f7:	78 20                	js     80105519 <argfd+0x4a>
801054f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054fc:	83 f8 0f             	cmp    $0xf,%eax
801054ff:	7f 18                	jg     80105519 <argfd+0x4a>
80105501:	e8 5b ec ff ff       	call   80104161 <myproc>
80105506:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105509:	83 c2 08             	add    $0x8,%edx
8010550c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105510:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105513:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105517:	75 07                	jne    80105520 <argfd+0x51>
    return -1;
80105519:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010551e:	eb 21                	jmp    80105541 <argfd+0x72>
  if(pfd)
80105520:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105524:	74 08                	je     8010552e <argfd+0x5f>
    *pfd = fd;
80105526:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105529:	8b 45 0c             	mov    0xc(%ebp),%eax
8010552c:	89 10                	mov    %edx,(%eax)
  if(pf)
8010552e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105532:	74 08                	je     8010553c <argfd+0x6d>
    *pf = f;
80105534:	8b 45 10             	mov    0x10(%ebp),%eax
80105537:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010553a:	89 10                	mov    %edx,(%eax)
  return 0;
8010553c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105541:	c9                   	leave  
80105542:	c3                   	ret    

80105543 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105543:	55                   	push   %ebp
80105544:	89 e5                	mov    %esp,%ebp
80105546:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105549:	e8 13 ec ff ff       	call   80104161 <myproc>
8010554e:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105551:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105558:	eb 2a                	jmp    80105584 <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
8010555a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010555d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105560:	83 c2 08             	add    $0x8,%edx
80105563:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105567:	85 c0                	test   %eax,%eax
80105569:	75 15                	jne    80105580 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
8010556b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010556e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105571:	8d 4a 08             	lea    0x8(%edx),%ecx
80105574:	8b 55 08             	mov    0x8(%ebp),%edx
80105577:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
8010557b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010557e:	eb 0f                	jmp    8010558f <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
80105580:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105584:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105588:	7e d0                	jle    8010555a <fdalloc+0x17>
    }
  }
  return -1;
8010558a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010558f:	c9                   	leave  
80105590:	c3                   	ret    

80105591 <sys_dup>:

int
sys_dup(void)
{
80105591:	55                   	push   %ebp
80105592:	89 e5                	mov    %esp,%ebp
80105594:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105597:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010559a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010559e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801055a5:	00 
801055a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801055ad:	e8 1d ff ff ff       	call   801054cf <argfd>
801055b2:	85 c0                	test   %eax,%eax
801055b4:	79 07                	jns    801055bd <sys_dup+0x2c>
    return -1;
801055b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055bb:	eb 29                	jmp    801055e6 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801055bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055c0:	89 04 24             	mov    %eax,(%esp)
801055c3:	e8 7b ff ff ff       	call   80105543 <fdalloc>
801055c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801055cb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801055cf:	79 07                	jns    801055d8 <sys_dup+0x47>
    return -1;
801055d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055d6:	eb 0e                	jmp    801055e6 <sys_dup+0x55>
  filedup(f);
801055d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055db:	89 04 24             	mov    %eax,(%esp)
801055de:	e8 02 ba ff ff       	call   80100fe5 <filedup>
  return fd;
801055e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801055e6:	c9                   	leave  
801055e7:	c3                   	ret    

801055e8 <sys_read>:

int
sys_read(void)
{
801055e8:	55                   	push   %ebp
801055e9:	89 e5                	mov    %esp,%ebp
801055eb:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801055ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
801055f1:	89 44 24 08          	mov    %eax,0x8(%esp)
801055f5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801055fc:	00 
801055fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105604:	e8 c6 fe ff ff       	call   801054cf <argfd>
80105609:	85 c0                	test   %eax,%eax
8010560b:	78 35                	js     80105642 <sys_read+0x5a>
8010560d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105610:	89 44 24 04          	mov    %eax,0x4(%esp)
80105614:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010561b:	e8 59 fd ff ff       	call   80105379 <argint>
80105620:	85 c0                	test   %eax,%eax
80105622:	78 1e                	js     80105642 <sys_read+0x5a>
80105624:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105627:	89 44 24 08          	mov    %eax,0x8(%esp)
8010562b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010562e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105632:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105639:	e8 68 fd ff ff       	call   801053a6 <argptr>
8010563e:	85 c0                	test   %eax,%eax
80105640:	79 07                	jns    80105649 <sys_read+0x61>
    return -1;
80105642:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105647:	eb 19                	jmp    80105662 <sys_read+0x7a>
  return fileread(f, p, n);
80105649:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010564c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010564f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105652:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105656:	89 54 24 04          	mov    %edx,0x4(%esp)
8010565a:	89 04 24             	mov    %eax,(%esp)
8010565d:	e8 f0 ba ff ff       	call   80101152 <fileread>
}
80105662:	c9                   	leave  
80105663:	c3                   	ret    

80105664 <sys_write>:

int
sys_write(void)
{
80105664:	55                   	push   %ebp
80105665:	89 e5                	mov    %esp,%ebp
80105667:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010566a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010566d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105671:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105678:	00 
80105679:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105680:	e8 4a fe ff ff       	call   801054cf <argfd>
80105685:	85 c0                	test   %eax,%eax
80105687:	78 35                	js     801056be <sys_write+0x5a>
80105689:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010568c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105690:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105697:	e8 dd fc ff ff       	call   80105379 <argint>
8010569c:	85 c0                	test   %eax,%eax
8010569e:	78 1e                	js     801056be <sys_write+0x5a>
801056a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056a3:	89 44 24 08          	mov    %eax,0x8(%esp)
801056a7:	8d 45 ec             	lea    -0x14(%ebp),%eax
801056aa:	89 44 24 04          	mov    %eax,0x4(%esp)
801056ae:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801056b5:	e8 ec fc ff ff       	call   801053a6 <argptr>
801056ba:	85 c0                	test   %eax,%eax
801056bc:	79 07                	jns    801056c5 <sys_write+0x61>
    return -1;
801056be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056c3:	eb 19                	jmp    801056de <sys_write+0x7a>
  return filewrite(f, p, n);
801056c5:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801056c8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801056cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056ce:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801056d2:	89 54 24 04          	mov    %edx,0x4(%esp)
801056d6:	89 04 24             	mov    %eax,(%esp)
801056d9:	e8 30 bb ff ff       	call   8010120e <filewrite>
}
801056de:	c9                   	leave  
801056df:	c3                   	ret    

801056e0 <sys_close>:

int
sys_close(void)
{
801056e0:	55                   	push   %ebp
801056e1:	89 e5                	mov    %esp,%ebp
801056e3:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
801056e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801056e9:	89 44 24 08          	mov    %eax,0x8(%esp)
801056ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
801056f0:	89 44 24 04          	mov    %eax,0x4(%esp)
801056f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801056fb:	e8 cf fd ff ff       	call   801054cf <argfd>
80105700:	85 c0                	test   %eax,%eax
80105702:	79 07                	jns    8010570b <sys_close+0x2b>
    return -1;
80105704:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105709:	eb 23                	jmp    8010572e <sys_close+0x4e>
  myproc()->ofile[fd] = 0;
8010570b:	e8 51 ea ff ff       	call   80104161 <myproc>
80105710:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105713:	83 c2 08             	add    $0x8,%edx
80105716:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010571d:	00 
  fileclose(f);
8010571e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105721:	89 04 24             	mov    %eax,(%esp)
80105724:	e8 04 b9 ff ff       	call   8010102d <fileclose>
  return 0;
80105729:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010572e:	c9                   	leave  
8010572f:	c3                   	ret    

80105730 <sys_fstat>:

int
sys_fstat(void)
{
80105730:	55                   	push   %ebp
80105731:	89 e5                	mov    %esp,%ebp
80105733:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105736:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105739:	89 44 24 08          	mov    %eax,0x8(%esp)
8010573d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105744:	00 
80105745:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010574c:	e8 7e fd ff ff       	call   801054cf <argfd>
80105751:	85 c0                	test   %eax,%eax
80105753:	78 1f                	js     80105774 <sys_fstat+0x44>
80105755:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
8010575c:	00 
8010575d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105760:	89 44 24 04          	mov    %eax,0x4(%esp)
80105764:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010576b:	e8 36 fc ff ff       	call   801053a6 <argptr>
80105770:	85 c0                	test   %eax,%eax
80105772:	79 07                	jns    8010577b <sys_fstat+0x4b>
    return -1;
80105774:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105779:	eb 12                	jmp    8010578d <sys_fstat+0x5d>
  return filestat(f, st);
8010577b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010577e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105781:	89 54 24 04          	mov    %edx,0x4(%esp)
80105785:	89 04 24             	mov    %eax,(%esp)
80105788:	e8 76 b9 ff ff       	call   80101103 <filestat>
}
8010578d:	c9                   	leave  
8010578e:	c3                   	ret    

8010578f <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
8010578f:	55                   	push   %ebp
80105790:	89 e5                	mov    %esp,%ebp
80105792:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105795:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105798:	89 44 24 04          	mov    %eax,0x4(%esp)
8010579c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801057a3:	e8 68 fc ff ff       	call   80105410 <argstr>
801057a8:	85 c0                	test   %eax,%eax
801057aa:	78 17                	js     801057c3 <sys_link+0x34>
801057ac:	8d 45 dc             	lea    -0x24(%ebp),%eax
801057af:	89 44 24 04          	mov    %eax,0x4(%esp)
801057b3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801057ba:	e8 51 fc ff ff       	call   80105410 <argstr>
801057bf:	85 c0                	test   %eax,%eax
801057c1:	79 0a                	jns    801057cd <sys_link+0x3e>
    return -1;
801057c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057c8:	e9 42 01 00 00       	jmp    8010590f <sys_link+0x180>

  begin_op();
801057cd:	e8 b5 dc ff ff       	call   80103487 <begin_op>
  if((ip = namei(old)) == 0){
801057d2:	8b 45 d8             	mov    -0x28(%ebp),%eax
801057d5:	89 04 24             	mov    %eax,(%esp)
801057d8:	e8 ba cc ff ff       	call   80102497 <namei>
801057dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
801057e0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801057e4:	75 0f                	jne    801057f5 <sys_link+0x66>
    end_op();
801057e6:	e8 20 dd ff ff       	call   8010350b <end_op>
    return -1;
801057eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057f0:	e9 1a 01 00 00       	jmp    8010590f <sys_link+0x180>
  }

  ilock(ip);
801057f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057f8:	89 04 24             	mov    %eax,(%esp)
801057fb:	e8 5d c1 ff ff       	call   8010195d <ilock>
  if(ip->type == T_DIR){
80105800:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105803:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105807:	66 83 f8 01          	cmp    $0x1,%ax
8010580b:	75 1a                	jne    80105827 <sys_link+0x98>
    iunlockput(ip);
8010580d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105810:	89 04 24             	mov    %eax,(%esp)
80105813:	e8 47 c3 ff ff       	call   80101b5f <iunlockput>
    end_op();
80105818:	e8 ee dc ff ff       	call   8010350b <end_op>
    return -1;
8010581d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105822:	e9 e8 00 00 00       	jmp    8010590f <sys_link+0x180>
  }

  ip->nlink++;
80105827:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010582a:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010582e:	8d 50 01             	lea    0x1(%eax),%edx
80105831:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105834:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105838:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010583b:	89 04 24             	mov    %eax,(%esp)
8010583e:	e8 55 bf ff ff       	call   80101798 <iupdate>
  iunlock(ip);
80105843:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105846:	89 04 24             	mov    %eax,(%esp)
80105849:	e8 1c c2 ff ff       	call   80101a6a <iunlock>

  if((dp = nameiparent(new, name)) == 0)
8010584e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105851:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105854:	89 54 24 04          	mov    %edx,0x4(%esp)
80105858:	89 04 24             	mov    %eax,(%esp)
8010585b:	e8 59 cc ff ff       	call   801024b9 <nameiparent>
80105860:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105863:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105867:	75 02                	jne    8010586b <sys_link+0xdc>
    goto bad;
80105869:	eb 68                	jmp    801058d3 <sys_link+0x144>
  ilock(dp);
8010586b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010586e:	89 04 24             	mov    %eax,(%esp)
80105871:	e8 e7 c0 ff ff       	call   8010195d <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105876:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105879:	8b 10                	mov    (%eax),%edx
8010587b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010587e:	8b 00                	mov    (%eax),%eax
80105880:	39 c2                	cmp    %eax,%edx
80105882:	75 20                	jne    801058a4 <sys_link+0x115>
80105884:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105887:	8b 40 04             	mov    0x4(%eax),%eax
8010588a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010588e:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105891:	89 44 24 04          	mov    %eax,0x4(%esp)
80105895:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105898:	89 04 24             	mov    %eax,(%esp)
8010589b:	e8 38 c9 ff ff       	call   801021d8 <dirlink>
801058a0:	85 c0                	test   %eax,%eax
801058a2:	79 0d                	jns    801058b1 <sys_link+0x122>
    iunlockput(dp);
801058a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058a7:	89 04 24             	mov    %eax,(%esp)
801058aa:	e8 b0 c2 ff ff       	call   80101b5f <iunlockput>
    goto bad;
801058af:	eb 22                	jmp    801058d3 <sys_link+0x144>
  }
  iunlockput(dp);
801058b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058b4:	89 04 24             	mov    %eax,(%esp)
801058b7:	e8 a3 c2 ff ff       	call   80101b5f <iunlockput>
  iput(ip);
801058bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058bf:	89 04 24             	mov    %eax,(%esp)
801058c2:	e8 e7 c1 ff ff       	call   80101aae <iput>

  end_op();
801058c7:	e8 3f dc ff ff       	call   8010350b <end_op>

  return 0;
801058cc:	b8 00 00 00 00       	mov    $0x0,%eax
801058d1:	eb 3c                	jmp    8010590f <sys_link+0x180>

bad:
  ilock(ip);
801058d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058d6:	89 04 24             	mov    %eax,(%esp)
801058d9:	e8 7f c0 ff ff       	call   8010195d <ilock>
  ip->nlink--;
801058de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058e1:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801058e5:	8d 50 ff             	lea    -0x1(%eax),%edx
801058e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058eb:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801058ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058f2:	89 04 24             	mov    %eax,(%esp)
801058f5:	e8 9e be ff ff       	call   80101798 <iupdate>
  iunlockput(ip);
801058fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058fd:	89 04 24             	mov    %eax,(%esp)
80105900:	e8 5a c2 ff ff       	call   80101b5f <iunlockput>
  end_op();
80105905:	e8 01 dc ff ff       	call   8010350b <end_op>
  return -1;
8010590a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010590f:	c9                   	leave  
80105910:	c3                   	ret    

80105911 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105911:	55                   	push   %ebp
80105912:	89 e5                	mov    %esp,%ebp
80105914:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105917:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
8010591e:	eb 4b                	jmp    8010596b <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105920:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105923:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010592a:	00 
8010592b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010592f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105932:	89 44 24 04          	mov    %eax,0x4(%esp)
80105936:	8b 45 08             	mov    0x8(%ebp),%eax
80105939:	89 04 24             	mov    %eax,(%esp)
8010593c:	e8 b9 c4 ff ff       	call   80101dfa <readi>
80105941:	83 f8 10             	cmp    $0x10,%eax
80105944:	74 0c                	je     80105952 <isdirempty+0x41>
      panic("isdirempty: readi");
80105946:	c7 04 24 f0 86 10 80 	movl   $0x801086f0,(%esp)
8010594d:	e8 10 ac ff ff       	call   80100562 <panic>
    if(de.inum != 0)
80105952:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105956:	66 85 c0             	test   %ax,%ax
80105959:	74 07                	je     80105962 <isdirempty+0x51>
      return 0;
8010595b:	b8 00 00 00 00       	mov    $0x0,%eax
80105960:	eb 1b                	jmp    8010597d <isdirempty+0x6c>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105962:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105965:	83 c0 10             	add    $0x10,%eax
80105968:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010596b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010596e:	8b 45 08             	mov    0x8(%ebp),%eax
80105971:	8b 40 58             	mov    0x58(%eax),%eax
80105974:	39 c2                	cmp    %eax,%edx
80105976:	72 a8                	jb     80105920 <isdirempty+0xf>
  }
  return 1;
80105978:	b8 01 00 00 00       	mov    $0x1,%eax
}
8010597d:	c9                   	leave  
8010597e:	c3                   	ret    

8010597f <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
8010597f:	55                   	push   %ebp
80105980:	89 e5                	mov    %esp,%ebp
80105982:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105985:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105988:	89 44 24 04          	mov    %eax,0x4(%esp)
8010598c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105993:	e8 78 fa ff ff       	call   80105410 <argstr>
80105998:	85 c0                	test   %eax,%eax
8010599a:	79 0a                	jns    801059a6 <sys_unlink+0x27>
    return -1;
8010599c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059a1:	e9 af 01 00 00       	jmp    80105b55 <sys_unlink+0x1d6>

  begin_op();
801059a6:	e8 dc da ff ff       	call   80103487 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801059ab:	8b 45 cc             	mov    -0x34(%ebp),%eax
801059ae:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801059b1:	89 54 24 04          	mov    %edx,0x4(%esp)
801059b5:	89 04 24             	mov    %eax,(%esp)
801059b8:	e8 fc ca ff ff       	call   801024b9 <nameiparent>
801059bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
801059c0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801059c4:	75 0f                	jne    801059d5 <sys_unlink+0x56>
    end_op();
801059c6:	e8 40 db ff ff       	call   8010350b <end_op>
    return -1;
801059cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059d0:	e9 80 01 00 00       	jmp    80105b55 <sys_unlink+0x1d6>
  }

  ilock(dp);
801059d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059d8:	89 04 24             	mov    %eax,(%esp)
801059db:	e8 7d bf ff ff       	call   8010195d <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801059e0:	c7 44 24 04 02 87 10 	movl   $0x80108702,0x4(%esp)
801059e7:	80 
801059e8:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801059eb:	89 04 24             	mov    %eax,(%esp)
801059ee:	e8 fa c6 ff ff       	call   801020ed <namecmp>
801059f3:	85 c0                	test   %eax,%eax
801059f5:	0f 84 45 01 00 00    	je     80105b40 <sys_unlink+0x1c1>
801059fb:	c7 44 24 04 04 87 10 	movl   $0x80108704,0x4(%esp)
80105a02:	80 
80105a03:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105a06:	89 04 24             	mov    %eax,(%esp)
80105a09:	e8 df c6 ff ff       	call   801020ed <namecmp>
80105a0e:	85 c0                	test   %eax,%eax
80105a10:	0f 84 2a 01 00 00    	je     80105b40 <sys_unlink+0x1c1>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105a16:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105a19:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a1d:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105a20:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a27:	89 04 24             	mov    %eax,(%esp)
80105a2a:	e8 e0 c6 ff ff       	call   8010210f <dirlookup>
80105a2f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105a32:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105a36:	75 05                	jne    80105a3d <sys_unlink+0xbe>
    goto bad;
80105a38:	e9 03 01 00 00       	jmp    80105b40 <sys_unlink+0x1c1>
  ilock(ip);
80105a3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a40:	89 04 24             	mov    %eax,(%esp)
80105a43:	e8 15 bf ff ff       	call   8010195d <ilock>

  if(ip->nlink < 1)
80105a48:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a4b:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105a4f:	66 85 c0             	test   %ax,%ax
80105a52:	7f 0c                	jg     80105a60 <sys_unlink+0xe1>
    panic("unlink: nlink < 1");
80105a54:	c7 04 24 07 87 10 80 	movl   $0x80108707,(%esp)
80105a5b:	e8 02 ab ff ff       	call   80100562 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105a60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a63:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105a67:	66 83 f8 01          	cmp    $0x1,%ax
80105a6b:	75 1f                	jne    80105a8c <sys_unlink+0x10d>
80105a6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a70:	89 04 24             	mov    %eax,(%esp)
80105a73:	e8 99 fe ff ff       	call   80105911 <isdirempty>
80105a78:	85 c0                	test   %eax,%eax
80105a7a:	75 10                	jne    80105a8c <sys_unlink+0x10d>
    iunlockput(ip);
80105a7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a7f:	89 04 24             	mov    %eax,(%esp)
80105a82:	e8 d8 c0 ff ff       	call   80101b5f <iunlockput>
    goto bad;
80105a87:	e9 b4 00 00 00       	jmp    80105b40 <sys_unlink+0x1c1>
  }

  memset(&de, 0, sizeof(de));
80105a8c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105a93:	00 
80105a94:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105a9b:	00 
80105a9c:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105a9f:	89 04 24             	mov    %eax,(%esp)
80105aa2:	e8 89 f5 ff ff       	call   80105030 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105aa7:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105aaa:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105ab1:	00 
80105ab2:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ab6:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105ab9:	89 44 24 04          	mov    %eax,0x4(%esp)
80105abd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ac0:	89 04 24             	mov    %eax,(%esp)
80105ac3:	e8 96 c4 ff ff       	call   80101f5e <writei>
80105ac8:	83 f8 10             	cmp    $0x10,%eax
80105acb:	74 0c                	je     80105ad9 <sys_unlink+0x15a>
    panic("unlink: writei");
80105acd:	c7 04 24 19 87 10 80 	movl   $0x80108719,(%esp)
80105ad4:	e8 89 aa ff ff       	call   80100562 <panic>
  if(ip->type == T_DIR){
80105ad9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105adc:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105ae0:	66 83 f8 01          	cmp    $0x1,%ax
80105ae4:	75 1c                	jne    80105b02 <sys_unlink+0x183>
    dp->nlink--;
80105ae6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ae9:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105aed:	8d 50 ff             	lea    -0x1(%eax),%edx
80105af0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105af3:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105af7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105afa:	89 04 24             	mov    %eax,(%esp)
80105afd:	e8 96 bc ff ff       	call   80101798 <iupdate>
  }
  iunlockput(dp);
80105b02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b05:	89 04 24             	mov    %eax,(%esp)
80105b08:	e8 52 c0 ff ff       	call   80101b5f <iunlockput>

  ip->nlink--;
80105b0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b10:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105b14:	8d 50 ff             	lea    -0x1(%eax),%edx
80105b17:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b1a:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105b1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b21:	89 04 24             	mov    %eax,(%esp)
80105b24:	e8 6f bc ff ff       	call   80101798 <iupdate>
  iunlockput(ip);
80105b29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b2c:	89 04 24             	mov    %eax,(%esp)
80105b2f:	e8 2b c0 ff ff       	call   80101b5f <iunlockput>

  end_op();
80105b34:	e8 d2 d9 ff ff       	call   8010350b <end_op>

  return 0;
80105b39:	b8 00 00 00 00       	mov    $0x0,%eax
80105b3e:	eb 15                	jmp    80105b55 <sys_unlink+0x1d6>

bad:
  iunlockput(dp);
80105b40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b43:	89 04 24             	mov    %eax,(%esp)
80105b46:	e8 14 c0 ff ff       	call   80101b5f <iunlockput>
  end_op();
80105b4b:	e8 bb d9 ff ff       	call   8010350b <end_op>
  return -1;
80105b50:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b55:	c9                   	leave  
80105b56:	c3                   	ret    

80105b57 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105b57:	55                   	push   %ebp
80105b58:	89 e5                	mov    %esp,%ebp
80105b5a:	83 ec 48             	sub    $0x48,%esp
80105b5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105b60:	8b 55 10             	mov    0x10(%ebp),%edx
80105b63:	8b 45 14             	mov    0x14(%ebp),%eax
80105b66:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105b6a:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105b6e:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105b72:	8d 45 de             	lea    -0x22(%ebp),%eax
80105b75:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b79:	8b 45 08             	mov    0x8(%ebp),%eax
80105b7c:	89 04 24             	mov    %eax,(%esp)
80105b7f:	e8 35 c9 ff ff       	call   801024b9 <nameiparent>
80105b84:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b87:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b8b:	75 0a                	jne    80105b97 <create+0x40>
    return 0;
80105b8d:	b8 00 00 00 00       	mov    $0x0,%eax
80105b92:	e9 7e 01 00 00       	jmp    80105d15 <create+0x1be>
  ilock(dp);
80105b97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b9a:	89 04 24             	mov    %eax,(%esp)
80105b9d:	e8 bb bd ff ff       	call   8010195d <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80105ba2:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105ba5:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ba9:	8d 45 de             	lea    -0x22(%ebp),%eax
80105bac:	89 44 24 04          	mov    %eax,0x4(%esp)
80105bb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bb3:	89 04 24             	mov    %eax,(%esp)
80105bb6:	e8 54 c5 ff ff       	call   8010210f <dirlookup>
80105bbb:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105bbe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105bc2:	74 47                	je     80105c0b <create+0xb4>
    iunlockput(dp);
80105bc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bc7:	89 04 24             	mov    %eax,(%esp)
80105bca:	e8 90 bf ff ff       	call   80101b5f <iunlockput>
    ilock(ip);
80105bcf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bd2:	89 04 24             	mov    %eax,(%esp)
80105bd5:	e8 83 bd ff ff       	call   8010195d <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80105bda:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105bdf:	75 15                	jne    80105bf6 <create+0x9f>
80105be1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105be4:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105be8:	66 83 f8 02          	cmp    $0x2,%ax
80105bec:	75 08                	jne    80105bf6 <create+0x9f>
      return ip;
80105bee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bf1:	e9 1f 01 00 00       	jmp    80105d15 <create+0x1be>
    iunlockput(ip);
80105bf6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bf9:	89 04 24             	mov    %eax,(%esp)
80105bfc:	e8 5e bf ff ff       	call   80101b5f <iunlockput>
    return 0;
80105c01:	b8 00 00 00 00       	mov    $0x0,%eax
80105c06:	e9 0a 01 00 00       	jmp    80105d15 <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105c0b:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105c0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c12:	8b 00                	mov    (%eax),%eax
80105c14:	89 54 24 04          	mov    %edx,0x4(%esp)
80105c18:	89 04 24             	mov    %eax,(%esp)
80105c1b:	e8 a3 ba ff ff       	call   801016c3 <ialloc>
80105c20:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c23:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c27:	75 0c                	jne    80105c35 <create+0xde>
    panic("create: ialloc");
80105c29:	c7 04 24 28 87 10 80 	movl   $0x80108728,(%esp)
80105c30:	e8 2d a9 ff ff       	call   80100562 <panic>

  ilock(ip);
80105c35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c38:	89 04 24             	mov    %eax,(%esp)
80105c3b:	e8 1d bd ff ff       	call   8010195d <ilock>
  ip->major = major;
80105c40:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c43:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105c47:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105c4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c4e:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105c52:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105c56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c59:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105c5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c62:	89 04 24             	mov    %eax,(%esp)
80105c65:	e8 2e bb ff ff       	call   80101798 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80105c6a:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105c6f:	75 6a                	jne    80105cdb <create+0x184>
    dp->nlink++;  // for ".."
80105c71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c74:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105c78:	8d 50 01             	lea    0x1(%eax),%edx
80105c7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c7e:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105c82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c85:	89 04 24             	mov    %eax,(%esp)
80105c88:	e8 0b bb ff ff       	call   80101798 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105c8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c90:	8b 40 04             	mov    0x4(%eax),%eax
80105c93:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c97:	c7 44 24 04 02 87 10 	movl   $0x80108702,0x4(%esp)
80105c9e:	80 
80105c9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ca2:	89 04 24             	mov    %eax,(%esp)
80105ca5:	e8 2e c5 ff ff       	call   801021d8 <dirlink>
80105caa:	85 c0                	test   %eax,%eax
80105cac:	78 21                	js     80105ccf <create+0x178>
80105cae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cb1:	8b 40 04             	mov    0x4(%eax),%eax
80105cb4:	89 44 24 08          	mov    %eax,0x8(%esp)
80105cb8:	c7 44 24 04 04 87 10 	movl   $0x80108704,0x4(%esp)
80105cbf:	80 
80105cc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cc3:	89 04 24             	mov    %eax,(%esp)
80105cc6:	e8 0d c5 ff ff       	call   801021d8 <dirlink>
80105ccb:	85 c0                	test   %eax,%eax
80105ccd:	79 0c                	jns    80105cdb <create+0x184>
      panic("create dots");
80105ccf:	c7 04 24 37 87 10 80 	movl   $0x80108737,(%esp)
80105cd6:	e8 87 a8 ff ff       	call   80100562 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105cdb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cde:	8b 40 04             	mov    0x4(%eax),%eax
80105ce1:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ce5:	8d 45 de             	lea    -0x22(%ebp),%eax
80105ce8:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cef:	89 04 24             	mov    %eax,(%esp)
80105cf2:	e8 e1 c4 ff ff       	call   801021d8 <dirlink>
80105cf7:	85 c0                	test   %eax,%eax
80105cf9:	79 0c                	jns    80105d07 <create+0x1b0>
    panic("create: dirlink");
80105cfb:	c7 04 24 43 87 10 80 	movl   $0x80108743,(%esp)
80105d02:	e8 5b a8 ff ff       	call   80100562 <panic>

  iunlockput(dp);
80105d07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d0a:	89 04 24             	mov    %eax,(%esp)
80105d0d:	e8 4d be ff ff       	call   80101b5f <iunlockput>

  return ip;
80105d12:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105d15:	c9                   	leave  
80105d16:	c3                   	ret    

80105d17 <sys_open>:

int
sys_open(void)
{
80105d17:	55                   	push   %ebp
80105d18:	89 e5                	mov    %esp,%ebp
80105d1a:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105d1d:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105d20:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d24:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105d2b:	e8 e0 f6 ff ff       	call   80105410 <argstr>
80105d30:	85 c0                	test   %eax,%eax
80105d32:	78 17                	js     80105d4b <sys_open+0x34>
80105d34:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105d37:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d3b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105d42:	e8 32 f6 ff ff       	call   80105379 <argint>
80105d47:	85 c0                	test   %eax,%eax
80105d49:	79 0a                	jns    80105d55 <sys_open+0x3e>
    return -1;
80105d4b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d50:	e9 5c 01 00 00       	jmp    80105eb1 <sys_open+0x19a>

  begin_op();
80105d55:	e8 2d d7 ff ff       	call   80103487 <begin_op>

  if(omode & O_CREATE){
80105d5a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105d5d:	25 00 02 00 00       	and    $0x200,%eax
80105d62:	85 c0                	test   %eax,%eax
80105d64:	74 3b                	je     80105da1 <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
80105d66:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105d69:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105d70:	00 
80105d71:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105d78:	00 
80105d79:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80105d80:	00 
80105d81:	89 04 24             	mov    %eax,(%esp)
80105d84:	e8 ce fd ff ff       	call   80105b57 <create>
80105d89:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105d8c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d90:	75 6b                	jne    80105dfd <sys_open+0xe6>
      end_op();
80105d92:	e8 74 d7 ff ff       	call   8010350b <end_op>
      return -1;
80105d97:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d9c:	e9 10 01 00 00       	jmp    80105eb1 <sys_open+0x19a>
    }
  } else {
    if((ip = namei(path)) == 0){
80105da1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105da4:	89 04 24             	mov    %eax,(%esp)
80105da7:	e8 eb c6 ff ff       	call   80102497 <namei>
80105dac:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105daf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105db3:	75 0f                	jne    80105dc4 <sys_open+0xad>
      end_op();
80105db5:	e8 51 d7 ff ff       	call   8010350b <end_op>
      return -1;
80105dba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dbf:	e9 ed 00 00 00       	jmp    80105eb1 <sys_open+0x19a>
    }
    ilock(ip);
80105dc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dc7:	89 04 24             	mov    %eax,(%esp)
80105dca:	e8 8e bb ff ff       	call   8010195d <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80105dcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dd2:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105dd6:	66 83 f8 01          	cmp    $0x1,%ax
80105dda:	75 21                	jne    80105dfd <sys_open+0xe6>
80105ddc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ddf:	85 c0                	test   %eax,%eax
80105de1:	74 1a                	je     80105dfd <sys_open+0xe6>
      iunlockput(ip);
80105de3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105de6:	89 04 24             	mov    %eax,(%esp)
80105de9:	e8 71 bd ff ff       	call   80101b5f <iunlockput>
      end_op();
80105dee:	e8 18 d7 ff ff       	call   8010350b <end_op>
      return -1;
80105df3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105df8:	e9 b4 00 00 00       	jmp    80105eb1 <sys_open+0x19a>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105dfd:	e8 83 b1 ff ff       	call   80100f85 <filealloc>
80105e02:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e05:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e09:	74 14                	je     80105e1f <sys_open+0x108>
80105e0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e0e:	89 04 24             	mov    %eax,(%esp)
80105e11:	e8 2d f7 ff ff       	call   80105543 <fdalloc>
80105e16:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105e19:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105e1d:	79 28                	jns    80105e47 <sys_open+0x130>
    if(f)
80105e1f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e23:	74 0b                	je     80105e30 <sys_open+0x119>
      fileclose(f);
80105e25:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e28:	89 04 24             	mov    %eax,(%esp)
80105e2b:	e8 fd b1 ff ff       	call   8010102d <fileclose>
    iunlockput(ip);
80105e30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e33:	89 04 24             	mov    %eax,(%esp)
80105e36:	e8 24 bd ff ff       	call   80101b5f <iunlockput>
    end_op();
80105e3b:	e8 cb d6 ff ff       	call   8010350b <end_op>
    return -1;
80105e40:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e45:	eb 6a                	jmp    80105eb1 <sys_open+0x19a>
  }
  iunlock(ip);
80105e47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e4a:	89 04 24             	mov    %eax,(%esp)
80105e4d:	e8 18 bc ff ff       	call   80101a6a <iunlock>
  end_op();
80105e52:	e8 b4 d6 ff ff       	call   8010350b <end_op>

  f->type = FD_INODE;
80105e57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e5a:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105e60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e63:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105e66:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105e69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e6c:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105e73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e76:	83 e0 01             	and    $0x1,%eax
80105e79:	85 c0                	test   %eax,%eax
80105e7b:	0f 94 c0             	sete   %al
80105e7e:	89 c2                	mov    %eax,%edx
80105e80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e83:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105e86:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e89:	83 e0 01             	and    $0x1,%eax
80105e8c:	85 c0                	test   %eax,%eax
80105e8e:	75 0a                	jne    80105e9a <sys_open+0x183>
80105e90:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e93:	83 e0 02             	and    $0x2,%eax
80105e96:	85 c0                	test   %eax,%eax
80105e98:	74 07                	je     80105ea1 <sys_open+0x18a>
80105e9a:	b8 01 00 00 00       	mov    $0x1,%eax
80105e9f:	eb 05                	jmp    80105ea6 <sys_open+0x18f>
80105ea1:	b8 00 00 00 00       	mov    $0x0,%eax
80105ea6:	89 c2                	mov    %eax,%edx
80105ea8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eab:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105eae:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105eb1:	c9                   	leave  
80105eb2:	c3                   	ret    

80105eb3 <sys_mkdir>:

int
sys_mkdir(void)
{
80105eb3:	55                   	push   %ebp
80105eb4:	89 e5                	mov    %esp,%ebp
80105eb6:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105eb9:	e8 c9 d5 ff ff       	call   80103487 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105ebe:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ec1:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ec5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105ecc:	e8 3f f5 ff ff       	call   80105410 <argstr>
80105ed1:	85 c0                	test   %eax,%eax
80105ed3:	78 2c                	js     80105f01 <sys_mkdir+0x4e>
80105ed5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ed8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105edf:	00 
80105ee0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105ee7:	00 
80105ee8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80105eef:	00 
80105ef0:	89 04 24             	mov    %eax,(%esp)
80105ef3:	e8 5f fc ff ff       	call   80105b57 <create>
80105ef8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105efb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105eff:	75 0c                	jne    80105f0d <sys_mkdir+0x5a>
    end_op();
80105f01:	e8 05 d6 ff ff       	call   8010350b <end_op>
    return -1;
80105f06:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f0b:	eb 15                	jmp    80105f22 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
80105f0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f10:	89 04 24             	mov    %eax,(%esp)
80105f13:	e8 47 bc ff ff       	call   80101b5f <iunlockput>
  end_op();
80105f18:	e8 ee d5 ff ff       	call   8010350b <end_op>
  return 0;
80105f1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f22:	c9                   	leave  
80105f23:	c3                   	ret    

80105f24 <sys_mknod>:

int
sys_mknod(void)
{
80105f24:	55                   	push   %ebp
80105f25:	89 e5                	mov    %esp,%ebp
80105f27:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105f2a:	e8 58 d5 ff ff       	call   80103487 <begin_op>
  if((argstr(0, &path)) < 0 ||
80105f2f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105f32:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f36:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105f3d:	e8 ce f4 ff ff       	call   80105410 <argstr>
80105f42:	85 c0                	test   %eax,%eax
80105f44:	78 5e                	js     80105fa4 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
80105f46:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105f49:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f4d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105f54:	e8 20 f4 ff ff       	call   80105379 <argint>
  if((argstr(0, &path)) < 0 ||
80105f59:	85 c0                	test   %eax,%eax
80105f5b:	78 47                	js     80105fa4 <sys_mknod+0x80>
     argint(2, &minor) < 0 ||
80105f5d:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105f60:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f64:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105f6b:	e8 09 f4 ff ff       	call   80105379 <argint>
     argint(1, &major) < 0 ||
80105f70:	85 c0                	test   %eax,%eax
80105f72:	78 30                	js     80105fa4 <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105f74:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f77:	0f bf c8             	movswl %ax,%ecx
80105f7a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105f7d:	0f bf d0             	movswl %ax,%edx
80105f80:	8b 45 f0             	mov    -0x10(%ebp),%eax
     argint(2, &minor) < 0 ||
80105f83:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80105f87:	89 54 24 08          	mov    %edx,0x8(%esp)
80105f8b:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80105f92:	00 
80105f93:	89 04 24             	mov    %eax,(%esp)
80105f96:	e8 bc fb ff ff       	call   80105b57 <create>
80105f9b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f9e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fa2:	75 0c                	jne    80105fb0 <sys_mknod+0x8c>
    end_op();
80105fa4:	e8 62 d5 ff ff       	call   8010350b <end_op>
    return -1;
80105fa9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fae:	eb 15                	jmp    80105fc5 <sys_mknod+0xa1>
  }
  iunlockput(ip);
80105fb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fb3:	89 04 24             	mov    %eax,(%esp)
80105fb6:	e8 a4 bb ff ff       	call   80101b5f <iunlockput>
  end_op();
80105fbb:	e8 4b d5 ff ff       	call   8010350b <end_op>
  return 0;
80105fc0:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105fc5:	c9                   	leave  
80105fc6:	c3                   	ret    

80105fc7 <sys_chdir>:

int
sys_chdir(void)
{
80105fc7:	55                   	push   %ebp
80105fc8:	89 e5                	mov    %esp,%ebp
80105fca:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105fcd:	e8 8f e1 ff ff       	call   80104161 <myproc>
80105fd2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80105fd5:	e8 ad d4 ff ff       	call   80103487 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105fda:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105fdd:	89 44 24 04          	mov    %eax,0x4(%esp)
80105fe1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105fe8:	e8 23 f4 ff ff       	call   80105410 <argstr>
80105fed:	85 c0                	test   %eax,%eax
80105fef:	78 14                	js     80106005 <sys_chdir+0x3e>
80105ff1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105ff4:	89 04 24             	mov    %eax,(%esp)
80105ff7:	e8 9b c4 ff ff       	call   80102497 <namei>
80105ffc:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105fff:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106003:	75 0c                	jne    80106011 <sys_chdir+0x4a>
    end_op();
80106005:	e8 01 d5 ff ff       	call   8010350b <end_op>
    return -1;
8010600a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010600f:	eb 5b                	jmp    8010606c <sys_chdir+0xa5>
  }
  ilock(ip);
80106011:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106014:	89 04 24             	mov    %eax,(%esp)
80106017:	e8 41 b9 ff ff       	call   8010195d <ilock>
  if(ip->type != T_DIR){
8010601c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010601f:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106023:	66 83 f8 01          	cmp    $0x1,%ax
80106027:	74 17                	je     80106040 <sys_chdir+0x79>
    iunlockput(ip);
80106029:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010602c:	89 04 24             	mov    %eax,(%esp)
8010602f:	e8 2b bb ff ff       	call   80101b5f <iunlockput>
    end_op();
80106034:	e8 d2 d4 ff ff       	call   8010350b <end_op>
    return -1;
80106039:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010603e:	eb 2c                	jmp    8010606c <sys_chdir+0xa5>
  }
  iunlock(ip);
80106040:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106043:	89 04 24             	mov    %eax,(%esp)
80106046:	e8 1f ba ff ff       	call   80101a6a <iunlock>
  iput(curproc->cwd);
8010604b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010604e:	8b 40 68             	mov    0x68(%eax),%eax
80106051:	89 04 24             	mov    %eax,(%esp)
80106054:	e8 55 ba ff ff       	call   80101aae <iput>
  end_op();
80106059:	e8 ad d4 ff ff       	call   8010350b <end_op>
  curproc->cwd = ip;
8010605e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106061:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106064:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106067:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010606c:	c9                   	leave  
8010606d:	c3                   	ret    

8010606e <sys_exec>:

int
sys_exec(void)
{
8010606e:	55                   	push   %ebp
8010606f:	89 e5                	mov    %esp,%ebp
80106071:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106077:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010607a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010607e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106085:	e8 86 f3 ff ff       	call   80105410 <argstr>
8010608a:	85 c0                	test   %eax,%eax
8010608c:	78 1a                	js     801060a8 <sys_exec+0x3a>
8010608e:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106094:	89 44 24 04          	mov    %eax,0x4(%esp)
80106098:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010609f:	e8 d5 f2 ff ff       	call   80105379 <argint>
801060a4:	85 c0                	test   %eax,%eax
801060a6:	79 0a                	jns    801060b2 <sys_exec+0x44>
    return -1;
801060a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060ad:	e9 c8 00 00 00       	jmp    8010617a <sys_exec+0x10c>
  }
  memset(argv, 0, sizeof(argv));
801060b2:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801060b9:	00 
801060ba:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801060c1:	00 
801060c2:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801060c8:	89 04 24             	mov    %eax,(%esp)
801060cb:	e8 60 ef ff ff       	call   80105030 <memset>
  for(i=0;; i++){
801060d0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801060d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060da:	83 f8 1f             	cmp    $0x1f,%eax
801060dd:	76 0a                	jbe    801060e9 <sys_exec+0x7b>
      return -1;
801060df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060e4:	e9 91 00 00 00       	jmp    8010617a <sys_exec+0x10c>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801060e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060ec:	c1 e0 02             	shl    $0x2,%eax
801060ef:	89 c2                	mov    %eax,%edx
801060f1:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801060f7:	01 c2                	add    %eax,%edx
801060f9:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801060ff:	89 44 24 04          	mov    %eax,0x4(%esp)
80106103:	89 14 24             	mov    %edx,(%esp)
80106106:	e8 cb f1 ff ff       	call   801052d6 <fetchint>
8010610b:	85 c0                	test   %eax,%eax
8010610d:	79 07                	jns    80106116 <sys_exec+0xa8>
      return -1;
8010610f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106114:	eb 64                	jmp    8010617a <sys_exec+0x10c>
    if(uarg == 0){
80106116:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010611c:	85 c0                	test   %eax,%eax
8010611e:	75 26                	jne    80106146 <sys_exec+0xd8>
      argv[i] = 0;
80106120:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106123:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
8010612a:	00 00 00 00 
      break;
8010612e:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
8010612f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106132:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106138:	89 54 24 04          	mov    %edx,0x4(%esp)
8010613c:	89 04 24             	mov    %eax,(%esp)
8010613f:	e8 da a9 ff ff       	call   80100b1e <exec>
80106144:	eb 34                	jmp    8010617a <sys_exec+0x10c>
    if(fetchstr(uarg, &argv[i]) < 0)
80106146:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010614c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010614f:	c1 e2 02             	shl    $0x2,%edx
80106152:	01 c2                	add    %eax,%edx
80106154:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010615a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010615e:	89 04 24             	mov    %eax,(%esp)
80106161:	e8 af f1 ff ff       	call   80105315 <fetchstr>
80106166:	85 c0                	test   %eax,%eax
80106168:	79 07                	jns    80106171 <sys_exec+0x103>
      return -1;
8010616a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010616f:	eb 09                	jmp    8010617a <sys_exec+0x10c>
  for(i=0;; i++){
80106171:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }
80106175:	e9 5d ff ff ff       	jmp    801060d7 <sys_exec+0x69>
}
8010617a:	c9                   	leave  
8010617b:	c3                   	ret    

8010617c <sys_pipe>:

int
sys_pipe(void)
{
8010617c:	55                   	push   %ebp
8010617d:	89 e5                	mov    %esp,%ebp
8010617f:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106182:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80106189:	00 
8010618a:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010618d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106191:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106198:	e8 09 f2 ff ff       	call   801053a6 <argptr>
8010619d:	85 c0                	test   %eax,%eax
8010619f:	79 0a                	jns    801061ab <sys_pipe+0x2f>
    return -1;
801061a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061a6:	e9 9a 00 00 00       	jmp    80106245 <sys_pipe+0xc9>
  if(pipealloc(&rf, &wf) < 0)
801061ab:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801061ae:	89 44 24 04          	mov    %eax,0x4(%esp)
801061b2:	8d 45 e8             	lea    -0x18(%ebp),%eax
801061b5:	89 04 24             	mov    %eax,(%esp)
801061b8:	e8 28 db ff ff       	call   80103ce5 <pipealloc>
801061bd:	85 c0                	test   %eax,%eax
801061bf:	79 07                	jns    801061c8 <sys_pipe+0x4c>
    return -1;
801061c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061c6:	eb 7d                	jmp    80106245 <sys_pipe+0xc9>
  fd0 = -1;
801061c8:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801061cf:	8b 45 e8             	mov    -0x18(%ebp),%eax
801061d2:	89 04 24             	mov    %eax,(%esp)
801061d5:	e8 69 f3 ff ff       	call   80105543 <fdalloc>
801061da:	89 45 f4             	mov    %eax,-0xc(%ebp)
801061dd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061e1:	78 14                	js     801061f7 <sys_pipe+0x7b>
801061e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061e6:	89 04 24             	mov    %eax,(%esp)
801061e9:	e8 55 f3 ff ff       	call   80105543 <fdalloc>
801061ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
801061f1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801061f5:	79 36                	jns    8010622d <sys_pipe+0xb1>
    if(fd0 >= 0)
801061f7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061fb:	78 13                	js     80106210 <sys_pipe+0x94>
      myproc()->ofile[fd0] = 0;
801061fd:	e8 5f df ff ff       	call   80104161 <myproc>
80106202:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106205:	83 c2 08             	add    $0x8,%edx
80106208:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010620f:	00 
    fileclose(rf);
80106210:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106213:	89 04 24             	mov    %eax,(%esp)
80106216:	e8 12 ae ff ff       	call   8010102d <fileclose>
    fileclose(wf);
8010621b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010621e:	89 04 24             	mov    %eax,(%esp)
80106221:	e8 07 ae ff ff       	call   8010102d <fileclose>
    return -1;
80106226:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010622b:	eb 18                	jmp    80106245 <sys_pipe+0xc9>
  }
  fd[0] = fd0;
8010622d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106230:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106233:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106235:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106238:	8d 50 04             	lea    0x4(%eax),%edx
8010623b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010623e:	89 02                	mov    %eax,(%edx)
  return 0;
80106240:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106245:	c9                   	leave  
80106246:	c3                   	ret    

80106247 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106247:	55                   	push   %ebp
80106248:	89 e5                	mov    %esp,%ebp
8010624a:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010624d:	e8 26 e2 ff ff       	call   80104478 <fork>
}
80106252:	c9                   	leave  
80106253:	c3                   	ret    

80106254 <sys_exit>:

int
sys_exit(void)
{
80106254:	55                   	push   %ebp
80106255:	89 e5                	mov    %esp,%ebp
80106257:	83 ec 08             	sub    $0x8,%esp
  exit();
8010625a:	e8 8d e3 ff ff       	call   801045ec <exit>
  return 0;  // not reached
8010625f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106264:	c9                   	leave  
80106265:	c3                   	ret    

80106266 <sys_wait>:

int
sys_wait(void)
{
80106266:	55                   	push   %ebp
80106267:	89 e5                	mov    %esp,%ebp
80106269:	83 ec 08             	sub    $0x8,%esp
  return wait();
8010626c:	e8 85 e4 ff ff       	call   801046f6 <wait>
}
80106271:	c9                   	leave  
80106272:	c3                   	ret    

80106273 <sys_kill>:

int
sys_kill(void)
{
80106273:	55                   	push   %ebp
80106274:	89 e5                	mov    %esp,%ebp
80106276:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106279:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010627c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106280:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106287:	e8 ed f0 ff ff       	call   80105379 <argint>
8010628c:	85 c0                	test   %eax,%eax
8010628e:	79 07                	jns    80106297 <sys_kill+0x24>
    return -1;
80106290:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106295:	eb 0b                	jmp    801062a2 <sys_kill+0x2f>
  return kill(pid);
80106297:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010629a:	89 04 24             	mov    %eax,(%esp)
8010629d:	e8 29 e8 ff ff       	call   80104acb <kill>
}
801062a2:	c9                   	leave  
801062a3:	c3                   	ret    

801062a4 <sys_getpid>:

int
sys_getpid(void)
{
801062a4:	55                   	push   %ebp
801062a5:	89 e5                	mov    %esp,%ebp
801062a7:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
801062aa:	e8 b2 de ff ff       	call   80104161 <myproc>
801062af:	8b 40 10             	mov    0x10(%eax),%eax
}
801062b2:	c9                   	leave  
801062b3:	c3                   	ret    

801062b4 <sys_sbrk>:

int
sys_sbrk(void)
{
801062b4:	55                   	push   %ebp
801062b5:	89 e5                	mov    %esp,%ebp
801062b7:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801062ba:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062bd:	89 44 24 04          	mov    %eax,0x4(%esp)
801062c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801062c8:	e8 ac f0 ff ff       	call   80105379 <argint>
801062cd:	85 c0                	test   %eax,%eax
801062cf:	79 07                	jns    801062d8 <sys_sbrk+0x24>
    return -1;
801062d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062d6:	eb 23                	jmp    801062fb <sys_sbrk+0x47>
  addr = myproc()->sz;
801062d8:	e8 84 de ff ff       	call   80104161 <myproc>
801062dd:	8b 00                	mov    (%eax),%eax
801062df:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801062e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062e5:	89 04 24             	mov    %eax,(%esp)
801062e8:	e8 d4 e0 ff ff       	call   801043c1 <growproc>
801062ed:	85 c0                	test   %eax,%eax
801062ef:	79 07                	jns    801062f8 <sys_sbrk+0x44>
    return -1;
801062f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062f6:	eb 03                	jmp    801062fb <sys_sbrk+0x47>
  return addr;
801062f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801062fb:	c9                   	leave  
801062fc:	c3                   	ret    

801062fd <sys_sleep>:

int
sys_sleep(void)
{
801062fd:	55                   	push   %ebp
801062fe:	89 e5                	mov    %esp,%ebp
80106300:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80106303:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106306:	89 44 24 04          	mov    %eax,0x4(%esp)
8010630a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106311:	e8 63 f0 ff ff       	call   80105379 <argint>
80106316:	85 c0                	test   %eax,%eax
80106318:	79 07                	jns    80106321 <sys_sleep+0x24>
    return -1;
8010631a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010631f:	eb 6b                	jmp    8010638c <sys_sleep+0x8f>
  acquire(&tickslock);
80106321:	c7 04 24 e0 5c 11 80 	movl   $0x80115ce0,(%esp)
80106328:	e8 91 ea ff ff       	call   80104dbe <acquire>
  ticks0 = ticks;
8010632d:	a1 20 65 11 80       	mov    0x80116520,%eax
80106332:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106335:	eb 33                	jmp    8010636a <sys_sleep+0x6d>
    if(myproc()->killed){
80106337:	e8 25 de ff ff       	call   80104161 <myproc>
8010633c:	8b 40 24             	mov    0x24(%eax),%eax
8010633f:	85 c0                	test   %eax,%eax
80106341:	74 13                	je     80106356 <sys_sleep+0x59>
      release(&tickslock);
80106343:	c7 04 24 e0 5c 11 80 	movl   $0x80115ce0,(%esp)
8010634a:	e8 d7 ea ff ff       	call   80104e26 <release>
      return -1;
8010634f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106354:	eb 36                	jmp    8010638c <sys_sleep+0x8f>
    }
    sleep(&ticks, &tickslock);
80106356:	c7 44 24 04 e0 5c 11 	movl   $0x80115ce0,0x4(%esp)
8010635d:	80 
8010635e:	c7 04 24 20 65 11 80 	movl   $0x80116520,(%esp)
80106365:	e8 62 e6 ff ff       	call   801049cc <sleep>
  while(ticks - ticks0 < n){
8010636a:	a1 20 65 11 80       	mov    0x80116520,%eax
8010636f:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106372:	89 c2                	mov    %eax,%edx
80106374:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106377:	39 c2                	cmp    %eax,%edx
80106379:	72 bc                	jb     80106337 <sys_sleep+0x3a>
  }
  release(&tickslock);
8010637b:	c7 04 24 e0 5c 11 80 	movl   $0x80115ce0,(%esp)
80106382:	e8 9f ea ff ff       	call   80104e26 <release>
  return 0;
80106387:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010638c:	c9                   	leave  
8010638d:	c3                   	ret    

8010638e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
8010638e:	55                   	push   %ebp
8010638f:	89 e5                	mov    %esp,%ebp
80106391:	83 ec 28             	sub    $0x28,%esp
  uint xticks;

  acquire(&tickslock);
80106394:	c7 04 24 e0 5c 11 80 	movl   $0x80115ce0,(%esp)
8010639b:	e8 1e ea ff ff       	call   80104dbe <acquire>
  xticks = ticks;
801063a0:	a1 20 65 11 80       	mov    0x80116520,%eax
801063a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801063a8:	c7 04 24 e0 5c 11 80 	movl   $0x80115ce0,(%esp)
801063af:	e8 72 ea ff ff       	call   80104e26 <release>
  return xticks;
801063b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801063b7:	c9                   	leave  
801063b8:	c3                   	ret    

801063b9 <sys_hw>:

int
sys_hw(void)
{
801063b9:	55                   	push   %ebp
801063ba:	89 e5                	mov    %esp,%ebp
801063bc:	83 ec 18             	sub    $0x18,%esp
  cprintf("hello world!\n");
801063bf:	c7 04 24 53 87 10 80 	movl   $0x80108753,(%esp)
801063c6:	e8 fd 9f ff ff       	call   801003c8 <cprintf>
  return 0;
801063cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
801063d0:	c9                   	leave  
801063d1:	c3                   	ret    

801063d2 <sys_fkc>:


int 
sys_fkc(void) 
{
801063d2:	55                   	push   %ebp
801063d3:	89 e5                	mov    %esp,%ebp
801063d5:	83 ec 28             	sub    $0x28,%esp
  int n;
  if (argint(0, &n) < 0) return -1;
801063d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
801063db:	89 44 24 04          	mov    %eax,0x4(%esp)
801063df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801063e6:	e8 8e ef ff ff       	call   80105379 <argint>
801063eb:	85 c0                	test   %eax,%eax
801063ed:	79 07                	jns    801063f6 <sys_fkc+0x24>
801063ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063f4:	eb 18                	jmp    8010640e <sys_fkc+0x3c>

  if (n == 0) {
801063f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063f9:	85 c0                	test   %eax,%eax
801063fb:	75 0c                	jne    80106409 <sys_fkc+0x37>
    reset_fork_count();
801063fd:	e8 67 e0 ff ff       	call   80104469 <reset_fork_count>
    return 0;
80106402:	b8 00 00 00 00       	mov    $0x0,%eax
80106407:	eb 05                	jmp    8010640e <sys_fkc+0x3c>
  }
  return get_fork_count();
80106409:	e8 51 e0 ff ff       	call   8010445f <get_fork_count>
8010640e:	c9                   	leave  
8010640f:	c3                   	ret    

80106410 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106410:	1e                   	push   %ds
  pushl %es
80106411:	06                   	push   %es
  pushl %fs
80106412:	0f a0                	push   %fs
  pushl %gs
80106414:	0f a8                	push   %gs
  pushal
80106416:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106417:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010641b:	8e d8                	mov    %eax,%ds
  movw %ax, %es
8010641d:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
8010641f:	54                   	push   %esp
  call trap
80106420:	e8 d8 01 00 00       	call   801065fd <trap>
  addl $4, %esp
80106425:	83 c4 04             	add    $0x4,%esp

80106428 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106428:	61                   	popa   
  popl %gs
80106429:	0f a9                	pop    %gs
  popl %fs
8010642b:	0f a1                	pop    %fs
  popl %es
8010642d:	07                   	pop    %es
  popl %ds
8010642e:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010642f:	83 c4 08             	add    $0x8,%esp
  iret
80106432:	cf                   	iret   

80106433 <lidt>:
{
80106433:	55                   	push   %ebp
80106434:	89 e5                	mov    %esp,%ebp
80106436:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106439:	8b 45 0c             	mov    0xc(%ebp),%eax
8010643c:	83 e8 01             	sub    $0x1,%eax
8010643f:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106443:	8b 45 08             	mov    0x8(%ebp),%eax
80106446:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010644a:	8b 45 08             	mov    0x8(%ebp),%eax
8010644d:	c1 e8 10             	shr    $0x10,%eax
80106450:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80106454:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106457:	0f 01 18             	lidtl  (%eax)
}
8010645a:	c9                   	leave  
8010645b:	c3                   	ret    

8010645c <rcr2>:

static inline uint
rcr2(void)
{
8010645c:	55                   	push   %ebp
8010645d:	89 e5                	mov    %esp,%ebp
8010645f:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106462:	0f 20 d0             	mov    %cr2,%eax
80106465:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106468:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010646b:	c9                   	leave  
8010646c:	c3                   	ret    

8010646d <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
8010646d:	55                   	push   %ebp
8010646e:	89 e5                	mov    %esp,%ebp
80106470:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
80106473:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010647a:	e9 c3 00 00 00       	jmp    80106542 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
8010647f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106482:	8b 04 85 80 b0 10 80 	mov    -0x7fef4f80(,%eax,4),%eax
80106489:	89 c2                	mov    %eax,%edx
8010648b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010648e:	66 89 14 c5 20 5d 11 	mov    %dx,-0x7feea2e0(,%eax,8)
80106495:	80 
80106496:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106499:	66 c7 04 c5 22 5d 11 	movw   $0x8,-0x7feea2de(,%eax,8)
801064a0:	80 08 00 
801064a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064a6:	0f b6 14 c5 24 5d 11 	movzbl -0x7feea2dc(,%eax,8),%edx
801064ad:	80 
801064ae:	83 e2 e0             	and    $0xffffffe0,%edx
801064b1:	88 14 c5 24 5d 11 80 	mov    %dl,-0x7feea2dc(,%eax,8)
801064b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064bb:	0f b6 14 c5 24 5d 11 	movzbl -0x7feea2dc(,%eax,8),%edx
801064c2:	80 
801064c3:	83 e2 1f             	and    $0x1f,%edx
801064c6:	88 14 c5 24 5d 11 80 	mov    %dl,-0x7feea2dc(,%eax,8)
801064cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064d0:	0f b6 14 c5 25 5d 11 	movzbl -0x7feea2db(,%eax,8),%edx
801064d7:	80 
801064d8:	83 e2 f0             	and    $0xfffffff0,%edx
801064db:	83 ca 0e             	or     $0xe,%edx
801064de:	88 14 c5 25 5d 11 80 	mov    %dl,-0x7feea2db(,%eax,8)
801064e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064e8:	0f b6 14 c5 25 5d 11 	movzbl -0x7feea2db(,%eax,8),%edx
801064ef:	80 
801064f0:	83 e2 ef             	and    $0xffffffef,%edx
801064f3:	88 14 c5 25 5d 11 80 	mov    %dl,-0x7feea2db(,%eax,8)
801064fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064fd:	0f b6 14 c5 25 5d 11 	movzbl -0x7feea2db(,%eax,8),%edx
80106504:	80 
80106505:	83 e2 9f             	and    $0xffffff9f,%edx
80106508:	88 14 c5 25 5d 11 80 	mov    %dl,-0x7feea2db(,%eax,8)
8010650f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106512:	0f b6 14 c5 25 5d 11 	movzbl -0x7feea2db(,%eax,8),%edx
80106519:	80 
8010651a:	83 ca 80             	or     $0xffffff80,%edx
8010651d:	88 14 c5 25 5d 11 80 	mov    %dl,-0x7feea2db(,%eax,8)
80106524:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106527:	8b 04 85 80 b0 10 80 	mov    -0x7fef4f80(,%eax,4),%eax
8010652e:	c1 e8 10             	shr    $0x10,%eax
80106531:	89 c2                	mov    %eax,%edx
80106533:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106536:	66 89 14 c5 26 5d 11 	mov    %dx,-0x7feea2da(,%eax,8)
8010653d:	80 
  for(i = 0; i < 256; i++)
8010653e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106542:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106549:	0f 8e 30 ff ff ff    	jle    8010647f <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010654f:	a1 80 b1 10 80       	mov    0x8010b180,%eax
80106554:	66 a3 20 5f 11 80    	mov    %ax,0x80115f20
8010655a:	66 c7 05 22 5f 11 80 	movw   $0x8,0x80115f22
80106561:	08 00 
80106563:	0f b6 05 24 5f 11 80 	movzbl 0x80115f24,%eax
8010656a:	83 e0 e0             	and    $0xffffffe0,%eax
8010656d:	a2 24 5f 11 80       	mov    %al,0x80115f24
80106572:	0f b6 05 24 5f 11 80 	movzbl 0x80115f24,%eax
80106579:	83 e0 1f             	and    $0x1f,%eax
8010657c:	a2 24 5f 11 80       	mov    %al,0x80115f24
80106581:	0f b6 05 25 5f 11 80 	movzbl 0x80115f25,%eax
80106588:	83 c8 0f             	or     $0xf,%eax
8010658b:	a2 25 5f 11 80       	mov    %al,0x80115f25
80106590:	0f b6 05 25 5f 11 80 	movzbl 0x80115f25,%eax
80106597:	83 e0 ef             	and    $0xffffffef,%eax
8010659a:	a2 25 5f 11 80       	mov    %al,0x80115f25
8010659f:	0f b6 05 25 5f 11 80 	movzbl 0x80115f25,%eax
801065a6:	83 c8 60             	or     $0x60,%eax
801065a9:	a2 25 5f 11 80       	mov    %al,0x80115f25
801065ae:	0f b6 05 25 5f 11 80 	movzbl 0x80115f25,%eax
801065b5:	83 c8 80             	or     $0xffffff80,%eax
801065b8:	a2 25 5f 11 80       	mov    %al,0x80115f25
801065bd:	a1 80 b1 10 80       	mov    0x8010b180,%eax
801065c2:	c1 e8 10             	shr    $0x10,%eax
801065c5:	66 a3 26 5f 11 80    	mov    %ax,0x80115f26

  initlock(&tickslock, "time");
801065cb:	c7 44 24 04 64 87 10 	movl   $0x80108764,0x4(%esp)
801065d2:	80 
801065d3:	c7 04 24 e0 5c 11 80 	movl   $0x80115ce0,(%esp)
801065da:	e8 be e7 ff ff       	call   80104d9d <initlock>
}
801065df:	c9                   	leave  
801065e0:	c3                   	ret    

801065e1 <idtinit>:

void
idtinit(void)
{
801065e1:	55                   	push   %ebp
801065e2:	89 e5                	mov    %esp,%ebp
801065e4:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
801065e7:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
801065ee:	00 
801065ef:	c7 04 24 20 5d 11 80 	movl   $0x80115d20,(%esp)
801065f6:	e8 38 fe ff ff       	call   80106433 <lidt>
}
801065fb:	c9                   	leave  
801065fc:	c3                   	ret    

801065fd <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801065fd:	55                   	push   %ebp
801065fe:	89 e5                	mov    %esp,%ebp
80106600:	57                   	push   %edi
80106601:	56                   	push   %esi
80106602:	53                   	push   %ebx
80106603:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
80106606:	8b 45 08             	mov    0x8(%ebp),%eax
80106609:	8b 40 30             	mov    0x30(%eax),%eax
8010660c:	83 f8 40             	cmp    $0x40,%eax
8010660f:	75 3c                	jne    8010664d <trap+0x50>
    if(myproc()->killed)
80106611:	e8 4b db ff ff       	call   80104161 <myproc>
80106616:	8b 40 24             	mov    0x24(%eax),%eax
80106619:	85 c0                	test   %eax,%eax
8010661b:	74 05                	je     80106622 <trap+0x25>
      exit();
8010661d:	e8 ca df ff ff       	call   801045ec <exit>
    myproc()->tf = tf;
80106622:	e8 3a db ff ff       	call   80104161 <myproc>
80106627:	8b 55 08             	mov    0x8(%ebp),%edx
8010662a:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
8010662d:	e8 15 ee ff ff       	call   80105447 <syscall>
    if(myproc()->killed)
80106632:	e8 2a db ff ff       	call   80104161 <myproc>
80106637:	8b 40 24             	mov    0x24(%eax),%eax
8010663a:	85 c0                	test   %eax,%eax
8010663c:	74 0a                	je     80106648 <trap+0x4b>
      exit();
8010663e:	e8 a9 df ff ff       	call   801045ec <exit>
    return;
80106643:	e9 19 02 00 00       	jmp    80106861 <trap+0x264>
80106648:	e9 14 02 00 00       	jmp    80106861 <trap+0x264>
  }

  switch(tf->trapno){
8010664d:	8b 45 08             	mov    0x8(%ebp),%eax
80106650:	8b 40 30             	mov    0x30(%eax),%eax
80106653:	83 e8 20             	sub    $0x20,%eax
80106656:	83 f8 1f             	cmp    $0x1f,%eax
80106659:	0f 87 b1 00 00 00    	ja     80106710 <trap+0x113>
8010665f:	8b 04 85 0c 88 10 80 	mov    -0x7fef77f4(,%eax,4),%eax
80106666:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80106668:	e8 5d da ff ff       	call   801040ca <cpuid>
8010666d:	85 c0                	test   %eax,%eax
8010666f:	75 31                	jne    801066a2 <trap+0xa5>
      acquire(&tickslock);
80106671:	c7 04 24 e0 5c 11 80 	movl   $0x80115ce0,(%esp)
80106678:	e8 41 e7 ff ff       	call   80104dbe <acquire>
      ticks++;
8010667d:	a1 20 65 11 80       	mov    0x80116520,%eax
80106682:	83 c0 01             	add    $0x1,%eax
80106685:	a3 20 65 11 80       	mov    %eax,0x80116520
      wakeup(&ticks);
8010668a:	c7 04 24 20 65 11 80 	movl   $0x80116520,(%esp)
80106691:	e8 0a e4 ff ff       	call   80104aa0 <wakeup>
      release(&tickslock);
80106696:	c7 04 24 e0 5c 11 80 	movl   $0x80115ce0,(%esp)
8010669d:	e8 84 e7 ff ff       	call   80104e26 <release>
    }
    lapiceoi();
801066a2:	e8 aa c8 ff ff       	call   80102f51 <lapiceoi>
    break;
801066a7:	e9 37 01 00 00       	jmp    801067e3 <trap+0x1e6>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801066ac:	e8 17 c1 ff ff       	call   801027c8 <ideintr>
    lapiceoi();
801066b1:	e8 9b c8 ff ff       	call   80102f51 <lapiceoi>
    break;
801066b6:	e9 28 01 00 00       	jmp    801067e3 <trap+0x1e6>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801066bb:	e8 a6 c6 ff ff       	call   80102d66 <kbdintr>
    lapiceoi();
801066c0:	e8 8c c8 ff ff       	call   80102f51 <lapiceoi>
    break;
801066c5:	e9 19 01 00 00       	jmp    801067e3 <trap+0x1e6>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801066ca:	e8 7b 03 00 00       	call   80106a4a <uartintr>
    lapiceoi();
801066cf:	e8 7d c8 ff ff       	call   80102f51 <lapiceoi>
    break;
801066d4:	e9 0a 01 00 00       	jmp    801067e3 <trap+0x1e6>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801066d9:	8b 45 08             	mov    0x8(%ebp),%eax
801066dc:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
801066df:	8b 45 08             	mov    0x8(%ebp),%eax
801066e2:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801066e6:	0f b7 d8             	movzwl %ax,%ebx
801066e9:	e8 dc d9 ff ff       	call   801040ca <cpuid>
801066ee:	89 74 24 0c          	mov    %esi,0xc(%esp)
801066f2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801066f6:	89 44 24 04          	mov    %eax,0x4(%esp)
801066fa:	c7 04 24 6c 87 10 80 	movl   $0x8010876c,(%esp)
80106701:	e8 c2 9c ff ff       	call   801003c8 <cprintf>
    lapiceoi();
80106706:	e8 46 c8 ff ff       	call   80102f51 <lapiceoi>
    break;
8010670b:	e9 d3 00 00 00       	jmp    801067e3 <trap+0x1e6>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106710:	e8 4c da ff ff       	call   80104161 <myproc>
80106715:	85 c0                	test   %eax,%eax
80106717:	74 11                	je     8010672a <trap+0x12d>
80106719:	8b 45 08             	mov    0x8(%ebp),%eax
8010671c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106720:	0f b7 c0             	movzwl %ax,%eax
80106723:	83 e0 03             	and    $0x3,%eax
80106726:	85 c0                	test   %eax,%eax
80106728:	75 40                	jne    8010676a <trap+0x16d>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010672a:	e8 2d fd ff ff       	call   8010645c <rcr2>
8010672f:	89 c3                	mov    %eax,%ebx
80106731:	8b 45 08             	mov    0x8(%ebp),%eax
80106734:	8b 70 38             	mov    0x38(%eax),%esi
80106737:	e8 8e d9 ff ff       	call   801040ca <cpuid>
8010673c:	8b 55 08             	mov    0x8(%ebp),%edx
8010673f:	8b 52 30             	mov    0x30(%edx),%edx
80106742:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106746:	89 74 24 0c          	mov    %esi,0xc(%esp)
8010674a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010674e:	89 54 24 04          	mov    %edx,0x4(%esp)
80106752:	c7 04 24 90 87 10 80 	movl   $0x80108790,(%esp)
80106759:	e8 6a 9c ff ff       	call   801003c8 <cprintf>
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
8010675e:	c7 04 24 c2 87 10 80 	movl   $0x801087c2,(%esp)
80106765:	e8 f8 9d ff ff       	call   80100562 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010676a:	e8 ed fc ff ff       	call   8010645c <rcr2>
8010676f:	89 c6                	mov    %eax,%esi
80106771:	8b 45 08             	mov    0x8(%ebp),%eax
80106774:	8b 40 38             	mov    0x38(%eax),%eax
80106777:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010677a:	e8 4b d9 ff ff       	call   801040ca <cpuid>
8010677f:	89 c3                	mov    %eax,%ebx
80106781:	8b 45 08             	mov    0x8(%ebp),%eax
80106784:	8b 78 34             	mov    0x34(%eax),%edi
80106787:	89 7d e0             	mov    %edi,-0x20(%ebp)
8010678a:	8b 45 08             	mov    0x8(%ebp),%eax
8010678d:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106790:	e8 cc d9 ff ff       	call   80104161 <myproc>
80106795:	8d 50 6c             	lea    0x6c(%eax),%edx
80106798:	89 55 dc             	mov    %edx,-0x24(%ebp)
8010679b:	e8 c1 d9 ff ff       	call   80104161 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801067a0:	8b 40 10             	mov    0x10(%eax),%eax
801067a3:	89 74 24 1c          	mov    %esi,0x1c(%esp)
801067a7:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801067aa:	89 4c 24 18          	mov    %ecx,0x18(%esp)
801067ae:	89 5c 24 14          	mov    %ebx,0x14(%esp)
801067b2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
801067b5:	89 4c 24 10          	mov    %ecx,0x10(%esp)
801067b9:	89 7c 24 0c          	mov    %edi,0xc(%esp)
801067bd:	8b 55 dc             	mov    -0x24(%ebp),%edx
801067c0:	89 54 24 08          	mov    %edx,0x8(%esp)
801067c4:	89 44 24 04          	mov    %eax,0x4(%esp)
801067c8:	c7 04 24 c8 87 10 80 	movl   $0x801087c8,(%esp)
801067cf:	e8 f4 9b ff ff       	call   801003c8 <cprintf>
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
801067d4:	e8 88 d9 ff ff       	call   80104161 <myproc>
801067d9:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801067e0:	eb 01                	jmp    801067e3 <trap+0x1e6>
    break;
801067e2:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801067e3:	e8 79 d9 ff ff       	call   80104161 <myproc>
801067e8:	85 c0                	test   %eax,%eax
801067ea:	74 23                	je     8010680f <trap+0x212>
801067ec:	e8 70 d9 ff ff       	call   80104161 <myproc>
801067f1:	8b 40 24             	mov    0x24(%eax),%eax
801067f4:	85 c0                	test   %eax,%eax
801067f6:	74 17                	je     8010680f <trap+0x212>
801067f8:	8b 45 08             	mov    0x8(%ebp),%eax
801067fb:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801067ff:	0f b7 c0             	movzwl %ax,%eax
80106802:	83 e0 03             	and    $0x3,%eax
80106805:	83 f8 03             	cmp    $0x3,%eax
80106808:	75 05                	jne    8010680f <trap+0x212>
    exit();
8010680a:	e8 dd dd ff ff       	call   801045ec <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
8010680f:	e8 4d d9 ff ff       	call   80104161 <myproc>
80106814:	85 c0                	test   %eax,%eax
80106816:	74 1d                	je     80106835 <trap+0x238>
80106818:	e8 44 d9 ff ff       	call   80104161 <myproc>
8010681d:	8b 40 0c             	mov    0xc(%eax),%eax
80106820:	83 f8 04             	cmp    $0x4,%eax
80106823:	75 10                	jne    80106835 <trap+0x238>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106825:	8b 45 08             	mov    0x8(%ebp),%eax
80106828:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
8010682b:	83 f8 20             	cmp    $0x20,%eax
8010682e:	75 05                	jne    80106835 <trap+0x238>
    yield();
80106830:	e8 27 e1 ff ff       	call   8010495c <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106835:	e8 27 d9 ff ff       	call   80104161 <myproc>
8010683a:	85 c0                	test   %eax,%eax
8010683c:	74 23                	je     80106861 <trap+0x264>
8010683e:	e8 1e d9 ff ff       	call   80104161 <myproc>
80106843:	8b 40 24             	mov    0x24(%eax),%eax
80106846:	85 c0                	test   %eax,%eax
80106848:	74 17                	je     80106861 <trap+0x264>
8010684a:	8b 45 08             	mov    0x8(%ebp),%eax
8010684d:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106851:	0f b7 c0             	movzwl %ax,%eax
80106854:	83 e0 03             	and    $0x3,%eax
80106857:	83 f8 03             	cmp    $0x3,%eax
8010685a:	75 05                	jne    80106861 <trap+0x264>
    exit();
8010685c:	e8 8b dd ff ff       	call   801045ec <exit>
}
80106861:	83 c4 3c             	add    $0x3c,%esp
80106864:	5b                   	pop    %ebx
80106865:	5e                   	pop    %esi
80106866:	5f                   	pop    %edi
80106867:	5d                   	pop    %ebp
80106868:	c3                   	ret    

80106869 <inb>:
{
80106869:	55                   	push   %ebp
8010686a:	89 e5                	mov    %esp,%ebp
8010686c:	83 ec 14             	sub    $0x14,%esp
8010686f:	8b 45 08             	mov    0x8(%ebp),%eax
80106872:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106876:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010687a:	89 c2                	mov    %eax,%edx
8010687c:	ec                   	in     (%dx),%al
8010687d:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106880:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106884:	c9                   	leave  
80106885:	c3                   	ret    

80106886 <outb>:
{
80106886:	55                   	push   %ebp
80106887:	89 e5                	mov    %esp,%ebp
80106889:	83 ec 08             	sub    $0x8,%esp
8010688c:	8b 55 08             	mov    0x8(%ebp),%edx
8010688f:	8b 45 0c             	mov    0xc(%ebp),%eax
80106892:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106896:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106899:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010689d:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801068a1:	ee                   	out    %al,(%dx)
}
801068a2:	c9                   	leave  
801068a3:	c3                   	ret    

801068a4 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801068a4:	55                   	push   %ebp
801068a5:	89 e5                	mov    %esp,%ebp
801068a7:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801068aa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801068b1:	00 
801068b2:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
801068b9:	e8 c8 ff ff ff       	call   80106886 <outb>

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801068be:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
801068c5:	00 
801068c6:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
801068cd:	e8 b4 ff ff ff       	call   80106886 <outb>
  outb(COM1+0, 115200/9600);
801068d2:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
801068d9:	00 
801068da:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801068e1:	e8 a0 ff ff ff       	call   80106886 <outb>
  outb(COM1+1, 0);
801068e6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801068ed:	00 
801068ee:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
801068f5:	e8 8c ff ff ff       	call   80106886 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801068fa:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106901:	00 
80106902:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106909:	e8 78 ff ff ff       	call   80106886 <outb>
  outb(COM1+4, 0);
8010690e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106915:	00 
80106916:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
8010691d:	e8 64 ff ff ff       	call   80106886 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106922:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106929:	00 
8010692a:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106931:	e8 50 ff ff ff       	call   80106886 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106936:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
8010693d:	e8 27 ff ff ff       	call   80106869 <inb>
80106942:	3c ff                	cmp    $0xff,%al
80106944:	75 02                	jne    80106948 <uartinit+0xa4>
    return;
80106946:	eb 5e                	jmp    801069a6 <uartinit+0x102>
  uart = 1;
80106948:	c7 05 28 b6 10 80 01 	movl   $0x1,0x8010b628
8010694f:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106952:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106959:	e8 0b ff ff ff       	call   80106869 <inb>
  inb(COM1+0);
8010695e:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106965:	e8 ff fe ff ff       	call   80106869 <inb>
  ioapicenable(IRQ_COM1, 0);
8010696a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106971:	00 
80106972:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106979:	e8 c1 c0 ff ff       	call   80102a3f <ioapicenable>

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
8010697e:	c7 45 f4 8c 88 10 80 	movl   $0x8010888c,-0xc(%ebp)
80106985:	eb 15                	jmp    8010699c <uartinit+0xf8>
    uartputc(*p);
80106987:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010698a:	0f b6 00             	movzbl (%eax),%eax
8010698d:	0f be c0             	movsbl %al,%eax
80106990:	89 04 24             	mov    %eax,(%esp)
80106993:	e8 10 00 00 00       	call   801069a8 <uartputc>
  for(p="xv6...\n"; *p; p++)
80106998:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010699c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010699f:	0f b6 00             	movzbl (%eax),%eax
801069a2:	84 c0                	test   %al,%al
801069a4:	75 e1                	jne    80106987 <uartinit+0xe3>
}
801069a6:	c9                   	leave  
801069a7:	c3                   	ret    

801069a8 <uartputc>:

void
uartputc(int c)
{
801069a8:	55                   	push   %ebp
801069a9:	89 e5                	mov    %esp,%ebp
801069ab:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
801069ae:	a1 28 b6 10 80       	mov    0x8010b628,%eax
801069b3:	85 c0                	test   %eax,%eax
801069b5:	75 02                	jne    801069b9 <uartputc+0x11>
    return;
801069b7:	eb 4b                	jmp    80106a04 <uartputc+0x5c>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801069b9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801069c0:	eb 10                	jmp    801069d2 <uartputc+0x2a>
    microdelay(10);
801069c2:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
801069c9:	e8 a8 c5 ff ff       	call   80102f76 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801069ce:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801069d2:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801069d6:	7f 16                	jg     801069ee <uartputc+0x46>
801069d8:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
801069df:	e8 85 fe ff ff       	call   80106869 <inb>
801069e4:	0f b6 c0             	movzbl %al,%eax
801069e7:	83 e0 20             	and    $0x20,%eax
801069ea:	85 c0                	test   %eax,%eax
801069ec:	74 d4                	je     801069c2 <uartputc+0x1a>
  outb(COM1+0, c);
801069ee:	8b 45 08             	mov    0x8(%ebp),%eax
801069f1:	0f b6 c0             	movzbl %al,%eax
801069f4:	89 44 24 04          	mov    %eax,0x4(%esp)
801069f8:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801069ff:	e8 82 fe ff ff       	call   80106886 <outb>
}
80106a04:	c9                   	leave  
80106a05:	c3                   	ret    

80106a06 <uartgetc>:

static int
uartgetc(void)
{
80106a06:	55                   	push   %ebp
80106a07:	89 e5                	mov    %esp,%ebp
80106a09:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80106a0c:	a1 28 b6 10 80       	mov    0x8010b628,%eax
80106a11:	85 c0                	test   %eax,%eax
80106a13:	75 07                	jne    80106a1c <uartgetc+0x16>
    return -1;
80106a15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a1a:	eb 2c                	jmp    80106a48 <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80106a1c:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106a23:	e8 41 fe ff ff       	call   80106869 <inb>
80106a28:	0f b6 c0             	movzbl %al,%eax
80106a2b:	83 e0 01             	and    $0x1,%eax
80106a2e:	85 c0                	test   %eax,%eax
80106a30:	75 07                	jne    80106a39 <uartgetc+0x33>
    return -1;
80106a32:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a37:	eb 0f                	jmp    80106a48 <uartgetc+0x42>
  return inb(COM1+0);
80106a39:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106a40:	e8 24 fe ff ff       	call   80106869 <inb>
80106a45:	0f b6 c0             	movzbl %al,%eax
}
80106a48:	c9                   	leave  
80106a49:	c3                   	ret    

80106a4a <uartintr>:

void
uartintr(void)
{
80106a4a:	55                   	push   %ebp
80106a4b:	89 e5                	mov    %esp,%ebp
80106a4d:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80106a50:	c7 04 24 06 6a 10 80 	movl   $0x80106a06,(%esp)
80106a57:	e8 8d 9d ff ff       	call   801007e9 <consoleintr>
}
80106a5c:	c9                   	leave  
80106a5d:	c3                   	ret    

80106a5e <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106a5e:	6a 00                	push   $0x0
  pushl $0
80106a60:	6a 00                	push   $0x0
  jmp alltraps
80106a62:	e9 a9 f9 ff ff       	jmp    80106410 <alltraps>

80106a67 <vector1>:
.globl vector1
vector1:
  pushl $0
80106a67:	6a 00                	push   $0x0
  pushl $1
80106a69:	6a 01                	push   $0x1
  jmp alltraps
80106a6b:	e9 a0 f9 ff ff       	jmp    80106410 <alltraps>

80106a70 <vector2>:
.globl vector2
vector2:
  pushl $0
80106a70:	6a 00                	push   $0x0
  pushl $2
80106a72:	6a 02                	push   $0x2
  jmp alltraps
80106a74:	e9 97 f9 ff ff       	jmp    80106410 <alltraps>

80106a79 <vector3>:
.globl vector3
vector3:
  pushl $0
80106a79:	6a 00                	push   $0x0
  pushl $3
80106a7b:	6a 03                	push   $0x3
  jmp alltraps
80106a7d:	e9 8e f9 ff ff       	jmp    80106410 <alltraps>

80106a82 <vector4>:
.globl vector4
vector4:
  pushl $0
80106a82:	6a 00                	push   $0x0
  pushl $4
80106a84:	6a 04                	push   $0x4
  jmp alltraps
80106a86:	e9 85 f9 ff ff       	jmp    80106410 <alltraps>

80106a8b <vector5>:
.globl vector5
vector5:
  pushl $0
80106a8b:	6a 00                	push   $0x0
  pushl $5
80106a8d:	6a 05                	push   $0x5
  jmp alltraps
80106a8f:	e9 7c f9 ff ff       	jmp    80106410 <alltraps>

80106a94 <vector6>:
.globl vector6
vector6:
  pushl $0
80106a94:	6a 00                	push   $0x0
  pushl $6
80106a96:	6a 06                	push   $0x6
  jmp alltraps
80106a98:	e9 73 f9 ff ff       	jmp    80106410 <alltraps>

80106a9d <vector7>:
.globl vector7
vector7:
  pushl $0
80106a9d:	6a 00                	push   $0x0
  pushl $7
80106a9f:	6a 07                	push   $0x7
  jmp alltraps
80106aa1:	e9 6a f9 ff ff       	jmp    80106410 <alltraps>

80106aa6 <vector8>:
.globl vector8
vector8:
  pushl $8
80106aa6:	6a 08                	push   $0x8
  jmp alltraps
80106aa8:	e9 63 f9 ff ff       	jmp    80106410 <alltraps>

80106aad <vector9>:
.globl vector9
vector9:
  pushl $0
80106aad:	6a 00                	push   $0x0
  pushl $9
80106aaf:	6a 09                	push   $0x9
  jmp alltraps
80106ab1:	e9 5a f9 ff ff       	jmp    80106410 <alltraps>

80106ab6 <vector10>:
.globl vector10
vector10:
  pushl $10
80106ab6:	6a 0a                	push   $0xa
  jmp alltraps
80106ab8:	e9 53 f9 ff ff       	jmp    80106410 <alltraps>

80106abd <vector11>:
.globl vector11
vector11:
  pushl $11
80106abd:	6a 0b                	push   $0xb
  jmp alltraps
80106abf:	e9 4c f9 ff ff       	jmp    80106410 <alltraps>

80106ac4 <vector12>:
.globl vector12
vector12:
  pushl $12
80106ac4:	6a 0c                	push   $0xc
  jmp alltraps
80106ac6:	e9 45 f9 ff ff       	jmp    80106410 <alltraps>

80106acb <vector13>:
.globl vector13
vector13:
  pushl $13
80106acb:	6a 0d                	push   $0xd
  jmp alltraps
80106acd:	e9 3e f9 ff ff       	jmp    80106410 <alltraps>

80106ad2 <vector14>:
.globl vector14
vector14:
  pushl $14
80106ad2:	6a 0e                	push   $0xe
  jmp alltraps
80106ad4:	e9 37 f9 ff ff       	jmp    80106410 <alltraps>

80106ad9 <vector15>:
.globl vector15
vector15:
  pushl $0
80106ad9:	6a 00                	push   $0x0
  pushl $15
80106adb:	6a 0f                	push   $0xf
  jmp alltraps
80106add:	e9 2e f9 ff ff       	jmp    80106410 <alltraps>

80106ae2 <vector16>:
.globl vector16
vector16:
  pushl $0
80106ae2:	6a 00                	push   $0x0
  pushl $16
80106ae4:	6a 10                	push   $0x10
  jmp alltraps
80106ae6:	e9 25 f9 ff ff       	jmp    80106410 <alltraps>

80106aeb <vector17>:
.globl vector17
vector17:
  pushl $17
80106aeb:	6a 11                	push   $0x11
  jmp alltraps
80106aed:	e9 1e f9 ff ff       	jmp    80106410 <alltraps>

80106af2 <vector18>:
.globl vector18
vector18:
  pushl $0
80106af2:	6a 00                	push   $0x0
  pushl $18
80106af4:	6a 12                	push   $0x12
  jmp alltraps
80106af6:	e9 15 f9 ff ff       	jmp    80106410 <alltraps>

80106afb <vector19>:
.globl vector19
vector19:
  pushl $0
80106afb:	6a 00                	push   $0x0
  pushl $19
80106afd:	6a 13                	push   $0x13
  jmp alltraps
80106aff:	e9 0c f9 ff ff       	jmp    80106410 <alltraps>

80106b04 <vector20>:
.globl vector20
vector20:
  pushl $0
80106b04:	6a 00                	push   $0x0
  pushl $20
80106b06:	6a 14                	push   $0x14
  jmp alltraps
80106b08:	e9 03 f9 ff ff       	jmp    80106410 <alltraps>

80106b0d <vector21>:
.globl vector21
vector21:
  pushl $0
80106b0d:	6a 00                	push   $0x0
  pushl $21
80106b0f:	6a 15                	push   $0x15
  jmp alltraps
80106b11:	e9 fa f8 ff ff       	jmp    80106410 <alltraps>

80106b16 <vector22>:
.globl vector22
vector22:
  pushl $0
80106b16:	6a 00                	push   $0x0
  pushl $22
80106b18:	6a 16                	push   $0x16
  jmp alltraps
80106b1a:	e9 f1 f8 ff ff       	jmp    80106410 <alltraps>

80106b1f <vector23>:
.globl vector23
vector23:
  pushl $0
80106b1f:	6a 00                	push   $0x0
  pushl $23
80106b21:	6a 17                	push   $0x17
  jmp alltraps
80106b23:	e9 e8 f8 ff ff       	jmp    80106410 <alltraps>

80106b28 <vector24>:
.globl vector24
vector24:
  pushl $0
80106b28:	6a 00                	push   $0x0
  pushl $24
80106b2a:	6a 18                	push   $0x18
  jmp alltraps
80106b2c:	e9 df f8 ff ff       	jmp    80106410 <alltraps>

80106b31 <vector25>:
.globl vector25
vector25:
  pushl $0
80106b31:	6a 00                	push   $0x0
  pushl $25
80106b33:	6a 19                	push   $0x19
  jmp alltraps
80106b35:	e9 d6 f8 ff ff       	jmp    80106410 <alltraps>

80106b3a <vector26>:
.globl vector26
vector26:
  pushl $0
80106b3a:	6a 00                	push   $0x0
  pushl $26
80106b3c:	6a 1a                	push   $0x1a
  jmp alltraps
80106b3e:	e9 cd f8 ff ff       	jmp    80106410 <alltraps>

80106b43 <vector27>:
.globl vector27
vector27:
  pushl $0
80106b43:	6a 00                	push   $0x0
  pushl $27
80106b45:	6a 1b                	push   $0x1b
  jmp alltraps
80106b47:	e9 c4 f8 ff ff       	jmp    80106410 <alltraps>

80106b4c <vector28>:
.globl vector28
vector28:
  pushl $0
80106b4c:	6a 00                	push   $0x0
  pushl $28
80106b4e:	6a 1c                	push   $0x1c
  jmp alltraps
80106b50:	e9 bb f8 ff ff       	jmp    80106410 <alltraps>

80106b55 <vector29>:
.globl vector29
vector29:
  pushl $0
80106b55:	6a 00                	push   $0x0
  pushl $29
80106b57:	6a 1d                	push   $0x1d
  jmp alltraps
80106b59:	e9 b2 f8 ff ff       	jmp    80106410 <alltraps>

80106b5e <vector30>:
.globl vector30
vector30:
  pushl $0
80106b5e:	6a 00                	push   $0x0
  pushl $30
80106b60:	6a 1e                	push   $0x1e
  jmp alltraps
80106b62:	e9 a9 f8 ff ff       	jmp    80106410 <alltraps>

80106b67 <vector31>:
.globl vector31
vector31:
  pushl $0
80106b67:	6a 00                	push   $0x0
  pushl $31
80106b69:	6a 1f                	push   $0x1f
  jmp alltraps
80106b6b:	e9 a0 f8 ff ff       	jmp    80106410 <alltraps>

80106b70 <vector32>:
.globl vector32
vector32:
  pushl $0
80106b70:	6a 00                	push   $0x0
  pushl $32
80106b72:	6a 20                	push   $0x20
  jmp alltraps
80106b74:	e9 97 f8 ff ff       	jmp    80106410 <alltraps>

80106b79 <vector33>:
.globl vector33
vector33:
  pushl $0
80106b79:	6a 00                	push   $0x0
  pushl $33
80106b7b:	6a 21                	push   $0x21
  jmp alltraps
80106b7d:	e9 8e f8 ff ff       	jmp    80106410 <alltraps>

80106b82 <vector34>:
.globl vector34
vector34:
  pushl $0
80106b82:	6a 00                	push   $0x0
  pushl $34
80106b84:	6a 22                	push   $0x22
  jmp alltraps
80106b86:	e9 85 f8 ff ff       	jmp    80106410 <alltraps>

80106b8b <vector35>:
.globl vector35
vector35:
  pushl $0
80106b8b:	6a 00                	push   $0x0
  pushl $35
80106b8d:	6a 23                	push   $0x23
  jmp alltraps
80106b8f:	e9 7c f8 ff ff       	jmp    80106410 <alltraps>

80106b94 <vector36>:
.globl vector36
vector36:
  pushl $0
80106b94:	6a 00                	push   $0x0
  pushl $36
80106b96:	6a 24                	push   $0x24
  jmp alltraps
80106b98:	e9 73 f8 ff ff       	jmp    80106410 <alltraps>

80106b9d <vector37>:
.globl vector37
vector37:
  pushl $0
80106b9d:	6a 00                	push   $0x0
  pushl $37
80106b9f:	6a 25                	push   $0x25
  jmp alltraps
80106ba1:	e9 6a f8 ff ff       	jmp    80106410 <alltraps>

80106ba6 <vector38>:
.globl vector38
vector38:
  pushl $0
80106ba6:	6a 00                	push   $0x0
  pushl $38
80106ba8:	6a 26                	push   $0x26
  jmp alltraps
80106baa:	e9 61 f8 ff ff       	jmp    80106410 <alltraps>

80106baf <vector39>:
.globl vector39
vector39:
  pushl $0
80106baf:	6a 00                	push   $0x0
  pushl $39
80106bb1:	6a 27                	push   $0x27
  jmp alltraps
80106bb3:	e9 58 f8 ff ff       	jmp    80106410 <alltraps>

80106bb8 <vector40>:
.globl vector40
vector40:
  pushl $0
80106bb8:	6a 00                	push   $0x0
  pushl $40
80106bba:	6a 28                	push   $0x28
  jmp alltraps
80106bbc:	e9 4f f8 ff ff       	jmp    80106410 <alltraps>

80106bc1 <vector41>:
.globl vector41
vector41:
  pushl $0
80106bc1:	6a 00                	push   $0x0
  pushl $41
80106bc3:	6a 29                	push   $0x29
  jmp alltraps
80106bc5:	e9 46 f8 ff ff       	jmp    80106410 <alltraps>

80106bca <vector42>:
.globl vector42
vector42:
  pushl $0
80106bca:	6a 00                	push   $0x0
  pushl $42
80106bcc:	6a 2a                	push   $0x2a
  jmp alltraps
80106bce:	e9 3d f8 ff ff       	jmp    80106410 <alltraps>

80106bd3 <vector43>:
.globl vector43
vector43:
  pushl $0
80106bd3:	6a 00                	push   $0x0
  pushl $43
80106bd5:	6a 2b                	push   $0x2b
  jmp alltraps
80106bd7:	e9 34 f8 ff ff       	jmp    80106410 <alltraps>

80106bdc <vector44>:
.globl vector44
vector44:
  pushl $0
80106bdc:	6a 00                	push   $0x0
  pushl $44
80106bde:	6a 2c                	push   $0x2c
  jmp alltraps
80106be0:	e9 2b f8 ff ff       	jmp    80106410 <alltraps>

80106be5 <vector45>:
.globl vector45
vector45:
  pushl $0
80106be5:	6a 00                	push   $0x0
  pushl $45
80106be7:	6a 2d                	push   $0x2d
  jmp alltraps
80106be9:	e9 22 f8 ff ff       	jmp    80106410 <alltraps>

80106bee <vector46>:
.globl vector46
vector46:
  pushl $0
80106bee:	6a 00                	push   $0x0
  pushl $46
80106bf0:	6a 2e                	push   $0x2e
  jmp alltraps
80106bf2:	e9 19 f8 ff ff       	jmp    80106410 <alltraps>

80106bf7 <vector47>:
.globl vector47
vector47:
  pushl $0
80106bf7:	6a 00                	push   $0x0
  pushl $47
80106bf9:	6a 2f                	push   $0x2f
  jmp alltraps
80106bfb:	e9 10 f8 ff ff       	jmp    80106410 <alltraps>

80106c00 <vector48>:
.globl vector48
vector48:
  pushl $0
80106c00:	6a 00                	push   $0x0
  pushl $48
80106c02:	6a 30                	push   $0x30
  jmp alltraps
80106c04:	e9 07 f8 ff ff       	jmp    80106410 <alltraps>

80106c09 <vector49>:
.globl vector49
vector49:
  pushl $0
80106c09:	6a 00                	push   $0x0
  pushl $49
80106c0b:	6a 31                	push   $0x31
  jmp alltraps
80106c0d:	e9 fe f7 ff ff       	jmp    80106410 <alltraps>

80106c12 <vector50>:
.globl vector50
vector50:
  pushl $0
80106c12:	6a 00                	push   $0x0
  pushl $50
80106c14:	6a 32                	push   $0x32
  jmp alltraps
80106c16:	e9 f5 f7 ff ff       	jmp    80106410 <alltraps>

80106c1b <vector51>:
.globl vector51
vector51:
  pushl $0
80106c1b:	6a 00                	push   $0x0
  pushl $51
80106c1d:	6a 33                	push   $0x33
  jmp alltraps
80106c1f:	e9 ec f7 ff ff       	jmp    80106410 <alltraps>

80106c24 <vector52>:
.globl vector52
vector52:
  pushl $0
80106c24:	6a 00                	push   $0x0
  pushl $52
80106c26:	6a 34                	push   $0x34
  jmp alltraps
80106c28:	e9 e3 f7 ff ff       	jmp    80106410 <alltraps>

80106c2d <vector53>:
.globl vector53
vector53:
  pushl $0
80106c2d:	6a 00                	push   $0x0
  pushl $53
80106c2f:	6a 35                	push   $0x35
  jmp alltraps
80106c31:	e9 da f7 ff ff       	jmp    80106410 <alltraps>

80106c36 <vector54>:
.globl vector54
vector54:
  pushl $0
80106c36:	6a 00                	push   $0x0
  pushl $54
80106c38:	6a 36                	push   $0x36
  jmp alltraps
80106c3a:	e9 d1 f7 ff ff       	jmp    80106410 <alltraps>

80106c3f <vector55>:
.globl vector55
vector55:
  pushl $0
80106c3f:	6a 00                	push   $0x0
  pushl $55
80106c41:	6a 37                	push   $0x37
  jmp alltraps
80106c43:	e9 c8 f7 ff ff       	jmp    80106410 <alltraps>

80106c48 <vector56>:
.globl vector56
vector56:
  pushl $0
80106c48:	6a 00                	push   $0x0
  pushl $56
80106c4a:	6a 38                	push   $0x38
  jmp alltraps
80106c4c:	e9 bf f7 ff ff       	jmp    80106410 <alltraps>

80106c51 <vector57>:
.globl vector57
vector57:
  pushl $0
80106c51:	6a 00                	push   $0x0
  pushl $57
80106c53:	6a 39                	push   $0x39
  jmp alltraps
80106c55:	e9 b6 f7 ff ff       	jmp    80106410 <alltraps>

80106c5a <vector58>:
.globl vector58
vector58:
  pushl $0
80106c5a:	6a 00                	push   $0x0
  pushl $58
80106c5c:	6a 3a                	push   $0x3a
  jmp alltraps
80106c5e:	e9 ad f7 ff ff       	jmp    80106410 <alltraps>

80106c63 <vector59>:
.globl vector59
vector59:
  pushl $0
80106c63:	6a 00                	push   $0x0
  pushl $59
80106c65:	6a 3b                	push   $0x3b
  jmp alltraps
80106c67:	e9 a4 f7 ff ff       	jmp    80106410 <alltraps>

80106c6c <vector60>:
.globl vector60
vector60:
  pushl $0
80106c6c:	6a 00                	push   $0x0
  pushl $60
80106c6e:	6a 3c                	push   $0x3c
  jmp alltraps
80106c70:	e9 9b f7 ff ff       	jmp    80106410 <alltraps>

80106c75 <vector61>:
.globl vector61
vector61:
  pushl $0
80106c75:	6a 00                	push   $0x0
  pushl $61
80106c77:	6a 3d                	push   $0x3d
  jmp alltraps
80106c79:	e9 92 f7 ff ff       	jmp    80106410 <alltraps>

80106c7e <vector62>:
.globl vector62
vector62:
  pushl $0
80106c7e:	6a 00                	push   $0x0
  pushl $62
80106c80:	6a 3e                	push   $0x3e
  jmp alltraps
80106c82:	e9 89 f7 ff ff       	jmp    80106410 <alltraps>

80106c87 <vector63>:
.globl vector63
vector63:
  pushl $0
80106c87:	6a 00                	push   $0x0
  pushl $63
80106c89:	6a 3f                	push   $0x3f
  jmp alltraps
80106c8b:	e9 80 f7 ff ff       	jmp    80106410 <alltraps>

80106c90 <vector64>:
.globl vector64
vector64:
  pushl $0
80106c90:	6a 00                	push   $0x0
  pushl $64
80106c92:	6a 40                	push   $0x40
  jmp alltraps
80106c94:	e9 77 f7 ff ff       	jmp    80106410 <alltraps>

80106c99 <vector65>:
.globl vector65
vector65:
  pushl $0
80106c99:	6a 00                	push   $0x0
  pushl $65
80106c9b:	6a 41                	push   $0x41
  jmp alltraps
80106c9d:	e9 6e f7 ff ff       	jmp    80106410 <alltraps>

80106ca2 <vector66>:
.globl vector66
vector66:
  pushl $0
80106ca2:	6a 00                	push   $0x0
  pushl $66
80106ca4:	6a 42                	push   $0x42
  jmp alltraps
80106ca6:	e9 65 f7 ff ff       	jmp    80106410 <alltraps>

80106cab <vector67>:
.globl vector67
vector67:
  pushl $0
80106cab:	6a 00                	push   $0x0
  pushl $67
80106cad:	6a 43                	push   $0x43
  jmp alltraps
80106caf:	e9 5c f7 ff ff       	jmp    80106410 <alltraps>

80106cb4 <vector68>:
.globl vector68
vector68:
  pushl $0
80106cb4:	6a 00                	push   $0x0
  pushl $68
80106cb6:	6a 44                	push   $0x44
  jmp alltraps
80106cb8:	e9 53 f7 ff ff       	jmp    80106410 <alltraps>

80106cbd <vector69>:
.globl vector69
vector69:
  pushl $0
80106cbd:	6a 00                	push   $0x0
  pushl $69
80106cbf:	6a 45                	push   $0x45
  jmp alltraps
80106cc1:	e9 4a f7 ff ff       	jmp    80106410 <alltraps>

80106cc6 <vector70>:
.globl vector70
vector70:
  pushl $0
80106cc6:	6a 00                	push   $0x0
  pushl $70
80106cc8:	6a 46                	push   $0x46
  jmp alltraps
80106cca:	e9 41 f7 ff ff       	jmp    80106410 <alltraps>

80106ccf <vector71>:
.globl vector71
vector71:
  pushl $0
80106ccf:	6a 00                	push   $0x0
  pushl $71
80106cd1:	6a 47                	push   $0x47
  jmp alltraps
80106cd3:	e9 38 f7 ff ff       	jmp    80106410 <alltraps>

80106cd8 <vector72>:
.globl vector72
vector72:
  pushl $0
80106cd8:	6a 00                	push   $0x0
  pushl $72
80106cda:	6a 48                	push   $0x48
  jmp alltraps
80106cdc:	e9 2f f7 ff ff       	jmp    80106410 <alltraps>

80106ce1 <vector73>:
.globl vector73
vector73:
  pushl $0
80106ce1:	6a 00                	push   $0x0
  pushl $73
80106ce3:	6a 49                	push   $0x49
  jmp alltraps
80106ce5:	e9 26 f7 ff ff       	jmp    80106410 <alltraps>

80106cea <vector74>:
.globl vector74
vector74:
  pushl $0
80106cea:	6a 00                	push   $0x0
  pushl $74
80106cec:	6a 4a                	push   $0x4a
  jmp alltraps
80106cee:	e9 1d f7 ff ff       	jmp    80106410 <alltraps>

80106cf3 <vector75>:
.globl vector75
vector75:
  pushl $0
80106cf3:	6a 00                	push   $0x0
  pushl $75
80106cf5:	6a 4b                	push   $0x4b
  jmp alltraps
80106cf7:	e9 14 f7 ff ff       	jmp    80106410 <alltraps>

80106cfc <vector76>:
.globl vector76
vector76:
  pushl $0
80106cfc:	6a 00                	push   $0x0
  pushl $76
80106cfe:	6a 4c                	push   $0x4c
  jmp alltraps
80106d00:	e9 0b f7 ff ff       	jmp    80106410 <alltraps>

80106d05 <vector77>:
.globl vector77
vector77:
  pushl $0
80106d05:	6a 00                	push   $0x0
  pushl $77
80106d07:	6a 4d                	push   $0x4d
  jmp alltraps
80106d09:	e9 02 f7 ff ff       	jmp    80106410 <alltraps>

80106d0e <vector78>:
.globl vector78
vector78:
  pushl $0
80106d0e:	6a 00                	push   $0x0
  pushl $78
80106d10:	6a 4e                	push   $0x4e
  jmp alltraps
80106d12:	e9 f9 f6 ff ff       	jmp    80106410 <alltraps>

80106d17 <vector79>:
.globl vector79
vector79:
  pushl $0
80106d17:	6a 00                	push   $0x0
  pushl $79
80106d19:	6a 4f                	push   $0x4f
  jmp alltraps
80106d1b:	e9 f0 f6 ff ff       	jmp    80106410 <alltraps>

80106d20 <vector80>:
.globl vector80
vector80:
  pushl $0
80106d20:	6a 00                	push   $0x0
  pushl $80
80106d22:	6a 50                	push   $0x50
  jmp alltraps
80106d24:	e9 e7 f6 ff ff       	jmp    80106410 <alltraps>

80106d29 <vector81>:
.globl vector81
vector81:
  pushl $0
80106d29:	6a 00                	push   $0x0
  pushl $81
80106d2b:	6a 51                	push   $0x51
  jmp alltraps
80106d2d:	e9 de f6 ff ff       	jmp    80106410 <alltraps>

80106d32 <vector82>:
.globl vector82
vector82:
  pushl $0
80106d32:	6a 00                	push   $0x0
  pushl $82
80106d34:	6a 52                	push   $0x52
  jmp alltraps
80106d36:	e9 d5 f6 ff ff       	jmp    80106410 <alltraps>

80106d3b <vector83>:
.globl vector83
vector83:
  pushl $0
80106d3b:	6a 00                	push   $0x0
  pushl $83
80106d3d:	6a 53                	push   $0x53
  jmp alltraps
80106d3f:	e9 cc f6 ff ff       	jmp    80106410 <alltraps>

80106d44 <vector84>:
.globl vector84
vector84:
  pushl $0
80106d44:	6a 00                	push   $0x0
  pushl $84
80106d46:	6a 54                	push   $0x54
  jmp alltraps
80106d48:	e9 c3 f6 ff ff       	jmp    80106410 <alltraps>

80106d4d <vector85>:
.globl vector85
vector85:
  pushl $0
80106d4d:	6a 00                	push   $0x0
  pushl $85
80106d4f:	6a 55                	push   $0x55
  jmp alltraps
80106d51:	e9 ba f6 ff ff       	jmp    80106410 <alltraps>

80106d56 <vector86>:
.globl vector86
vector86:
  pushl $0
80106d56:	6a 00                	push   $0x0
  pushl $86
80106d58:	6a 56                	push   $0x56
  jmp alltraps
80106d5a:	e9 b1 f6 ff ff       	jmp    80106410 <alltraps>

80106d5f <vector87>:
.globl vector87
vector87:
  pushl $0
80106d5f:	6a 00                	push   $0x0
  pushl $87
80106d61:	6a 57                	push   $0x57
  jmp alltraps
80106d63:	e9 a8 f6 ff ff       	jmp    80106410 <alltraps>

80106d68 <vector88>:
.globl vector88
vector88:
  pushl $0
80106d68:	6a 00                	push   $0x0
  pushl $88
80106d6a:	6a 58                	push   $0x58
  jmp alltraps
80106d6c:	e9 9f f6 ff ff       	jmp    80106410 <alltraps>

80106d71 <vector89>:
.globl vector89
vector89:
  pushl $0
80106d71:	6a 00                	push   $0x0
  pushl $89
80106d73:	6a 59                	push   $0x59
  jmp alltraps
80106d75:	e9 96 f6 ff ff       	jmp    80106410 <alltraps>

80106d7a <vector90>:
.globl vector90
vector90:
  pushl $0
80106d7a:	6a 00                	push   $0x0
  pushl $90
80106d7c:	6a 5a                	push   $0x5a
  jmp alltraps
80106d7e:	e9 8d f6 ff ff       	jmp    80106410 <alltraps>

80106d83 <vector91>:
.globl vector91
vector91:
  pushl $0
80106d83:	6a 00                	push   $0x0
  pushl $91
80106d85:	6a 5b                	push   $0x5b
  jmp alltraps
80106d87:	e9 84 f6 ff ff       	jmp    80106410 <alltraps>

80106d8c <vector92>:
.globl vector92
vector92:
  pushl $0
80106d8c:	6a 00                	push   $0x0
  pushl $92
80106d8e:	6a 5c                	push   $0x5c
  jmp alltraps
80106d90:	e9 7b f6 ff ff       	jmp    80106410 <alltraps>

80106d95 <vector93>:
.globl vector93
vector93:
  pushl $0
80106d95:	6a 00                	push   $0x0
  pushl $93
80106d97:	6a 5d                	push   $0x5d
  jmp alltraps
80106d99:	e9 72 f6 ff ff       	jmp    80106410 <alltraps>

80106d9e <vector94>:
.globl vector94
vector94:
  pushl $0
80106d9e:	6a 00                	push   $0x0
  pushl $94
80106da0:	6a 5e                	push   $0x5e
  jmp alltraps
80106da2:	e9 69 f6 ff ff       	jmp    80106410 <alltraps>

80106da7 <vector95>:
.globl vector95
vector95:
  pushl $0
80106da7:	6a 00                	push   $0x0
  pushl $95
80106da9:	6a 5f                	push   $0x5f
  jmp alltraps
80106dab:	e9 60 f6 ff ff       	jmp    80106410 <alltraps>

80106db0 <vector96>:
.globl vector96
vector96:
  pushl $0
80106db0:	6a 00                	push   $0x0
  pushl $96
80106db2:	6a 60                	push   $0x60
  jmp alltraps
80106db4:	e9 57 f6 ff ff       	jmp    80106410 <alltraps>

80106db9 <vector97>:
.globl vector97
vector97:
  pushl $0
80106db9:	6a 00                	push   $0x0
  pushl $97
80106dbb:	6a 61                	push   $0x61
  jmp alltraps
80106dbd:	e9 4e f6 ff ff       	jmp    80106410 <alltraps>

80106dc2 <vector98>:
.globl vector98
vector98:
  pushl $0
80106dc2:	6a 00                	push   $0x0
  pushl $98
80106dc4:	6a 62                	push   $0x62
  jmp alltraps
80106dc6:	e9 45 f6 ff ff       	jmp    80106410 <alltraps>

80106dcb <vector99>:
.globl vector99
vector99:
  pushl $0
80106dcb:	6a 00                	push   $0x0
  pushl $99
80106dcd:	6a 63                	push   $0x63
  jmp alltraps
80106dcf:	e9 3c f6 ff ff       	jmp    80106410 <alltraps>

80106dd4 <vector100>:
.globl vector100
vector100:
  pushl $0
80106dd4:	6a 00                	push   $0x0
  pushl $100
80106dd6:	6a 64                	push   $0x64
  jmp alltraps
80106dd8:	e9 33 f6 ff ff       	jmp    80106410 <alltraps>

80106ddd <vector101>:
.globl vector101
vector101:
  pushl $0
80106ddd:	6a 00                	push   $0x0
  pushl $101
80106ddf:	6a 65                	push   $0x65
  jmp alltraps
80106de1:	e9 2a f6 ff ff       	jmp    80106410 <alltraps>

80106de6 <vector102>:
.globl vector102
vector102:
  pushl $0
80106de6:	6a 00                	push   $0x0
  pushl $102
80106de8:	6a 66                	push   $0x66
  jmp alltraps
80106dea:	e9 21 f6 ff ff       	jmp    80106410 <alltraps>

80106def <vector103>:
.globl vector103
vector103:
  pushl $0
80106def:	6a 00                	push   $0x0
  pushl $103
80106df1:	6a 67                	push   $0x67
  jmp alltraps
80106df3:	e9 18 f6 ff ff       	jmp    80106410 <alltraps>

80106df8 <vector104>:
.globl vector104
vector104:
  pushl $0
80106df8:	6a 00                	push   $0x0
  pushl $104
80106dfa:	6a 68                	push   $0x68
  jmp alltraps
80106dfc:	e9 0f f6 ff ff       	jmp    80106410 <alltraps>

80106e01 <vector105>:
.globl vector105
vector105:
  pushl $0
80106e01:	6a 00                	push   $0x0
  pushl $105
80106e03:	6a 69                	push   $0x69
  jmp alltraps
80106e05:	e9 06 f6 ff ff       	jmp    80106410 <alltraps>

80106e0a <vector106>:
.globl vector106
vector106:
  pushl $0
80106e0a:	6a 00                	push   $0x0
  pushl $106
80106e0c:	6a 6a                	push   $0x6a
  jmp alltraps
80106e0e:	e9 fd f5 ff ff       	jmp    80106410 <alltraps>

80106e13 <vector107>:
.globl vector107
vector107:
  pushl $0
80106e13:	6a 00                	push   $0x0
  pushl $107
80106e15:	6a 6b                	push   $0x6b
  jmp alltraps
80106e17:	e9 f4 f5 ff ff       	jmp    80106410 <alltraps>

80106e1c <vector108>:
.globl vector108
vector108:
  pushl $0
80106e1c:	6a 00                	push   $0x0
  pushl $108
80106e1e:	6a 6c                	push   $0x6c
  jmp alltraps
80106e20:	e9 eb f5 ff ff       	jmp    80106410 <alltraps>

80106e25 <vector109>:
.globl vector109
vector109:
  pushl $0
80106e25:	6a 00                	push   $0x0
  pushl $109
80106e27:	6a 6d                	push   $0x6d
  jmp alltraps
80106e29:	e9 e2 f5 ff ff       	jmp    80106410 <alltraps>

80106e2e <vector110>:
.globl vector110
vector110:
  pushl $0
80106e2e:	6a 00                	push   $0x0
  pushl $110
80106e30:	6a 6e                	push   $0x6e
  jmp alltraps
80106e32:	e9 d9 f5 ff ff       	jmp    80106410 <alltraps>

80106e37 <vector111>:
.globl vector111
vector111:
  pushl $0
80106e37:	6a 00                	push   $0x0
  pushl $111
80106e39:	6a 6f                	push   $0x6f
  jmp alltraps
80106e3b:	e9 d0 f5 ff ff       	jmp    80106410 <alltraps>

80106e40 <vector112>:
.globl vector112
vector112:
  pushl $0
80106e40:	6a 00                	push   $0x0
  pushl $112
80106e42:	6a 70                	push   $0x70
  jmp alltraps
80106e44:	e9 c7 f5 ff ff       	jmp    80106410 <alltraps>

80106e49 <vector113>:
.globl vector113
vector113:
  pushl $0
80106e49:	6a 00                	push   $0x0
  pushl $113
80106e4b:	6a 71                	push   $0x71
  jmp alltraps
80106e4d:	e9 be f5 ff ff       	jmp    80106410 <alltraps>

80106e52 <vector114>:
.globl vector114
vector114:
  pushl $0
80106e52:	6a 00                	push   $0x0
  pushl $114
80106e54:	6a 72                	push   $0x72
  jmp alltraps
80106e56:	e9 b5 f5 ff ff       	jmp    80106410 <alltraps>

80106e5b <vector115>:
.globl vector115
vector115:
  pushl $0
80106e5b:	6a 00                	push   $0x0
  pushl $115
80106e5d:	6a 73                	push   $0x73
  jmp alltraps
80106e5f:	e9 ac f5 ff ff       	jmp    80106410 <alltraps>

80106e64 <vector116>:
.globl vector116
vector116:
  pushl $0
80106e64:	6a 00                	push   $0x0
  pushl $116
80106e66:	6a 74                	push   $0x74
  jmp alltraps
80106e68:	e9 a3 f5 ff ff       	jmp    80106410 <alltraps>

80106e6d <vector117>:
.globl vector117
vector117:
  pushl $0
80106e6d:	6a 00                	push   $0x0
  pushl $117
80106e6f:	6a 75                	push   $0x75
  jmp alltraps
80106e71:	e9 9a f5 ff ff       	jmp    80106410 <alltraps>

80106e76 <vector118>:
.globl vector118
vector118:
  pushl $0
80106e76:	6a 00                	push   $0x0
  pushl $118
80106e78:	6a 76                	push   $0x76
  jmp alltraps
80106e7a:	e9 91 f5 ff ff       	jmp    80106410 <alltraps>

80106e7f <vector119>:
.globl vector119
vector119:
  pushl $0
80106e7f:	6a 00                	push   $0x0
  pushl $119
80106e81:	6a 77                	push   $0x77
  jmp alltraps
80106e83:	e9 88 f5 ff ff       	jmp    80106410 <alltraps>

80106e88 <vector120>:
.globl vector120
vector120:
  pushl $0
80106e88:	6a 00                	push   $0x0
  pushl $120
80106e8a:	6a 78                	push   $0x78
  jmp alltraps
80106e8c:	e9 7f f5 ff ff       	jmp    80106410 <alltraps>

80106e91 <vector121>:
.globl vector121
vector121:
  pushl $0
80106e91:	6a 00                	push   $0x0
  pushl $121
80106e93:	6a 79                	push   $0x79
  jmp alltraps
80106e95:	e9 76 f5 ff ff       	jmp    80106410 <alltraps>

80106e9a <vector122>:
.globl vector122
vector122:
  pushl $0
80106e9a:	6a 00                	push   $0x0
  pushl $122
80106e9c:	6a 7a                	push   $0x7a
  jmp alltraps
80106e9e:	e9 6d f5 ff ff       	jmp    80106410 <alltraps>

80106ea3 <vector123>:
.globl vector123
vector123:
  pushl $0
80106ea3:	6a 00                	push   $0x0
  pushl $123
80106ea5:	6a 7b                	push   $0x7b
  jmp alltraps
80106ea7:	e9 64 f5 ff ff       	jmp    80106410 <alltraps>

80106eac <vector124>:
.globl vector124
vector124:
  pushl $0
80106eac:	6a 00                	push   $0x0
  pushl $124
80106eae:	6a 7c                	push   $0x7c
  jmp alltraps
80106eb0:	e9 5b f5 ff ff       	jmp    80106410 <alltraps>

80106eb5 <vector125>:
.globl vector125
vector125:
  pushl $0
80106eb5:	6a 00                	push   $0x0
  pushl $125
80106eb7:	6a 7d                	push   $0x7d
  jmp alltraps
80106eb9:	e9 52 f5 ff ff       	jmp    80106410 <alltraps>

80106ebe <vector126>:
.globl vector126
vector126:
  pushl $0
80106ebe:	6a 00                	push   $0x0
  pushl $126
80106ec0:	6a 7e                	push   $0x7e
  jmp alltraps
80106ec2:	e9 49 f5 ff ff       	jmp    80106410 <alltraps>

80106ec7 <vector127>:
.globl vector127
vector127:
  pushl $0
80106ec7:	6a 00                	push   $0x0
  pushl $127
80106ec9:	6a 7f                	push   $0x7f
  jmp alltraps
80106ecb:	e9 40 f5 ff ff       	jmp    80106410 <alltraps>

80106ed0 <vector128>:
.globl vector128
vector128:
  pushl $0
80106ed0:	6a 00                	push   $0x0
  pushl $128
80106ed2:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106ed7:	e9 34 f5 ff ff       	jmp    80106410 <alltraps>

80106edc <vector129>:
.globl vector129
vector129:
  pushl $0
80106edc:	6a 00                	push   $0x0
  pushl $129
80106ede:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106ee3:	e9 28 f5 ff ff       	jmp    80106410 <alltraps>

80106ee8 <vector130>:
.globl vector130
vector130:
  pushl $0
80106ee8:	6a 00                	push   $0x0
  pushl $130
80106eea:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106eef:	e9 1c f5 ff ff       	jmp    80106410 <alltraps>

80106ef4 <vector131>:
.globl vector131
vector131:
  pushl $0
80106ef4:	6a 00                	push   $0x0
  pushl $131
80106ef6:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106efb:	e9 10 f5 ff ff       	jmp    80106410 <alltraps>

80106f00 <vector132>:
.globl vector132
vector132:
  pushl $0
80106f00:	6a 00                	push   $0x0
  pushl $132
80106f02:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106f07:	e9 04 f5 ff ff       	jmp    80106410 <alltraps>

80106f0c <vector133>:
.globl vector133
vector133:
  pushl $0
80106f0c:	6a 00                	push   $0x0
  pushl $133
80106f0e:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106f13:	e9 f8 f4 ff ff       	jmp    80106410 <alltraps>

80106f18 <vector134>:
.globl vector134
vector134:
  pushl $0
80106f18:	6a 00                	push   $0x0
  pushl $134
80106f1a:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106f1f:	e9 ec f4 ff ff       	jmp    80106410 <alltraps>

80106f24 <vector135>:
.globl vector135
vector135:
  pushl $0
80106f24:	6a 00                	push   $0x0
  pushl $135
80106f26:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106f2b:	e9 e0 f4 ff ff       	jmp    80106410 <alltraps>

80106f30 <vector136>:
.globl vector136
vector136:
  pushl $0
80106f30:	6a 00                	push   $0x0
  pushl $136
80106f32:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106f37:	e9 d4 f4 ff ff       	jmp    80106410 <alltraps>

80106f3c <vector137>:
.globl vector137
vector137:
  pushl $0
80106f3c:	6a 00                	push   $0x0
  pushl $137
80106f3e:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106f43:	e9 c8 f4 ff ff       	jmp    80106410 <alltraps>

80106f48 <vector138>:
.globl vector138
vector138:
  pushl $0
80106f48:	6a 00                	push   $0x0
  pushl $138
80106f4a:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106f4f:	e9 bc f4 ff ff       	jmp    80106410 <alltraps>

80106f54 <vector139>:
.globl vector139
vector139:
  pushl $0
80106f54:	6a 00                	push   $0x0
  pushl $139
80106f56:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106f5b:	e9 b0 f4 ff ff       	jmp    80106410 <alltraps>

80106f60 <vector140>:
.globl vector140
vector140:
  pushl $0
80106f60:	6a 00                	push   $0x0
  pushl $140
80106f62:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106f67:	e9 a4 f4 ff ff       	jmp    80106410 <alltraps>

80106f6c <vector141>:
.globl vector141
vector141:
  pushl $0
80106f6c:	6a 00                	push   $0x0
  pushl $141
80106f6e:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106f73:	e9 98 f4 ff ff       	jmp    80106410 <alltraps>

80106f78 <vector142>:
.globl vector142
vector142:
  pushl $0
80106f78:	6a 00                	push   $0x0
  pushl $142
80106f7a:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106f7f:	e9 8c f4 ff ff       	jmp    80106410 <alltraps>

80106f84 <vector143>:
.globl vector143
vector143:
  pushl $0
80106f84:	6a 00                	push   $0x0
  pushl $143
80106f86:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106f8b:	e9 80 f4 ff ff       	jmp    80106410 <alltraps>

80106f90 <vector144>:
.globl vector144
vector144:
  pushl $0
80106f90:	6a 00                	push   $0x0
  pushl $144
80106f92:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106f97:	e9 74 f4 ff ff       	jmp    80106410 <alltraps>

80106f9c <vector145>:
.globl vector145
vector145:
  pushl $0
80106f9c:	6a 00                	push   $0x0
  pushl $145
80106f9e:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106fa3:	e9 68 f4 ff ff       	jmp    80106410 <alltraps>

80106fa8 <vector146>:
.globl vector146
vector146:
  pushl $0
80106fa8:	6a 00                	push   $0x0
  pushl $146
80106faa:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106faf:	e9 5c f4 ff ff       	jmp    80106410 <alltraps>

80106fb4 <vector147>:
.globl vector147
vector147:
  pushl $0
80106fb4:	6a 00                	push   $0x0
  pushl $147
80106fb6:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106fbb:	e9 50 f4 ff ff       	jmp    80106410 <alltraps>

80106fc0 <vector148>:
.globl vector148
vector148:
  pushl $0
80106fc0:	6a 00                	push   $0x0
  pushl $148
80106fc2:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106fc7:	e9 44 f4 ff ff       	jmp    80106410 <alltraps>

80106fcc <vector149>:
.globl vector149
vector149:
  pushl $0
80106fcc:	6a 00                	push   $0x0
  pushl $149
80106fce:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106fd3:	e9 38 f4 ff ff       	jmp    80106410 <alltraps>

80106fd8 <vector150>:
.globl vector150
vector150:
  pushl $0
80106fd8:	6a 00                	push   $0x0
  pushl $150
80106fda:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106fdf:	e9 2c f4 ff ff       	jmp    80106410 <alltraps>

80106fe4 <vector151>:
.globl vector151
vector151:
  pushl $0
80106fe4:	6a 00                	push   $0x0
  pushl $151
80106fe6:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106feb:	e9 20 f4 ff ff       	jmp    80106410 <alltraps>

80106ff0 <vector152>:
.globl vector152
vector152:
  pushl $0
80106ff0:	6a 00                	push   $0x0
  pushl $152
80106ff2:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106ff7:	e9 14 f4 ff ff       	jmp    80106410 <alltraps>

80106ffc <vector153>:
.globl vector153
vector153:
  pushl $0
80106ffc:	6a 00                	push   $0x0
  pushl $153
80106ffe:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107003:	e9 08 f4 ff ff       	jmp    80106410 <alltraps>

80107008 <vector154>:
.globl vector154
vector154:
  pushl $0
80107008:	6a 00                	push   $0x0
  pushl $154
8010700a:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
8010700f:	e9 fc f3 ff ff       	jmp    80106410 <alltraps>

80107014 <vector155>:
.globl vector155
vector155:
  pushl $0
80107014:	6a 00                	push   $0x0
  pushl $155
80107016:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
8010701b:	e9 f0 f3 ff ff       	jmp    80106410 <alltraps>

80107020 <vector156>:
.globl vector156
vector156:
  pushl $0
80107020:	6a 00                	push   $0x0
  pushl $156
80107022:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107027:	e9 e4 f3 ff ff       	jmp    80106410 <alltraps>

8010702c <vector157>:
.globl vector157
vector157:
  pushl $0
8010702c:	6a 00                	push   $0x0
  pushl $157
8010702e:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107033:	e9 d8 f3 ff ff       	jmp    80106410 <alltraps>

80107038 <vector158>:
.globl vector158
vector158:
  pushl $0
80107038:	6a 00                	push   $0x0
  pushl $158
8010703a:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010703f:	e9 cc f3 ff ff       	jmp    80106410 <alltraps>

80107044 <vector159>:
.globl vector159
vector159:
  pushl $0
80107044:	6a 00                	push   $0x0
  pushl $159
80107046:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
8010704b:	e9 c0 f3 ff ff       	jmp    80106410 <alltraps>

80107050 <vector160>:
.globl vector160
vector160:
  pushl $0
80107050:	6a 00                	push   $0x0
  pushl $160
80107052:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107057:	e9 b4 f3 ff ff       	jmp    80106410 <alltraps>

8010705c <vector161>:
.globl vector161
vector161:
  pushl $0
8010705c:	6a 00                	push   $0x0
  pushl $161
8010705e:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107063:	e9 a8 f3 ff ff       	jmp    80106410 <alltraps>

80107068 <vector162>:
.globl vector162
vector162:
  pushl $0
80107068:	6a 00                	push   $0x0
  pushl $162
8010706a:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
8010706f:	e9 9c f3 ff ff       	jmp    80106410 <alltraps>

80107074 <vector163>:
.globl vector163
vector163:
  pushl $0
80107074:	6a 00                	push   $0x0
  pushl $163
80107076:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
8010707b:	e9 90 f3 ff ff       	jmp    80106410 <alltraps>

80107080 <vector164>:
.globl vector164
vector164:
  pushl $0
80107080:	6a 00                	push   $0x0
  pushl $164
80107082:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107087:	e9 84 f3 ff ff       	jmp    80106410 <alltraps>

8010708c <vector165>:
.globl vector165
vector165:
  pushl $0
8010708c:	6a 00                	push   $0x0
  pushl $165
8010708e:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107093:	e9 78 f3 ff ff       	jmp    80106410 <alltraps>

80107098 <vector166>:
.globl vector166
vector166:
  pushl $0
80107098:	6a 00                	push   $0x0
  pushl $166
8010709a:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
8010709f:	e9 6c f3 ff ff       	jmp    80106410 <alltraps>

801070a4 <vector167>:
.globl vector167
vector167:
  pushl $0
801070a4:	6a 00                	push   $0x0
  pushl $167
801070a6:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801070ab:	e9 60 f3 ff ff       	jmp    80106410 <alltraps>

801070b0 <vector168>:
.globl vector168
vector168:
  pushl $0
801070b0:	6a 00                	push   $0x0
  pushl $168
801070b2:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801070b7:	e9 54 f3 ff ff       	jmp    80106410 <alltraps>

801070bc <vector169>:
.globl vector169
vector169:
  pushl $0
801070bc:	6a 00                	push   $0x0
  pushl $169
801070be:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801070c3:	e9 48 f3 ff ff       	jmp    80106410 <alltraps>

801070c8 <vector170>:
.globl vector170
vector170:
  pushl $0
801070c8:	6a 00                	push   $0x0
  pushl $170
801070ca:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801070cf:	e9 3c f3 ff ff       	jmp    80106410 <alltraps>

801070d4 <vector171>:
.globl vector171
vector171:
  pushl $0
801070d4:	6a 00                	push   $0x0
  pushl $171
801070d6:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801070db:	e9 30 f3 ff ff       	jmp    80106410 <alltraps>

801070e0 <vector172>:
.globl vector172
vector172:
  pushl $0
801070e0:	6a 00                	push   $0x0
  pushl $172
801070e2:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801070e7:	e9 24 f3 ff ff       	jmp    80106410 <alltraps>

801070ec <vector173>:
.globl vector173
vector173:
  pushl $0
801070ec:	6a 00                	push   $0x0
  pushl $173
801070ee:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801070f3:	e9 18 f3 ff ff       	jmp    80106410 <alltraps>

801070f8 <vector174>:
.globl vector174
vector174:
  pushl $0
801070f8:	6a 00                	push   $0x0
  pushl $174
801070fa:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801070ff:	e9 0c f3 ff ff       	jmp    80106410 <alltraps>

80107104 <vector175>:
.globl vector175
vector175:
  pushl $0
80107104:	6a 00                	push   $0x0
  pushl $175
80107106:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
8010710b:	e9 00 f3 ff ff       	jmp    80106410 <alltraps>

80107110 <vector176>:
.globl vector176
vector176:
  pushl $0
80107110:	6a 00                	push   $0x0
  pushl $176
80107112:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107117:	e9 f4 f2 ff ff       	jmp    80106410 <alltraps>

8010711c <vector177>:
.globl vector177
vector177:
  pushl $0
8010711c:	6a 00                	push   $0x0
  pushl $177
8010711e:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107123:	e9 e8 f2 ff ff       	jmp    80106410 <alltraps>

80107128 <vector178>:
.globl vector178
vector178:
  pushl $0
80107128:	6a 00                	push   $0x0
  pushl $178
8010712a:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010712f:	e9 dc f2 ff ff       	jmp    80106410 <alltraps>

80107134 <vector179>:
.globl vector179
vector179:
  pushl $0
80107134:	6a 00                	push   $0x0
  pushl $179
80107136:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
8010713b:	e9 d0 f2 ff ff       	jmp    80106410 <alltraps>

80107140 <vector180>:
.globl vector180
vector180:
  pushl $0
80107140:	6a 00                	push   $0x0
  pushl $180
80107142:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107147:	e9 c4 f2 ff ff       	jmp    80106410 <alltraps>

8010714c <vector181>:
.globl vector181
vector181:
  pushl $0
8010714c:	6a 00                	push   $0x0
  pushl $181
8010714e:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107153:	e9 b8 f2 ff ff       	jmp    80106410 <alltraps>

80107158 <vector182>:
.globl vector182
vector182:
  pushl $0
80107158:	6a 00                	push   $0x0
  pushl $182
8010715a:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
8010715f:	e9 ac f2 ff ff       	jmp    80106410 <alltraps>

80107164 <vector183>:
.globl vector183
vector183:
  pushl $0
80107164:	6a 00                	push   $0x0
  pushl $183
80107166:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
8010716b:	e9 a0 f2 ff ff       	jmp    80106410 <alltraps>

80107170 <vector184>:
.globl vector184
vector184:
  pushl $0
80107170:	6a 00                	push   $0x0
  pushl $184
80107172:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107177:	e9 94 f2 ff ff       	jmp    80106410 <alltraps>

8010717c <vector185>:
.globl vector185
vector185:
  pushl $0
8010717c:	6a 00                	push   $0x0
  pushl $185
8010717e:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107183:	e9 88 f2 ff ff       	jmp    80106410 <alltraps>

80107188 <vector186>:
.globl vector186
vector186:
  pushl $0
80107188:	6a 00                	push   $0x0
  pushl $186
8010718a:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010718f:	e9 7c f2 ff ff       	jmp    80106410 <alltraps>

80107194 <vector187>:
.globl vector187
vector187:
  pushl $0
80107194:	6a 00                	push   $0x0
  pushl $187
80107196:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
8010719b:	e9 70 f2 ff ff       	jmp    80106410 <alltraps>

801071a0 <vector188>:
.globl vector188
vector188:
  pushl $0
801071a0:	6a 00                	push   $0x0
  pushl $188
801071a2:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801071a7:	e9 64 f2 ff ff       	jmp    80106410 <alltraps>

801071ac <vector189>:
.globl vector189
vector189:
  pushl $0
801071ac:	6a 00                	push   $0x0
  pushl $189
801071ae:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801071b3:	e9 58 f2 ff ff       	jmp    80106410 <alltraps>

801071b8 <vector190>:
.globl vector190
vector190:
  pushl $0
801071b8:	6a 00                	push   $0x0
  pushl $190
801071ba:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801071bf:	e9 4c f2 ff ff       	jmp    80106410 <alltraps>

801071c4 <vector191>:
.globl vector191
vector191:
  pushl $0
801071c4:	6a 00                	push   $0x0
  pushl $191
801071c6:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801071cb:	e9 40 f2 ff ff       	jmp    80106410 <alltraps>

801071d0 <vector192>:
.globl vector192
vector192:
  pushl $0
801071d0:	6a 00                	push   $0x0
  pushl $192
801071d2:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801071d7:	e9 34 f2 ff ff       	jmp    80106410 <alltraps>

801071dc <vector193>:
.globl vector193
vector193:
  pushl $0
801071dc:	6a 00                	push   $0x0
  pushl $193
801071de:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801071e3:	e9 28 f2 ff ff       	jmp    80106410 <alltraps>

801071e8 <vector194>:
.globl vector194
vector194:
  pushl $0
801071e8:	6a 00                	push   $0x0
  pushl $194
801071ea:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801071ef:	e9 1c f2 ff ff       	jmp    80106410 <alltraps>

801071f4 <vector195>:
.globl vector195
vector195:
  pushl $0
801071f4:	6a 00                	push   $0x0
  pushl $195
801071f6:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801071fb:	e9 10 f2 ff ff       	jmp    80106410 <alltraps>

80107200 <vector196>:
.globl vector196
vector196:
  pushl $0
80107200:	6a 00                	push   $0x0
  pushl $196
80107202:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107207:	e9 04 f2 ff ff       	jmp    80106410 <alltraps>

8010720c <vector197>:
.globl vector197
vector197:
  pushl $0
8010720c:	6a 00                	push   $0x0
  pushl $197
8010720e:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107213:	e9 f8 f1 ff ff       	jmp    80106410 <alltraps>

80107218 <vector198>:
.globl vector198
vector198:
  pushl $0
80107218:	6a 00                	push   $0x0
  pushl $198
8010721a:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010721f:	e9 ec f1 ff ff       	jmp    80106410 <alltraps>

80107224 <vector199>:
.globl vector199
vector199:
  pushl $0
80107224:	6a 00                	push   $0x0
  pushl $199
80107226:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
8010722b:	e9 e0 f1 ff ff       	jmp    80106410 <alltraps>

80107230 <vector200>:
.globl vector200
vector200:
  pushl $0
80107230:	6a 00                	push   $0x0
  pushl $200
80107232:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107237:	e9 d4 f1 ff ff       	jmp    80106410 <alltraps>

8010723c <vector201>:
.globl vector201
vector201:
  pushl $0
8010723c:	6a 00                	push   $0x0
  pushl $201
8010723e:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107243:	e9 c8 f1 ff ff       	jmp    80106410 <alltraps>

80107248 <vector202>:
.globl vector202
vector202:
  pushl $0
80107248:	6a 00                	push   $0x0
  pushl $202
8010724a:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010724f:	e9 bc f1 ff ff       	jmp    80106410 <alltraps>

80107254 <vector203>:
.globl vector203
vector203:
  pushl $0
80107254:	6a 00                	push   $0x0
  pushl $203
80107256:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
8010725b:	e9 b0 f1 ff ff       	jmp    80106410 <alltraps>

80107260 <vector204>:
.globl vector204
vector204:
  pushl $0
80107260:	6a 00                	push   $0x0
  pushl $204
80107262:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107267:	e9 a4 f1 ff ff       	jmp    80106410 <alltraps>

8010726c <vector205>:
.globl vector205
vector205:
  pushl $0
8010726c:	6a 00                	push   $0x0
  pushl $205
8010726e:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107273:	e9 98 f1 ff ff       	jmp    80106410 <alltraps>

80107278 <vector206>:
.globl vector206
vector206:
  pushl $0
80107278:	6a 00                	push   $0x0
  pushl $206
8010727a:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
8010727f:	e9 8c f1 ff ff       	jmp    80106410 <alltraps>

80107284 <vector207>:
.globl vector207
vector207:
  pushl $0
80107284:	6a 00                	push   $0x0
  pushl $207
80107286:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
8010728b:	e9 80 f1 ff ff       	jmp    80106410 <alltraps>

80107290 <vector208>:
.globl vector208
vector208:
  pushl $0
80107290:	6a 00                	push   $0x0
  pushl $208
80107292:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107297:	e9 74 f1 ff ff       	jmp    80106410 <alltraps>

8010729c <vector209>:
.globl vector209
vector209:
  pushl $0
8010729c:	6a 00                	push   $0x0
  pushl $209
8010729e:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801072a3:	e9 68 f1 ff ff       	jmp    80106410 <alltraps>

801072a8 <vector210>:
.globl vector210
vector210:
  pushl $0
801072a8:	6a 00                	push   $0x0
  pushl $210
801072aa:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801072af:	e9 5c f1 ff ff       	jmp    80106410 <alltraps>

801072b4 <vector211>:
.globl vector211
vector211:
  pushl $0
801072b4:	6a 00                	push   $0x0
  pushl $211
801072b6:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801072bb:	e9 50 f1 ff ff       	jmp    80106410 <alltraps>

801072c0 <vector212>:
.globl vector212
vector212:
  pushl $0
801072c0:	6a 00                	push   $0x0
  pushl $212
801072c2:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801072c7:	e9 44 f1 ff ff       	jmp    80106410 <alltraps>

801072cc <vector213>:
.globl vector213
vector213:
  pushl $0
801072cc:	6a 00                	push   $0x0
  pushl $213
801072ce:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801072d3:	e9 38 f1 ff ff       	jmp    80106410 <alltraps>

801072d8 <vector214>:
.globl vector214
vector214:
  pushl $0
801072d8:	6a 00                	push   $0x0
  pushl $214
801072da:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801072df:	e9 2c f1 ff ff       	jmp    80106410 <alltraps>

801072e4 <vector215>:
.globl vector215
vector215:
  pushl $0
801072e4:	6a 00                	push   $0x0
  pushl $215
801072e6:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801072eb:	e9 20 f1 ff ff       	jmp    80106410 <alltraps>

801072f0 <vector216>:
.globl vector216
vector216:
  pushl $0
801072f0:	6a 00                	push   $0x0
  pushl $216
801072f2:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801072f7:	e9 14 f1 ff ff       	jmp    80106410 <alltraps>

801072fc <vector217>:
.globl vector217
vector217:
  pushl $0
801072fc:	6a 00                	push   $0x0
  pushl $217
801072fe:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107303:	e9 08 f1 ff ff       	jmp    80106410 <alltraps>

80107308 <vector218>:
.globl vector218
vector218:
  pushl $0
80107308:	6a 00                	push   $0x0
  pushl $218
8010730a:	68 da 00 00 00       	push   $0xda
  jmp alltraps
8010730f:	e9 fc f0 ff ff       	jmp    80106410 <alltraps>

80107314 <vector219>:
.globl vector219
vector219:
  pushl $0
80107314:	6a 00                	push   $0x0
  pushl $219
80107316:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
8010731b:	e9 f0 f0 ff ff       	jmp    80106410 <alltraps>

80107320 <vector220>:
.globl vector220
vector220:
  pushl $0
80107320:	6a 00                	push   $0x0
  pushl $220
80107322:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107327:	e9 e4 f0 ff ff       	jmp    80106410 <alltraps>

8010732c <vector221>:
.globl vector221
vector221:
  pushl $0
8010732c:	6a 00                	push   $0x0
  pushl $221
8010732e:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107333:	e9 d8 f0 ff ff       	jmp    80106410 <alltraps>

80107338 <vector222>:
.globl vector222
vector222:
  pushl $0
80107338:	6a 00                	push   $0x0
  pushl $222
8010733a:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010733f:	e9 cc f0 ff ff       	jmp    80106410 <alltraps>

80107344 <vector223>:
.globl vector223
vector223:
  pushl $0
80107344:	6a 00                	push   $0x0
  pushl $223
80107346:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
8010734b:	e9 c0 f0 ff ff       	jmp    80106410 <alltraps>

80107350 <vector224>:
.globl vector224
vector224:
  pushl $0
80107350:	6a 00                	push   $0x0
  pushl $224
80107352:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107357:	e9 b4 f0 ff ff       	jmp    80106410 <alltraps>

8010735c <vector225>:
.globl vector225
vector225:
  pushl $0
8010735c:	6a 00                	push   $0x0
  pushl $225
8010735e:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107363:	e9 a8 f0 ff ff       	jmp    80106410 <alltraps>

80107368 <vector226>:
.globl vector226
vector226:
  pushl $0
80107368:	6a 00                	push   $0x0
  pushl $226
8010736a:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
8010736f:	e9 9c f0 ff ff       	jmp    80106410 <alltraps>

80107374 <vector227>:
.globl vector227
vector227:
  pushl $0
80107374:	6a 00                	push   $0x0
  pushl $227
80107376:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
8010737b:	e9 90 f0 ff ff       	jmp    80106410 <alltraps>

80107380 <vector228>:
.globl vector228
vector228:
  pushl $0
80107380:	6a 00                	push   $0x0
  pushl $228
80107382:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107387:	e9 84 f0 ff ff       	jmp    80106410 <alltraps>

8010738c <vector229>:
.globl vector229
vector229:
  pushl $0
8010738c:	6a 00                	push   $0x0
  pushl $229
8010738e:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107393:	e9 78 f0 ff ff       	jmp    80106410 <alltraps>

80107398 <vector230>:
.globl vector230
vector230:
  pushl $0
80107398:	6a 00                	push   $0x0
  pushl $230
8010739a:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
8010739f:	e9 6c f0 ff ff       	jmp    80106410 <alltraps>

801073a4 <vector231>:
.globl vector231
vector231:
  pushl $0
801073a4:	6a 00                	push   $0x0
  pushl $231
801073a6:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801073ab:	e9 60 f0 ff ff       	jmp    80106410 <alltraps>

801073b0 <vector232>:
.globl vector232
vector232:
  pushl $0
801073b0:	6a 00                	push   $0x0
  pushl $232
801073b2:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801073b7:	e9 54 f0 ff ff       	jmp    80106410 <alltraps>

801073bc <vector233>:
.globl vector233
vector233:
  pushl $0
801073bc:	6a 00                	push   $0x0
  pushl $233
801073be:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801073c3:	e9 48 f0 ff ff       	jmp    80106410 <alltraps>

801073c8 <vector234>:
.globl vector234
vector234:
  pushl $0
801073c8:	6a 00                	push   $0x0
  pushl $234
801073ca:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801073cf:	e9 3c f0 ff ff       	jmp    80106410 <alltraps>

801073d4 <vector235>:
.globl vector235
vector235:
  pushl $0
801073d4:	6a 00                	push   $0x0
  pushl $235
801073d6:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801073db:	e9 30 f0 ff ff       	jmp    80106410 <alltraps>

801073e0 <vector236>:
.globl vector236
vector236:
  pushl $0
801073e0:	6a 00                	push   $0x0
  pushl $236
801073e2:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801073e7:	e9 24 f0 ff ff       	jmp    80106410 <alltraps>

801073ec <vector237>:
.globl vector237
vector237:
  pushl $0
801073ec:	6a 00                	push   $0x0
  pushl $237
801073ee:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801073f3:	e9 18 f0 ff ff       	jmp    80106410 <alltraps>

801073f8 <vector238>:
.globl vector238
vector238:
  pushl $0
801073f8:	6a 00                	push   $0x0
  pushl $238
801073fa:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801073ff:	e9 0c f0 ff ff       	jmp    80106410 <alltraps>

80107404 <vector239>:
.globl vector239
vector239:
  pushl $0
80107404:	6a 00                	push   $0x0
  pushl $239
80107406:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
8010740b:	e9 00 f0 ff ff       	jmp    80106410 <alltraps>

80107410 <vector240>:
.globl vector240
vector240:
  pushl $0
80107410:	6a 00                	push   $0x0
  pushl $240
80107412:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107417:	e9 f4 ef ff ff       	jmp    80106410 <alltraps>

8010741c <vector241>:
.globl vector241
vector241:
  pushl $0
8010741c:	6a 00                	push   $0x0
  pushl $241
8010741e:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107423:	e9 e8 ef ff ff       	jmp    80106410 <alltraps>

80107428 <vector242>:
.globl vector242
vector242:
  pushl $0
80107428:	6a 00                	push   $0x0
  pushl $242
8010742a:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010742f:	e9 dc ef ff ff       	jmp    80106410 <alltraps>

80107434 <vector243>:
.globl vector243
vector243:
  pushl $0
80107434:	6a 00                	push   $0x0
  pushl $243
80107436:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
8010743b:	e9 d0 ef ff ff       	jmp    80106410 <alltraps>

80107440 <vector244>:
.globl vector244
vector244:
  pushl $0
80107440:	6a 00                	push   $0x0
  pushl $244
80107442:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107447:	e9 c4 ef ff ff       	jmp    80106410 <alltraps>

8010744c <vector245>:
.globl vector245
vector245:
  pushl $0
8010744c:	6a 00                	push   $0x0
  pushl $245
8010744e:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107453:	e9 b8 ef ff ff       	jmp    80106410 <alltraps>

80107458 <vector246>:
.globl vector246
vector246:
  pushl $0
80107458:	6a 00                	push   $0x0
  pushl $246
8010745a:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
8010745f:	e9 ac ef ff ff       	jmp    80106410 <alltraps>

80107464 <vector247>:
.globl vector247
vector247:
  pushl $0
80107464:	6a 00                	push   $0x0
  pushl $247
80107466:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
8010746b:	e9 a0 ef ff ff       	jmp    80106410 <alltraps>

80107470 <vector248>:
.globl vector248
vector248:
  pushl $0
80107470:	6a 00                	push   $0x0
  pushl $248
80107472:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107477:	e9 94 ef ff ff       	jmp    80106410 <alltraps>

8010747c <vector249>:
.globl vector249
vector249:
  pushl $0
8010747c:	6a 00                	push   $0x0
  pushl $249
8010747e:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107483:	e9 88 ef ff ff       	jmp    80106410 <alltraps>

80107488 <vector250>:
.globl vector250
vector250:
  pushl $0
80107488:	6a 00                	push   $0x0
  pushl $250
8010748a:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
8010748f:	e9 7c ef ff ff       	jmp    80106410 <alltraps>

80107494 <vector251>:
.globl vector251
vector251:
  pushl $0
80107494:	6a 00                	push   $0x0
  pushl $251
80107496:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
8010749b:	e9 70 ef ff ff       	jmp    80106410 <alltraps>

801074a0 <vector252>:
.globl vector252
vector252:
  pushl $0
801074a0:	6a 00                	push   $0x0
  pushl $252
801074a2:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801074a7:	e9 64 ef ff ff       	jmp    80106410 <alltraps>

801074ac <vector253>:
.globl vector253
vector253:
  pushl $0
801074ac:	6a 00                	push   $0x0
  pushl $253
801074ae:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801074b3:	e9 58 ef ff ff       	jmp    80106410 <alltraps>

801074b8 <vector254>:
.globl vector254
vector254:
  pushl $0
801074b8:	6a 00                	push   $0x0
  pushl $254
801074ba:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801074bf:	e9 4c ef ff ff       	jmp    80106410 <alltraps>

801074c4 <vector255>:
.globl vector255
vector255:
  pushl $0
801074c4:	6a 00                	push   $0x0
  pushl $255
801074c6:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801074cb:	e9 40 ef ff ff       	jmp    80106410 <alltraps>

801074d0 <lgdt>:
{
801074d0:	55                   	push   %ebp
801074d1:	89 e5                	mov    %esp,%ebp
801074d3:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
801074d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801074d9:	83 e8 01             	sub    $0x1,%eax
801074dc:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801074e0:	8b 45 08             	mov    0x8(%ebp),%eax
801074e3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801074e7:	8b 45 08             	mov    0x8(%ebp),%eax
801074ea:	c1 e8 10             	shr    $0x10,%eax
801074ed:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
801074f1:	8d 45 fa             	lea    -0x6(%ebp),%eax
801074f4:	0f 01 10             	lgdtl  (%eax)
}
801074f7:	c9                   	leave  
801074f8:	c3                   	ret    

801074f9 <ltr>:
{
801074f9:	55                   	push   %ebp
801074fa:	89 e5                	mov    %esp,%ebp
801074fc:	83 ec 04             	sub    $0x4,%esp
801074ff:	8b 45 08             	mov    0x8(%ebp),%eax
80107502:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107506:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010750a:	0f 00 d8             	ltr    %ax
}
8010750d:	c9                   	leave  
8010750e:	c3                   	ret    

8010750f <lcr3>:

static inline void
lcr3(uint val)
{
8010750f:	55                   	push   %ebp
80107510:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107512:	8b 45 08             	mov    0x8(%ebp),%eax
80107515:	0f 22 d8             	mov    %eax,%cr3
}
80107518:	5d                   	pop    %ebp
80107519:	c3                   	ret    

8010751a <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
8010751a:	55                   	push   %ebp
8010751b:	89 e5                	mov    %esp,%ebp
8010751d:	83 ec 28             	sub    $0x28,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107520:	e8 a5 cb ff ff       	call   801040ca <cpuid>
80107525:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
8010752b:	05 00 38 11 80       	add    $0x80113800,%eax
80107530:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107533:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107536:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
8010753c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010753f:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107545:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107548:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
8010754c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010754f:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107553:	83 e2 f0             	and    $0xfffffff0,%edx
80107556:	83 ca 0a             	or     $0xa,%edx
80107559:	88 50 7d             	mov    %dl,0x7d(%eax)
8010755c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010755f:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107563:	83 ca 10             	or     $0x10,%edx
80107566:	88 50 7d             	mov    %dl,0x7d(%eax)
80107569:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010756c:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107570:	83 e2 9f             	and    $0xffffff9f,%edx
80107573:	88 50 7d             	mov    %dl,0x7d(%eax)
80107576:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107579:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010757d:	83 ca 80             	or     $0xffffff80,%edx
80107580:	88 50 7d             	mov    %dl,0x7d(%eax)
80107583:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107586:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010758a:	83 ca 0f             	or     $0xf,%edx
8010758d:	88 50 7e             	mov    %dl,0x7e(%eax)
80107590:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107593:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107597:	83 e2 ef             	and    $0xffffffef,%edx
8010759a:	88 50 7e             	mov    %dl,0x7e(%eax)
8010759d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075a0:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801075a4:	83 e2 df             	and    $0xffffffdf,%edx
801075a7:	88 50 7e             	mov    %dl,0x7e(%eax)
801075aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075ad:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801075b1:	83 ca 40             	or     $0x40,%edx
801075b4:	88 50 7e             	mov    %dl,0x7e(%eax)
801075b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075ba:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801075be:	83 ca 80             	or     $0xffffff80,%edx
801075c1:	88 50 7e             	mov    %dl,0x7e(%eax)
801075c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075c7:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801075cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075ce:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801075d5:	ff ff 
801075d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075da:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801075e1:	00 00 
801075e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075e6:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801075ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075f0:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801075f7:	83 e2 f0             	and    $0xfffffff0,%edx
801075fa:	83 ca 02             	or     $0x2,%edx
801075fd:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107603:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107606:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010760d:	83 ca 10             	or     $0x10,%edx
80107610:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107616:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107619:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107620:	83 e2 9f             	and    $0xffffff9f,%edx
80107623:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107629:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010762c:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107633:	83 ca 80             	or     $0xffffff80,%edx
80107636:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010763c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010763f:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107646:	83 ca 0f             	or     $0xf,%edx
80107649:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010764f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107652:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107659:	83 e2 ef             	and    $0xffffffef,%edx
8010765c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107662:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107665:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010766c:	83 e2 df             	and    $0xffffffdf,%edx
8010766f:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107675:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107678:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010767f:	83 ca 40             	or     $0x40,%edx
80107682:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107688:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010768b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107692:	83 ca 80             	or     $0xffffff80,%edx
80107695:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010769b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010769e:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801076a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076a8:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
801076af:	ff ff 
801076b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076b4:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
801076bb:	00 00 
801076bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076c0:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
801076c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076ca:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801076d1:	83 e2 f0             	and    $0xfffffff0,%edx
801076d4:	83 ca 0a             	or     $0xa,%edx
801076d7:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801076dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076e0:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801076e7:	83 ca 10             	or     $0x10,%edx
801076ea:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801076f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076f3:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801076fa:	83 ca 60             	or     $0x60,%edx
801076fd:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107703:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107706:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010770d:	83 ca 80             	or     $0xffffff80,%edx
80107710:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107716:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107719:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107720:	83 ca 0f             	or     $0xf,%edx
80107723:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107729:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010772c:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107733:	83 e2 ef             	and    $0xffffffef,%edx
80107736:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010773c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010773f:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107746:	83 e2 df             	and    $0xffffffdf,%edx
80107749:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010774f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107752:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107759:	83 ca 40             	or     $0x40,%edx
8010775c:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107762:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107765:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010776c:	83 ca 80             	or     $0xffffff80,%edx
8010776f:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107775:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107778:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
8010777f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107782:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107789:	ff ff 
8010778b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010778e:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107795:	00 00 
80107797:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010779a:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801077a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077a4:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801077ab:	83 e2 f0             	and    $0xfffffff0,%edx
801077ae:	83 ca 02             	or     $0x2,%edx
801077b1:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801077b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ba:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801077c1:	83 ca 10             	or     $0x10,%edx
801077c4:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801077ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077cd:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801077d4:	83 ca 60             	or     $0x60,%edx
801077d7:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801077dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077e0:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801077e7:	83 ca 80             	or     $0xffffff80,%edx
801077ea:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801077f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077f3:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801077fa:	83 ca 0f             	or     $0xf,%edx
801077fd:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107803:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107806:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010780d:	83 e2 ef             	and    $0xffffffef,%edx
80107810:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107816:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107819:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107820:	83 e2 df             	and    $0xffffffdf,%edx
80107823:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107829:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010782c:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107833:	83 ca 40             	or     $0x40,%edx
80107836:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010783c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010783f:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107846:	83 ca 80             	or     $0xffffff80,%edx
80107849:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010784f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107852:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107859:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010785c:	83 c0 70             	add    $0x70,%eax
8010785f:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
80107866:	00 
80107867:	89 04 24             	mov    %eax,(%esp)
8010786a:	e8 61 fc ff ff       	call   801074d0 <lgdt>
}
8010786f:	c9                   	leave  
80107870:	c3                   	ret    

80107871 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107871:	55                   	push   %ebp
80107872:	89 e5                	mov    %esp,%ebp
80107874:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107877:	8b 45 0c             	mov    0xc(%ebp),%eax
8010787a:	c1 e8 16             	shr    $0x16,%eax
8010787d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107884:	8b 45 08             	mov    0x8(%ebp),%eax
80107887:	01 d0                	add    %edx,%eax
80107889:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
8010788c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010788f:	8b 00                	mov    (%eax),%eax
80107891:	83 e0 01             	and    $0x1,%eax
80107894:	85 c0                	test   %eax,%eax
80107896:	74 14                	je     801078ac <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107898:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010789b:	8b 00                	mov    (%eax),%eax
8010789d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801078a2:	05 00 00 00 80       	add    $0x80000000,%eax
801078a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801078aa:	eb 48                	jmp    801078f4 <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801078ac:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801078b0:	74 0e                	je     801078c0 <walkpgdir+0x4f>
801078b2:	e8 f2 b2 ff ff       	call   80102ba9 <kalloc>
801078b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801078ba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801078be:	75 07                	jne    801078c7 <walkpgdir+0x56>
      return 0;
801078c0:	b8 00 00 00 00       	mov    $0x0,%eax
801078c5:	eb 44                	jmp    8010790b <walkpgdir+0x9a>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
801078c7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801078ce:	00 
801078cf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801078d6:	00 
801078d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078da:	89 04 24             	mov    %eax,(%esp)
801078dd:	e8 4e d7 ff ff       	call   80105030 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
801078e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078e5:	05 00 00 00 80       	add    $0x80000000,%eax
801078ea:	83 c8 07             	or     $0x7,%eax
801078ed:	89 c2                	mov    %eax,%edx
801078ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801078f2:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
801078f4:	8b 45 0c             	mov    0xc(%ebp),%eax
801078f7:	c1 e8 0c             	shr    $0xc,%eax
801078fa:	25 ff 03 00 00       	and    $0x3ff,%eax
801078ff:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107906:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107909:	01 d0                	add    %edx,%eax
}
8010790b:	c9                   	leave  
8010790c:	c3                   	ret    

8010790d <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
8010790d:	55                   	push   %ebp
8010790e:	89 e5                	mov    %esp,%ebp
80107910:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107913:	8b 45 0c             	mov    0xc(%ebp),%eax
80107916:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010791b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
8010791e:	8b 55 0c             	mov    0xc(%ebp),%edx
80107921:	8b 45 10             	mov    0x10(%ebp),%eax
80107924:	01 d0                	add    %edx,%eax
80107926:	83 e8 01             	sub    $0x1,%eax
80107929:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010792e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107931:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80107938:	00 
80107939:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010793c:	89 44 24 04          	mov    %eax,0x4(%esp)
80107940:	8b 45 08             	mov    0x8(%ebp),%eax
80107943:	89 04 24             	mov    %eax,(%esp)
80107946:	e8 26 ff ff ff       	call   80107871 <walkpgdir>
8010794b:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010794e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107952:	75 07                	jne    8010795b <mappages+0x4e>
      return -1;
80107954:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107959:	eb 48                	jmp    801079a3 <mappages+0x96>
    if(*pte & PTE_P)
8010795b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010795e:	8b 00                	mov    (%eax),%eax
80107960:	83 e0 01             	and    $0x1,%eax
80107963:	85 c0                	test   %eax,%eax
80107965:	74 0c                	je     80107973 <mappages+0x66>
      panic("remap");
80107967:	c7 04 24 94 88 10 80 	movl   $0x80108894,(%esp)
8010796e:	e8 ef 8b ff ff       	call   80100562 <panic>
    *pte = pa | perm | PTE_P;
80107973:	8b 45 18             	mov    0x18(%ebp),%eax
80107976:	0b 45 14             	or     0x14(%ebp),%eax
80107979:	83 c8 01             	or     $0x1,%eax
8010797c:	89 c2                	mov    %eax,%edx
8010797e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107981:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107983:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107986:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107989:	75 08                	jne    80107993 <mappages+0x86>
      break;
8010798b:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
8010798c:	b8 00 00 00 00       	mov    $0x0,%eax
80107991:	eb 10                	jmp    801079a3 <mappages+0x96>
    a += PGSIZE;
80107993:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
8010799a:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
801079a1:	eb 8e                	jmp    80107931 <mappages+0x24>
}
801079a3:	c9                   	leave  
801079a4:	c3                   	ret    

801079a5 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801079a5:	55                   	push   %ebp
801079a6:	89 e5                	mov    %esp,%ebp
801079a8:	53                   	push   %ebx
801079a9:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
801079ac:	e8 f8 b1 ff ff       	call   80102ba9 <kalloc>
801079b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801079b4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801079b8:	75 0a                	jne    801079c4 <setupkvm+0x1f>
    return 0;
801079ba:	b8 00 00 00 00       	mov    $0x0,%eax
801079bf:	e9 84 00 00 00       	jmp    80107a48 <setupkvm+0xa3>
  memset(pgdir, 0, PGSIZE);
801079c4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801079cb:	00 
801079cc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801079d3:	00 
801079d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801079d7:	89 04 24             	mov    %eax,(%esp)
801079da:	e8 51 d6 ff ff       	call   80105030 <memset>
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801079df:	c7 45 f4 80 b4 10 80 	movl   $0x8010b480,-0xc(%ebp)
801079e6:	eb 54                	jmp    80107a3c <setupkvm+0x97>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801079e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079eb:	8b 48 0c             	mov    0xc(%eax),%ecx
801079ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079f1:	8b 50 04             	mov    0x4(%eax),%edx
801079f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079f7:	8b 58 08             	mov    0x8(%eax),%ebx
801079fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079fd:	8b 40 04             	mov    0x4(%eax),%eax
80107a00:	29 c3                	sub    %eax,%ebx
80107a02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a05:	8b 00                	mov    (%eax),%eax
80107a07:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80107a0b:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107a0f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107a13:	89 44 24 04          	mov    %eax,0x4(%esp)
80107a17:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107a1a:	89 04 24             	mov    %eax,(%esp)
80107a1d:	e8 eb fe ff ff       	call   8010790d <mappages>
80107a22:	85 c0                	test   %eax,%eax
80107a24:	79 12                	jns    80107a38 <setupkvm+0x93>
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
80107a26:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107a29:	89 04 24             	mov    %eax,(%esp)
80107a2c:	e8 26 05 00 00       	call   80107f57 <freevm>
      return 0;
80107a31:	b8 00 00 00 00       	mov    $0x0,%eax
80107a36:	eb 10                	jmp    80107a48 <setupkvm+0xa3>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107a38:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107a3c:	81 7d f4 c0 b4 10 80 	cmpl   $0x8010b4c0,-0xc(%ebp)
80107a43:	72 a3                	jb     801079e8 <setupkvm+0x43>
    }
  return pgdir;
80107a45:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107a48:	83 c4 34             	add    $0x34,%esp
80107a4b:	5b                   	pop    %ebx
80107a4c:	5d                   	pop    %ebp
80107a4d:	c3                   	ret    

80107a4e <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107a4e:	55                   	push   %ebp
80107a4f:	89 e5                	mov    %esp,%ebp
80107a51:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107a54:	e8 4c ff ff ff       	call   801079a5 <setupkvm>
80107a59:	a3 24 65 11 80       	mov    %eax,0x80116524
  switchkvm();
80107a5e:	e8 02 00 00 00       	call   80107a65 <switchkvm>
}
80107a63:	c9                   	leave  
80107a64:	c3                   	ret    

80107a65 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107a65:	55                   	push   %ebp
80107a66:	89 e5                	mov    %esp,%ebp
80107a68:	83 ec 04             	sub    $0x4,%esp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107a6b:	a1 24 65 11 80       	mov    0x80116524,%eax
80107a70:	05 00 00 00 80       	add    $0x80000000,%eax
80107a75:	89 04 24             	mov    %eax,(%esp)
80107a78:	e8 92 fa ff ff       	call   8010750f <lcr3>
}
80107a7d:	c9                   	leave  
80107a7e:	c3                   	ret    

80107a7f <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107a7f:	55                   	push   %ebp
80107a80:	89 e5                	mov    %esp,%ebp
80107a82:	57                   	push   %edi
80107a83:	56                   	push   %esi
80107a84:	53                   	push   %ebx
80107a85:	83 ec 1c             	sub    $0x1c,%esp
  if(p == 0)
80107a88:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107a8c:	75 0c                	jne    80107a9a <switchuvm+0x1b>
    panic("switchuvm: no process");
80107a8e:	c7 04 24 9a 88 10 80 	movl   $0x8010889a,(%esp)
80107a95:	e8 c8 8a ff ff       	call   80100562 <panic>
  if(p->kstack == 0)
80107a9a:	8b 45 08             	mov    0x8(%ebp),%eax
80107a9d:	8b 40 08             	mov    0x8(%eax),%eax
80107aa0:	85 c0                	test   %eax,%eax
80107aa2:	75 0c                	jne    80107ab0 <switchuvm+0x31>
    panic("switchuvm: no kstack");
80107aa4:	c7 04 24 b0 88 10 80 	movl   $0x801088b0,(%esp)
80107aab:	e8 b2 8a ff ff       	call   80100562 <panic>
  if(p->pgdir == 0)
80107ab0:	8b 45 08             	mov    0x8(%ebp),%eax
80107ab3:	8b 40 04             	mov    0x4(%eax),%eax
80107ab6:	85 c0                	test   %eax,%eax
80107ab8:	75 0c                	jne    80107ac6 <switchuvm+0x47>
    panic("switchuvm: no pgdir");
80107aba:	c7 04 24 c5 88 10 80 	movl   $0x801088c5,(%esp)
80107ac1:	e8 9c 8a ff ff       	call   80100562 <panic>

  pushcli();
80107ac6:	e8 60 d4 ff ff       	call   80104f2b <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107acb:	e8 1b c6 ff ff       	call   801040eb <mycpu>
80107ad0:	89 c3                	mov    %eax,%ebx
80107ad2:	e8 14 c6 ff ff       	call   801040eb <mycpu>
80107ad7:	83 c0 08             	add    $0x8,%eax
80107ada:	89 c7                	mov    %eax,%edi
80107adc:	e8 0a c6 ff ff       	call   801040eb <mycpu>
80107ae1:	83 c0 08             	add    $0x8,%eax
80107ae4:	c1 e8 10             	shr    $0x10,%eax
80107ae7:	89 c6                	mov    %eax,%esi
80107ae9:	e8 fd c5 ff ff       	call   801040eb <mycpu>
80107aee:	83 c0 08             	add    $0x8,%eax
80107af1:	c1 e8 18             	shr    $0x18,%eax
80107af4:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107afb:	67 00 
80107afd:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
80107b04:	89 f1                	mov    %esi,%ecx
80107b06:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80107b0c:	0f b6 93 9d 00 00 00 	movzbl 0x9d(%ebx),%edx
80107b13:	83 e2 f0             	and    $0xfffffff0,%edx
80107b16:	83 ca 09             	or     $0x9,%edx
80107b19:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80107b1f:	0f b6 93 9d 00 00 00 	movzbl 0x9d(%ebx),%edx
80107b26:	83 ca 10             	or     $0x10,%edx
80107b29:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80107b2f:	0f b6 93 9d 00 00 00 	movzbl 0x9d(%ebx),%edx
80107b36:	83 e2 9f             	and    $0xffffff9f,%edx
80107b39:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80107b3f:	0f b6 93 9d 00 00 00 	movzbl 0x9d(%ebx),%edx
80107b46:	83 ca 80             	or     $0xffffff80,%edx
80107b49:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80107b4f:	0f b6 93 9e 00 00 00 	movzbl 0x9e(%ebx),%edx
80107b56:	83 e2 f0             	and    $0xfffffff0,%edx
80107b59:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80107b5f:	0f b6 93 9e 00 00 00 	movzbl 0x9e(%ebx),%edx
80107b66:	83 e2 ef             	and    $0xffffffef,%edx
80107b69:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80107b6f:	0f b6 93 9e 00 00 00 	movzbl 0x9e(%ebx),%edx
80107b76:	83 e2 df             	and    $0xffffffdf,%edx
80107b79:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80107b7f:	0f b6 93 9e 00 00 00 	movzbl 0x9e(%ebx),%edx
80107b86:	83 ca 40             	or     $0x40,%edx
80107b89:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80107b8f:	0f b6 93 9e 00 00 00 	movzbl 0x9e(%ebx),%edx
80107b96:	83 e2 7f             	and    $0x7f,%edx
80107b99:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80107b9f:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107ba5:	e8 41 c5 ff ff       	call   801040eb <mycpu>
80107baa:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107bb1:	83 e2 ef             	and    $0xffffffef,%edx
80107bb4:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107bba:	e8 2c c5 ff ff       	call   801040eb <mycpu>
80107bbf:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107bc5:	e8 21 c5 ff ff       	call   801040eb <mycpu>
80107bca:	8b 55 08             	mov    0x8(%ebp),%edx
80107bcd:	8b 52 08             	mov    0x8(%edx),%edx
80107bd0:	81 c2 00 10 00 00    	add    $0x1000,%edx
80107bd6:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107bd9:	e8 0d c5 ff ff       	call   801040eb <mycpu>
80107bde:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107be4:	c7 04 24 28 00 00 00 	movl   $0x28,(%esp)
80107beb:	e8 09 f9 ff ff       	call   801074f9 <ltr>
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107bf0:	8b 45 08             	mov    0x8(%ebp),%eax
80107bf3:	8b 40 04             	mov    0x4(%eax),%eax
80107bf6:	05 00 00 00 80       	add    $0x80000000,%eax
80107bfb:	89 04 24             	mov    %eax,(%esp)
80107bfe:	e8 0c f9 ff ff       	call   8010750f <lcr3>
  popcli();
80107c03:	e8 6f d3 ff ff       	call   80104f77 <popcli>
}
80107c08:	83 c4 1c             	add    $0x1c,%esp
80107c0b:	5b                   	pop    %ebx
80107c0c:	5e                   	pop    %esi
80107c0d:	5f                   	pop    %edi
80107c0e:	5d                   	pop    %ebp
80107c0f:	c3                   	ret    

80107c10 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107c10:	55                   	push   %ebp
80107c11:	89 e5                	mov    %esp,%ebp
80107c13:	83 ec 38             	sub    $0x38,%esp
  char *mem;

  if(sz >= PGSIZE)
80107c16:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107c1d:	76 0c                	jbe    80107c2b <inituvm+0x1b>
    panic("inituvm: more than a page");
80107c1f:	c7 04 24 d9 88 10 80 	movl   $0x801088d9,(%esp)
80107c26:	e8 37 89 ff ff       	call   80100562 <panic>
  mem = kalloc();
80107c2b:	e8 79 af ff ff       	call   80102ba9 <kalloc>
80107c30:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107c33:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107c3a:	00 
80107c3b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107c42:	00 
80107c43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c46:	89 04 24             	mov    %eax,(%esp)
80107c49:	e8 e2 d3 ff ff       	call   80105030 <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107c4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c51:	05 00 00 00 80       	add    $0x80000000,%eax
80107c56:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80107c5d:	00 
80107c5e:	89 44 24 0c          	mov    %eax,0xc(%esp)
80107c62:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107c69:	00 
80107c6a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107c71:	00 
80107c72:	8b 45 08             	mov    0x8(%ebp),%eax
80107c75:	89 04 24             	mov    %eax,(%esp)
80107c78:	e8 90 fc ff ff       	call   8010790d <mappages>
  memmove(mem, init, sz);
80107c7d:	8b 45 10             	mov    0x10(%ebp),%eax
80107c80:	89 44 24 08          	mov    %eax,0x8(%esp)
80107c84:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c87:	89 44 24 04          	mov    %eax,0x4(%esp)
80107c8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c8e:	89 04 24             	mov    %eax,(%esp)
80107c91:	e8 69 d4 ff ff       	call   801050ff <memmove>
}
80107c96:	c9                   	leave  
80107c97:	c3                   	ret    

80107c98 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107c98:	55                   	push   %ebp
80107c99:	89 e5                	mov    %esp,%ebp
80107c9b:	83 ec 28             	sub    $0x28,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107c9e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ca1:	25 ff 0f 00 00       	and    $0xfff,%eax
80107ca6:	85 c0                	test   %eax,%eax
80107ca8:	74 0c                	je     80107cb6 <loaduvm+0x1e>
    panic("loaduvm: addr must be page aligned");
80107caa:	c7 04 24 f4 88 10 80 	movl   $0x801088f4,(%esp)
80107cb1:	e8 ac 88 ff ff       	call   80100562 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107cb6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107cbd:	e9 a6 00 00 00       	jmp    80107d68 <loaduvm+0xd0>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107cc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc5:	8b 55 0c             	mov    0xc(%ebp),%edx
80107cc8:	01 d0                	add    %edx,%eax
80107cca:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80107cd1:	00 
80107cd2:	89 44 24 04          	mov    %eax,0x4(%esp)
80107cd6:	8b 45 08             	mov    0x8(%ebp),%eax
80107cd9:	89 04 24             	mov    %eax,(%esp)
80107cdc:	e8 90 fb ff ff       	call   80107871 <walkpgdir>
80107ce1:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107ce4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107ce8:	75 0c                	jne    80107cf6 <loaduvm+0x5e>
      panic("loaduvm: address should exist");
80107cea:	c7 04 24 17 89 10 80 	movl   $0x80108917,(%esp)
80107cf1:	e8 6c 88 ff ff       	call   80100562 <panic>
    pa = PTE_ADDR(*pte);
80107cf6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107cf9:	8b 00                	mov    (%eax),%eax
80107cfb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d00:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107d03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d06:	8b 55 18             	mov    0x18(%ebp),%edx
80107d09:	29 c2                	sub    %eax,%edx
80107d0b:	89 d0                	mov    %edx,%eax
80107d0d:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107d12:	77 0f                	ja     80107d23 <loaduvm+0x8b>
      n = sz - i;
80107d14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d17:	8b 55 18             	mov    0x18(%ebp),%edx
80107d1a:	29 c2                	sub    %eax,%edx
80107d1c:	89 d0                	mov    %edx,%eax
80107d1e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107d21:	eb 07                	jmp    80107d2a <loaduvm+0x92>
    else
      n = PGSIZE;
80107d23:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107d2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d2d:	8b 55 14             	mov    0x14(%ebp),%edx
80107d30:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80107d33:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107d36:	05 00 00 00 80       	add    $0x80000000,%eax
80107d3b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107d3e:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107d42:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80107d46:	89 44 24 04          	mov    %eax,0x4(%esp)
80107d4a:	8b 45 10             	mov    0x10(%ebp),%eax
80107d4d:	89 04 24             	mov    %eax,(%esp)
80107d50:	e8 a5 a0 ff ff       	call   80101dfa <readi>
80107d55:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107d58:	74 07                	je     80107d61 <loaduvm+0xc9>
      return -1;
80107d5a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d5f:	eb 18                	jmp    80107d79 <loaduvm+0xe1>
  for(i = 0; i < sz; i += PGSIZE){
80107d61:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107d68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d6b:	3b 45 18             	cmp    0x18(%ebp),%eax
80107d6e:	0f 82 4e ff ff ff    	jb     80107cc2 <loaduvm+0x2a>
  }
  return 0;
80107d74:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107d79:	c9                   	leave  
80107d7a:	c3                   	ret    

80107d7b <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107d7b:	55                   	push   %ebp
80107d7c:	89 e5                	mov    %esp,%ebp
80107d7e:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107d81:	8b 45 10             	mov    0x10(%ebp),%eax
80107d84:	85 c0                	test   %eax,%eax
80107d86:	79 0a                	jns    80107d92 <allocuvm+0x17>
    return 0;
80107d88:	b8 00 00 00 00       	mov    $0x0,%eax
80107d8d:	e9 fd 00 00 00       	jmp    80107e8f <allocuvm+0x114>
  if(newsz < oldsz)
80107d92:	8b 45 10             	mov    0x10(%ebp),%eax
80107d95:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107d98:	73 08                	jae    80107da2 <allocuvm+0x27>
    return oldsz;
80107d9a:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d9d:	e9 ed 00 00 00       	jmp    80107e8f <allocuvm+0x114>

  a = PGROUNDUP(oldsz);
80107da2:	8b 45 0c             	mov    0xc(%ebp),%eax
80107da5:	05 ff 0f 00 00       	add    $0xfff,%eax
80107daa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107daf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107db2:	e9 c9 00 00 00       	jmp    80107e80 <allocuvm+0x105>
    mem = kalloc();
80107db7:	e8 ed ad ff ff       	call   80102ba9 <kalloc>
80107dbc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107dbf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107dc3:	75 2f                	jne    80107df4 <allocuvm+0x79>
      cprintf("allocuvm out of memory\n");
80107dc5:	c7 04 24 35 89 10 80 	movl   $0x80108935,(%esp)
80107dcc:	e8 f7 85 ff ff       	call   801003c8 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80107dd1:	8b 45 0c             	mov    0xc(%ebp),%eax
80107dd4:	89 44 24 08          	mov    %eax,0x8(%esp)
80107dd8:	8b 45 10             	mov    0x10(%ebp),%eax
80107ddb:	89 44 24 04          	mov    %eax,0x4(%esp)
80107ddf:	8b 45 08             	mov    0x8(%ebp),%eax
80107de2:	89 04 24             	mov    %eax,(%esp)
80107de5:	e8 a7 00 00 00       	call   80107e91 <deallocuvm>
      return 0;
80107dea:	b8 00 00 00 00       	mov    $0x0,%eax
80107def:	e9 9b 00 00 00       	jmp    80107e8f <allocuvm+0x114>
    }
    memset(mem, 0, PGSIZE);
80107df4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107dfb:	00 
80107dfc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107e03:	00 
80107e04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e07:	89 04 24             	mov    %eax,(%esp)
80107e0a:	e8 21 d2 ff ff       	call   80105030 <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107e0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e12:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107e18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e1b:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80107e22:	00 
80107e23:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107e27:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107e2e:	00 
80107e2f:	89 44 24 04          	mov    %eax,0x4(%esp)
80107e33:	8b 45 08             	mov    0x8(%ebp),%eax
80107e36:	89 04 24             	mov    %eax,(%esp)
80107e39:	e8 cf fa ff ff       	call   8010790d <mappages>
80107e3e:	85 c0                	test   %eax,%eax
80107e40:	79 37                	jns    80107e79 <allocuvm+0xfe>
      cprintf("allocuvm out of memory (2)\n");
80107e42:	c7 04 24 4d 89 10 80 	movl   $0x8010894d,(%esp)
80107e49:	e8 7a 85 ff ff       	call   801003c8 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80107e4e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e51:	89 44 24 08          	mov    %eax,0x8(%esp)
80107e55:	8b 45 10             	mov    0x10(%ebp),%eax
80107e58:	89 44 24 04          	mov    %eax,0x4(%esp)
80107e5c:	8b 45 08             	mov    0x8(%ebp),%eax
80107e5f:	89 04 24             	mov    %eax,(%esp)
80107e62:	e8 2a 00 00 00       	call   80107e91 <deallocuvm>
      kfree(mem);
80107e67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e6a:	89 04 24             	mov    %eax,(%esp)
80107e6d:	e8 a1 ac ff ff       	call   80102b13 <kfree>
      return 0;
80107e72:	b8 00 00 00 00       	mov    $0x0,%eax
80107e77:	eb 16                	jmp    80107e8f <allocuvm+0x114>
  for(; a < newsz; a += PGSIZE){
80107e79:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107e80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e83:	3b 45 10             	cmp    0x10(%ebp),%eax
80107e86:	0f 82 2b ff ff ff    	jb     80107db7 <allocuvm+0x3c>
    }
  }
  return newsz;
80107e8c:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107e8f:	c9                   	leave  
80107e90:	c3                   	ret    

80107e91 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107e91:	55                   	push   %ebp
80107e92:	89 e5                	mov    %esp,%ebp
80107e94:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107e97:	8b 45 10             	mov    0x10(%ebp),%eax
80107e9a:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107e9d:	72 08                	jb     80107ea7 <deallocuvm+0x16>
    return oldsz;
80107e9f:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ea2:	e9 ae 00 00 00       	jmp    80107f55 <deallocuvm+0xc4>

  a = PGROUNDUP(newsz);
80107ea7:	8b 45 10             	mov    0x10(%ebp),%eax
80107eaa:	05 ff 0f 00 00       	add    $0xfff,%eax
80107eaf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107eb4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107eb7:	e9 8a 00 00 00       	jmp    80107f46 <deallocuvm+0xb5>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107ebc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ebf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80107ec6:	00 
80107ec7:	89 44 24 04          	mov    %eax,0x4(%esp)
80107ecb:	8b 45 08             	mov    0x8(%ebp),%eax
80107ece:	89 04 24             	mov    %eax,(%esp)
80107ed1:	e8 9b f9 ff ff       	call   80107871 <walkpgdir>
80107ed6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107ed9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107edd:	75 16                	jne    80107ef5 <deallocuvm+0x64>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107edf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ee2:	c1 e8 16             	shr    $0x16,%eax
80107ee5:	83 c0 01             	add    $0x1,%eax
80107ee8:	c1 e0 16             	shl    $0x16,%eax
80107eeb:	2d 00 10 00 00       	sub    $0x1000,%eax
80107ef0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107ef3:	eb 4a                	jmp    80107f3f <deallocuvm+0xae>
    else if((*pte & PTE_P) != 0){
80107ef5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ef8:	8b 00                	mov    (%eax),%eax
80107efa:	83 e0 01             	and    $0x1,%eax
80107efd:	85 c0                	test   %eax,%eax
80107eff:	74 3e                	je     80107f3f <deallocuvm+0xae>
      pa = PTE_ADDR(*pte);
80107f01:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f04:	8b 00                	mov    (%eax),%eax
80107f06:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f0b:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107f0e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107f12:	75 0c                	jne    80107f20 <deallocuvm+0x8f>
        panic("kfree");
80107f14:	c7 04 24 69 89 10 80 	movl   $0x80108969,(%esp)
80107f1b:	e8 42 86 ff ff       	call   80100562 <panic>
      char *v = P2V(pa);
80107f20:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f23:	05 00 00 00 80       	add    $0x80000000,%eax
80107f28:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107f2b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107f2e:	89 04 24             	mov    %eax,(%esp)
80107f31:	e8 dd ab ff ff       	call   80102b13 <kfree>
      *pte = 0;
80107f36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f39:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107f3f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107f46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f49:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107f4c:	0f 82 6a ff ff ff    	jb     80107ebc <deallocuvm+0x2b>
    }
  }
  return newsz;
80107f52:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107f55:	c9                   	leave  
80107f56:	c3                   	ret    

80107f57 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107f57:	55                   	push   %ebp
80107f58:	89 e5                	mov    %esp,%ebp
80107f5a:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80107f5d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107f61:	75 0c                	jne    80107f6f <freevm+0x18>
    panic("freevm: no pgdir");
80107f63:	c7 04 24 6f 89 10 80 	movl   $0x8010896f,(%esp)
80107f6a:	e8 f3 85 ff ff       	call   80100562 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107f6f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80107f76:	00 
80107f77:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80107f7e:	80 
80107f7f:	8b 45 08             	mov    0x8(%ebp),%eax
80107f82:	89 04 24             	mov    %eax,(%esp)
80107f85:	e8 07 ff ff ff       	call   80107e91 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80107f8a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107f91:	eb 45                	jmp    80107fd8 <freevm+0x81>
    if(pgdir[i] & PTE_P){
80107f93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f96:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107f9d:	8b 45 08             	mov    0x8(%ebp),%eax
80107fa0:	01 d0                	add    %edx,%eax
80107fa2:	8b 00                	mov    (%eax),%eax
80107fa4:	83 e0 01             	and    $0x1,%eax
80107fa7:	85 c0                	test   %eax,%eax
80107fa9:	74 29                	je     80107fd4 <freevm+0x7d>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107fab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fae:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107fb5:	8b 45 08             	mov    0x8(%ebp),%eax
80107fb8:	01 d0                	add    %edx,%eax
80107fba:	8b 00                	mov    (%eax),%eax
80107fbc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fc1:	05 00 00 00 80       	add    $0x80000000,%eax
80107fc6:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107fc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fcc:	89 04 24             	mov    %eax,(%esp)
80107fcf:	e8 3f ab ff ff       	call   80102b13 <kfree>
  for(i = 0; i < NPDENTRIES; i++){
80107fd4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107fd8:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107fdf:	76 b2                	jbe    80107f93 <freevm+0x3c>
    }
  }
  kfree((char*)pgdir);
80107fe1:	8b 45 08             	mov    0x8(%ebp),%eax
80107fe4:	89 04 24             	mov    %eax,(%esp)
80107fe7:	e8 27 ab ff ff       	call   80102b13 <kfree>
}
80107fec:	c9                   	leave  
80107fed:	c3                   	ret    

80107fee <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107fee:	55                   	push   %ebp
80107fef:	89 e5                	mov    %esp,%ebp
80107ff1:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107ff4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80107ffb:	00 
80107ffc:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fff:	89 44 24 04          	mov    %eax,0x4(%esp)
80108003:	8b 45 08             	mov    0x8(%ebp),%eax
80108006:	89 04 24             	mov    %eax,(%esp)
80108009:	e8 63 f8 ff ff       	call   80107871 <walkpgdir>
8010800e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108011:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108015:	75 0c                	jne    80108023 <clearpteu+0x35>
    panic("clearpteu");
80108017:	c7 04 24 80 89 10 80 	movl   $0x80108980,(%esp)
8010801e:	e8 3f 85 ff ff       	call   80100562 <panic>
  *pte &= ~PTE_U;
80108023:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108026:	8b 00                	mov    (%eax),%eax
80108028:	83 e0 fb             	and    $0xfffffffb,%eax
8010802b:	89 c2                	mov    %eax,%edx
8010802d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108030:	89 10                	mov    %edx,(%eax)
}
80108032:	c9                   	leave  
80108033:	c3                   	ret    

80108034 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108034:	55                   	push   %ebp
80108035:	89 e5                	mov    %esp,%ebp
80108037:	83 ec 48             	sub    $0x48,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
8010803a:	e8 66 f9 ff ff       	call   801079a5 <setupkvm>
8010803f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108042:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108046:	75 0a                	jne    80108052 <copyuvm+0x1e>
    return 0;
80108048:	b8 00 00 00 00       	mov    $0x0,%eax
8010804d:	e9 03 01 00 00       	jmp    80108155 <copyuvm+0x121>
  for(i = 0; i < sz; i += PGSIZE){
80108052:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108059:	e9 d6 00 00 00       	jmp    80108134 <copyuvm+0x100>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
8010805e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108061:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108068:	00 
80108069:	89 44 24 04          	mov    %eax,0x4(%esp)
8010806d:	8b 45 08             	mov    0x8(%ebp),%eax
80108070:	89 04 24             	mov    %eax,(%esp)
80108073:	e8 f9 f7 ff ff       	call   80107871 <walkpgdir>
80108078:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010807b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010807f:	75 0c                	jne    8010808d <copyuvm+0x59>
      panic("copyuvm: pte should exist");
80108081:	c7 04 24 8a 89 10 80 	movl   $0x8010898a,(%esp)
80108088:	e8 d5 84 ff ff       	call   80100562 <panic>
    if(!(*pte & PTE_P))
8010808d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108090:	8b 00                	mov    (%eax),%eax
80108092:	83 e0 01             	and    $0x1,%eax
80108095:	85 c0                	test   %eax,%eax
80108097:	75 0c                	jne    801080a5 <copyuvm+0x71>
      panic("copyuvm: page not present");
80108099:	c7 04 24 a4 89 10 80 	movl   $0x801089a4,(%esp)
801080a0:	e8 bd 84 ff ff       	call   80100562 <panic>
    pa = PTE_ADDR(*pte);
801080a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080a8:	8b 00                	mov    (%eax),%eax
801080aa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080af:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801080b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080b5:	8b 00                	mov    (%eax),%eax
801080b7:	25 ff 0f 00 00       	and    $0xfff,%eax
801080bc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801080bf:	e8 e5 aa ff ff       	call   80102ba9 <kalloc>
801080c4:	89 45 e0             	mov    %eax,-0x20(%ebp)
801080c7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801080cb:	75 02                	jne    801080cf <copyuvm+0x9b>
      goto bad;
801080cd:	eb 76                	jmp    80108145 <copyuvm+0x111>
    memmove(mem, (char*)P2V(pa), PGSIZE);
801080cf:	8b 45 e8             	mov    -0x18(%ebp),%eax
801080d2:	05 00 00 00 80       	add    $0x80000000,%eax
801080d7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801080de:	00 
801080df:	89 44 24 04          	mov    %eax,0x4(%esp)
801080e3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801080e6:	89 04 24             	mov    %eax,(%esp)
801080e9:	e8 11 d0 ff ff       	call   801050ff <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
801080ee:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801080f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801080f4:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
801080fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080fd:	89 54 24 10          	mov    %edx,0x10(%esp)
80108101:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80108105:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010810c:	00 
8010810d:	89 44 24 04          	mov    %eax,0x4(%esp)
80108111:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108114:	89 04 24             	mov    %eax,(%esp)
80108117:	e8 f1 f7 ff ff       	call   8010790d <mappages>
8010811c:	85 c0                	test   %eax,%eax
8010811e:	79 0d                	jns    8010812d <copyuvm+0xf9>
      kfree(mem);
80108120:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108123:	89 04 24             	mov    %eax,(%esp)
80108126:	e8 e8 a9 ff ff       	call   80102b13 <kfree>
      goto bad;
8010812b:	eb 18                	jmp    80108145 <copyuvm+0x111>
  for(i = 0; i < sz; i += PGSIZE){
8010812d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108134:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108137:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010813a:	0f 82 1e ff ff ff    	jb     8010805e <copyuvm+0x2a>
    }
  }
  return d;
80108140:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108143:	eb 10                	jmp    80108155 <copyuvm+0x121>

bad:
  freevm(d);
80108145:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108148:	89 04 24             	mov    %eax,(%esp)
8010814b:	e8 07 fe ff ff       	call   80107f57 <freevm>
  return 0;
80108150:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108155:	c9                   	leave  
80108156:	c3                   	ret    

80108157 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108157:	55                   	push   %ebp
80108158:	89 e5                	mov    %esp,%ebp
8010815a:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010815d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108164:	00 
80108165:	8b 45 0c             	mov    0xc(%ebp),%eax
80108168:	89 44 24 04          	mov    %eax,0x4(%esp)
8010816c:	8b 45 08             	mov    0x8(%ebp),%eax
8010816f:	89 04 24             	mov    %eax,(%esp)
80108172:	e8 fa f6 ff ff       	call   80107871 <walkpgdir>
80108177:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
8010817a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010817d:	8b 00                	mov    (%eax),%eax
8010817f:	83 e0 01             	and    $0x1,%eax
80108182:	85 c0                	test   %eax,%eax
80108184:	75 07                	jne    8010818d <uva2ka+0x36>
    return 0;
80108186:	b8 00 00 00 00       	mov    $0x0,%eax
8010818b:	eb 22                	jmp    801081af <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
8010818d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108190:	8b 00                	mov    (%eax),%eax
80108192:	83 e0 04             	and    $0x4,%eax
80108195:	85 c0                	test   %eax,%eax
80108197:	75 07                	jne    801081a0 <uva2ka+0x49>
    return 0;
80108199:	b8 00 00 00 00       	mov    $0x0,%eax
8010819e:	eb 0f                	jmp    801081af <uva2ka+0x58>
  return (char*)P2V(PTE_ADDR(*pte));
801081a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081a3:	8b 00                	mov    (%eax),%eax
801081a5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801081aa:	05 00 00 00 80       	add    $0x80000000,%eax
}
801081af:	c9                   	leave  
801081b0:	c3                   	ret    

801081b1 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801081b1:	55                   	push   %ebp
801081b2:	89 e5                	mov    %esp,%ebp
801081b4:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801081b7:	8b 45 10             	mov    0x10(%ebp),%eax
801081ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801081bd:	e9 87 00 00 00       	jmp    80108249 <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
801081c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801081c5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801081ca:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801081cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081d0:	89 44 24 04          	mov    %eax,0x4(%esp)
801081d4:	8b 45 08             	mov    0x8(%ebp),%eax
801081d7:	89 04 24             	mov    %eax,(%esp)
801081da:	e8 78 ff ff ff       	call   80108157 <uva2ka>
801081df:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801081e2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801081e6:	75 07                	jne    801081ef <copyout+0x3e>
      return -1;
801081e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801081ed:	eb 69                	jmp    80108258 <copyout+0xa7>
    n = PGSIZE - (va - va0);
801081ef:	8b 45 0c             	mov    0xc(%ebp),%eax
801081f2:	8b 55 ec             	mov    -0x14(%ebp),%edx
801081f5:	29 c2                	sub    %eax,%edx
801081f7:	89 d0                	mov    %edx,%eax
801081f9:	05 00 10 00 00       	add    $0x1000,%eax
801081fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108201:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108204:	3b 45 14             	cmp    0x14(%ebp),%eax
80108207:	76 06                	jbe    8010820f <copyout+0x5e>
      n = len;
80108209:	8b 45 14             	mov    0x14(%ebp),%eax
8010820c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
8010820f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108212:	8b 55 0c             	mov    0xc(%ebp),%edx
80108215:	29 c2                	sub    %eax,%edx
80108217:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010821a:	01 c2                	add    %eax,%edx
8010821c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010821f:	89 44 24 08          	mov    %eax,0x8(%esp)
80108223:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108226:	89 44 24 04          	mov    %eax,0x4(%esp)
8010822a:	89 14 24             	mov    %edx,(%esp)
8010822d:	e8 cd ce ff ff       	call   801050ff <memmove>
    len -= n;
80108232:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108235:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108238:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010823b:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
8010823e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108241:	05 00 10 00 00       	add    $0x1000,%eax
80108246:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80108249:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010824d:	0f 85 6f ff ff ff    	jne    801081c2 <copyout+0x11>
  }
  return 0;
80108253:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108258:	c9                   	leave  
80108259:	c3                   	ret    
