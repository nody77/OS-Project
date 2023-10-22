
obj/user/fos_helloWorld:     file format elf32-i386


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
  800031:	e8 31 00 00 00       	call   800067 <libmain>
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
  80003b:	83 ec 08             	sub    $0x8,%esp
	extern unsigned char * etext;
	//cprintf("HELLO WORLD , FOS IS SAYING HI :D:D:D %d\n",4);
	atomic_cprintf("HELLO WORLD , FOS IS SAYING HI :D:D:D \n");
  80003e:	83 ec 0c             	sub    $0xc,%esp
  800041:	68 a0 1b 80 00       	push   $0x801ba0
  800046:	e8 62 02 00 00       	call   8002ad <atomic_cprintf>
  80004b:	83 c4 10             	add    $0x10,%esp
	atomic_cprintf("end of code = %x\n",etext);
  80004e:	a1 8d 1b 80 00       	mov    0x801b8d,%eax
  800053:	83 ec 08             	sub    $0x8,%esp
  800056:	50                   	push   %eax
  800057:	68 c8 1b 80 00       	push   $0x801bc8
  80005c:	e8 4c 02 00 00       	call   8002ad <atomic_cprintf>
  800061:	83 c4 10             	add    $0x10,%esp
}
  800064:	90                   	nop
  800065:	c9                   	leave  
  800066:	c3                   	ret    

00800067 <libmain>:
volatile struct Env *myEnv = NULL;
volatile char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800067:	55                   	push   %ebp
  800068:	89 e5                	mov    %esp,%ebp
  80006a:	83 ec 18             	sub    $0x18,%esp
	int envIndex = sys_getenvindex();
  80006d:	e8 a8 13 00 00       	call   80141a <sys_getenvindex>
  800072:	89 45 f4             	mov    %eax,-0xc(%ebp)
	myEnv = &(envs[envIndex]);
  800075:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800078:	89 d0                	mov    %edx,%eax
  80007a:	01 c0                	add    %eax,%eax
  80007c:	01 d0                	add    %edx,%eax
  80007e:	01 c0                	add    %eax,%eax
  800080:	01 d0                	add    %edx,%eax
  800082:	c1 e0 02             	shl    $0x2,%eax
  800085:	01 d0                	add    %edx,%eax
  800087:	01 c0                	add    %eax,%eax
  800089:	01 d0                	add    %edx,%eax
  80008b:	c1 e0 02             	shl    $0x2,%eax
  80008e:	01 d0                	add    %edx,%eax
  800090:	c1 e0 02             	shl    $0x2,%eax
  800093:	01 d0                	add    %edx,%eax
  800095:	c1 e0 02             	shl    $0x2,%eax
  800098:	01 d0                	add    %edx,%eax
  80009a:	c1 e0 05             	shl    $0x5,%eax
  80009d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000a2:	a3 20 30 80 00       	mov    %eax,0x803020

	//SET THE PROGRAM NAME
	if (myEnv->prog_name[0] != '\0')
  8000a7:	a1 20 30 80 00       	mov    0x803020,%eax
  8000ac:	8a 40 5c             	mov    0x5c(%eax),%al
  8000af:	84 c0                	test   %al,%al
  8000b1:	74 0d                	je     8000c0 <libmain+0x59>
		binaryname = myEnv->prog_name;
  8000b3:	a1 20 30 80 00       	mov    0x803020,%eax
  8000b8:	83 c0 5c             	add    $0x5c,%eax
  8000bb:	a3 00 30 80 00       	mov    %eax,0x803000

	// set env to point at our env structure in envs[].
	// env = envs;

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000c4:	7e 0a                	jle    8000d0 <libmain+0x69>
		binaryname = argv[0];
  8000c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000c9:	8b 00                	mov    (%eax),%eax
  8000cb:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	_main(argc, argv);
  8000d0:	83 ec 08             	sub    $0x8,%esp
  8000d3:	ff 75 0c             	pushl  0xc(%ebp)
  8000d6:	ff 75 08             	pushl  0x8(%ebp)
  8000d9:	e8 5a ff ff ff       	call   800038 <_main>
  8000de:	83 c4 10             	add    $0x10,%esp



	sys_disable_interrupt();
  8000e1:	e8 41 11 00 00       	call   801227 <sys_disable_interrupt>
	cprintf("**************************************\n");
  8000e6:	83 ec 0c             	sub    $0xc,%esp
  8000e9:	68 f4 1b 80 00       	push   $0x801bf4
  8000ee:	e8 8d 01 00 00       	call   800280 <cprintf>
  8000f3:	83 c4 10             	add    $0x10,%esp
	cprintf("Num of PAGE faults = %d, modif = %d\n", myEnv->pageFaultsCounter, myEnv->nModifiedPages);
  8000f6:	a1 20 30 80 00       	mov    0x803020,%eax
  8000fb:	8b 90 84 da 01 00    	mov    0x1da84(%eax),%edx
  800101:	a1 20 30 80 00       	mov    0x803020,%eax
  800106:	8b 80 74 da 01 00    	mov    0x1da74(%eax),%eax
  80010c:	83 ec 04             	sub    $0x4,%esp
  80010f:	52                   	push   %edx
  800110:	50                   	push   %eax
  800111:	68 1c 1c 80 00       	push   $0x801c1c
  800116:	e8 65 01 00 00       	call   800280 <cprintf>
  80011b:	83 c4 10             	add    $0x10,%esp
	cprintf("# PAGE IN (from disk) = %d, # PAGE OUT (on disk) = %d, # NEW PAGE ADDED (on disk) = %d\n", myEnv->nPageIn, myEnv->nPageOut,myEnv->nNewPageAdded);
  80011e:	a1 20 30 80 00       	mov    0x803020,%eax
  800123:	8b 88 98 da 01 00    	mov    0x1da98(%eax),%ecx
  800129:	a1 20 30 80 00       	mov    0x803020,%eax
  80012e:	8b 90 94 da 01 00    	mov    0x1da94(%eax),%edx
  800134:	a1 20 30 80 00       	mov    0x803020,%eax
  800139:	8b 80 90 da 01 00    	mov    0x1da90(%eax),%eax
  80013f:	51                   	push   %ecx
  800140:	52                   	push   %edx
  800141:	50                   	push   %eax
  800142:	68 44 1c 80 00       	push   $0x801c44
  800147:	e8 34 01 00 00       	call   800280 <cprintf>
  80014c:	83 c4 10             	add    $0x10,%esp
	//cprintf("Num of freeing scarce memory = %d, freeing full working set = %d\n", myEnv->freeingScarceMemCounter, myEnv->freeingFullWSCounter);
	cprintf("Num of clocks = %d\n", myEnv->nClocks);
  80014f:	a1 20 30 80 00       	mov    0x803020,%eax
  800154:	8b 80 9c da 01 00    	mov    0x1da9c(%eax),%eax
  80015a:	83 ec 08             	sub    $0x8,%esp
  80015d:	50                   	push   %eax
  80015e:	68 9c 1c 80 00       	push   $0x801c9c
  800163:	e8 18 01 00 00       	call   800280 <cprintf>
  800168:	83 c4 10             	add    $0x10,%esp
	cprintf("**************************************\n");
  80016b:	83 ec 0c             	sub    $0xc,%esp
  80016e:	68 f4 1b 80 00       	push   $0x801bf4
  800173:	e8 08 01 00 00       	call   800280 <cprintf>
  800178:	83 c4 10             	add    $0x10,%esp
	sys_enable_interrupt();
  80017b:	e8 c1 10 00 00       	call   801241 <sys_enable_interrupt>

	// exit gracefully
	exit();
  800180:	e8 19 00 00 00       	call   80019e <exit>
}
  800185:	90                   	nop
  800186:	c9                   	leave  
  800187:	c3                   	ret    

00800188 <destroy>:

#include <inc/lib.h>

void
destroy(void)
{
  800188:	55                   	push   %ebp
  800189:	89 e5                	mov    %esp,%ebp
  80018b:	83 ec 08             	sub    $0x8,%esp
	sys_destroy_env(0);
  80018e:	83 ec 0c             	sub    $0xc,%esp
  800191:	6a 00                	push   $0x0
  800193:	e8 4e 12 00 00       	call   8013e6 <sys_destroy_env>
  800198:	83 c4 10             	add    $0x10,%esp
}
  80019b:	90                   	nop
  80019c:	c9                   	leave  
  80019d:	c3                   	ret    

0080019e <exit>:

void
exit(void)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	83 ec 08             	sub    $0x8,%esp
	sys_exit_env();
  8001a4:	e8 a3 12 00 00       	call   80144c <sys_exit_env>
}
  8001a9:	90                   	nop
  8001aa:	c9                   	leave  
  8001ab:	c3                   	ret    

008001ac <putch>:
};

//2017:
uint8 printProgName = 0;

static void putch(int ch, struct printbuf *b) {
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	83 ec 08             	sub    $0x8,%esp
	b->buf[b->idx++] = ch;
  8001b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001b5:	8b 00                	mov    (%eax),%eax
  8001b7:	8d 48 01             	lea    0x1(%eax),%ecx
  8001ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001bd:	89 0a                	mov    %ecx,(%edx)
  8001bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c2:	88 d1                	mov    %dl,%cl
  8001c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c7:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256 - 1) {
  8001cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001ce:	8b 00                	mov    (%eax),%eax
  8001d0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001d5:	75 2c                	jne    800203 <putch+0x57>
		sys_cputs(b->buf, b->idx, printProgName);
  8001d7:	a0 24 30 80 00       	mov    0x803024,%al
  8001dc:	0f b6 c0             	movzbl %al,%eax
  8001df:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e2:	8b 12                	mov    (%edx),%edx
  8001e4:	89 d1                	mov    %edx,%ecx
  8001e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e9:	83 c2 08             	add    $0x8,%edx
  8001ec:	83 ec 04             	sub    $0x4,%esp
  8001ef:	50                   	push   %eax
  8001f0:	51                   	push   %ecx
  8001f1:	52                   	push   %edx
  8001f2:	e8 d7 0e 00 00       	call   8010ce <sys_cputs>
  8001f7:	83 c4 10             	add    $0x10,%esp
		b->idx = 0;
  8001fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001fd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800203:	8b 45 0c             	mov    0xc(%ebp),%eax
  800206:	8b 40 04             	mov    0x4(%eax),%eax
  800209:	8d 50 01             	lea    0x1(%eax),%edx
  80020c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80020f:	89 50 04             	mov    %edx,0x4(%eax)
}
  800212:	90                   	nop
  800213:	c9                   	leave  
  800214:	c3                   	ret    

00800215 <vcprintf>:

int vcprintf(const char *fmt, va_list ap) {
  800215:	55                   	push   %ebp
  800216:	89 e5                	mov    %esp,%ebp
  800218:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80021e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800225:	00 00 00 
	b.cnt = 0;
  800228:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80022f:	00 00 00 
	vprintfmt((void*) putch, &b, fmt, ap);
  800232:	ff 75 0c             	pushl  0xc(%ebp)
  800235:	ff 75 08             	pushl  0x8(%ebp)
  800238:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80023e:	50                   	push   %eax
  80023f:	68 ac 01 80 00       	push   $0x8001ac
  800244:	e8 11 02 00 00       	call   80045a <vprintfmt>
  800249:	83 c4 10             	add    $0x10,%esp
	sys_cputs(b.buf, b.idx, printProgName);
  80024c:	a0 24 30 80 00       	mov    0x803024,%al
  800251:	0f b6 c0             	movzbl %al,%eax
  800254:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
  80025a:	83 ec 04             	sub    $0x4,%esp
  80025d:	50                   	push   %eax
  80025e:	52                   	push   %edx
  80025f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800265:	83 c0 08             	add    $0x8,%eax
  800268:	50                   	push   %eax
  800269:	e8 60 0e 00 00       	call   8010ce <sys_cputs>
  80026e:	83 c4 10             	add    $0x10,%esp

	printProgName = 0;
  800271:	c6 05 24 30 80 00 00 	movb   $0x0,0x803024
	return b.cnt;
  800278:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  80027e:	c9                   	leave  
  80027f:	c3                   	ret    

00800280 <cprintf>:

int cprintf(const char *fmt, ...) {
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;
	printProgName = 1 ;
  800286:	c6 05 24 30 80 00 01 	movb   $0x1,0x803024
	va_start(ap, fmt);
  80028d:	8d 45 0c             	lea    0xc(%ebp),%eax
  800290:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cnt = vcprintf(fmt, ap);
  800293:	8b 45 08             	mov    0x8(%ebp),%eax
  800296:	83 ec 08             	sub    $0x8,%esp
  800299:	ff 75 f4             	pushl  -0xc(%ebp)
  80029c:	50                   	push   %eax
  80029d:	e8 73 ff ff ff       	call   800215 <vcprintf>
  8002a2:	83 c4 10             	add    $0x10,%esp
  8002a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
	va_end(ap);

	return cnt;
  8002a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  8002ab:	c9                   	leave  
  8002ac:	c3                   	ret    

008002ad <atomic_cprintf>:

int atomic_cprintf(const char *fmt, ...) {
  8002ad:	55                   	push   %ebp
  8002ae:	89 e5                	mov    %esp,%ebp
  8002b0:	83 ec 18             	sub    $0x18,%esp
	sys_disable_interrupt();
  8002b3:	e8 6f 0f 00 00       	call   801227 <sys_disable_interrupt>
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002b8:	8d 45 0c             	lea    0xc(%ebp),%eax
  8002bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cnt = vcprintf(fmt, ap);
  8002be:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c1:	83 ec 08             	sub    $0x8,%esp
  8002c4:	ff 75 f4             	pushl  -0xc(%ebp)
  8002c7:	50                   	push   %eax
  8002c8:	e8 48 ff ff ff       	call   800215 <vcprintf>
  8002cd:	83 c4 10             	add    $0x10,%esp
  8002d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
	va_end(ap);

	sys_enable_interrupt();
  8002d3:	e8 69 0f 00 00       	call   801241 <sys_enable_interrupt>
	return cnt;
  8002d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  8002db:	c9                   	leave  
  8002dc:	c3                   	ret    

008002dd <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002dd:	55                   	push   %ebp
  8002de:	89 e5                	mov    %esp,%ebp
  8002e0:	53                   	push   %ebx
  8002e1:	83 ec 14             	sub    $0x14,%esp
  8002e4:	8b 45 10             	mov    0x10(%ebp),%eax
  8002e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8002ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8002ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002f0:	8b 45 18             	mov    0x18(%ebp),%eax
  8002f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f8:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8002fb:	77 55                	ja     800352 <printnum+0x75>
  8002fd:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800300:	72 05                	jb     800307 <printnum+0x2a>
  800302:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800305:	77 4b                	ja     800352 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800307:	8b 45 1c             	mov    0x1c(%ebp),%eax
  80030a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80030d:	8b 45 18             	mov    0x18(%ebp),%eax
  800310:	ba 00 00 00 00       	mov    $0x0,%edx
  800315:	52                   	push   %edx
  800316:	50                   	push   %eax
  800317:	ff 75 f4             	pushl  -0xc(%ebp)
  80031a:	ff 75 f0             	pushl  -0x10(%ebp)
  80031d:	e8 0a 16 00 00       	call   80192c <__udivdi3>
  800322:	83 c4 10             	add    $0x10,%esp
  800325:	83 ec 04             	sub    $0x4,%esp
  800328:	ff 75 20             	pushl  0x20(%ebp)
  80032b:	53                   	push   %ebx
  80032c:	ff 75 18             	pushl  0x18(%ebp)
  80032f:	52                   	push   %edx
  800330:	50                   	push   %eax
  800331:	ff 75 0c             	pushl  0xc(%ebp)
  800334:	ff 75 08             	pushl  0x8(%ebp)
  800337:	e8 a1 ff ff ff       	call   8002dd <printnum>
  80033c:	83 c4 20             	add    $0x20,%esp
  80033f:	eb 1a                	jmp    80035b <printnum+0x7e>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800341:	83 ec 08             	sub    $0x8,%esp
  800344:	ff 75 0c             	pushl  0xc(%ebp)
  800347:	ff 75 20             	pushl  0x20(%ebp)
  80034a:	8b 45 08             	mov    0x8(%ebp),%eax
  80034d:	ff d0                	call   *%eax
  80034f:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800352:	ff 4d 1c             	decl   0x1c(%ebp)
  800355:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800359:	7f e6                	jg     800341 <printnum+0x64>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80035b:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80035e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800363:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800366:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800369:	53                   	push   %ebx
  80036a:	51                   	push   %ecx
  80036b:	52                   	push   %edx
  80036c:	50                   	push   %eax
  80036d:	e8 ca 16 00 00       	call   801a3c <__umoddi3>
  800372:	83 c4 10             	add    $0x10,%esp
  800375:	05 d4 1e 80 00       	add    $0x801ed4,%eax
  80037a:	8a 00                	mov    (%eax),%al
  80037c:	0f be c0             	movsbl %al,%eax
  80037f:	83 ec 08             	sub    $0x8,%esp
  800382:	ff 75 0c             	pushl  0xc(%ebp)
  800385:	50                   	push   %eax
  800386:	8b 45 08             	mov    0x8(%ebp),%eax
  800389:	ff d0                	call   *%eax
  80038b:	83 c4 10             	add    $0x10,%esp
}
  80038e:	90                   	nop
  80038f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800392:	c9                   	leave  
  800393:	c3                   	ret    

00800394 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800394:	55                   	push   %ebp
  800395:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800397:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80039b:	7e 1c                	jle    8003b9 <getuint+0x25>
		return va_arg(*ap, unsigned long long);
  80039d:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a0:	8b 00                	mov    (%eax),%eax
  8003a2:	8d 50 08             	lea    0x8(%eax),%edx
  8003a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a8:	89 10                	mov    %edx,(%eax)
  8003aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ad:	8b 00                	mov    (%eax),%eax
  8003af:	83 e8 08             	sub    $0x8,%eax
  8003b2:	8b 50 04             	mov    0x4(%eax),%edx
  8003b5:	8b 00                	mov    (%eax),%eax
  8003b7:	eb 40                	jmp    8003f9 <getuint+0x65>
	else if (lflag)
  8003b9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8003bd:	74 1e                	je     8003dd <getuint+0x49>
		return va_arg(*ap, unsigned long);
  8003bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c2:	8b 00                	mov    (%eax),%eax
  8003c4:	8d 50 04             	lea    0x4(%eax),%edx
  8003c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ca:	89 10                	mov    %edx,(%eax)
  8003cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8003cf:	8b 00                	mov    (%eax),%eax
  8003d1:	83 e8 04             	sub    $0x4,%eax
  8003d4:	8b 00                	mov    (%eax),%eax
  8003d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8003db:	eb 1c                	jmp    8003f9 <getuint+0x65>
	else
		return va_arg(*ap, unsigned int);
  8003dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e0:	8b 00                	mov    (%eax),%eax
  8003e2:	8d 50 04             	lea    0x4(%eax),%edx
  8003e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e8:	89 10                	mov    %edx,(%eax)
  8003ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ed:	8b 00                	mov    (%eax),%eax
  8003ef:	83 e8 04             	sub    $0x4,%eax
  8003f2:	8b 00                	mov    (%eax),%eax
  8003f4:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003f9:	5d                   	pop    %ebp
  8003fa:	c3                   	ret    

008003fb <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8003fb:	55                   	push   %ebp
  8003fc:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003fe:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800402:	7e 1c                	jle    800420 <getint+0x25>
		return va_arg(*ap, long long);
  800404:	8b 45 08             	mov    0x8(%ebp),%eax
  800407:	8b 00                	mov    (%eax),%eax
  800409:	8d 50 08             	lea    0x8(%eax),%edx
  80040c:	8b 45 08             	mov    0x8(%ebp),%eax
  80040f:	89 10                	mov    %edx,(%eax)
  800411:	8b 45 08             	mov    0x8(%ebp),%eax
  800414:	8b 00                	mov    (%eax),%eax
  800416:	83 e8 08             	sub    $0x8,%eax
  800419:	8b 50 04             	mov    0x4(%eax),%edx
  80041c:	8b 00                	mov    (%eax),%eax
  80041e:	eb 38                	jmp    800458 <getint+0x5d>
	else if (lflag)
  800420:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800424:	74 1a                	je     800440 <getint+0x45>
		return va_arg(*ap, long);
  800426:	8b 45 08             	mov    0x8(%ebp),%eax
  800429:	8b 00                	mov    (%eax),%eax
  80042b:	8d 50 04             	lea    0x4(%eax),%edx
  80042e:	8b 45 08             	mov    0x8(%ebp),%eax
  800431:	89 10                	mov    %edx,(%eax)
  800433:	8b 45 08             	mov    0x8(%ebp),%eax
  800436:	8b 00                	mov    (%eax),%eax
  800438:	83 e8 04             	sub    $0x4,%eax
  80043b:	8b 00                	mov    (%eax),%eax
  80043d:	99                   	cltd   
  80043e:	eb 18                	jmp    800458 <getint+0x5d>
	else
		return va_arg(*ap, int);
  800440:	8b 45 08             	mov    0x8(%ebp),%eax
  800443:	8b 00                	mov    (%eax),%eax
  800445:	8d 50 04             	lea    0x4(%eax),%edx
  800448:	8b 45 08             	mov    0x8(%ebp),%eax
  80044b:	89 10                	mov    %edx,(%eax)
  80044d:	8b 45 08             	mov    0x8(%ebp),%eax
  800450:	8b 00                	mov    (%eax),%eax
  800452:	83 e8 04             	sub    $0x4,%eax
  800455:	8b 00                	mov    (%eax),%eax
  800457:	99                   	cltd   
}
  800458:	5d                   	pop    %ebp
  800459:	c3                   	ret    

0080045a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80045a:	55                   	push   %ebp
  80045b:	89 e5                	mov    %esp,%ebp
  80045d:	56                   	push   %esi
  80045e:	53                   	push   %ebx
  80045f:	83 ec 20             	sub    $0x20,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800462:	eb 17                	jmp    80047b <vprintfmt+0x21>
			if (ch == '\0')
  800464:	85 db                	test   %ebx,%ebx
  800466:	0f 84 af 03 00 00    	je     80081b <vprintfmt+0x3c1>
				return;
			putch(ch, putdat);
  80046c:	83 ec 08             	sub    $0x8,%esp
  80046f:	ff 75 0c             	pushl  0xc(%ebp)
  800472:	53                   	push   %ebx
  800473:	8b 45 08             	mov    0x8(%ebp),%eax
  800476:	ff d0                	call   *%eax
  800478:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80047b:	8b 45 10             	mov    0x10(%ebp),%eax
  80047e:	8d 50 01             	lea    0x1(%eax),%edx
  800481:	89 55 10             	mov    %edx,0x10(%ebp)
  800484:	8a 00                	mov    (%eax),%al
  800486:	0f b6 d8             	movzbl %al,%ebx
  800489:	83 fb 25             	cmp    $0x25,%ebx
  80048c:	75 d6                	jne    800464 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  80048e:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  800492:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800499:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8004a0:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  8004a7:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ae:	8b 45 10             	mov    0x10(%ebp),%eax
  8004b1:	8d 50 01             	lea    0x1(%eax),%edx
  8004b4:	89 55 10             	mov    %edx,0x10(%ebp)
  8004b7:	8a 00                	mov    (%eax),%al
  8004b9:	0f b6 d8             	movzbl %al,%ebx
  8004bc:	8d 43 dd             	lea    -0x23(%ebx),%eax
  8004bf:	83 f8 55             	cmp    $0x55,%eax
  8004c2:	0f 87 2b 03 00 00    	ja     8007f3 <vprintfmt+0x399>
  8004c8:	8b 04 85 f8 1e 80 00 	mov    0x801ef8(,%eax,4),%eax
  8004cf:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  8004d1:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  8004d5:	eb d7                	jmp    8004ae <vprintfmt+0x54>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004d7:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  8004db:	eb d1                	jmp    8004ae <vprintfmt+0x54>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004dd:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8004e4:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004e7:	89 d0                	mov    %edx,%eax
  8004e9:	c1 e0 02             	shl    $0x2,%eax
  8004ec:	01 d0                	add    %edx,%eax
  8004ee:	01 c0                	add    %eax,%eax
  8004f0:	01 d8                	add    %ebx,%eax
  8004f2:	83 e8 30             	sub    $0x30,%eax
  8004f5:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8004f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8004fb:	8a 00                	mov    (%eax),%al
  8004fd:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  800500:	83 fb 2f             	cmp    $0x2f,%ebx
  800503:	7e 3e                	jle    800543 <vprintfmt+0xe9>
  800505:	83 fb 39             	cmp    $0x39,%ebx
  800508:	7f 39                	jg     800543 <vprintfmt+0xe9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80050a:	ff 45 10             	incl   0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80050d:	eb d5                	jmp    8004e4 <vprintfmt+0x8a>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80050f:	8b 45 14             	mov    0x14(%ebp),%eax
  800512:	83 c0 04             	add    $0x4,%eax
  800515:	89 45 14             	mov    %eax,0x14(%ebp)
  800518:	8b 45 14             	mov    0x14(%ebp),%eax
  80051b:	83 e8 04             	sub    $0x4,%eax
  80051e:	8b 00                	mov    (%eax),%eax
  800520:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  800523:	eb 1f                	jmp    800544 <vprintfmt+0xea>

		case '.':
			if (width < 0)
  800525:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800529:	79 83                	jns    8004ae <vprintfmt+0x54>
				width = 0;
  80052b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  800532:	e9 77 ff ff ff       	jmp    8004ae <vprintfmt+0x54>

		case '#':
			altflag = 1;
  800537:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80053e:	e9 6b ff ff ff       	jmp    8004ae <vprintfmt+0x54>
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
			goto process_precision;
  800543:	90                   	nop
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800544:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800548:	0f 89 60 ff ff ff    	jns    8004ae <vprintfmt+0x54>
				width = precision, precision = -1;
  80054e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800551:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800554:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  80055b:	e9 4e ff ff ff       	jmp    8004ae <vprintfmt+0x54>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800560:	ff 45 e8             	incl   -0x18(%ebp)
			goto reswitch;
  800563:	e9 46 ff ff ff       	jmp    8004ae <vprintfmt+0x54>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800568:	8b 45 14             	mov    0x14(%ebp),%eax
  80056b:	83 c0 04             	add    $0x4,%eax
  80056e:	89 45 14             	mov    %eax,0x14(%ebp)
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	83 e8 04             	sub    $0x4,%eax
  800577:	8b 00                	mov    (%eax),%eax
  800579:	83 ec 08             	sub    $0x8,%esp
  80057c:	ff 75 0c             	pushl  0xc(%ebp)
  80057f:	50                   	push   %eax
  800580:	8b 45 08             	mov    0x8(%ebp),%eax
  800583:	ff d0                	call   *%eax
  800585:	83 c4 10             	add    $0x10,%esp
			break;
  800588:	e9 89 02 00 00       	jmp    800816 <vprintfmt+0x3bc>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80058d:	8b 45 14             	mov    0x14(%ebp),%eax
  800590:	83 c0 04             	add    $0x4,%eax
  800593:	89 45 14             	mov    %eax,0x14(%ebp)
  800596:	8b 45 14             	mov    0x14(%ebp),%eax
  800599:	83 e8 04             	sub    $0x4,%eax
  80059c:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  80059e:	85 db                	test   %ebx,%ebx
  8005a0:	79 02                	jns    8005a4 <vprintfmt+0x14a>
				err = -err;
  8005a2:	f7 db                	neg    %ebx
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  8005a4:	83 fb 64             	cmp    $0x64,%ebx
  8005a7:	7f 0b                	jg     8005b4 <vprintfmt+0x15a>
  8005a9:	8b 34 9d 40 1d 80 00 	mov    0x801d40(,%ebx,4),%esi
  8005b0:	85 f6                	test   %esi,%esi
  8005b2:	75 19                	jne    8005cd <vprintfmt+0x173>
				printfmt(putch, putdat, "error %d", err);
  8005b4:	53                   	push   %ebx
  8005b5:	68 e5 1e 80 00       	push   $0x801ee5
  8005ba:	ff 75 0c             	pushl  0xc(%ebp)
  8005bd:	ff 75 08             	pushl  0x8(%ebp)
  8005c0:	e8 5e 02 00 00       	call   800823 <printfmt>
  8005c5:	83 c4 10             	add    $0x10,%esp
			else
				printfmt(putch, putdat, "%s", p);
			break;
  8005c8:	e9 49 02 00 00       	jmp    800816 <vprintfmt+0x3bc>
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8005cd:	56                   	push   %esi
  8005ce:	68 ee 1e 80 00       	push   $0x801eee
  8005d3:	ff 75 0c             	pushl  0xc(%ebp)
  8005d6:	ff 75 08             	pushl  0x8(%ebp)
  8005d9:	e8 45 02 00 00       	call   800823 <printfmt>
  8005de:	83 c4 10             	add    $0x10,%esp
			break;
  8005e1:	e9 30 02 00 00       	jmp    800816 <vprintfmt+0x3bc>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e9:	83 c0 04             	add    $0x4,%eax
  8005ec:	89 45 14             	mov    %eax,0x14(%ebp)
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	83 e8 04             	sub    $0x4,%eax
  8005f5:	8b 30                	mov    (%eax),%esi
  8005f7:	85 f6                	test   %esi,%esi
  8005f9:	75 05                	jne    800600 <vprintfmt+0x1a6>
				p = "(null)";
  8005fb:	be f1 1e 80 00       	mov    $0x801ef1,%esi
			if (width > 0 && padc != '-')
  800600:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800604:	7e 6d                	jle    800673 <vprintfmt+0x219>
  800606:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  80060a:	74 67                	je     800673 <vprintfmt+0x219>
				for (width -= strnlen(p, precision); width > 0; width--)
  80060c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80060f:	83 ec 08             	sub    $0x8,%esp
  800612:	50                   	push   %eax
  800613:	56                   	push   %esi
  800614:	e8 0c 03 00 00       	call   800925 <strnlen>
  800619:	83 c4 10             	add    $0x10,%esp
  80061c:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  80061f:	eb 16                	jmp    800637 <vprintfmt+0x1dd>
					putch(padc, putdat);
  800621:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800625:	83 ec 08             	sub    $0x8,%esp
  800628:	ff 75 0c             	pushl  0xc(%ebp)
  80062b:	50                   	push   %eax
  80062c:	8b 45 08             	mov    0x8(%ebp),%eax
  80062f:	ff d0                	call   *%eax
  800631:	83 c4 10             	add    $0x10,%esp
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800634:	ff 4d e4             	decl   -0x1c(%ebp)
  800637:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80063b:	7f e4                	jg     800621 <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80063d:	eb 34                	jmp    800673 <vprintfmt+0x219>
				if (altflag && (ch < ' ' || ch > '~'))
  80063f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800643:	74 1c                	je     800661 <vprintfmt+0x207>
  800645:	83 fb 1f             	cmp    $0x1f,%ebx
  800648:	7e 05                	jle    80064f <vprintfmt+0x1f5>
  80064a:	83 fb 7e             	cmp    $0x7e,%ebx
  80064d:	7e 12                	jle    800661 <vprintfmt+0x207>
					putch('?', putdat);
  80064f:	83 ec 08             	sub    $0x8,%esp
  800652:	ff 75 0c             	pushl  0xc(%ebp)
  800655:	6a 3f                	push   $0x3f
  800657:	8b 45 08             	mov    0x8(%ebp),%eax
  80065a:	ff d0                	call   *%eax
  80065c:	83 c4 10             	add    $0x10,%esp
  80065f:	eb 0f                	jmp    800670 <vprintfmt+0x216>
				else
					putch(ch, putdat);
  800661:	83 ec 08             	sub    $0x8,%esp
  800664:	ff 75 0c             	pushl  0xc(%ebp)
  800667:	53                   	push   %ebx
  800668:	8b 45 08             	mov    0x8(%ebp),%eax
  80066b:	ff d0                	call   *%eax
  80066d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800670:	ff 4d e4             	decl   -0x1c(%ebp)
  800673:	89 f0                	mov    %esi,%eax
  800675:	8d 70 01             	lea    0x1(%eax),%esi
  800678:	8a 00                	mov    (%eax),%al
  80067a:	0f be d8             	movsbl %al,%ebx
  80067d:	85 db                	test   %ebx,%ebx
  80067f:	74 24                	je     8006a5 <vprintfmt+0x24b>
  800681:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800685:	78 b8                	js     80063f <vprintfmt+0x1e5>
  800687:	ff 4d e0             	decl   -0x20(%ebp)
  80068a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80068e:	79 af                	jns    80063f <vprintfmt+0x1e5>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800690:	eb 13                	jmp    8006a5 <vprintfmt+0x24b>
				putch(' ', putdat);
  800692:	83 ec 08             	sub    $0x8,%esp
  800695:	ff 75 0c             	pushl  0xc(%ebp)
  800698:	6a 20                	push   $0x20
  80069a:	8b 45 08             	mov    0x8(%ebp),%eax
  80069d:	ff d0                	call   *%eax
  80069f:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006a2:	ff 4d e4             	decl   -0x1c(%ebp)
  8006a5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006a9:	7f e7                	jg     800692 <vprintfmt+0x238>
				putch(' ', putdat);
			break;
  8006ab:	e9 66 01 00 00       	jmp    800816 <vprintfmt+0x3bc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006b0:	83 ec 08             	sub    $0x8,%esp
  8006b3:	ff 75 e8             	pushl  -0x18(%ebp)
  8006b6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b9:	50                   	push   %eax
  8006ba:	e8 3c fd ff ff       	call   8003fb <getint>
  8006bf:	83 c4 10             	add    $0x10,%esp
  8006c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006c5:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  8006c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006ce:	85 d2                	test   %edx,%edx
  8006d0:	79 23                	jns    8006f5 <vprintfmt+0x29b>
				putch('-', putdat);
  8006d2:	83 ec 08             	sub    $0x8,%esp
  8006d5:	ff 75 0c             	pushl  0xc(%ebp)
  8006d8:	6a 2d                	push   $0x2d
  8006da:	8b 45 08             	mov    0x8(%ebp),%eax
  8006dd:	ff d0                	call   *%eax
  8006df:	83 c4 10             	add    $0x10,%esp
				num = -(long long) num;
  8006e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006e8:	f7 d8                	neg    %eax
  8006ea:	83 d2 00             	adc    $0x0,%edx
  8006ed:	f7 da                	neg    %edx
  8006ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006f2:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  8006f5:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8006fc:	e9 bc 00 00 00       	jmp    8007bd <vprintfmt+0x363>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800701:	83 ec 08             	sub    $0x8,%esp
  800704:	ff 75 e8             	pushl  -0x18(%ebp)
  800707:	8d 45 14             	lea    0x14(%ebp),%eax
  80070a:	50                   	push   %eax
  80070b:	e8 84 fc ff ff       	call   800394 <getuint>
  800710:	83 c4 10             	add    $0x10,%esp
  800713:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800716:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800719:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800720:	e9 98 00 00 00       	jmp    8007bd <vprintfmt+0x363>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800725:	83 ec 08             	sub    $0x8,%esp
  800728:	ff 75 0c             	pushl  0xc(%ebp)
  80072b:	6a 58                	push   $0x58
  80072d:	8b 45 08             	mov    0x8(%ebp),%eax
  800730:	ff d0                	call   *%eax
  800732:	83 c4 10             	add    $0x10,%esp
			putch('X', putdat);
  800735:	83 ec 08             	sub    $0x8,%esp
  800738:	ff 75 0c             	pushl  0xc(%ebp)
  80073b:	6a 58                	push   $0x58
  80073d:	8b 45 08             	mov    0x8(%ebp),%eax
  800740:	ff d0                	call   *%eax
  800742:	83 c4 10             	add    $0x10,%esp
			putch('X', putdat);
  800745:	83 ec 08             	sub    $0x8,%esp
  800748:	ff 75 0c             	pushl  0xc(%ebp)
  80074b:	6a 58                	push   $0x58
  80074d:	8b 45 08             	mov    0x8(%ebp),%eax
  800750:	ff d0                	call   *%eax
  800752:	83 c4 10             	add    $0x10,%esp
			break;
  800755:	e9 bc 00 00 00       	jmp    800816 <vprintfmt+0x3bc>

		// pointer
		case 'p':
			putch('0', putdat);
  80075a:	83 ec 08             	sub    $0x8,%esp
  80075d:	ff 75 0c             	pushl  0xc(%ebp)
  800760:	6a 30                	push   $0x30
  800762:	8b 45 08             	mov    0x8(%ebp),%eax
  800765:	ff d0                	call   *%eax
  800767:	83 c4 10             	add    $0x10,%esp
			putch('x', putdat);
  80076a:	83 ec 08             	sub    $0x8,%esp
  80076d:	ff 75 0c             	pushl  0xc(%ebp)
  800770:	6a 78                	push   $0x78
  800772:	8b 45 08             	mov    0x8(%ebp),%eax
  800775:	ff d0                	call   *%eax
  800777:	83 c4 10             	add    $0x10,%esp
			num = (unsigned long long)
				(uint32) va_arg(ap, void *);
  80077a:	8b 45 14             	mov    0x14(%ebp),%eax
  80077d:	83 c0 04             	add    $0x4,%eax
  800780:	89 45 14             	mov    %eax,0x14(%ebp)
  800783:	8b 45 14             	mov    0x14(%ebp),%eax
  800786:	83 e8 04             	sub    $0x4,%eax
  800789:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80078b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80078e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uint32) va_arg(ap, void *);
			base = 16;
  800795:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  80079c:	eb 1f                	jmp    8007bd <vprintfmt+0x363>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80079e:	83 ec 08             	sub    $0x8,%esp
  8007a1:	ff 75 e8             	pushl  -0x18(%ebp)
  8007a4:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a7:	50                   	push   %eax
  8007a8:	e8 e7 fb ff ff       	call   800394 <getuint>
  8007ad:	83 c4 10             	add    $0x10,%esp
  8007b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007b3:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  8007b6:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007bd:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  8007c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007c4:	83 ec 04             	sub    $0x4,%esp
  8007c7:	52                   	push   %edx
  8007c8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007cb:	50                   	push   %eax
  8007cc:	ff 75 f4             	pushl  -0xc(%ebp)
  8007cf:	ff 75 f0             	pushl  -0x10(%ebp)
  8007d2:	ff 75 0c             	pushl  0xc(%ebp)
  8007d5:	ff 75 08             	pushl  0x8(%ebp)
  8007d8:	e8 00 fb ff ff       	call   8002dd <printnum>
  8007dd:	83 c4 20             	add    $0x20,%esp
			break;
  8007e0:	eb 34                	jmp    800816 <vprintfmt+0x3bc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007e2:	83 ec 08             	sub    $0x8,%esp
  8007e5:	ff 75 0c             	pushl  0xc(%ebp)
  8007e8:	53                   	push   %ebx
  8007e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ec:	ff d0                	call   *%eax
  8007ee:	83 c4 10             	add    $0x10,%esp
			break;
  8007f1:	eb 23                	jmp    800816 <vprintfmt+0x3bc>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007f3:	83 ec 08             	sub    $0x8,%esp
  8007f6:	ff 75 0c             	pushl  0xc(%ebp)
  8007f9:	6a 25                	push   $0x25
  8007fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fe:	ff d0                	call   *%eax
  800800:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  800803:	ff 4d 10             	decl   0x10(%ebp)
  800806:	eb 03                	jmp    80080b <vprintfmt+0x3b1>
  800808:	ff 4d 10             	decl   0x10(%ebp)
  80080b:	8b 45 10             	mov    0x10(%ebp),%eax
  80080e:	48                   	dec    %eax
  80080f:	8a 00                	mov    (%eax),%al
  800811:	3c 25                	cmp    $0x25,%al
  800813:	75 f3                	jne    800808 <vprintfmt+0x3ae>
				/* do nothing */;
			break;
  800815:	90                   	nop
		}
	}
  800816:	e9 47 fc ff ff       	jmp    800462 <vprintfmt+0x8>
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
  80081b:	90                   	nop
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80081c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80081f:	5b                   	pop    %ebx
  800820:	5e                   	pop    %esi
  800821:	5d                   	pop    %ebp
  800822:	c3                   	ret    

00800823 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800829:	8d 45 10             	lea    0x10(%ebp),%eax
  80082c:	83 c0 04             	add    $0x4,%eax
  80082f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800832:	8b 45 10             	mov    0x10(%ebp),%eax
  800835:	ff 75 f4             	pushl  -0xc(%ebp)
  800838:	50                   	push   %eax
  800839:	ff 75 0c             	pushl  0xc(%ebp)
  80083c:	ff 75 08             	pushl  0x8(%ebp)
  80083f:	e8 16 fc ff ff       	call   80045a <vprintfmt>
  800844:	83 c4 10             	add    $0x10,%esp
	va_end(ap);
}
  800847:	90                   	nop
  800848:	c9                   	leave  
  800849:	c3                   	ret    

0080084a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80084a:	55                   	push   %ebp
  80084b:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  80084d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800850:	8b 40 08             	mov    0x8(%eax),%eax
  800853:	8d 50 01             	lea    0x1(%eax),%edx
  800856:	8b 45 0c             	mov    0xc(%ebp),%eax
  800859:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  80085c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80085f:	8b 10                	mov    (%eax),%edx
  800861:	8b 45 0c             	mov    0xc(%ebp),%eax
  800864:	8b 40 04             	mov    0x4(%eax),%eax
  800867:	39 c2                	cmp    %eax,%edx
  800869:	73 12                	jae    80087d <sprintputch+0x33>
		*b->buf++ = ch;
  80086b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80086e:	8b 00                	mov    (%eax),%eax
  800870:	8d 48 01             	lea    0x1(%eax),%ecx
  800873:	8b 55 0c             	mov    0xc(%ebp),%edx
  800876:	89 0a                	mov    %ecx,(%edx)
  800878:	8b 55 08             	mov    0x8(%ebp),%edx
  80087b:	88 10                	mov    %dl,(%eax)
}
  80087d:	90                   	nop
  80087e:	5d                   	pop    %ebp
  80087f:	c3                   	ret    

00800880 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	83 ec 18             	sub    $0x18,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800886:	8b 45 08             	mov    0x8(%ebp),%eax
  800889:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80088c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80088f:	8d 50 ff             	lea    -0x1(%eax),%edx
  800892:	8b 45 08             	mov    0x8(%ebp),%eax
  800895:	01 d0                	add    %edx,%eax
  800897:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80089a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008a1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8008a5:	74 06                	je     8008ad <vsnprintf+0x2d>
  8008a7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8008ab:	7f 07                	jg     8008b4 <vsnprintf+0x34>
		return -E_INVAL;
  8008ad:	b8 03 00 00 00       	mov    $0x3,%eax
  8008b2:	eb 20                	jmp    8008d4 <vsnprintf+0x54>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008b4:	ff 75 14             	pushl  0x14(%ebp)
  8008b7:	ff 75 10             	pushl  0x10(%ebp)
  8008ba:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008bd:	50                   	push   %eax
  8008be:	68 4a 08 80 00       	push   $0x80084a
  8008c3:	e8 92 fb ff ff       	call   80045a <vprintfmt>
  8008c8:	83 c4 10             	add    $0x10,%esp

	// null terminate the buffer
	*b.buf = '\0';
  8008cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008ce:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8008d4:	c9                   	leave  
  8008d5:	c3                   	ret    

008008d6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008d6:	55                   	push   %ebp
  8008d7:	89 e5                	mov    %esp,%ebp
  8008d9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008dc:	8d 45 10             	lea    0x10(%ebp),%eax
  8008df:	83 c0 04             	add    $0x4,%eax
  8008e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8008e5:	8b 45 10             	mov    0x10(%ebp),%eax
  8008e8:	ff 75 f4             	pushl  -0xc(%ebp)
  8008eb:	50                   	push   %eax
  8008ec:	ff 75 0c             	pushl  0xc(%ebp)
  8008ef:	ff 75 08             	pushl  0x8(%ebp)
  8008f2:	e8 89 ff ff ff       	call   800880 <vsnprintf>
  8008f7:	83 c4 10             	add    $0x10,%esp
  8008fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
	va_end(ap);

	return rc;
  8008fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  800900:	c9                   	leave  
  800901:	c3                   	ret    

00800902 <strlen>:

#include <inc/string.h>
#include <inc/assert.h>
int
strlen(const char *s)
{
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800908:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80090f:	eb 06                	jmp    800917 <strlen+0x15>
		n++;
  800911:	ff 45 fc             	incl   -0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800914:	ff 45 08             	incl   0x8(%ebp)
  800917:	8b 45 08             	mov    0x8(%ebp),%eax
  80091a:	8a 00                	mov    (%eax),%al
  80091c:	84 c0                	test   %al,%al
  80091e:	75 f1                	jne    800911 <strlen+0xf>
		n++;
	return n;
  800920:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800923:	c9                   	leave  
  800924:	c3                   	ret    

00800925 <strnlen>:

int
strnlen(const char *s, uint32 size)
{
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80092b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800932:	eb 09                	jmp    80093d <strnlen+0x18>
		n++;
  800934:	ff 45 fc             	incl   -0x4(%ebp)
int
strnlen(const char *s, uint32 size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800937:	ff 45 08             	incl   0x8(%ebp)
  80093a:	ff 4d 0c             	decl   0xc(%ebp)
  80093d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800941:	74 09                	je     80094c <strnlen+0x27>
  800943:	8b 45 08             	mov    0x8(%ebp),%eax
  800946:	8a 00                	mov    (%eax),%al
  800948:	84 c0                	test   %al,%al
  80094a:	75 e8                	jne    800934 <strnlen+0xf>
		n++;
	return n;
  80094c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80094f:	c9                   	leave  
  800950:	c3                   	ret    

00800951 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800957:	8b 45 08             	mov    0x8(%ebp),%eax
  80095a:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  80095d:	90                   	nop
  80095e:	8b 45 08             	mov    0x8(%ebp),%eax
  800961:	8d 50 01             	lea    0x1(%eax),%edx
  800964:	89 55 08             	mov    %edx,0x8(%ebp)
  800967:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80096d:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800970:	8a 12                	mov    (%edx),%dl
  800972:	88 10                	mov    %dl,(%eax)
  800974:	8a 00                	mov    (%eax),%al
  800976:	84 c0                	test   %al,%al
  800978:	75 e4                	jne    80095e <strcpy+0xd>
		/* do nothing */;
	return ret;
  80097a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80097d:	c9                   	leave  
  80097e:	c3                   	ret    

0080097f <strncpy>:

char *
strncpy(char *dst, const char *src, uint32 size) {
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	83 ec 10             	sub    $0x10,%esp
	uint32 i;
	char *ret;

	ret = dst;
  800985:	8b 45 08             	mov    0x8(%ebp),%eax
  800988:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  80098b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800992:	eb 1f                	jmp    8009b3 <strncpy+0x34>
		*dst++ = *src;
  800994:	8b 45 08             	mov    0x8(%ebp),%eax
  800997:	8d 50 01             	lea    0x1(%eax),%edx
  80099a:	89 55 08             	mov    %edx,0x8(%ebp)
  80099d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a0:	8a 12                	mov    (%edx),%dl
  8009a2:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  8009a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a7:	8a 00                	mov    (%eax),%al
  8009a9:	84 c0                	test   %al,%al
  8009ab:	74 03                	je     8009b0 <strncpy+0x31>
			src++;
  8009ad:	ff 45 0c             	incl   0xc(%ebp)
strncpy(char *dst, const char *src, uint32 size) {
	uint32 i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009b0:	ff 45 fc             	incl   -0x4(%ebp)
  8009b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8009b6:	3b 45 10             	cmp    0x10(%ebp),%eax
  8009b9:	72 d9                	jb     800994 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  8009bb:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  8009be:	c9                   	leave  
  8009bf:	c3                   	ret    

008009c0 <strlcpy>:

uint32
strlcpy(char *dst, const char *src, uint32 size)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  8009c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c9:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  8009cc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009d0:	74 30                	je     800a02 <strlcpy+0x42>
		while (--size > 0 && *src != '\0')
  8009d2:	eb 16                	jmp    8009ea <strlcpy+0x2a>
			*dst++ = *src++;
  8009d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d7:	8d 50 01             	lea    0x1(%eax),%edx
  8009da:	89 55 08             	mov    %edx,0x8(%ebp)
  8009dd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009e0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8009e3:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  8009e6:	8a 12                	mov    (%edx),%dl
  8009e8:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009ea:	ff 4d 10             	decl   0x10(%ebp)
  8009ed:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009f1:	74 09                	je     8009fc <strlcpy+0x3c>
  8009f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f6:	8a 00                	mov    (%eax),%al
  8009f8:	84 c0                	test   %al,%al
  8009fa:	75 d8                	jne    8009d4 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  8009fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ff:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a02:	8b 55 08             	mov    0x8(%ebp),%edx
  800a05:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a08:	29 c2                	sub    %eax,%edx
  800a0a:	89 d0                	mov    %edx,%eax
}
  800a0c:	c9                   	leave  
  800a0d:	c3                   	ret    

00800a0e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800a11:	eb 06                	jmp    800a19 <strcmp+0xb>
		p++, q++;
  800a13:	ff 45 08             	incl   0x8(%ebp)
  800a16:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a19:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1c:	8a 00                	mov    (%eax),%al
  800a1e:	84 c0                	test   %al,%al
  800a20:	74 0e                	je     800a30 <strcmp+0x22>
  800a22:	8b 45 08             	mov    0x8(%ebp),%eax
  800a25:	8a 10                	mov    (%eax),%dl
  800a27:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a2a:	8a 00                	mov    (%eax),%al
  800a2c:	38 c2                	cmp    %al,%dl
  800a2e:	74 e3                	je     800a13 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a30:	8b 45 08             	mov    0x8(%ebp),%eax
  800a33:	8a 00                	mov    (%eax),%al
  800a35:	0f b6 d0             	movzbl %al,%edx
  800a38:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3b:	8a 00                	mov    (%eax),%al
  800a3d:	0f b6 c0             	movzbl %al,%eax
  800a40:	29 c2                	sub    %eax,%edx
  800a42:	89 d0                	mov    %edx,%eax
}
  800a44:	5d                   	pop    %ebp
  800a45:	c3                   	ret    

00800a46 <strncmp>:

int
strncmp(const char *p, const char *q, uint32 n)
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800a49:	eb 09                	jmp    800a54 <strncmp+0xe>
		n--, p++, q++;
  800a4b:	ff 4d 10             	decl   0x10(%ebp)
  800a4e:	ff 45 08             	incl   0x8(%ebp)
  800a51:	ff 45 0c             	incl   0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint32 n)
{
	while (n > 0 && *p && *p == *q)
  800a54:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a58:	74 17                	je     800a71 <strncmp+0x2b>
  800a5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5d:	8a 00                	mov    (%eax),%al
  800a5f:	84 c0                	test   %al,%al
  800a61:	74 0e                	je     800a71 <strncmp+0x2b>
  800a63:	8b 45 08             	mov    0x8(%ebp),%eax
  800a66:	8a 10                	mov    (%eax),%dl
  800a68:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6b:	8a 00                	mov    (%eax),%al
  800a6d:	38 c2                	cmp    %al,%dl
  800a6f:	74 da                	je     800a4b <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800a71:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a75:	75 07                	jne    800a7e <strncmp+0x38>
		return 0;
  800a77:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7c:	eb 14                	jmp    800a92 <strncmp+0x4c>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a81:	8a 00                	mov    (%eax),%al
  800a83:	0f b6 d0             	movzbl %al,%edx
  800a86:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a89:	8a 00                	mov    (%eax),%al
  800a8b:	0f b6 c0             	movzbl %al,%eax
  800a8e:	29 c2                	sub    %eax,%edx
  800a90:	89 d0                	mov    %edx,%eax
}
  800a92:	5d                   	pop    %ebp
  800a93:	c3                   	ret    

00800a94 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a94:	55                   	push   %ebp
  800a95:	89 e5                	mov    %esp,%ebp
  800a97:	83 ec 04             	sub    $0x4,%esp
  800a9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9d:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800aa0:	eb 12                	jmp    800ab4 <strchr+0x20>
		if (*s == c)
  800aa2:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa5:	8a 00                	mov    (%eax),%al
  800aa7:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800aaa:	75 05                	jne    800ab1 <strchr+0x1d>
			return (char *) s;
  800aac:	8b 45 08             	mov    0x8(%ebp),%eax
  800aaf:	eb 11                	jmp    800ac2 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ab1:	ff 45 08             	incl   0x8(%ebp)
  800ab4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab7:	8a 00                	mov    (%eax),%al
  800ab9:	84 c0                	test   %al,%al
  800abb:	75 e5                	jne    800aa2 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800abd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ac2:	c9                   	leave  
  800ac3:	c3                   	ret    

00800ac4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	83 ec 04             	sub    $0x4,%esp
  800aca:	8b 45 0c             	mov    0xc(%ebp),%eax
  800acd:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800ad0:	eb 0d                	jmp    800adf <strfind+0x1b>
		if (*s == c)
  800ad2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad5:	8a 00                	mov    (%eax),%al
  800ad7:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800ada:	74 0e                	je     800aea <strfind+0x26>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800adc:	ff 45 08             	incl   0x8(%ebp)
  800adf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae2:	8a 00                	mov    (%eax),%al
  800ae4:	84 c0                	test   %al,%al
  800ae6:	75 ea                	jne    800ad2 <strfind+0xe>
  800ae8:	eb 01                	jmp    800aeb <strfind+0x27>
		if (*s == c)
			break;
  800aea:	90                   	nop
	return (char *) s;
  800aeb:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800aee:	c9                   	leave  
  800aef:	c3                   	ret    

00800af0 <memset>:


void *
memset(void *v, int c, uint32 n)
{
  800af0:	55                   	push   %ebp
  800af1:	89 e5                	mov    %esp,%ebp
  800af3:	83 ec 10             	sub    $0x10,%esp
	char *p;
	int m;

	p = v;
  800af6:	8b 45 08             	mov    0x8(%ebp),%eax
  800af9:	89 45 fc             	mov    %eax,-0x4(%ebp)
	m = n;
  800afc:	8b 45 10             	mov    0x10(%ebp),%eax
  800aff:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (--m >= 0)
  800b02:	eb 0e                	jmp    800b12 <memset+0x22>
		*p++ = c;
  800b04:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800b07:	8d 50 01             	lea    0x1(%eax),%edx
  800b0a:	89 55 fc             	mov    %edx,-0x4(%ebp)
  800b0d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b10:	88 10                	mov    %dl,(%eax)
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800b12:	ff 4d f8             	decl   -0x8(%ebp)
  800b15:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
  800b19:	79 e9                	jns    800b04 <memset+0x14>
		*p++ = c;

	return v;
  800b1b:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b1e:	c9                   	leave  
  800b1f:	c3                   	ret    

00800b20 <memcpy>:

void *
memcpy(void *dst, const void *src, uint32 n)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800b26:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b29:	89 45 fc             	mov    %eax,-0x4(%ebp)
	d = dst;
  800b2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2f:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (n-- > 0)
  800b32:	eb 16                	jmp    800b4a <memcpy+0x2a>
		*d++ = *s++;
  800b34:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800b37:	8d 50 01             	lea    0x1(%eax),%edx
  800b3a:	89 55 f8             	mov    %edx,-0x8(%ebp)
  800b3d:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800b40:	8d 4a 01             	lea    0x1(%edx),%ecx
  800b43:	89 4d fc             	mov    %ecx,-0x4(%ebp)
  800b46:	8a 12                	mov    (%edx),%dl
  800b48:	88 10                	mov    %dl,(%eax)
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
  800b4a:	8b 45 10             	mov    0x10(%ebp),%eax
  800b4d:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b50:	89 55 10             	mov    %edx,0x10(%ebp)
  800b53:	85 c0                	test   %eax,%eax
  800b55:	75 dd                	jne    800b34 <memcpy+0x14>
		*d++ = *s++;

	return dst;
  800b57:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b5a:	c9                   	leave  
  800b5b:	c3                   	ret    

00800b5c <memmove>:

void *
memmove(void *dst, const void *src, uint32 n)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800b62:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b65:	89 45 fc             	mov    %eax,-0x4(%ebp)
	d = dst;
  800b68:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6b:	89 45 f8             	mov    %eax,-0x8(%ebp)
	if (s < d && s + n > d) {
  800b6e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800b71:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  800b74:	73 50                	jae    800bc6 <memmove+0x6a>
  800b76:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800b79:	8b 45 10             	mov    0x10(%ebp),%eax
  800b7c:	01 d0                	add    %edx,%eax
  800b7e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  800b81:	76 43                	jbe    800bc6 <memmove+0x6a>
		s += n;
  800b83:	8b 45 10             	mov    0x10(%ebp),%eax
  800b86:	01 45 fc             	add    %eax,-0x4(%ebp)
		d += n;
  800b89:	8b 45 10             	mov    0x10(%ebp),%eax
  800b8c:	01 45 f8             	add    %eax,-0x8(%ebp)
		while (n-- > 0)
  800b8f:	eb 10                	jmp    800ba1 <memmove+0x45>
			*--d = *--s;
  800b91:	ff 4d f8             	decl   -0x8(%ebp)
  800b94:	ff 4d fc             	decl   -0x4(%ebp)
  800b97:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800b9a:	8a 10                	mov    (%eax),%dl
  800b9c:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800b9f:	88 10                	mov    %dl,(%eax)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  800ba1:	8b 45 10             	mov    0x10(%ebp),%eax
  800ba4:	8d 50 ff             	lea    -0x1(%eax),%edx
  800ba7:	89 55 10             	mov    %edx,0x10(%ebp)
  800baa:	85 c0                	test   %eax,%eax
  800bac:	75 e3                	jne    800b91 <memmove+0x35>
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bae:	eb 23                	jmp    800bd3 <memmove+0x77>
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  800bb0:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800bb3:	8d 50 01             	lea    0x1(%eax),%edx
  800bb6:	89 55 f8             	mov    %edx,-0x8(%ebp)
  800bb9:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800bbc:	8d 4a 01             	lea    0x1(%edx),%ecx
  800bbf:	89 4d fc             	mov    %ecx,-0x4(%ebp)
  800bc2:	8a 12                	mov    (%edx),%dl
  800bc4:	88 10                	mov    %dl,(%eax)
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800bc6:	8b 45 10             	mov    0x10(%ebp),%eax
  800bc9:	8d 50 ff             	lea    -0x1(%eax),%edx
  800bcc:	89 55 10             	mov    %edx,0x10(%ebp)
  800bcf:	85 c0                	test   %eax,%eax
  800bd1:	75 dd                	jne    800bb0 <memmove+0x54>
			*d++ = *s++;

	return dst;
  800bd3:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800bd6:	c9                   	leave  
  800bd7:	c3                   	ret    

00800bd8 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint32 n)
{
  800bd8:	55                   	push   %ebp
  800bd9:	89 e5                	mov    %esp,%ebp
  800bdb:	83 ec 10             	sub    $0x10,%esp
	const uint8 *s1 = (const uint8 *) v1;
  800bde:	8b 45 08             	mov    0x8(%ebp),%eax
  800be1:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8 *s2 = (const uint8 *) v2;
  800be4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be7:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800bea:	eb 2a                	jmp    800c16 <memcmp+0x3e>
		if (*s1 != *s2)
  800bec:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bef:	8a 10                	mov    (%eax),%dl
  800bf1:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800bf4:	8a 00                	mov    (%eax),%al
  800bf6:	38 c2                	cmp    %al,%dl
  800bf8:	74 16                	je     800c10 <memcmp+0x38>
			return (int) *s1 - (int) *s2;
  800bfa:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bfd:	8a 00                	mov    (%eax),%al
  800bff:	0f b6 d0             	movzbl %al,%edx
  800c02:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c05:	8a 00                	mov    (%eax),%al
  800c07:	0f b6 c0             	movzbl %al,%eax
  800c0a:	29 c2                	sub    %eax,%edx
  800c0c:	89 d0                	mov    %edx,%eax
  800c0e:	eb 18                	jmp    800c28 <memcmp+0x50>
		s1++, s2++;
  800c10:	ff 45 fc             	incl   -0x4(%ebp)
  800c13:	ff 45 f8             	incl   -0x8(%ebp)
memcmp(const void *v1, const void *v2, uint32 n)
{
	const uint8 *s1 = (const uint8 *) v1;
	const uint8 *s2 = (const uint8 *) v2;

	while (n-- > 0) {
  800c16:	8b 45 10             	mov    0x10(%ebp),%eax
  800c19:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c1c:	89 55 10             	mov    %edx,0x10(%ebp)
  800c1f:	85 c0                	test   %eax,%eax
  800c21:	75 c9                	jne    800bec <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c23:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c28:	c9                   	leave  
  800c29:	c3                   	ret    

00800c2a <memfind>:

void *
memfind(const void *s, int c, uint32 n)
{
  800c2a:	55                   	push   %ebp
  800c2b:	89 e5                	mov    %esp,%ebp
  800c2d:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800c30:	8b 55 08             	mov    0x8(%ebp),%edx
  800c33:	8b 45 10             	mov    0x10(%ebp),%eax
  800c36:	01 d0                	add    %edx,%eax
  800c38:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800c3b:	eb 15                	jmp    800c52 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c40:	8a 00                	mov    (%eax),%al
  800c42:	0f b6 d0             	movzbl %al,%edx
  800c45:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c48:	0f b6 c0             	movzbl %al,%eax
  800c4b:	39 c2                	cmp    %eax,%edx
  800c4d:	74 0d                	je     800c5c <memfind+0x32>

void *
memfind(const void *s, int c, uint32 n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c4f:	ff 45 08             	incl   0x8(%ebp)
  800c52:	8b 45 08             	mov    0x8(%ebp),%eax
  800c55:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800c58:	72 e3                	jb     800c3d <memfind+0x13>
  800c5a:	eb 01                	jmp    800c5d <memfind+0x33>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
  800c5c:	90                   	nop
	return (void *) s;
  800c5d:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c60:	c9                   	leave  
  800c61:	c3                   	ret    

00800c62 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c62:	55                   	push   %ebp
  800c63:	89 e5                	mov    %esp,%ebp
  800c65:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800c68:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800c6f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c76:	eb 03                	jmp    800c7b <strtol+0x19>
		s++;
  800c78:	ff 45 08             	incl   0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7e:	8a 00                	mov    (%eax),%al
  800c80:	3c 20                	cmp    $0x20,%al
  800c82:	74 f4                	je     800c78 <strtol+0x16>
  800c84:	8b 45 08             	mov    0x8(%ebp),%eax
  800c87:	8a 00                	mov    (%eax),%al
  800c89:	3c 09                	cmp    $0x9,%al
  800c8b:	74 eb                	je     800c78 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c90:	8a 00                	mov    (%eax),%al
  800c92:	3c 2b                	cmp    $0x2b,%al
  800c94:	75 05                	jne    800c9b <strtol+0x39>
		s++;
  800c96:	ff 45 08             	incl   0x8(%ebp)
  800c99:	eb 13                	jmp    800cae <strtol+0x4c>
	else if (*s == '-')
  800c9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9e:	8a 00                	mov    (%eax),%al
  800ca0:	3c 2d                	cmp    $0x2d,%al
  800ca2:	75 0a                	jne    800cae <strtol+0x4c>
		s++, neg = 1;
  800ca4:	ff 45 08             	incl   0x8(%ebp)
  800ca7:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cae:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cb2:	74 06                	je     800cba <strtol+0x58>
  800cb4:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800cb8:	75 20                	jne    800cda <strtol+0x78>
  800cba:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbd:	8a 00                	mov    (%eax),%al
  800cbf:	3c 30                	cmp    $0x30,%al
  800cc1:	75 17                	jne    800cda <strtol+0x78>
  800cc3:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc6:	40                   	inc    %eax
  800cc7:	8a 00                	mov    (%eax),%al
  800cc9:	3c 78                	cmp    $0x78,%al
  800ccb:	75 0d                	jne    800cda <strtol+0x78>
		s += 2, base = 16;
  800ccd:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800cd1:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800cd8:	eb 28                	jmp    800d02 <strtol+0xa0>
	else if (base == 0 && s[0] == '0')
  800cda:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cde:	75 15                	jne    800cf5 <strtol+0x93>
  800ce0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce3:	8a 00                	mov    (%eax),%al
  800ce5:	3c 30                	cmp    $0x30,%al
  800ce7:	75 0c                	jne    800cf5 <strtol+0x93>
		s++, base = 8;
  800ce9:	ff 45 08             	incl   0x8(%ebp)
  800cec:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800cf3:	eb 0d                	jmp    800d02 <strtol+0xa0>
	else if (base == 0)
  800cf5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cf9:	75 07                	jne    800d02 <strtol+0xa0>
		base = 10;
  800cfb:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d02:	8b 45 08             	mov    0x8(%ebp),%eax
  800d05:	8a 00                	mov    (%eax),%al
  800d07:	3c 2f                	cmp    $0x2f,%al
  800d09:	7e 19                	jle    800d24 <strtol+0xc2>
  800d0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0e:	8a 00                	mov    (%eax),%al
  800d10:	3c 39                	cmp    $0x39,%al
  800d12:	7f 10                	jg     800d24 <strtol+0xc2>
			dig = *s - '0';
  800d14:	8b 45 08             	mov    0x8(%ebp),%eax
  800d17:	8a 00                	mov    (%eax),%al
  800d19:	0f be c0             	movsbl %al,%eax
  800d1c:	83 e8 30             	sub    $0x30,%eax
  800d1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d22:	eb 42                	jmp    800d66 <strtol+0x104>
		else if (*s >= 'a' && *s <= 'z')
  800d24:	8b 45 08             	mov    0x8(%ebp),%eax
  800d27:	8a 00                	mov    (%eax),%al
  800d29:	3c 60                	cmp    $0x60,%al
  800d2b:	7e 19                	jle    800d46 <strtol+0xe4>
  800d2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d30:	8a 00                	mov    (%eax),%al
  800d32:	3c 7a                	cmp    $0x7a,%al
  800d34:	7f 10                	jg     800d46 <strtol+0xe4>
			dig = *s - 'a' + 10;
  800d36:	8b 45 08             	mov    0x8(%ebp),%eax
  800d39:	8a 00                	mov    (%eax),%al
  800d3b:	0f be c0             	movsbl %al,%eax
  800d3e:	83 e8 57             	sub    $0x57,%eax
  800d41:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d44:	eb 20                	jmp    800d66 <strtol+0x104>
		else if (*s >= 'A' && *s <= 'Z')
  800d46:	8b 45 08             	mov    0x8(%ebp),%eax
  800d49:	8a 00                	mov    (%eax),%al
  800d4b:	3c 40                	cmp    $0x40,%al
  800d4d:	7e 39                	jle    800d88 <strtol+0x126>
  800d4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d52:	8a 00                	mov    (%eax),%al
  800d54:	3c 5a                	cmp    $0x5a,%al
  800d56:	7f 30                	jg     800d88 <strtol+0x126>
			dig = *s - 'A' + 10;
  800d58:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5b:	8a 00                	mov    (%eax),%al
  800d5d:	0f be c0             	movsbl %al,%eax
  800d60:	83 e8 37             	sub    $0x37,%eax
  800d63:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800d66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d69:	3b 45 10             	cmp    0x10(%ebp),%eax
  800d6c:	7d 19                	jge    800d87 <strtol+0x125>
			break;
		s++, val = (val * base) + dig;
  800d6e:	ff 45 08             	incl   0x8(%ebp)
  800d71:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d74:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d78:	89 c2                	mov    %eax,%edx
  800d7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d7d:	01 d0                	add    %edx,%eax
  800d7f:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800d82:	e9 7b ff ff ff       	jmp    800d02 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
			break;
  800d87:	90                   	nop
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d88:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d8c:	74 08                	je     800d96 <strtol+0x134>
		*endptr = (char *) s;
  800d8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d91:	8b 55 08             	mov    0x8(%ebp),%edx
  800d94:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800d96:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800d9a:	74 07                	je     800da3 <strtol+0x141>
  800d9c:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d9f:	f7 d8                	neg    %eax
  800da1:	eb 03                	jmp    800da6 <strtol+0x144>
  800da3:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800da6:	c9                   	leave  
  800da7:	c3                   	ret    

00800da8 <ltostr>:

void
ltostr(long value, char *str)
{
  800da8:	55                   	push   %ebp
  800da9:	89 e5                	mov    %esp,%ebp
  800dab:	83 ec 20             	sub    $0x20,%esp
	int neg = 0;
  800dae:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	int s = 0 ;
  800db5:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// plus/minus sign
	if (value < 0)
  800dbc:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800dc0:	79 13                	jns    800dd5 <ltostr+0x2d>
	{
		neg = 1;
  800dc2:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
		str[0] = '-';
  800dc9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dcc:	c6 00 2d             	movb   $0x2d,(%eax)
		value = value * -1 ;
  800dcf:	f7 5d 08             	negl   0x8(%ebp)
		s++ ;
  800dd2:	ff 45 f8             	incl   -0x8(%ebp)
	}
	do
	{
		int mod = value % 10 ;
  800dd5:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800ddd:	99                   	cltd   
  800dde:	f7 f9                	idiv   %ecx
  800de0:	89 55 ec             	mov    %edx,-0x14(%ebp)
		str[s++] = mod + '0' ;
  800de3:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800de6:	8d 50 01             	lea    0x1(%eax),%edx
  800de9:	89 55 f8             	mov    %edx,-0x8(%ebp)
  800dec:	89 c2                	mov    %eax,%edx
  800dee:	8b 45 0c             	mov    0xc(%ebp),%eax
  800df1:	01 d0                	add    %edx,%eax
  800df3:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800df6:	83 c2 30             	add    $0x30,%edx
  800df9:	88 10                	mov    %dl,(%eax)
		value = value / 10 ;
  800dfb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dfe:	b8 67 66 66 66       	mov    $0x66666667,%eax
  800e03:	f7 e9                	imul   %ecx
  800e05:	c1 fa 02             	sar    $0x2,%edx
  800e08:	89 c8                	mov    %ecx,%eax
  800e0a:	c1 f8 1f             	sar    $0x1f,%eax
  800e0d:	29 c2                	sub    %eax,%edx
  800e0f:	89 d0                	mov    %edx,%eax
  800e11:	89 45 08             	mov    %eax,0x8(%ebp)
	} while (value % 10 != 0);
  800e14:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e17:	b8 67 66 66 66       	mov    $0x66666667,%eax
  800e1c:	f7 e9                	imul   %ecx
  800e1e:	c1 fa 02             	sar    $0x2,%edx
  800e21:	89 c8                	mov    %ecx,%eax
  800e23:	c1 f8 1f             	sar    $0x1f,%eax
  800e26:	29 c2                	sub    %eax,%edx
  800e28:	89 d0                	mov    %edx,%eax
  800e2a:	c1 e0 02             	shl    $0x2,%eax
  800e2d:	01 d0                	add    %edx,%eax
  800e2f:	01 c0                	add    %eax,%eax
  800e31:	29 c1                	sub    %eax,%ecx
  800e33:	89 ca                	mov    %ecx,%edx
  800e35:	85 d2                	test   %edx,%edx
  800e37:	75 9c                	jne    800dd5 <ltostr+0x2d>

	//reverse the string
	int start = 0 ;
  800e39:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	int end = s-1 ;
  800e40:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e43:	48                   	dec    %eax
  800e44:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (neg)
  800e47:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800e4b:	74 3d                	je     800e8a <ltostr+0xe2>
		start = 1 ;
  800e4d:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	while(start<end)
  800e54:	eb 34                	jmp    800e8a <ltostr+0xe2>
	{
		char tmp = str[start] ;
  800e56:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e59:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e5c:	01 d0                	add    %edx,%eax
  800e5e:	8a 00                	mov    (%eax),%al
  800e60:	88 45 eb             	mov    %al,-0x15(%ebp)
		str[start] = str[end] ;
  800e63:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e66:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e69:	01 c2                	add    %eax,%edx
  800e6b:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  800e6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e71:	01 c8                	add    %ecx,%eax
  800e73:	8a 00                	mov    (%eax),%al
  800e75:	88 02                	mov    %al,(%edx)
		str[end] = tmp;
  800e77:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e7d:	01 c2                	add    %eax,%edx
  800e7f:	8a 45 eb             	mov    -0x15(%ebp),%al
  800e82:	88 02                	mov    %al,(%edx)
		start++ ;
  800e84:	ff 45 f4             	incl   -0xc(%ebp)
		end-- ;
  800e87:	ff 4d f0             	decl   -0x10(%ebp)
	//reverse the string
	int start = 0 ;
	int end = s-1 ;
	if (neg)
		start = 1 ;
	while(start<end)
  800e8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e8d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800e90:	7c c4                	jl     800e56 <ltostr+0xae>
		str[end] = tmp;
		start++ ;
		end-- ;
	}

	str[s] = 0 ;
  800e92:	8b 55 f8             	mov    -0x8(%ebp),%edx
  800e95:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e98:	01 d0                	add    %edx,%eax
  800e9a:	c6 00 00             	movb   $0x0,(%eax)
	// we don't properly detect overflow!

}
  800e9d:	90                   	nop
  800e9e:	c9                   	leave  
  800e9f:	c3                   	ret    

00800ea0 <strcconcat>:

void
strcconcat(const char *str1, const char *str2, char *final)
{
  800ea0:	55                   	push   %ebp
  800ea1:	89 e5                	mov    %esp,%ebp
  800ea3:	83 ec 10             	sub    $0x10,%esp
	int len1 = strlen(str1);
  800ea6:	ff 75 08             	pushl  0x8(%ebp)
  800ea9:	e8 54 fa ff ff       	call   800902 <strlen>
  800eae:	83 c4 04             	add    $0x4,%esp
  800eb1:	89 45 f4             	mov    %eax,-0xc(%ebp)
	int len2 = strlen(str2);
  800eb4:	ff 75 0c             	pushl  0xc(%ebp)
  800eb7:	e8 46 fa ff ff       	call   800902 <strlen>
  800ebc:	83 c4 04             	add    $0x4,%esp
  800ebf:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int s = 0 ;
  800ec2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	for (s=0 ; s < len1 ; s++)
  800ec9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800ed0:	eb 17                	jmp    800ee9 <strcconcat+0x49>
		final[s] = str1[s] ;
  800ed2:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800ed5:	8b 45 10             	mov    0x10(%ebp),%eax
  800ed8:	01 c2                	add    %eax,%edx
  800eda:	8b 4d fc             	mov    -0x4(%ebp),%ecx
  800edd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee0:	01 c8                	add    %ecx,%eax
  800ee2:	8a 00                	mov    (%eax),%al
  800ee4:	88 02                	mov    %al,(%edx)
strcconcat(const char *str1, const char *str2, char *final)
{
	int len1 = strlen(str1);
	int len2 = strlen(str2);
	int s = 0 ;
	for (s=0 ; s < len1 ; s++)
  800ee6:	ff 45 fc             	incl   -0x4(%ebp)
  800ee9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800eec:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  800eef:	7c e1                	jl     800ed2 <strcconcat+0x32>
		final[s] = str1[s] ;

	int i = 0 ;
  800ef1:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
	for (i=0 ; i < len2 ; i++)
  800ef8:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  800eff:	eb 1f                	jmp    800f20 <strcconcat+0x80>
		final[s++] = str2[i] ;
  800f01:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800f04:	8d 50 01             	lea    0x1(%eax),%edx
  800f07:	89 55 fc             	mov    %edx,-0x4(%ebp)
  800f0a:	89 c2                	mov    %eax,%edx
  800f0c:	8b 45 10             	mov    0x10(%ebp),%eax
  800f0f:	01 c2                	add    %eax,%edx
  800f11:	8b 4d f8             	mov    -0x8(%ebp),%ecx
  800f14:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f17:	01 c8                	add    %ecx,%eax
  800f19:	8a 00                	mov    (%eax),%al
  800f1b:	88 02                	mov    %al,(%edx)
	int s = 0 ;
	for (s=0 ; s < len1 ; s++)
		final[s] = str1[s] ;

	int i = 0 ;
	for (i=0 ; i < len2 ; i++)
  800f1d:	ff 45 f8             	incl   -0x8(%ebp)
  800f20:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800f23:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800f26:	7c d9                	jl     800f01 <strcconcat+0x61>
		final[s++] = str2[i] ;

	final[s] = 0;
  800f28:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800f2b:	8b 45 10             	mov    0x10(%ebp),%eax
  800f2e:	01 d0                	add    %edx,%eax
  800f30:	c6 00 00             	movb   $0x0,(%eax)
}
  800f33:	90                   	nop
  800f34:	c9                   	leave  
  800f35:	c3                   	ret    

00800f36 <strsplit>:
int strsplit(char *string, char *SPLIT_CHARS, char **argv, int * argc)
{
  800f36:	55                   	push   %ebp
  800f37:	89 e5                	mov    %esp,%ebp
	// Parse the command string into splitchars-separated arguments
	*argc = 0;
  800f39:	8b 45 14             	mov    0x14(%ebp),%eax
  800f3c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	(argv)[*argc] = 0;
  800f42:	8b 45 14             	mov    0x14(%ebp),%eax
  800f45:	8b 00                	mov    (%eax),%eax
  800f47:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800f4e:	8b 45 10             	mov    0x10(%ebp),%eax
  800f51:	01 d0                	add    %edx,%eax
  800f53:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	while (1)
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
  800f59:	eb 0c                	jmp    800f67 <strsplit+0x31>
			*string++ = 0;
  800f5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f5e:	8d 50 01             	lea    0x1(%eax),%edx
  800f61:	89 55 08             	mov    %edx,0x8(%ebp)
  800f64:	c6 00 00             	movb   $0x0,(%eax)
	*argc = 0;
	(argv)[*argc] = 0;
	while (1)
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
  800f67:	8b 45 08             	mov    0x8(%ebp),%eax
  800f6a:	8a 00                	mov    (%eax),%al
  800f6c:	84 c0                	test   %al,%al
  800f6e:	74 18                	je     800f88 <strsplit+0x52>
  800f70:	8b 45 08             	mov    0x8(%ebp),%eax
  800f73:	8a 00                	mov    (%eax),%al
  800f75:	0f be c0             	movsbl %al,%eax
  800f78:	50                   	push   %eax
  800f79:	ff 75 0c             	pushl  0xc(%ebp)
  800f7c:	e8 13 fb ff ff       	call   800a94 <strchr>
  800f81:	83 c4 08             	add    $0x8,%esp
  800f84:	85 c0                	test   %eax,%eax
  800f86:	75 d3                	jne    800f5b <strsplit+0x25>
			*string++ = 0;

		//if the command string is finished, then break the loop
		if (*string == 0)
  800f88:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8b:	8a 00                	mov    (%eax),%al
  800f8d:	84 c0                	test   %al,%al
  800f8f:	74 5a                	je     800feb <strsplit+0xb5>
			break;

		//check current number of arguments
		if (*argc == MAX_ARGUMENTS-1)
  800f91:	8b 45 14             	mov    0x14(%ebp),%eax
  800f94:	8b 00                	mov    (%eax),%eax
  800f96:	83 f8 0f             	cmp    $0xf,%eax
  800f99:	75 07                	jne    800fa2 <strsplit+0x6c>
		{
			return 0;
  800f9b:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa0:	eb 66                	jmp    801008 <strsplit+0xd2>
		}

		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
  800fa2:	8b 45 14             	mov    0x14(%ebp),%eax
  800fa5:	8b 00                	mov    (%eax),%eax
  800fa7:	8d 48 01             	lea    0x1(%eax),%ecx
  800faa:	8b 55 14             	mov    0x14(%ebp),%edx
  800fad:	89 0a                	mov    %ecx,(%edx)
  800faf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800fb6:	8b 45 10             	mov    0x10(%ebp),%eax
  800fb9:	01 c2                	add    %eax,%edx
  800fbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800fbe:	89 02                	mov    %eax,(%edx)
		while (*string && !strchr(SPLIT_CHARS, *string))
  800fc0:	eb 03                	jmp    800fc5 <strsplit+0x8f>
			string++;
  800fc2:	ff 45 08             	incl   0x8(%ebp)
			return 0;
		}

		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
		while (*string && !strchr(SPLIT_CHARS, *string))
  800fc5:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc8:	8a 00                	mov    (%eax),%al
  800fca:	84 c0                	test   %al,%al
  800fcc:	74 8b                	je     800f59 <strsplit+0x23>
  800fce:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd1:	8a 00                	mov    (%eax),%al
  800fd3:	0f be c0             	movsbl %al,%eax
  800fd6:	50                   	push   %eax
  800fd7:	ff 75 0c             	pushl  0xc(%ebp)
  800fda:	e8 b5 fa ff ff       	call   800a94 <strchr>
  800fdf:	83 c4 08             	add    $0x8,%esp
  800fe2:	85 c0                	test   %eax,%eax
  800fe4:	74 dc                	je     800fc2 <strsplit+0x8c>
			string++;
	}
  800fe6:	e9 6e ff ff ff       	jmp    800f59 <strsplit+0x23>
		while (*string && strchr(SPLIT_CHARS, *string))
			*string++ = 0;

		//if the command string is finished, then break the loop
		if (*string == 0)
			break;
  800feb:	90                   	nop
		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
		while (*string && !strchr(SPLIT_CHARS, *string))
			string++;
	}
	(argv)[*argc] = 0;
  800fec:	8b 45 14             	mov    0x14(%ebp),%eax
  800fef:	8b 00                	mov    (%eax),%eax
  800ff1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800ff8:	8b 45 10             	mov    0x10(%ebp),%eax
  800ffb:	01 d0                	add    %edx,%eax
  800ffd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return 1 ;
  801003:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801008:	c9                   	leave  
  801009:	c3                   	ret    

0080100a <str2lower>:


/*2024*/
char* str2lower(char *dst, const char *src)
{
  80100a:	55                   	push   %ebp
  80100b:	89 e5                	mov    %esp,%ebp
  80100d:	83 ec 20             	sub    $0x20,%esp
	//TODO: [PROJECT'23.MS1 - #1] [1] PLAY WITH CODE! - str2lower
	//Comment the following line before start coding...
	//panic("process_command is not implemented yet");
	long long size = strlen(src);
  801010:	ff 75 0c             	pushl  0xc(%ebp)
  801013:	e8 ea f8 ff ff       	call   800902 <strlen>
  801018:	83 c4 04             	add    $0x4,%esp
  80101b:	99                   	cltd   
  80101c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80101f:	89 55 f4             	mov    %edx,-0xc(%ebp)
	for(long long i=0;i<size;i++)
  801022:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  801029:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  801030:	eb 57                	jmp    801089 <str2lower+0x7f>
	{
		if(src[i] >=65 && src[i] <=90)
  801032:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801035:	8b 45 0c             	mov    0xc(%ebp),%eax
  801038:	01 d0                	add    %edx,%eax
  80103a:	8a 00                	mov    (%eax),%al
  80103c:	3c 40                	cmp    $0x40,%al
  80103e:	7e 2d                	jle    80106d <str2lower+0x63>
  801040:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801043:	8b 45 0c             	mov    0xc(%ebp),%eax
  801046:	01 d0                	add    %edx,%eax
  801048:	8a 00                	mov    (%eax),%al
  80104a:	3c 5a                	cmp    $0x5a,%al
  80104c:	7f 1f                	jg     80106d <str2lower+0x63>
		{
			char temp = src[i] + 32;
  80104e:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801051:	8b 45 0c             	mov    0xc(%ebp),%eax
  801054:	01 d0                	add    %edx,%eax
  801056:	8a 00                	mov    (%eax),%al
  801058:	83 c0 20             	add    $0x20,%eax
  80105b:	88 45 ef             	mov    %al,-0x11(%ebp)
			dst[i] = temp;
  80105e:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801061:	8b 45 08             	mov    0x8(%ebp),%eax
  801064:	01 c2                	add    %eax,%edx
  801066:	8a 45 ef             	mov    -0x11(%ebp),%al
  801069:	88 02                	mov    %al,(%edx)
	//panic("process_command is not implemented yet");
	long long size = strlen(src);
	for(long long i=0;i<size;i++)
	{
		if(src[i] >=65 && src[i] <=90)
		{
  80106b:	eb 14                	jmp    801081 <str2lower+0x77>
			char temp = src[i] + 32;
			dst[i] = temp;
		}
		else
		{
			dst[i] = src[i];
  80106d:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801070:	8b 45 08             	mov    0x8(%ebp),%eax
  801073:	01 c2                	add    %eax,%edx
  801075:	8b 4d f8             	mov    -0x8(%ebp),%ecx
  801078:	8b 45 0c             	mov    0xc(%ebp),%eax
  80107b:	01 c8                	add    %ecx,%eax
  80107d:	8a 00                	mov    (%eax),%al
  80107f:	88 02                	mov    %al,(%edx)
{
	//TODO: [PROJECT'23.MS1 - #1] [1] PLAY WITH CODE! - str2lower
	//Comment the following line before start coding...
	//panic("process_command is not implemented yet");
	long long size = strlen(src);
	for(long long i=0;i<size;i++)
  801081:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  801085:	83 55 fc 00          	adcl   $0x0,-0x4(%ebp)
  801089:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80108c:	8b 55 fc             	mov    -0x4(%ebp),%edx
  80108f:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  801092:	7c 9e                	jl     801032 <str2lower+0x28>
  801094:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  801097:	7f 05                	jg     80109e <str2lower+0x94>
  801099:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  80109c:	72 94                	jb     801032 <str2lower+0x28>
		else
		{
			dst[i] = src[i];
		}
	}
	return dst;
  80109e:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8010a1:	c9                   	leave  
  8010a2:	c3                   	ret    

008010a3 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline uint32
syscall(int num, uint32 a1, uint32 a2, uint32 a3, uint32 a4, uint32 a5)
{
  8010a3:	55                   	push   %ebp
  8010a4:	89 e5                	mov    %esp,%ebp
  8010a6:	57                   	push   %edi
  8010a7:	56                   	push   %esi
  8010a8:	53                   	push   %ebx
  8010a9:	83 ec 10             	sub    $0x10,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8010af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010b2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8010b5:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8010b8:	8b 7d 18             	mov    0x18(%ebp),%edi
  8010bb:	8b 75 1c             	mov    0x1c(%ebp),%esi
  8010be:	cd 30                	int    $0x30
  8010c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	return ret;
  8010c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  8010c6:	83 c4 10             	add    $0x10,%esp
  8010c9:	5b                   	pop    %ebx
  8010ca:	5e                   	pop    %esi
  8010cb:	5f                   	pop    %edi
  8010cc:	5d                   	pop    %ebp
  8010cd:	c3                   	ret    

008010ce <sys_cputs>:

void
sys_cputs(const char *s, uint32 len, uint8 printProgName)
{
  8010ce:	55                   	push   %ebp
  8010cf:	89 e5                	mov    %esp,%ebp
  8010d1:	83 ec 04             	sub    $0x4,%esp
  8010d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8010d7:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_cputs, (uint32) s, len, (uint32)printProgName, 0, 0);
  8010da:	0f b6 55 fc          	movzbl -0x4(%ebp),%edx
  8010de:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e1:	6a 00                	push   $0x0
  8010e3:	6a 00                	push   $0x0
  8010e5:	52                   	push   %edx
  8010e6:	ff 75 0c             	pushl  0xc(%ebp)
  8010e9:	50                   	push   %eax
  8010ea:	6a 00                	push   $0x0
  8010ec:	e8 b2 ff ff ff       	call   8010a3 <syscall>
  8010f1:	83 c4 18             	add    $0x18,%esp
}
  8010f4:	90                   	nop
  8010f5:	c9                   	leave  
  8010f6:	c3                   	ret    

008010f7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8010f7:	55                   	push   %ebp
  8010f8:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0);
  8010fa:	6a 00                	push   $0x0
  8010fc:	6a 00                	push   $0x0
  8010fe:	6a 00                	push   $0x0
  801100:	6a 00                	push   $0x0
  801102:	6a 00                	push   $0x0
  801104:	6a 01                	push   $0x1
  801106:	e8 98 ff ff ff       	call   8010a3 <syscall>
  80110b:	83 c4 18             	add    $0x18,%esp
}
  80110e:	c9                   	leave  
  80110f:	c3                   	ret    

00801110 <__sys_allocate_page>:

int __sys_allocate_page(void *va, int perm)
{
  801110:	55                   	push   %ebp
  801111:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_allocate_page, (uint32) va, perm, 0 , 0, 0);
  801113:	8b 55 0c             	mov    0xc(%ebp),%edx
  801116:	8b 45 08             	mov    0x8(%ebp),%eax
  801119:	6a 00                	push   $0x0
  80111b:	6a 00                	push   $0x0
  80111d:	6a 00                	push   $0x0
  80111f:	52                   	push   %edx
  801120:	50                   	push   %eax
  801121:	6a 05                	push   $0x5
  801123:	e8 7b ff ff ff       	call   8010a3 <syscall>
  801128:	83 c4 18             	add    $0x18,%esp
}
  80112b:	c9                   	leave  
  80112c:	c3                   	ret    

0080112d <__sys_map_frame>:

int __sys_map_frame(int32 srcenv, void *srcva, int32 dstenv, void *dstva, int perm)
{
  80112d:	55                   	push   %ebp
  80112e:	89 e5                	mov    %esp,%ebp
  801130:	56                   	push   %esi
  801131:	53                   	push   %ebx
	return syscall(SYS_map_frame, srcenv, (uint32) srcva, dstenv, (uint32) dstva, perm);
  801132:	8b 75 18             	mov    0x18(%ebp),%esi
  801135:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801138:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80113b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80113e:	8b 45 08             	mov    0x8(%ebp),%eax
  801141:	56                   	push   %esi
  801142:	53                   	push   %ebx
  801143:	51                   	push   %ecx
  801144:	52                   	push   %edx
  801145:	50                   	push   %eax
  801146:	6a 06                	push   $0x6
  801148:	e8 56 ff ff ff       	call   8010a3 <syscall>
  80114d:	83 c4 18             	add    $0x18,%esp
}
  801150:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801153:	5b                   	pop    %ebx
  801154:	5e                   	pop    %esi
  801155:	5d                   	pop    %ebp
  801156:	c3                   	ret    

00801157 <__sys_unmap_frame>:

int __sys_unmap_frame(int32 envid, void *va)
{
  801157:	55                   	push   %ebp
  801158:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_unmap_frame, envid, (uint32) va, 0, 0, 0);
  80115a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80115d:	8b 45 08             	mov    0x8(%ebp),%eax
  801160:	6a 00                	push   $0x0
  801162:	6a 00                	push   $0x0
  801164:	6a 00                	push   $0x0
  801166:	52                   	push   %edx
  801167:	50                   	push   %eax
  801168:	6a 07                	push   $0x7
  80116a:	e8 34 ff ff ff       	call   8010a3 <syscall>
  80116f:	83 c4 18             	add    $0x18,%esp
}
  801172:	c9                   	leave  
  801173:	c3                   	ret    

00801174 <sys_calculate_required_frames>:

uint32 sys_calculate_required_frames(uint32 start_virtual_address, uint32 size)
{
  801174:	55                   	push   %ebp
  801175:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_req_frames, start_virtual_address, (uint32) size, 0, 0, 0);
  801177:	6a 00                	push   $0x0
  801179:	6a 00                	push   $0x0
  80117b:	6a 00                	push   $0x0
  80117d:	ff 75 0c             	pushl  0xc(%ebp)
  801180:	ff 75 08             	pushl  0x8(%ebp)
  801183:	6a 08                	push   $0x8
  801185:	e8 19 ff ff ff       	call   8010a3 <syscall>
  80118a:	83 c4 18             	add    $0x18,%esp
}
  80118d:	c9                   	leave  
  80118e:	c3                   	ret    

0080118f <sys_calculate_free_frames>:

uint32 sys_calculate_free_frames()
{
  80118f:	55                   	push   %ebp
  801190:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_free_frames, 0, 0, 0, 0, 0);
  801192:	6a 00                	push   $0x0
  801194:	6a 00                	push   $0x0
  801196:	6a 00                	push   $0x0
  801198:	6a 00                	push   $0x0
  80119a:	6a 00                	push   $0x0
  80119c:	6a 09                	push   $0x9
  80119e:	e8 00 ff ff ff       	call   8010a3 <syscall>
  8011a3:	83 c4 18             	add    $0x18,%esp
}
  8011a6:	c9                   	leave  
  8011a7:	c3                   	ret    

008011a8 <sys_calculate_modified_frames>:
uint32 sys_calculate_modified_frames()
{
  8011a8:	55                   	push   %ebp
  8011a9:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_modified_frames, 0, 0, 0, 0, 0);
  8011ab:	6a 00                	push   $0x0
  8011ad:	6a 00                	push   $0x0
  8011af:	6a 00                	push   $0x0
  8011b1:	6a 00                	push   $0x0
  8011b3:	6a 00                	push   $0x0
  8011b5:	6a 0a                	push   $0xa
  8011b7:	e8 e7 fe ff ff       	call   8010a3 <syscall>
  8011bc:	83 c4 18             	add    $0x18,%esp
}
  8011bf:	c9                   	leave  
  8011c0:	c3                   	ret    

008011c1 <sys_calculate_notmod_frames>:

uint32 sys_calculate_notmod_frames()
{
  8011c1:	55                   	push   %ebp
  8011c2:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_notmod_frames, 0, 0, 0, 0, 0);
  8011c4:	6a 00                	push   $0x0
  8011c6:	6a 00                	push   $0x0
  8011c8:	6a 00                	push   $0x0
  8011ca:	6a 00                	push   $0x0
  8011cc:	6a 00                	push   $0x0
  8011ce:	6a 0b                	push   $0xb
  8011d0:	e8 ce fe ff ff       	call   8010a3 <syscall>
  8011d5:	83 c4 18             	add    $0x18,%esp
}
  8011d8:	c9                   	leave  
  8011d9:	c3                   	ret    

008011da <sys_pf_calculate_allocated_pages>:



int sys_pf_calculate_allocated_pages()
{
  8011da:	55                   	push   %ebp
  8011db:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_pf_calc_allocated_pages, 0,0,0,0,0);
  8011dd:	6a 00                	push   $0x0
  8011df:	6a 00                	push   $0x0
  8011e1:	6a 00                	push   $0x0
  8011e3:	6a 00                	push   $0x0
  8011e5:	6a 00                	push   $0x0
  8011e7:	6a 0c                	push   $0xc
  8011e9:	e8 b5 fe ff ff       	call   8010a3 <syscall>
  8011ee:	83 c4 18             	add    $0x18,%esp
}
  8011f1:	c9                   	leave  
  8011f2:	c3                   	ret    

008011f3 <sys_calculate_pages_tobe_removed_ready_exit>:

int sys_calculate_pages_tobe_removed_ready_exit(uint32 WS_or_MEMORY_flag)
{
  8011f3:	55                   	push   %ebp
  8011f4:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calculate_pages_tobe_removed_ready_exit, WS_or_MEMORY_flag,0,0,0,0);
  8011f6:	6a 00                	push   $0x0
  8011f8:	6a 00                	push   $0x0
  8011fa:	6a 00                	push   $0x0
  8011fc:	6a 00                	push   $0x0
  8011fe:	ff 75 08             	pushl  0x8(%ebp)
  801201:	6a 0d                	push   $0xd
  801203:	e8 9b fe ff ff       	call   8010a3 <syscall>
  801208:	83 c4 18             	add    $0x18,%esp
}
  80120b:	c9                   	leave  
  80120c:	c3                   	ret    

0080120d <sys_scarce_memory>:

void sys_scarce_memory()
{
  80120d:	55                   	push   %ebp
  80120e:	89 e5                	mov    %esp,%ebp
	syscall(SYS_scarce_memory,0,0,0,0,0);
  801210:	6a 00                	push   $0x0
  801212:	6a 00                	push   $0x0
  801214:	6a 00                	push   $0x0
  801216:	6a 00                	push   $0x0
  801218:	6a 00                	push   $0x0
  80121a:	6a 0e                	push   $0xe
  80121c:	e8 82 fe ff ff       	call   8010a3 <syscall>
  801221:	83 c4 18             	add    $0x18,%esp
}
  801224:	90                   	nop
  801225:	c9                   	leave  
  801226:	c3                   	ret    

00801227 <sys_disable_interrupt>:

//NEW !! 2012...
void
sys_disable_interrupt()
{
  801227:	55                   	push   %ebp
  801228:	89 e5                	mov    %esp,%ebp
	syscall(SYS_disableINTR,0, 0, 0, 0, 0);
  80122a:	6a 00                	push   $0x0
  80122c:	6a 00                	push   $0x0
  80122e:	6a 00                	push   $0x0
  801230:	6a 00                	push   $0x0
  801232:	6a 00                	push   $0x0
  801234:	6a 11                	push   $0x11
  801236:	e8 68 fe ff ff       	call   8010a3 <syscall>
  80123b:	83 c4 18             	add    $0x18,%esp
}
  80123e:	90                   	nop
  80123f:	c9                   	leave  
  801240:	c3                   	ret    

00801241 <sys_enable_interrupt>:


void
sys_enable_interrupt()
{
  801241:	55                   	push   %ebp
  801242:	89 e5                	mov    %esp,%ebp
	syscall(SYS_enableINTR,0, 0, 0, 0, 0);
  801244:	6a 00                	push   $0x0
  801246:	6a 00                	push   $0x0
  801248:	6a 00                	push   $0x0
  80124a:	6a 00                	push   $0x0
  80124c:	6a 00                	push   $0x0
  80124e:	6a 12                	push   $0x12
  801250:	e8 4e fe ff ff       	call   8010a3 <syscall>
  801255:	83 c4 18             	add    $0x18,%esp
}
  801258:	90                   	nop
  801259:	c9                   	leave  
  80125a:	c3                   	ret    

0080125b <sys_cputc>:


void
sys_cputc(const char c)
{
  80125b:	55                   	push   %ebp
  80125c:	89 e5                	mov    %esp,%ebp
  80125e:	83 ec 04             	sub    $0x4,%esp
  801261:	8b 45 08             	mov    0x8(%ebp),%eax
  801264:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_cputc, (uint32) c, 0, 0, 0, 0);
  801267:	0f be 45 fc          	movsbl -0x4(%ebp),%eax
  80126b:	6a 00                	push   $0x0
  80126d:	6a 00                	push   $0x0
  80126f:	6a 00                	push   $0x0
  801271:	6a 00                	push   $0x0
  801273:	50                   	push   %eax
  801274:	6a 13                	push   $0x13
  801276:	e8 28 fe ff ff       	call   8010a3 <syscall>
  80127b:	83 c4 18             	add    $0x18,%esp
}
  80127e:	90                   	nop
  80127f:	c9                   	leave  
  801280:	c3                   	ret    

00801281 <sys_clear_ffl>:


//NEW'12: BONUS2 Testing
void
sys_clear_ffl()
{
  801281:	55                   	push   %ebp
  801282:	89 e5                	mov    %esp,%ebp
	syscall(SYS_clearFFL,0, 0, 0, 0, 0);
  801284:	6a 00                	push   $0x0
  801286:	6a 00                	push   $0x0
  801288:	6a 00                	push   $0x0
  80128a:	6a 00                	push   $0x0
  80128c:	6a 00                	push   $0x0
  80128e:	6a 14                	push   $0x14
  801290:	e8 0e fe ff ff       	call   8010a3 <syscall>
  801295:	83 c4 18             	add    $0x18,%esp
}
  801298:	90                   	nop
  801299:	c9                   	leave  
  80129a:	c3                   	ret    

0080129b <sys_createSemaphore>:

int
sys_createSemaphore(char* semaphoreName, uint32 initialValue)
{
  80129b:	55                   	push   %ebp
  80129c:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_create_semaphore,(uint32)semaphoreName, (uint32)initialValue, 0, 0, 0);
  80129e:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a1:	6a 00                	push   $0x0
  8012a3:	6a 00                	push   $0x0
  8012a5:	6a 00                	push   $0x0
  8012a7:	ff 75 0c             	pushl  0xc(%ebp)
  8012aa:	50                   	push   %eax
  8012ab:	6a 15                	push   $0x15
  8012ad:	e8 f1 fd ff ff       	call   8010a3 <syscall>
  8012b2:	83 c4 18             	add    $0x18,%esp
}
  8012b5:	c9                   	leave  
  8012b6:	c3                   	ret    

008012b7 <sys_getSemaphoreValue>:

int
sys_getSemaphoreValue(int32 ownerEnvID, char* semaphoreName)
{
  8012b7:	55                   	push   %ebp
  8012b8:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_get_semaphore_value,(uint32) ownerEnvID, (uint32)semaphoreName, 0, 0, 0);
  8012ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c0:	6a 00                	push   $0x0
  8012c2:	6a 00                	push   $0x0
  8012c4:	6a 00                	push   $0x0
  8012c6:	52                   	push   %edx
  8012c7:	50                   	push   %eax
  8012c8:	6a 18                	push   $0x18
  8012ca:	e8 d4 fd ff ff       	call   8010a3 <syscall>
  8012cf:	83 c4 18             	add    $0x18,%esp
}
  8012d2:	c9                   	leave  
  8012d3:	c3                   	ret    

008012d4 <sys_waitSemaphore>:

void
sys_waitSemaphore(int32 ownerEnvID, char* semaphoreName)
{
  8012d4:	55                   	push   %ebp
  8012d5:	89 e5                	mov    %esp,%ebp
	syscall(SYS_wait_semaphore,(uint32) ownerEnvID, (uint32)semaphoreName, 0, 0, 0);
  8012d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012da:	8b 45 08             	mov    0x8(%ebp),%eax
  8012dd:	6a 00                	push   $0x0
  8012df:	6a 00                	push   $0x0
  8012e1:	6a 00                	push   $0x0
  8012e3:	52                   	push   %edx
  8012e4:	50                   	push   %eax
  8012e5:	6a 16                	push   $0x16
  8012e7:	e8 b7 fd ff ff       	call   8010a3 <syscall>
  8012ec:	83 c4 18             	add    $0x18,%esp
}
  8012ef:	90                   	nop
  8012f0:	c9                   	leave  
  8012f1:	c3                   	ret    

008012f2 <sys_signalSemaphore>:

void
sys_signalSemaphore(int32 ownerEnvID, char* semaphoreName)
{
  8012f2:	55                   	push   %ebp
  8012f3:	89 e5                	mov    %esp,%ebp
	syscall(SYS_signal_semaphore,(uint32) ownerEnvID, (uint32)semaphoreName, 0, 0, 0);
  8012f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8012fb:	6a 00                	push   $0x0
  8012fd:	6a 00                	push   $0x0
  8012ff:	6a 00                	push   $0x0
  801301:	52                   	push   %edx
  801302:	50                   	push   %eax
  801303:	6a 17                	push   $0x17
  801305:	e8 99 fd ff ff       	call   8010a3 <syscall>
  80130a:	83 c4 18             	add    $0x18,%esp
}
  80130d:	90                   	nop
  80130e:	c9                   	leave  
  80130f:	c3                   	ret    

00801310 <sys_createSharedObject>:

int
sys_createSharedObject(char* shareName, uint32 size, uint8 isWritable, void* virtual_address)
{
  801310:	55                   	push   %ebp
  801311:	89 e5                	mov    %esp,%ebp
  801313:	83 ec 04             	sub    $0x4,%esp
  801316:	8b 45 10             	mov    0x10(%ebp),%eax
  801319:	88 45 fc             	mov    %al,-0x4(%ebp)
	return syscall(SYS_create_shared_object,(uint32)shareName, (uint32)size, isWritable, (uint32)virtual_address,  0);
  80131c:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80131f:	0f b6 55 fc          	movzbl -0x4(%ebp),%edx
  801323:	8b 45 08             	mov    0x8(%ebp),%eax
  801326:	6a 00                	push   $0x0
  801328:	51                   	push   %ecx
  801329:	52                   	push   %edx
  80132a:	ff 75 0c             	pushl  0xc(%ebp)
  80132d:	50                   	push   %eax
  80132e:	6a 19                	push   $0x19
  801330:	e8 6e fd ff ff       	call   8010a3 <syscall>
  801335:	83 c4 18             	add    $0x18,%esp
}
  801338:	c9                   	leave  
  801339:	c3                   	ret    

0080133a <sys_getSizeOfSharedObject>:

//2017:
int
sys_getSizeOfSharedObject(int32 ownerID, char* shareName)
{
  80133a:	55                   	push   %ebp
  80133b:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_get_size_of_shared_object,(uint32) ownerID, (uint32)shareName, 0, 0, 0);
  80133d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801340:	8b 45 08             	mov    0x8(%ebp),%eax
  801343:	6a 00                	push   $0x0
  801345:	6a 00                	push   $0x0
  801347:	6a 00                	push   $0x0
  801349:	52                   	push   %edx
  80134a:	50                   	push   %eax
  80134b:	6a 1a                	push   $0x1a
  80134d:	e8 51 fd ff ff       	call   8010a3 <syscall>
  801352:	83 c4 18             	add    $0x18,%esp
}
  801355:	c9                   	leave  
  801356:	c3                   	ret    

00801357 <sys_getSharedObject>:
//==========

int
sys_getSharedObject(int32 ownerID, char* shareName, void* virtual_address)
{
  801357:	55                   	push   %ebp
  801358:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_get_shared_object,(uint32) ownerID, (uint32)shareName, (uint32)virtual_address, 0, 0);
  80135a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80135d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801360:	8b 45 08             	mov    0x8(%ebp),%eax
  801363:	6a 00                	push   $0x0
  801365:	6a 00                	push   $0x0
  801367:	51                   	push   %ecx
  801368:	52                   	push   %edx
  801369:	50                   	push   %eax
  80136a:	6a 1b                	push   $0x1b
  80136c:	e8 32 fd ff ff       	call   8010a3 <syscall>
  801371:	83 c4 18             	add    $0x18,%esp
}
  801374:	c9                   	leave  
  801375:	c3                   	ret    

00801376 <sys_freeSharedObject>:

int
sys_freeSharedObject(int32 sharedObjectID, void *startVA)
{
  801376:	55                   	push   %ebp
  801377:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_free_shared_object,(uint32) sharedObjectID, (uint32) startVA, 0, 0, 0);
  801379:	8b 55 0c             	mov    0xc(%ebp),%edx
  80137c:	8b 45 08             	mov    0x8(%ebp),%eax
  80137f:	6a 00                	push   $0x0
  801381:	6a 00                	push   $0x0
  801383:	6a 00                	push   $0x0
  801385:	52                   	push   %edx
  801386:	50                   	push   %eax
  801387:	6a 1c                	push   $0x1c
  801389:	e8 15 fd ff ff       	call   8010a3 <syscall>
  80138e:	83 c4 18             	add    $0x18,%esp
}
  801391:	c9                   	leave  
  801392:	c3                   	ret    

00801393 <sys_getMaxShares>:

uint32 	sys_getMaxShares()
{
  801393:	55                   	push   %ebp
  801394:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_get_max_shares,0, 0, 0, 0, 0);
  801396:	6a 00                	push   $0x0
  801398:	6a 00                	push   $0x0
  80139a:	6a 00                	push   $0x0
  80139c:	6a 00                	push   $0x0
  80139e:	6a 00                	push   $0x0
  8013a0:	6a 1d                	push   $0x1d
  8013a2:	e8 fc fc ff ff       	call   8010a3 <syscall>
  8013a7:	83 c4 18             	add    $0x18,%esp
}
  8013aa:	c9                   	leave  
  8013ab:	c3                   	ret    

008013ac <sys_create_env>:

int sys_create_env(char* programName, unsigned int page_WS_size,unsigned int LRU_second_list_size,unsigned int percent_WS_pages_to_remove)
{
  8013ac:	55                   	push   %ebp
  8013ad:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_create_env,(uint32)programName, (uint32)page_WS_size,(uint32)LRU_second_list_size, (uint32)percent_WS_pages_to_remove, 0);
  8013af:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b2:	6a 00                	push   $0x0
  8013b4:	ff 75 14             	pushl  0x14(%ebp)
  8013b7:	ff 75 10             	pushl  0x10(%ebp)
  8013ba:	ff 75 0c             	pushl  0xc(%ebp)
  8013bd:	50                   	push   %eax
  8013be:	6a 1e                	push   $0x1e
  8013c0:	e8 de fc ff ff       	call   8010a3 <syscall>
  8013c5:	83 c4 18             	add    $0x18,%esp
}
  8013c8:	c9                   	leave  
  8013c9:	c3                   	ret    

008013ca <sys_run_env>:

void
sys_run_env(int32 envId)
{
  8013ca:	55                   	push   %ebp
  8013cb:	89 e5                	mov    %esp,%ebp
	syscall(SYS_run_env, (int32)envId, 0, 0, 0, 0);
  8013cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d0:	6a 00                	push   $0x0
  8013d2:	6a 00                	push   $0x0
  8013d4:	6a 00                	push   $0x0
  8013d6:	6a 00                	push   $0x0
  8013d8:	50                   	push   %eax
  8013d9:	6a 1f                	push   $0x1f
  8013db:	e8 c3 fc ff ff       	call   8010a3 <syscall>
  8013e0:	83 c4 18             	add    $0x18,%esp
}
  8013e3:	90                   	nop
  8013e4:	c9                   	leave  
  8013e5:	c3                   	ret    

008013e6 <sys_destroy_env>:

int sys_destroy_env(int32  envid)
{
  8013e6:	55                   	push   %ebp
  8013e7:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_destroy_env, envid, 0, 0, 0, 0);
  8013e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ec:	6a 00                	push   $0x0
  8013ee:	6a 00                	push   $0x0
  8013f0:	6a 00                	push   $0x0
  8013f2:	6a 00                	push   $0x0
  8013f4:	50                   	push   %eax
  8013f5:	6a 20                	push   $0x20
  8013f7:	e8 a7 fc ff ff       	call   8010a3 <syscall>
  8013fc:	83 c4 18             	add    $0x18,%esp
}
  8013ff:	c9                   	leave  
  801400:	c3                   	ret    

00801401 <sys_getenvid>:

int32 sys_getenvid(void)
{
  801401:	55                   	push   %ebp
  801402:	89 e5                	mov    %esp,%ebp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0);
  801404:	6a 00                	push   $0x0
  801406:	6a 00                	push   $0x0
  801408:	6a 00                	push   $0x0
  80140a:	6a 00                	push   $0x0
  80140c:	6a 00                	push   $0x0
  80140e:	6a 02                	push   $0x2
  801410:	e8 8e fc ff ff       	call   8010a3 <syscall>
  801415:	83 c4 18             	add    $0x18,%esp
}
  801418:	c9                   	leave  
  801419:	c3                   	ret    

0080141a <sys_getenvindex>:

//2017
int32 sys_getenvindex(void)
{
  80141a:	55                   	push   %ebp
  80141b:	89 e5                	mov    %esp,%ebp
	 return syscall(SYS_getenvindex, 0, 0, 0, 0, 0);
  80141d:	6a 00                	push   $0x0
  80141f:	6a 00                	push   $0x0
  801421:	6a 00                	push   $0x0
  801423:	6a 00                	push   $0x0
  801425:	6a 00                	push   $0x0
  801427:	6a 03                	push   $0x3
  801429:	e8 75 fc ff ff       	call   8010a3 <syscall>
  80142e:	83 c4 18             	add    $0x18,%esp
}
  801431:	c9                   	leave  
  801432:	c3                   	ret    

00801433 <sys_getparentenvid>:

int32 sys_getparentenvid(void)
{
  801433:	55                   	push   %ebp
  801434:	89 e5                	mov    %esp,%ebp
	 return syscall(SYS_getparentenvid, 0, 0, 0, 0, 0);
  801436:	6a 00                	push   $0x0
  801438:	6a 00                	push   $0x0
  80143a:	6a 00                	push   $0x0
  80143c:	6a 00                	push   $0x0
  80143e:	6a 00                	push   $0x0
  801440:	6a 04                	push   $0x4
  801442:	e8 5c fc ff ff       	call   8010a3 <syscall>
  801447:	83 c4 18             	add    $0x18,%esp
}
  80144a:	c9                   	leave  
  80144b:	c3                   	ret    

0080144c <sys_exit_env>:


void sys_exit_env(void)
{
  80144c:	55                   	push   %ebp
  80144d:	89 e5                	mov    %esp,%ebp
	syscall(SYS_exit_env, 0, 0, 0, 0, 0);
  80144f:	6a 00                	push   $0x0
  801451:	6a 00                	push   $0x0
  801453:	6a 00                	push   $0x0
  801455:	6a 00                	push   $0x0
  801457:	6a 00                	push   $0x0
  801459:	6a 21                	push   $0x21
  80145b:	e8 43 fc ff ff       	call   8010a3 <syscall>
  801460:	83 c4 18             	add    $0x18,%esp
}
  801463:	90                   	nop
  801464:	c9                   	leave  
  801465:	c3                   	ret    

00801466 <sys_get_virtual_time>:


struct uint64
sys_get_virtual_time()
{
  801466:	55                   	push   %ebp
  801467:	89 e5                	mov    %esp,%ebp
  801469:	83 ec 10             	sub    $0x10,%esp
	struct uint64 result;
	syscall(SYS_get_virtual_time, (uint32)&(result.low), (uint32)&(result.hi), 0, 0, 0);
  80146c:	8d 45 f8             	lea    -0x8(%ebp),%eax
  80146f:	8d 50 04             	lea    0x4(%eax),%edx
  801472:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801475:	6a 00                	push   $0x0
  801477:	6a 00                	push   $0x0
  801479:	6a 00                	push   $0x0
  80147b:	52                   	push   %edx
  80147c:	50                   	push   %eax
  80147d:	6a 22                	push   $0x22
  80147f:	e8 1f fc ff ff       	call   8010a3 <syscall>
  801484:	83 c4 18             	add    $0x18,%esp
	return result;
  801487:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80148a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80148d:	8b 55 fc             	mov    -0x4(%ebp),%edx
  801490:	89 01                	mov    %eax,(%ecx)
  801492:	89 51 04             	mov    %edx,0x4(%ecx)
}
  801495:	8b 45 08             	mov    0x8(%ebp),%eax
  801498:	c9                   	leave  
  801499:	c2 04 00             	ret    $0x4

0080149c <sys_move_user_mem>:

// 2014
void sys_move_user_mem(uint32 src_virtual_address, uint32 dst_virtual_address, uint32 size)
{
  80149c:	55                   	push   %ebp
  80149d:	89 e5                	mov    %esp,%ebp
	syscall(SYS_move_user_mem, src_virtual_address, dst_virtual_address, size, 0, 0);
  80149f:	6a 00                	push   $0x0
  8014a1:	6a 00                	push   $0x0
  8014a3:	ff 75 10             	pushl  0x10(%ebp)
  8014a6:	ff 75 0c             	pushl  0xc(%ebp)
  8014a9:	ff 75 08             	pushl  0x8(%ebp)
  8014ac:	6a 10                	push   $0x10
  8014ae:	e8 f0 fb ff ff       	call   8010a3 <syscall>
  8014b3:	83 c4 18             	add    $0x18,%esp
	return ;
  8014b6:	90                   	nop
}
  8014b7:	c9                   	leave  
  8014b8:	c3                   	ret    

008014b9 <sys_rcr2>:
uint32 sys_rcr2()
{
  8014b9:	55                   	push   %ebp
  8014ba:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_rcr2, 0, 0, 0, 0, 0);
  8014bc:	6a 00                	push   $0x0
  8014be:	6a 00                	push   $0x0
  8014c0:	6a 00                	push   $0x0
  8014c2:	6a 00                	push   $0x0
  8014c4:	6a 00                	push   $0x0
  8014c6:	6a 23                	push   $0x23
  8014c8:	e8 d6 fb ff ff       	call   8010a3 <syscall>
  8014cd:	83 c4 18             	add    $0x18,%esp
}
  8014d0:	c9                   	leave  
  8014d1:	c3                   	ret    

008014d2 <sys_bypassPageFault>:
void sys_bypassPageFault(uint8 instrLength)
{
  8014d2:	55                   	push   %ebp
  8014d3:	89 e5                	mov    %esp,%ebp
  8014d5:	83 ec 04             	sub    $0x4,%esp
  8014d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8014db:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_bypassPageFault, instrLength, 0, 0, 0, 0);
  8014de:	0f b6 45 fc          	movzbl -0x4(%ebp),%eax
  8014e2:	6a 00                	push   $0x0
  8014e4:	6a 00                	push   $0x0
  8014e6:	6a 00                	push   $0x0
  8014e8:	6a 00                	push   $0x0
  8014ea:	50                   	push   %eax
  8014eb:	6a 24                	push   $0x24
  8014ed:	e8 b1 fb ff ff       	call   8010a3 <syscall>
  8014f2:	83 c4 18             	add    $0x18,%esp
	return ;
  8014f5:	90                   	nop
}
  8014f6:	c9                   	leave  
  8014f7:	c3                   	ret    

008014f8 <rsttst>:
void rsttst()
{
  8014f8:	55                   	push   %ebp
  8014f9:	89 e5                	mov    %esp,%ebp
	syscall(SYS_rsttst, 0, 0, 0, 0, 0);
  8014fb:	6a 00                	push   $0x0
  8014fd:	6a 00                	push   $0x0
  8014ff:	6a 00                	push   $0x0
  801501:	6a 00                	push   $0x0
  801503:	6a 00                	push   $0x0
  801505:	6a 26                	push   $0x26
  801507:	e8 97 fb ff ff       	call   8010a3 <syscall>
  80150c:	83 c4 18             	add    $0x18,%esp
	return ;
  80150f:	90                   	nop
}
  801510:	c9                   	leave  
  801511:	c3                   	ret    

00801512 <tst>:
void tst(uint32 n, uint32 v1, uint32 v2, char c, int inv)
{
  801512:	55                   	push   %ebp
  801513:	89 e5                	mov    %esp,%ebp
  801515:	83 ec 04             	sub    $0x4,%esp
  801518:	8b 45 14             	mov    0x14(%ebp),%eax
  80151b:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_testNum, n, v1, v2, c, inv);
  80151e:	8b 55 18             	mov    0x18(%ebp),%edx
  801521:	0f be 45 fc          	movsbl -0x4(%ebp),%eax
  801525:	52                   	push   %edx
  801526:	50                   	push   %eax
  801527:	ff 75 10             	pushl  0x10(%ebp)
  80152a:	ff 75 0c             	pushl  0xc(%ebp)
  80152d:	ff 75 08             	pushl  0x8(%ebp)
  801530:	6a 25                	push   $0x25
  801532:	e8 6c fb ff ff       	call   8010a3 <syscall>
  801537:	83 c4 18             	add    $0x18,%esp
	return ;
  80153a:	90                   	nop
}
  80153b:	c9                   	leave  
  80153c:	c3                   	ret    

0080153d <chktst>:
void chktst(uint32 n)
{
  80153d:	55                   	push   %ebp
  80153e:	89 e5                	mov    %esp,%ebp
	syscall(SYS_chktst, n, 0, 0, 0, 0);
  801540:	6a 00                	push   $0x0
  801542:	6a 00                	push   $0x0
  801544:	6a 00                	push   $0x0
  801546:	6a 00                	push   $0x0
  801548:	ff 75 08             	pushl  0x8(%ebp)
  80154b:	6a 27                	push   $0x27
  80154d:	e8 51 fb ff ff       	call   8010a3 <syscall>
  801552:	83 c4 18             	add    $0x18,%esp
	return ;
  801555:	90                   	nop
}
  801556:	c9                   	leave  
  801557:	c3                   	ret    

00801558 <inctst>:

void inctst()
{
  801558:	55                   	push   %ebp
  801559:	89 e5                	mov    %esp,%ebp
	syscall(SYS_inctst, 0, 0, 0, 0, 0);
  80155b:	6a 00                	push   $0x0
  80155d:	6a 00                	push   $0x0
  80155f:	6a 00                	push   $0x0
  801561:	6a 00                	push   $0x0
  801563:	6a 00                	push   $0x0
  801565:	6a 28                	push   $0x28
  801567:	e8 37 fb ff ff       	call   8010a3 <syscall>
  80156c:	83 c4 18             	add    $0x18,%esp
	return ;
  80156f:	90                   	nop
}
  801570:	c9                   	leave  
  801571:	c3                   	ret    

00801572 <gettst>:
uint32 gettst()
{
  801572:	55                   	push   %ebp
  801573:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_gettst, 0, 0, 0, 0, 0);
  801575:	6a 00                	push   $0x0
  801577:	6a 00                	push   $0x0
  801579:	6a 00                	push   $0x0
  80157b:	6a 00                	push   $0x0
  80157d:	6a 00                	push   $0x0
  80157f:	6a 29                	push   $0x29
  801581:	e8 1d fb ff ff       	call   8010a3 <syscall>
  801586:	83 c4 18             	add    $0x18,%esp
}
  801589:	c9                   	leave  
  80158a:	c3                   	ret    

0080158b <sys_isUHeapPlacementStrategyFIRSTFIT>:


//2015
uint32 sys_isUHeapPlacementStrategyFIRSTFIT()
{
  80158b:	55                   	push   %ebp
  80158c:	89 e5                	mov    %esp,%ebp
  80158e:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  801591:	6a 00                	push   $0x0
  801593:	6a 00                	push   $0x0
  801595:	6a 00                	push   $0x0
  801597:	6a 00                	push   $0x0
  801599:	6a 00                	push   $0x0
  80159b:	6a 2a                	push   $0x2a
  80159d:	e8 01 fb ff ff       	call   8010a3 <syscall>
  8015a2:	83 c4 18             	add    $0x18,%esp
  8015a5:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_FIRSTFIT)
  8015a8:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
  8015ac:	75 07                	jne    8015b5 <sys_isUHeapPlacementStrategyFIRSTFIT+0x2a>
		return 1;
  8015ae:	b8 01 00 00 00       	mov    $0x1,%eax
  8015b3:	eb 05                	jmp    8015ba <sys_isUHeapPlacementStrategyFIRSTFIT+0x2f>
	else
		return 0;
  8015b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015ba:	c9                   	leave  
  8015bb:	c3                   	ret    

008015bc <sys_isUHeapPlacementStrategyBESTFIT>:
uint32 sys_isUHeapPlacementStrategyBESTFIT()
{
  8015bc:	55                   	push   %ebp
  8015bd:	89 e5                	mov    %esp,%ebp
  8015bf:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  8015c2:	6a 00                	push   $0x0
  8015c4:	6a 00                	push   $0x0
  8015c6:	6a 00                	push   $0x0
  8015c8:	6a 00                	push   $0x0
  8015ca:	6a 00                	push   $0x0
  8015cc:	6a 2a                	push   $0x2a
  8015ce:	e8 d0 fa ff ff       	call   8010a3 <syscall>
  8015d3:	83 c4 18             	add    $0x18,%esp
  8015d6:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_BESTFIT)
  8015d9:	83 7d fc 02          	cmpl   $0x2,-0x4(%ebp)
  8015dd:	75 07                	jne    8015e6 <sys_isUHeapPlacementStrategyBESTFIT+0x2a>
		return 1;
  8015df:	b8 01 00 00 00       	mov    $0x1,%eax
  8015e4:	eb 05                	jmp    8015eb <sys_isUHeapPlacementStrategyBESTFIT+0x2f>
	else
		return 0;
  8015e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015eb:	c9                   	leave  
  8015ec:	c3                   	ret    

008015ed <sys_isUHeapPlacementStrategyNEXTFIT>:
uint32 sys_isUHeapPlacementStrategyNEXTFIT()
{
  8015ed:	55                   	push   %ebp
  8015ee:	89 e5                	mov    %esp,%ebp
  8015f0:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  8015f3:	6a 00                	push   $0x0
  8015f5:	6a 00                	push   $0x0
  8015f7:	6a 00                	push   $0x0
  8015f9:	6a 00                	push   $0x0
  8015fb:	6a 00                	push   $0x0
  8015fd:	6a 2a                	push   $0x2a
  8015ff:	e8 9f fa ff ff       	call   8010a3 <syscall>
  801604:	83 c4 18             	add    $0x18,%esp
  801607:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_NEXTFIT)
  80160a:	83 7d fc 03          	cmpl   $0x3,-0x4(%ebp)
  80160e:	75 07                	jne    801617 <sys_isUHeapPlacementStrategyNEXTFIT+0x2a>
		return 1;
  801610:	b8 01 00 00 00       	mov    $0x1,%eax
  801615:	eb 05                	jmp    80161c <sys_isUHeapPlacementStrategyNEXTFIT+0x2f>
	else
		return 0;
  801617:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80161c:	c9                   	leave  
  80161d:	c3                   	ret    

0080161e <sys_isUHeapPlacementStrategyWORSTFIT>:
uint32 sys_isUHeapPlacementStrategyWORSTFIT()
{
  80161e:	55                   	push   %ebp
  80161f:	89 e5                	mov    %esp,%ebp
  801621:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  801624:	6a 00                	push   $0x0
  801626:	6a 00                	push   $0x0
  801628:	6a 00                	push   $0x0
  80162a:	6a 00                	push   $0x0
  80162c:	6a 00                	push   $0x0
  80162e:	6a 2a                	push   $0x2a
  801630:	e8 6e fa ff ff       	call   8010a3 <syscall>
  801635:	83 c4 18             	add    $0x18,%esp
  801638:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_WORSTFIT)
  80163b:	83 7d fc 04          	cmpl   $0x4,-0x4(%ebp)
  80163f:	75 07                	jne    801648 <sys_isUHeapPlacementStrategyWORSTFIT+0x2a>
		return 1;
  801641:	b8 01 00 00 00       	mov    $0x1,%eax
  801646:	eb 05                	jmp    80164d <sys_isUHeapPlacementStrategyWORSTFIT+0x2f>
	else
		return 0;
  801648:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80164d:	c9                   	leave  
  80164e:	c3                   	ret    

0080164f <sys_set_uheap_strategy>:

void sys_set_uheap_strategy(uint32 heapStrategy)
{
  80164f:	55                   	push   %ebp
  801650:	89 e5                	mov    %esp,%ebp
	syscall(SYS_set_heap_strategy, heapStrategy, 0, 0, 0, 0);
  801652:	6a 00                	push   $0x0
  801654:	6a 00                	push   $0x0
  801656:	6a 00                	push   $0x0
  801658:	6a 00                	push   $0x0
  80165a:	ff 75 08             	pushl  0x8(%ebp)
  80165d:	6a 2b                	push   $0x2b
  80165f:	e8 3f fa ff ff       	call   8010a3 <syscall>
  801664:	83 c4 18             	add    $0x18,%esp
	return ;
  801667:	90                   	nop
}
  801668:	c9                   	leave  
  801669:	c3                   	ret    

0080166a <sys_check_LRU_lists>:

//2020
int sys_check_LRU_lists(uint32* active_list_content, uint32* second_list_content, int actual_active_list_size, int actual_second_list_size)
{
  80166a:	55                   	push   %ebp
  80166b:	89 e5                	mov    %esp,%ebp
  80166d:	53                   	push   %ebx
	return syscall(SYS_check_LRU_lists, (uint32)active_list_content, (uint32)second_list_content, (uint32)actual_active_list_size, (uint32)actual_second_list_size, 0);
  80166e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801671:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801674:	8b 55 0c             	mov    0xc(%ebp),%edx
  801677:	8b 45 08             	mov    0x8(%ebp),%eax
  80167a:	6a 00                	push   $0x0
  80167c:	53                   	push   %ebx
  80167d:	51                   	push   %ecx
  80167e:	52                   	push   %edx
  80167f:	50                   	push   %eax
  801680:	6a 2c                	push   $0x2c
  801682:	e8 1c fa ff ff       	call   8010a3 <syscall>
  801687:	83 c4 18             	add    $0x18,%esp
}
  80168a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80168d:	c9                   	leave  
  80168e:	c3                   	ret    

0080168f <sys_check_LRU_lists_free>:

int sys_check_LRU_lists_free(uint32* list_content, int list_size)
{
  80168f:	55                   	push   %ebp
  801690:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_check_LRU_lists_free, (uint32)list_content, (uint32)list_size , 0, 0, 0);
  801692:	8b 55 0c             	mov    0xc(%ebp),%edx
  801695:	8b 45 08             	mov    0x8(%ebp),%eax
  801698:	6a 00                	push   $0x0
  80169a:	6a 00                	push   $0x0
  80169c:	6a 00                	push   $0x0
  80169e:	52                   	push   %edx
  80169f:	50                   	push   %eax
  8016a0:	6a 2d                	push   $0x2d
  8016a2:	e8 fc f9 ff ff       	call   8010a3 <syscall>
  8016a7:	83 c4 18             	add    $0x18,%esp
}
  8016aa:	c9                   	leave  
  8016ab:	c3                   	ret    

008016ac <sys_check_WS_list>:

int sys_check_WS_list(uint32* WS_list_content, int actual_WS_list_size, uint32 last_WS_element_content, bool chk_in_order)
{
  8016ac:	55                   	push   %ebp
  8016ad:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_check_WS_list, (uint32)WS_list_content, (uint32)actual_WS_list_size , last_WS_element_content, (uint32)chk_in_order, 0);
  8016af:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8016b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b8:	6a 00                	push   $0x0
  8016ba:	51                   	push   %ecx
  8016bb:	ff 75 10             	pushl  0x10(%ebp)
  8016be:	52                   	push   %edx
  8016bf:	50                   	push   %eax
  8016c0:	6a 2e                	push   $0x2e
  8016c2:	e8 dc f9 ff ff       	call   8010a3 <syscall>
  8016c7:	83 c4 18             	add    $0x18,%esp
}
  8016ca:	c9                   	leave  
  8016cb:	c3                   	ret    

008016cc <sys_allocate_chunk>:
void sys_allocate_chunk(uint32 virtual_address, uint32 size, uint32 perms)
{
  8016cc:	55                   	push   %ebp
  8016cd:	89 e5                	mov    %esp,%ebp
	syscall(SYS_allocate_chunk_in_mem, virtual_address, size, perms, 0, 0);
  8016cf:	6a 00                	push   $0x0
  8016d1:	6a 00                	push   $0x0
  8016d3:	ff 75 10             	pushl  0x10(%ebp)
  8016d6:	ff 75 0c             	pushl  0xc(%ebp)
  8016d9:	ff 75 08             	pushl  0x8(%ebp)
  8016dc:	6a 0f                	push   $0xf
  8016de:	e8 c0 f9 ff ff       	call   8010a3 <syscall>
  8016e3:	83 c4 18             	add    $0x18,%esp
	return ;
  8016e6:	90                   	nop
}
  8016e7:	c9                   	leave  
  8016e8:	c3                   	ret    

008016e9 <sys_sbrk>:


/*2023*/
//TODO: [PROJECT'23.MS1 - #3] [2] SYSTEM CALLS - Implement these system calls
void* sys_sbrk(int increment)
{
  8016e9:	55                   	push   %ebp
  8016ea:	89 e5                	mov    %esp,%ebp
  8016ec:	83 ec 08             	sub    $0x8,%esp
	//Comment the following line before start coding...
	panic("not implemented yet");
  8016ef:	83 ec 04             	sub    $0x4,%esp
  8016f2:	68 50 20 80 00       	push   $0x802050
  8016f7:	68 54 01 00 00       	push   $0x154
  8016fc:	68 64 20 80 00       	push   $0x802064
  801701:	e8 3a 00 00 00       	call   801740 <_panic>

00801706 <sys_free_user_mem>:
	return NULL;
}

void sys_free_user_mem(uint32 virtual_address, uint32 size)
{
  801706:	55                   	push   %ebp
  801707:	89 e5                	mov    %esp,%ebp
  801709:	83 ec 08             	sub    $0x8,%esp
	//Comment the following line before start coding...
	panic("not implemented yet");
  80170c:	83 ec 04             	sub    $0x4,%esp
  80170f:	68 50 20 80 00       	push   $0x802050
  801714:	68 5b 01 00 00       	push   $0x15b
  801719:	68 64 20 80 00       	push   $0x802064
  80171e:	e8 1d 00 00 00       	call   801740 <_panic>

00801723 <sys_allocate_user_mem>:
}

void sys_allocate_user_mem(uint32 virtual_address, uint32 size)
{
  801723:	55                   	push   %ebp
  801724:	89 e5                	mov    %esp,%ebp
  801726:	83 ec 08             	sub    $0x8,%esp
	//Comment the following line before start coding...
	panic("not implemented yet");
  801729:	83 ec 04             	sub    $0x4,%esp
  80172c:	68 50 20 80 00       	push   $0x802050
  801731:	68 61 01 00 00       	push   $0x161
  801736:	68 64 20 80 00       	push   $0x802064
  80173b:	e8 00 00 00 00       	call   801740 <_panic>

00801740 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes FOS to enter the FOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  801740:	55                   	push   %ebp
  801741:	89 e5                	mov    %esp,%ebp
  801743:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	va_start(ap, fmt);
  801746:	8d 45 10             	lea    0x10(%ebp),%eax
  801749:	83 c0 04             	add    $0x4,%eax
  80174c:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// Print the panic message
	if (argv0)
  80174f:	a1 18 31 80 00       	mov    0x803118,%eax
  801754:	85 c0                	test   %eax,%eax
  801756:	74 16                	je     80176e <_panic+0x2e>
		cprintf("%s: ", argv0);
  801758:	a1 18 31 80 00       	mov    0x803118,%eax
  80175d:	83 ec 08             	sub    $0x8,%esp
  801760:	50                   	push   %eax
  801761:	68 74 20 80 00       	push   $0x802074
  801766:	e8 15 eb ff ff       	call   800280 <cprintf>
  80176b:	83 c4 10             	add    $0x10,%esp
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  80176e:	a1 00 30 80 00       	mov    0x803000,%eax
  801773:	ff 75 0c             	pushl  0xc(%ebp)
  801776:	ff 75 08             	pushl  0x8(%ebp)
  801779:	50                   	push   %eax
  80177a:	68 79 20 80 00       	push   $0x802079
  80177f:	e8 fc ea ff ff       	call   800280 <cprintf>
  801784:	83 c4 10             	add    $0x10,%esp
	vcprintf(fmt, ap);
  801787:	8b 45 10             	mov    0x10(%ebp),%eax
  80178a:	83 ec 08             	sub    $0x8,%esp
  80178d:	ff 75 f4             	pushl  -0xc(%ebp)
  801790:	50                   	push   %eax
  801791:	e8 7f ea ff ff       	call   800215 <vcprintf>
  801796:	83 c4 10             	add    $0x10,%esp
	vcprintf("\n", NULL);
  801799:	83 ec 08             	sub    $0x8,%esp
  80179c:	6a 00                	push   $0x0
  80179e:	68 95 20 80 00       	push   $0x802095
  8017a3:	e8 6d ea ff ff       	call   800215 <vcprintf>
  8017a8:	83 c4 10             	add    $0x10,%esp
	// Cause a breakpoint exception
//	while (1);
//		asm volatile("int3");

	//2013: exit the panic env only
	exit() ;
  8017ab:	e8 ee e9 ff ff       	call   80019e <exit>

	// should not return here
	while (1) ;
  8017b0:	eb fe                	jmp    8017b0 <_panic+0x70>

008017b2 <CheckWSArrayWithoutLastIndex>:
}

void CheckWSArrayWithoutLastIndex(uint32 *expectedPages, int arraySize)
{
  8017b2:	55                   	push   %ebp
  8017b3:	89 e5                	mov    %esp,%ebp
  8017b5:	83 ec 28             	sub    $0x28,%esp
	if (arraySize != myEnv->page_WS_max_size)
  8017b8:	a1 20 30 80 00       	mov    0x803020,%eax
  8017bd:	8b 90 7c d5 01 00    	mov    0x1d57c(%eax),%edx
  8017c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017c6:	39 c2                	cmp    %eax,%edx
  8017c8:	74 14                	je     8017de <CheckWSArrayWithoutLastIndex+0x2c>
	{
		panic("number of expected pages SHOULD BE EQUAL to max WS size... review your TA!!");
  8017ca:	83 ec 04             	sub    $0x4,%esp
  8017cd:	68 98 20 80 00       	push   $0x802098
  8017d2:	6a 26                	push   $0x26
  8017d4:	68 e4 20 80 00       	push   $0x8020e4
  8017d9:	e8 62 ff ff ff       	call   801740 <_panic>
	}
	int expectedNumOfEmptyLocs = 0;
  8017de:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	for (int e = 0; e < arraySize; e++) {
  8017e5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8017ec:	e9 c5 00 00 00       	jmp    8018b6 <CheckWSArrayWithoutLastIndex+0x104>
		if (expectedPages[e] == 0) {
  8017f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8017fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fe:	01 d0                	add    %edx,%eax
  801800:	8b 00                	mov    (%eax),%eax
  801802:	85 c0                	test   %eax,%eax
  801804:	75 08                	jne    80180e <CheckWSArrayWithoutLastIndex+0x5c>
			expectedNumOfEmptyLocs++;
  801806:	ff 45 f4             	incl   -0xc(%ebp)
			continue;
  801809:	e9 a5 00 00 00       	jmp    8018b3 <CheckWSArrayWithoutLastIndex+0x101>
		}
		int found = 0;
  80180e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  801815:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  80181c:	eb 69                	jmp    801887 <CheckWSArrayWithoutLastIndex+0xd5>
			if (myEnv->__uptr_pws[w].empty == 0) {
  80181e:	a1 20 30 80 00       	mov    0x803020,%eax
  801823:	8b 88 6c da 01 00    	mov    0x1da6c(%eax),%ecx
  801829:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80182c:	89 d0                	mov    %edx,%eax
  80182e:	01 c0                	add    %eax,%eax
  801830:	01 d0                	add    %edx,%eax
  801832:	c1 e0 03             	shl    $0x3,%eax
  801835:	01 c8                	add    %ecx,%eax
  801837:	8a 40 04             	mov    0x4(%eax),%al
  80183a:	84 c0                	test   %al,%al
  80183c:	75 46                	jne    801884 <CheckWSArrayWithoutLastIndex+0xd2>
				if (ROUNDDOWN(myEnv->__uptr_pws[w].virtual_address, PAGE_SIZE)
  80183e:	a1 20 30 80 00       	mov    0x803020,%eax
  801843:	8b 88 6c da 01 00    	mov    0x1da6c(%eax),%ecx
  801849:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80184c:	89 d0                	mov    %edx,%eax
  80184e:	01 c0                	add    %eax,%eax
  801850:	01 d0                	add    %edx,%eax
  801852:	c1 e0 03             	shl    $0x3,%eax
  801855:	01 c8                	add    %ecx,%eax
  801857:	8b 00                	mov    (%eax),%eax
  801859:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80185c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80185f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801864:	89 c2                	mov    %eax,%edx
						== expectedPages[e]) {
  801866:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801869:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801870:	8b 45 08             	mov    0x8(%ebp),%eax
  801873:	01 c8                	add    %ecx,%eax
  801875:	8b 00                	mov    (%eax),%eax
			continue;
		}
		int found = 0;
		for (int w = 0; w < myEnv->page_WS_max_size; w++) {
			if (myEnv->__uptr_pws[w].empty == 0) {
				if (ROUNDDOWN(myEnv->__uptr_pws[w].virtual_address, PAGE_SIZE)
  801877:	39 c2                	cmp    %eax,%edx
  801879:	75 09                	jne    801884 <CheckWSArrayWithoutLastIndex+0xd2>
						== expectedPages[e]) {
					found = 1;
  80187b:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
					break;
  801882:	eb 15                	jmp    801899 <CheckWSArrayWithoutLastIndex+0xe7>
		if (expectedPages[e] == 0) {
			expectedNumOfEmptyLocs++;
			continue;
		}
		int found = 0;
		for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  801884:	ff 45 e8             	incl   -0x18(%ebp)
  801887:	a1 20 30 80 00       	mov    0x803020,%eax
  80188c:	8b 90 7c d5 01 00    	mov    0x1d57c(%eax),%edx
  801892:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801895:	39 c2                	cmp    %eax,%edx
  801897:	77 85                	ja     80181e <CheckWSArrayWithoutLastIndex+0x6c>
					found = 1;
					break;
				}
			}
		}
		if (!found)
  801899:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  80189d:	75 14                	jne    8018b3 <CheckWSArrayWithoutLastIndex+0x101>
			panic(
  80189f:	83 ec 04             	sub    $0x4,%esp
  8018a2:	68 f0 20 80 00       	push   $0x8020f0
  8018a7:	6a 3a                	push   $0x3a
  8018a9:	68 e4 20 80 00       	push   $0x8020e4
  8018ae:	e8 8d fe ff ff       	call   801740 <_panic>
	if (arraySize != myEnv->page_WS_max_size)
	{
		panic("number of expected pages SHOULD BE EQUAL to max WS size... review your TA!!");
	}
	int expectedNumOfEmptyLocs = 0;
	for (int e = 0; e < arraySize; e++) {
  8018b3:	ff 45 f0             	incl   -0x10(%ebp)
  8018b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018b9:	3b 45 0c             	cmp    0xc(%ebp),%eax
  8018bc:	0f 8c 2f ff ff ff    	jl     8017f1 <CheckWSArrayWithoutLastIndex+0x3f>
		}
		if (!found)
			panic(
					"PAGE WS entry checking failed... trace it by printing page WS before & after fault");
	}
	int actualNumOfEmptyLocs = 0;
  8018c2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  8018c9:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8018d0:	eb 26                	jmp    8018f8 <CheckWSArrayWithoutLastIndex+0x146>
		if (myEnv->__uptr_pws[w].empty == 1) {
  8018d2:	a1 20 30 80 00       	mov    0x803020,%eax
  8018d7:	8b 88 6c da 01 00    	mov    0x1da6c(%eax),%ecx
  8018dd:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8018e0:	89 d0                	mov    %edx,%eax
  8018e2:	01 c0                	add    %eax,%eax
  8018e4:	01 d0                	add    %edx,%eax
  8018e6:	c1 e0 03             	shl    $0x3,%eax
  8018e9:	01 c8                	add    %ecx,%eax
  8018eb:	8a 40 04             	mov    0x4(%eax),%al
  8018ee:	3c 01                	cmp    $0x1,%al
  8018f0:	75 03                	jne    8018f5 <CheckWSArrayWithoutLastIndex+0x143>
			actualNumOfEmptyLocs++;
  8018f2:	ff 45 e4             	incl   -0x1c(%ebp)
		if (!found)
			panic(
					"PAGE WS entry checking failed... trace it by printing page WS before & after fault");
	}
	int actualNumOfEmptyLocs = 0;
	for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  8018f5:	ff 45 e0             	incl   -0x20(%ebp)
  8018f8:	a1 20 30 80 00       	mov    0x803020,%eax
  8018fd:	8b 90 7c d5 01 00    	mov    0x1d57c(%eax),%edx
  801903:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801906:	39 c2                	cmp    %eax,%edx
  801908:	77 c8                	ja     8018d2 <CheckWSArrayWithoutLastIndex+0x120>
		if (myEnv->__uptr_pws[w].empty == 1) {
			actualNumOfEmptyLocs++;
		}
	}
	if (expectedNumOfEmptyLocs != actualNumOfEmptyLocs)
  80190a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80190d:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
  801910:	74 14                	je     801926 <CheckWSArrayWithoutLastIndex+0x174>
		panic(
  801912:	83 ec 04             	sub    $0x4,%esp
  801915:	68 44 21 80 00       	push   $0x802144
  80191a:	6a 44                	push   $0x44
  80191c:	68 e4 20 80 00       	push   $0x8020e4
  801921:	e8 1a fe ff ff       	call   801740 <_panic>
				"PAGE WS entry checking failed... number of empty locations is not correct");
}
  801926:	90                   	nop
  801927:	c9                   	leave  
  801928:	c3                   	ret    
  801929:	66 90                	xchg   %ax,%ax
  80192b:	90                   	nop

0080192c <__udivdi3>:
  80192c:	55                   	push   %ebp
  80192d:	57                   	push   %edi
  80192e:	56                   	push   %esi
  80192f:	53                   	push   %ebx
  801930:	83 ec 1c             	sub    $0x1c,%esp
  801933:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801937:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  80193b:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80193f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801943:	89 ca                	mov    %ecx,%edx
  801945:	89 f8                	mov    %edi,%eax
  801947:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80194b:	85 f6                	test   %esi,%esi
  80194d:	75 2d                	jne    80197c <__udivdi3+0x50>
  80194f:	39 cf                	cmp    %ecx,%edi
  801951:	77 65                	ja     8019b8 <__udivdi3+0x8c>
  801953:	89 fd                	mov    %edi,%ebp
  801955:	85 ff                	test   %edi,%edi
  801957:	75 0b                	jne    801964 <__udivdi3+0x38>
  801959:	b8 01 00 00 00       	mov    $0x1,%eax
  80195e:	31 d2                	xor    %edx,%edx
  801960:	f7 f7                	div    %edi
  801962:	89 c5                	mov    %eax,%ebp
  801964:	31 d2                	xor    %edx,%edx
  801966:	89 c8                	mov    %ecx,%eax
  801968:	f7 f5                	div    %ebp
  80196a:	89 c1                	mov    %eax,%ecx
  80196c:	89 d8                	mov    %ebx,%eax
  80196e:	f7 f5                	div    %ebp
  801970:	89 cf                	mov    %ecx,%edi
  801972:	89 fa                	mov    %edi,%edx
  801974:	83 c4 1c             	add    $0x1c,%esp
  801977:	5b                   	pop    %ebx
  801978:	5e                   	pop    %esi
  801979:	5f                   	pop    %edi
  80197a:	5d                   	pop    %ebp
  80197b:	c3                   	ret    
  80197c:	39 ce                	cmp    %ecx,%esi
  80197e:	77 28                	ja     8019a8 <__udivdi3+0x7c>
  801980:	0f bd fe             	bsr    %esi,%edi
  801983:	83 f7 1f             	xor    $0x1f,%edi
  801986:	75 40                	jne    8019c8 <__udivdi3+0x9c>
  801988:	39 ce                	cmp    %ecx,%esi
  80198a:	72 0a                	jb     801996 <__udivdi3+0x6a>
  80198c:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801990:	0f 87 9e 00 00 00    	ja     801a34 <__udivdi3+0x108>
  801996:	b8 01 00 00 00       	mov    $0x1,%eax
  80199b:	89 fa                	mov    %edi,%edx
  80199d:	83 c4 1c             	add    $0x1c,%esp
  8019a0:	5b                   	pop    %ebx
  8019a1:	5e                   	pop    %esi
  8019a2:	5f                   	pop    %edi
  8019a3:	5d                   	pop    %ebp
  8019a4:	c3                   	ret    
  8019a5:	8d 76 00             	lea    0x0(%esi),%esi
  8019a8:	31 ff                	xor    %edi,%edi
  8019aa:	31 c0                	xor    %eax,%eax
  8019ac:	89 fa                	mov    %edi,%edx
  8019ae:	83 c4 1c             	add    $0x1c,%esp
  8019b1:	5b                   	pop    %ebx
  8019b2:	5e                   	pop    %esi
  8019b3:	5f                   	pop    %edi
  8019b4:	5d                   	pop    %ebp
  8019b5:	c3                   	ret    
  8019b6:	66 90                	xchg   %ax,%ax
  8019b8:	89 d8                	mov    %ebx,%eax
  8019ba:	f7 f7                	div    %edi
  8019bc:	31 ff                	xor    %edi,%edi
  8019be:	89 fa                	mov    %edi,%edx
  8019c0:	83 c4 1c             	add    $0x1c,%esp
  8019c3:	5b                   	pop    %ebx
  8019c4:	5e                   	pop    %esi
  8019c5:	5f                   	pop    %edi
  8019c6:	5d                   	pop    %ebp
  8019c7:	c3                   	ret    
  8019c8:	bd 20 00 00 00       	mov    $0x20,%ebp
  8019cd:	89 eb                	mov    %ebp,%ebx
  8019cf:	29 fb                	sub    %edi,%ebx
  8019d1:	89 f9                	mov    %edi,%ecx
  8019d3:	d3 e6                	shl    %cl,%esi
  8019d5:	89 c5                	mov    %eax,%ebp
  8019d7:	88 d9                	mov    %bl,%cl
  8019d9:	d3 ed                	shr    %cl,%ebp
  8019db:	89 e9                	mov    %ebp,%ecx
  8019dd:	09 f1                	or     %esi,%ecx
  8019df:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8019e3:	89 f9                	mov    %edi,%ecx
  8019e5:	d3 e0                	shl    %cl,%eax
  8019e7:	89 c5                	mov    %eax,%ebp
  8019e9:	89 d6                	mov    %edx,%esi
  8019eb:	88 d9                	mov    %bl,%cl
  8019ed:	d3 ee                	shr    %cl,%esi
  8019ef:	89 f9                	mov    %edi,%ecx
  8019f1:	d3 e2                	shl    %cl,%edx
  8019f3:	8b 44 24 08          	mov    0x8(%esp),%eax
  8019f7:	88 d9                	mov    %bl,%cl
  8019f9:	d3 e8                	shr    %cl,%eax
  8019fb:	09 c2                	or     %eax,%edx
  8019fd:	89 d0                	mov    %edx,%eax
  8019ff:	89 f2                	mov    %esi,%edx
  801a01:	f7 74 24 0c          	divl   0xc(%esp)
  801a05:	89 d6                	mov    %edx,%esi
  801a07:	89 c3                	mov    %eax,%ebx
  801a09:	f7 e5                	mul    %ebp
  801a0b:	39 d6                	cmp    %edx,%esi
  801a0d:	72 19                	jb     801a28 <__udivdi3+0xfc>
  801a0f:	74 0b                	je     801a1c <__udivdi3+0xf0>
  801a11:	89 d8                	mov    %ebx,%eax
  801a13:	31 ff                	xor    %edi,%edi
  801a15:	e9 58 ff ff ff       	jmp    801972 <__udivdi3+0x46>
  801a1a:	66 90                	xchg   %ax,%ax
  801a1c:	8b 54 24 08          	mov    0x8(%esp),%edx
  801a20:	89 f9                	mov    %edi,%ecx
  801a22:	d3 e2                	shl    %cl,%edx
  801a24:	39 c2                	cmp    %eax,%edx
  801a26:	73 e9                	jae    801a11 <__udivdi3+0xe5>
  801a28:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801a2b:	31 ff                	xor    %edi,%edi
  801a2d:	e9 40 ff ff ff       	jmp    801972 <__udivdi3+0x46>
  801a32:	66 90                	xchg   %ax,%ax
  801a34:	31 c0                	xor    %eax,%eax
  801a36:	e9 37 ff ff ff       	jmp    801972 <__udivdi3+0x46>
  801a3b:	90                   	nop

00801a3c <__umoddi3>:
  801a3c:	55                   	push   %ebp
  801a3d:	57                   	push   %edi
  801a3e:	56                   	push   %esi
  801a3f:	53                   	push   %ebx
  801a40:	83 ec 1c             	sub    $0x1c,%esp
  801a43:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801a47:	8b 74 24 34          	mov    0x34(%esp),%esi
  801a4b:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801a4f:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801a53:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a57:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801a5b:	89 f3                	mov    %esi,%ebx
  801a5d:	89 fa                	mov    %edi,%edx
  801a5f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801a63:	89 34 24             	mov    %esi,(%esp)
  801a66:	85 c0                	test   %eax,%eax
  801a68:	75 1a                	jne    801a84 <__umoddi3+0x48>
  801a6a:	39 f7                	cmp    %esi,%edi
  801a6c:	0f 86 a2 00 00 00    	jbe    801b14 <__umoddi3+0xd8>
  801a72:	89 c8                	mov    %ecx,%eax
  801a74:	89 f2                	mov    %esi,%edx
  801a76:	f7 f7                	div    %edi
  801a78:	89 d0                	mov    %edx,%eax
  801a7a:	31 d2                	xor    %edx,%edx
  801a7c:	83 c4 1c             	add    $0x1c,%esp
  801a7f:	5b                   	pop    %ebx
  801a80:	5e                   	pop    %esi
  801a81:	5f                   	pop    %edi
  801a82:	5d                   	pop    %ebp
  801a83:	c3                   	ret    
  801a84:	39 f0                	cmp    %esi,%eax
  801a86:	0f 87 ac 00 00 00    	ja     801b38 <__umoddi3+0xfc>
  801a8c:	0f bd e8             	bsr    %eax,%ebp
  801a8f:	83 f5 1f             	xor    $0x1f,%ebp
  801a92:	0f 84 ac 00 00 00    	je     801b44 <__umoddi3+0x108>
  801a98:	bf 20 00 00 00       	mov    $0x20,%edi
  801a9d:	29 ef                	sub    %ebp,%edi
  801a9f:	89 fe                	mov    %edi,%esi
  801aa1:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801aa5:	89 e9                	mov    %ebp,%ecx
  801aa7:	d3 e0                	shl    %cl,%eax
  801aa9:	89 d7                	mov    %edx,%edi
  801aab:	89 f1                	mov    %esi,%ecx
  801aad:	d3 ef                	shr    %cl,%edi
  801aaf:	09 c7                	or     %eax,%edi
  801ab1:	89 e9                	mov    %ebp,%ecx
  801ab3:	d3 e2                	shl    %cl,%edx
  801ab5:	89 14 24             	mov    %edx,(%esp)
  801ab8:	89 d8                	mov    %ebx,%eax
  801aba:	d3 e0                	shl    %cl,%eax
  801abc:	89 c2                	mov    %eax,%edx
  801abe:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ac2:	d3 e0                	shl    %cl,%eax
  801ac4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ac8:	8b 44 24 08          	mov    0x8(%esp),%eax
  801acc:	89 f1                	mov    %esi,%ecx
  801ace:	d3 e8                	shr    %cl,%eax
  801ad0:	09 d0                	or     %edx,%eax
  801ad2:	d3 eb                	shr    %cl,%ebx
  801ad4:	89 da                	mov    %ebx,%edx
  801ad6:	f7 f7                	div    %edi
  801ad8:	89 d3                	mov    %edx,%ebx
  801ada:	f7 24 24             	mull   (%esp)
  801add:	89 c6                	mov    %eax,%esi
  801adf:	89 d1                	mov    %edx,%ecx
  801ae1:	39 d3                	cmp    %edx,%ebx
  801ae3:	0f 82 87 00 00 00    	jb     801b70 <__umoddi3+0x134>
  801ae9:	0f 84 91 00 00 00    	je     801b80 <__umoddi3+0x144>
  801aef:	8b 54 24 04          	mov    0x4(%esp),%edx
  801af3:	29 f2                	sub    %esi,%edx
  801af5:	19 cb                	sbb    %ecx,%ebx
  801af7:	89 d8                	mov    %ebx,%eax
  801af9:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  801afd:	d3 e0                	shl    %cl,%eax
  801aff:	89 e9                	mov    %ebp,%ecx
  801b01:	d3 ea                	shr    %cl,%edx
  801b03:	09 d0                	or     %edx,%eax
  801b05:	89 e9                	mov    %ebp,%ecx
  801b07:	d3 eb                	shr    %cl,%ebx
  801b09:	89 da                	mov    %ebx,%edx
  801b0b:	83 c4 1c             	add    $0x1c,%esp
  801b0e:	5b                   	pop    %ebx
  801b0f:	5e                   	pop    %esi
  801b10:	5f                   	pop    %edi
  801b11:	5d                   	pop    %ebp
  801b12:	c3                   	ret    
  801b13:	90                   	nop
  801b14:	89 fd                	mov    %edi,%ebp
  801b16:	85 ff                	test   %edi,%edi
  801b18:	75 0b                	jne    801b25 <__umoddi3+0xe9>
  801b1a:	b8 01 00 00 00       	mov    $0x1,%eax
  801b1f:	31 d2                	xor    %edx,%edx
  801b21:	f7 f7                	div    %edi
  801b23:	89 c5                	mov    %eax,%ebp
  801b25:	89 f0                	mov    %esi,%eax
  801b27:	31 d2                	xor    %edx,%edx
  801b29:	f7 f5                	div    %ebp
  801b2b:	89 c8                	mov    %ecx,%eax
  801b2d:	f7 f5                	div    %ebp
  801b2f:	89 d0                	mov    %edx,%eax
  801b31:	e9 44 ff ff ff       	jmp    801a7a <__umoddi3+0x3e>
  801b36:	66 90                	xchg   %ax,%ax
  801b38:	89 c8                	mov    %ecx,%eax
  801b3a:	89 f2                	mov    %esi,%edx
  801b3c:	83 c4 1c             	add    $0x1c,%esp
  801b3f:	5b                   	pop    %ebx
  801b40:	5e                   	pop    %esi
  801b41:	5f                   	pop    %edi
  801b42:	5d                   	pop    %ebp
  801b43:	c3                   	ret    
  801b44:	3b 04 24             	cmp    (%esp),%eax
  801b47:	72 06                	jb     801b4f <__umoddi3+0x113>
  801b49:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  801b4d:	77 0f                	ja     801b5e <__umoddi3+0x122>
  801b4f:	89 f2                	mov    %esi,%edx
  801b51:	29 f9                	sub    %edi,%ecx
  801b53:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  801b57:	89 14 24             	mov    %edx,(%esp)
  801b5a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801b5e:	8b 44 24 04          	mov    0x4(%esp),%eax
  801b62:	8b 14 24             	mov    (%esp),%edx
  801b65:	83 c4 1c             	add    $0x1c,%esp
  801b68:	5b                   	pop    %ebx
  801b69:	5e                   	pop    %esi
  801b6a:	5f                   	pop    %edi
  801b6b:	5d                   	pop    %ebp
  801b6c:	c3                   	ret    
  801b6d:	8d 76 00             	lea    0x0(%esi),%esi
  801b70:	2b 04 24             	sub    (%esp),%eax
  801b73:	19 fa                	sbb    %edi,%edx
  801b75:	89 d1                	mov    %edx,%ecx
  801b77:	89 c6                	mov    %eax,%esi
  801b79:	e9 71 ff ff ff       	jmp    801aef <__umoddi3+0xb3>
  801b7e:	66 90                	xchg   %ax,%ax
  801b80:	39 44 24 04          	cmp    %eax,0x4(%esp)
  801b84:	72 ea                	jb     801b70 <__umoddi3+0x134>
  801b86:	89 d9                	mov    %ebx,%ecx
  801b88:	e9 62 ff ff ff       	jmp    801aef <__umoddi3+0xb3>
