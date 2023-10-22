
obj/user/fos_data_on_stack:     file format elf32-i386


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
  800031:	e8 1e 00 00 00       	call   800054 <libmain>
1:      jmp 1b
  800036:	eb fe                	jmp    800036 <args_exist+0x5>

00800038 <_main>:
#include <inc/lib.h>


void _main(void)
{
  800038:	55                   	push   %ebp
  800039:	89 e5                	mov    %esp,%ebp
  80003b:	81 ec 48 27 00 00    	sub    $0x2748,%esp
	/// Adding array of 512 integer on user stack
	int arr[2512];

	atomic_cprintf("user stack contains 512 integer\n");
  800041:	83 ec 0c             	sub    $0xc,%esp
  800044:	68 80 1b 80 00       	push   $0x801b80
  800049:	e8 4c 02 00 00       	call   80029a <atomic_cprintf>
  80004e:	83 c4 10             	add    $0x10,%esp

	return;	
  800051:	90                   	nop
}
  800052:	c9                   	leave  
  800053:	c3                   	ret    

00800054 <libmain>:
volatile struct Env *myEnv = NULL;
volatile char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	83 ec 18             	sub    $0x18,%esp
	int envIndex = sys_getenvindex();
  80005a:	e8 a8 13 00 00       	call   801407 <sys_getenvindex>
  80005f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	myEnv = &(envs[envIndex]);
  800062:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800065:	89 d0                	mov    %edx,%eax
  800067:	01 c0                	add    %eax,%eax
  800069:	01 d0                	add    %edx,%eax
  80006b:	01 c0                	add    %eax,%eax
  80006d:	01 d0                	add    %edx,%eax
  80006f:	c1 e0 02             	shl    $0x2,%eax
  800072:	01 d0                	add    %edx,%eax
  800074:	01 c0                	add    %eax,%eax
  800076:	01 d0                	add    %edx,%eax
  800078:	c1 e0 02             	shl    $0x2,%eax
  80007b:	01 d0                	add    %edx,%eax
  80007d:	c1 e0 02             	shl    $0x2,%eax
  800080:	01 d0                	add    %edx,%eax
  800082:	c1 e0 02             	shl    $0x2,%eax
  800085:	01 d0                	add    %edx,%eax
  800087:	c1 e0 05             	shl    $0x5,%eax
  80008a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008f:	a3 20 30 80 00       	mov    %eax,0x803020

	//SET THE PROGRAM NAME
	if (myEnv->prog_name[0] != '\0')
  800094:	a1 20 30 80 00       	mov    0x803020,%eax
  800099:	8a 40 5c             	mov    0x5c(%eax),%al
  80009c:	84 c0                	test   %al,%al
  80009e:	74 0d                	je     8000ad <libmain+0x59>
		binaryname = myEnv->prog_name;
  8000a0:	a1 20 30 80 00       	mov    0x803020,%eax
  8000a5:	83 c0 5c             	add    $0x5c,%eax
  8000a8:	a3 00 30 80 00       	mov    %eax,0x803000

	// set env to point at our env structure in envs[].
	// env = envs;

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ad:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000b1:	7e 0a                	jle    8000bd <libmain+0x69>
		binaryname = argv[0];
  8000b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000b6:	8b 00                	mov    (%eax),%eax
  8000b8:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	_main(argc, argv);
  8000bd:	83 ec 08             	sub    $0x8,%esp
  8000c0:	ff 75 0c             	pushl  0xc(%ebp)
  8000c3:	ff 75 08             	pushl  0x8(%ebp)
  8000c6:	e8 6d ff ff ff       	call   800038 <_main>
  8000cb:	83 c4 10             	add    $0x10,%esp



	sys_disable_interrupt();
  8000ce:	e8 41 11 00 00       	call   801214 <sys_disable_interrupt>
	cprintf("**************************************\n");
  8000d3:	83 ec 0c             	sub    $0xc,%esp
  8000d6:	68 bc 1b 80 00       	push   $0x801bbc
  8000db:	e8 8d 01 00 00       	call   80026d <cprintf>
  8000e0:	83 c4 10             	add    $0x10,%esp
	cprintf("Num of PAGE faults = %d, modif = %d\n", myEnv->pageFaultsCounter, myEnv->nModifiedPages);
  8000e3:	a1 20 30 80 00       	mov    0x803020,%eax
  8000e8:	8b 90 84 da 01 00    	mov    0x1da84(%eax),%edx
  8000ee:	a1 20 30 80 00       	mov    0x803020,%eax
  8000f3:	8b 80 74 da 01 00    	mov    0x1da74(%eax),%eax
  8000f9:	83 ec 04             	sub    $0x4,%esp
  8000fc:	52                   	push   %edx
  8000fd:	50                   	push   %eax
  8000fe:	68 e4 1b 80 00       	push   $0x801be4
  800103:	e8 65 01 00 00       	call   80026d <cprintf>
  800108:	83 c4 10             	add    $0x10,%esp
	cprintf("# PAGE IN (from disk) = %d, # PAGE OUT (on disk) = %d, # NEW PAGE ADDED (on disk) = %d\n", myEnv->nPageIn, myEnv->nPageOut,myEnv->nNewPageAdded);
  80010b:	a1 20 30 80 00       	mov    0x803020,%eax
  800110:	8b 88 98 da 01 00    	mov    0x1da98(%eax),%ecx
  800116:	a1 20 30 80 00       	mov    0x803020,%eax
  80011b:	8b 90 94 da 01 00    	mov    0x1da94(%eax),%edx
  800121:	a1 20 30 80 00       	mov    0x803020,%eax
  800126:	8b 80 90 da 01 00    	mov    0x1da90(%eax),%eax
  80012c:	51                   	push   %ecx
  80012d:	52                   	push   %edx
  80012e:	50                   	push   %eax
  80012f:	68 0c 1c 80 00       	push   $0x801c0c
  800134:	e8 34 01 00 00       	call   80026d <cprintf>
  800139:	83 c4 10             	add    $0x10,%esp
	//cprintf("Num of freeing scarce memory = %d, freeing full working set = %d\n", myEnv->freeingScarceMemCounter, myEnv->freeingFullWSCounter);
	cprintf("Num of clocks = %d\n", myEnv->nClocks);
  80013c:	a1 20 30 80 00       	mov    0x803020,%eax
  800141:	8b 80 9c da 01 00    	mov    0x1da9c(%eax),%eax
  800147:	83 ec 08             	sub    $0x8,%esp
  80014a:	50                   	push   %eax
  80014b:	68 64 1c 80 00       	push   $0x801c64
  800150:	e8 18 01 00 00       	call   80026d <cprintf>
  800155:	83 c4 10             	add    $0x10,%esp
	cprintf("**************************************\n");
  800158:	83 ec 0c             	sub    $0xc,%esp
  80015b:	68 bc 1b 80 00       	push   $0x801bbc
  800160:	e8 08 01 00 00       	call   80026d <cprintf>
  800165:	83 c4 10             	add    $0x10,%esp
	sys_enable_interrupt();
  800168:	e8 c1 10 00 00       	call   80122e <sys_enable_interrupt>

	// exit gracefully
	exit();
  80016d:	e8 19 00 00 00       	call   80018b <exit>
}
  800172:	90                   	nop
  800173:	c9                   	leave  
  800174:	c3                   	ret    

00800175 <destroy>:

#include <inc/lib.h>

void
destroy(void)
{
  800175:	55                   	push   %ebp
  800176:	89 e5                	mov    %esp,%ebp
  800178:	83 ec 08             	sub    $0x8,%esp
	sys_destroy_env(0);
  80017b:	83 ec 0c             	sub    $0xc,%esp
  80017e:	6a 00                	push   $0x0
  800180:	e8 4e 12 00 00       	call   8013d3 <sys_destroy_env>
  800185:	83 c4 10             	add    $0x10,%esp
}
  800188:	90                   	nop
  800189:	c9                   	leave  
  80018a:	c3                   	ret    

0080018b <exit>:

void
exit(void)
{
  80018b:	55                   	push   %ebp
  80018c:	89 e5                	mov    %esp,%ebp
  80018e:	83 ec 08             	sub    $0x8,%esp
	sys_exit_env();
  800191:	e8 a3 12 00 00       	call   801439 <sys_exit_env>
}
  800196:	90                   	nop
  800197:	c9                   	leave  
  800198:	c3                   	ret    

00800199 <putch>:
};

//2017:
uint8 printProgName = 0;

static void putch(int ch, struct printbuf *b) {
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	83 ec 08             	sub    $0x8,%esp
	b->buf[b->idx++] = ch;
  80019f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001a2:	8b 00                	mov    (%eax),%eax
  8001a4:	8d 48 01             	lea    0x1(%eax),%ecx
  8001a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001aa:	89 0a                	mov    %ecx,(%edx)
  8001ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8001af:	88 d1                	mov    %dl,%cl
  8001b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b4:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256 - 1) {
  8001b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001bb:	8b 00                	mov    (%eax),%eax
  8001bd:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c2:	75 2c                	jne    8001f0 <putch+0x57>
		sys_cputs(b->buf, b->idx, printProgName);
  8001c4:	a0 24 30 80 00       	mov    0x803024,%al
  8001c9:	0f b6 c0             	movzbl %al,%eax
  8001cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001cf:	8b 12                	mov    (%edx),%edx
  8001d1:	89 d1                	mov    %edx,%ecx
  8001d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d6:	83 c2 08             	add    $0x8,%edx
  8001d9:	83 ec 04             	sub    $0x4,%esp
  8001dc:	50                   	push   %eax
  8001dd:	51                   	push   %ecx
  8001de:	52                   	push   %edx
  8001df:	e8 d7 0e 00 00       	call   8010bb <sys_cputs>
  8001e4:	83 c4 10             	add    $0x10,%esp
		b->idx = 0;
  8001e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001ea:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  8001f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001f3:	8b 40 04             	mov    0x4(%eax),%eax
  8001f6:	8d 50 01             	lea    0x1(%eax),%edx
  8001f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001fc:	89 50 04             	mov    %edx,0x4(%eax)
}
  8001ff:	90                   	nop
  800200:	c9                   	leave  
  800201:	c3                   	ret    

00800202 <vcprintf>:

int vcprintf(const char *fmt, va_list ap) {
  800202:	55                   	push   %ebp
  800203:	89 e5                	mov    %esp,%ebp
  800205:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80020b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800212:	00 00 00 
	b.cnt = 0;
  800215:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80021c:	00 00 00 
	vprintfmt((void*) putch, &b, fmt, ap);
  80021f:	ff 75 0c             	pushl  0xc(%ebp)
  800222:	ff 75 08             	pushl  0x8(%ebp)
  800225:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80022b:	50                   	push   %eax
  80022c:	68 99 01 80 00       	push   $0x800199
  800231:	e8 11 02 00 00       	call   800447 <vprintfmt>
  800236:	83 c4 10             	add    $0x10,%esp
	sys_cputs(b.buf, b.idx, printProgName);
  800239:	a0 24 30 80 00       	mov    0x803024,%al
  80023e:	0f b6 c0             	movzbl %al,%eax
  800241:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
  800247:	83 ec 04             	sub    $0x4,%esp
  80024a:	50                   	push   %eax
  80024b:	52                   	push   %edx
  80024c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800252:	83 c0 08             	add    $0x8,%eax
  800255:	50                   	push   %eax
  800256:	e8 60 0e 00 00       	call   8010bb <sys_cputs>
  80025b:	83 c4 10             	add    $0x10,%esp

	printProgName = 0;
  80025e:	c6 05 24 30 80 00 00 	movb   $0x0,0x803024
	return b.cnt;
  800265:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  80026b:	c9                   	leave  
  80026c:	c3                   	ret    

0080026d <cprintf>:

int cprintf(const char *fmt, ...) {
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;
	printProgName = 1 ;
  800273:	c6 05 24 30 80 00 01 	movb   $0x1,0x803024
	va_start(ap, fmt);
  80027a:	8d 45 0c             	lea    0xc(%ebp),%eax
  80027d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cnt = vcprintf(fmt, ap);
  800280:	8b 45 08             	mov    0x8(%ebp),%eax
  800283:	83 ec 08             	sub    $0x8,%esp
  800286:	ff 75 f4             	pushl  -0xc(%ebp)
  800289:	50                   	push   %eax
  80028a:	e8 73 ff ff ff       	call   800202 <vcprintf>
  80028f:	83 c4 10             	add    $0x10,%esp
  800292:	89 45 f0             	mov    %eax,-0x10(%ebp)
	va_end(ap);

	return cnt;
  800295:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  800298:	c9                   	leave  
  800299:	c3                   	ret    

0080029a <atomic_cprintf>:

int atomic_cprintf(const char *fmt, ...) {
  80029a:	55                   	push   %ebp
  80029b:	89 e5                	mov    %esp,%ebp
  80029d:	83 ec 18             	sub    $0x18,%esp
	sys_disable_interrupt();
  8002a0:	e8 6f 0f 00 00       	call   801214 <sys_disable_interrupt>
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002a5:	8d 45 0c             	lea    0xc(%ebp),%eax
  8002a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cnt = vcprintf(fmt, ap);
  8002ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ae:	83 ec 08             	sub    $0x8,%esp
  8002b1:	ff 75 f4             	pushl  -0xc(%ebp)
  8002b4:	50                   	push   %eax
  8002b5:	e8 48 ff ff ff       	call   800202 <vcprintf>
  8002ba:	83 c4 10             	add    $0x10,%esp
  8002bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
	va_end(ap);

	sys_enable_interrupt();
  8002c0:	e8 69 0f 00 00       	call   80122e <sys_enable_interrupt>
	return cnt;
  8002c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  8002c8:	c9                   	leave  
  8002c9:	c3                   	ret    

008002ca <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002ca:	55                   	push   %ebp
  8002cb:	89 e5                	mov    %esp,%ebp
  8002cd:	53                   	push   %ebx
  8002ce:	83 ec 14             	sub    $0x14,%esp
  8002d1:	8b 45 10             	mov    0x10(%ebp),%eax
  8002d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8002d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8002da:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002dd:	8b 45 18             	mov    0x18(%ebp),%eax
  8002e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e5:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8002e8:	77 55                	ja     80033f <printnum+0x75>
  8002ea:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8002ed:	72 05                	jb     8002f4 <printnum+0x2a>
  8002ef:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8002f2:	77 4b                	ja     80033f <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f4:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8002f7:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002fa:	8b 45 18             	mov    0x18(%ebp),%eax
  8002fd:	ba 00 00 00 00       	mov    $0x0,%edx
  800302:	52                   	push   %edx
  800303:	50                   	push   %eax
  800304:	ff 75 f4             	pushl  -0xc(%ebp)
  800307:	ff 75 f0             	pushl  -0x10(%ebp)
  80030a:	e8 09 16 00 00       	call   801918 <__udivdi3>
  80030f:	83 c4 10             	add    $0x10,%esp
  800312:	83 ec 04             	sub    $0x4,%esp
  800315:	ff 75 20             	pushl  0x20(%ebp)
  800318:	53                   	push   %ebx
  800319:	ff 75 18             	pushl  0x18(%ebp)
  80031c:	52                   	push   %edx
  80031d:	50                   	push   %eax
  80031e:	ff 75 0c             	pushl  0xc(%ebp)
  800321:	ff 75 08             	pushl  0x8(%ebp)
  800324:	e8 a1 ff ff ff       	call   8002ca <printnum>
  800329:	83 c4 20             	add    $0x20,%esp
  80032c:	eb 1a                	jmp    800348 <printnum+0x7e>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80032e:	83 ec 08             	sub    $0x8,%esp
  800331:	ff 75 0c             	pushl  0xc(%ebp)
  800334:	ff 75 20             	pushl  0x20(%ebp)
  800337:	8b 45 08             	mov    0x8(%ebp),%eax
  80033a:	ff d0                	call   *%eax
  80033c:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80033f:	ff 4d 1c             	decl   0x1c(%ebp)
  800342:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800346:	7f e6                	jg     80032e <printnum+0x64>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800348:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80034b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800350:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800353:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800356:	53                   	push   %ebx
  800357:	51                   	push   %ecx
  800358:	52                   	push   %edx
  800359:	50                   	push   %eax
  80035a:	e8 c9 16 00 00       	call   801a28 <__umoddi3>
  80035f:	83 c4 10             	add    $0x10,%esp
  800362:	05 94 1e 80 00       	add    $0x801e94,%eax
  800367:	8a 00                	mov    (%eax),%al
  800369:	0f be c0             	movsbl %al,%eax
  80036c:	83 ec 08             	sub    $0x8,%esp
  80036f:	ff 75 0c             	pushl  0xc(%ebp)
  800372:	50                   	push   %eax
  800373:	8b 45 08             	mov    0x8(%ebp),%eax
  800376:	ff d0                	call   *%eax
  800378:	83 c4 10             	add    $0x10,%esp
}
  80037b:	90                   	nop
  80037c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80037f:	c9                   	leave  
  800380:	c3                   	ret    

00800381 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800381:	55                   	push   %ebp
  800382:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800384:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800388:	7e 1c                	jle    8003a6 <getuint+0x25>
		return va_arg(*ap, unsigned long long);
  80038a:	8b 45 08             	mov    0x8(%ebp),%eax
  80038d:	8b 00                	mov    (%eax),%eax
  80038f:	8d 50 08             	lea    0x8(%eax),%edx
  800392:	8b 45 08             	mov    0x8(%ebp),%eax
  800395:	89 10                	mov    %edx,(%eax)
  800397:	8b 45 08             	mov    0x8(%ebp),%eax
  80039a:	8b 00                	mov    (%eax),%eax
  80039c:	83 e8 08             	sub    $0x8,%eax
  80039f:	8b 50 04             	mov    0x4(%eax),%edx
  8003a2:	8b 00                	mov    (%eax),%eax
  8003a4:	eb 40                	jmp    8003e6 <getuint+0x65>
	else if (lflag)
  8003a6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8003aa:	74 1e                	je     8003ca <getuint+0x49>
		return va_arg(*ap, unsigned long);
  8003ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8003af:	8b 00                	mov    (%eax),%eax
  8003b1:	8d 50 04             	lea    0x4(%eax),%edx
  8003b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b7:	89 10                	mov    %edx,(%eax)
  8003b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8003bc:	8b 00                	mov    (%eax),%eax
  8003be:	83 e8 04             	sub    $0x4,%eax
  8003c1:	8b 00                	mov    (%eax),%eax
  8003c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8003c8:	eb 1c                	jmp    8003e6 <getuint+0x65>
	else
		return va_arg(*ap, unsigned int);
  8003ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8003cd:	8b 00                	mov    (%eax),%eax
  8003cf:	8d 50 04             	lea    0x4(%eax),%edx
  8003d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d5:	89 10                	mov    %edx,(%eax)
  8003d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003da:	8b 00                	mov    (%eax),%eax
  8003dc:	83 e8 04             	sub    $0x4,%eax
  8003df:	8b 00                	mov    (%eax),%eax
  8003e1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003e6:	5d                   	pop    %ebp
  8003e7:	c3                   	ret    

008003e8 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003eb:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8003ef:	7e 1c                	jle    80040d <getint+0x25>
		return va_arg(*ap, long long);
  8003f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f4:	8b 00                	mov    (%eax),%eax
  8003f6:	8d 50 08             	lea    0x8(%eax),%edx
  8003f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fc:	89 10                	mov    %edx,(%eax)
  8003fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800401:	8b 00                	mov    (%eax),%eax
  800403:	83 e8 08             	sub    $0x8,%eax
  800406:	8b 50 04             	mov    0x4(%eax),%edx
  800409:	8b 00                	mov    (%eax),%eax
  80040b:	eb 38                	jmp    800445 <getint+0x5d>
	else if (lflag)
  80040d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800411:	74 1a                	je     80042d <getint+0x45>
		return va_arg(*ap, long);
  800413:	8b 45 08             	mov    0x8(%ebp),%eax
  800416:	8b 00                	mov    (%eax),%eax
  800418:	8d 50 04             	lea    0x4(%eax),%edx
  80041b:	8b 45 08             	mov    0x8(%ebp),%eax
  80041e:	89 10                	mov    %edx,(%eax)
  800420:	8b 45 08             	mov    0x8(%ebp),%eax
  800423:	8b 00                	mov    (%eax),%eax
  800425:	83 e8 04             	sub    $0x4,%eax
  800428:	8b 00                	mov    (%eax),%eax
  80042a:	99                   	cltd   
  80042b:	eb 18                	jmp    800445 <getint+0x5d>
	else
		return va_arg(*ap, int);
  80042d:	8b 45 08             	mov    0x8(%ebp),%eax
  800430:	8b 00                	mov    (%eax),%eax
  800432:	8d 50 04             	lea    0x4(%eax),%edx
  800435:	8b 45 08             	mov    0x8(%ebp),%eax
  800438:	89 10                	mov    %edx,(%eax)
  80043a:	8b 45 08             	mov    0x8(%ebp),%eax
  80043d:	8b 00                	mov    (%eax),%eax
  80043f:	83 e8 04             	sub    $0x4,%eax
  800442:	8b 00                	mov    (%eax),%eax
  800444:	99                   	cltd   
}
  800445:	5d                   	pop    %ebp
  800446:	c3                   	ret    

00800447 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800447:	55                   	push   %ebp
  800448:	89 e5                	mov    %esp,%ebp
  80044a:	56                   	push   %esi
  80044b:	53                   	push   %ebx
  80044c:	83 ec 20             	sub    $0x20,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80044f:	eb 17                	jmp    800468 <vprintfmt+0x21>
			if (ch == '\0')
  800451:	85 db                	test   %ebx,%ebx
  800453:	0f 84 af 03 00 00    	je     800808 <vprintfmt+0x3c1>
				return;
			putch(ch, putdat);
  800459:	83 ec 08             	sub    $0x8,%esp
  80045c:	ff 75 0c             	pushl  0xc(%ebp)
  80045f:	53                   	push   %ebx
  800460:	8b 45 08             	mov    0x8(%ebp),%eax
  800463:	ff d0                	call   *%eax
  800465:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800468:	8b 45 10             	mov    0x10(%ebp),%eax
  80046b:	8d 50 01             	lea    0x1(%eax),%edx
  80046e:	89 55 10             	mov    %edx,0x10(%ebp)
  800471:	8a 00                	mov    (%eax),%al
  800473:	0f b6 d8             	movzbl %al,%ebx
  800476:	83 fb 25             	cmp    $0x25,%ebx
  800479:	75 d6                	jne    800451 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  80047b:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  80047f:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800486:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80048d:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  800494:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049b:	8b 45 10             	mov    0x10(%ebp),%eax
  80049e:	8d 50 01             	lea    0x1(%eax),%edx
  8004a1:	89 55 10             	mov    %edx,0x10(%ebp)
  8004a4:	8a 00                	mov    (%eax),%al
  8004a6:	0f b6 d8             	movzbl %al,%ebx
  8004a9:	8d 43 dd             	lea    -0x23(%ebx),%eax
  8004ac:	83 f8 55             	cmp    $0x55,%eax
  8004af:	0f 87 2b 03 00 00    	ja     8007e0 <vprintfmt+0x399>
  8004b5:	8b 04 85 b8 1e 80 00 	mov    0x801eb8(,%eax,4),%eax
  8004bc:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  8004be:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  8004c2:	eb d7                	jmp    80049b <vprintfmt+0x54>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004c4:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  8004c8:	eb d1                	jmp    80049b <vprintfmt+0x54>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004ca:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8004d1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004d4:	89 d0                	mov    %edx,%eax
  8004d6:	c1 e0 02             	shl    $0x2,%eax
  8004d9:	01 d0                	add    %edx,%eax
  8004db:	01 c0                	add    %eax,%eax
  8004dd:	01 d8                	add    %ebx,%eax
  8004df:	83 e8 30             	sub    $0x30,%eax
  8004e2:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8004e5:	8b 45 10             	mov    0x10(%ebp),%eax
  8004e8:	8a 00                	mov    (%eax),%al
  8004ea:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8004ed:	83 fb 2f             	cmp    $0x2f,%ebx
  8004f0:	7e 3e                	jle    800530 <vprintfmt+0xe9>
  8004f2:	83 fb 39             	cmp    $0x39,%ebx
  8004f5:	7f 39                	jg     800530 <vprintfmt+0xe9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004f7:	ff 45 10             	incl   0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004fa:	eb d5                	jmp    8004d1 <vprintfmt+0x8a>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ff:	83 c0 04             	add    $0x4,%eax
  800502:	89 45 14             	mov    %eax,0x14(%ebp)
  800505:	8b 45 14             	mov    0x14(%ebp),%eax
  800508:	83 e8 04             	sub    $0x4,%eax
  80050b:	8b 00                	mov    (%eax),%eax
  80050d:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  800510:	eb 1f                	jmp    800531 <vprintfmt+0xea>

		case '.':
			if (width < 0)
  800512:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800516:	79 83                	jns    80049b <vprintfmt+0x54>
				width = 0;
  800518:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  80051f:	e9 77 ff ff ff       	jmp    80049b <vprintfmt+0x54>

		case '#':
			altflag = 1;
  800524:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80052b:	e9 6b ff ff ff       	jmp    80049b <vprintfmt+0x54>
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
			goto process_precision;
  800530:	90                   	nop
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800531:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800535:	0f 89 60 ff ff ff    	jns    80049b <vprintfmt+0x54>
				width = precision, precision = -1;
  80053b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80053e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800541:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800548:	e9 4e ff ff ff       	jmp    80049b <vprintfmt+0x54>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80054d:	ff 45 e8             	incl   -0x18(%ebp)
			goto reswitch;
  800550:	e9 46 ff ff ff       	jmp    80049b <vprintfmt+0x54>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800555:	8b 45 14             	mov    0x14(%ebp),%eax
  800558:	83 c0 04             	add    $0x4,%eax
  80055b:	89 45 14             	mov    %eax,0x14(%ebp)
  80055e:	8b 45 14             	mov    0x14(%ebp),%eax
  800561:	83 e8 04             	sub    $0x4,%eax
  800564:	8b 00                	mov    (%eax),%eax
  800566:	83 ec 08             	sub    $0x8,%esp
  800569:	ff 75 0c             	pushl  0xc(%ebp)
  80056c:	50                   	push   %eax
  80056d:	8b 45 08             	mov    0x8(%ebp),%eax
  800570:	ff d0                	call   *%eax
  800572:	83 c4 10             	add    $0x10,%esp
			break;
  800575:	e9 89 02 00 00       	jmp    800803 <vprintfmt+0x3bc>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80057a:	8b 45 14             	mov    0x14(%ebp),%eax
  80057d:	83 c0 04             	add    $0x4,%eax
  800580:	89 45 14             	mov    %eax,0x14(%ebp)
  800583:	8b 45 14             	mov    0x14(%ebp),%eax
  800586:	83 e8 04             	sub    $0x4,%eax
  800589:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  80058b:	85 db                	test   %ebx,%ebx
  80058d:	79 02                	jns    800591 <vprintfmt+0x14a>
				err = -err;
  80058f:	f7 db                	neg    %ebx
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800591:	83 fb 64             	cmp    $0x64,%ebx
  800594:	7f 0b                	jg     8005a1 <vprintfmt+0x15a>
  800596:	8b 34 9d 00 1d 80 00 	mov    0x801d00(,%ebx,4),%esi
  80059d:	85 f6                	test   %esi,%esi
  80059f:	75 19                	jne    8005ba <vprintfmt+0x173>
				printfmt(putch, putdat, "error %d", err);
  8005a1:	53                   	push   %ebx
  8005a2:	68 a5 1e 80 00       	push   $0x801ea5
  8005a7:	ff 75 0c             	pushl  0xc(%ebp)
  8005aa:	ff 75 08             	pushl  0x8(%ebp)
  8005ad:	e8 5e 02 00 00       	call   800810 <printfmt>
  8005b2:	83 c4 10             	add    $0x10,%esp
			else
				printfmt(putch, putdat, "%s", p);
			break;
  8005b5:	e9 49 02 00 00       	jmp    800803 <vprintfmt+0x3bc>
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8005ba:	56                   	push   %esi
  8005bb:	68 ae 1e 80 00       	push   $0x801eae
  8005c0:	ff 75 0c             	pushl  0xc(%ebp)
  8005c3:	ff 75 08             	pushl  0x8(%ebp)
  8005c6:	e8 45 02 00 00       	call   800810 <printfmt>
  8005cb:	83 c4 10             	add    $0x10,%esp
			break;
  8005ce:	e9 30 02 00 00       	jmp    800803 <vprintfmt+0x3bc>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d6:	83 c0 04             	add    $0x4,%eax
  8005d9:	89 45 14             	mov    %eax,0x14(%ebp)
  8005dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005df:	83 e8 04             	sub    $0x4,%eax
  8005e2:	8b 30                	mov    (%eax),%esi
  8005e4:	85 f6                	test   %esi,%esi
  8005e6:	75 05                	jne    8005ed <vprintfmt+0x1a6>
				p = "(null)";
  8005e8:	be b1 1e 80 00       	mov    $0x801eb1,%esi
			if (width > 0 && padc != '-')
  8005ed:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005f1:	7e 6d                	jle    800660 <vprintfmt+0x219>
  8005f3:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  8005f7:	74 67                	je     800660 <vprintfmt+0x219>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005fc:	83 ec 08             	sub    $0x8,%esp
  8005ff:	50                   	push   %eax
  800600:	56                   	push   %esi
  800601:	e8 0c 03 00 00       	call   800912 <strnlen>
  800606:	83 c4 10             	add    $0x10,%esp
  800609:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  80060c:	eb 16                	jmp    800624 <vprintfmt+0x1dd>
					putch(padc, putdat);
  80060e:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800612:	83 ec 08             	sub    $0x8,%esp
  800615:	ff 75 0c             	pushl  0xc(%ebp)
  800618:	50                   	push   %eax
  800619:	8b 45 08             	mov    0x8(%ebp),%eax
  80061c:	ff d0                	call   *%eax
  80061e:	83 c4 10             	add    $0x10,%esp
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800621:	ff 4d e4             	decl   -0x1c(%ebp)
  800624:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800628:	7f e4                	jg     80060e <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80062a:	eb 34                	jmp    800660 <vprintfmt+0x219>
				if (altflag && (ch < ' ' || ch > '~'))
  80062c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800630:	74 1c                	je     80064e <vprintfmt+0x207>
  800632:	83 fb 1f             	cmp    $0x1f,%ebx
  800635:	7e 05                	jle    80063c <vprintfmt+0x1f5>
  800637:	83 fb 7e             	cmp    $0x7e,%ebx
  80063a:	7e 12                	jle    80064e <vprintfmt+0x207>
					putch('?', putdat);
  80063c:	83 ec 08             	sub    $0x8,%esp
  80063f:	ff 75 0c             	pushl  0xc(%ebp)
  800642:	6a 3f                	push   $0x3f
  800644:	8b 45 08             	mov    0x8(%ebp),%eax
  800647:	ff d0                	call   *%eax
  800649:	83 c4 10             	add    $0x10,%esp
  80064c:	eb 0f                	jmp    80065d <vprintfmt+0x216>
				else
					putch(ch, putdat);
  80064e:	83 ec 08             	sub    $0x8,%esp
  800651:	ff 75 0c             	pushl  0xc(%ebp)
  800654:	53                   	push   %ebx
  800655:	8b 45 08             	mov    0x8(%ebp),%eax
  800658:	ff d0                	call   *%eax
  80065a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80065d:	ff 4d e4             	decl   -0x1c(%ebp)
  800660:	89 f0                	mov    %esi,%eax
  800662:	8d 70 01             	lea    0x1(%eax),%esi
  800665:	8a 00                	mov    (%eax),%al
  800667:	0f be d8             	movsbl %al,%ebx
  80066a:	85 db                	test   %ebx,%ebx
  80066c:	74 24                	je     800692 <vprintfmt+0x24b>
  80066e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800672:	78 b8                	js     80062c <vprintfmt+0x1e5>
  800674:	ff 4d e0             	decl   -0x20(%ebp)
  800677:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80067b:	79 af                	jns    80062c <vprintfmt+0x1e5>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80067d:	eb 13                	jmp    800692 <vprintfmt+0x24b>
				putch(' ', putdat);
  80067f:	83 ec 08             	sub    $0x8,%esp
  800682:	ff 75 0c             	pushl  0xc(%ebp)
  800685:	6a 20                	push   $0x20
  800687:	8b 45 08             	mov    0x8(%ebp),%eax
  80068a:	ff d0                	call   *%eax
  80068c:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80068f:	ff 4d e4             	decl   -0x1c(%ebp)
  800692:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800696:	7f e7                	jg     80067f <vprintfmt+0x238>
				putch(' ', putdat);
			break;
  800698:	e9 66 01 00 00       	jmp    800803 <vprintfmt+0x3bc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80069d:	83 ec 08             	sub    $0x8,%esp
  8006a0:	ff 75 e8             	pushl  -0x18(%ebp)
  8006a3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a6:	50                   	push   %eax
  8006a7:	e8 3c fd ff ff       	call   8003e8 <getint>
  8006ac:	83 c4 10             	add    $0x10,%esp
  8006af:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006b2:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  8006b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006bb:	85 d2                	test   %edx,%edx
  8006bd:	79 23                	jns    8006e2 <vprintfmt+0x29b>
				putch('-', putdat);
  8006bf:	83 ec 08             	sub    $0x8,%esp
  8006c2:	ff 75 0c             	pushl  0xc(%ebp)
  8006c5:	6a 2d                	push   $0x2d
  8006c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ca:	ff d0                	call   *%eax
  8006cc:	83 c4 10             	add    $0x10,%esp
				num = -(long long) num;
  8006cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006d5:	f7 d8                	neg    %eax
  8006d7:	83 d2 00             	adc    $0x0,%edx
  8006da:	f7 da                	neg    %edx
  8006dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006df:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  8006e2:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8006e9:	e9 bc 00 00 00       	jmp    8007aa <vprintfmt+0x363>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006ee:	83 ec 08             	sub    $0x8,%esp
  8006f1:	ff 75 e8             	pushl  -0x18(%ebp)
  8006f4:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f7:	50                   	push   %eax
  8006f8:	e8 84 fc ff ff       	call   800381 <getuint>
  8006fd:	83 c4 10             	add    $0x10,%esp
  800700:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800703:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800706:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  80070d:	e9 98 00 00 00       	jmp    8007aa <vprintfmt+0x363>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800712:	83 ec 08             	sub    $0x8,%esp
  800715:	ff 75 0c             	pushl  0xc(%ebp)
  800718:	6a 58                	push   $0x58
  80071a:	8b 45 08             	mov    0x8(%ebp),%eax
  80071d:	ff d0                	call   *%eax
  80071f:	83 c4 10             	add    $0x10,%esp
			putch('X', putdat);
  800722:	83 ec 08             	sub    $0x8,%esp
  800725:	ff 75 0c             	pushl  0xc(%ebp)
  800728:	6a 58                	push   $0x58
  80072a:	8b 45 08             	mov    0x8(%ebp),%eax
  80072d:	ff d0                	call   *%eax
  80072f:	83 c4 10             	add    $0x10,%esp
			putch('X', putdat);
  800732:	83 ec 08             	sub    $0x8,%esp
  800735:	ff 75 0c             	pushl  0xc(%ebp)
  800738:	6a 58                	push   $0x58
  80073a:	8b 45 08             	mov    0x8(%ebp),%eax
  80073d:	ff d0                	call   *%eax
  80073f:	83 c4 10             	add    $0x10,%esp
			break;
  800742:	e9 bc 00 00 00       	jmp    800803 <vprintfmt+0x3bc>

		// pointer
		case 'p':
			putch('0', putdat);
  800747:	83 ec 08             	sub    $0x8,%esp
  80074a:	ff 75 0c             	pushl  0xc(%ebp)
  80074d:	6a 30                	push   $0x30
  80074f:	8b 45 08             	mov    0x8(%ebp),%eax
  800752:	ff d0                	call   *%eax
  800754:	83 c4 10             	add    $0x10,%esp
			putch('x', putdat);
  800757:	83 ec 08             	sub    $0x8,%esp
  80075a:	ff 75 0c             	pushl  0xc(%ebp)
  80075d:	6a 78                	push   $0x78
  80075f:	8b 45 08             	mov    0x8(%ebp),%eax
  800762:	ff d0                	call   *%eax
  800764:	83 c4 10             	add    $0x10,%esp
			num = (unsigned long long)
				(uint32) va_arg(ap, void *);
  800767:	8b 45 14             	mov    0x14(%ebp),%eax
  80076a:	83 c0 04             	add    $0x4,%eax
  80076d:	89 45 14             	mov    %eax,0x14(%ebp)
  800770:	8b 45 14             	mov    0x14(%ebp),%eax
  800773:	83 e8 04             	sub    $0x4,%eax
  800776:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800778:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80077b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uint32) va_arg(ap, void *);
			base = 16;
  800782:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800789:	eb 1f                	jmp    8007aa <vprintfmt+0x363>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80078b:	83 ec 08             	sub    $0x8,%esp
  80078e:	ff 75 e8             	pushl  -0x18(%ebp)
  800791:	8d 45 14             	lea    0x14(%ebp),%eax
  800794:	50                   	push   %eax
  800795:	e8 e7 fb ff ff       	call   800381 <getuint>
  80079a:	83 c4 10             	add    $0x10,%esp
  80079d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007a0:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  8007a3:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007aa:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  8007ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007b1:	83 ec 04             	sub    $0x4,%esp
  8007b4:	52                   	push   %edx
  8007b5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007b8:	50                   	push   %eax
  8007b9:	ff 75 f4             	pushl  -0xc(%ebp)
  8007bc:	ff 75 f0             	pushl  -0x10(%ebp)
  8007bf:	ff 75 0c             	pushl  0xc(%ebp)
  8007c2:	ff 75 08             	pushl  0x8(%ebp)
  8007c5:	e8 00 fb ff ff       	call   8002ca <printnum>
  8007ca:	83 c4 20             	add    $0x20,%esp
			break;
  8007cd:	eb 34                	jmp    800803 <vprintfmt+0x3bc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007cf:	83 ec 08             	sub    $0x8,%esp
  8007d2:	ff 75 0c             	pushl  0xc(%ebp)
  8007d5:	53                   	push   %ebx
  8007d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d9:	ff d0                	call   *%eax
  8007db:	83 c4 10             	add    $0x10,%esp
			break;
  8007de:	eb 23                	jmp    800803 <vprintfmt+0x3bc>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007e0:	83 ec 08             	sub    $0x8,%esp
  8007e3:	ff 75 0c             	pushl  0xc(%ebp)
  8007e6:	6a 25                	push   $0x25
  8007e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007eb:	ff d0                	call   *%eax
  8007ed:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007f0:	ff 4d 10             	decl   0x10(%ebp)
  8007f3:	eb 03                	jmp    8007f8 <vprintfmt+0x3b1>
  8007f5:	ff 4d 10             	decl   0x10(%ebp)
  8007f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8007fb:	48                   	dec    %eax
  8007fc:	8a 00                	mov    (%eax),%al
  8007fe:	3c 25                	cmp    $0x25,%al
  800800:	75 f3                	jne    8007f5 <vprintfmt+0x3ae>
				/* do nothing */;
			break;
  800802:	90                   	nop
		}
	}
  800803:	e9 47 fc ff ff       	jmp    80044f <vprintfmt+0x8>
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
  800808:	90                   	nop
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800809:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80080c:	5b                   	pop    %ebx
  80080d:	5e                   	pop    %esi
  80080e:	5d                   	pop    %ebp
  80080f:	c3                   	ret    

00800810 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800810:	55                   	push   %ebp
  800811:	89 e5                	mov    %esp,%ebp
  800813:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800816:	8d 45 10             	lea    0x10(%ebp),%eax
  800819:	83 c0 04             	add    $0x4,%eax
  80081c:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  80081f:	8b 45 10             	mov    0x10(%ebp),%eax
  800822:	ff 75 f4             	pushl  -0xc(%ebp)
  800825:	50                   	push   %eax
  800826:	ff 75 0c             	pushl  0xc(%ebp)
  800829:	ff 75 08             	pushl  0x8(%ebp)
  80082c:	e8 16 fc ff ff       	call   800447 <vprintfmt>
  800831:	83 c4 10             	add    $0x10,%esp
	va_end(ap);
}
  800834:	90                   	nop
  800835:	c9                   	leave  
  800836:	c3                   	ret    

00800837 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800837:	55                   	push   %ebp
  800838:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  80083a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80083d:	8b 40 08             	mov    0x8(%eax),%eax
  800840:	8d 50 01             	lea    0x1(%eax),%edx
  800843:	8b 45 0c             	mov    0xc(%ebp),%eax
  800846:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800849:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084c:	8b 10                	mov    (%eax),%edx
  80084e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800851:	8b 40 04             	mov    0x4(%eax),%eax
  800854:	39 c2                	cmp    %eax,%edx
  800856:	73 12                	jae    80086a <sprintputch+0x33>
		*b->buf++ = ch;
  800858:	8b 45 0c             	mov    0xc(%ebp),%eax
  80085b:	8b 00                	mov    (%eax),%eax
  80085d:	8d 48 01             	lea    0x1(%eax),%ecx
  800860:	8b 55 0c             	mov    0xc(%ebp),%edx
  800863:	89 0a                	mov    %ecx,(%edx)
  800865:	8b 55 08             	mov    0x8(%ebp),%edx
  800868:	88 10                	mov    %dl,(%eax)
}
  80086a:	90                   	nop
  80086b:	5d                   	pop    %ebp
  80086c:	c3                   	ret    

0080086d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80086d:	55                   	push   %ebp
  80086e:	89 e5                	mov    %esp,%ebp
  800870:	83 ec 18             	sub    $0x18,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800873:	8b 45 08             	mov    0x8(%ebp),%eax
  800876:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800879:	8b 45 0c             	mov    0xc(%ebp),%eax
  80087c:	8d 50 ff             	lea    -0x1(%eax),%edx
  80087f:	8b 45 08             	mov    0x8(%ebp),%eax
  800882:	01 d0                	add    %edx,%eax
  800884:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800887:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80088e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800892:	74 06                	je     80089a <vsnprintf+0x2d>
  800894:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800898:	7f 07                	jg     8008a1 <vsnprintf+0x34>
		return -E_INVAL;
  80089a:	b8 03 00 00 00       	mov    $0x3,%eax
  80089f:	eb 20                	jmp    8008c1 <vsnprintf+0x54>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008a1:	ff 75 14             	pushl  0x14(%ebp)
  8008a4:	ff 75 10             	pushl  0x10(%ebp)
  8008a7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008aa:	50                   	push   %eax
  8008ab:	68 37 08 80 00       	push   $0x800837
  8008b0:	e8 92 fb ff ff       	call   800447 <vprintfmt>
  8008b5:	83 c4 10             	add    $0x10,%esp

	// null terminate the buffer
	*b.buf = '\0';
  8008b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008bb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008be:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8008c1:	c9                   	leave  
  8008c2:	c3                   	ret    

008008c3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008c9:	8d 45 10             	lea    0x10(%ebp),%eax
  8008cc:	83 c0 04             	add    $0x4,%eax
  8008cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8008d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8008d5:	ff 75 f4             	pushl  -0xc(%ebp)
  8008d8:	50                   	push   %eax
  8008d9:	ff 75 0c             	pushl  0xc(%ebp)
  8008dc:	ff 75 08             	pushl  0x8(%ebp)
  8008df:	e8 89 ff ff ff       	call   80086d <vsnprintf>
  8008e4:	83 c4 10             	add    $0x10,%esp
  8008e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
	va_end(ap);

	return rc;
  8008ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  8008ed:	c9                   	leave  
  8008ee:	c3                   	ret    

008008ef <strlen>:

#include <inc/string.h>
#include <inc/assert.h>
int
strlen(const char *s)
{
  8008ef:	55                   	push   %ebp
  8008f0:	89 e5                	mov    %esp,%ebp
  8008f2:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  8008f5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8008fc:	eb 06                	jmp    800904 <strlen+0x15>
		n++;
  8008fe:	ff 45 fc             	incl   -0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800901:	ff 45 08             	incl   0x8(%ebp)
  800904:	8b 45 08             	mov    0x8(%ebp),%eax
  800907:	8a 00                	mov    (%eax),%al
  800909:	84 c0                	test   %al,%al
  80090b:	75 f1                	jne    8008fe <strlen+0xf>
		n++;
	return n;
  80090d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800910:	c9                   	leave  
  800911:	c3                   	ret    

00800912 <strnlen>:

int
strnlen(const char *s, uint32 size)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800918:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80091f:	eb 09                	jmp    80092a <strnlen+0x18>
		n++;
  800921:	ff 45 fc             	incl   -0x4(%ebp)
int
strnlen(const char *s, uint32 size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800924:	ff 45 08             	incl   0x8(%ebp)
  800927:	ff 4d 0c             	decl   0xc(%ebp)
  80092a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80092e:	74 09                	je     800939 <strnlen+0x27>
  800930:	8b 45 08             	mov    0x8(%ebp),%eax
  800933:	8a 00                	mov    (%eax),%al
  800935:	84 c0                	test   %al,%al
  800937:	75 e8                	jne    800921 <strnlen+0xf>
		n++;
	return n;
  800939:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80093c:	c9                   	leave  
  80093d:	c3                   	ret    

0080093e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800944:	8b 45 08             	mov    0x8(%ebp),%eax
  800947:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  80094a:	90                   	nop
  80094b:	8b 45 08             	mov    0x8(%ebp),%eax
  80094e:	8d 50 01             	lea    0x1(%eax),%edx
  800951:	89 55 08             	mov    %edx,0x8(%ebp)
  800954:	8b 55 0c             	mov    0xc(%ebp),%edx
  800957:	8d 4a 01             	lea    0x1(%edx),%ecx
  80095a:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  80095d:	8a 12                	mov    (%edx),%dl
  80095f:	88 10                	mov    %dl,(%eax)
  800961:	8a 00                	mov    (%eax),%al
  800963:	84 c0                	test   %al,%al
  800965:	75 e4                	jne    80094b <strcpy+0xd>
		/* do nothing */;
	return ret;
  800967:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80096a:	c9                   	leave  
  80096b:	c3                   	ret    

0080096c <strncpy>:

char *
strncpy(char *dst, const char *src, uint32 size) {
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	83 ec 10             	sub    $0x10,%esp
	uint32 i;
	char *ret;

	ret = dst;
  800972:	8b 45 08             	mov    0x8(%ebp),%eax
  800975:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800978:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80097f:	eb 1f                	jmp    8009a0 <strncpy+0x34>
		*dst++ = *src;
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	8d 50 01             	lea    0x1(%eax),%edx
  800987:	89 55 08             	mov    %edx,0x8(%ebp)
  80098a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098d:	8a 12                	mov    (%edx),%dl
  80098f:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800991:	8b 45 0c             	mov    0xc(%ebp),%eax
  800994:	8a 00                	mov    (%eax),%al
  800996:	84 c0                	test   %al,%al
  800998:	74 03                	je     80099d <strncpy+0x31>
			src++;
  80099a:	ff 45 0c             	incl   0xc(%ebp)
strncpy(char *dst, const char *src, uint32 size) {
	uint32 i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80099d:	ff 45 fc             	incl   -0x4(%ebp)
  8009a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8009a3:	3b 45 10             	cmp    0x10(%ebp),%eax
  8009a6:	72 d9                	jb     800981 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  8009a8:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  8009ab:	c9                   	leave  
  8009ac:	c3                   	ret    

008009ad <strlcpy>:

uint32
strlcpy(char *dst, const char *src, uint32 size)
{
  8009ad:	55                   	push   %ebp
  8009ae:	89 e5                	mov    %esp,%ebp
  8009b0:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  8009b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b6:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  8009b9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009bd:	74 30                	je     8009ef <strlcpy+0x42>
		while (--size > 0 && *src != '\0')
  8009bf:	eb 16                	jmp    8009d7 <strlcpy+0x2a>
			*dst++ = *src++;
  8009c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c4:	8d 50 01             	lea    0x1(%eax),%edx
  8009c7:	89 55 08             	mov    %edx,0x8(%ebp)
  8009ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009cd:	8d 4a 01             	lea    0x1(%edx),%ecx
  8009d0:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  8009d3:	8a 12                	mov    (%edx),%dl
  8009d5:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009d7:	ff 4d 10             	decl   0x10(%ebp)
  8009da:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009de:	74 09                	je     8009e9 <strlcpy+0x3c>
  8009e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e3:	8a 00                	mov    (%eax),%al
  8009e5:	84 c0                	test   %al,%al
  8009e7:	75 d8                	jne    8009c1 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  8009e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ec:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8009f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8009f5:	29 c2                	sub    %eax,%edx
  8009f7:	89 d0                	mov    %edx,%eax
}
  8009f9:	c9                   	leave  
  8009fa:	c3                   	ret    

008009fb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  8009fe:	eb 06                	jmp    800a06 <strcmp+0xb>
		p++, q++;
  800a00:	ff 45 08             	incl   0x8(%ebp)
  800a03:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a06:	8b 45 08             	mov    0x8(%ebp),%eax
  800a09:	8a 00                	mov    (%eax),%al
  800a0b:	84 c0                	test   %al,%al
  800a0d:	74 0e                	je     800a1d <strcmp+0x22>
  800a0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a12:	8a 10                	mov    (%eax),%dl
  800a14:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a17:	8a 00                	mov    (%eax),%al
  800a19:	38 c2                	cmp    %al,%dl
  800a1b:	74 e3                	je     800a00 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a20:	8a 00                	mov    (%eax),%al
  800a22:	0f b6 d0             	movzbl %al,%edx
  800a25:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a28:	8a 00                	mov    (%eax),%al
  800a2a:	0f b6 c0             	movzbl %al,%eax
  800a2d:	29 c2                	sub    %eax,%edx
  800a2f:	89 d0                	mov    %edx,%eax
}
  800a31:	5d                   	pop    %ebp
  800a32:	c3                   	ret    

00800a33 <strncmp>:

int
strncmp(const char *p, const char *q, uint32 n)
{
  800a33:	55                   	push   %ebp
  800a34:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800a36:	eb 09                	jmp    800a41 <strncmp+0xe>
		n--, p++, q++;
  800a38:	ff 4d 10             	decl   0x10(%ebp)
  800a3b:	ff 45 08             	incl   0x8(%ebp)
  800a3e:	ff 45 0c             	incl   0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint32 n)
{
	while (n > 0 && *p && *p == *q)
  800a41:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a45:	74 17                	je     800a5e <strncmp+0x2b>
  800a47:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4a:	8a 00                	mov    (%eax),%al
  800a4c:	84 c0                	test   %al,%al
  800a4e:	74 0e                	je     800a5e <strncmp+0x2b>
  800a50:	8b 45 08             	mov    0x8(%ebp),%eax
  800a53:	8a 10                	mov    (%eax),%dl
  800a55:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a58:	8a 00                	mov    (%eax),%al
  800a5a:	38 c2                	cmp    %al,%dl
  800a5c:	74 da                	je     800a38 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800a5e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a62:	75 07                	jne    800a6b <strncmp+0x38>
		return 0;
  800a64:	b8 00 00 00 00       	mov    $0x0,%eax
  800a69:	eb 14                	jmp    800a7f <strncmp+0x4c>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6e:	8a 00                	mov    (%eax),%al
  800a70:	0f b6 d0             	movzbl %al,%edx
  800a73:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a76:	8a 00                	mov    (%eax),%al
  800a78:	0f b6 c0             	movzbl %al,%eax
  800a7b:	29 c2                	sub    %eax,%edx
  800a7d:	89 d0                	mov    %edx,%eax
}
  800a7f:	5d                   	pop    %ebp
  800a80:	c3                   	ret    

00800a81 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a81:	55                   	push   %ebp
  800a82:	89 e5                	mov    %esp,%ebp
  800a84:	83 ec 04             	sub    $0x4,%esp
  800a87:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8a:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800a8d:	eb 12                	jmp    800aa1 <strchr+0x20>
		if (*s == c)
  800a8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a92:	8a 00                	mov    (%eax),%al
  800a94:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800a97:	75 05                	jne    800a9e <strchr+0x1d>
			return (char *) s;
  800a99:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9c:	eb 11                	jmp    800aaf <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a9e:	ff 45 08             	incl   0x8(%ebp)
  800aa1:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa4:	8a 00                	mov    (%eax),%al
  800aa6:	84 c0                	test   %al,%al
  800aa8:	75 e5                	jne    800a8f <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800aaa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aaf:	c9                   	leave  
  800ab0:	c3                   	ret    

00800ab1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	83 ec 04             	sub    $0x4,%esp
  800ab7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aba:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800abd:	eb 0d                	jmp    800acc <strfind+0x1b>
		if (*s == c)
  800abf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac2:	8a 00                	mov    (%eax),%al
  800ac4:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800ac7:	74 0e                	je     800ad7 <strfind+0x26>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ac9:	ff 45 08             	incl   0x8(%ebp)
  800acc:	8b 45 08             	mov    0x8(%ebp),%eax
  800acf:	8a 00                	mov    (%eax),%al
  800ad1:	84 c0                	test   %al,%al
  800ad3:	75 ea                	jne    800abf <strfind+0xe>
  800ad5:	eb 01                	jmp    800ad8 <strfind+0x27>
		if (*s == c)
			break;
  800ad7:	90                   	nop
	return (char *) s;
  800ad8:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800adb:	c9                   	leave  
  800adc:	c3                   	ret    

00800add <memset>:


void *
memset(void *v, int c, uint32 n)
{
  800add:	55                   	push   %ebp
  800ade:	89 e5                	mov    %esp,%ebp
  800ae0:	83 ec 10             	sub    $0x10,%esp
	char *p;
	int m;

	p = v;
  800ae3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae6:	89 45 fc             	mov    %eax,-0x4(%ebp)
	m = n;
  800ae9:	8b 45 10             	mov    0x10(%ebp),%eax
  800aec:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (--m >= 0)
  800aef:	eb 0e                	jmp    800aff <memset+0x22>
		*p++ = c;
  800af1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800af4:	8d 50 01             	lea    0x1(%eax),%edx
  800af7:	89 55 fc             	mov    %edx,-0x4(%ebp)
  800afa:	8b 55 0c             	mov    0xc(%ebp),%edx
  800afd:	88 10                	mov    %dl,(%eax)
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800aff:	ff 4d f8             	decl   -0x8(%ebp)
  800b02:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
  800b06:	79 e9                	jns    800af1 <memset+0x14>
		*p++ = c;

	return v;
  800b08:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b0b:	c9                   	leave  
  800b0c:	c3                   	ret    

00800b0d <memcpy>:

void *
memcpy(void *dst, const void *src, uint32 n)
{
  800b0d:	55                   	push   %ebp
  800b0e:	89 e5                	mov    %esp,%ebp
  800b10:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800b13:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b16:	89 45 fc             	mov    %eax,-0x4(%ebp)
	d = dst;
  800b19:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1c:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (n-- > 0)
  800b1f:	eb 16                	jmp    800b37 <memcpy+0x2a>
		*d++ = *s++;
  800b21:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800b24:	8d 50 01             	lea    0x1(%eax),%edx
  800b27:	89 55 f8             	mov    %edx,-0x8(%ebp)
  800b2a:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800b2d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800b30:	89 4d fc             	mov    %ecx,-0x4(%ebp)
  800b33:	8a 12                	mov    (%edx),%dl
  800b35:	88 10                	mov    %dl,(%eax)
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
  800b37:	8b 45 10             	mov    0x10(%ebp),%eax
  800b3a:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b3d:	89 55 10             	mov    %edx,0x10(%ebp)
  800b40:	85 c0                	test   %eax,%eax
  800b42:	75 dd                	jne    800b21 <memcpy+0x14>
		*d++ = *s++;

	return dst;
  800b44:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b47:	c9                   	leave  
  800b48:	c3                   	ret    

00800b49 <memmove>:

void *
memmove(void *dst, const void *src, uint32 n)
{
  800b49:	55                   	push   %ebp
  800b4a:	89 e5                	mov    %esp,%ebp
  800b4c:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800b4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b52:	89 45 fc             	mov    %eax,-0x4(%ebp)
	d = dst;
  800b55:	8b 45 08             	mov    0x8(%ebp),%eax
  800b58:	89 45 f8             	mov    %eax,-0x8(%ebp)
	if (s < d && s + n > d) {
  800b5b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800b5e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  800b61:	73 50                	jae    800bb3 <memmove+0x6a>
  800b63:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800b66:	8b 45 10             	mov    0x10(%ebp),%eax
  800b69:	01 d0                	add    %edx,%eax
  800b6b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  800b6e:	76 43                	jbe    800bb3 <memmove+0x6a>
		s += n;
  800b70:	8b 45 10             	mov    0x10(%ebp),%eax
  800b73:	01 45 fc             	add    %eax,-0x4(%ebp)
		d += n;
  800b76:	8b 45 10             	mov    0x10(%ebp),%eax
  800b79:	01 45 f8             	add    %eax,-0x8(%ebp)
		while (n-- > 0)
  800b7c:	eb 10                	jmp    800b8e <memmove+0x45>
			*--d = *--s;
  800b7e:	ff 4d f8             	decl   -0x8(%ebp)
  800b81:	ff 4d fc             	decl   -0x4(%ebp)
  800b84:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800b87:	8a 10                	mov    (%eax),%dl
  800b89:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800b8c:	88 10                	mov    %dl,(%eax)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  800b8e:	8b 45 10             	mov    0x10(%ebp),%eax
  800b91:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b94:	89 55 10             	mov    %edx,0x10(%ebp)
  800b97:	85 c0                	test   %eax,%eax
  800b99:	75 e3                	jne    800b7e <memmove+0x35>
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b9b:	eb 23                	jmp    800bc0 <memmove+0x77>
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  800b9d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800ba0:	8d 50 01             	lea    0x1(%eax),%edx
  800ba3:	89 55 f8             	mov    %edx,-0x8(%ebp)
  800ba6:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800ba9:	8d 4a 01             	lea    0x1(%edx),%ecx
  800bac:	89 4d fc             	mov    %ecx,-0x4(%ebp)
  800baf:	8a 12                	mov    (%edx),%dl
  800bb1:	88 10                	mov    %dl,(%eax)
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800bb3:	8b 45 10             	mov    0x10(%ebp),%eax
  800bb6:	8d 50 ff             	lea    -0x1(%eax),%edx
  800bb9:	89 55 10             	mov    %edx,0x10(%ebp)
  800bbc:	85 c0                	test   %eax,%eax
  800bbe:	75 dd                	jne    800b9d <memmove+0x54>
			*d++ = *s++;

	return dst;
  800bc0:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800bc3:	c9                   	leave  
  800bc4:	c3                   	ret    

00800bc5 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint32 n)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	83 ec 10             	sub    $0x10,%esp
	const uint8 *s1 = (const uint8 *) v1;
  800bcb:	8b 45 08             	mov    0x8(%ebp),%eax
  800bce:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8 *s2 = (const uint8 *) v2;
  800bd1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd4:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800bd7:	eb 2a                	jmp    800c03 <memcmp+0x3e>
		if (*s1 != *s2)
  800bd9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bdc:	8a 10                	mov    (%eax),%dl
  800bde:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800be1:	8a 00                	mov    (%eax),%al
  800be3:	38 c2                	cmp    %al,%dl
  800be5:	74 16                	je     800bfd <memcmp+0x38>
			return (int) *s1 - (int) *s2;
  800be7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bea:	8a 00                	mov    (%eax),%al
  800bec:	0f b6 d0             	movzbl %al,%edx
  800bef:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800bf2:	8a 00                	mov    (%eax),%al
  800bf4:	0f b6 c0             	movzbl %al,%eax
  800bf7:	29 c2                	sub    %eax,%edx
  800bf9:	89 d0                	mov    %edx,%eax
  800bfb:	eb 18                	jmp    800c15 <memcmp+0x50>
		s1++, s2++;
  800bfd:	ff 45 fc             	incl   -0x4(%ebp)
  800c00:	ff 45 f8             	incl   -0x8(%ebp)
memcmp(const void *v1, const void *v2, uint32 n)
{
	const uint8 *s1 = (const uint8 *) v1;
	const uint8 *s2 = (const uint8 *) v2;

	while (n-- > 0) {
  800c03:	8b 45 10             	mov    0x10(%ebp),%eax
  800c06:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c09:	89 55 10             	mov    %edx,0x10(%ebp)
  800c0c:	85 c0                	test   %eax,%eax
  800c0e:	75 c9                	jne    800bd9 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c10:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c15:	c9                   	leave  
  800c16:	c3                   	ret    

00800c17 <memfind>:

void *
memfind(const void *s, int c, uint32 n)
{
  800c17:	55                   	push   %ebp
  800c18:	89 e5                	mov    %esp,%ebp
  800c1a:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800c1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c20:	8b 45 10             	mov    0x10(%ebp),%eax
  800c23:	01 d0                	add    %edx,%eax
  800c25:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800c28:	eb 15                	jmp    800c3f <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2d:	8a 00                	mov    (%eax),%al
  800c2f:	0f b6 d0             	movzbl %al,%edx
  800c32:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c35:	0f b6 c0             	movzbl %al,%eax
  800c38:	39 c2                	cmp    %eax,%edx
  800c3a:	74 0d                	je     800c49 <memfind+0x32>

void *
memfind(const void *s, int c, uint32 n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c3c:	ff 45 08             	incl   0x8(%ebp)
  800c3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c42:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800c45:	72 e3                	jb     800c2a <memfind+0x13>
  800c47:	eb 01                	jmp    800c4a <memfind+0x33>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
  800c49:	90                   	nop
	return (void *) s;
  800c4a:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c4d:	c9                   	leave  
  800c4e:	c3                   	ret    

00800c4f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c4f:	55                   	push   %ebp
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800c55:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800c5c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c63:	eb 03                	jmp    800c68 <strtol+0x19>
		s++;
  800c65:	ff 45 08             	incl   0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c68:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6b:	8a 00                	mov    (%eax),%al
  800c6d:	3c 20                	cmp    $0x20,%al
  800c6f:	74 f4                	je     800c65 <strtol+0x16>
  800c71:	8b 45 08             	mov    0x8(%ebp),%eax
  800c74:	8a 00                	mov    (%eax),%al
  800c76:	3c 09                	cmp    $0x9,%al
  800c78:	74 eb                	je     800c65 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7d:	8a 00                	mov    (%eax),%al
  800c7f:	3c 2b                	cmp    $0x2b,%al
  800c81:	75 05                	jne    800c88 <strtol+0x39>
		s++;
  800c83:	ff 45 08             	incl   0x8(%ebp)
  800c86:	eb 13                	jmp    800c9b <strtol+0x4c>
	else if (*s == '-')
  800c88:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8b:	8a 00                	mov    (%eax),%al
  800c8d:	3c 2d                	cmp    $0x2d,%al
  800c8f:	75 0a                	jne    800c9b <strtol+0x4c>
		s++, neg = 1;
  800c91:	ff 45 08             	incl   0x8(%ebp)
  800c94:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c9b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c9f:	74 06                	je     800ca7 <strtol+0x58>
  800ca1:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800ca5:	75 20                	jne    800cc7 <strtol+0x78>
  800ca7:	8b 45 08             	mov    0x8(%ebp),%eax
  800caa:	8a 00                	mov    (%eax),%al
  800cac:	3c 30                	cmp    $0x30,%al
  800cae:	75 17                	jne    800cc7 <strtol+0x78>
  800cb0:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb3:	40                   	inc    %eax
  800cb4:	8a 00                	mov    (%eax),%al
  800cb6:	3c 78                	cmp    $0x78,%al
  800cb8:	75 0d                	jne    800cc7 <strtol+0x78>
		s += 2, base = 16;
  800cba:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800cbe:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800cc5:	eb 28                	jmp    800cef <strtol+0xa0>
	else if (base == 0 && s[0] == '0')
  800cc7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ccb:	75 15                	jne    800ce2 <strtol+0x93>
  800ccd:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd0:	8a 00                	mov    (%eax),%al
  800cd2:	3c 30                	cmp    $0x30,%al
  800cd4:	75 0c                	jne    800ce2 <strtol+0x93>
		s++, base = 8;
  800cd6:	ff 45 08             	incl   0x8(%ebp)
  800cd9:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800ce0:	eb 0d                	jmp    800cef <strtol+0xa0>
	else if (base == 0)
  800ce2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ce6:	75 07                	jne    800cef <strtol+0xa0>
		base = 10;
  800ce8:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cef:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf2:	8a 00                	mov    (%eax),%al
  800cf4:	3c 2f                	cmp    $0x2f,%al
  800cf6:	7e 19                	jle    800d11 <strtol+0xc2>
  800cf8:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfb:	8a 00                	mov    (%eax),%al
  800cfd:	3c 39                	cmp    $0x39,%al
  800cff:	7f 10                	jg     800d11 <strtol+0xc2>
			dig = *s - '0';
  800d01:	8b 45 08             	mov    0x8(%ebp),%eax
  800d04:	8a 00                	mov    (%eax),%al
  800d06:	0f be c0             	movsbl %al,%eax
  800d09:	83 e8 30             	sub    $0x30,%eax
  800d0c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d0f:	eb 42                	jmp    800d53 <strtol+0x104>
		else if (*s >= 'a' && *s <= 'z')
  800d11:	8b 45 08             	mov    0x8(%ebp),%eax
  800d14:	8a 00                	mov    (%eax),%al
  800d16:	3c 60                	cmp    $0x60,%al
  800d18:	7e 19                	jle    800d33 <strtol+0xe4>
  800d1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1d:	8a 00                	mov    (%eax),%al
  800d1f:	3c 7a                	cmp    $0x7a,%al
  800d21:	7f 10                	jg     800d33 <strtol+0xe4>
			dig = *s - 'a' + 10;
  800d23:	8b 45 08             	mov    0x8(%ebp),%eax
  800d26:	8a 00                	mov    (%eax),%al
  800d28:	0f be c0             	movsbl %al,%eax
  800d2b:	83 e8 57             	sub    $0x57,%eax
  800d2e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d31:	eb 20                	jmp    800d53 <strtol+0x104>
		else if (*s >= 'A' && *s <= 'Z')
  800d33:	8b 45 08             	mov    0x8(%ebp),%eax
  800d36:	8a 00                	mov    (%eax),%al
  800d38:	3c 40                	cmp    $0x40,%al
  800d3a:	7e 39                	jle    800d75 <strtol+0x126>
  800d3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3f:	8a 00                	mov    (%eax),%al
  800d41:	3c 5a                	cmp    $0x5a,%al
  800d43:	7f 30                	jg     800d75 <strtol+0x126>
			dig = *s - 'A' + 10;
  800d45:	8b 45 08             	mov    0x8(%ebp),%eax
  800d48:	8a 00                	mov    (%eax),%al
  800d4a:	0f be c0             	movsbl %al,%eax
  800d4d:	83 e8 37             	sub    $0x37,%eax
  800d50:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800d53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d56:	3b 45 10             	cmp    0x10(%ebp),%eax
  800d59:	7d 19                	jge    800d74 <strtol+0x125>
			break;
		s++, val = (val * base) + dig;
  800d5b:	ff 45 08             	incl   0x8(%ebp)
  800d5e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d61:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d65:	89 c2                	mov    %eax,%edx
  800d67:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d6a:	01 d0                	add    %edx,%eax
  800d6c:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800d6f:	e9 7b ff ff ff       	jmp    800cef <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
			break;
  800d74:	90                   	nop
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d75:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d79:	74 08                	je     800d83 <strtol+0x134>
		*endptr = (char *) s;
  800d7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d81:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800d83:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800d87:	74 07                	je     800d90 <strtol+0x141>
  800d89:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d8c:	f7 d8                	neg    %eax
  800d8e:	eb 03                	jmp    800d93 <strtol+0x144>
  800d90:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800d93:	c9                   	leave  
  800d94:	c3                   	ret    

00800d95 <ltostr>:

void
ltostr(long value, char *str)
{
  800d95:	55                   	push   %ebp
  800d96:	89 e5                	mov    %esp,%ebp
  800d98:	83 ec 20             	sub    $0x20,%esp
	int neg = 0;
  800d9b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	int s = 0 ;
  800da2:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// plus/minus sign
	if (value < 0)
  800da9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800dad:	79 13                	jns    800dc2 <ltostr+0x2d>
	{
		neg = 1;
  800daf:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
		str[0] = '-';
  800db6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800db9:	c6 00 2d             	movb   $0x2d,(%eax)
		value = value * -1 ;
  800dbc:	f7 5d 08             	negl   0x8(%ebp)
		s++ ;
  800dbf:	ff 45 f8             	incl   -0x8(%ebp)
	}
	do
	{
		int mod = value % 10 ;
  800dc2:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800dca:	99                   	cltd   
  800dcb:	f7 f9                	idiv   %ecx
  800dcd:	89 55 ec             	mov    %edx,-0x14(%ebp)
		str[s++] = mod + '0' ;
  800dd0:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800dd3:	8d 50 01             	lea    0x1(%eax),%edx
  800dd6:	89 55 f8             	mov    %edx,-0x8(%ebp)
  800dd9:	89 c2                	mov    %eax,%edx
  800ddb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dde:	01 d0                	add    %edx,%eax
  800de0:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800de3:	83 c2 30             	add    $0x30,%edx
  800de6:	88 10                	mov    %dl,(%eax)
		value = value / 10 ;
  800de8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800deb:	b8 67 66 66 66       	mov    $0x66666667,%eax
  800df0:	f7 e9                	imul   %ecx
  800df2:	c1 fa 02             	sar    $0x2,%edx
  800df5:	89 c8                	mov    %ecx,%eax
  800df7:	c1 f8 1f             	sar    $0x1f,%eax
  800dfa:	29 c2                	sub    %eax,%edx
  800dfc:	89 d0                	mov    %edx,%eax
  800dfe:	89 45 08             	mov    %eax,0x8(%ebp)
	} while (value % 10 != 0);
  800e01:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e04:	b8 67 66 66 66       	mov    $0x66666667,%eax
  800e09:	f7 e9                	imul   %ecx
  800e0b:	c1 fa 02             	sar    $0x2,%edx
  800e0e:	89 c8                	mov    %ecx,%eax
  800e10:	c1 f8 1f             	sar    $0x1f,%eax
  800e13:	29 c2                	sub    %eax,%edx
  800e15:	89 d0                	mov    %edx,%eax
  800e17:	c1 e0 02             	shl    $0x2,%eax
  800e1a:	01 d0                	add    %edx,%eax
  800e1c:	01 c0                	add    %eax,%eax
  800e1e:	29 c1                	sub    %eax,%ecx
  800e20:	89 ca                	mov    %ecx,%edx
  800e22:	85 d2                	test   %edx,%edx
  800e24:	75 9c                	jne    800dc2 <ltostr+0x2d>

	//reverse the string
	int start = 0 ;
  800e26:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	int end = s-1 ;
  800e2d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e30:	48                   	dec    %eax
  800e31:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (neg)
  800e34:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800e38:	74 3d                	je     800e77 <ltostr+0xe2>
		start = 1 ;
  800e3a:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	while(start<end)
  800e41:	eb 34                	jmp    800e77 <ltostr+0xe2>
	{
		char tmp = str[start] ;
  800e43:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e46:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e49:	01 d0                	add    %edx,%eax
  800e4b:	8a 00                	mov    (%eax),%al
  800e4d:	88 45 eb             	mov    %al,-0x15(%ebp)
		str[start] = str[end] ;
  800e50:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e53:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e56:	01 c2                	add    %eax,%edx
  800e58:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  800e5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e5e:	01 c8                	add    %ecx,%eax
  800e60:	8a 00                	mov    (%eax),%al
  800e62:	88 02                	mov    %al,(%edx)
		str[end] = tmp;
  800e64:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e67:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e6a:	01 c2                	add    %eax,%edx
  800e6c:	8a 45 eb             	mov    -0x15(%ebp),%al
  800e6f:	88 02                	mov    %al,(%edx)
		start++ ;
  800e71:	ff 45 f4             	incl   -0xc(%ebp)
		end-- ;
  800e74:	ff 4d f0             	decl   -0x10(%ebp)
	//reverse the string
	int start = 0 ;
	int end = s-1 ;
	if (neg)
		start = 1 ;
	while(start<end)
  800e77:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e7a:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800e7d:	7c c4                	jl     800e43 <ltostr+0xae>
		str[end] = tmp;
		start++ ;
		end-- ;
	}

	str[s] = 0 ;
  800e7f:	8b 55 f8             	mov    -0x8(%ebp),%edx
  800e82:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e85:	01 d0                	add    %edx,%eax
  800e87:	c6 00 00             	movb   $0x0,(%eax)
	// we don't properly detect overflow!

}
  800e8a:	90                   	nop
  800e8b:	c9                   	leave  
  800e8c:	c3                   	ret    

00800e8d <strcconcat>:

void
strcconcat(const char *str1, const char *str2, char *final)
{
  800e8d:	55                   	push   %ebp
  800e8e:	89 e5                	mov    %esp,%ebp
  800e90:	83 ec 10             	sub    $0x10,%esp
	int len1 = strlen(str1);
  800e93:	ff 75 08             	pushl  0x8(%ebp)
  800e96:	e8 54 fa ff ff       	call   8008ef <strlen>
  800e9b:	83 c4 04             	add    $0x4,%esp
  800e9e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	int len2 = strlen(str2);
  800ea1:	ff 75 0c             	pushl  0xc(%ebp)
  800ea4:	e8 46 fa ff ff       	call   8008ef <strlen>
  800ea9:	83 c4 04             	add    $0x4,%esp
  800eac:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int s = 0 ;
  800eaf:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	for (s=0 ; s < len1 ; s++)
  800eb6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800ebd:	eb 17                	jmp    800ed6 <strcconcat+0x49>
		final[s] = str1[s] ;
  800ebf:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800ec2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ec5:	01 c2                	add    %eax,%edx
  800ec7:	8b 4d fc             	mov    -0x4(%ebp),%ecx
  800eca:	8b 45 08             	mov    0x8(%ebp),%eax
  800ecd:	01 c8                	add    %ecx,%eax
  800ecf:	8a 00                	mov    (%eax),%al
  800ed1:	88 02                	mov    %al,(%edx)
strcconcat(const char *str1, const char *str2, char *final)
{
	int len1 = strlen(str1);
	int len2 = strlen(str2);
	int s = 0 ;
	for (s=0 ; s < len1 ; s++)
  800ed3:	ff 45 fc             	incl   -0x4(%ebp)
  800ed6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800ed9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  800edc:	7c e1                	jl     800ebf <strcconcat+0x32>
		final[s] = str1[s] ;

	int i = 0 ;
  800ede:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
	for (i=0 ; i < len2 ; i++)
  800ee5:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  800eec:	eb 1f                	jmp    800f0d <strcconcat+0x80>
		final[s++] = str2[i] ;
  800eee:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800ef1:	8d 50 01             	lea    0x1(%eax),%edx
  800ef4:	89 55 fc             	mov    %edx,-0x4(%ebp)
  800ef7:	89 c2                	mov    %eax,%edx
  800ef9:	8b 45 10             	mov    0x10(%ebp),%eax
  800efc:	01 c2                	add    %eax,%edx
  800efe:	8b 4d f8             	mov    -0x8(%ebp),%ecx
  800f01:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f04:	01 c8                	add    %ecx,%eax
  800f06:	8a 00                	mov    (%eax),%al
  800f08:	88 02                	mov    %al,(%edx)
	int s = 0 ;
	for (s=0 ; s < len1 ; s++)
		final[s] = str1[s] ;

	int i = 0 ;
	for (i=0 ; i < len2 ; i++)
  800f0a:	ff 45 f8             	incl   -0x8(%ebp)
  800f0d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800f10:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800f13:	7c d9                	jl     800eee <strcconcat+0x61>
		final[s++] = str2[i] ;

	final[s] = 0;
  800f15:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800f18:	8b 45 10             	mov    0x10(%ebp),%eax
  800f1b:	01 d0                	add    %edx,%eax
  800f1d:	c6 00 00             	movb   $0x0,(%eax)
}
  800f20:	90                   	nop
  800f21:	c9                   	leave  
  800f22:	c3                   	ret    

00800f23 <strsplit>:
int strsplit(char *string, char *SPLIT_CHARS, char **argv, int * argc)
{
  800f23:	55                   	push   %ebp
  800f24:	89 e5                	mov    %esp,%ebp
	// Parse the command string into splitchars-separated arguments
	*argc = 0;
  800f26:	8b 45 14             	mov    0x14(%ebp),%eax
  800f29:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	(argv)[*argc] = 0;
  800f2f:	8b 45 14             	mov    0x14(%ebp),%eax
  800f32:	8b 00                	mov    (%eax),%eax
  800f34:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800f3b:	8b 45 10             	mov    0x10(%ebp),%eax
  800f3e:	01 d0                	add    %edx,%eax
  800f40:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	while (1)
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
  800f46:	eb 0c                	jmp    800f54 <strsplit+0x31>
			*string++ = 0;
  800f48:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4b:	8d 50 01             	lea    0x1(%eax),%edx
  800f4e:	89 55 08             	mov    %edx,0x8(%ebp)
  800f51:	c6 00 00             	movb   $0x0,(%eax)
	*argc = 0;
	(argv)[*argc] = 0;
	while (1)
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
  800f54:	8b 45 08             	mov    0x8(%ebp),%eax
  800f57:	8a 00                	mov    (%eax),%al
  800f59:	84 c0                	test   %al,%al
  800f5b:	74 18                	je     800f75 <strsplit+0x52>
  800f5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f60:	8a 00                	mov    (%eax),%al
  800f62:	0f be c0             	movsbl %al,%eax
  800f65:	50                   	push   %eax
  800f66:	ff 75 0c             	pushl  0xc(%ebp)
  800f69:	e8 13 fb ff ff       	call   800a81 <strchr>
  800f6e:	83 c4 08             	add    $0x8,%esp
  800f71:	85 c0                	test   %eax,%eax
  800f73:	75 d3                	jne    800f48 <strsplit+0x25>
			*string++ = 0;

		//if the command string is finished, then break the loop
		if (*string == 0)
  800f75:	8b 45 08             	mov    0x8(%ebp),%eax
  800f78:	8a 00                	mov    (%eax),%al
  800f7a:	84 c0                	test   %al,%al
  800f7c:	74 5a                	je     800fd8 <strsplit+0xb5>
			break;

		//check current number of arguments
		if (*argc == MAX_ARGUMENTS-1)
  800f7e:	8b 45 14             	mov    0x14(%ebp),%eax
  800f81:	8b 00                	mov    (%eax),%eax
  800f83:	83 f8 0f             	cmp    $0xf,%eax
  800f86:	75 07                	jne    800f8f <strsplit+0x6c>
		{
			return 0;
  800f88:	b8 00 00 00 00       	mov    $0x0,%eax
  800f8d:	eb 66                	jmp    800ff5 <strsplit+0xd2>
		}

		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
  800f8f:	8b 45 14             	mov    0x14(%ebp),%eax
  800f92:	8b 00                	mov    (%eax),%eax
  800f94:	8d 48 01             	lea    0x1(%eax),%ecx
  800f97:	8b 55 14             	mov    0x14(%ebp),%edx
  800f9a:	89 0a                	mov    %ecx,(%edx)
  800f9c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800fa3:	8b 45 10             	mov    0x10(%ebp),%eax
  800fa6:	01 c2                	add    %eax,%edx
  800fa8:	8b 45 08             	mov    0x8(%ebp),%eax
  800fab:	89 02                	mov    %eax,(%edx)
		while (*string && !strchr(SPLIT_CHARS, *string))
  800fad:	eb 03                	jmp    800fb2 <strsplit+0x8f>
			string++;
  800faf:	ff 45 08             	incl   0x8(%ebp)
			return 0;
		}

		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
		while (*string && !strchr(SPLIT_CHARS, *string))
  800fb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb5:	8a 00                	mov    (%eax),%al
  800fb7:	84 c0                	test   %al,%al
  800fb9:	74 8b                	je     800f46 <strsplit+0x23>
  800fbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800fbe:	8a 00                	mov    (%eax),%al
  800fc0:	0f be c0             	movsbl %al,%eax
  800fc3:	50                   	push   %eax
  800fc4:	ff 75 0c             	pushl  0xc(%ebp)
  800fc7:	e8 b5 fa ff ff       	call   800a81 <strchr>
  800fcc:	83 c4 08             	add    $0x8,%esp
  800fcf:	85 c0                	test   %eax,%eax
  800fd1:	74 dc                	je     800faf <strsplit+0x8c>
			string++;
	}
  800fd3:	e9 6e ff ff ff       	jmp    800f46 <strsplit+0x23>
		while (*string && strchr(SPLIT_CHARS, *string))
			*string++ = 0;

		//if the command string is finished, then break the loop
		if (*string == 0)
			break;
  800fd8:	90                   	nop
		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
		while (*string && !strchr(SPLIT_CHARS, *string))
			string++;
	}
	(argv)[*argc] = 0;
  800fd9:	8b 45 14             	mov    0x14(%ebp),%eax
  800fdc:	8b 00                	mov    (%eax),%eax
  800fde:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800fe5:	8b 45 10             	mov    0x10(%ebp),%eax
  800fe8:	01 d0                	add    %edx,%eax
  800fea:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return 1 ;
  800ff0:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800ff5:	c9                   	leave  
  800ff6:	c3                   	ret    

00800ff7 <str2lower>:


/*2024*/
char* str2lower(char *dst, const char *src)
{
  800ff7:	55                   	push   %ebp
  800ff8:	89 e5                	mov    %esp,%ebp
  800ffa:	83 ec 20             	sub    $0x20,%esp
	//TODO: [PROJECT'23.MS1 - #1] [1] PLAY WITH CODE! - str2lower
	//Comment the following line before start coding...
	//panic("process_command is not implemented yet");
	long long size = strlen(src);
  800ffd:	ff 75 0c             	pushl  0xc(%ebp)
  801000:	e8 ea f8 ff ff       	call   8008ef <strlen>
  801005:	83 c4 04             	add    $0x4,%esp
  801008:	99                   	cltd   
  801009:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80100c:	89 55 f4             	mov    %edx,-0xc(%ebp)
	for(long long i=0;i<size;i++)
  80100f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  801016:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80101d:	eb 57                	jmp    801076 <str2lower+0x7f>
	{
		if(src[i] >=65 && src[i] <=90)
  80101f:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801022:	8b 45 0c             	mov    0xc(%ebp),%eax
  801025:	01 d0                	add    %edx,%eax
  801027:	8a 00                	mov    (%eax),%al
  801029:	3c 40                	cmp    $0x40,%al
  80102b:	7e 2d                	jle    80105a <str2lower+0x63>
  80102d:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801030:	8b 45 0c             	mov    0xc(%ebp),%eax
  801033:	01 d0                	add    %edx,%eax
  801035:	8a 00                	mov    (%eax),%al
  801037:	3c 5a                	cmp    $0x5a,%al
  801039:	7f 1f                	jg     80105a <str2lower+0x63>
		{
			char temp = src[i] + 32;
  80103b:	8b 55 f8             	mov    -0x8(%ebp),%edx
  80103e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801041:	01 d0                	add    %edx,%eax
  801043:	8a 00                	mov    (%eax),%al
  801045:	83 c0 20             	add    $0x20,%eax
  801048:	88 45 ef             	mov    %al,-0x11(%ebp)
			dst[i] = temp;
  80104b:	8b 55 f8             	mov    -0x8(%ebp),%edx
  80104e:	8b 45 08             	mov    0x8(%ebp),%eax
  801051:	01 c2                	add    %eax,%edx
  801053:	8a 45 ef             	mov    -0x11(%ebp),%al
  801056:	88 02                	mov    %al,(%edx)
	//panic("process_command is not implemented yet");
	long long size = strlen(src);
	for(long long i=0;i<size;i++)
	{
		if(src[i] >=65 && src[i] <=90)
		{
  801058:	eb 14                	jmp    80106e <str2lower+0x77>
			char temp = src[i] + 32;
			dst[i] = temp;
		}
		else
		{
			dst[i] = src[i];
  80105a:	8b 55 f8             	mov    -0x8(%ebp),%edx
  80105d:	8b 45 08             	mov    0x8(%ebp),%eax
  801060:	01 c2                	add    %eax,%edx
  801062:	8b 4d f8             	mov    -0x8(%ebp),%ecx
  801065:	8b 45 0c             	mov    0xc(%ebp),%eax
  801068:	01 c8                	add    %ecx,%eax
  80106a:	8a 00                	mov    (%eax),%al
  80106c:	88 02                	mov    %al,(%edx)
{
	//TODO: [PROJECT'23.MS1 - #1] [1] PLAY WITH CODE! - str2lower
	//Comment the following line before start coding...
	//panic("process_command is not implemented yet");
	long long size = strlen(src);
	for(long long i=0;i<size;i++)
  80106e:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  801072:	83 55 fc 00          	adcl   $0x0,-0x4(%ebp)
  801076:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801079:	8b 55 fc             	mov    -0x4(%ebp),%edx
  80107c:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  80107f:	7c 9e                	jl     80101f <str2lower+0x28>
  801081:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  801084:	7f 05                	jg     80108b <str2lower+0x94>
  801086:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  801089:	72 94                	jb     80101f <str2lower+0x28>
		else
		{
			dst[i] = src[i];
		}
	}
	return dst;
  80108b:	8b 45 08             	mov    0x8(%ebp),%eax
}
  80108e:	c9                   	leave  
  80108f:	c3                   	ret    

00801090 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline uint32
syscall(int num, uint32 a1, uint32 a2, uint32 a3, uint32 a4, uint32 a5)
{
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
  801093:	57                   	push   %edi
  801094:	56                   	push   %esi
  801095:	53                   	push   %ebx
  801096:	83 ec 10             	sub    $0x10,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801099:	8b 45 08             	mov    0x8(%ebp),%eax
  80109c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80109f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8010a2:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8010a5:	8b 7d 18             	mov    0x18(%ebp),%edi
  8010a8:	8b 75 1c             	mov    0x1c(%ebp),%esi
  8010ab:	cd 30                	int    $0x30
  8010ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	return ret;
  8010b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  8010b3:	83 c4 10             	add    $0x10,%esp
  8010b6:	5b                   	pop    %ebx
  8010b7:	5e                   	pop    %esi
  8010b8:	5f                   	pop    %edi
  8010b9:	5d                   	pop    %ebp
  8010ba:	c3                   	ret    

008010bb <sys_cputs>:

void
sys_cputs(const char *s, uint32 len, uint8 printProgName)
{
  8010bb:	55                   	push   %ebp
  8010bc:	89 e5                	mov    %esp,%ebp
  8010be:	83 ec 04             	sub    $0x4,%esp
  8010c1:	8b 45 10             	mov    0x10(%ebp),%eax
  8010c4:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_cputs, (uint32) s, len, (uint32)printProgName, 0, 0);
  8010c7:	0f b6 55 fc          	movzbl -0x4(%ebp),%edx
  8010cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ce:	6a 00                	push   $0x0
  8010d0:	6a 00                	push   $0x0
  8010d2:	52                   	push   %edx
  8010d3:	ff 75 0c             	pushl  0xc(%ebp)
  8010d6:	50                   	push   %eax
  8010d7:	6a 00                	push   $0x0
  8010d9:	e8 b2 ff ff ff       	call   801090 <syscall>
  8010de:	83 c4 18             	add    $0x18,%esp
}
  8010e1:	90                   	nop
  8010e2:	c9                   	leave  
  8010e3:	c3                   	ret    

008010e4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8010e4:	55                   	push   %ebp
  8010e5:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0);
  8010e7:	6a 00                	push   $0x0
  8010e9:	6a 00                	push   $0x0
  8010eb:	6a 00                	push   $0x0
  8010ed:	6a 00                	push   $0x0
  8010ef:	6a 00                	push   $0x0
  8010f1:	6a 01                	push   $0x1
  8010f3:	e8 98 ff ff ff       	call   801090 <syscall>
  8010f8:	83 c4 18             	add    $0x18,%esp
}
  8010fb:	c9                   	leave  
  8010fc:	c3                   	ret    

008010fd <__sys_allocate_page>:

int __sys_allocate_page(void *va, int perm)
{
  8010fd:	55                   	push   %ebp
  8010fe:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_allocate_page, (uint32) va, perm, 0 , 0, 0);
  801100:	8b 55 0c             	mov    0xc(%ebp),%edx
  801103:	8b 45 08             	mov    0x8(%ebp),%eax
  801106:	6a 00                	push   $0x0
  801108:	6a 00                	push   $0x0
  80110a:	6a 00                	push   $0x0
  80110c:	52                   	push   %edx
  80110d:	50                   	push   %eax
  80110e:	6a 05                	push   $0x5
  801110:	e8 7b ff ff ff       	call   801090 <syscall>
  801115:	83 c4 18             	add    $0x18,%esp
}
  801118:	c9                   	leave  
  801119:	c3                   	ret    

0080111a <__sys_map_frame>:

int __sys_map_frame(int32 srcenv, void *srcva, int32 dstenv, void *dstva, int perm)
{
  80111a:	55                   	push   %ebp
  80111b:	89 e5                	mov    %esp,%ebp
  80111d:	56                   	push   %esi
  80111e:	53                   	push   %ebx
	return syscall(SYS_map_frame, srcenv, (uint32) srcva, dstenv, (uint32) dstva, perm);
  80111f:	8b 75 18             	mov    0x18(%ebp),%esi
  801122:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801125:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801128:	8b 55 0c             	mov    0xc(%ebp),%edx
  80112b:	8b 45 08             	mov    0x8(%ebp),%eax
  80112e:	56                   	push   %esi
  80112f:	53                   	push   %ebx
  801130:	51                   	push   %ecx
  801131:	52                   	push   %edx
  801132:	50                   	push   %eax
  801133:	6a 06                	push   $0x6
  801135:	e8 56 ff ff ff       	call   801090 <syscall>
  80113a:	83 c4 18             	add    $0x18,%esp
}
  80113d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801140:	5b                   	pop    %ebx
  801141:	5e                   	pop    %esi
  801142:	5d                   	pop    %ebp
  801143:	c3                   	ret    

00801144 <__sys_unmap_frame>:

int __sys_unmap_frame(int32 envid, void *va)
{
  801144:	55                   	push   %ebp
  801145:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_unmap_frame, envid, (uint32) va, 0, 0, 0);
  801147:	8b 55 0c             	mov    0xc(%ebp),%edx
  80114a:	8b 45 08             	mov    0x8(%ebp),%eax
  80114d:	6a 00                	push   $0x0
  80114f:	6a 00                	push   $0x0
  801151:	6a 00                	push   $0x0
  801153:	52                   	push   %edx
  801154:	50                   	push   %eax
  801155:	6a 07                	push   $0x7
  801157:	e8 34 ff ff ff       	call   801090 <syscall>
  80115c:	83 c4 18             	add    $0x18,%esp
}
  80115f:	c9                   	leave  
  801160:	c3                   	ret    

00801161 <sys_calculate_required_frames>:

uint32 sys_calculate_required_frames(uint32 start_virtual_address, uint32 size)
{
  801161:	55                   	push   %ebp
  801162:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_req_frames, start_virtual_address, (uint32) size, 0, 0, 0);
  801164:	6a 00                	push   $0x0
  801166:	6a 00                	push   $0x0
  801168:	6a 00                	push   $0x0
  80116a:	ff 75 0c             	pushl  0xc(%ebp)
  80116d:	ff 75 08             	pushl  0x8(%ebp)
  801170:	6a 08                	push   $0x8
  801172:	e8 19 ff ff ff       	call   801090 <syscall>
  801177:	83 c4 18             	add    $0x18,%esp
}
  80117a:	c9                   	leave  
  80117b:	c3                   	ret    

0080117c <sys_calculate_free_frames>:

uint32 sys_calculate_free_frames()
{
  80117c:	55                   	push   %ebp
  80117d:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_free_frames, 0, 0, 0, 0, 0);
  80117f:	6a 00                	push   $0x0
  801181:	6a 00                	push   $0x0
  801183:	6a 00                	push   $0x0
  801185:	6a 00                	push   $0x0
  801187:	6a 00                	push   $0x0
  801189:	6a 09                	push   $0x9
  80118b:	e8 00 ff ff ff       	call   801090 <syscall>
  801190:	83 c4 18             	add    $0x18,%esp
}
  801193:	c9                   	leave  
  801194:	c3                   	ret    

00801195 <sys_calculate_modified_frames>:
uint32 sys_calculate_modified_frames()
{
  801195:	55                   	push   %ebp
  801196:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_modified_frames, 0, 0, 0, 0, 0);
  801198:	6a 00                	push   $0x0
  80119a:	6a 00                	push   $0x0
  80119c:	6a 00                	push   $0x0
  80119e:	6a 00                	push   $0x0
  8011a0:	6a 00                	push   $0x0
  8011a2:	6a 0a                	push   $0xa
  8011a4:	e8 e7 fe ff ff       	call   801090 <syscall>
  8011a9:	83 c4 18             	add    $0x18,%esp
}
  8011ac:	c9                   	leave  
  8011ad:	c3                   	ret    

008011ae <sys_calculate_notmod_frames>:

uint32 sys_calculate_notmod_frames()
{
  8011ae:	55                   	push   %ebp
  8011af:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_notmod_frames, 0, 0, 0, 0, 0);
  8011b1:	6a 00                	push   $0x0
  8011b3:	6a 00                	push   $0x0
  8011b5:	6a 00                	push   $0x0
  8011b7:	6a 00                	push   $0x0
  8011b9:	6a 00                	push   $0x0
  8011bb:	6a 0b                	push   $0xb
  8011bd:	e8 ce fe ff ff       	call   801090 <syscall>
  8011c2:	83 c4 18             	add    $0x18,%esp
}
  8011c5:	c9                   	leave  
  8011c6:	c3                   	ret    

008011c7 <sys_pf_calculate_allocated_pages>:



int sys_pf_calculate_allocated_pages()
{
  8011c7:	55                   	push   %ebp
  8011c8:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_pf_calc_allocated_pages, 0,0,0,0,0);
  8011ca:	6a 00                	push   $0x0
  8011cc:	6a 00                	push   $0x0
  8011ce:	6a 00                	push   $0x0
  8011d0:	6a 00                	push   $0x0
  8011d2:	6a 00                	push   $0x0
  8011d4:	6a 0c                	push   $0xc
  8011d6:	e8 b5 fe ff ff       	call   801090 <syscall>
  8011db:	83 c4 18             	add    $0x18,%esp
}
  8011de:	c9                   	leave  
  8011df:	c3                   	ret    

008011e0 <sys_calculate_pages_tobe_removed_ready_exit>:

int sys_calculate_pages_tobe_removed_ready_exit(uint32 WS_or_MEMORY_flag)
{
  8011e0:	55                   	push   %ebp
  8011e1:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calculate_pages_tobe_removed_ready_exit, WS_or_MEMORY_flag,0,0,0,0);
  8011e3:	6a 00                	push   $0x0
  8011e5:	6a 00                	push   $0x0
  8011e7:	6a 00                	push   $0x0
  8011e9:	6a 00                	push   $0x0
  8011eb:	ff 75 08             	pushl  0x8(%ebp)
  8011ee:	6a 0d                	push   $0xd
  8011f0:	e8 9b fe ff ff       	call   801090 <syscall>
  8011f5:	83 c4 18             	add    $0x18,%esp
}
  8011f8:	c9                   	leave  
  8011f9:	c3                   	ret    

008011fa <sys_scarce_memory>:

void sys_scarce_memory()
{
  8011fa:	55                   	push   %ebp
  8011fb:	89 e5                	mov    %esp,%ebp
	syscall(SYS_scarce_memory,0,0,0,0,0);
  8011fd:	6a 00                	push   $0x0
  8011ff:	6a 00                	push   $0x0
  801201:	6a 00                	push   $0x0
  801203:	6a 00                	push   $0x0
  801205:	6a 00                	push   $0x0
  801207:	6a 0e                	push   $0xe
  801209:	e8 82 fe ff ff       	call   801090 <syscall>
  80120e:	83 c4 18             	add    $0x18,%esp
}
  801211:	90                   	nop
  801212:	c9                   	leave  
  801213:	c3                   	ret    

00801214 <sys_disable_interrupt>:

//NEW !! 2012...
void
sys_disable_interrupt()
{
  801214:	55                   	push   %ebp
  801215:	89 e5                	mov    %esp,%ebp
	syscall(SYS_disableINTR,0, 0, 0, 0, 0);
  801217:	6a 00                	push   $0x0
  801219:	6a 00                	push   $0x0
  80121b:	6a 00                	push   $0x0
  80121d:	6a 00                	push   $0x0
  80121f:	6a 00                	push   $0x0
  801221:	6a 11                	push   $0x11
  801223:	e8 68 fe ff ff       	call   801090 <syscall>
  801228:	83 c4 18             	add    $0x18,%esp
}
  80122b:	90                   	nop
  80122c:	c9                   	leave  
  80122d:	c3                   	ret    

0080122e <sys_enable_interrupt>:


void
sys_enable_interrupt()
{
  80122e:	55                   	push   %ebp
  80122f:	89 e5                	mov    %esp,%ebp
	syscall(SYS_enableINTR,0, 0, 0, 0, 0);
  801231:	6a 00                	push   $0x0
  801233:	6a 00                	push   $0x0
  801235:	6a 00                	push   $0x0
  801237:	6a 00                	push   $0x0
  801239:	6a 00                	push   $0x0
  80123b:	6a 12                	push   $0x12
  80123d:	e8 4e fe ff ff       	call   801090 <syscall>
  801242:	83 c4 18             	add    $0x18,%esp
}
  801245:	90                   	nop
  801246:	c9                   	leave  
  801247:	c3                   	ret    

00801248 <sys_cputc>:


void
sys_cputc(const char c)
{
  801248:	55                   	push   %ebp
  801249:	89 e5                	mov    %esp,%ebp
  80124b:	83 ec 04             	sub    $0x4,%esp
  80124e:	8b 45 08             	mov    0x8(%ebp),%eax
  801251:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_cputc, (uint32) c, 0, 0, 0, 0);
  801254:	0f be 45 fc          	movsbl -0x4(%ebp),%eax
  801258:	6a 00                	push   $0x0
  80125a:	6a 00                	push   $0x0
  80125c:	6a 00                	push   $0x0
  80125e:	6a 00                	push   $0x0
  801260:	50                   	push   %eax
  801261:	6a 13                	push   $0x13
  801263:	e8 28 fe ff ff       	call   801090 <syscall>
  801268:	83 c4 18             	add    $0x18,%esp
}
  80126b:	90                   	nop
  80126c:	c9                   	leave  
  80126d:	c3                   	ret    

0080126e <sys_clear_ffl>:


//NEW'12: BONUS2 Testing
void
sys_clear_ffl()
{
  80126e:	55                   	push   %ebp
  80126f:	89 e5                	mov    %esp,%ebp
	syscall(SYS_clearFFL,0, 0, 0, 0, 0);
  801271:	6a 00                	push   $0x0
  801273:	6a 00                	push   $0x0
  801275:	6a 00                	push   $0x0
  801277:	6a 00                	push   $0x0
  801279:	6a 00                	push   $0x0
  80127b:	6a 14                	push   $0x14
  80127d:	e8 0e fe ff ff       	call   801090 <syscall>
  801282:	83 c4 18             	add    $0x18,%esp
}
  801285:	90                   	nop
  801286:	c9                   	leave  
  801287:	c3                   	ret    

00801288 <sys_createSemaphore>:

int
sys_createSemaphore(char* semaphoreName, uint32 initialValue)
{
  801288:	55                   	push   %ebp
  801289:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_create_semaphore,(uint32)semaphoreName, (uint32)initialValue, 0, 0, 0);
  80128b:	8b 45 08             	mov    0x8(%ebp),%eax
  80128e:	6a 00                	push   $0x0
  801290:	6a 00                	push   $0x0
  801292:	6a 00                	push   $0x0
  801294:	ff 75 0c             	pushl  0xc(%ebp)
  801297:	50                   	push   %eax
  801298:	6a 15                	push   $0x15
  80129a:	e8 f1 fd ff ff       	call   801090 <syscall>
  80129f:	83 c4 18             	add    $0x18,%esp
}
  8012a2:	c9                   	leave  
  8012a3:	c3                   	ret    

008012a4 <sys_getSemaphoreValue>:

int
sys_getSemaphoreValue(int32 ownerEnvID, char* semaphoreName)
{
  8012a4:	55                   	push   %ebp
  8012a5:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_get_semaphore_value,(uint32) ownerEnvID, (uint32)semaphoreName, 0, 0, 0);
  8012a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ad:	6a 00                	push   $0x0
  8012af:	6a 00                	push   $0x0
  8012b1:	6a 00                	push   $0x0
  8012b3:	52                   	push   %edx
  8012b4:	50                   	push   %eax
  8012b5:	6a 18                	push   $0x18
  8012b7:	e8 d4 fd ff ff       	call   801090 <syscall>
  8012bc:	83 c4 18             	add    $0x18,%esp
}
  8012bf:	c9                   	leave  
  8012c0:	c3                   	ret    

008012c1 <sys_waitSemaphore>:

void
sys_waitSemaphore(int32 ownerEnvID, char* semaphoreName)
{
  8012c1:	55                   	push   %ebp
  8012c2:	89 e5                	mov    %esp,%ebp
	syscall(SYS_wait_semaphore,(uint32) ownerEnvID, (uint32)semaphoreName, 0, 0, 0);
  8012c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ca:	6a 00                	push   $0x0
  8012cc:	6a 00                	push   $0x0
  8012ce:	6a 00                	push   $0x0
  8012d0:	52                   	push   %edx
  8012d1:	50                   	push   %eax
  8012d2:	6a 16                	push   $0x16
  8012d4:	e8 b7 fd ff ff       	call   801090 <syscall>
  8012d9:	83 c4 18             	add    $0x18,%esp
}
  8012dc:	90                   	nop
  8012dd:	c9                   	leave  
  8012de:	c3                   	ret    

008012df <sys_signalSemaphore>:

void
sys_signalSemaphore(int32 ownerEnvID, char* semaphoreName)
{
  8012df:	55                   	push   %ebp
  8012e0:	89 e5                	mov    %esp,%ebp
	syscall(SYS_signal_semaphore,(uint32) ownerEnvID, (uint32)semaphoreName, 0, 0, 0);
  8012e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8012e8:	6a 00                	push   $0x0
  8012ea:	6a 00                	push   $0x0
  8012ec:	6a 00                	push   $0x0
  8012ee:	52                   	push   %edx
  8012ef:	50                   	push   %eax
  8012f0:	6a 17                	push   $0x17
  8012f2:	e8 99 fd ff ff       	call   801090 <syscall>
  8012f7:	83 c4 18             	add    $0x18,%esp
}
  8012fa:	90                   	nop
  8012fb:	c9                   	leave  
  8012fc:	c3                   	ret    

008012fd <sys_createSharedObject>:

int
sys_createSharedObject(char* shareName, uint32 size, uint8 isWritable, void* virtual_address)
{
  8012fd:	55                   	push   %ebp
  8012fe:	89 e5                	mov    %esp,%ebp
  801300:	83 ec 04             	sub    $0x4,%esp
  801303:	8b 45 10             	mov    0x10(%ebp),%eax
  801306:	88 45 fc             	mov    %al,-0x4(%ebp)
	return syscall(SYS_create_shared_object,(uint32)shareName, (uint32)size, isWritable, (uint32)virtual_address,  0);
  801309:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80130c:	0f b6 55 fc          	movzbl -0x4(%ebp),%edx
  801310:	8b 45 08             	mov    0x8(%ebp),%eax
  801313:	6a 00                	push   $0x0
  801315:	51                   	push   %ecx
  801316:	52                   	push   %edx
  801317:	ff 75 0c             	pushl  0xc(%ebp)
  80131a:	50                   	push   %eax
  80131b:	6a 19                	push   $0x19
  80131d:	e8 6e fd ff ff       	call   801090 <syscall>
  801322:	83 c4 18             	add    $0x18,%esp
}
  801325:	c9                   	leave  
  801326:	c3                   	ret    

00801327 <sys_getSizeOfSharedObject>:

//2017:
int
sys_getSizeOfSharedObject(int32 ownerID, char* shareName)
{
  801327:	55                   	push   %ebp
  801328:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_get_size_of_shared_object,(uint32) ownerID, (uint32)shareName, 0, 0, 0);
  80132a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80132d:	8b 45 08             	mov    0x8(%ebp),%eax
  801330:	6a 00                	push   $0x0
  801332:	6a 00                	push   $0x0
  801334:	6a 00                	push   $0x0
  801336:	52                   	push   %edx
  801337:	50                   	push   %eax
  801338:	6a 1a                	push   $0x1a
  80133a:	e8 51 fd ff ff       	call   801090 <syscall>
  80133f:	83 c4 18             	add    $0x18,%esp
}
  801342:	c9                   	leave  
  801343:	c3                   	ret    

00801344 <sys_getSharedObject>:
//==========

int
sys_getSharedObject(int32 ownerID, char* shareName, void* virtual_address)
{
  801344:	55                   	push   %ebp
  801345:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_get_shared_object,(uint32) ownerID, (uint32)shareName, (uint32)virtual_address, 0, 0);
  801347:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80134a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80134d:	8b 45 08             	mov    0x8(%ebp),%eax
  801350:	6a 00                	push   $0x0
  801352:	6a 00                	push   $0x0
  801354:	51                   	push   %ecx
  801355:	52                   	push   %edx
  801356:	50                   	push   %eax
  801357:	6a 1b                	push   $0x1b
  801359:	e8 32 fd ff ff       	call   801090 <syscall>
  80135e:	83 c4 18             	add    $0x18,%esp
}
  801361:	c9                   	leave  
  801362:	c3                   	ret    

00801363 <sys_freeSharedObject>:

int
sys_freeSharedObject(int32 sharedObjectID, void *startVA)
{
  801363:	55                   	push   %ebp
  801364:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_free_shared_object,(uint32) sharedObjectID, (uint32) startVA, 0, 0, 0);
  801366:	8b 55 0c             	mov    0xc(%ebp),%edx
  801369:	8b 45 08             	mov    0x8(%ebp),%eax
  80136c:	6a 00                	push   $0x0
  80136e:	6a 00                	push   $0x0
  801370:	6a 00                	push   $0x0
  801372:	52                   	push   %edx
  801373:	50                   	push   %eax
  801374:	6a 1c                	push   $0x1c
  801376:	e8 15 fd ff ff       	call   801090 <syscall>
  80137b:	83 c4 18             	add    $0x18,%esp
}
  80137e:	c9                   	leave  
  80137f:	c3                   	ret    

00801380 <sys_getMaxShares>:

uint32 	sys_getMaxShares()
{
  801380:	55                   	push   %ebp
  801381:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_get_max_shares,0, 0, 0, 0, 0);
  801383:	6a 00                	push   $0x0
  801385:	6a 00                	push   $0x0
  801387:	6a 00                	push   $0x0
  801389:	6a 00                	push   $0x0
  80138b:	6a 00                	push   $0x0
  80138d:	6a 1d                	push   $0x1d
  80138f:	e8 fc fc ff ff       	call   801090 <syscall>
  801394:	83 c4 18             	add    $0x18,%esp
}
  801397:	c9                   	leave  
  801398:	c3                   	ret    

00801399 <sys_create_env>:

int sys_create_env(char* programName, unsigned int page_WS_size,unsigned int LRU_second_list_size,unsigned int percent_WS_pages_to_remove)
{
  801399:	55                   	push   %ebp
  80139a:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_create_env,(uint32)programName, (uint32)page_WS_size,(uint32)LRU_second_list_size, (uint32)percent_WS_pages_to_remove, 0);
  80139c:	8b 45 08             	mov    0x8(%ebp),%eax
  80139f:	6a 00                	push   $0x0
  8013a1:	ff 75 14             	pushl  0x14(%ebp)
  8013a4:	ff 75 10             	pushl  0x10(%ebp)
  8013a7:	ff 75 0c             	pushl  0xc(%ebp)
  8013aa:	50                   	push   %eax
  8013ab:	6a 1e                	push   $0x1e
  8013ad:	e8 de fc ff ff       	call   801090 <syscall>
  8013b2:	83 c4 18             	add    $0x18,%esp
}
  8013b5:	c9                   	leave  
  8013b6:	c3                   	ret    

008013b7 <sys_run_env>:

void
sys_run_env(int32 envId)
{
  8013b7:	55                   	push   %ebp
  8013b8:	89 e5                	mov    %esp,%ebp
	syscall(SYS_run_env, (int32)envId, 0, 0, 0, 0);
  8013ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8013bd:	6a 00                	push   $0x0
  8013bf:	6a 00                	push   $0x0
  8013c1:	6a 00                	push   $0x0
  8013c3:	6a 00                	push   $0x0
  8013c5:	50                   	push   %eax
  8013c6:	6a 1f                	push   $0x1f
  8013c8:	e8 c3 fc ff ff       	call   801090 <syscall>
  8013cd:	83 c4 18             	add    $0x18,%esp
}
  8013d0:	90                   	nop
  8013d1:	c9                   	leave  
  8013d2:	c3                   	ret    

008013d3 <sys_destroy_env>:

int sys_destroy_env(int32  envid)
{
  8013d3:	55                   	push   %ebp
  8013d4:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_destroy_env, envid, 0, 0, 0, 0);
  8013d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d9:	6a 00                	push   $0x0
  8013db:	6a 00                	push   $0x0
  8013dd:	6a 00                	push   $0x0
  8013df:	6a 00                	push   $0x0
  8013e1:	50                   	push   %eax
  8013e2:	6a 20                	push   $0x20
  8013e4:	e8 a7 fc ff ff       	call   801090 <syscall>
  8013e9:	83 c4 18             	add    $0x18,%esp
}
  8013ec:	c9                   	leave  
  8013ed:	c3                   	ret    

008013ee <sys_getenvid>:

int32 sys_getenvid(void)
{
  8013ee:	55                   	push   %ebp
  8013ef:	89 e5                	mov    %esp,%ebp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0);
  8013f1:	6a 00                	push   $0x0
  8013f3:	6a 00                	push   $0x0
  8013f5:	6a 00                	push   $0x0
  8013f7:	6a 00                	push   $0x0
  8013f9:	6a 00                	push   $0x0
  8013fb:	6a 02                	push   $0x2
  8013fd:	e8 8e fc ff ff       	call   801090 <syscall>
  801402:	83 c4 18             	add    $0x18,%esp
}
  801405:	c9                   	leave  
  801406:	c3                   	ret    

00801407 <sys_getenvindex>:

//2017
int32 sys_getenvindex(void)
{
  801407:	55                   	push   %ebp
  801408:	89 e5                	mov    %esp,%ebp
	 return syscall(SYS_getenvindex, 0, 0, 0, 0, 0);
  80140a:	6a 00                	push   $0x0
  80140c:	6a 00                	push   $0x0
  80140e:	6a 00                	push   $0x0
  801410:	6a 00                	push   $0x0
  801412:	6a 00                	push   $0x0
  801414:	6a 03                	push   $0x3
  801416:	e8 75 fc ff ff       	call   801090 <syscall>
  80141b:	83 c4 18             	add    $0x18,%esp
}
  80141e:	c9                   	leave  
  80141f:	c3                   	ret    

00801420 <sys_getparentenvid>:

int32 sys_getparentenvid(void)
{
  801420:	55                   	push   %ebp
  801421:	89 e5                	mov    %esp,%ebp
	 return syscall(SYS_getparentenvid, 0, 0, 0, 0, 0);
  801423:	6a 00                	push   $0x0
  801425:	6a 00                	push   $0x0
  801427:	6a 00                	push   $0x0
  801429:	6a 00                	push   $0x0
  80142b:	6a 00                	push   $0x0
  80142d:	6a 04                	push   $0x4
  80142f:	e8 5c fc ff ff       	call   801090 <syscall>
  801434:	83 c4 18             	add    $0x18,%esp
}
  801437:	c9                   	leave  
  801438:	c3                   	ret    

00801439 <sys_exit_env>:


void sys_exit_env(void)
{
  801439:	55                   	push   %ebp
  80143a:	89 e5                	mov    %esp,%ebp
	syscall(SYS_exit_env, 0, 0, 0, 0, 0);
  80143c:	6a 00                	push   $0x0
  80143e:	6a 00                	push   $0x0
  801440:	6a 00                	push   $0x0
  801442:	6a 00                	push   $0x0
  801444:	6a 00                	push   $0x0
  801446:	6a 21                	push   $0x21
  801448:	e8 43 fc ff ff       	call   801090 <syscall>
  80144d:	83 c4 18             	add    $0x18,%esp
}
  801450:	90                   	nop
  801451:	c9                   	leave  
  801452:	c3                   	ret    

00801453 <sys_get_virtual_time>:


struct uint64
sys_get_virtual_time()
{
  801453:	55                   	push   %ebp
  801454:	89 e5                	mov    %esp,%ebp
  801456:	83 ec 10             	sub    $0x10,%esp
	struct uint64 result;
	syscall(SYS_get_virtual_time, (uint32)&(result.low), (uint32)&(result.hi), 0, 0, 0);
  801459:	8d 45 f8             	lea    -0x8(%ebp),%eax
  80145c:	8d 50 04             	lea    0x4(%eax),%edx
  80145f:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801462:	6a 00                	push   $0x0
  801464:	6a 00                	push   $0x0
  801466:	6a 00                	push   $0x0
  801468:	52                   	push   %edx
  801469:	50                   	push   %eax
  80146a:	6a 22                	push   $0x22
  80146c:	e8 1f fc ff ff       	call   801090 <syscall>
  801471:	83 c4 18             	add    $0x18,%esp
	return result;
  801474:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801477:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80147a:	8b 55 fc             	mov    -0x4(%ebp),%edx
  80147d:	89 01                	mov    %eax,(%ecx)
  80147f:	89 51 04             	mov    %edx,0x4(%ecx)
}
  801482:	8b 45 08             	mov    0x8(%ebp),%eax
  801485:	c9                   	leave  
  801486:	c2 04 00             	ret    $0x4

00801489 <sys_move_user_mem>:

// 2014
void sys_move_user_mem(uint32 src_virtual_address, uint32 dst_virtual_address, uint32 size)
{
  801489:	55                   	push   %ebp
  80148a:	89 e5                	mov    %esp,%ebp
	syscall(SYS_move_user_mem, src_virtual_address, dst_virtual_address, size, 0, 0);
  80148c:	6a 00                	push   $0x0
  80148e:	6a 00                	push   $0x0
  801490:	ff 75 10             	pushl  0x10(%ebp)
  801493:	ff 75 0c             	pushl  0xc(%ebp)
  801496:	ff 75 08             	pushl  0x8(%ebp)
  801499:	6a 10                	push   $0x10
  80149b:	e8 f0 fb ff ff       	call   801090 <syscall>
  8014a0:	83 c4 18             	add    $0x18,%esp
	return ;
  8014a3:	90                   	nop
}
  8014a4:	c9                   	leave  
  8014a5:	c3                   	ret    

008014a6 <sys_rcr2>:
uint32 sys_rcr2()
{
  8014a6:	55                   	push   %ebp
  8014a7:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_rcr2, 0, 0, 0, 0, 0);
  8014a9:	6a 00                	push   $0x0
  8014ab:	6a 00                	push   $0x0
  8014ad:	6a 00                	push   $0x0
  8014af:	6a 00                	push   $0x0
  8014b1:	6a 00                	push   $0x0
  8014b3:	6a 23                	push   $0x23
  8014b5:	e8 d6 fb ff ff       	call   801090 <syscall>
  8014ba:	83 c4 18             	add    $0x18,%esp
}
  8014bd:	c9                   	leave  
  8014be:	c3                   	ret    

008014bf <sys_bypassPageFault>:
void sys_bypassPageFault(uint8 instrLength)
{
  8014bf:	55                   	push   %ebp
  8014c0:	89 e5                	mov    %esp,%ebp
  8014c2:	83 ec 04             	sub    $0x4,%esp
  8014c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c8:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_bypassPageFault, instrLength, 0, 0, 0, 0);
  8014cb:	0f b6 45 fc          	movzbl -0x4(%ebp),%eax
  8014cf:	6a 00                	push   $0x0
  8014d1:	6a 00                	push   $0x0
  8014d3:	6a 00                	push   $0x0
  8014d5:	6a 00                	push   $0x0
  8014d7:	50                   	push   %eax
  8014d8:	6a 24                	push   $0x24
  8014da:	e8 b1 fb ff ff       	call   801090 <syscall>
  8014df:	83 c4 18             	add    $0x18,%esp
	return ;
  8014e2:	90                   	nop
}
  8014e3:	c9                   	leave  
  8014e4:	c3                   	ret    

008014e5 <rsttst>:
void rsttst()
{
  8014e5:	55                   	push   %ebp
  8014e6:	89 e5                	mov    %esp,%ebp
	syscall(SYS_rsttst, 0, 0, 0, 0, 0);
  8014e8:	6a 00                	push   $0x0
  8014ea:	6a 00                	push   $0x0
  8014ec:	6a 00                	push   $0x0
  8014ee:	6a 00                	push   $0x0
  8014f0:	6a 00                	push   $0x0
  8014f2:	6a 26                	push   $0x26
  8014f4:	e8 97 fb ff ff       	call   801090 <syscall>
  8014f9:	83 c4 18             	add    $0x18,%esp
	return ;
  8014fc:	90                   	nop
}
  8014fd:	c9                   	leave  
  8014fe:	c3                   	ret    

008014ff <tst>:
void tst(uint32 n, uint32 v1, uint32 v2, char c, int inv)
{
  8014ff:	55                   	push   %ebp
  801500:	89 e5                	mov    %esp,%ebp
  801502:	83 ec 04             	sub    $0x4,%esp
  801505:	8b 45 14             	mov    0x14(%ebp),%eax
  801508:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_testNum, n, v1, v2, c, inv);
  80150b:	8b 55 18             	mov    0x18(%ebp),%edx
  80150e:	0f be 45 fc          	movsbl -0x4(%ebp),%eax
  801512:	52                   	push   %edx
  801513:	50                   	push   %eax
  801514:	ff 75 10             	pushl  0x10(%ebp)
  801517:	ff 75 0c             	pushl  0xc(%ebp)
  80151a:	ff 75 08             	pushl  0x8(%ebp)
  80151d:	6a 25                	push   $0x25
  80151f:	e8 6c fb ff ff       	call   801090 <syscall>
  801524:	83 c4 18             	add    $0x18,%esp
	return ;
  801527:	90                   	nop
}
  801528:	c9                   	leave  
  801529:	c3                   	ret    

0080152a <chktst>:
void chktst(uint32 n)
{
  80152a:	55                   	push   %ebp
  80152b:	89 e5                	mov    %esp,%ebp
	syscall(SYS_chktst, n, 0, 0, 0, 0);
  80152d:	6a 00                	push   $0x0
  80152f:	6a 00                	push   $0x0
  801531:	6a 00                	push   $0x0
  801533:	6a 00                	push   $0x0
  801535:	ff 75 08             	pushl  0x8(%ebp)
  801538:	6a 27                	push   $0x27
  80153a:	e8 51 fb ff ff       	call   801090 <syscall>
  80153f:	83 c4 18             	add    $0x18,%esp
	return ;
  801542:	90                   	nop
}
  801543:	c9                   	leave  
  801544:	c3                   	ret    

00801545 <inctst>:

void inctst()
{
  801545:	55                   	push   %ebp
  801546:	89 e5                	mov    %esp,%ebp
	syscall(SYS_inctst, 0, 0, 0, 0, 0);
  801548:	6a 00                	push   $0x0
  80154a:	6a 00                	push   $0x0
  80154c:	6a 00                	push   $0x0
  80154e:	6a 00                	push   $0x0
  801550:	6a 00                	push   $0x0
  801552:	6a 28                	push   $0x28
  801554:	e8 37 fb ff ff       	call   801090 <syscall>
  801559:	83 c4 18             	add    $0x18,%esp
	return ;
  80155c:	90                   	nop
}
  80155d:	c9                   	leave  
  80155e:	c3                   	ret    

0080155f <gettst>:
uint32 gettst()
{
  80155f:	55                   	push   %ebp
  801560:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_gettst, 0, 0, 0, 0, 0);
  801562:	6a 00                	push   $0x0
  801564:	6a 00                	push   $0x0
  801566:	6a 00                	push   $0x0
  801568:	6a 00                	push   $0x0
  80156a:	6a 00                	push   $0x0
  80156c:	6a 29                	push   $0x29
  80156e:	e8 1d fb ff ff       	call   801090 <syscall>
  801573:	83 c4 18             	add    $0x18,%esp
}
  801576:	c9                   	leave  
  801577:	c3                   	ret    

00801578 <sys_isUHeapPlacementStrategyFIRSTFIT>:


//2015
uint32 sys_isUHeapPlacementStrategyFIRSTFIT()
{
  801578:	55                   	push   %ebp
  801579:	89 e5                	mov    %esp,%ebp
  80157b:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  80157e:	6a 00                	push   $0x0
  801580:	6a 00                	push   $0x0
  801582:	6a 00                	push   $0x0
  801584:	6a 00                	push   $0x0
  801586:	6a 00                	push   $0x0
  801588:	6a 2a                	push   $0x2a
  80158a:	e8 01 fb ff ff       	call   801090 <syscall>
  80158f:	83 c4 18             	add    $0x18,%esp
  801592:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_FIRSTFIT)
  801595:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
  801599:	75 07                	jne    8015a2 <sys_isUHeapPlacementStrategyFIRSTFIT+0x2a>
		return 1;
  80159b:	b8 01 00 00 00       	mov    $0x1,%eax
  8015a0:	eb 05                	jmp    8015a7 <sys_isUHeapPlacementStrategyFIRSTFIT+0x2f>
	else
		return 0;
  8015a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015a7:	c9                   	leave  
  8015a8:	c3                   	ret    

008015a9 <sys_isUHeapPlacementStrategyBESTFIT>:
uint32 sys_isUHeapPlacementStrategyBESTFIT()
{
  8015a9:	55                   	push   %ebp
  8015aa:	89 e5                	mov    %esp,%ebp
  8015ac:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  8015af:	6a 00                	push   $0x0
  8015b1:	6a 00                	push   $0x0
  8015b3:	6a 00                	push   $0x0
  8015b5:	6a 00                	push   $0x0
  8015b7:	6a 00                	push   $0x0
  8015b9:	6a 2a                	push   $0x2a
  8015bb:	e8 d0 fa ff ff       	call   801090 <syscall>
  8015c0:	83 c4 18             	add    $0x18,%esp
  8015c3:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_BESTFIT)
  8015c6:	83 7d fc 02          	cmpl   $0x2,-0x4(%ebp)
  8015ca:	75 07                	jne    8015d3 <sys_isUHeapPlacementStrategyBESTFIT+0x2a>
		return 1;
  8015cc:	b8 01 00 00 00       	mov    $0x1,%eax
  8015d1:	eb 05                	jmp    8015d8 <sys_isUHeapPlacementStrategyBESTFIT+0x2f>
	else
		return 0;
  8015d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015d8:	c9                   	leave  
  8015d9:	c3                   	ret    

008015da <sys_isUHeapPlacementStrategyNEXTFIT>:
uint32 sys_isUHeapPlacementStrategyNEXTFIT()
{
  8015da:	55                   	push   %ebp
  8015db:	89 e5                	mov    %esp,%ebp
  8015dd:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  8015e0:	6a 00                	push   $0x0
  8015e2:	6a 00                	push   $0x0
  8015e4:	6a 00                	push   $0x0
  8015e6:	6a 00                	push   $0x0
  8015e8:	6a 00                	push   $0x0
  8015ea:	6a 2a                	push   $0x2a
  8015ec:	e8 9f fa ff ff       	call   801090 <syscall>
  8015f1:	83 c4 18             	add    $0x18,%esp
  8015f4:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_NEXTFIT)
  8015f7:	83 7d fc 03          	cmpl   $0x3,-0x4(%ebp)
  8015fb:	75 07                	jne    801604 <sys_isUHeapPlacementStrategyNEXTFIT+0x2a>
		return 1;
  8015fd:	b8 01 00 00 00       	mov    $0x1,%eax
  801602:	eb 05                	jmp    801609 <sys_isUHeapPlacementStrategyNEXTFIT+0x2f>
	else
		return 0;
  801604:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801609:	c9                   	leave  
  80160a:	c3                   	ret    

0080160b <sys_isUHeapPlacementStrategyWORSTFIT>:
uint32 sys_isUHeapPlacementStrategyWORSTFIT()
{
  80160b:	55                   	push   %ebp
  80160c:	89 e5                	mov    %esp,%ebp
  80160e:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  801611:	6a 00                	push   $0x0
  801613:	6a 00                	push   $0x0
  801615:	6a 00                	push   $0x0
  801617:	6a 00                	push   $0x0
  801619:	6a 00                	push   $0x0
  80161b:	6a 2a                	push   $0x2a
  80161d:	e8 6e fa ff ff       	call   801090 <syscall>
  801622:	83 c4 18             	add    $0x18,%esp
  801625:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_WORSTFIT)
  801628:	83 7d fc 04          	cmpl   $0x4,-0x4(%ebp)
  80162c:	75 07                	jne    801635 <sys_isUHeapPlacementStrategyWORSTFIT+0x2a>
		return 1;
  80162e:	b8 01 00 00 00       	mov    $0x1,%eax
  801633:	eb 05                	jmp    80163a <sys_isUHeapPlacementStrategyWORSTFIT+0x2f>
	else
		return 0;
  801635:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80163a:	c9                   	leave  
  80163b:	c3                   	ret    

0080163c <sys_set_uheap_strategy>:

void sys_set_uheap_strategy(uint32 heapStrategy)
{
  80163c:	55                   	push   %ebp
  80163d:	89 e5                	mov    %esp,%ebp
	syscall(SYS_set_heap_strategy, heapStrategy, 0, 0, 0, 0);
  80163f:	6a 00                	push   $0x0
  801641:	6a 00                	push   $0x0
  801643:	6a 00                	push   $0x0
  801645:	6a 00                	push   $0x0
  801647:	ff 75 08             	pushl  0x8(%ebp)
  80164a:	6a 2b                	push   $0x2b
  80164c:	e8 3f fa ff ff       	call   801090 <syscall>
  801651:	83 c4 18             	add    $0x18,%esp
	return ;
  801654:	90                   	nop
}
  801655:	c9                   	leave  
  801656:	c3                   	ret    

00801657 <sys_check_LRU_lists>:

//2020
int sys_check_LRU_lists(uint32* active_list_content, uint32* second_list_content, int actual_active_list_size, int actual_second_list_size)
{
  801657:	55                   	push   %ebp
  801658:	89 e5                	mov    %esp,%ebp
  80165a:	53                   	push   %ebx
	return syscall(SYS_check_LRU_lists, (uint32)active_list_content, (uint32)second_list_content, (uint32)actual_active_list_size, (uint32)actual_second_list_size, 0);
  80165b:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80165e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801661:	8b 55 0c             	mov    0xc(%ebp),%edx
  801664:	8b 45 08             	mov    0x8(%ebp),%eax
  801667:	6a 00                	push   $0x0
  801669:	53                   	push   %ebx
  80166a:	51                   	push   %ecx
  80166b:	52                   	push   %edx
  80166c:	50                   	push   %eax
  80166d:	6a 2c                	push   $0x2c
  80166f:	e8 1c fa ff ff       	call   801090 <syscall>
  801674:	83 c4 18             	add    $0x18,%esp
}
  801677:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80167a:	c9                   	leave  
  80167b:	c3                   	ret    

0080167c <sys_check_LRU_lists_free>:

int sys_check_LRU_lists_free(uint32* list_content, int list_size)
{
  80167c:	55                   	push   %ebp
  80167d:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_check_LRU_lists_free, (uint32)list_content, (uint32)list_size , 0, 0, 0);
  80167f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801682:	8b 45 08             	mov    0x8(%ebp),%eax
  801685:	6a 00                	push   $0x0
  801687:	6a 00                	push   $0x0
  801689:	6a 00                	push   $0x0
  80168b:	52                   	push   %edx
  80168c:	50                   	push   %eax
  80168d:	6a 2d                	push   $0x2d
  80168f:	e8 fc f9 ff ff       	call   801090 <syscall>
  801694:	83 c4 18             	add    $0x18,%esp
}
  801697:	c9                   	leave  
  801698:	c3                   	ret    

00801699 <sys_check_WS_list>:

int sys_check_WS_list(uint32* WS_list_content, int actual_WS_list_size, uint32 last_WS_element_content, bool chk_in_order)
{
  801699:	55                   	push   %ebp
  80169a:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_check_WS_list, (uint32)WS_list_content, (uint32)actual_WS_list_size , last_WS_element_content, (uint32)chk_in_order, 0);
  80169c:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80169f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a5:	6a 00                	push   $0x0
  8016a7:	51                   	push   %ecx
  8016a8:	ff 75 10             	pushl  0x10(%ebp)
  8016ab:	52                   	push   %edx
  8016ac:	50                   	push   %eax
  8016ad:	6a 2e                	push   $0x2e
  8016af:	e8 dc f9 ff ff       	call   801090 <syscall>
  8016b4:	83 c4 18             	add    $0x18,%esp
}
  8016b7:	c9                   	leave  
  8016b8:	c3                   	ret    

008016b9 <sys_allocate_chunk>:
void sys_allocate_chunk(uint32 virtual_address, uint32 size, uint32 perms)
{
  8016b9:	55                   	push   %ebp
  8016ba:	89 e5                	mov    %esp,%ebp
	syscall(SYS_allocate_chunk_in_mem, virtual_address, size, perms, 0, 0);
  8016bc:	6a 00                	push   $0x0
  8016be:	6a 00                	push   $0x0
  8016c0:	ff 75 10             	pushl  0x10(%ebp)
  8016c3:	ff 75 0c             	pushl  0xc(%ebp)
  8016c6:	ff 75 08             	pushl  0x8(%ebp)
  8016c9:	6a 0f                	push   $0xf
  8016cb:	e8 c0 f9 ff ff       	call   801090 <syscall>
  8016d0:	83 c4 18             	add    $0x18,%esp
	return ;
  8016d3:	90                   	nop
}
  8016d4:	c9                   	leave  
  8016d5:	c3                   	ret    

008016d6 <sys_sbrk>:


/*2023*/
//TODO: [PROJECT'23.MS1 - #3] [2] SYSTEM CALLS - Implement these system calls
void* sys_sbrk(int increment)
{
  8016d6:	55                   	push   %ebp
  8016d7:	89 e5                	mov    %esp,%ebp
  8016d9:	83 ec 08             	sub    $0x8,%esp
	//Comment the following line before start coding...
	panic("not implemented yet");
  8016dc:	83 ec 04             	sub    $0x4,%esp
  8016df:	68 10 20 80 00       	push   $0x802010
  8016e4:	68 54 01 00 00       	push   $0x154
  8016e9:	68 24 20 80 00       	push   $0x802024
  8016ee:	e8 3a 00 00 00       	call   80172d <_panic>

008016f3 <sys_free_user_mem>:
	return NULL;
}

void sys_free_user_mem(uint32 virtual_address, uint32 size)
{
  8016f3:	55                   	push   %ebp
  8016f4:	89 e5                	mov    %esp,%ebp
  8016f6:	83 ec 08             	sub    $0x8,%esp
	//Comment the following line before start coding...
	panic("not implemented yet");
  8016f9:	83 ec 04             	sub    $0x4,%esp
  8016fc:	68 10 20 80 00       	push   $0x802010
  801701:	68 5b 01 00 00       	push   $0x15b
  801706:	68 24 20 80 00       	push   $0x802024
  80170b:	e8 1d 00 00 00       	call   80172d <_panic>

00801710 <sys_allocate_user_mem>:
}

void sys_allocate_user_mem(uint32 virtual_address, uint32 size)
{
  801710:	55                   	push   %ebp
  801711:	89 e5                	mov    %esp,%ebp
  801713:	83 ec 08             	sub    $0x8,%esp
	//Comment the following line before start coding...
	panic("not implemented yet");
  801716:	83 ec 04             	sub    $0x4,%esp
  801719:	68 10 20 80 00       	push   $0x802010
  80171e:	68 61 01 00 00       	push   $0x161
  801723:	68 24 20 80 00       	push   $0x802024
  801728:	e8 00 00 00 00       	call   80172d <_panic>

0080172d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes FOS to enter the FOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  80172d:	55                   	push   %ebp
  80172e:	89 e5                	mov    %esp,%ebp
  801730:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	va_start(ap, fmt);
  801733:	8d 45 10             	lea    0x10(%ebp),%eax
  801736:	83 c0 04             	add    $0x4,%eax
  801739:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// Print the panic message
	if (argv0)
  80173c:	a1 18 31 80 00       	mov    0x803118,%eax
  801741:	85 c0                	test   %eax,%eax
  801743:	74 16                	je     80175b <_panic+0x2e>
		cprintf("%s: ", argv0);
  801745:	a1 18 31 80 00       	mov    0x803118,%eax
  80174a:	83 ec 08             	sub    $0x8,%esp
  80174d:	50                   	push   %eax
  80174e:	68 34 20 80 00       	push   $0x802034
  801753:	e8 15 eb ff ff       	call   80026d <cprintf>
  801758:	83 c4 10             	add    $0x10,%esp
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  80175b:	a1 00 30 80 00       	mov    0x803000,%eax
  801760:	ff 75 0c             	pushl  0xc(%ebp)
  801763:	ff 75 08             	pushl  0x8(%ebp)
  801766:	50                   	push   %eax
  801767:	68 39 20 80 00       	push   $0x802039
  80176c:	e8 fc ea ff ff       	call   80026d <cprintf>
  801771:	83 c4 10             	add    $0x10,%esp
	vcprintf(fmt, ap);
  801774:	8b 45 10             	mov    0x10(%ebp),%eax
  801777:	83 ec 08             	sub    $0x8,%esp
  80177a:	ff 75 f4             	pushl  -0xc(%ebp)
  80177d:	50                   	push   %eax
  80177e:	e8 7f ea ff ff       	call   800202 <vcprintf>
  801783:	83 c4 10             	add    $0x10,%esp
	vcprintf("\n", NULL);
  801786:	83 ec 08             	sub    $0x8,%esp
  801789:	6a 00                	push   $0x0
  80178b:	68 55 20 80 00       	push   $0x802055
  801790:	e8 6d ea ff ff       	call   800202 <vcprintf>
  801795:	83 c4 10             	add    $0x10,%esp
	// Cause a breakpoint exception
//	while (1);
//		asm volatile("int3");

	//2013: exit the panic env only
	exit() ;
  801798:	e8 ee e9 ff ff       	call   80018b <exit>

	// should not return here
	while (1) ;
  80179d:	eb fe                	jmp    80179d <_panic+0x70>

0080179f <CheckWSArrayWithoutLastIndex>:
}

void CheckWSArrayWithoutLastIndex(uint32 *expectedPages, int arraySize)
{
  80179f:	55                   	push   %ebp
  8017a0:	89 e5                	mov    %esp,%ebp
  8017a2:	83 ec 28             	sub    $0x28,%esp
	if (arraySize != myEnv->page_WS_max_size)
  8017a5:	a1 20 30 80 00       	mov    0x803020,%eax
  8017aa:	8b 90 7c d5 01 00    	mov    0x1d57c(%eax),%edx
  8017b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017b3:	39 c2                	cmp    %eax,%edx
  8017b5:	74 14                	je     8017cb <CheckWSArrayWithoutLastIndex+0x2c>
	{
		panic("number of expected pages SHOULD BE EQUAL to max WS size... review your TA!!");
  8017b7:	83 ec 04             	sub    $0x4,%esp
  8017ba:	68 58 20 80 00       	push   $0x802058
  8017bf:	6a 26                	push   $0x26
  8017c1:	68 a4 20 80 00       	push   $0x8020a4
  8017c6:	e8 62 ff ff ff       	call   80172d <_panic>
	}
	int expectedNumOfEmptyLocs = 0;
  8017cb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	for (int e = 0; e < arraySize; e++) {
  8017d2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8017d9:	e9 c5 00 00 00       	jmp    8018a3 <CheckWSArrayWithoutLastIndex+0x104>
		if (expectedPages[e] == 0) {
  8017de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017e1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8017e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017eb:	01 d0                	add    %edx,%eax
  8017ed:	8b 00                	mov    (%eax),%eax
  8017ef:	85 c0                	test   %eax,%eax
  8017f1:	75 08                	jne    8017fb <CheckWSArrayWithoutLastIndex+0x5c>
			expectedNumOfEmptyLocs++;
  8017f3:	ff 45 f4             	incl   -0xc(%ebp)
			continue;
  8017f6:	e9 a5 00 00 00       	jmp    8018a0 <CheckWSArrayWithoutLastIndex+0x101>
		}
		int found = 0;
  8017fb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  801802:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  801809:	eb 69                	jmp    801874 <CheckWSArrayWithoutLastIndex+0xd5>
			if (myEnv->__uptr_pws[w].empty == 0) {
  80180b:	a1 20 30 80 00       	mov    0x803020,%eax
  801810:	8b 88 6c da 01 00    	mov    0x1da6c(%eax),%ecx
  801816:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801819:	89 d0                	mov    %edx,%eax
  80181b:	01 c0                	add    %eax,%eax
  80181d:	01 d0                	add    %edx,%eax
  80181f:	c1 e0 03             	shl    $0x3,%eax
  801822:	01 c8                	add    %ecx,%eax
  801824:	8a 40 04             	mov    0x4(%eax),%al
  801827:	84 c0                	test   %al,%al
  801829:	75 46                	jne    801871 <CheckWSArrayWithoutLastIndex+0xd2>
				if (ROUNDDOWN(myEnv->__uptr_pws[w].virtual_address, PAGE_SIZE)
  80182b:	a1 20 30 80 00       	mov    0x803020,%eax
  801830:	8b 88 6c da 01 00    	mov    0x1da6c(%eax),%ecx
  801836:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801839:	89 d0                	mov    %edx,%eax
  80183b:	01 c0                	add    %eax,%eax
  80183d:	01 d0                	add    %edx,%eax
  80183f:	c1 e0 03             	shl    $0x3,%eax
  801842:	01 c8                	add    %ecx,%eax
  801844:	8b 00                	mov    (%eax),%eax
  801846:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801849:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80184c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801851:	89 c2                	mov    %eax,%edx
						== expectedPages[e]) {
  801853:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801856:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  80185d:	8b 45 08             	mov    0x8(%ebp),%eax
  801860:	01 c8                	add    %ecx,%eax
  801862:	8b 00                	mov    (%eax),%eax
			continue;
		}
		int found = 0;
		for (int w = 0; w < myEnv->page_WS_max_size; w++) {
			if (myEnv->__uptr_pws[w].empty == 0) {
				if (ROUNDDOWN(myEnv->__uptr_pws[w].virtual_address, PAGE_SIZE)
  801864:	39 c2                	cmp    %eax,%edx
  801866:	75 09                	jne    801871 <CheckWSArrayWithoutLastIndex+0xd2>
						== expectedPages[e]) {
					found = 1;
  801868:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
					break;
  80186f:	eb 15                	jmp    801886 <CheckWSArrayWithoutLastIndex+0xe7>
		if (expectedPages[e] == 0) {
			expectedNumOfEmptyLocs++;
			continue;
		}
		int found = 0;
		for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  801871:	ff 45 e8             	incl   -0x18(%ebp)
  801874:	a1 20 30 80 00       	mov    0x803020,%eax
  801879:	8b 90 7c d5 01 00    	mov    0x1d57c(%eax),%edx
  80187f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801882:	39 c2                	cmp    %eax,%edx
  801884:	77 85                	ja     80180b <CheckWSArrayWithoutLastIndex+0x6c>
					found = 1;
					break;
				}
			}
		}
		if (!found)
  801886:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  80188a:	75 14                	jne    8018a0 <CheckWSArrayWithoutLastIndex+0x101>
			panic(
  80188c:	83 ec 04             	sub    $0x4,%esp
  80188f:	68 b0 20 80 00       	push   $0x8020b0
  801894:	6a 3a                	push   $0x3a
  801896:	68 a4 20 80 00       	push   $0x8020a4
  80189b:	e8 8d fe ff ff       	call   80172d <_panic>
	if (arraySize != myEnv->page_WS_max_size)
	{
		panic("number of expected pages SHOULD BE EQUAL to max WS size... review your TA!!");
	}
	int expectedNumOfEmptyLocs = 0;
	for (int e = 0; e < arraySize; e++) {
  8018a0:	ff 45 f0             	incl   -0x10(%ebp)
  8018a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018a6:	3b 45 0c             	cmp    0xc(%ebp),%eax
  8018a9:	0f 8c 2f ff ff ff    	jl     8017de <CheckWSArrayWithoutLastIndex+0x3f>
		}
		if (!found)
			panic(
					"PAGE WS entry checking failed... trace it by printing page WS before & after fault");
	}
	int actualNumOfEmptyLocs = 0;
  8018af:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  8018b6:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8018bd:	eb 26                	jmp    8018e5 <CheckWSArrayWithoutLastIndex+0x146>
		if (myEnv->__uptr_pws[w].empty == 1) {
  8018bf:	a1 20 30 80 00       	mov    0x803020,%eax
  8018c4:	8b 88 6c da 01 00    	mov    0x1da6c(%eax),%ecx
  8018ca:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8018cd:	89 d0                	mov    %edx,%eax
  8018cf:	01 c0                	add    %eax,%eax
  8018d1:	01 d0                	add    %edx,%eax
  8018d3:	c1 e0 03             	shl    $0x3,%eax
  8018d6:	01 c8                	add    %ecx,%eax
  8018d8:	8a 40 04             	mov    0x4(%eax),%al
  8018db:	3c 01                	cmp    $0x1,%al
  8018dd:	75 03                	jne    8018e2 <CheckWSArrayWithoutLastIndex+0x143>
			actualNumOfEmptyLocs++;
  8018df:	ff 45 e4             	incl   -0x1c(%ebp)
		if (!found)
			panic(
					"PAGE WS entry checking failed... trace it by printing page WS before & after fault");
	}
	int actualNumOfEmptyLocs = 0;
	for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  8018e2:	ff 45 e0             	incl   -0x20(%ebp)
  8018e5:	a1 20 30 80 00       	mov    0x803020,%eax
  8018ea:	8b 90 7c d5 01 00    	mov    0x1d57c(%eax),%edx
  8018f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018f3:	39 c2                	cmp    %eax,%edx
  8018f5:	77 c8                	ja     8018bf <CheckWSArrayWithoutLastIndex+0x120>
		if (myEnv->__uptr_pws[w].empty == 1) {
			actualNumOfEmptyLocs++;
		}
	}
	if (expectedNumOfEmptyLocs != actualNumOfEmptyLocs)
  8018f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018fa:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
  8018fd:	74 14                	je     801913 <CheckWSArrayWithoutLastIndex+0x174>
		panic(
  8018ff:	83 ec 04             	sub    $0x4,%esp
  801902:	68 04 21 80 00       	push   $0x802104
  801907:	6a 44                	push   $0x44
  801909:	68 a4 20 80 00       	push   $0x8020a4
  80190e:	e8 1a fe ff ff       	call   80172d <_panic>
				"PAGE WS entry checking failed... number of empty locations is not correct");
}
  801913:	90                   	nop
  801914:	c9                   	leave  
  801915:	c3                   	ret    
  801916:	66 90                	xchg   %ax,%ax

00801918 <__udivdi3>:
  801918:	55                   	push   %ebp
  801919:	57                   	push   %edi
  80191a:	56                   	push   %esi
  80191b:	53                   	push   %ebx
  80191c:	83 ec 1c             	sub    $0x1c,%esp
  80191f:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801923:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801927:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80192b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80192f:	89 ca                	mov    %ecx,%edx
  801931:	89 f8                	mov    %edi,%eax
  801933:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801937:	85 f6                	test   %esi,%esi
  801939:	75 2d                	jne    801968 <__udivdi3+0x50>
  80193b:	39 cf                	cmp    %ecx,%edi
  80193d:	77 65                	ja     8019a4 <__udivdi3+0x8c>
  80193f:	89 fd                	mov    %edi,%ebp
  801941:	85 ff                	test   %edi,%edi
  801943:	75 0b                	jne    801950 <__udivdi3+0x38>
  801945:	b8 01 00 00 00       	mov    $0x1,%eax
  80194a:	31 d2                	xor    %edx,%edx
  80194c:	f7 f7                	div    %edi
  80194e:	89 c5                	mov    %eax,%ebp
  801950:	31 d2                	xor    %edx,%edx
  801952:	89 c8                	mov    %ecx,%eax
  801954:	f7 f5                	div    %ebp
  801956:	89 c1                	mov    %eax,%ecx
  801958:	89 d8                	mov    %ebx,%eax
  80195a:	f7 f5                	div    %ebp
  80195c:	89 cf                	mov    %ecx,%edi
  80195e:	89 fa                	mov    %edi,%edx
  801960:	83 c4 1c             	add    $0x1c,%esp
  801963:	5b                   	pop    %ebx
  801964:	5e                   	pop    %esi
  801965:	5f                   	pop    %edi
  801966:	5d                   	pop    %ebp
  801967:	c3                   	ret    
  801968:	39 ce                	cmp    %ecx,%esi
  80196a:	77 28                	ja     801994 <__udivdi3+0x7c>
  80196c:	0f bd fe             	bsr    %esi,%edi
  80196f:	83 f7 1f             	xor    $0x1f,%edi
  801972:	75 40                	jne    8019b4 <__udivdi3+0x9c>
  801974:	39 ce                	cmp    %ecx,%esi
  801976:	72 0a                	jb     801982 <__udivdi3+0x6a>
  801978:	3b 44 24 08          	cmp    0x8(%esp),%eax
  80197c:	0f 87 9e 00 00 00    	ja     801a20 <__udivdi3+0x108>
  801982:	b8 01 00 00 00       	mov    $0x1,%eax
  801987:	89 fa                	mov    %edi,%edx
  801989:	83 c4 1c             	add    $0x1c,%esp
  80198c:	5b                   	pop    %ebx
  80198d:	5e                   	pop    %esi
  80198e:	5f                   	pop    %edi
  80198f:	5d                   	pop    %ebp
  801990:	c3                   	ret    
  801991:	8d 76 00             	lea    0x0(%esi),%esi
  801994:	31 ff                	xor    %edi,%edi
  801996:	31 c0                	xor    %eax,%eax
  801998:	89 fa                	mov    %edi,%edx
  80199a:	83 c4 1c             	add    $0x1c,%esp
  80199d:	5b                   	pop    %ebx
  80199e:	5e                   	pop    %esi
  80199f:	5f                   	pop    %edi
  8019a0:	5d                   	pop    %ebp
  8019a1:	c3                   	ret    
  8019a2:	66 90                	xchg   %ax,%ax
  8019a4:	89 d8                	mov    %ebx,%eax
  8019a6:	f7 f7                	div    %edi
  8019a8:	31 ff                	xor    %edi,%edi
  8019aa:	89 fa                	mov    %edi,%edx
  8019ac:	83 c4 1c             	add    $0x1c,%esp
  8019af:	5b                   	pop    %ebx
  8019b0:	5e                   	pop    %esi
  8019b1:	5f                   	pop    %edi
  8019b2:	5d                   	pop    %ebp
  8019b3:	c3                   	ret    
  8019b4:	bd 20 00 00 00       	mov    $0x20,%ebp
  8019b9:	89 eb                	mov    %ebp,%ebx
  8019bb:	29 fb                	sub    %edi,%ebx
  8019bd:	89 f9                	mov    %edi,%ecx
  8019bf:	d3 e6                	shl    %cl,%esi
  8019c1:	89 c5                	mov    %eax,%ebp
  8019c3:	88 d9                	mov    %bl,%cl
  8019c5:	d3 ed                	shr    %cl,%ebp
  8019c7:	89 e9                	mov    %ebp,%ecx
  8019c9:	09 f1                	or     %esi,%ecx
  8019cb:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8019cf:	89 f9                	mov    %edi,%ecx
  8019d1:	d3 e0                	shl    %cl,%eax
  8019d3:	89 c5                	mov    %eax,%ebp
  8019d5:	89 d6                	mov    %edx,%esi
  8019d7:	88 d9                	mov    %bl,%cl
  8019d9:	d3 ee                	shr    %cl,%esi
  8019db:	89 f9                	mov    %edi,%ecx
  8019dd:	d3 e2                	shl    %cl,%edx
  8019df:	8b 44 24 08          	mov    0x8(%esp),%eax
  8019e3:	88 d9                	mov    %bl,%cl
  8019e5:	d3 e8                	shr    %cl,%eax
  8019e7:	09 c2                	or     %eax,%edx
  8019e9:	89 d0                	mov    %edx,%eax
  8019eb:	89 f2                	mov    %esi,%edx
  8019ed:	f7 74 24 0c          	divl   0xc(%esp)
  8019f1:	89 d6                	mov    %edx,%esi
  8019f3:	89 c3                	mov    %eax,%ebx
  8019f5:	f7 e5                	mul    %ebp
  8019f7:	39 d6                	cmp    %edx,%esi
  8019f9:	72 19                	jb     801a14 <__udivdi3+0xfc>
  8019fb:	74 0b                	je     801a08 <__udivdi3+0xf0>
  8019fd:	89 d8                	mov    %ebx,%eax
  8019ff:	31 ff                	xor    %edi,%edi
  801a01:	e9 58 ff ff ff       	jmp    80195e <__udivdi3+0x46>
  801a06:	66 90                	xchg   %ax,%ax
  801a08:	8b 54 24 08          	mov    0x8(%esp),%edx
  801a0c:	89 f9                	mov    %edi,%ecx
  801a0e:	d3 e2                	shl    %cl,%edx
  801a10:	39 c2                	cmp    %eax,%edx
  801a12:	73 e9                	jae    8019fd <__udivdi3+0xe5>
  801a14:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801a17:	31 ff                	xor    %edi,%edi
  801a19:	e9 40 ff ff ff       	jmp    80195e <__udivdi3+0x46>
  801a1e:	66 90                	xchg   %ax,%ax
  801a20:	31 c0                	xor    %eax,%eax
  801a22:	e9 37 ff ff ff       	jmp    80195e <__udivdi3+0x46>
  801a27:	90                   	nop

00801a28 <__umoddi3>:
  801a28:	55                   	push   %ebp
  801a29:	57                   	push   %edi
  801a2a:	56                   	push   %esi
  801a2b:	53                   	push   %ebx
  801a2c:	83 ec 1c             	sub    $0x1c,%esp
  801a2f:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801a33:	8b 74 24 34          	mov    0x34(%esp),%esi
  801a37:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801a3b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801a3f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a43:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801a47:	89 f3                	mov    %esi,%ebx
  801a49:	89 fa                	mov    %edi,%edx
  801a4b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801a4f:	89 34 24             	mov    %esi,(%esp)
  801a52:	85 c0                	test   %eax,%eax
  801a54:	75 1a                	jne    801a70 <__umoddi3+0x48>
  801a56:	39 f7                	cmp    %esi,%edi
  801a58:	0f 86 a2 00 00 00    	jbe    801b00 <__umoddi3+0xd8>
  801a5e:	89 c8                	mov    %ecx,%eax
  801a60:	89 f2                	mov    %esi,%edx
  801a62:	f7 f7                	div    %edi
  801a64:	89 d0                	mov    %edx,%eax
  801a66:	31 d2                	xor    %edx,%edx
  801a68:	83 c4 1c             	add    $0x1c,%esp
  801a6b:	5b                   	pop    %ebx
  801a6c:	5e                   	pop    %esi
  801a6d:	5f                   	pop    %edi
  801a6e:	5d                   	pop    %ebp
  801a6f:	c3                   	ret    
  801a70:	39 f0                	cmp    %esi,%eax
  801a72:	0f 87 ac 00 00 00    	ja     801b24 <__umoddi3+0xfc>
  801a78:	0f bd e8             	bsr    %eax,%ebp
  801a7b:	83 f5 1f             	xor    $0x1f,%ebp
  801a7e:	0f 84 ac 00 00 00    	je     801b30 <__umoddi3+0x108>
  801a84:	bf 20 00 00 00       	mov    $0x20,%edi
  801a89:	29 ef                	sub    %ebp,%edi
  801a8b:	89 fe                	mov    %edi,%esi
  801a8d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801a91:	89 e9                	mov    %ebp,%ecx
  801a93:	d3 e0                	shl    %cl,%eax
  801a95:	89 d7                	mov    %edx,%edi
  801a97:	89 f1                	mov    %esi,%ecx
  801a99:	d3 ef                	shr    %cl,%edi
  801a9b:	09 c7                	or     %eax,%edi
  801a9d:	89 e9                	mov    %ebp,%ecx
  801a9f:	d3 e2                	shl    %cl,%edx
  801aa1:	89 14 24             	mov    %edx,(%esp)
  801aa4:	89 d8                	mov    %ebx,%eax
  801aa6:	d3 e0                	shl    %cl,%eax
  801aa8:	89 c2                	mov    %eax,%edx
  801aaa:	8b 44 24 08          	mov    0x8(%esp),%eax
  801aae:	d3 e0                	shl    %cl,%eax
  801ab0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ab4:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ab8:	89 f1                	mov    %esi,%ecx
  801aba:	d3 e8                	shr    %cl,%eax
  801abc:	09 d0                	or     %edx,%eax
  801abe:	d3 eb                	shr    %cl,%ebx
  801ac0:	89 da                	mov    %ebx,%edx
  801ac2:	f7 f7                	div    %edi
  801ac4:	89 d3                	mov    %edx,%ebx
  801ac6:	f7 24 24             	mull   (%esp)
  801ac9:	89 c6                	mov    %eax,%esi
  801acb:	89 d1                	mov    %edx,%ecx
  801acd:	39 d3                	cmp    %edx,%ebx
  801acf:	0f 82 87 00 00 00    	jb     801b5c <__umoddi3+0x134>
  801ad5:	0f 84 91 00 00 00    	je     801b6c <__umoddi3+0x144>
  801adb:	8b 54 24 04          	mov    0x4(%esp),%edx
  801adf:	29 f2                	sub    %esi,%edx
  801ae1:	19 cb                	sbb    %ecx,%ebx
  801ae3:	89 d8                	mov    %ebx,%eax
  801ae5:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  801ae9:	d3 e0                	shl    %cl,%eax
  801aeb:	89 e9                	mov    %ebp,%ecx
  801aed:	d3 ea                	shr    %cl,%edx
  801aef:	09 d0                	or     %edx,%eax
  801af1:	89 e9                	mov    %ebp,%ecx
  801af3:	d3 eb                	shr    %cl,%ebx
  801af5:	89 da                	mov    %ebx,%edx
  801af7:	83 c4 1c             	add    $0x1c,%esp
  801afa:	5b                   	pop    %ebx
  801afb:	5e                   	pop    %esi
  801afc:	5f                   	pop    %edi
  801afd:	5d                   	pop    %ebp
  801afe:	c3                   	ret    
  801aff:	90                   	nop
  801b00:	89 fd                	mov    %edi,%ebp
  801b02:	85 ff                	test   %edi,%edi
  801b04:	75 0b                	jne    801b11 <__umoddi3+0xe9>
  801b06:	b8 01 00 00 00       	mov    $0x1,%eax
  801b0b:	31 d2                	xor    %edx,%edx
  801b0d:	f7 f7                	div    %edi
  801b0f:	89 c5                	mov    %eax,%ebp
  801b11:	89 f0                	mov    %esi,%eax
  801b13:	31 d2                	xor    %edx,%edx
  801b15:	f7 f5                	div    %ebp
  801b17:	89 c8                	mov    %ecx,%eax
  801b19:	f7 f5                	div    %ebp
  801b1b:	89 d0                	mov    %edx,%eax
  801b1d:	e9 44 ff ff ff       	jmp    801a66 <__umoddi3+0x3e>
  801b22:	66 90                	xchg   %ax,%ax
  801b24:	89 c8                	mov    %ecx,%eax
  801b26:	89 f2                	mov    %esi,%edx
  801b28:	83 c4 1c             	add    $0x1c,%esp
  801b2b:	5b                   	pop    %ebx
  801b2c:	5e                   	pop    %esi
  801b2d:	5f                   	pop    %edi
  801b2e:	5d                   	pop    %ebp
  801b2f:	c3                   	ret    
  801b30:	3b 04 24             	cmp    (%esp),%eax
  801b33:	72 06                	jb     801b3b <__umoddi3+0x113>
  801b35:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  801b39:	77 0f                	ja     801b4a <__umoddi3+0x122>
  801b3b:	89 f2                	mov    %esi,%edx
  801b3d:	29 f9                	sub    %edi,%ecx
  801b3f:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  801b43:	89 14 24             	mov    %edx,(%esp)
  801b46:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801b4a:	8b 44 24 04          	mov    0x4(%esp),%eax
  801b4e:	8b 14 24             	mov    (%esp),%edx
  801b51:	83 c4 1c             	add    $0x1c,%esp
  801b54:	5b                   	pop    %ebx
  801b55:	5e                   	pop    %esi
  801b56:	5f                   	pop    %edi
  801b57:	5d                   	pop    %ebp
  801b58:	c3                   	ret    
  801b59:	8d 76 00             	lea    0x0(%esi),%esi
  801b5c:	2b 04 24             	sub    (%esp),%eax
  801b5f:	19 fa                	sbb    %edi,%edx
  801b61:	89 d1                	mov    %edx,%ecx
  801b63:	89 c6                	mov    %eax,%esi
  801b65:	e9 71 ff ff ff       	jmp    801adb <__umoddi3+0xb3>
  801b6a:	66 90                	xchg   %ax,%ax
  801b6c:	39 44 24 04          	cmp    %eax,0x4(%esp)
  801b70:	72 ea                	jb     801b5c <__umoddi3+0x134>
  801b72:	89 d9                	mov    %ebx,%ecx
  801b74:	e9 62 ff ff ff       	jmp    801adb <__umoddi3+0xb3>
