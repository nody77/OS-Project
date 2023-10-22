
obj/user/fos_add:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	mov $0, %eax
  800020:	b8 00 00 00 00       	mov    $0x0,%eax
	cmpl $USTACKTOP, %esp
  800025:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  80002b:	75 04                	jne    800031 <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  80002d:	6a 00                	push   $0x0
	pushl $0
  80002f:	6a 00                	push   $0x0

00800031 <args_exist>:

args_exist:
	call libmain
  800031:	e8 60 00 00 00       	call   800096 <libmain>
1:      jmp 1b
  800036:	eb fe                	jmp    800036 <args_exist+0x5>

00800038 <_main>:
// hello, world
#include <inc/lib.h>

void
_main(void)
{
  800038:	55                   	push   %ebp
  800039:	89 e5                	mov    %esp,%ebp
  80003b:	83 ec 18             	sub    $0x18,%esp

	int i1=0;
  80003e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	int i2=0;
  800045:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

	i1 = strtol("1", NULL, 10);
  80004c:	83 ec 04             	sub    $0x4,%esp
  80004f:	6a 0a                	push   $0xa
  800051:	6a 00                	push   $0x0
  800053:	68 c0 1b 80 00       	push   $0x801bc0
  800058:	e8 34 0c 00 00       	call   800c91 <strtol>
  80005d:	83 c4 10             	add    $0x10,%esp
  800060:	89 45 f4             	mov    %eax,-0xc(%ebp)
	i2 = strtol("2", NULL, 10);
  800063:	83 ec 04             	sub    $0x4,%esp
  800066:	6a 0a                	push   $0xa
  800068:	6a 00                	push   $0x0
  80006a:	68 c2 1b 80 00       	push   $0x801bc2
  80006f:	e8 1d 0c 00 00       	call   800c91 <strtol>
  800074:	83 c4 10             	add    $0x10,%esp
  800077:	89 45 f0             	mov    %eax,-0x10(%ebp)

	atomic_cprintf("number 1 + number 2 = %d\n",i1+i2);
  80007a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80007d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800080:	01 d0                	add    %edx,%eax
  800082:	83 ec 08             	sub    $0x8,%esp
  800085:	50                   	push   %eax
  800086:	68 c4 1b 80 00       	push   $0x801bc4
  80008b:	e8 4c 02 00 00       	call   8002dc <atomic_cprintf>
  800090:	83 c4 10             	add    $0x10,%esp
	//cprintf("number 1 + number 2 = \n");
	return;
  800093:	90                   	nop
}
  800094:	c9                   	leave  
  800095:	c3                   	ret    

00800096 <libmain>:
volatile struct Env *myEnv = NULL;
volatile char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800096:	55                   	push   %ebp
  800097:	89 e5                	mov    %esp,%ebp
  800099:	83 ec 18             	sub    $0x18,%esp
	int envIndex = sys_getenvindex();
  80009c:	e8 a8 13 00 00       	call   801449 <sys_getenvindex>
  8000a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
	myEnv = &(envs[envIndex]);
  8000a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8000a7:	89 d0                	mov    %edx,%eax
  8000a9:	01 c0                	add    %eax,%eax
  8000ab:	01 d0                	add    %edx,%eax
  8000ad:	01 c0                	add    %eax,%eax
  8000af:	01 d0                	add    %edx,%eax
  8000b1:	c1 e0 02             	shl    $0x2,%eax
  8000b4:	01 d0                	add    %edx,%eax
  8000b6:	01 c0                	add    %eax,%eax
  8000b8:	01 d0                	add    %edx,%eax
  8000ba:	c1 e0 02             	shl    $0x2,%eax
  8000bd:	01 d0                	add    %edx,%eax
  8000bf:	c1 e0 02             	shl    $0x2,%eax
  8000c2:	01 d0                	add    %edx,%eax
  8000c4:	c1 e0 02             	shl    $0x2,%eax
  8000c7:	01 d0                	add    %edx,%eax
  8000c9:	c1 e0 05             	shl    $0x5,%eax
  8000cc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d1:	a3 20 30 80 00       	mov    %eax,0x803020

	//SET THE PROGRAM NAME
	if (myEnv->prog_name[0] != '\0')
  8000d6:	a1 20 30 80 00       	mov    0x803020,%eax
  8000db:	8a 40 5c             	mov    0x5c(%eax),%al
  8000de:	84 c0                	test   %al,%al
  8000e0:	74 0d                	je     8000ef <libmain+0x59>
		binaryname = myEnv->prog_name;
  8000e2:	a1 20 30 80 00       	mov    0x803020,%eax
  8000e7:	83 c0 5c             	add    $0x5c,%eax
  8000ea:	a3 00 30 80 00       	mov    %eax,0x803000

	// set env to point at our env structure in envs[].
	// env = envs;

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ef:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000f3:	7e 0a                	jle    8000ff <libmain+0x69>
		binaryname = argv[0];
  8000f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000f8:	8b 00                	mov    (%eax),%eax
  8000fa:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	_main(argc, argv);
  8000ff:	83 ec 08             	sub    $0x8,%esp
  800102:	ff 75 0c             	pushl  0xc(%ebp)
  800105:	ff 75 08             	pushl  0x8(%ebp)
  800108:	e8 2b ff ff ff       	call   800038 <_main>
  80010d:	83 c4 10             	add    $0x10,%esp



	sys_disable_interrupt();
  800110:	e8 41 11 00 00       	call   801256 <sys_disable_interrupt>
	cprintf("**************************************\n");
  800115:	83 ec 0c             	sub    $0xc,%esp
  800118:	68 f8 1b 80 00       	push   $0x801bf8
  80011d:	e8 8d 01 00 00       	call   8002af <cprintf>
  800122:	83 c4 10             	add    $0x10,%esp
	cprintf("Num of PAGE faults = %d, modif = %d\n", myEnv->pageFaultsCounter, myEnv->nModifiedPages);
  800125:	a1 20 30 80 00       	mov    0x803020,%eax
  80012a:	8b 90 84 da 01 00    	mov    0x1da84(%eax),%edx
  800130:	a1 20 30 80 00       	mov    0x803020,%eax
  800135:	8b 80 74 da 01 00    	mov    0x1da74(%eax),%eax
  80013b:	83 ec 04             	sub    $0x4,%esp
  80013e:	52                   	push   %edx
  80013f:	50                   	push   %eax
  800140:	68 20 1c 80 00       	push   $0x801c20
  800145:	e8 65 01 00 00       	call   8002af <cprintf>
  80014a:	83 c4 10             	add    $0x10,%esp
	cprintf("# PAGE IN (from disk) = %d, # PAGE OUT (on disk) = %d, # NEW PAGE ADDED (on disk) = %d\n", myEnv->nPageIn, myEnv->nPageOut,myEnv->nNewPageAdded);
  80014d:	a1 20 30 80 00       	mov    0x803020,%eax
  800152:	8b 88 98 da 01 00    	mov    0x1da98(%eax),%ecx
  800158:	a1 20 30 80 00       	mov    0x803020,%eax
  80015d:	8b 90 94 da 01 00    	mov    0x1da94(%eax),%edx
  800163:	a1 20 30 80 00       	mov    0x803020,%eax
  800168:	8b 80 90 da 01 00    	mov    0x1da90(%eax),%eax
  80016e:	51                   	push   %ecx
  80016f:	52                   	push   %edx
  800170:	50                   	push   %eax
  800171:	68 48 1c 80 00       	push   $0x801c48
  800176:	e8 34 01 00 00       	call   8002af <cprintf>
  80017b:	83 c4 10             	add    $0x10,%esp
	//cprintf("Num of freeing scarce memory = %d, freeing full working set = %d\n", myEnv->freeingScarceMemCounter, myEnv->freeingFullWSCounter);
	cprintf("Num of clocks = %d\n", myEnv->nClocks);
  80017e:	a1 20 30 80 00       	mov    0x803020,%eax
  800183:	8b 80 9c da 01 00    	mov    0x1da9c(%eax),%eax
  800189:	83 ec 08             	sub    $0x8,%esp
  80018c:	50                   	push   %eax
  80018d:	68 a0 1c 80 00       	push   $0x801ca0
  800192:	e8 18 01 00 00       	call   8002af <cprintf>
  800197:	83 c4 10             	add    $0x10,%esp
	cprintf("**************************************\n");
  80019a:	83 ec 0c             	sub    $0xc,%esp
  80019d:	68 f8 1b 80 00       	push   $0x801bf8
  8001a2:	e8 08 01 00 00       	call   8002af <cprintf>
  8001a7:	83 c4 10             	add    $0x10,%esp
	sys_enable_interrupt();
  8001aa:	e8 c1 10 00 00       	call   801270 <sys_enable_interrupt>

	// exit gracefully
	exit();
  8001af:	e8 19 00 00 00       	call   8001cd <exit>
}
  8001b4:	90                   	nop
  8001b5:	c9                   	leave  
  8001b6:	c3                   	ret    

008001b7 <destroy>:

#include <inc/lib.h>

void
destroy(void)
{
  8001b7:	55                   	push   %ebp
  8001b8:	89 e5                	mov    %esp,%ebp
  8001ba:	83 ec 08             	sub    $0x8,%esp
	sys_destroy_env(0);
  8001bd:	83 ec 0c             	sub    $0xc,%esp
  8001c0:	6a 00                	push   $0x0
  8001c2:	e8 4e 12 00 00       	call   801415 <sys_destroy_env>
  8001c7:	83 c4 10             	add    $0x10,%esp
}
  8001ca:	90                   	nop
  8001cb:	c9                   	leave  
  8001cc:	c3                   	ret    

008001cd <exit>:

void
exit(void)
{
  8001cd:	55                   	push   %ebp
  8001ce:	89 e5                	mov    %esp,%ebp
  8001d0:	83 ec 08             	sub    $0x8,%esp
	sys_exit_env();
  8001d3:	e8 a3 12 00 00       	call   80147b <sys_exit_env>
}
  8001d8:	90                   	nop
  8001d9:	c9                   	leave  
  8001da:	c3                   	ret    

008001db <putch>:
};

//2017:
uint8 printProgName = 0;

static void putch(int ch, struct printbuf *b) {
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	83 ec 08             	sub    $0x8,%esp
	b->buf[b->idx++] = ch;
  8001e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001e4:	8b 00                	mov    (%eax),%eax
  8001e6:	8d 48 01             	lea    0x1(%eax),%ecx
  8001e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ec:	89 0a                	mov    %ecx,(%edx)
  8001ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f1:	88 d1                	mov    %dl,%cl
  8001f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001f6:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256 - 1) {
  8001fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001fd:	8b 00                	mov    (%eax),%eax
  8001ff:	3d ff 00 00 00       	cmp    $0xff,%eax
  800204:	75 2c                	jne    800232 <putch+0x57>
		sys_cputs(b->buf, b->idx, printProgName);
  800206:	a0 24 30 80 00       	mov    0x803024,%al
  80020b:	0f b6 c0             	movzbl %al,%eax
  80020e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800211:	8b 12                	mov    (%edx),%edx
  800213:	89 d1                	mov    %edx,%ecx
  800215:	8b 55 0c             	mov    0xc(%ebp),%edx
  800218:	83 c2 08             	add    $0x8,%edx
  80021b:	83 ec 04             	sub    $0x4,%esp
  80021e:	50                   	push   %eax
  80021f:	51                   	push   %ecx
  800220:	52                   	push   %edx
  800221:	e8 d7 0e 00 00       	call   8010fd <sys_cputs>
  800226:	83 c4 10             	add    $0x10,%esp
		b->idx = 0;
  800229:	8b 45 0c             	mov    0xc(%ebp),%eax
  80022c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800232:	8b 45 0c             	mov    0xc(%ebp),%eax
  800235:	8b 40 04             	mov    0x4(%eax),%eax
  800238:	8d 50 01             	lea    0x1(%eax),%edx
  80023b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80023e:	89 50 04             	mov    %edx,0x4(%eax)
}
  800241:	90                   	nop
  800242:	c9                   	leave  
  800243:	c3                   	ret    

00800244 <vcprintf>:

int vcprintf(const char *fmt, va_list ap) {
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80024d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800254:	00 00 00 
	b.cnt = 0;
  800257:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80025e:	00 00 00 
	vprintfmt((void*) putch, &b, fmt, ap);
  800261:	ff 75 0c             	pushl  0xc(%ebp)
  800264:	ff 75 08             	pushl  0x8(%ebp)
  800267:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80026d:	50                   	push   %eax
  80026e:	68 db 01 80 00       	push   $0x8001db
  800273:	e8 11 02 00 00       	call   800489 <vprintfmt>
  800278:	83 c4 10             	add    $0x10,%esp
	sys_cputs(b.buf, b.idx, printProgName);
  80027b:	a0 24 30 80 00       	mov    0x803024,%al
  800280:	0f b6 c0             	movzbl %al,%eax
  800283:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
  800289:	83 ec 04             	sub    $0x4,%esp
  80028c:	50                   	push   %eax
  80028d:	52                   	push   %edx
  80028e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800294:	83 c0 08             	add    $0x8,%eax
  800297:	50                   	push   %eax
  800298:	e8 60 0e 00 00       	call   8010fd <sys_cputs>
  80029d:	83 c4 10             	add    $0x10,%esp

	printProgName = 0;
  8002a0:	c6 05 24 30 80 00 00 	movb   $0x0,0x803024
	return b.cnt;
  8002a7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8002ad:	c9                   	leave  
  8002ae:	c3                   	ret    

008002af <cprintf>:

int cprintf(const char *fmt, ...) {
  8002af:	55                   	push   %ebp
  8002b0:	89 e5                	mov    %esp,%ebp
  8002b2:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;
	printProgName = 1 ;
  8002b5:	c6 05 24 30 80 00 01 	movb   $0x1,0x803024
	va_start(ap, fmt);
  8002bc:	8d 45 0c             	lea    0xc(%ebp),%eax
  8002bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cnt = vcprintf(fmt, ap);
  8002c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c5:	83 ec 08             	sub    $0x8,%esp
  8002c8:	ff 75 f4             	pushl  -0xc(%ebp)
  8002cb:	50                   	push   %eax
  8002cc:	e8 73 ff ff ff       	call   800244 <vcprintf>
  8002d1:	83 c4 10             	add    $0x10,%esp
  8002d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
	va_end(ap);

	return cnt;
  8002d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  8002da:	c9                   	leave  
  8002db:	c3                   	ret    

008002dc <atomic_cprintf>:

int atomic_cprintf(const char *fmt, ...) {
  8002dc:	55                   	push   %ebp
  8002dd:	89 e5                	mov    %esp,%ebp
  8002df:	83 ec 18             	sub    $0x18,%esp
	sys_disable_interrupt();
  8002e2:	e8 6f 0f 00 00       	call   801256 <sys_disable_interrupt>
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002e7:	8d 45 0c             	lea    0xc(%ebp),%eax
  8002ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cnt = vcprintf(fmt, ap);
  8002ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f0:	83 ec 08             	sub    $0x8,%esp
  8002f3:	ff 75 f4             	pushl  -0xc(%ebp)
  8002f6:	50                   	push   %eax
  8002f7:	e8 48 ff ff ff       	call   800244 <vcprintf>
  8002fc:	83 c4 10             	add    $0x10,%esp
  8002ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
	va_end(ap);

	sys_enable_interrupt();
  800302:	e8 69 0f 00 00       	call   801270 <sys_enable_interrupt>
	return cnt;
  800307:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  80030a:	c9                   	leave  
  80030b:	c3                   	ret    

0080030c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80030c:	55                   	push   %ebp
  80030d:	89 e5                	mov    %esp,%ebp
  80030f:	53                   	push   %ebx
  800310:	83 ec 14             	sub    $0x14,%esp
  800313:	8b 45 10             	mov    0x10(%ebp),%eax
  800316:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800319:	8b 45 14             	mov    0x14(%ebp),%eax
  80031c:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80031f:	8b 45 18             	mov    0x18(%ebp),%eax
  800322:	ba 00 00 00 00       	mov    $0x0,%edx
  800327:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  80032a:	77 55                	ja     800381 <printnum+0x75>
  80032c:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  80032f:	72 05                	jb     800336 <printnum+0x2a>
  800331:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800334:	77 4b                	ja     800381 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800336:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800339:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80033c:	8b 45 18             	mov    0x18(%ebp),%eax
  80033f:	ba 00 00 00 00       	mov    $0x0,%edx
  800344:	52                   	push   %edx
  800345:	50                   	push   %eax
  800346:	ff 75 f4             	pushl  -0xc(%ebp)
  800349:	ff 75 f0             	pushl  -0x10(%ebp)
  80034c:	e8 07 16 00 00       	call   801958 <__udivdi3>
  800351:	83 c4 10             	add    $0x10,%esp
  800354:	83 ec 04             	sub    $0x4,%esp
  800357:	ff 75 20             	pushl  0x20(%ebp)
  80035a:	53                   	push   %ebx
  80035b:	ff 75 18             	pushl  0x18(%ebp)
  80035e:	52                   	push   %edx
  80035f:	50                   	push   %eax
  800360:	ff 75 0c             	pushl  0xc(%ebp)
  800363:	ff 75 08             	pushl  0x8(%ebp)
  800366:	e8 a1 ff ff ff       	call   80030c <printnum>
  80036b:	83 c4 20             	add    $0x20,%esp
  80036e:	eb 1a                	jmp    80038a <printnum+0x7e>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800370:	83 ec 08             	sub    $0x8,%esp
  800373:	ff 75 0c             	pushl  0xc(%ebp)
  800376:	ff 75 20             	pushl  0x20(%ebp)
  800379:	8b 45 08             	mov    0x8(%ebp),%eax
  80037c:	ff d0                	call   *%eax
  80037e:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800381:	ff 4d 1c             	decl   0x1c(%ebp)
  800384:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800388:	7f e6                	jg     800370 <printnum+0x64>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80038a:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80038d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800392:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800395:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800398:	53                   	push   %ebx
  800399:	51                   	push   %ecx
  80039a:	52                   	push   %edx
  80039b:	50                   	push   %eax
  80039c:	e8 c7 16 00 00       	call   801a68 <__umoddi3>
  8003a1:	83 c4 10             	add    $0x10,%esp
  8003a4:	05 d4 1e 80 00       	add    $0x801ed4,%eax
  8003a9:	8a 00                	mov    (%eax),%al
  8003ab:	0f be c0             	movsbl %al,%eax
  8003ae:	83 ec 08             	sub    $0x8,%esp
  8003b1:	ff 75 0c             	pushl  0xc(%ebp)
  8003b4:	50                   	push   %eax
  8003b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b8:	ff d0                	call   *%eax
  8003ba:	83 c4 10             	add    $0x10,%esp
}
  8003bd:	90                   	nop
  8003be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003c1:	c9                   	leave  
  8003c2:	c3                   	ret    

008003c3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003c3:	55                   	push   %ebp
  8003c4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003c6:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8003ca:	7e 1c                	jle    8003e8 <getuint+0x25>
		return va_arg(*ap, unsigned long long);
  8003cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8003cf:	8b 00                	mov    (%eax),%eax
  8003d1:	8d 50 08             	lea    0x8(%eax),%edx
  8003d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d7:	89 10                	mov    %edx,(%eax)
  8003d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8003dc:	8b 00                	mov    (%eax),%eax
  8003de:	83 e8 08             	sub    $0x8,%eax
  8003e1:	8b 50 04             	mov    0x4(%eax),%edx
  8003e4:	8b 00                	mov    (%eax),%eax
  8003e6:	eb 40                	jmp    800428 <getuint+0x65>
	else if (lflag)
  8003e8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8003ec:	74 1e                	je     80040c <getuint+0x49>
		return va_arg(*ap, unsigned long);
  8003ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f1:	8b 00                	mov    (%eax),%eax
  8003f3:	8d 50 04             	lea    0x4(%eax),%edx
  8003f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f9:	89 10                	mov    %edx,(%eax)
  8003fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fe:	8b 00                	mov    (%eax),%eax
  800400:	83 e8 04             	sub    $0x4,%eax
  800403:	8b 00                	mov    (%eax),%eax
  800405:	ba 00 00 00 00       	mov    $0x0,%edx
  80040a:	eb 1c                	jmp    800428 <getuint+0x65>
	else
		return va_arg(*ap, unsigned int);
  80040c:	8b 45 08             	mov    0x8(%ebp),%eax
  80040f:	8b 00                	mov    (%eax),%eax
  800411:	8d 50 04             	lea    0x4(%eax),%edx
  800414:	8b 45 08             	mov    0x8(%ebp),%eax
  800417:	89 10                	mov    %edx,(%eax)
  800419:	8b 45 08             	mov    0x8(%ebp),%eax
  80041c:	8b 00                	mov    (%eax),%eax
  80041e:	83 e8 04             	sub    $0x4,%eax
  800421:	8b 00                	mov    (%eax),%eax
  800423:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800428:	5d                   	pop    %ebp
  800429:	c3                   	ret    

0080042a <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80042a:	55                   	push   %ebp
  80042b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80042d:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800431:	7e 1c                	jle    80044f <getint+0x25>
		return va_arg(*ap, long long);
  800433:	8b 45 08             	mov    0x8(%ebp),%eax
  800436:	8b 00                	mov    (%eax),%eax
  800438:	8d 50 08             	lea    0x8(%eax),%edx
  80043b:	8b 45 08             	mov    0x8(%ebp),%eax
  80043e:	89 10                	mov    %edx,(%eax)
  800440:	8b 45 08             	mov    0x8(%ebp),%eax
  800443:	8b 00                	mov    (%eax),%eax
  800445:	83 e8 08             	sub    $0x8,%eax
  800448:	8b 50 04             	mov    0x4(%eax),%edx
  80044b:	8b 00                	mov    (%eax),%eax
  80044d:	eb 38                	jmp    800487 <getint+0x5d>
	else if (lflag)
  80044f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800453:	74 1a                	je     80046f <getint+0x45>
		return va_arg(*ap, long);
  800455:	8b 45 08             	mov    0x8(%ebp),%eax
  800458:	8b 00                	mov    (%eax),%eax
  80045a:	8d 50 04             	lea    0x4(%eax),%edx
  80045d:	8b 45 08             	mov    0x8(%ebp),%eax
  800460:	89 10                	mov    %edx,(%eax)
  800462:	8b 45 08             	mov    0x8(%ebp),%eax
  800465:	8b 00                	mov    (%eax),%eax
  800467:	83 e8 04             	sub    $0x4,%eax
  80046a:	8b 00                	mov    (%eax),%eax
  80046c:	99                   	cltd   
  80046d:	eb 18                	jmp    800487 <getint+0x5d>
	else
		return va_arg(*ap, int);
  80046f:	8b 45 08             	mov    0x8(%ebp),%eax
  800472:	8b 00                	mov    (%eax),%eax
  800474:	8d 50 04             	lea    0x4(%eax),%edx
  800477:	8b 45 08             	mov    0x8(%ebp),%eax
  80047a:	89 10                	mov    %edx,(%eax)
  80047c:	8b 45 08             	mov    0x8(%ebp),%eax
  80047f:	8b 00                	mov    (%eax),%eax
  800481:	83 e8 04             	sub    $0x4,%eax
  800484:	8b 00                	mov    (%eax),%eax
  800486:	99                   	cltd   
}
  800487:	5d                   	pop    %ebp
  800488:	c3                   	ret    

00800489 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800489:	55                   	push   %ebp
  80048a:	89 e5                	mov    %esp,%ebp
  80048c:	56                   	push   %esi
  80048d:	53                   	push   %ebx
  80048e:	83 ec 20             	sub    $0x20,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800491:	eb 17                	jmp    8004aa <vprintfmt+0x21>
			if (ch == '\0')
  800493:	85 db                	test   %ebx,%ebx
  800495:	0f 84 af 03 00 00    	je     80084a <vprintfmt+0x3c1>
				return;
			putch(ch, putdat);
  80049b:	83 ec 08             	sub    $0x8,%esp
  80049e:	ff 75 0c             	pushl  0xc(%ebp)
  8004a1:	53                   	push   %ebx
  8004a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a5:	ff d0                	call   *%eax
  8004a7:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8004ad:	8d 50 01             	lea    0x1(%eax),%edx
  8004b0:	89 55 10             	mov    %edx,0x10(%ebp)
  8004b3:	8a 00                	mov    (%eax),%al
  8004b5:	0f b6 d8             	movzbl %al,%ebx
  8004b8:	83 fb 25             	cmp    $0x25,%ebx
  8004bb:	75 d6                	jne    800493 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  8004bd:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  8004c1:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  8004c8:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8004cf:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  8004d6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004dd:	8b 45 10             	mov    0x10(%ebp),%eax
  8004e0:	8d 50 01             	lea    0x1(%eax),%edx
  8004e3:	89 55 10             	mov    %edx,0x10(%ebp)
  8004e6:	8a 00                	mov    (%eax),%al
  8004e8:	0f b6 d8             	movzbl %al,%ebx
  8004eb:	8d 43 dd             	lea    -0x23(%ebx),%eax
  8004ee:	83 f8 55             	cmp    $0x55,%eax
  8004f1:	0f 87 2b 03 00 00    	ja     800822 <vprintfmt+0x399>
  8004f7:	8b 04 85 f8 1e 80 00 	mov    0x801ef8(,%eax,4),%eax
  8004fe:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800500:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  800504:	eb d7                	jmp    8004dd <vprintfmt+0x54>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800506:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  80050a:	eb d1                	jmp    8004dd <vprintfmt+0x54>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80050c:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  800513:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800516:	89 d0                	mov    %edx,%eax
  800518:	c1 e0 02             	shl    $0x2,%eax
  80051b:	01 d0                	add    %edx,%eax
  80051d:	01 c0                	add    %eax,%eax
  80051f:	01 d8                	add    %ebx,%eax
  800521:	83 e8 30             	sub    $0x30,%eax
  800524:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  800527:	8b 45 10             	mov    0x10(%ebp),%eax
  80052a:	8a 00                	mov    (%eax),%al
  80052c:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  80052f:	83 fb 2f             	cmp    $0x2f,%ebx
  800532:	7e 3e                	jle    800572 <vprintfmt+0xe9>
  800534:	83 fb 39             	cmp    $0x39,%ebx
  800537:	7f 39                	jg     800572 <vprintfmt+0xe9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800539:	ff 45 10             	incl   0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80053c:	eb d5                	jmp    800513 <vprintfmt+0x8a>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80053e:	8b 45 14             	mov    0x14(%ebp),%eax
  800541:	83 c0 04             	add    $0x4,%eax
  800544:	89 45 14             	mov    %eax,0x14(%ebp)
  800547:	8b 45 14             	mov    0x14(%ebp),%eax
  80054a:	83 e8 04             	sub    $0x4,%eax
  80054d:	8b 00                	mov    (%eax),%eax
  80054f:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  800552:	eb 1f                	jmp    800573 <vprintfmt+0xea>

		case '.':
			if (width < 0)
  800554:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800558:	79 83                	jns    8004dd <vprintfmt+0x54>
				width = 0;
  80055a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  800561:	e9 77 ff ff ff       	jmp    8004dd <vprintfmt+0x54>

		case '#':
			altflag = 1;
  800566:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80056d:	e9 6b ff ff ff       	jmp    8004dd <vprintfmt+0x54>
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
			goto process_precision;
  800572:	90                   	nop
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800573:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800577:	0f 89 60 ff ff ff    	jns    8004dd <vprintfmt+0x54>
				width = precision, precision = -1;
  80057d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800580:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800583:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  80058a:	e9 4e ff ff ff       	jmp    8004dd <vprintfmt+0x54>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80058f:	ff 45 e8             	incl   -0x18(%ebp)
			goto reswitch;
  800592:	e9 46 ff ff ff       	jmp    8004dd <vprintfmt+0x54>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800597:	8b 45 14             	mov    0x14(%ebp),%eax
  80059a:	83 c0 04             	add    $0x4,%eax
  80059d:	89 45 14             	mov    %eax,0x14(%ebp)
  8005a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a3:	83 e8 04             	sub    $0x4,%eax
  8005a6:	8b 00                	mov    (%eax),%eax
  8005a8:	83 ec 08             	sub    $0x8,%esp
  8005ab:	ff 75 0c             	pushl  0xc(%ebp)
  8005ae:	50                   	push   %eax
  8005af:	8b 45 08             	mov    0x8(%ebp),%eax
  8005b2:	ff d0                	call   *%eax
  8005b4:	83 c4 10             	add    $0x10,%esp
			break;
  8005b7:	e9 89 02 00 00       	jmp    800845 <vprintfmt+0x3bc>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bf:	83 c0 04             	add    $0x4,%eax
  8005c2:	89 45 14             	mov    %eax,0x14(%ebp)
  8005c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c8:	83 e8 04             	sub    $0x4,%eax
  8005cb:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  8005cd:	85 db                	test   %ebx,%ebx
  8005cf:	79 02                	jns    8005d3 <vprintfmt+0x14a>
				err = -err;
  8005d1:	f7 db                	neg    %ebx
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  8005d3:	83 fb 64             	cmp    $0x64,%ebx
  8005d6:	7f 0b                	jg     8005e3 <vprintfmt+0x15a>
  8005d8:	8b 34 9d 40 1d 80 00 	mov    0x801d40(,%ebx,4),%esi
  8005df:	85 f6                	test   %esi,%esi
  8005e1:	75 19                	jne    8005fc <vprintfmt+0x173>
				printfmt(putch, putdat, "error %d", err);
  8005e3:	53                   	push   %ebx
  8005e4:	68 e5 1e 80 00       	push   $0x801ee5
  8005e9:	ff 75 0c             	pushl  0xc(%ebp)
  8005ec:	ff 75 08             	pushl  0x8(%ebp)
  8005ef:	e8 5e 02 00 00       	call   800852 <printfmt>
  8005f4:	83 c4 10             	add    $0x10,%esp
			else
				printfmt(putch, putdat, "%s", p);
			break;
  8005f7:	e9 49 02 00 00       	jmp    800845 <vprintfmt+0x3bc>
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8005fc:	56                   	push   %esi
  8005fd:	68 ee 1e 80 00       	push   $0x801eee
  800602:	ff 75 0c             	pushl  0xc(%ebp)
  800605:	ff 75 08             	pushl  0x8(%ebp)
  800608:	e8 45 02 00 00       	call   800852 <printfmt>
  80060d:	83 c4 10             	add    $0x10,%esp
			break;
  800610:	e9 30 02 00 00       	jmp    800845 <vprintfmt+0x3bc>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800615:	8b 45 14             	mov    0x14(%ebp),%eax
  800618:	83 c0 04             	add    $0x4,%eax
  80061b:	89 45 14             	mov    %eax,0x14(%ebp)
  80061e:	8b 45 14             	mov    0x14(%ebp),%eax
  800621:	83 e8 04             	sub    $0x4,%eax
  800624:	8b 30                	mov    (%eax),%esi
  800626:	85 f6                	test   %esi,%esi
  800628:	75 05                	jne    80062f <vprintfmt+0x1a6>
				p = "(null)";
  80062a:	be f1 1e 80 00       	mov    $0x801ef1,%esi
			if (width > 0 && padc != '-')
  80062f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800633:	7e 6d                	jle    8006a2 <vprintfmt+0x219>
  800635:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800639:	74 67                	je     8006a2 <vprintfmt+0x219>
				for (width -= strnlen(p, precision); width > 0; width--)
  80063b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80063e:	83 ec 08             	sub    $0x8,%esp
  800641:	50                   	push   %eax
  800642:	56                   	push   %esi
  800643:	e8 0c 03 00 00       	call   800954 <strnlen>
  800648:	83 c4 10             	add    $0x10,%esp
  80064b:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  80064e:	eb 16                	jmp    800666 <vprintfmt+0x1dd>
					putch(padc, putdat);
  800650:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800654:	83 ec 08             	sub    $0x8,%esp
  800657:	ff 75 0c             	pushl  0xc(%ebp)
  80065a:	50                   	push   %eax
  80065b:	8b 45 08             	mov    0x8(%ebp),%eax
  80065e:	ff d0                	call   *%eax
  800660:	83 c4 10             	add    $0x10,%esp
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800663:	ff 4d e4             	decl   -0x1c(%ebp)
  800666:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80066a:	7f e4                	jg     800650 <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80066c:	eb 34                	jmp    8006a2 <vprintfmt+0x219>
				if (altflag && (ch < ' ' || ch > '~'))
  80066e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800672:	74 1c                	je     800690 <vprintfmt+0x207>
  800674:	83 fb 1f             	cmp    $0x1f,%ebx
  800677:	7e 05                	jle    80067e <vprintfmt+0x1f5>
  800679:	83 fb 7e             	cmp    $0x7e,%ebx
  80067c:	7e 12                	jle    800690 <vprintfmt+0x207>
					putch('?', putdat);
  80067e:	83 ec 08             	sub    $0x8,%esp
  800681:	ff 75 0c             	pushl  0xc(%ebp)
  800684:	6a 3f                	push   $0x3f
  800686:	8b 45 08             	mov    0x8(%ebp),%eax
  800689:	ff d0                	call   *%eax
  80068b:	83 c4 10             	add    $0x10,%esp
  80068e:	eb 0f                	jmp    80069f <vprintfmt+0x216>
				else
					putch(ch, putdat);
  800690:	83 ec 08             	sub    $0x8,%esp
  800693:	ff 75 0c             	pushl  0xc(%ebp)
  800696:	53                   	push   %ebx
  800697:	8b 45 08             	mov    0x8(%ebp),%eax
  80069a:	ff d0                	call   *%eax
  80069c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80069f:	ff 4d e4             	decl   -0x1c(%ebp)
  8006a2:	89 f0                	mov    %esi,%eax
  8006a4:	8d 70 01             	lea    0x1(%eax),%esi
  8006a7:	8a 00                	mov    (%eax),%al
  8006a9:	0f be d8             	movsbl %al,%ebx
  8006ac:	85 db                	test   %ebx,%ebx
  8006ae:	74 24                	je     8006d4 <vprintfmt+0x24b>
  8006b0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006b4:	78 b8                	js     80066e <vprintfmt+0x1e5>
  8006b6:	ff 4d e0             	decl   -0x20(%ebp)
  8006b9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006bd:	79 af                	jns    80066e <vprintfmt+0x1e5>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006bf:	eb 13                	jmp    8006d4 <vprintfmt+0x24b>
				putch(' ', putdat);
  8006c1:	83 ec 08             	sub    $0x8,%esp
  8006c4:	ff 75 0c             	pushl  0xc(%ebp)
  8006c7:	6a 20                	push   $0x20
  8006c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cc:	ff d0                	call   *%eax
  8006ce:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006d1:	ff 4d e4             	decl   -0x1c(%ebp)
  8006d4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006d8:	7f e7                	jg     8006c1 <vprintfmt+0x238>
				putch(' ', putdat);
			break;
  8006da:	e9 66 01 00 00       	jmp    800845 <vprintfmt+0x3bc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006df:	83 ec 08             	sub    $0x8,%esp
  8006e2:	ff 75 e8             	pushl  -0x18(%ebp)
  8006e5:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e8:	50                   	push   %eax
  8006e9:	e8 3c fd ff ff       	call   80042a <getint>
  8006ee:	83 c4 10             	add    $0x10,%esp
  8006f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006f4:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  8006f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006fd:	85 d2                	test   %edx,%edx
  8006ff:	79 23                	jns    800724 <vprintfmt+0x29b>
				putch('-', putdat);
  800701:	83 ec 08             	sub    $0x8,%esp
  800704:	ff 75 0c             	pushl  0xc(%ebp)
  800707:	6a 2d                	push   $0x2d
  800709:	8b 45 08             	mov    0x8(%ebp),%eax
  80070c:	ff d0                	call   *%eax
  80070e:	83 c4 10             	add    $0x10,%esp
				num = -(long long) num;
  800711:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800714:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800717:	f7 d8                	neg    %eax
  800719:	83 d2 00             	adc    $0x0,%edx
  80071c:	f7 da                	neg    %edx
  80071e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800721:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800724:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  80072b:	e9 bc 00 00 00       	jmp    8007ec <vprintfmt+0x363>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800730:	83 ec 08             	sub    $0x8,%esp
  800733:	ff 75 e8             	pushl  -0x18(%ebp)
  800736:	8d 45 14             	lea    0x14(%ebp),%eax
  800739:	50                   	push   %eax
  80073a:	e8 84 fc ff ff       	call   8003c3 <getuint>
  80073f:	83 c4 10             	add    $0x10,%esp
  800742:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800745:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800748:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  80074f:	e9 98 00 00 00       	jmp    8007ec <vprintfmt+0x363>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800754:	83 ec 08             	sub    $0x8,%esp
  800757:	ff 75 0c             	pushl  0xc(%ebp)
  80075a:	6a 58                	push   $0x58
  80075c:	8b 45 08             	mov    0x8(%ebp),%eax
  80075f:	ff d0                	call   *%eax
  800761:	83 c4 10             	add    $0x10,%esp
			putch('X', putdat);
  800764:	83 ec 08             	sub    $0x8,%esp
  800767:	ff 75 0c             	pushl  0xc(%ebp)
  80076a:	6a 58                	push   $0x58
  80076c:	8b 45 08             	mov    0x8(%ebp),%eax
  80076f:	ff d0                	call   *%eax
  800771:	83 c4 10             	add    $0x10,%esp
			putch('X', putdat);
  800774:	83 ec 08             	sub    $0x8,%esp
  800777:	ff 75 0c             	pushl  0xc(%ebp)
  80077a:	6a 58                	push   $0x58
  80077c:	8b 45 08             	mov    0x8(%ebp),%eax
  80077f:	ff d0                	call   *%eax
  800781:	83 c4 10             	add    $0x10,%esp
			break;
  800784:	e9 bc 00 00 00       	jmp    800845 <vprintfmt+0x3bc>

		// pointer
		case 'p':
			putch('0', putdat);
  800789:	83 ec 08             	sub    $0x8,%esp
  80078c:	ff 75 0c             	pushl  0xc(%ebp)
  80078f:	6a 30                	push   $0x30
  800791:	8b 45 08             	mov    0x8(%ebp),%eax
  800794:	ff d0                	call   *%eax
  800796:	83 c4 10             	add    $0x10,%esp
			putch('x', putdat);
  800799:	83 ec 08             	sub    $0x8,%esp
  80079c:	ff 75 0c             	pushl  0xc(%ebp)
  80079f:	6a 78                	push   $0x78
  8007a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a4:	ff d0                	call   *%eax
  8007a6:	83 c4 10             	add    $0x10,%esp
			num = (unsigned long long)
				(uint32) va_arg(ap, void *);
  8007a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ac:	83 c0 04             	add    $0x4,%eax
  8007af:	89 45 14             	mov    %eax,0x14(%ebp)
  8007b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b5:	83 e8 04             	sub    $0x4,%eax
  8007b8:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007bd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uint32) va_arg(ap, void *);
			base = 16;
  8007c4:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  8007cb:	eb 1f                	jmp    8007ec <vprintfmt+0x363>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007cd:	83 ec 08             	sub    $0x8,%esp
  8007d0:	ff 75 e8             	pushl  -0x18(%ebp)
  8007d3:	8d 45 14             	lea    0x14(%ebp),%eax
  8007d6:	50                   	push   %eax
  8007d7:	e8 e7 fb ff ff       	call   8003c3 <getuint>
  8007dc:	83 c4 10             	add    $0x10,%esp
  8007df:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007e2:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  8007e5:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007ec:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  8007f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007f3:	83 ec 04             	sub    $0x4,%esp
  8007f6:	52                   	push   %edx
  8007f7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007fa:	50                   	push   %eax
  8007fb:	ff 75 f4             	pushl  -0xc(%ebp)
  8007fe:	ff 75 f0             	pushl  -0x10(%ebp)
  800801:	ff 75 0c             	pushl  0xc(%ebp)
  800804:	ff 75 08             	pushl  0x8(%ebp)
  800807:	e8 00 fb ff ff       	call   80030c <printnum>
  80080c:	83 c4 20             	add    $0x20,%esp
			break;
  80080f:	eb 34                	jmp    800845 <vprintfmt+0x3bc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800811:	83 ec 08             	sub    $0x8,%esp
  800814:	ff 75 0c             	pushl  0xc(%ebp)
  800817:	53                   	push   %ebx
  800818:	8b 45 08             	mov    0x8(%ebp),%eax
  80081b:	ff d0                	call   *%eax
  80081d:	83 c4 10             	add    $0x10,%esp
			break;
  800820:	eb 23                	jmp    800845 <vprintfmt+0x3bc>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800822:	83 ec 08             	sub    $0x8,%esp
  800825:	ff 75 0c             	pushl  0xc(%ebp)
  800828:	6a 25                	push   $0x25
  80082a:	8b 45 08             	mov    0x8(%ebp),%eax
  80082d:	ff d0                	call   *%eax
  80082f:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  800832:	ff 4d 10             	decl   0x10(%ebp)
  800835:	eb 03                	jmp    80083a <vprintfmt+0x3b1>
  800837:	ff 4d 10             	decl   0x10(%ebp)
  80083a:	8b 45 10             	mov    0x10(%ebp),%eax
  80083d:	48                   	dec    %eax
  80083e:	8a 00                	mov    (%eax),%al
  800840:	3c 25                	cmp    $0x25,%al
  800842:	75 f3                	jne    800837 <vprintfmt+0x3ae>
				/* do nothing */;
			break;
  800844:	90                   	nop
		}
	}
  800845:	e9 47 fc ff ff       	jmp    800491 <vprintfmt+0x8>
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
  80084a:	90                   	nop
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80084b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80084e:	5b                   	pop    %ebx
  80084f:	5e                   	pop    %esi
  800850:	5d                   	pop    %ebp
  800851:	c3                   	ret    

00800852 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800858:	8d 45 10             	lea    0x10(%ebp),%eax
  80085b:	83 c0 04             	add    $0x4,%eax
  80085e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800861:	8b 45 10             	mov    0x10(%ebp),%eax
  800864:	ff 75 f4             	pushl  -0xc(%ebp)
  800867:	50                   	push   %eax
  800868:	ff 75 0c             	pushl  0xc(%ebp)
  80086b:	ff 75 08             	pushl  0x8(%ebp)
  80086e:	e8 16 fc ff ff       	call   800489 <vprintfmt>
  800873:	83 c4 10             	add    $0x10,%esp
	va_end(ap);
}
  800876:	90                   	nop
  800877:	c9                   	leave  
  800878:	c3                   	ret    

00800879 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  80087c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80087f:	8b 40 08             	mov    0x8(%eax),%eax
  800882:	8d 50 01             	lea    0x1(%eax),%edx
  800885:	8b 45 0c             	mov    0xc(%ebp),%eax
  800888:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  80088b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80088e:	8b 10                	mov    (%eax),%edx
  800890:	8b 45 0c             	mov    0xc(%ebp),%eax
  800893:	8b 40 04             	mov    0x4(%eax),%eax
  800896:	39 c2                	cmp    %eax,%edx
  800898:	73 12                	jae    8008ac <sprintputch+0x33>
		*b->buf++ = ch;
  80089a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80089d:	8b 00                	mov    (%eax),%eax
  80089f:	8d 48 01             	lea    0x1(%eax),%ecx
  8008a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a5:	89 0a                	mov    %ecx,(%edx)
  8008a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8008aa:	88 10                	mov    %dl,(%eax)
}
  8008ac:	90                   	nop
  8008ad:	5d                   	pop    %ebp
  8008ae:	c3                   	ret    

008008af <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008af:	55                   	push   %ebp
  8008b0:	89 e5                	mov    %esp,%ebp
  8008b2:	83 ec 18             	sub    $0x18,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008be:	8d 50 ff             	lea    -0x1(%eax),%edx
  8008c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c4:	01 d0                	add    %edx,%eax
  8008c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8008c9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008d0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8008d4:	74 06                	je     8008dc <vsnprintf+0x2d>
  8008d6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8008da:	7f 07                	jg     8008e3 <vsnprintf+0x34>
		return -E_INVAL;
  8008dc:	b8 03 00 00 00       	mov    $0x3,%eax
  8008e1:	eb 20                	jmp    800903 <vsnprintf+0x54>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008e3:	ff 75 14             	pushl  0x14(%ebp)
  8008e6:	ff 75 10             	pushl  0x10(%ebp)
  8008e9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008ec:	50                   	push   %eax
  8008ed:	68 79 08 80 00       	push   $0x800879
  8008f2:	e8 92 fb ff ff       	call   800489 <vprintfmt>
  8008f7:	83 c4 10             	add    $0x10,%esp

	// null terminate the buffer
	*b.buf = '\0';
  8008fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008fd:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800900:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800903:	c9                   	leave  
  800904:	c3                   	ret    

00800905 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80090b:	8d 45 10             	lea    0x10(%ebp),%eax
  80090e:	83 c0 04             	add    $0x4,%eax
  800911:	89 45 f4             	mov    %eax,-0xc(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800914:	8b 45 10             	mov    0x10(%ebp),%eax
  800917:	ff 75 f4             	pushl  -0xc(%ebp)
  80091a:	50                   	push   %eax
  80091b:	ff 75 0c             	pushl  0xc(%ebp)
  80091e:	ff 75 08             	pushl  0x8(%ebp)
  800921:	e8 89 ff ff ff       	call   8008af <vsnprintf>
  800926:	83 c4 10             	add    $0x10,%esp
  800929:	89 45 f0             	mov    %eax,-0x10(%ebp)
	va_end(ap);

	return rc;
  80092c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  80092f:	c9                   	leave  
  800930:	c3                   	ret    

00800931 <strlen>:

#include <inc/string.h>
#include <inc/assert.h>
int
strlen(const char *s)
{
  800931:	55                   	push   %ebp
  800932:	89 e5                	mov    %esp,%ebp
  800934:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800937:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80093e:	eb 06                	jmp    800946 <strlen+0x15>
		n++;
  800940:	ff 45 fc             	incl   -0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800943:	ff 45 08             	incl   0x8(%ebp)
  800946:	8b 45 08             	mov    0x8(%ebp),%eax
  800949:	8a 00                	mov    (%eax),%al
  80094b:	84 c0                	test   %al,%al
  80094d:	75 f1                	jne    800940 <strlen+0xf>
		n++;
	return n;
  80094f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800952:	c9                   	leave  
  800953:	c3                   	ret    

00800954 <strnlen>:

int
strnlen(const char *s, uint32 size)
{
  800954:	55                   	push   %ebp
  800955:	89 e5                	mov    %esp,%ebp
  800957:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80095a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800961:	eb 09                	jmp    80096c <strnlen+0x18>
		n++;
  800963:	ff 45 fc             	incl   -0x4(%ebp)
int
strnlen(const char *s, uint32 size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800966:	ff 45 08             	incl   0x8(%ebp)
  800969:	ff 4d 0c             	decl   0xc(%ebp)
  80096c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800970:	74 09                	je     80097b <strnlen+0x27>
  800972:	8b 45 08             	mov    0x8(%ebp),%eax
  800975:	8a 00                	mov    (%eax),%al
  800977:	84 c0                	test   %al,%al
  800979:	75 e8                	jne    800963 <strnlen+0xf>
		n++;
	return n;
  80097b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80097e:	c9                   	leave  
  80097f:	c3                   	ret    

00800980 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800986:	8b 45 08             	mov    0x8(%ebp),%eax
  800989:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  80098c:	90                   	nop
  80098d:	8b 45 08             	mov    0x8(%ebp),%eax
  800990:	8d 50 01             	lea    0x1(%eax),%edx
  800993:	89 55 08             	mov    %edx,0x8(%ebp)
  800996:	8b 55 0c             	mov    0xc(%ebp),%edx
  800999:	8d 4a 01             	lea    0x1(%edx),%ecx
  80099c:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  80099f:	8a 12                	mov    (%edx),%dl
  8009a1:	88 10                	mov    %dl,(%eax)
  8009a3:	8a 00                	mov    (%eax),%al
  8009a5:	84 c0                	test   %al,%al
  8009a7:	75 e4                	jne    80098d <strcpy+0xd>
		/* do nothing */;
	return ret;
  8009a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8009ac:	c9                   	leave  
  8009ad:	c3                   	ret    

008009ae <strncpy>:

char *
strncpy(char *dst, const char *src, uint32 size) {
  8009ae:	55                   	push   %ebp
  8009af:	89 e5                	mov    %esp,%ebp
  8009b1:	83 ec 10             	sub    $0x10,%esp
	uint32 i;
	char *ret;

	ret = dst;
  8009b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b7:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  8009ba:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8009c1:	eb 1f                	jmp    8009e2 <strncpy+0x34>
		*dst++ = *src;
  8009c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c6:	8d 50 01             	lea    0x1(%eax),%edx
  8009c9:	89 55 08             	mov    %edx,0x8(%ebp)
  8009cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009cf:	8a 12                	mov    (%edx),%dl
  8009d1:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  8009d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d6:	8a 00                	mov    (%eax),%al
  8009d8:	84 c0                	test   %al,%al
  8009da:	74 03                	je     8009df <strncpy+0x31>
			src++;
  8009dc:	ff 45 0c             	incl   0xc(%ebp)
strncpy(char *dst, const char *src, uint32 size) {
	uint32 i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009df:	ff 45 fc             	incl   -0x4(%ebp)
  8009e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8009e5:	3b 45 10             	cmp    0x10(%ebp),%eax
  8009e8:	72 d9                	jb     8009c3 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  8009ea:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  8009ed:	c9                   	leave  
  8009ee:	c3                   	ret    

008009ef <strlcpy>:

uint32
strlcpy(char *dst, const char *src, uint32 size)
{
  8009ef:	55                   	push   %ebp
  8009f0:	89 e5                	mov    %esp,%ebp
  8009f2:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  8009f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f8:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  8009fb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009ff:	74 30                	je     800a31 <strlcpy+0x42>
		while (--size > 0 && *src != '\0')
  800a01:	eb 16                	jmp    800a19 <strlcpy+0x2a>
			*dst++ = *src++;
  800a03:	8b 45 08             	mov    0x8(%ebp),%eax
  800a06:	8d 50 01             	lea    0x1(%eax),%edx
  800a09:	89 55 08             	mov    %edx,0x8(%ebp)
  800a0c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800a12:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800a15:	8a 12                	mov    (%edx),%dl
  800a17:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a19:	ff 4d 10             	decl   0x10(%ebp)
  800a1c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a20:	74 09                	je     800a2b <strlcpy+0x3c>
  800a22:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a25:	8a 00                	mov    (%eax),%al
  800a27:	84 c0                	test   %al,%al
  800a29:	75 d8                	jne    800a03 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800a2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a31:	8b 55 08             	mov    0x8(%ebp),%edx
  800a34:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a37:	29 c2                	sub    %eax,%edx
  800a39:	89 d0                	mov    %edx,%eax
}
  800a3b:	c9                   	leave  
  800a3c:	c3                   	ret    

00800a3d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a3d:	55                   	push   %ebp
  800a3e:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800a40:	eb 06                	jmp    800a48 <strcmp+0xb>
		p++, q++;
  800a42:	ff 45 08             	incl   0x8(%ebp)
  800a45:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a48:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4b:	8a 00                	mov    (%eax),%al
  800a4d:	84 c0                	test   %al,%al
  800a4f:	74 0e                	je     800a5f <strcmp+0x22>
  800a51:	8b 45 08             	mov    0x8(%ebp),%eax
  800a54:	8a 10                	mov    (%eax),%dl
  800a56:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a59:	8a 00                	mov    (%eax),%al
  800a5b:	38 c2                	cmp    %al,%dl
  800a5d:	74 e3                	je     800a42 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a62:	8a 00                	mov    (%eax),%al
  800a64:	0f b6 d0             	movzbl %al,%edx
  800a67:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6a:	8a 00                	mov    (%eax),%al
  800a6c:	0f b6 c0             	movzbl %al,%eax
  800a6f:	29 c2                	sub    %eax,%edx
  800a71:	89 d0                	mov    %edx,%eax
}
  800a73:	5d                   	pop    %ebp
  800a74:	c3                   	ret    

00800a75 <strncmp>:

int
strncmp(const char *p, const char *q, uint32 n)
{
  800a75:	55                   	push   %ebp
  800a76:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800a78:	eb 09                	jmp    800a83 <strncmp+0xe>
		n--, p++, q++;
  800a7a:	ff 4d 10             	decl   0x10(%ebp)
  800a7d:	ff 45 08             	incl   0x8(%ebp)
  800a80:	ff 45 0c             	incl   0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint32 n)
{
	while (n > 0 && *p && *p == *q)
  800a83:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a87:	74 17                	je     800aa0 <strncmp+0x2b>
  800a89:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8c:	8a 00                	mov    (%eax),%al
  800a8e:	84 c0                	test   %al,%al
  800a90:	74 0e                	je     800aa0 <strncmp+0x2b>
  800a92:	8b 45 08             	mov    0x8(%ebp),%eax
  800a95:	8a 10                	mov    (%eax),%dl
  800a97:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9a:	8a 00                	mov    (%eax),%al
  800a9c:	38 c2                	cmp    %al,%dl
  800a9e:	74 da                	je     800a7a <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800aa0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800aa4:	75 07                	jne    800aad <strncmp+0x38>
		return 0;
  800aa6:	b8 00 00 00 00       	mov    $0x0,%eax
  800aab:	eb 14                	jmp    800ac1 <strncmp+0x4c>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800aad:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab0:	8a 00                	mov    (%eax),%al
  800ab2:	0f b6 d0             	movzbl %al,%edx
  800ab5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab8:	8a 00                	mov    (%eax),%al
  800aba:	0f b6 c0             	movzbl %al,%eax
  800abd:	29 c2                	sub    %eax,%edx
  800abf:	89 d0                	mov    %edx,%eax
}
  800ac1:	5d                   	pop    %ebp
  800ac2:	c3                   	ret    

00800ac3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ac3:	55                   	push   %ebp
  800ac4:	89 e5                	mov    %esp,%ebp
  800ac6:	83 ec 04             	sub    $0x4,%esp
  800ac9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800acc:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800acf:	eb 12                	jmp    800ae3 <strchr+0x20>
		if (*s == c)
  800ad1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad4:	8a 00                	mov    (%eax),%al
  800ad6:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800ad9:	75 05                	jne    800ae0 <strchr+0x1d>
			return (char *) s;
  800adb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ade:	eb 11                	jmp    800af1 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ae0:	ff 45 08             	incl   0x8(%ebp)
  800ae3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae6:	8a 00                	mov    (%eax),%al
  800ae8:	84 c0                	test   %al,%al
  800aea:	75 e5                	jne    800ad1 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800aec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af1:	c9                   	leave  
  800af2:	c3                   	ret    

00800af3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	83 ec 04             	sub    $0x4,%esp
  800af9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800afc:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800aff:	eb 0d                	jmp    800b0e <strfind+0x1b>
		if (*s == c)
  800b01:	8b 45 08             	mov    0x8(%ebp),%eax
  800b04:	8a 00                	mov    (%eax),%al
  800b06:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800b09:	74 0e                	je     800b19 <strfind+0x26>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b0b:	ff 45 08             	incl   0x8(%ebp)
  800b0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b11:	8a 00                	mov    (%eax),%al
  800b13:	84 c0                	test   %al,%al
  800b15:	75 ea                	jne    800b01 <strfind+0xe>
  800b17:	eb 01                	jmp    800b1a <strfind+0x27>
		if (*s == c)
			break;
  800b19:	90                   	nop
	return (char *) s;
  800b1a:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b1d:	c9                   	leave  
  800b1e:	c3                   	ret    

00800b1f <memset>:


void *
memset(void *v, int c, uint32 n)
{
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	83 ec 10             	sub    $0x10,%esp
	char *p;
	int m;

	p = v;
  800b25:	8b 45 08             	mov    0x8(%ebp),%eax
  800b28:	89 45 fc             	mov    %eax,-0x4(%ebp)
	m = n;
  800b2b:	8b 45 10             	mov    0x10(%ebp),%eax
  800b2e:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (--m >= 0)
  800b31:	eb 0e                	jmp    800b41 <memset+0x22>
		*p++ = c;
  800b33:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800b36:	8d 50 01             	lea    0x1(%eax),%edx
  800b39:	89 55 fc             	mov    %edx,-0x4(%ebp)
  800b3c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b3f:	88 10                	mov    %dl,(%eax)
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800b41:	ff 4d f8             	decl   -0x8(%ebp)
  800b44:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
  800b48:	79 e9                	jns    800b33 <memset+0x14>
		*p++ = c;

	return v;
  800b4a:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b4d:	c9                   	leave  
  800b4e:	c3                   	ret    

00800b4f <memcpy>:

void *
memcpy(void *dst, const void *src, uint32 n)
{
  800b4f:	55                   	push   %ebp
  800b50:	89 e5                	mov    %esp,%ebp
  800b52:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800b55:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b58:	89 45 fc             	mov    %eax,-0x4(%ebp)
	d = dst;
  800b5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5e:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (n-- > 0)
  800b61:	eb 16                	jmp    800b79 <memcpy+0x2a>
		*d++ = *s++;
  800b63:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800b66:	8d 50 01             	lea    0x1(%eax),%edx
  800b69:	89 55 f8             	mov    %edx,-0x8(%ebp)
  800b6c:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800b6f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800b72:	89 4d fc             	mov    %ecx,-0x4(%ebp)
  800b75:	8a 12                	mov    (%edx),%dl
  800b77:	88 10                	mov    %dl,(%eax)
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
  800b79:	8b 45 10             	mov    0x10(%ebp),%eax
  800b7c:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b7f:	89 55 10             	mov    %edx,0x10(%ebp)
  800b82:	85 c0                	test   %eax,%eax
  800b84:	75 dd                	jne    800b63 <memcpy+0x14>
		*d++ = *s++;

	return dst;
  800b86:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b89:	c9                   	leave  
  800b8a:	c3                   	ret    

00800b8b <memmove>:

void *
memmove(void *dst, const void *src, uint32 n)
{
  800b8b:	55                   	push   %ebp
  800b8c:	89 e5                	mov    %esp,%ebp
  800b8e:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800b91:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b94:	89 45 fc             	mov    %eax,-0x4(%ebp)
	d = dst;
  800b97:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9a:	89 45 f8             	mov    %eax,-0x8(%ebp)
	if (s < d && s + n > d) {
  800b9d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800ba0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  800ba3:	73 50                	jae    800bf5 <memmove+0x6a>
  800ba5:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800ba8:	8b 45 10             	mov    0x10(%ebp),%eax
  800bab:	01 d0                	add    %edx,%eax
  800bad:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  800bb0:	76 43                	jbe    800bf5 <memmove+0x6a>
		s += n;
  800bb2:	8b 45 10             	mov    0x10(%ebp),%eax
  800bb5:	01 45 fc             	add    %eax,-0x4(%ebp)
		d += n;
  800bb8:	8b 45 10             	mov    0x10(%ebp),%eax
  800bbb:	01 45 f8             	add    %eax,-0x8(%ebp)
		while (n-- > 0)
  800bbe:	eb 10                	jmp    800bd0 <memmove+0x45>
			*--d = *--s;
  800bc0:	ff 4d f8             	decl   -0x8(%ebp)
  800bc3:	ff 4d fc             	decl   -0x4(%ebp)
  800bc6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bc9:	8a 10                	mov    (%eax),%dl
  800bcb:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800bce:	88 10                	mov    %dl,(%eax)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  800bd0:	8b 45 10             	mov    0x10(%ebp),%eax
  800bd3:	8d 50 ff             	lea    -0x1(%eax),%edx
  800bd6:	89 55 10             	mov    %edx,0x10(%ebp)
  800bd9:	85 c0                	test   %eax,%eax
  800bdb:	75 e3                	jne    800bc0 <memmove+0x35>
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bdd:	eb 23                	jmp    800c02 <memmove+0x77>
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  800bdf:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800be2:	8d 50 01             	lea    0x1(%eax),%edx
  800be5:	89 55 f8             	mov    %edx,-0x8(%ebp)
  800be8:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800beb:	8d 4a 01             	lea    0x1(%edx),%ecx
  800bee:	89 4d fc             	mov    %ecx,-0x4(%ebp)
  800bf1:	8a 12                	mov    (%edx),%dl
  800bf3:	88 10                	mov    %dl,(%eax)
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800bf5:	8b 45 10             	mov    0x10(%ebp),%eax
  800bf8:	8d 50 ff             	lea    -0x1(%eax),%edx
  800bfb:	89 55 10             	mov    %edx,0x10(%ebp)
  800bfe:	85 c0                	test   %eax,%eax
  800c00:	75 dd                	jne    800bdf <memmove+0x54>
			*d++ = *s++;

	return dst;
  800c02:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c05:	c9                   	leave  
  800c06:	c3                   	ret    

00800c07 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint32 n)
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	83 ec 10             	sub    $0x10,%esp
	const uint8 *s1 = (const uint8 *) v1;
  800c0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c10:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8 *s2 = (const uint8 *) v2;
  800c13:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c16:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800c19:	eb 2a                	jmp    800c45 <memcmp+0x3e>
		if (*s1 != *s2)
  800c1b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c1e:	8a 10                	mov    (%eax),%dl
  800c20:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c23:	8a 00                	mov    (%eax),%al
  800c25:	38 c2                	cmp    %al,%dl
  800c27:	74 16                	je     800c3f <memcmp+0x38>
			return (int) *s1 - (int) *s2;
  800c29:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c2c:	8a 00                	mov    (%eax),%al
  800c2e:	0f b6 d0             	movzbl %al,%edx
  800c31:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c34:	8a 00                	mov    (%eax),%al
  800c36:	0f b6 c0             	movzbl %al,%eax
  800c39:	29 c2                	sub    %eax,%edx
  800c3b:	89 d0                	mov    %edx,%eax
  800c3d:	eb 18                	jmp    800c57 <memcmp+0x50>
		s1++, s2++;
  800c3f:	ff 45 fc             	incl   -0x4(%ebp)
  800c42:	ff 45 f8             	incl   -0x8(%ebp)
memcmp(const void *v1, const void *v2, uint32 n)
{
	const uint8 *s1 = (const uint8 *) v1;
	const uint8 *s2 = (const uint8 *) v2;

	while (n-- > 0) {
  800c45:	8b 45 10             	mov    0x10(%ebp),%eax
  800c48:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c4b:	89 55 10             	mov    %edx,0x10(%ebp)
  800c4e:	85 c0                	test   %eax,%eax
  800c50:	75 c9                	jne    800c1b <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c52:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c57:	c9                   	leave  
  800c58:	c3                   	ret    

00800c59 <memfind>:

void *
memfind(const void *s, int c, uint32 n)
{
  800c59:	55                   	push   %ebp
  800c5a:	89 e5                	mov    %esp,%ebp
  800c5c:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800c5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c62:	8b 45 10             	mov    0x10(%ebp),%eax
  800c65:	01 d0                	add    %edx,%eax
  800c67:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800c6a:	eb 15                	jmp    800c81 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6f:	8a 00                	mov    (%eax),%al
  800c71:	0f b6 d0             	movzbl %al,%edx
  800c74:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c77:	0f b6 c0             	movzbl %al,%eax
  800c7a:	39 c2                	cmp    %eax,%edx
  800c7c:	74 0d                	je     800c8b <memfind+0x32>

void *
memfind(const void *s, int c, uint32 n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c7e:	ff 45 08             	incl   0x8(%ebp)
  800c81:	8b 45 08             	mov    0x8(%ebp),%eax
  800c84:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800c87:	72 e3                	jb     800c6c <memfind+0x13>
  800c89:	eb 01                	jmp    800c8c <memfind+0x33>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
  800c8b:	90                   	nop
	return (void *) s;
  800c8c:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c8f:	c9                   	leave  
  800c90:	c3                   	ret    

00800c91 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c91:	55                   	push   %ebp
  800c92:	89 e5                	mov    %esp,%ebp
  800c94:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800c97:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800c9e:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ca5:	eb 03                	jmp    800caa <strtol+0x19>
		s++;
  800ca7:	ff 45 08             	incl   0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800caa:	8b 45 08             	mov    0x8(%ebp),%eax
  800cad:	8a 00                	mov    (%eax),%al
  800caf:	3c 20                	cmp    $0x20,%al
  800cb1:	74 f4                	je     800ca7 <strtol+0x16>
  800cb3:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb6:	8a 00                	mov    (%eax),%al
  800cb8:	3c 09                	cmp    $0x9,%al
  800cba:	74 eb                	je     800ca7 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cbc:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbf:	8a 00                	mov    (%eax),%al
  800cc1:	3c 2b                	cmp    $0x2b,%al
  800cc3:	75 05                	jne    800cca <strtol+0x39>
		s++;
  800cc5:	ff 45 08             	incl   0x8(%ebp)
  800cc8:	eb 13                	jmp    800cdd <strtol+0x4c>
	else if (*s == '-')
  800cca:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccd:	8a 00                	mov    (%eax),%al
  800ccf:	3c 2d                	cmp    $0x2d,%al
  800cd1:	75 0a                	jne    800cdd <strtol+0x4c>
		s++, neg = 1;
  800cd3:	ff 45 08             	incl   0x8(%ebp)
  800cd6:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cdd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ce1:	74 06                	je     800ce9 <strtol+0x58>
  800ce3:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800ce7:	75 20                	jne    800d09 <strtol+0x78>
  800ce9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cec:	8a 00                	mov    (%eax),%al
  800cee:	3c 30                	cmp    $0x30,%al
  800cf0:	75 17                	jne    800d09 <strtol+0x78>
  800cf2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf5:	40                   	inc    %eax
  800cf6:	8a 00                	mov    (%eax),%al
  800cf8:	3c 78                	cmp    $0x78,%al
  800cfa:	75 0d                	jne    800d09 <strtol+0x78>
		s += 2, base = 16;
  800cfc:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800d00:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800d07:	eb 28                	jmp    800d31 <strtol+0xa0>
	else if (base == 0 && s[0] == '0')
  800d09:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d0d:	75 15                	jne    800d24 <strtol+0x93>
  800d0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d12:	8a 00                	mov    (%eax),%al
  800d14:	3c 30                	cmp    $0x30,%al
  800d16:	75 0c                	jne    800d24 <strtol+0x93>
		s++, base = 8;
  800d18:	ff 45 08             	incl   0x8(%ebp)
  800d1b:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800d22:	eb 0d                	jmp    800d31 <strtol+0xa0>
	else if (base == 0)
  800d24:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d28:	75 07                	jne    800d31 <strtol+0xa0>
		base = 10;
  800d2a:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d31:	8b 45 08             	mov    0x8(%ebp),%eax
  800d34:	8a 00                	mov    (%eax),%al
  800d36:	3c 2f                	cmp    $0x2f,%al
  800d38:	7e 19                	jle    800d53 <strtol+0xc2>
  800d3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3d:	8a 00                	mov    (%eax),%al
  800d3f:	3c 39                	cmp    $0x39,%al
  800d41:	7f 10                	jg     800d53 <strtol+0xc2>
			dig = *s - '0';
  800d43:	8b 45 08             	mov    0x8(%ebp),%eax
  800d46:	8a 00                	mov    (%eax),%al
  800d48:	0f be c0             	movsbl %al,%eax
  800d4b:	83 e8 30             	sub    $0x30,%eax
  800d4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d51:	eb 42                	jmp    800d95 <strtol+0x104>
		else if (*s >= 'a' && *s <= 'z')
  800d53:	8b 45 08             	mov    0x8(%ebp),%eax
  800d56:	8a 00                	mov    (%eax),%al
  800d58:	3c 60                	cmp    $0x60,%al
  800d5a:	7e 19                	jle    800d75 <strtol+0xe4>
  800d5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5f:	8a 00                	mov    (%eax),%al
  800d61:	3c 7a                	cmp    $0x7a,%al
  800d63:	7f 10                	jg     800d75 <strtol+0xe4>
			dig = *s - 'a' + 10;
  800d65:	8b 45 08             	mov    0x8(%ebp),%eax
  800d68:	8a 00                	mov    (%eax),%al
  800d6a:	0f be c0             	movsbl %al,%eax
  800d6d:	83 e8 57             	sub    $0x57,%eax
  800d70:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d73:	eb 20                	jmp    800d95 <strtol+0x104>
		else if (*s >= 'A' && *s <= 'Z')
  800d75:	8b 45 08             	mov    0x8(%ebp),%eax
  800d78:	8a 00                	mov    (%eax),%al
  800d7a:	3c 40                	cmp    $0x40,%al
  800d7c:	7e 39                	jle    800db7 <strtol+0x126>
  800d7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d81:	8a 00                	mov    (%eax),%al
  800d83:	3c 5a                	cmp    $0x5a,%al
  800d85:	7f 30                	jg     800db7 <strtol+0x126>
			dig = *s - 'A' + 10;
  800d87:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8a:	8a 00                	mov    (%eax),%al
  800d8c:	0f be c0             	movsbl %al,%eax
  800d8f:	83 e8 37             	sub    $0x37,%eax
  800d92:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800d95:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d98:	3b 45 10             	cmp    0x10(%ebp),%eax
  800d9b:	7d 19                	jge    800db6 <strtol+0x125>
			break;
		s++, val = (val * base) + dig;
  800d9d:	ff 45 08             	incl   0x8(%ebp)
  800da0:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800da3:	0f af 45 10          	imul   0x10(%ebp),%eax
  800da7:	89 c2                	mov    %eax,%edx
  800da9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dac:	01 d0                	add    %edx,%eax
  800dae:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800db1:	e9 7b ff ff ff       	jmp    800d31 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
			break;
  800db6:	90                   	nop
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800db7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dbb:	74 08                	je     800dc5 <strtol+0x134>
		*endptr = (char *) s;
  800dbd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc3:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800dc5:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800dc9:	74 07                	je     800dd2 <strtol+0x141>
  800dcb:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800dce:	f7 d8                	neg    %eax
  800dd0:	eb 03                	jmp    800dd5 <strtol+0x144>
  800dd2:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800dd5:	c9                   	leave  
  800dd6:	c3                   	ret    

00800dd7 <ltostr>:

void
ltostr(long value, char *str)
{
  800dd7:	55                   	push   %ebp
  800dd8:	89 e5                	mov    %esp,%ebp
  800dda:	83 ec 20             	sub    $0x20,%esp
	int neg = 0;
  800ddd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	int s = 0 ;
  800de4:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// plus/minus sign
	if (value < 0)
  800deb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800def:	79 13                	jns    800e04 <ltostr+0x2d>
	{
		neg = 1;
  800df1:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
		str[0] = '-';
  800df8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dfb:	c6 00 2d             	movb   $0x2d,(%eax)
		value = value * -1 ;
  800dfe:	f7 5d 08             	negl   0x8(%ebp)
		s++ ;
  800e01:	ff 45 f8             	incl   -0x8(%ebp)
	}
	do
	{
		int mod = value % 10 ;
  800e04:	8b 45 08             	mov    0x8(%ebp),%eax
  800e07:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800e0c:	99                   	cltd   
  800e0d:	f7 f9                	idiv   %ecx
  800e0f:	89 55 ec             	mov    %edx,-0x14(%ebp)
		str[s++] = mod + '0' ;
  800e12:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e15:	8d 50 01             	lea    0x1(%eax),%edx
  800e18:	89 55 f8             	mov    %edx,-0x8(%ebp)
  800e1b:	89 c2                	mov    %eax,%edx
  800e1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e20:	01 d0                	add    %edx,%eax
  800e22:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800e25:	83 c2 30             	add    $0x30,%edx
  800e28:	88 10                	mov    %dl,(%eax)
		value = value / 10 ;
  800e2a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e2d:	b8 67 66 66 66       	mov    $0x66666667,%eax
  800e32:	f7 e9                	imul   %ecx
  800e34:	c1 fa 02             	sar    $0x2,%edx
  800e37:	89 c8                	mov    %ecx,%eax
  800e39:	c1 f8 1f             	sar    $0x1f,%eax
  800e3c:	29 c2                	sub    %eax,%edx
  800e3e:	89 d0                	mov    %edx,%eax
  800e40:	89 45 08             	mov    %eax,0x8(%ebp)
	} while (value % 10 != 0);
  800e43:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e46:	b8 67 66 66 66       	mov    $0x66666667,%eax
  800e4b:	f7 e9                	imul   %ecx
  800e4d:	c1 fa 02             	sar    $0x2,%edx
  800e50:	89 c8                	mov    %ecx,%eax
  800e52:	c1 f8 1f             	sar    $0x1f,%eax
  800e55:	29 c2                	sub    %eax,%edx
  800e57:	89 d0                	mov    %edx,%eax
  800e59:	c1 e0 02             	shl    $0x2,%eax
  800e5c:	01 d0                	add    %edx,%eax
  800e5e:	01 c0                	add    %eax,%eax
  800e60:	29 c1                	sub    %eax,%ecx
  800e62:	89 ca                	mov    %ecx,%edx
  800e64:	85 d2                	test   %edx,%edx
  800e66:	75 9c                	jne    800e04 <ltostr+0x2d>

	//reverse the string
	int start = 0 ;
  800e68:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	int end = s-1 ;
  800e6f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e72:	48                   	dec    %eax
  800e73:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (neg)
  800e76:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800e7a:	74 3d                	je     800eb9 <ltostr+0xe2>
		start = 1 ;
  800e7c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	while(start<end)
  800e83:	eb 34                	jmp    800eb9 <ltostr+0xe2>
	{
		char tmp = str[start] ;
  800e85:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e88:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e8b:	01 d0                	add    %edx,%eax
  800e8d:	8a 00                	mov    (%eax),%al
  800e8f:	88 45 eb             	mov    %al,-0x15(%ebp)
		str[start] = str[end] ;
  800e92:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e95:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e98:	01 c2                	add    %eax,%edx
  800e9a:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  800e9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ea0:	01 c8                	add    %ecx,%eax
  800ea2:	8a 00                	mov    (%eax),%al
  800ea4:	88 02                	mov    %al,(%edx)
		str[end] = tmp;
  800ea6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ea9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eac:	01 c2                	add    %eax,%edx
  800eae:	8a 45 eb             	mov    -0x15(%ebp),%al
  800eb1:	88 02                	mov    %al,(%edx)
		start++ ;
  800eb3:	ff 45 f4             	incl   -0xc(%ebp)
		end-- ;
  800eb6:	ff 4d f0             	decl   -0x10(%ebp)
	//reverse the string
	int start = 0 ;
	int end = s-1 ;
	if (neg)
		start = 1 ;
	while(start<end)
  800eb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ebc:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800ebf:	7c c4                	jl     800e85 <ltostr+0xae>
		str[end] = tmp;
		start++ ;
		end-- ;
	}

	str[s] = 0 ;
  800ec1:	8b 55 f8             	mov    -0x8(%ebp),%edx
  800ec4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ec7:	01 d0                	add    %edx,%eax
  800ec9:	c6 00 00             	movb   $0x0,(%eax)
	// we don't properly detect overflow!

}
  800ecc:	90                   	nop
  800ecd:	c9                   	leave  
  800ece:	c3                   	ret    

00800ecf <strcconcat>:

void
strcconcat(const char *str1, const char *str2, char *final)
{
  800ecf:	55                   	push   %ebp
  800ed0:	89 e5                	mov    %esp,%ebp
  800ed2:	83 ec 10             	sub    $0x10,%esp
	int len1 = strlen(str1);
  800ed5:	ff 75 08             	pushl  0x8(%ebp)
  800ed8:	e8 54 fa ff ff       	call   800931 <strlen>
  800edd:	83 c4 04             	add    $0x4,%esp
  800ee0:	89 45 f4             	mov    %eax,-0xc(%ebp)
	int len2 = strlen(str2);
  800ee3:	ff 75 0c             	pushl  0xc(%ebp)
  800ee6:	e8 46 fa ff ff       	call   800931 <strlen>
  800eeb:	83 c4 04             	add    $0x4,%esp
  800eee:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int s = 0 ;
  800ef1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	for (s=0 ; s < len1 ; s++)
  800ef8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800eff:	eb 17                	jmp    800f18 <strcconcat+0x49>
		final[s] = str1[s] ;
  800f01:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800f04:	8b 45 10             	mov    0x10(%ebp),%eax
  800f07:	01 c2                	add    %eax,%edx
  800f09:	8b 4d fc             	mov    -0x4(%ebp),%ecx
  800f0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0f:	01 c8                	add    %ecx,%eax
  800f11:	8a 00                	mov    (%eax),%al
  800f13:	88 02                	mov    %al,(%edx)
strcconcat(const char *str1, const char *str2, char *final)
{
	int len1 = strlen(str1);
	int len2 = strlen(str2);
	int s = 0 ;
	for (s=0 ; s < len1 ; s++)
  800f15:	ff 45 fc             	incl   -0x4(%ebp)
  800f18:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800f1b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  800f1e:	7c e1                	jl     800f01 <strcconcat+0x32>
		final[s] = str1[s] ;

	int i = 0 ;
  800f20:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
	for (i=0 ; i < len2 ; i++)
  800f27:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  800f2e:	eb 1f                	jmp    800f4f <strcconcat+0x80>
		final[s++] = str2[i] ;
  800f30:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800f33:	8d 50 01             	lea    0x1(%eax),%edx
  800f36:	89 55 fc             	mov    %edx,-0x4(%ebp)
  800f39:	89 c2                	mov    %eax,%edx
  800f3b:	8b 45 10             	mov    0x10(%ebp),%eax
  800f3e:	01 c2                	add    %eax,%edx
  800f40:	8b 4d f8             	mov    -0x8(%ebp),%ecx
  800f43:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f46:	01 c8                	add    %ecx,%eax
  800f48:	8a 00                	mov    (%eax),%al
  800f4a:	88 02                	mov    %al,(%edx)
	int s = 0 ;
	for (s=0 ; s < len1 ; s++)
		final[s] = str1[s] ;

	int i = 0 ;
	for (i=0 ; i < len2 ; i++)
  800f4c:	ff 45 f8             	incl   -0x8(%ebp)
  800f4f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800f52:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800f55:	7c d9                	jl     800f30 <strcconcat+0x61>
		final[s++] = str2[i] ;

	final[s] = 0;
  800f57:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800f5a:	8b 45 10             	mov    0x10(%ebp),%eax
  800f5d:	01 d0                	add    %edx,%eax
  800f5f:	c6 00 00             	movb   $0x0,(%eax)
}
  800f62:	90                   	nop
  800f63:	c9                   	leave  
  800f64:	c3                   	ret    

00800f65 <strsplit>:
int strsplit(char *string, char *SPLIT_CHARS, char **argv, int * argc)
{
  800f65:	55                   	push   %ebp
  800f66:	89 e5                	mov    %esp,%ebp
	// Parse the command string into splitchars-separated arguments
	*argc = 0;
  800f68:	8b 45 14             	mov    0x14(%ebp),%eax
  800f6b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	(argv)[*argc] = 0;
  800f71:	8b 45 14             	mov    0x14(%ebp),%eax
  800f74:	8b 00                	mov    (%eax),%eax
  800f76:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800f7d:	8b 45 10             	mov    0x10(%ebp),%eax
  800f80:	01 d0                	add    %edx,%eax
  800f82:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	while (1)
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
  800f88:	eb 0c                	jmp    800f96 <strsplit+0x31>
			*string++ = 0;
  800f8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8d:	8d 50 01             	lea    0x1(%eax),%edx
  800f90:	89 55 08             	mov    %edx,0x8(%ebp)
  800f93:	c6 00 00             	movb   $0x0,(%eax)
	*argc = 0;
	(argv)[*argc] = 0;
	while (1)
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
  800f96:	8b 45 08             	mov    0x8(%ebp),%eax
  800f99:	8a 00                	mov    (%eax),%al
  800f9b:	84 c0                	test   %al,%al
  800f9d:	74 18                	je     800fb7 <strsplit+0x52>
  800f9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa2:	8a 00                	mov    (%eax),%al
  800fa4:	0f be c0             	movsbl %al,%eax
  800fa7:	50                   	push   %eax
  800fa8:	ff 75 0c             	pushl  0xc(%ebp)
  800fab:	e8 13 fb ff ff       	call   800ac3 <strchr>
  800fb0:	83 c4 08             	add    $0x8,%esp
  800fb3:	85 c0                	test   %eax,%eax
  800fb5:	75 d3                	jne    800f8a <strsplit+0x25>
			*string++ = 0;

		//if the command string is finished, then break the loop
		if (*string == 0)
  800fb7:	8b 45 08             	mov    0x8(%ebp),%eax
  800fba:	8a 00                	mov    (%eax),%al
  800fbc:	84 c0                	test   %al,%al
  800fbe:	74 5a                	je     80101a <strsplit+0xb5>
			break;

		//check current number of arguments
		if (*argc == MAX_ARGUMENTS-1)
  800fc0:	8b 45 14             	mov    0x14(%ebp),%eax
  800fc3:	8b 00                	mov    (%eax),%eax
  800fc5:	83 f8 0f             	cmp    $0xf,%eax
  800fc8:	75 07                	jne    800fd1 <strsplit+0x6c>
		{
			return 0;
  800fca:	b8 00 00 00 00       	mov    $0x0,%eax
  800fcf:	eb 66                	jmp    801037 <strsplit+0xd2>
		}

		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
  800fd1:	8b 45 14             	mov    0x14(%ebp),%eax
  800fd4:	8b 00                	mov    (%eax),%eax
  800fd6:	8d 48 01             	lea    0x1(%eax),%ecx
  800fd9:	8b 55 14             	mov    0x14(%ebp),%edx
  800fdc:	89 0a                	mov    %ecx,(%edx)
  800fde:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800fe5:	8b 45 10             	mov    0x10(%ebp),%eax
  800fe8:	01 c2                	add    %eax,%edx
  800fea:	8b 45 08             	mov    0x8(%ebp),%eax
  800fed:	89 02                	mov    %eax,(%edx)
		while (*string && !strchr(SPLIT_CHARS, *string))
  800fef:	eb 03                	jmp    800ff4 <strsplit+0x8f>
			string++;
  800ff1:	ff 45 08             	incl   0x8(%ebp)
			return 0;
		}

		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
		while (*string && !strchr(SPLIT_CHARS, *string))
  800ff4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff7:	8a 00                	mov    (%eax),%al
  800ff9:	84 c0                	test   %al,%al
  800ffb:	74 8b                	je     800f88 <strsplit+0x23>
  800ffd:	8b 45 08             	mov    0x8(%ebp),%eax
  801000:	8a 00                	mov    (%eax),%al
  801002:	0f be c0             	movsbl %al,%eax
  801005:	50                   	push   %eax
  801006:	ff 75 0c             	pushl  0xc(%ebp)
  801009:	e8 b5 fa ff ff       	call   800ac3 <strchr>
  80100e:	83 c4 08             	add    $0x8,%esp
  801011:	85 c0                	test   %eax,%eax
  801013:	74 dc                	je     800ff1 <strsplit+0x8c>
			string++;
	}
  801015:	e9 6e ff ff ff       	jmp    800f88 <strsplit+0x23>
		while (*string && strchr(SPLIT_CHARS, *string))
			*string++ = 0;

		//if the command string is finished, then break the loop
		if (*string == 0)
			break;
  80101a:	90                   	nop
		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
		while (*string && !strchr(SPLIT_CHARS, *string))
			string++;
	}
	(argv)[*argc] = 0;
  80101b:	8b 45 14             	mov    0x14(%ebp),%eax
  80101e:	8b 00                	mov    (%eax),%eax
  801020:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801027:	8b 45 10             	mov    0x10(%ebp),%eax
  80102a:	01 d0                	add    %edx,%eax
  80102c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return 1 ;
  801032:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801037:	c9                   	leave  
  801038:	c3                   	ret    

00801039 <str2lower>:


/*2024*/
char* str2lower(char *dst, const char *src)
{
  801039:	55                   	push   %ebp
  80103a:	89 e5                	mov    %esp,%ebp
  80103c:	83 ec 20             	sub    $0x20,%esp
	//TODO: [PROJECT'23.MS1 - #1] [1] PLAY WITH CODE! - str2lower
	//Comment the following line before start coding...
	//panic("process_command is not implemented yet");
	long long size = strlen(src);
  80103f:	ff 75 0c             	pushl  0xc(%ebp)
  801042:	e8 ea f8 ff ff       	call   800931 <strlen>
  801047:	83 c4 04             	add    $0x4,%esp
  80104a:	99                   	cltd   
  80104b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80104e:	89 55 f4             	mov    %edx,-0xc(%ebp)
	for(long long i=0;i<size;i++)
  801051:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  801058:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80105f:	eb 57                	jmp    8010b8 <str2lower+0x7f>
	{
		if(src[i] >=65 && src[i] <=90)
  801061:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801064:	8b 45 0c             	mov    0xc(%ebp),%eax
  801067:	01 d0                	add    %edx,%eax
  801069:	8a 00                	mov    (%eax),%al
  80106b:	3c 40                	cmp    $0x40,%al
  80106d:	7e 2d                	jle    80109c <str2lower+0x63>
  80106f:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801072:	8b 45 0c             	mov    0xc(%ebp),%eax
  801075:	01 d0                	add    %edx,%eax
  801077:	8a 00                	mov    (%eax),%al
  801079:	3c 5a                	cmp    $0x5a,%al
  80107b:	7f 1f                	jg     80109c <str2lower+0x63>
		{
			char temp = src[i] + 32;
  80107d:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801080:	8b 45 0c             	mov    0xc(%ebp),%eax
  801083:	01 d0                	add    %edx,%eax
  801085:	8a 00                	mov    (%eax),%al
  801087:	83 c0 20             	add    $0x20,%eax
  80108a:	88 45 ef             	mov    %al,-0x11(%ebp)
			dst[i] = temp;
  80108d:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801090:	8b 45 08             	mov    0x8(%ebp),%eax
  801093:	01 c2                	add    %eax,%edx
  801095:	8a 45 ef             	mov    -0x11(%ebp),%al
  801098:	88 02                	mov    %al,(%edx)
	//panic("process_command is not implemented yet");
	long long size = strlen(src);
	for(long long i=0;i<size;i++)
	{
		if(src[i] >=65 && src[i] <=90)
		{
  80109a:	eb 14                	jmp    8010b0 <str2lower+0x77>
			char temp = src[i] + 32;
			dst[i] = temp;
		}
		else
		{
			dst[i] = src[i];
  80109c:	8b 55 f8             	mov    -0x8(%ebp),%edx
  80109f:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a2:	01 c2                	add    %eax,%edx
  8010a4:	8b 4d f8             	mov    -0x8(%ebp),%ecx
  8010a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010aa:	01 c8                	add    %ecx,%eax
  8010ac:	8a 00                	mov    (%eax),%al
  8010ae:	88 02                	mov    %al,(%edx)
{
	//TODO: [PROJECT'23.MS1 - #1] [1] PLAY WITH CODE! - str2lower
	//Comment the following line before start coding...
	//panic("process_command is not implemented yet");
	long long size = strlen(src);
	for(long long i=0;i<size;i++)
  8010b0:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  8010b4:	83 55 fc 00          	adcl   $0x0,-0x4(%ebp)
  8010b8:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8010bb:	8b 55 fc             	mov    -0x4(%ebp),%edx
  8010be:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8010c1:	7c 9e                	jl     801061 <str2lower+0x28>
  8010c3:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8010c6:	7f 05                	jg     8010cd <str2lower+0x94>
  8010c8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8010cb:	72 94                	jb     801061 <str2lower+0x28>
		else
		{
			dst[i] = src[i];
		}
	}
	return dst;
  8010cd:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8010d0:	c9                   	leave  
  8010d1:	c3                   	ret    

008010d2 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline uint32
syscall(int num, uint32 a1, uint32 a2, uint32 a3, uint32 a4, uint32 a5)
{
  8010d2:	55                   	push   %ebp
  8010d3:	89 e5                	mov    %esp,%ebp
  8010d5:	57                   	push   %edi
  8010d6:	56                   	push   %esi
  8010d7:	53                   	push   %ebx
  8010d8:	83 ec 10             	sub    $0x10,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010db:	8b 45 08             	mov    0x8(%ebp),%eax
  8010de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010e1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8010e4:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8010e7:	8b 7d 18             	mov    0x18(%ebp),%edi
  8010ea:	8b 75 1c             	mov    0x1c(%ebp),%esi
  8010ed:	cd 30                	int    $0x30
  8010ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	return ret;
  8010f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  8010f5:	83 c4 10             	add    $0x10,%esp
  8010f8:	5b                   	pop    %ebx
  8010f9:	5e                   	pop    %esi
  8010fa:	5f                   	pop    %edi
  8010fb:	5d                   	pop    %ebp
  8010fc:	c3                   	ret    

008010fd <sys_cputs>:

void
sys_cputs(const char *s, uint32 len, uint8 printProgName)
{
  8010fd:	55                   	push   %ebp
  8010fe:	89 e5                	mov    %esp,%ebp
  801100:	83 ec 04             	sub    $0x4,%esp
  801103:	8b 45 10             	mov    0x10(%ebp),%eax
  801106:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_cputs, (uint32) s, len, (uint32)printProgName, 0, 0);
  801109:	0f b6 55 fc          	movzbl -0x4(%ebp),%edx
  80110d:	8b 45 08             	mov    0x8(%ebp),%eax
  801110:	6a 00                	push   $0x0
  801112:	6a 00                	push   $0x0
  801114:	52                   	push   %edx
  801115:	ff 75 0c             	pushl  0xc(%ebp)
  801118:	50                   	push   %eax
  801119:	6a 00                	push   $0x0
  80111b:	e8 b2 ff ff ff       	call   8010d2 <syscall>
  801120:	83 c4 18             	add    $0x18,%esp
}
  801123:	90                   	nop
  801124:	c9                   	leave  
  801125:	c3                   	ret    

00801126 <sys_cgetc>:

int
sys_cgetc(void)
{
  801126:	55                   	push   %ebp
  801127:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0);
  801129:	6a 00                	push   $0x0
  80112b:	6a 00                	push   $0x0
  80112d:	6a 00                	push   $0x0
  80112f:	6a 00                	push   $0x0
  801131:	6a 00                	push   $0x0
  801133:	6a 01                	push   $0x1
  801135:	e8 98 ff ff ff       	call   8010d2 <syscall>
  80113a:	83 c4 18             	add    $0x18,%esp
}
  80113d:	c9                   	leave  
  80113e:	c3                   	ret    

0080113f <__sys_allocate_page>:

int __sys_allocate_page(void *va, int perm)
{
  80113f:	55                   	push   %ebp
  801140:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_allocate_page, (uint32) va, perm, 0 , 0, 0);
  801142:	8b 55 0c             	mov    0xc(%ebp),%edx
  801145:	8b 45 08             	mov    0x8(%ebp),%eax
  801148:	6a 00                	push   $0x0
  80114a:	6a 00                	push   $0x0
  80114c:	6a 00                	push   $0x0
  80114e:	52                   	push   %edx
  80114f:	50                   	push   %eax
  801150:	6a 05                	push   $0x5
  801152:	e8 7b ff ff ff       	call   8010d2 <syscall>
  801157:	83 c4 18             	add    $0x18,%esp
}
  80115a:	c9                   	leave  
  80115b:	c3                   	ret    

0080115c <__sys_map_frame>:

int __sys_map_frame(int32 srcenv, void *srcva, int32 dstenv, void *dstva, int perm)
{
  80115c:	55                   	push   %ebp
  80115d:	89 e5                	mov    %esp,%ebp
  80115f:	56                   	push   %esi
  801160:	53                   	push   %ebx
	return syscall(SYS_map_frame, srcenv, (uint32) srcva, dstenv, (uint32) dstva, perm);
  801161:	8b 75 18             	mov    0x18(%ebp),%esi
  801164:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801167:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80116a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80116d:	8b 45 08             	mov    0x8(%ebp),%eax
  801170:	56                   	push   %esi
  801171:	53                   	push   %ebx
  801172:	51                   	push   %ecx
  801173:	52                   	push   %edx
  801174:	50                   	push   %eax
  801175:	6a 06                	push   $0x6
  801177:	e8 56 ff ff ff       	call   8010d2 <syscall>
  80117c:	83 c4 18             	add    $0x18,%esp
}
  80117f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801182:	5b                   	pop    %ebx
  801183:	5e                   	pop    %esi
  801184:	5d                   	pop    %ebp
  801185:	c3                   	ret    

00801186 <__sys_unmap_frame>:

int __sys_unmap_frame(int32 envid, void *va)
{
  801186:	55                   	push   %ebp
  801187:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_unmap_frame, envid, (uint32) va, 0, 0, 0);
  801189:	8b 55 0c             	mov    0xc(%ebp),%edx
  80118c:	8b 45 08             	mov    0x8(%ebp),%eax
  80118f:	6a 00                	push   $0x0
  801191:	6a 00                	push   $0x0
  801193:	6a 00                	push   $0x0
  801195:	52                   	push   %edx
  801196:	50                   	push   %eax
  801197:	6a 07                	push   $0x7
  801199:	e8 34 ff ff ff       	call   8010d2 <syscall>
  80119e:	83 c4 18             	add    $0x18,%esp
}
  8011a1:	c9                   	leave  
  8011a2:	c3                   	ret    

008011a3 <sys_calculate_required_frames>:

uint32 sys_calculate_required_frames(uint32 start_virtual_address, uint32 size)
{
  8011a3:	55                   	push   %ebp
  8011a4:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_req_frames, start_virtual_address, (uint32) size, 0, 0, 0);
  8011a6:	6a 00                	push   $0x0
  8011a8:	6a 00                	push   $0x0
  8011aa:	6a 00                	push   $0x0
  8011ac:	ff 75 0c             	pushl  0xc(%ebp)
  8011af:	ff 75 08             	pushl  0x8(%ebp)
  8011b2:	6a 08                	push   $0x8
  8011b4:	e8 19 ff ff ff       	call   8010d2 <syscall>
  8011b9:	83 c4 18             	add    $0x18,%esp
}
  8011bc:	c9                   	leave  
  8011bd:	c3                   	ret    

008011be <sys_calculate_free_frames>:

uint32 sys_calculate_free_frames()
{
  8011be:	55                   	push   %ebp
  8011bf:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_free_frames, 0, 0, 0, 0, 0);
  8011c1:	6a 00                	push   $0x0
  8011c3:	6a 00                	push   $0x0
  8011c5:	6a 00                	push   $0x0
  8011c7:	6a 00                	push   $0x0
  8011c9:	6a 00                	push   $0x0
  8011cb:	6a 09                	push   $0x9
  8011cd:	e8 00 ff ff ff       	call   8010d2 <syscall>
  8011d2:	83 c4 18             	add    $0x18,%esp
}
  8011d5:	c9                   	leave  
  8011d6:	c3                   	ret    

008011d7 <sys_calculate_modified_frames>:
uint32 sys_calculate_modified_frames()
{
  8011d7:	55                   	push   %ebp
  8011d8:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_modified_frames, 0, 0, 0, 0, 0);
  8011da:	6a 00                	push   $0x0
  8011dc:	6a 00                	push   $0x0
  8011de:	6a 00                	push   $0x0
  8011e0:	6a 00                	push   $0x0
  8011e2:	6a 00                	push   $0x0
  8011e4:	6a 0a                	push   $0xa
  8011e6:	e8 e7 fe ff ff       	call   8010d2 <syscall>
  8011eb:	83 c4 18             	add    $0x18,%esp
}
  8011ee:	c9                   	leave  
  8011ef:	c3                   	ret    

008011f0 <sys_calculate_notmod_frames>:

uint32 sys_calculate_notmod_frames()
{
  8011f0:	55                   	push   %ebp
  8011f1:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_notmod_frames, 0, 0, 0, 0, 0);
  8011f3:	6a 00                	push   $0x0
  8011f5:	6a 00                	push   $0x0
  8011f7:	6a 00                	push   $0x0
  8011f9:	6a 00                	push   $0x0
  8011fb:	6a 00                	push   $0x0
  8011fd:	6a 0b                	push   $0xb
  8011ff:	e8 ce fe ff ff       	call   8010d2 <syscall>
  801204:	83 c4 18             	add    $0x18,%esp
}
  801207:	c9                   	leave  
  801208:	c3                   	ret    

00801209 <sys_pf_calculate_allocated_pages>:



int sys_pf_calculate_allocated_pages()
{
  801209:	55                   	push   %ebp
  80120a:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_pf_calc_allocated_pages, 0,0,0,0,0);
  80120c:	6a 00                	push   $0x0
  80120e:	6a 00                	push   $0x0
  801210:	6a 00                	push   $0x0
  801212:	6a 00                	push   $0x0
  801214:	6a 00                	push   $0x0
  801216:	6a 0c                	push   $0xc
  801218:	e8 b5 fe ff ff       	call   8010d2 <syscall>
  80121d:	83 c4 18             	add    $0x18,%esp
}
  801220:	c9                   	leave  
  801221:	c3                   	ret    

00801222 <sys_calculate_pages_tobe_removed_ready_exit>:

int sys_calculate_pages_tobe_removed_ready_exit(uint32 WS_or_MEMORY_flag)
{
  801222:	55                   	push   %ebp
  801223:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calculate_pages_tobe_removed_ready_exit, WS_or_MEMORY_flag,0,0,0,0);
  801225:	6a 00                	push   $0x0
  801227:	6a 00                	push   $0x0
  801229:	6a 00                	push   $0x0
  80122b:	6a 00                	push   $0x0
  80122d:	ff 75 08             	pushl  0x8(%ebp)
  801230:	6a 0d                	push   $0xd
  801232:	e8 9b fe ff ff       	call   8010d2 <syscall>
  801237:	83 c4 18             	add    $0x18,%esp
}
  80123a:	c9                   	leave  
  80123b:	c3                   	ret    

0080123c <sys_scarce_memory>:

void sys_scarce_memory()
{
  80123c:	55                   	push   %ebp
  80123d:	89 e5                	mov    %esp,%ebp
	syscall(SYS_scarce_memory,0,0,0,0,0);
  80123f:	6a 00                	push   $0x0
  801241:	6a 00                	push   $0x0
  801243:	6a 00                	push   $0x0
  801245:	6a 00                	push   $0x0
  801247:	6a 00                	push   $0x0
  801249:	6a 0e                	push   $0xe
  80124b:	e8 82 fe ff ff       	call   8010d2 <syscall>
  801250:	83 c4 18             	add    $0x18,%esp
}
  801253:	90                   	nop
  801254:	c9                   	leave  
  801255:	c3                   	ret    

00801256 <sys_disable_interrupt>:

//NEW !! 2012...
void
sys_disable_interrupt()
{
  801256:	55                   	push   %ebp
  801257:	89 e5                	mov    %esp,%ebp
	syscall(SYS_disableINTR,0, 0, 0, 0, 0);
  801259:	6a 00                	push   $0x0
  80125b:	6a 00                	push   $0x0
  80125d:	6a 00                	push   $0x0
  80125f:	6a 00                	push   $0x0
  801261:	6a 00                	push   $0x0
  801263:	6a 11                	push   $0x11
  801265:	e8 68 fe ff ff       	call   8010d2 <syscall>
  80126a:	83 c4 18             	add    $0x18,%esp
}
  80126d:	90                   	nop
  80126e:	c9                   	leave  
  80126f:	c3                   	ret    

00801270 <sys_enable_interrupt>:


void
sys_enable_interrupt()
{
  801270:	55                   	push   %ebp
  801271:	89 e5                	mov    %esp,%ebp
	syscall(SYS_enableINTR,0, 0, 0, 0, 0);
  801273:	6a 00                	push   $0x0
  801275:	6a 00                	push   $0x0
  801277:	6a 00                	push   $0x0
  801279:	6a 00                	push   $0x0
  80127b:	6a 00                	push   $0x0
  80127d:	6a 12                	push   $0x12
  80127f:	e8 4e fe ff ff       	call   8010d2 <syscall>
  801284:	83 c4 18             	add    $0x18,%esp
}
  801287:	90                   	nop
  801288:	c9                   	leave  
  801289:	c3                   	ret    

0080128a <sys_cputc>:


void
sys_cputc(const char c)
{
  80128a:	55                   	push   %ebp
  80128b:	89 e5                	mov    %esp,%ebp
  80128d:	83 ec 04             	sub    $0x4,%esp
  801290:	8b 45 08             	mov    0x8(%ebp),%eax
  801293:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_cputc, (uint32) c, 0, 0, 0, 0);
  801296:	0f be 45 fc          	movsbl -0x4(%ebp),%eax
  80129a:	6a 00                	push   $0x0
  80129c:	6a 00                	push   $0x0
  80129e:	6a 00                	push   $0x0
  8012a0:	6a 00                	push   $0x0
  8012a2:	50                   	push   %eax
  8012a3:	6a 13                	push   $0x13
  8012a5:	e8 28 fe ff ff       	call   8010d2 <syscall>
  8012aa:	83 c4 18             	add    $0x18,%esp
}
  8012ad:	90                   	nop
  8012ae:	c9                   	leave  
  8012af:	c3                   	ret    

008012b0 <sys_clear_ffl>:


//NEW'12: BONUS2 Testing
void
sys_clear_ffl()
{
  8012b0:	55                   	push   %ebp
  8012b1:	89 e5                	mov    %esp,%ebp
	syscall(SYS_clearFFL,0, 0, 0, 0, 0);
  8012b3:	6a 00                	push   $0x0
  8012b5:	6a 00                	push   $0x0
  8012b7:	6a 00                	push   $0x0
  8012b9:	6a 00                	push   $0x0
  8012bb:	6a 00                	push   $0x0
  8012bd:	6a 14                	push   $0x14
  8012bf:	e8 0e fe ff ff       	call   8010d2 <syscall>
  8012c4:	83 c4 18             	add    $0x18,%esp
}
  8012c7:	90                   	nop
  8012c8:	c9                   	leave  
  8012c9:	c3                   	ret    

008012ca <sys_createSemaphore>:

int
sys_createSemaphore(char* semaphoreName, uint32 initialValue)
{
  8012ca:	55                   	push   %ebp
  8012cb:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_create_semaphore,(uint32)semaphoreName, (uint32)initialValue, 0, 0, 0);
  8012cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8012d0:	6a 00                	push   $0x0
  8012d2:	6a 00                	push   $0x0
  8012d4:	6a 00                	push   $0x0
  8012d6:	ff 75 0c             	pushl  0xc(%ebp)
  8012d9:	50                   	push   %eax
  8012da:	6a 15                	push   $0x15
  8012dc:	e8 f1 fd ff ff       	call   8010d2 <syscall>
  8012e1:	83 c4 18             	add    $0x18,%esp
}
  8012e4:	c9                   	leave  
  8012e5:	c3                   	ret    

008012e6 <sys_getSemaphoreValue>:

int
sys_getSemaphoreValue(int32 ownerEnvID, char* semaphoreName)
{
  8012e6:	55                   	push   %ebp
  8012e7:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_get_semaphore_value,(uint32) ownerEnvID, (uint32)semaphoreName, 0, 0, 0);
  8012e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ef:	6a 00                	push   $0x0
  8012f1:	6a 00                	push   $0x0
  8012f3:	6a 00                	push   $0x0
  8012f5:	52                   	push   %edx
  8012f6:	50                   	push   %eax
  8012f7:	6a 18                	push   $0x18
  8012f9:	e8 d4 fd ff ff       	call   8010d2 <syscall>
  8012fe:	83 c4 18             	add    $0x18,%esp
}
  801301:	c9                   	leave  
  801302:	c3                   	ret    

00801303 <sys_waitSemaphore>:

void
sys_waitSemaphore(int32 ownerEnvID, char* semaphoreName)
{
  801303:	55                   	push   %ebp
  801304:	89 e5                	mov    %esp,%ebp
	syscall(SYS_wait_semaphore,(uint32) ownerEnvID, (uint32)semaphoreName, 0, 0, 0);
  801306:	8b 55 0c             	mov    0xc(%ebp),%edx
  801309:	8b 45 08             	mov    0x8(%ebp),%eax
  80130c:	6a 00                	push   $0x0
  80130e:	6a 00                	push   $0x0
  801310:	6a 00                	push   $0x0
  801312:	52                   	push   %edx
  801313:	50                   	push   %eax
  801314:	6a 16                	push   $0x16
  801316:	e8 b7 fd ff ff       	call   8010d2 <syscall>
  80131b:	83 c4 18             	add    $0x18,%esp
}
  80131e:	90                   	nop
  80131f:	c9                   	leave  
  801320:	c3                   	ret    

00801321 <sys_signalSemaphore>:

void
sys_signalSemaphore(int32 ownerEnvID, char* semaphoreName)
{
  801321:	55                   	push   %ebp
  801322:	89 e5                	mov    %esp,%ebp
	syscall(SYS_signal_semaphore,(uint32) ownerEnvID, (uint32)semaphoreName, 0, 0, 0);
  801324:	8b 55 0c             	mov    0xc(%ebp),%edx
  801327:	8b 45 08             	mov    0x8(%ebp),%eax
  80132a:	6a 00                	push   $0x0
  80132c:	6a 00                	push   $0x0
  80132e:	6a 00                	push   $0x0
  801330:	52                   	push   %edx
  801331:	50                   	push   %eax
  801332:	6a 17                	push   $0x17
  801334:	e8 99 fd ff ff       	call   8010d2 <syscall>
  801339:	83 c4 18             	add    $0x18,%esp
}
  80133c:	90                   	nop
  80133d:	c9                   	leave  
  80133e:	c3                   	ret    

0080133f <sys_createSharedObject>:

int
sys_createSharedObject(char* shareName, uint32 size, uint8 isWritable, void* virtual_address)
{
  80133f:	55                   	push   %ebp
  801340:	89 e5                	mov    %esp,%ebp
  801342:	83 ec 04             	sub    $0x4,%esp
  801345:	8b 45 10             	mov    0x10(%ebp),%eax
  801348:	88 45 fc             	mov    %al,-0x4(%ebp)
	return syscall(SYS_create_shared_object,(uint32)shareName, (uint32)size, isWritable, (uint32)virtual_address,  0);
  80134b:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80134e:	0f b6 55 fc          	movzbl -0x4(%ebp),%edx
  801352:	8b 45 08             	mov    0x8(%ebp),%eax
  801355:	6a 00                	push   $0x0
  801357:	51                   	push   %ecx
  801358:	52                   	push   %edx
  801359:	ff 75 0c             	pushl  0xc(%ebp)
  80135c:	50                   	push   %eax
  80135d:	6a 19                	push   $0x19
  80135f:	e8 6e fd ff ff       	call   8010d2 <syscall>
  801364:	83 c4 18             	add    $0x18,%esp
}
  801367:	c9                   	leave  
  801368:	c3                   	ret    

00801369 <sys_getSizeOfSharedObject>:

//2017:
int
sys_getSizeOfSharedObject(int32 ownerID, char* shareName)
{
  801369:	55                   	push   %ebp
  80136a:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_get_size_of_shared_object,(uint32) ownerID, (uint32)shareName, 0, 0, 0);
  80136c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80136f:	8b 45 08             	mov    0x8(%ebp),%eax
  801372:	6a 00                	push   $0x0
  801374:	6a 00                	push   $0x0
  801376:	6a 00                	push   $0x0
  801378:	52                   	push   %edx
  801379:	50                   	push   %eax
  80137a:	6a 1a                	push   $0x1a
  80137c:	e8 51 fd ff ff       	call   8010d2 <syscall>
  801381:	83 c4 18             	add    $0x18,%esp
}
  801384:	c9                   	leave  
  801385:	c3                   	ret    

00801386 <sys_getSharedObject>:
//==========

int
sys_getSharedObject(int32 ownerID, char* shareName, void* virtual_address)
{
  801386:	55                   	push   %ebp
  801387:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_get_shared_object,(uint32) ownerID, (uint32)shareName, (uint32)virtual_address, 0, 0);
  801389:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80138c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80138f:	8b 45 08             	mov    0x8(%ebp),%eax
  801392:	6a 00                	push   $0x0
  801394:	6a 00                	push   $0x0
  801396:	51                   	push   %ecx
  801397:	52                   	push   %edx
  801398:	50                   	push   %eax
  801399:	6a 1b                	push   $0x1b
  80139b:	e8 32 fd ff ff       	call   8010d2 <syscall>
  8013a0:	83 c4 18             	add    $0x18,%esp
}
  8013a3:	c9                   	leave  
  8013a4:	c3                   	ret    

008013a5 <sys_freeSharedObject>:

int
sys_freeSharedObject(int32 sharedObjectID, void *startVA)
{
  8013a5:	55                   	push   %ebp
  8013a6:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_free_shared_object,(uint32) sharedObjectID, (uint32) startVA, 0, 0, 0);
  8013a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ae:	6a 00                	push   $0x0
  8013b0:	6a 00                	push   $0x0
  8013b2:	6a 00                	push   $0x0
  8013b4:	52                   	push   %edx
  8013b5:	50                   	push   %eax
  8013b6:	6a 1c                	push   $0x1c
  8013b8:	e8 15 fd ff ff       	call   8010d2 <syscall>
  8013bd:	83 c4 18             	add    $0x18,%esp
}
  8013c0:	c9                   	leave  
  8013c1:	c3                   	ret    

008013c2 <sys_getMaxShares>:

uint32 	sys_getMaxShares()
{
  8013c2:	55                   	push   %ebp
  8013c3:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_get_max_shares,0, 0, 0, 0, 0);
  8013c5:	6a 00                	push   $0x0
  8013c7:	6a 00                	push   $0x0
  8013c9:	6a 00                	push   $0x0
  8013cb:	6a 00                	push   $0x0
  8013cd:	6a 00                	push   $0x0
  8013cf:	6a 1d                	push   $0x1d
  8013d1:	e8 fc fc ff ff       	call   8010d2 <syscall>
  8013d6:	83 c4 18             	add    $0x18,%esp
}
  8013d9:	c9                   	leave  
  8013da:	c3                   	ret    

008013db <sys_create_env>:

int sys_create_env(char* programName, unsigned int page_WS_size,unsigned int LRU_second_list_size,unsigned int percent_WS_pages_to_remove)
{
  8013db:	55                   	push   %ebp
  8013dc:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_create_env,(uint32)programName, (uint32)page_WS_size,(uint32)LRU_second_list_size, (uint32)percent_WS_pages_to_remove, 0);
  8013de:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e1:	6a 00                	push   $0x0
  8013e3:	ff 75 14             	pushl  0x14(%ebp)
  8013e6:	ff 75 10             	pushl  0x10(%ebp)
  8013e9:	ff 75 0c             	pushl  0xc(%ebp)
  8013ec:	50                   	push   %eax
  8013ed:	6a 1e                	push   $0x1e
  8013ef:	e8 de fc ff ff       	call   8010d2 <syscall>
  8013f4:	83 c4 18             	add    $0x18,%esp
}
  8013f7:	c9                   	leave  
  8013f8:	c3                   	ret    

008013f9 <sys_run_env>:

void
sys_run_env(int32 envId)
{
  8013f9:	55                   	push   %ebp
  8013fa:	89 e5                	mov    %esp,%ebp
	syscall(SYS_run_env, (int32)envId, 0, 0, 0, 0);
  8013fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ff:	6a 00                	push   $0x0
  801401:	6a 00                	push   $0x0
  801403:	6a 00                	push   $0x0
  801405:	6a 00                	push   $0x0
  801407:	50                   	push   %eax
  801408:	6a 1f                	push   $0x1f
  80140a:	e8 c3 fc ff ff       	call   8010d2 <syscall>
  80140f:	83 c4 18             	add    $0x18,%esp
}
  801412:	90                   	nop
  801413:	c9                   	leave  
  801414:	c3                   	ret    

00801415 <sys_destroy_env>:

int sys_destroy_env(int32  envid)
{
  801415:	55                   	push   %ebp
  801416:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_destroy_env, envid, 0, 0, 0, 0);
  801418:	8b 45 08             	mov    0x8(%ebp),%eax
  80141b:	6a 00                	push   $0x0
  80141d:	6a 00                	push   $0x0
  80141f:	6a 00                	push   $0x0
  801421:	6a 00                	push   $0x0
  801423:	50                   	push   %eax
  801424:	6a 20                	push   $0x20
  801426:	e8 a7 fc ff ff       	call   8010d2 <syscall>
  80142b:	83 c4 18             	add    $0x18,%esp
}
  80142e:	c9                   	leave  
  80142f:	c3                   	ret    

00801430 <sys_getenvid>:

int32 sys_getenvid(void)
{
  801430:	55                   	push   %ebp
  801431:	89 e5                	mov    %esp,%ebp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0);
  801433:	6a 00                	push   $0x0
  801435:	6a 00                	push   $0x0
  801437:	6a 00                	push   $0x0
  801439:	6a 00                	push   $0x0
  80143b:	6a 00                	push   $0x0
  80143d:	6a 02                	push   $0x2
  80143f:	e8 8e fc ff ff       	call   8010d2 <syscall>
  801444:	83 c4 18             	add    $0x18,%esp
}
  801447:	c9                   	leave  
  801448:	c3                   	ret    

00801449 <sys_getenvindex>:

//2017
int32 sys_getenvindex(void)
{
  801449:	55                   	push   %ebp
  80144a:	89 e5                	mov    %esp,%ebp
	 return syscall(SYS_getenvindex, 0, 0, 0, 0, 0);
  80144c:	6a 00                	push   $0x0
  80144e:	6a 00                	push   $0x0
  801450:	6a 00                	push   $0x0
  801452:	6a 00                	push   $0x0
  801454:	6a 00                	push   $0x0
  801456:	6a 03                	push   $0x3
  801458:	e8 75 fc ff ff       	call   8010d2 <syscall>
  80145d:	83 c4 18             	add    $0x18,%esp
}
  801460:	c9                   	leave  
  801461:	c3                   	ret    

00801462 <sys_getparentenvid>:

int32 sys_getparentenvid(void)
{
  801462:	55                   	push   %ebp
  801463:	89 e5                	mov    %esp,%ebp
	 return syscall(SYS_getparentenvid, 0, 0, 0, 0, 0);
  801465:	6a 00                	push   $0x0
  801467:	6a 00                	push   $0x0
  801469:	6a 00                	push   $0x0
  80146b:	6a 00                	push   $0x0
  80146d:	6a 00                	push   $0x0
  80146f:	6a 04                	push   $0x4
  801471:	e8 5c fc ff ff       	call   8010d2 <syscall>
  801476:	83 c4 18             	add    $0x18,%esp
}
  801479:	c9                   	leave  
  80147a:	c3                   	ret    

0080147b <sys_exit_env>:


void sys_exit_env(void)
{
  80147b:	55                   	push   %ebp
  80147c:	89 e5                	mov    %esp,%ebp
	syscall(SYS_exit_env, 0, 0, 0, 0, 0);
  80147e:	6a 00                	push   $0x0
  801480:	6a 00                	push   $0x0
  801482:	6a 00                	push   $0x0
  801484:	6a 00                	push   $0x0
  801486:	6a 00                	push   $0x0
  801488:	6a 21                	push   $0x21
  80148a:	e8 43 fc ff ff       	call   8010d2 <syscall>
  80148f:	83 c4 18             	add    $0x18,%esp
}
  801492:	90                   	nop
  801493:	c9                   	leave  
  801494:	c3                   	ret    

00801495 <sys_get_virtual_time>:


struct uint64
sys_get_virtual_time()
{
  801495:	55                   	push   %ebp
  801496:	89 e5                	mov    %esp,%ebp
  801498:	83 ec 10             	sub    $0x10,%esp
	struct uint64 result;
	syscall(SYS_get_virtual_time, (uint32)&(result.low), (uint32)&(result.hi), 0, 0, 0);
  80149b:	8d 45 f8             	lea    -0x8(%ebp),%eax
  80149e:	8d 50 04             	lea    0x4(%eax),%edx
  8014a1:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8014a4:	6a 00                	push   $0x0
  8014a6:	6a 00                	push   $0x0
  8014a8:	6a 00                	push   $0x0
  8014aa:	52                   	push   %edx
  8014ab:	50                   	push   %eax
  8014ac:	6a 22                	push   $0x22
  8014ae:	e8 1f fc ff ff       	call   8010d2 <syscall>
  8014b3:	83 c4 18             	add    $0x18,%esp
	return result;
  8014b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014b9:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8014bc:	8b 55 fc             	mov    -0x4(%ebp),%edx
  8014bf:	89 01                	mov    %eax,(%ecx)
  8014c1:	89 51 04             	mov    %edx,0x4(%ecx)
}
  8014c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c7:	c9                   	leave  
  8014c8:	c2 04 00             	ret    $0x4

008014cb <sys_move_user_mem>:

// 2014
void sys_move_user_mem(uint32 src_virtual_address, uint32 dst_virtual_address, uint32 size)
{
  8014cb:	55                   	push   %ebp
  8014cc:	89 e5                	mov    %esp,%ebp
	syscall(SYS_move_user_mem, src_virtual_address, dst_virtual_address, size, 0, 0);
  8014ce:	6a 00                	push   $0x0
  8014d0:	6a 00                	push   $0x0
  8014d2:	ff 75 10             	pushl  0x10(%ebp)
  8014d5:	ff 75 0c             	pushl  0xc(%ebp)
  8014d8:	ff 75 08             	pushl  0x8(%ebp)
  8014db:	6a 10                	push   $0x10
  8014dd:	e8 f0 fb ff ff       	call   8010d2 <syscall>
  8014e2:	83 c4 18             	add    $0x18,%esp
	return ;
  8014e5:	90                   	nop
}
  8014e6:	c9                   	leave  
  8014e7:	c3                   	ret    

008014e8 <sys_rcr2>:
uint32 sys_rcr2()
{
  8014e8:	55                   	push   %ebp
  8014e9:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_rcr2, 0, 0, 0, 0, 0);
  8014eb:	6a 00                	push   $0x0
  8014ed:	6a 00                	push   $0x0
  8014ef:	6a 00                	push   $0x0
  8014f1:	6a 00                	push   $0x0
  8014f3:	6a 00                	push   $0x0
  8014f5:	6a 23                	push   $0x23
  8014f7:	e8 d6 fb ff ff       	call   8010d2 <syscall>
  8014fc:	83 c4 18             	add    $0x18,%esp
}
  8014ff:	c9                   	leave  
  801500:	c3                   	ret    

00801501 <sys_bypassPageFault>:
void sys_bypassPageFault(uint8 instrLength)
{
  801501:	55                   	push   %ebp
  801502:	89 e5                	mov    %esp,%ebp
  801504:	83 ec 04             	sub    $0x4,%esp
  801507:	8b 45 08             	mov    0x8(%ebp),%eax
  80150a:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_bypassPageFault, instrLength, 0, 0, 0, 0);
  80150d:	0f b6 45 fc          	movzbl -0x4(%ebp),%eax
  801511:	6a 00                	push   $0x0
  801513:	6a 00                	push   $0x0
  801515:	6a 00                	push   $0x0
  801517:	6a 00                	push   $0x0
  801519:	50                   	push   %eax
  80151a:	6a 24                	push   $0x24
  80151c:	e8 b1 fb ff ff       	call   8010d2 <syscall>
  801521:	83 c4 18             	add    $0x18,%esp
	return ;
  801524:	90                   	nop
}
  801525:	c9                   	leave  
  801526:	c3                   	ret    

00801527 <rsttst>:
void rsttst()
{
  801527:	55                   	push   %ebp
  801528:	89 e5                	mov    %esp,%ebp
	syscall(SYS_rsttst, 0, 0, 0, 0, 0);
  80152a:	6a 00                	push   $0x0
  80152c:	6a 00                	push   $0x0
  80152e:	6a 00                	push   $0x0
  801530:	6a 00                	push   $0x0
  801532:	6a 00                	push   $0x0
  801534:	6a 26                	push   $0x26
  801536:	e8 97 fb ff ff       	call   8010d2 <syscall>
  80153b:	83 c4 18             	add    $0x18,%esp
	return ;
  80153e:	90                   	nop
}
  80153f:	c9                   	leave  
  801540:	c3                   	ret    

00801541 <tst>:
void tst(uint32 n, uint32 v1, uint32 v2, char c, int inv)
{
  801541:	55                   	push   %ebp
  801542:	89 e5                	mov    %esp,%ebp
  801544:	83 ec 04             	sub    $0x4,%esp
  801547:	8b 45 14             	mov    0x14(%ebp),%eax
  80154a:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_testNum, n, v1, v2, c, inv);
  80154d:	8b 55 18             	mov    0x18(%ebp),%edx
  801550:	0f be 45 fc          	movsbl -0x4(%ebp),%eax
  801554:	52                   	push   %edx
  801555:	50                   	push   %eax
  801556:	ff 75 10             	pushl  0x10(%ebp)
  801559:	ff 75 0c             	pushl  0xc(%ebp)
  80155c:	ff 75 08             	pushl  0x8(%ebp)
  80155f:	6a 25                	push   $0x25
  801561:	e8 6c fb ff ff       	call   8010d2 <syscall>
  801566:	83 c4 18             	add    $0x18,%esp
	return ;
  801569:	90                   	nop
}
  80156a:	c9                   	leave  
  80156b:	c3                   	ret    

0080156c <chktst>:
void chktst(uint32 n)
{
  80156c:	55                   	push   %ebp
  80156d:	89 e5                	mov    %esp,%ebp
	syscall(SYS_chktst, n, 0, 0, 0, 0);
  80156f:	6a 00                	push   $0x0
  801571:	6a 00                	push   $0x0
  801573:	6a 00                	push   $0x0
  801575:	6a 00                	push   $0x0
  801577:	ff 75 08             	pushl  0x8(%ebp)
  80157a:	6a 27                	push   $0x27
  80157c:	e8 51 fb ff ff       	call   8010d2 <syscall>
  801581:	83 c4 18             	add    $0x18,%esp
	return ;
  801584:	90                   	nop
}
  801585:	c9                   	leave  
  801586:	c3                   	ret    

00801587 <inctst>:

void inctst()
{
  801587:	55                   	push   %ebp
  801588:	89 e5                	mov    %esp,%ebp
	syscall(SYS_inctst, 0, 0, 0, 0, 0);
  80158a:	6a 00                	push   $0x0
  80158c:	6a 00                	push   $0x0
  80158e:	6a 00                	push   $0x0
  801590:	6a 00                	push   $0x0
  801592:	6a 00                	push   $0x0
  801594:	6a 28                	push   $0x28
  801596:	e8 37 fb ff ff       	call   8010d2 <syscall>
  80159b:	83 c4 18             	add    $0x18,%esp
	return ;
  80159e:	90                   	nop
}
  80159f:	c9                   	leave  
  8015a0:	c3                   	ret    

008015a1 <gettst>:
uint32 gettst()
{
  8015a1:	55                   	push   %ebp
  8015a2:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_gettst, 0, 0, 0, 0, 0);
  8015a4:	6a 00                	push   $0x0
  8015a6:	6a 00                	push   $0x0
  8015a8:	6a 00                	push   $0x0
  8015aa:	6a 00                	push   $0x0
  8015ac:	6a 00                	push   $0x0
  8015ae:	6a 29                	push   $0x29
  8015b0:	e8 1d fb ff ff       	call   8010d2 <syscall>
  8015b5:	83 c4 18             	add    $0x18,%esp
}
  8015b8:	c9                   	leave  
  8015b9:	c3                   	ret    

008015ba <sys_isUHeapPlacementStrategyFIRSTFIT>:


//2015
uint32 sys_isUHeapPlacementStrategyFIRSTFIT()
{
  8015ba:	55                   	push   %ebp
  8015bb:	89 e5                	mov    %esp,%ebp
  8015bd:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  8015c0:	6a 00                	push   $0x0
  8015c2:	6a 00                	push   $0x0
  8015c4:	6a 00                	push   $0x0
  8015c6:	6a 00                	push   $0x0
  8015c8:	6a 00                	push   $0x0
  8015ca:	6a 2a                	push   $0x2a
  8015cc:	e8 01 fb ff ff       	call   8010d2 <syscall>
  8015d1:	83 c4 18             	add    $0x18,%esp
  8015d4:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_FIRSTFIT)
  8015d7:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
  8015db:	75 07                	jne    8015e4 <sys_isUHeapPlacementStrategyFIRSTFIT+0x2a>
		return 1;
  8015dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8015e2:	eb 05                	jmp    8015e9 <sys_isUHeapPlacementStrategyFIRSTFIT+0x2f>
	else
		return 0;
  8015e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015e9:	c9                   	leave  
  8015ea:	c3                   	ret    

008015eb <sys_isUHeapPlacementStrategyBESTFIT>:
uint32 sys_isUHeapPlacementStrategyBESTFIT()
{
  8015eb:	55                   	push   %ebp
  8015ec:	89 e5                	mov    %esp,%ebp
  8015ee:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  8015f1:	6a 00                	push   $0x0
  8015f3:	6a 00                	push   $0x0
  8015f5:	6a 00                	push   $0x0
  8015f7:	6a 00                	push   $0x0
  8015f9:	6a 00                	push   $0x0
  8015fb:	6a 2a                	push   $0x2a
  8015fd:	e8 d0 fa ff ff       	call   8010d2 <syscall>
  801602:	83 c4 18             	add    $0x18,%esp
  801605:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_BESTFIT)
  801608:	83 7d fc 02          	cmpl   $0x2,-0x4(%ebp)
  80160c:	75 07                	jne    801615 <sys_isUHeapPlacementStrategyBESTFIT+0x2a>
		return 1;
  80160e:	b8 01 00 00 00       	mov    $0x1,%eax
  801613:	eb 05                	jmp    80161a <sys_isUHeapPlacementStrategyBESTFIT+0x2f>
	else
		return 0;
  801615:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80161a:	c9                   	leave  
  80161b:	c3                   	ret    

0080161c <sys_isUHeapPlacementStrategyNEXTFIT>:
uint32 sys_isUHeapPlacementStrategyNEXTFIT()
{
  80161c:	55                   	push   %ebp
  80161d:	89 e5                	mov    %esp,%ebp
  80161f:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  801622:	6a 00                	push   $0x0
  801624:	6a 00                	push   $0x0
  801626:	6a 00                	push   $0x0
  801628:	6a 00                	push   $0x0
  80162a:	6a 00                	push   $0x0
  80162c:	6a 2a                	push   $0x2a
  80162e:	e8 9f fa ff ff       	call   8010d2 <syscall>
  801633:	83 c4 18             	add    $0x18,%esp
  801636:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_NEXTFIT)
  801639:	83 7d fc 03          	cmpl   $0x3,-0x4(%ebp)
  80163d:	75 07                	jne    801646 <sys_isUHeapPlacementStrategyNEXTFIT+0x2a>
		return 1;
  80163f:	b8 01 00 00 00       	mov    $0x1,%eax
  801644:	eb 05                	jmp    80164b <sys_isUHeapPlacementStrategyNEXTFIT+0x2f>
	else
		return 0;
  801646:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80164b:	c9                   	leave  
  80164c:	c3                   	ret    

0080164d <sys_isUHeapPlacementStrategyWORSTFIT>:
uint32 sys_isUHeapPlacementStrategyWORSTFIT()
{
  80164d:	55                   	push   %ebp
  80164e:	89 e5                	mov    %esp,%ebp
  801650:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  801653:	6a 00                	push   $0x0
  801655:	6a 00                	push   $0x0
  801657:	6a 00                	push   $0x0
  801659:	6a 00                	push   $0x0
  80165b:	6a 00                	push   $0x0
  80165d:	6a 2a                	push   $0x2a
  80165f:	e8 6e fa ff ff       	call   8010d2 <syscall>
  801664:	83 c4 18             	add    $0x18,%esp
  801667:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_WORSTFIT)
  80166a:	83 7d fc 04          	cmpl   $0x4,-0x4(%ebp)
  80166e:	75 07                	jne    801677 <sys_isUHeapPlacementStrategyWORSTFIT+0x2a>
		return 1;
  801670:	b8 01 00 00 00       	mov    $0x1,%eax
  801675:	eb 05                	jmp    80167c <sys_isUHeapPlacementStrategyWORSTFIT+0x2f>
	else
		return 0;
  801677:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80167c:	c9                   	leave  
  80167d:	c3                   	ret    

0080167e <sys_set_uheap_strategy>:

void sys_set_uheap_strategy(uint32 heapStrategy)
{
  80167e:	55                   	push   %ebp
  80167f:	89 e5                	mov    %esp,%ebp
	syscall(SYS_set_heap_strategy, heapStrategy, 0, 0, 0, 0);
  801681:	6a 00                	push   $0x0
  801683:	6a 00                	push   $0x0
  801685:	6a 00                	push   $0x0
  801687:	6a 00                	push   $0x0
  801689:	ff 75 08             	pushl  0x8(%ebp)
  80168c:	6a 2b                	push   $0x2b
  80168e:	e8 3f fa ff ff       	call   8010d2 <syscall>
  801693:	83 c4 18             	add    $0x18,%esp
	return ;
  801696:	90                   	nop
}
  801697:	c9                   	leave  
  801698:	c3                   	ret    

00801699 <sys_check_LRU_lists>:

//2020
int sys_check_LRU_lists(uint32* active_list_content, uint32* second_list_content, int actual_active_list_size, int actual_second_list_size)
{
  801699:	55                   	push   %ebp
  80169a:	89 e5                	mov    %esp,%ebp
  80169c:	53                   	push   %ebx
	return syscall(SYS_check_LRU_lists, (uint32)active_list_content, (uint32)second_list_content, (uint32)actual_active_list_size, (uint32)actual_second_list_size, 0);
  80169d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8016a0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a9:	6a 00                	push   $0x0
  8016ab:	53                   	push   %ebx
  8016ac:	51                   	push   %ecx
  8016ad:	52                   	push   %edx
  8016ae:	50                   	push   %eax
  8016af:	6a 2c                	push   $0x2c
  8016b1:	e8 1c fa ff ff       	call   8010d2 <syscall>
  8016b6:	83 c4 18             	add    $0x18,%esp
}
  8016b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016bc:	c9                   	leave  
  8016bd:	c3                   	ret    

008016be <sys_check_LRU_lists_free>:

int sys_check_LRU_lists_free(uint32* list_content, int list_size)
{
  8016be:	55                   	push   %ebp
  8016bf:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_check_LRU_lists_free, (uint32)list_content, (uint32)list_size , 0, 0, 0);
  8016c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c7:	6a 00                	push   $0x0
  8016c9:	6a 00                	push   $0x0
  8016cb:	6a 00                	push   $0x0
  8016cd:	52                   	push   %edx
  8016ce:	50                   	push   %eax
  8016cf:	6a 2d                	push   $0x2d
  8016d1:	e8 fc f9 ff ff       	call   8010d2 <syscall>
  8016d6:	83 c4 18             	add    $0x18,%esp
}
  8016d9:	c9                   	leave  
  8016da:	c3                   	ret    

008016db <sys_check_WS_list>:

int sys_check_WS_list(uint32* WS_list_content, int actual_WS_list_size, uint32 last_WS_element_content, bool chk_in_order)
{
  8016db:	55                   	push   %ebp
  8016dc:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_check_WS_list, (uint32)WS_list_content, (uint32)actual_WS_list_size , last_WS_element_content, (uint32)chk_in_order, 0);
  8016de:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8016e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e7:	6a 00                	push   $0x0
  8016e9:	51                   	push   %ecx
  8016ea:	ff 75 10             	pushl  0x10(%ebp)
  8016ed:	52                   	push   %edx
  8016ee:	50                   	push   %eax
  8016ef:	6a 2e                	push   $0x2e
  8016f1:	e8 dc f9 ff ff       	call   8010d2 <syscall>
  8016f6:	83 c4 18             	add    $0x18,%esp
}
  8016f9:	c9                   	leave  
  8016fa:	c3                   	ret    

008016fb <sys_allocate_chunk>:
void sys_allocate_chunk(uint32 virtual_address, uint32 size, uint32 perms)
{
  8016fb:	55                   	push   %ebp
  8016fc:	89 e5                	mov    %esp,%ebp
	syscall(SYS_allocate_chunk_in_mem, virtual_address, size, perms, 0, 0);
  8016fe:	6a 00                	push   $0x0
  801700:	6a 00                	push   $0x0
  801702:	ff 75 10             	pushl  0x10(%ebp)
  801705:	ff 75 0c             	pushl  0xc(%ebp)
  801708:	ff 75 08             	pushl  0x8(%ebp)
  80170b:	6a 0f                	push   $0xf
  80170d:	e8 c0 f9 ff ff       	call   8010d2 <syscall>
  801712:	83 c4 18             	add    $0x18,%esp
	return ;
  801715:	90                   	nop
}
  801716:	c9                   	leave  
  801717:	c3                   	ret    

00801718 <sys_sbrk>:


/*2023*/
//TODO: [PROJECT'23.MS1 - #3] [2] SYSTEM CALLS - Implement these system calls
void* sys_sbrk(int increment)
{
  801718:	55                   	push   %ebp
  801719:	89 e5                	mov    %esp,%ebp
  80171b:	83 ec 08             	sub    $0x8,%esp
	//Comment the following line before start coding...
	panic("not implemented yet");
  80171e:	83 ec 04             	sub    $0x4,%esp
  801721:	68 50 20 80 00       	push   $0x802050
  801726:	68 54 01 00 00       	push   $0x154
  80172b:	68 64 20 80 00       	push   $0x802064
  801730:	e8 3a 00 00 00       	call   80176f <_panic>

00801735 <sys_free_user_mem>:
	return NULL;
}

void sys_free_user_mem(uint32 virtual_address, uint32 size)
{
  801735:	55                   	push   %ebp
  801736:	89 e5                	mov    %esp,%ebp
  801738:	83 ec 08             	sub    $0x8,%esp
	//Comment the following line before start coding...
	panic("not implemented yet");
  80173b:	83 ec 04             	sub    $0x4,%esp
  80173e:	68 50 20 80 00       	push   $0x802050
  801743:	68 5b 01 00 00       	push   $0x15b
  801748:	68 64 20 80 00       	push   $0x802064
  80174d:	e8 1d 00 00 00       	call   80176f <_panic>

00801752 <sys_allocate_user_mem>:
}

void sys_allocate_user_mem(uint32 virtual_address, uint32 size)
{
  801752:	55                   	push   %ebp
  801753:	89 e5                	mov    %esp,%ebp
  801755:	83 ec 08             	sub    $0x8,%esp
	//Comment the following line before start coding...
	panic("not implemented yet");
  801758:	83 ec 04             	sub    $0x4,%esp
  80175b:	68 50 20 80 00       	push   $0x802050
  801760:	68 61 01 00 00       	push   $0x161
  801765:	68 64 20 80 00       	push   $0x802064
  80176a:	e8 00 00 00 00       	call   80176f <_panic>

0080176f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes FOS to enter the FOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  80176f:	55                   	push   %ebp
  801770:	89 e5                	mov    %esp,%ebp
  801772:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	va_start(ap, fmt);
  801775:	8d 45 10             	lea    0x10(%ebp),%eax
  801778:	83 c0 04             	add    $0x4,%eax
  80177b:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// Print the panic message
	if (argv0)
  80177e:	a1 18 31 80 00       	mov    0x803118,%eax
  801783:	85 c0                	test   %eax,%eax
  801785:	74 16                	je     80179d <_panic+0x2e>
		cprintf("%s: ", argv0);
  801787:	a1 18 31 80 00       	mov    0x803118,%eax
  80178c:	83 ec 08             	sub    $0x8,%esp
  80178f:	50                   	push   %eax
  801790:	68 74 20 80 00       	push   $0x802074
  801795:	e8 15 eb ff ff       	call   8002af <cprintf>
  80179a:	83 c4 10             	add    $0x10,%esp
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  80179d:	a1 00 30 80 00       	mov    0x803000,%eax
  8017a2:	ff 75 0c             	pushl  0xc(%ebp)
  8017a5:	ff 75 08             	pushl  0x8(%ebp)
  8017a8:	50                   	push   %eax
  8017a9:	68 79 20 80 00       	push   $0x802079
  8017ae:	e8 fc ea ff ff       	call   8002af <cprintf>
  8017b3:	83 c4 10             	add    $0x10,%esp
	vcprintf(fmt, ap);
  8017b6:	8b 45 10             	mov    0x10(%ebp),%eax
  8017b9:	83 ec 08             	sub    $0x8,%esp
  8017bc:	ff 75 f4             	pushl  -0xc(%ebp)
  8017bf:	50                   	push   %eax
  8017c0:	e8 7f ea ff ff       	call   800244 <vcprintf>
  8017c5:	83 c4 10             	add    $0x10,%esp
	vcprintf("\n", NULL);
  8017c8:	83 ec 08             	sub    $0x8,%esp
  8017cb:	6a 00                	push   $0x0
  8017cd:	68 95 20 80 00       	push   $0x802095
  8017d2:	e8 6d ea ff ff       	call   800244 <vcprintf>
  8017d7:	83 c4 10             	add    $0x10,%esp
	// Cause a breakpoint exception
//	while (1);
//		asm volatile("int3");

	//2013: exit the panic env only
	exit() ;
  8017da:	e8 ee e9 ff ff       	call   8001cd <exit>

	// should not return here
	while (1) ;
  8017df:	eb fe                	jmp    8017df <_panic+0x70>

008017e1 <CheckWSArrayWithoutLastIndex>:
}

void CheckWSArrayWithoutLastIndex(uint32 *expectedPages, int arraySize)
{
  8017e1:	55                   	push   %ebp
  8017e2:	89 e5                	mov    %esp,%ebp
  8017e4:	83 ec 28             	sub    $0x28,%esp
	if (arraySize != myEnv->page_WS_max_size)
  8017e7:	a1 20 30 80 00       	mov    0x803020,%eax
  8017ec:	8b 90 7c d5 01 00    	mov    0x1d57c(%eax),%edx
  8017f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017f5:	39 c2                	cmp    %eax,%edx
  8017f7:	74 14                	je     80180d <CheckWSArrayWithoutLastIndex+0x2c>
	{
		panic("number of expected pages SHOULD BE EQUAL to max WS size... review your TA!!");
  8017f9:	83 ec 04             	sub    $0x4,%esp
  8017fc:	68 98 20 80 00       	push   $0x802098
  801801:	6a 26                	push   $0x26
  801803:	68 e4 20 80 00       	push   $0x8020e4
  801808:	e8 62 ff ff ff       	call   80176f <_panic>
	}
	int expectedNumOfEmptyLocs = 0;
  80180d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	for (int e = 0; e < arraySize; e++) {
  801814:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  80181b:	e9 c5 00 00 00       	jmp    8018e5 <CheckWSArrayWithoutLastIndex+0x104>
		if (expectedPages[e] == 0) {
  801820:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801823:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80182a:	8b 45 08             	mov    0x8(%ebp),%eax
  80182d:	01 d0                	add    %edx,%eax
  80182f:	8b 00                	mov    (%eax),%eax
  801831:	85 c0                	test   %eax,%eax
  801833:	75 08                	jne    80183d <CheckWSArrayWithoutLastIndex+0x5c>
			expectedNumOfEmptyLocs++;
  801835:	ff 45 f4             	incl   -0xc(%ebp)
			continue;
  801838:	e9 a5 00 00 00       	jmp    8018e2 <CheckWSArrayWithoutLastIndex+0x101>
		}
		int found = 0;
  80183d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  801844:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  80184b:	eb 69                	jmp    8018b6 <CheckWSArrayWithoutLastIndex+0xd5>
			if (myEnv->__uptr_pws[w].empty == 0) {
  80184d:	a1 20 30 80 00       	mov    0x803020,%eax
  801852:	8b 88 6c da 01 00    	mov    0x1da6c(%eax),%ecx
  801858:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80185b:	89 d0                	mov    %edx,%eax
  80185d:	01 c0                	add    %eax,%eax
  80185f:	01 d0                	add    %edx,%eax
  801861:	c1 e0 03             	shl    $0x3,%eax
  801864:	01 c8                	add    %ecx,%eax
  801866:	8a 40 04             	mov    0x4(%eax),%al
  801869:	84 c0                	test   %al,%al
  80186b:	75 46                	jne    8018b3 <CheckWSArrayWithoutLastIndex+0xd2>
				if (ROUNDDOWN(myEnv->__uptr_pws[w].virtual_address, PAGE_SIZE)
  80186d:	a1 20 30 80 00       	mov    0x803020,%eax
  801872:	8b 88 6c da 01 00    	mov    0x1da6c(%eax),%ecx
  801878:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80187b:	89 d0                	mov    %edx,%eax
  80187d:	01 c0                	add    %eax,%eax
  80187f:	01 d0                	add    %edx,%eax
  801881:	c1 e0 03             	shl    $0x3,%eax
  801884:	01 c8                	add    %ecx,%eax
  801886:	8b 00                	mov    (%eax),%eax
  801888:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80188b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80188e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801893:	89 c2                	mov    %eax,%edx
						== expectedPages[e]) {
  801895:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801898:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  80189f:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a2:	01 c8                	add    %ecx,%eax
  8018a4:	8b 00                	mov    (%eax),%eax
			continue;
		}
		int found = 0;
		for (int w = 0; w < myEnv->page_WS_max_size; w++) {
			if (myEnv->__uptr_pws[w].empty == 0) {
				if (ROUNDDOWN(myEnv->__uptr_pws[w].virtual_address, PAGE_SIZE)
  8018a6:	39 c2                	cmp    %eax,%edx
  8018a8:	75 09                	jne    8018b3 <CheckWSArrayWithoutLastIndex+0xd2>
						== expectedPages[e]) {
					found = 1;
  8018aa:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
					break;
  8018b1:	eb 15                	jmp    8018c8 <CheckWSArrayWithoutLastIndex+0xe7>
		if (expectedPages[e] == 0) {
			expectedNumOfEmptyLocs++;
			continue;
		}
		int found = 0;
		for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  8018b3:	ff 45 e8             	incl   -0x18(%ebp)
  8018b6:	a1 20 30 80 00       	mov    0x803020,%eax
  8018bb:	8b 90 7c d5 01 00    	mov    0x1d57c(%eax),%edx
  8018c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8018c4:	39 c2                	cmp    %eax,%edx
  8018c6:	77 85                	ja     80184d <CheckWSArrayWithoutLastIndex+0x6c>
					found = 1;
					break;
				}
			}
		}
		if (!found)
  8018c8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8018cc:	75 14                	jne    8018e2 <CheckWSArrayWithoutLastIndex+0x101>
			panic(
  8018ce:	83 ec 04             	sub    $0x4,%esp
  8018d1:	68 f0 20 80 00       	push   $0x8020f0
  8018d6:	6a 3a                	push   $0x3a
  8018d8:	68 e4 20 80 00       	push   $0x8020e4
  8018dd:	e8 8d fe ff ff       	call   80176f <_panic>
	if (arraySize != myEnv->page_WS_max_size)
	{
		panic("number of expected pages SHOULD BE EQUAL to max WS size... review your TA!!");
	}
	int expectedNumOfEmptyLocs = 0;
	for (int e = 0; e < arraySize; e++) {
  8018e2:	ff 45 f0             	incl   -0x10(%ebp)
  8018e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018e8:	3b 45 0c             	cmp    0xc(%ebp),%eax
  8018eb:	0f 8c 2f ff ff ff    	jl     801820 <CheckWSArrayWithoutLastIndex+0x3f>
		}
		if (!found)
			panic(
					"PAGE WS entry checking failed... trace it by printing page WS before & after fault");
	}
	int actualNumOfEmptyLocs = 0;
  8018f1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  8018f8:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8018ff:	eb 26                	jmp    801927 <CheckWSArrayWithoutLastIndex+0x146>
		if (myEnv->__uptr_pws[w].empty == 1) {
  801901:	a1 20 30 80 00       	mov    0x803020,%eax
  801906:	8b 88 6c da 01 00    	mov    0x1da6c(%eax),%ecx
  80190c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80190f:	89 d0                	mov    %edx,%eax
  801911:	01 c0                	add    %eax,%eax
  801913:	01 d0                	add    %edx,%eax
  801915:	c1 e0 03             	shl    $0x3,%eax
  801918:	01 c8                	add    %ecx,%eax
  80191a:	8a 40 04             	mov    0x4(%eax),%al
  80191d:	3c 01                	cmp    $0x1,%al
  80191f:	75 03                	jne    801924 <CheckWSArrayWithoutLastIndex+0x143>
			actualNumOfEmptyLocs++;
  801921:	ff 45 e4             	incl   -0x1c(%ebp)
		if (!found)
			panic(
					"PAGE WS entry checking failed... trace it by printing page WS before & after fault");
	}
	int actualNumOfEmptyLocs = 0;
	for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  801924:	ff 45 e0             	incl   -0x20(%ebp)
  801927:	a1 20 30 80 00       	mov    0x803020,%eax
  80192c:	8b 90 7c d5 01 00    	mov    0x1d57c(%eax),%edx
  801932:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801935:	39 c2                	cmp    %eax,%edx
  801937:	77 c8                	ja     801901 <CheckWSArrayWithoutLastIndex+0x120>
		if (myEnv->__uptr_pws[w].empty == 1) {
			actualNumOfEmptyLocs++;
		}
	}
	if (expectedNumOfEmptyLocs != actualNumOfEmptyLocs)
  801939:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80193c:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
  80193f:	74 14                	je     801955 <CheckWSArrayWithoutLastIndex+0x174>
		panic(
  801941:	83 ec 04             	sub    $0x4,%esp
  801944:	68 44 21 80 00       	push   $0x802144
  801949:	6a 44                	push   $0x44
  80194b:	68 e4 20 80 00       	push   $0x8020e4
  801950:	e8 1a fe ff ff       	call   80176f <_panic>
				"PAGE WS entry checking failed... number of empty locations is not correct");
}
  801955:	90                   	nop
  801956:	c9                   	leave  
  801957:	c3                   	ret    

00801958 <__udivdi3>:
  801958:	55                   	push   %ebp
  801959:	57                   	push   %edi
  80195a:	56                   	push   %esi
  80195b:	53                   	push   %ebx
  80195c:	83 ec 1c             	sub    $0x1c,%esp
  80195f:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801963:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801967:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80196b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80196f:	89 ca                	mov    %ecx,%edx
  801971:	89 f8                	mov    %edi,%eax
  801973:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801977:	85 f6                	test   %esi,%esi
  801979:	75 2d                	jne    8019a8 <__udivdi3+0x50>
  80197b:	39 cf                	cmp    %ecx,%edi
  80197d:	77 65                	ja     8019e4 <__udivdi3+0x8c>
  80197f:	89 fd                	mov    %edi,%ebp
  801981:	85 ff                	test   %edi,%edi
  801983:	75 0b                	jne    801990 <__udivdi3+0x38>
  801985:	b8 01 00 00 00       	mov    $0x1,%eax
  80198a:	31 d2                	xor    %edx,%edx
  80198c:	f7 f7                	div    %edi
  80198e:	89 c5                	mov    %eax,%ebp
  801990:	31 d2                	xor    %edx,%edx
  801992:	89 c8                	mov    %ecx,%eax
  801994:	f7 f5                	div    %ebp
  801996:	89 c1                	mov    %eax,%ecx
  801998:	89 d8                	mov    %ebx,%eax
  80199a:	f7 f5                	div    %ebp
  80199c:	89 cf                	mov    %ecx,%edi
  80199e:	89 fa                	mov    %edi,%edx
  8019a0:	83 c4 1c             	add    $0x1c,%esp
  8019a3:	5b                   	pop    %ebx
  8019a4:	5e                   	pop    %esi
  8019a5:	5f                   	pop    %edi
  8019a6:	5d                   	pop    %ebp
  8019a7:	c3                   	ret    
  8019a8:	39 ce                	cmp    %ecx,%esi
  8019aa:	77 28                	ja     8019d4 <__udivdi3+0x7c>
  8019ac:	0f bd fe             	bsr    %esi,%edi
  8019af:	83 f7 1f             	xor    $0x1f,%edi
  8019b2:	75 40                	jne    8019f4 <__udivdi3+0x9c>
  8019b4:	39 ce                	cmp    %ecx,%esi
  8019b6:	72 0a                	jb     8019c2 <__udivdi3+0x6a>
  8019b8:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8019bc:	0f 87 9e 00 00 00    	ja     801a60 <__udivdi3+0x108>
  8019c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8019c7:	89 fa                	mov    %edi,%edx
  8019c9:	83 c4 1c             	add    $0x1c,%esp
  8019cc:	5b                   	pop    %ebx
  8019cd:	5e                   	pop    %esi
  8019ce:	5f                   	pop    %edi
  8019cf:	5d                   	pop    %ebp
  8019d0:	c3                   	ret    
  8019d1:	8d 76 00             	lea    0x0(%esi),%esi
  8019d4:	31 ff                	xor    %edi,%edi
  8019d6:	31 c0                	xor    %eax,%eax
  8019d8:	89 fa                	mov    %edi,%edx
  8019da:	83 c4 1c             	add    $0x1c,%esp
  8019dd:	5b                   	pop    %ebx
  8019de:	5e                   	pop    %esi
  8019df:	5f                   	pop    %edi
  8019e0:	5d                   	pop    %ebp
  8019e1:	c3                   	ret    
  8019e2:	66 90                	xchg   %ax,%ax
  8019e4:	89 d8                	mov    %ebx,%eax
  8019e6:	f7 f7                	div    %edi
  8019e8:	31 ff                	xor    %edi,%edi
  8019ea:	89 fa                	mov    %edi,%edx
  8019ec:	83 c4 1c             	add    $0x1c,%esp
  8019ef:	5b                   	pop    %ebx
  8019f0:	5e                   	pop    %esi
  8019f1:	5f                   	pop    %edi
  8019f2:	5d                   	pop    %ebp
  8019f3:	c3                   	ret    
  8019f4:	bd 20 00 00 00       	mov    $0x20,%ebp
  8019f9:	89 eb                	mov    %ebp,%ebx
  8019fb:	29 fb                	sub    %edi,%ebx
  8019fd:	89 f9                	mov    %edi,%ecx
  8019ff:	d3 e6                	shl    %cl,%esi
  801a01:	89 c5                	mov    %eax,%ebp
  801a03:	88 d9                	mov    %bl,%cl
  801a05:	d3 ed                	shr    %cl,%ebp
  801a07:	89 e9                	mov    %ebp,%ecx
  801a09:	09 f1                	or     %esi,%ecx
  801a0b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801a0f:	89 f9                	mov    %edi,%ecx
  801a11:	d3 e0                	shl    %cl,%eax
  801a13:	89 c5                	mov    %eax,%ebp
  801a15:	89 d6                	mov    %edx,%esi
  801a17:	88 d9                	mov    %bl,%cl
  801a19:	d3 ee                	shr    %cl,%esi
  801a1b:	89 f9                	mov    %edi,%ecx
  801a1d:	d3 e2                	shl    %cl,%edx
  801a1f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801a23:	88 d9                	mov    %bl,%cl
  801a25:	d3 e8                	shr    %cl,%eax
  801a27:	09 c2                	or     %eax,%edx
  801a29:	89 d0                	mov    %edx,%eax
  801a2b:	89 f2                	mov    %esi,%edx
  801a2d:	f7 74 24 0c          	divl   0xc(%esp)
  801a31:	89 d6                	mov    %edx,%esi
  801a33:	89 c3                	mov    %eax,%ebx
  801a35:	f7 e5                	mul    %ebp
  801a37:	39 d6                	cmp    %edx,%esi
  801a39:	72 19                	jb     801a54 <__udivdi3+0xfc>
  801a3b:	74 0b                	je     801a48 <__udivdi3+0xf0>
  801a3d:	89 d8                	mov    %ebx,%eax
  801a3f:	31 ff                	xor    %edi,%edi
  801a41:	e9 58 ff ff ff       	jmp    80199e <__udivdi3+0x46>
  801a46:	66 90                	xchg   %ax,%ax
  801a48:	8b 54 24 08          	mov    0x8(%esp),%edx
  801a4c:	89 f9                	mov    %edi,%ecx
  801a4e:	d3 e2                	shl    %cl,%edx
  801a50:	39 c2                	cmp    %eax,%edx
  801a52:	73 e9                	jae    801a3d <__udivdi3+0xe5>
  801a54:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801a57:	31 ff                	xor    %edi,%edi
  801a59:	e9 40 ff ff ff       	jmp    80199e <__udivdi3+0x46>
  801a5e:	66 90                	xchg   %ax,%ax
  801a60:	31 c0                	xor    %eax,%eax
  801a62:	e9 37 ff ff ff       	jmp    80199e <__udivdi3+0x46>
  801a67:	90                   	nop

00801a68 <__umoddi3>:
  801a68:	55                   	push   %ebp
  801a69:	57                   	push   %edi
  801a6a:	56                   	push   %esi
  801a6b:	53                   	push   %ebx
  801a6c:	83 ec 1c             	sub    $0x1c,%esp
  801a6f:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801a73:	8b 74 24 34          	mov    0x34(%esp),%esi
  801a77:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801a7b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801a7f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a83:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801a87:	89 f3                	mov    %esi,%ebx
  801a89:	89 fa                	mov    %edi,%edx
  801a8b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801a8f:	89 34 24             	mov    %esi,(%esp)
  801a92:	85 c0                	test   %eax,%eax
  801a94:	75 1a                	jne    801ab0 <__umoddi3+0x48>
  801a96:	39 f7                	cmp    %esi,%edi
  801a98:	0f 86 a2 00 00 00    	jbe    801b40 <__umoddi3+0xd8>
  801a9e:	89 c8                	mov    %ecx,%eax
  801aa0:	89 f2                	mov    %esi,%edx
  801aa2:	f7 f7                	div    %edi
  801aa4:	89 d0                	mov    %edx,%eax
  801aa6:	31 d2                	xor    %edx,%edx
  801aa8:	83 c4 1c             	add    $0x1c,%esp
  801aab:	5b                   	pop    %ebx
  801aac:	5e                   	pop    %esi
  801aad:	5f                   	pop    %edi
  801aae:	5d                   	pop    %ebp
  801aaf:	c3                   	ret    
  801ab0:	39 f0                	cmp    %esi,%eax
  801ab2:	0f 87 ac 00 00 00    	ja     801b64 <__umoddi3+0xfc>
  801ab8:	0f bd e8             	bsr    %eax,%ebp
  801abb:	83 f5 1f             	xor    $0x1f,%ebp
  801abe:	0f 84 ac 00 00 00    	je     801b70 <__umoddi3+0x108>
  801ac4:	bf 20 00 00 00       	mov    $0x20,%edi
  801ac9:	29 ef                	sub    %ebp,%edi
  801acb:	89 fe                	mov    %edi,%esi
  801acd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801ad1:	89 e9                	mov    %ebp,%ecx
  801ad3:	d3 e0                	shl    %cl,%eax
  801ad5:	89 d7                	mov    %edx,%edi
  801ad7:	89 f1                	mov    %esi,%ecx
  801ad9:	d3 ef                	shr    %cl,%edi
  801adb:	09 c7                	or     %eax,%edi
  801add:	89 e9                	mov    %ebp,%ecx
  801adf:	d3 e2                	shl    %cl,%edx
  801ae1:	89 14 24             	mov    %edx,(%esp)
  801ae4:	89 d8                	mov    %ebx,%eax
  801ae6:	d3 e0                	shl    %cl,%eax
  801ae8:	89 c2                	mov    %eax,%edx
  801aea:	8b 44 24 08          	mov    0x8(%esp),%eax
  801aee:	d3 e0                	shl    %cl,%eax
  801af0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801af4:	8b 44 24 08          	mov    0x8(%esp),%eax
  801af8:	89 f1                	mov    %esi,%ecx
  801afa:	d3 e8                	shr    %cl,%eax
  801afc:	09 d0                	or     %edx,%eax
  801afe:	d3 eb                	shr    %cl,%ebx
  801b00:	89 da                	mov    %ebx,%edx
  801b02:	f7 f7                	div    %edi
  801b04:	89 d3                	mov    %edx,%ebx
  801b06:	f7 24 24             	mull   (%esp)
  801b09:	89 c6                	mov    %eax,%esi
  801b0b:	89 d1                	mov    %edx,%ecx
  801b0d:	39 d3                	cmp    %edx,%ebx
  801b0f:	0f 82 87 00 00 00    	jb     801b9c <__umoddi3+0x134>
  801b15:	0f 84 91 00 00 00    	je     801bac <__umoddi3+0x144>
  801b1b:	8b 54 24 04          	mov    0x4(%esp),%edx
  801b1f:	29 f2                	sub    %esi,%edx
  801b21:	19 cb                	sbb    %ecx,%ebx
  801b23:	89 d8                	mov    %ebx,%eax
  801b25:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  801b29:	d3 e0                	shl    %cl,%eax
  801b2b:	89 e9                	mov    %ebp,%ecx
  801b2d:	d3 ea                	shr    %cl,%edx
  801b2f:	09 d0                	or     %edx,%eax
  801b31:	89 e9                	mov    %ebp,%ecx
  801b33:	d3 eb                	shr    %cl,%ebx
  801b35:	89 da                	mov    %ebx,%edx
  801b37:	83 c4 1c             	add    $0x1c,%esp
  801b3a:	5b                   	pop    %ebx
  801b3b:	5e                   	pop    %esi
  801b3c:	5f                   	pop    %edi
  801b3d:	5d                   	pop    %ebp
  801b3e:	c3                   	ret    
  801b3f:	90                   	nop
  801b40:	89 fd                	mov    %edi,%ebp
  801b42:	85 ff                	test   %edi,%edi
  801b44:	75 0b                	jne    801b51 <__umoddi3+0xe9>
  801b46:	b8 01 00 00 00       	mov    $0x1,%eax
  801b4b:	31 d2                	xor    %edx,%edx
  801b4d:	f7 f7                	div    %edi
  801b4f:	89 c5                	mov    %eax,%ebp
  801b51:	89 f0                	mov    %esi,%eax
  801b53:	31 d2                	xor    %edx,%edx
  801b55:	f7 f5                	div    %ebp
  801b57:	89 c8                	mov    %ecx,%eax
  801b59:	f7 f5                	div    %ebp
  801b5b:	89 d0                	mov    %edx,%eax
  801b5d:	e9 44 ff ff ff       	jmp    801aa6 <__umoddi3+0x3e>
  801b62:	66 90                	xchg   %ax,%ax
  801b64:	89 c8                	mov    %ecx,%eax
  801b66:	89 f2                	mov    %esi,%edx
  801b68:	83 c4 1c             	add    $0x1c,%esp
  801b6b:	5b                   	pop    %ebx
  801b6c:	5e                   	pop    %esi
  801b6d:	5f                   	pop    %edi
  801b6e:	5d                   	pop    %ebp
  801b6f:	c3                   	ret    
  801b70:	3b 04 24             	cmp    (%esp),%eax
  801b73:	72 06                	jb     801b7b <__umoddi3+0x113>
  801b75:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  801b79:	77 0f                	ja     801b8a <__umoddi3+0x122>
  801b7b:	89 f2                	mov    %esi,%edx
  801b7d:	29 f9                	sub    %edi,%ecx
  801b7f:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  801b83:	89 14 24             	mov    %edx,(%esp)
  801b86:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801b8a:	8b 44 24 04          	mov    0x4(%esp),%eax
  801b8e:	8b 14 24             	mov    (%esp),%edx
  801b91:	83 c4 1c             	add    $0x1c,%esp
  801b94:	5b                   	pop    %ebx
  801b95:	5e                   	pop    %esi
  801b96:	5f                   	pop    %edi
  801b97:	5d                   	pop    %ebp
  801b98:	c3                   	ret    
  801b99:	8d 76 00             	lea    0x0(%esi),%esi
  801b9c:	2b 04 24             	sub    (%esp),%eax
  801b9f:	19 fa                	sbb    %edi,%edx
  801ba1:	89 d1                	mov    %edx,%ecx
  801ba3:	89 c6                	mov    %eax,%esi
  801ba5:	e9 71 ff ff ff       	jmp    801b1b <__umoddi3+0xb3>
  801baa:	66 90                	xchg   %ax,%ax
  801bac:	39 44 24 04          	cmp    %eax,0x4(%esp)
  801bb0:	72 ea                	jb     801b9c <__umoddi3+0x134>
  801bb2:	89 d9                	mov    %ebx,%ecx
  801bb4:	e9 62 ff ff ff       	jmp    801b1b <__umoddi3+0xb3>
