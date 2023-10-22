
obj/user/fos_factorial:     file format elf32-i386


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
  800031:	e8 95 00 00 00       	call   8000cb <libmain>
1:      jmp 1b
  800036:	eb fe                	jmp    800036 <args_exist+0x5>

00800038 <_main>:

int factorial(int n);

void
_main(void)
{
  800038:	55                   	push   %ebp
  800039:	89 e5                	mov    %esp,%ebp
  80003b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	int i1=0;
  800041:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	char buff1[256];
	atomic_readline("Please enter a number:", buff1);
  800048:	83 ec 08             	sub    $0x8,%esp
  80004b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800051:	50                   	push   %eax
  800052:	68 a0 1e 80 00       	push   $0x801ea0
  800057:	e8 08 0a 00 00       	call   800a64 <atomic_readline>
  80005c:	83 c4 10             	add    $0x10,%esp
	i1 = strtol(buff1, NULL, 10);
  80005f:	83 ec 04             	sub    $0x4,%esp
  800062:	6a 0a                	push   $0xa
  800064:	6a 00                	push   $0x0
  800066:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80006c:	50                   	push   %eax
  80006d:	e8 5a 0e 00 00       	call   800ecc <strtol>
  800072:	83 c4 10             	add    $0x10,%esp
  800075:	89 45 f4             	mov    %eax,-0xc(%ebp)

	int res = factorial(i1) ;
  800078:	83 ec 0c             	sub    $0xc,%esp
  80007b:	ff 75 f4             	pushl  -0xc(%ebp)
  80007e:	e8 1f 00 00 00       	call   8000a2 <factorial>
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	89 45 f0             	mov    %eax,-0x10(%ebp)

	atomic_cprintf("Factorial %d = %d\n",i1, res);
  800089:	83 ec 04             	sub    $0x4,%esp
  80008c:	ff 75 f0             	pushl  -0x10(%ebp)
  80008f:	ff 75 f4             	pushl  -0xc(%ebp)
  800092:	68 b7 1e 80 00       	push   $0x801eb7
  800097:	e8 75 02 00 00       	call   800311 <atomic_cprintf>
  80009c:	83 c4 10             	add    $0x10,%esp
	return;
  80009f:	90                   	nop
}
  8000a0:	c9                   	leave  
  8000a1:	c3                   	ret    

008000a2 <factorial>:


int factorial(int n)
{
  8000a2:	55                   	push   %ebp
  8000a3:	89 e5                	mov    %esp,%ebp
  8000a5:	83 ec 08             	sub    $0x8,%esp
	if (n <= 1)
  8000a8:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8000ac:	7f 07                	jg     8000b5 <factorial+0x13>
		return 1 ;
  8000ae:	b8 01 00 00 00       	mov    $0x1,%eax
  8000b3:	eb 14                	jmp    8000c9 <factorial+0x27>
	return n * factorial(n-1) ;
  8000b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8000b8:	48                   	dec    %eax
  8000b9:	83 ec 0c             	sub    $0xc,%esp
  8000bc:	50                   	push   %eax
  8000bd:	e8 e0 ff ff ff       	call   8000a2 <factorial>
  8000c2:	83 c4 10             	add    $0x10,%esp
  8000c5:	0f af 45 08          	imul   0x8(%ebp),%eax
}
  8000c9:	c9                   	leave  
  8000ca:	c3                   	ret    

008000cb <libmain>:
volatile struct Env *myEnv = NULL;
volatile char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  8000cb:	55                   	push   %ebp
  8000cc:	89 e5                	mov    %esp,%ebp
  8000ce:	83 ec 18             	sub    $0x18,%esp
	int envIndex = sys_getenvindex();
  8000d1:	e8 ae 15 00 00       	call   801684 <sys_getenvindex>
  8000d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	myEnv = &(envs[envIndex]);
  8000d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8000dc:	89 d0                	mov    %edx,%eax
  8000de:	01 c0                	add    %eax,%eax
  8000e0:	01 d0                	add    %edx,%eax
  8000e2:	01 c0                	add    %eax,%eax
  8000e4:	01 d0                	add    %edx,%eax
  8000e6:	c1 e0 02             	shl    $0x2,%eax
  8000e9:	01 d0                	add    %edx,%eax
  8000eb:	01 c0                	add    %eax,%eax
  8000ed:	01 d0                	add    %edx,%eax
  8000ef:	c1 e0 02             	shl    $0x2,%eax
  8000f2:	01 d0                	add    %edx,%eax
  8000f4:	c1 e0 02             	shl    $0x2,%eax
  8000f7:	01 d0                	add    %edx,%eax
  8000f9:	c1 e0 02             	shl    $0x2,%eax
  8000fc:	01 d0                	add    %edx,%eax
  8000fe:	c1 e0 05             	shl    $0x5,%eax
  800101:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800106:	a3 20 30 80 00       	mov    %eax,0x803020

	//SET THE PROGRAM NAME
	if (myEnv->prog_name[0] != '\0')
  80010b:	a1 20 30 80 00       	mov    0x803020,%eax
  800110:	8a 40 5c             	mov    0x5c(%eax),%al
  800113:	84 c0                	test   %al,%al
  800115:	74 0d                	je     800124 <libmain+0x59>
		binaryname = myEnv->prog_name;
  800117:	a1 20 30 80 00       	mov    0x803020,%eax
  80011c:	83 c0 5c             	add    $0x5c,%eax
  80011f:	a3 00 30 80 00       	mov    %eax,0x803000

	// set env to point at our env structure in envs[].
	// env = envs;

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800124:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800128:	7e 0a                	jle    800134 <libmain+0x69>
		binaryname = argv[0];
  80012a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80012d:	8b 00                	mov    (%eax),%eax
  80012f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	_main(argc, argv);
  800134:	83 ec 08             	sub    $0x8,%esp
  800137:	ff 75 0c             	pushl  0xc(%ebp)
  80013a:	ff 75 08             	pushl  0x8(%ebp)
  80013d:	e8 f6 fe ff ff       	call   800038 <_main>
  800142:	83 c4 10             	add    $0x10,%esp



	sys_disable_interrupt();
  800145:	e8 47 13 00 00       	call   801491 <sys_disable_interrupt>
	cprintf("**************************************\n");
  80014a:	83 ec 0c             	sub    $0xc,%esp
  80014d:	68 e4 1e 80 00       	push   $0x801ee4
  800152:	e8 8d 01 00 00       	call   8002e4 <cprintf>
  800157:	83 c4 10             	add    $0x10,%esp
	cprintf("Num of PAGE faults = %d, modif = %d\n", myEnv->pageFaultsCounter, myEnv->nModifiedPages);
  80015a:	a1 20 30 80 00       	mov    0x803020,%eax
  80015f:	8b 90 84 da 01 00    	mov    0x1da84(%eax),%edx
  800165:	a1 20 30 80 00       	mov    0x803020,%eax
  80016a:	8b 80 74 da 01 00    	mov    0x1da74(%eax),%eax
  800170:	83 ec 04             	sub    $0x4,%esp
  800173:	52                   	push   %edx
  800174:	50                   	push   %eax
  800175:	68 0c 1f 80 00       	push   $0x801f0c
  80017a:	e8 65 01 00 00       	call   8002e4 <cprintf>
  80017f:	83 c4 10             	add    $0x10,%esp
	cprintf("# PAGE IN (from disk) = %d, # PAGE OUT (on disk) = %d, # NEW PAGE ADDED (on disk) = %d\n", myEnv->nPageIn, myEnv->nPageOut,myEnv->nNewPageAdded);
  800182:	a1 20 30 80 00       	mov    0x803020,%eax
  800187:	8b 88 98 da 01 00    	mov    0x1da98(%eax),%ecx
  80018d:	a1 20 30 80 00       	mov    0x803020,%eax
  800192:	8b 90 94 da 01 00    	mov    0x1da94(%eax),%edx
  800198:	a1 20 30 80 00       	mov    0x803020,%eax
  80019d:	8b 80 90 da 01 00    	mov    0x1da90(%eax),%eax
  8001a3:	51                   	push   %ecx
  8001a4:	52                   	push   %edx
  8001a5:	50                   	push   %eax
  8001a6:	68 34 1f 80 00       	push   $0x801f34
  8001ab:	e8 34 01 00 00       	call   8002e4 <cprintf>
  8001b0:	83 c4 10             	add    $0x10,%esp
	//cprintf("Num of freeing scarce memory = %d, freeing full working set = %d\n", myEnv->freeingScarceMemCounter, myEnv->freeingFullWSCounter);
	cprintf("Num of clocks = %d\n", myEnv->nClocks);
  8001b3:	a1 20 30 80 00       	mov    0x803020,%eax
  8001b8:	8b 80 9c da 01 00    	mov    0x1da9c(%eax),%eax
  8001be:	83 ec 08             	sub    $0x8,%esp
  8001c1:	50                   	push   %eax
  8001c2:	68 8c 1f 80 00       	push   $0x801f8c
  8001c7:	e8 18 01 00 00       	call   8002e4 <cprintf>
  8001cc:	83 c4 10             	add    $0x10,%esp
	cprintf("**************************************\n");
  8001cf:	83 ec 0c             	sub    $0xc,%esp
  8001d2:	68 e4 1e 80 00       	push   $0x801ee4
  8001d7:	e8 08 01 00 00       	call   8002e4 <cprintf>
  8001dc:	83 c4 10             	add    $0x10,%esp
	sys_enable_interrupt();
  8001df:	e8 c7 12 00 00       	call   8014ab <sys_enable_interrupt>

	// exit gracefully
	exit();
  8001e4:	e8 19 00 00 00       	call   800202 <exit>
}
  8001e9:	90                   	nop
  8001ea:	c9                   	leave  
  8001eb:	c3                   	ret    

008001ec <destroy>:

#include <inc/lib.h>

void
destroy(void)
{
  8001ec:	55                   	push   %ebp
  8001ed:	89 e5                	mov    %esp,%ebp
  8001ef:	83 ec 08             	sub    $0x8,%esp
	sys_destroy_env(0);
  8001f2:	83 ec 0c             	sub    $0xc,%esp
  8001f5:	6a 00                	push   $0x0
  8001f7:	e8 54 14 00 00       	call   801650 <sys_destroy_env>
  8001fc:	83 c4 10             	add    $0x10,%esp
}
  8001ff:	90                   	nop
  800200:	c9                   	leave  
  800201:	c3                   	ret    

00800202 <exit>:

void
exit(void)
{
  800202:	55                   	push   %ebp
  800203:	89 e5                	mov    %esp,%ebp
  800205:	83 ec 08             	sub    $0x8,%esp
	sys_exit_env();
  800208:	e8 a9 14 00 00       	call   8016b6 <sys_exit_env>
}
  80020d:	90                   	nop
  80020e:	c9                   	leave  
  80020f:	c3                   	ret    

00800210 <putch>:
};

//2017:
uint8 printProgName = 0;

static void putch(int ch, struct printbuf *b) {
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	83 ec 08             	sub    $0x8,%esp
	b->buf[b->idx++] = ch;
  800216:	8b 45 0c             	mov    0xc(%ebp),%eax
  800219:	8b 00                	mov    (%eax),%eax
  80021b:	8d 48 01             	lea    0x1(%eax),%ecx
  80021e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800221:	89 0a                	mov    %ecx,(%edx)
  800223:	8b 55 08             	mov    0x8(%ebp),%edx
  800226:	88 d1                	mov    %dl,%cl
  800228:	8b 55 0c             	mov    0xc(%ebp),%edx
  80022b:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256 - 1) {
  80022f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800232:	8b 00                	mov    (%eax),%eax
  800234:	3d ff 00 00 00       	cmp    $0xff,%eax
  800239:	75 2c                	jne    800267 <putch+0x57>
		sys_cputs(b->buf, b->idx, printProgName);
  80023b:	a0 24 30 80 00       	mov    0x803024,%al
  800240:	0f b6 c0             	movzbl %al,%eax
  800243:	8b 55 0c             	mov    0xc(%ebp),%edx
  800246:	8b 12                	mov    (%edx),%edx
  800248:	89 d1                	mov    %edx,%ecx
  80024a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80024d:	83 c2 08             	add    $0x8,%edx
  800250:	83 ec 04             	sub    $0x4,%esp
  800253:	50                   	push   %eax
  800254:	51                   	push   %ecx
  800255:	52                   	push   %edx
  800256:	e8 dd 10 00 00       	call   801338 <sys_cputs>
  80025b:	83 c4 10             	add    $0x10,%esp
		b->idx = 0;
  80025e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800261:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800267:	8b 45 0c             	mov    0xc(%ebp),%eax
  80026a:	8b 40 04             	mov    0x4(%eax),%eax
  80026d:	8d 50 01             	lea    0x1(%eax),%edx
  800270:	8b 45 0c             	mov    0xc(%ebp),%eax
  800273:	89 50 04             	mov    %edx,0x4(%eax)
}
  800276:	90                   	nop
  800277:	c9                   	leave  
  800278:	c3                   	ret    

00800279 <vcprintf>:

int vcprintf(const char *fmt, va_list ap) {
  800279:	55                   	push   %ebp
  80027a:	89 e5                	mov    %esp,%ebp
  80027c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800282:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800289:	00 00 00 
	b.cnt = 0;
  80028c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800293:	00 00 00 
	vprintfmt((void*) putch, &b, fmt, ap);
  800296:	ff 75 0c             	pushl  0xc(%ebp)
  800299:	ff 75 08             	pushl  0x8(%ebp)
  80029c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002a2:	50                   	push   %eax
  8002a3:	68 10 02 80 00       	push   $0x800210
  8002a8:	e8 11 02 00 00       	call   8004be <vprintfmt>
  8002ad:	83 c4 10             	add    $0x10,%esp
	sys_cputs(b.buf, b.idx, printProgName);
  8002b0:	a0 24 30 80 00       	mov    0x803024,%al
  8002b5:	0f b6 c0             	movzbl %al,%eax
  8002b8:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
  8002be:	83 ec 04             	sub    $0x4,%esp
  8002c1:	50                   	push   %eax
  8002c2:	52                   	push   %edx
  8002c3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002c9:	83 c0 08             	add    $0x8,%eax
  8002cc:	50                   	push   %eax
  8002cd:	e8 66 10 00 00       	call   801338 <sys_cputs>
  8002d2:	83 c4 10             	add    $0x10,%esp

	printProgName = 0;
  8002d5:	c6 05 24 30 80 00 00 	movb   $0x0,0x803024
	return b.cnt;
  8002dc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8002e2:	c9                   	leave  
  8002e3:	c3                   	ret    

008002e4 <cprintf>:

int cprintf(const char *fmt, ...) {
  8002e4:	55                   	push   %ebp
  8002e5:	89 e5                	mov    %esp,%ebp
  8002e7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;
	printProgName = 1 ;
  8002ea:	c6 05 24 30 80 00 01 	movb   $0x1,0x803024
	va_start(ap, fmt);
  8002f1:	8d 45 0c             	lea    0xc(%ebp),%eax
  8002f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cnt = vcprintf(fmt, ap);
  8002f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002fa:	83 ec 08             	sub    $0x8,%esp
  8002fd:	ff 75 f4             	pushl  -0xc(%ebp)
  800300:	50                   	push   %eax
  800301:	e8 73 ff ff ff       	call   800279 <vcprintf>
  800306:	83 c4 10             	add    $0x10,%esp
  800309:	89 45 f0             	mov    %eax,-0x10(%ebp)
	va_end(ap);

	return cnt;
  80030c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  80030f:	c9                   	leave  
  800310:	c3                   	ret    

00800311 <atomic_cprintf>:

int atomic_cprintf(const char *fmt, ...) {
  800311:	55                   	push   %ebp
  800312:	89 e5                	mov    %esp,%ebp
  800314:	83 ec 18             	sub    $0x18,%esp
	sys_disable_interrupt();
  800317:	e8 75 11 00 00       	call   801491 <sys_disable_interrupt>
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80031c:	8d 45 0c             	lea    0xc(%ebp),%eax
  80031f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cnt = vcprintf(fmt, ap);
  800322:	8b 45 08             	mov    0x8(%ebp),%eax
  800325:	83 ec 08             	sub    $0x8,%esp
  800328:	ff 75 f4             	pushl  -0xc(%ebp)
  80032b:	50                   	push   %eax
  80032c:	e8 48 ff ff ff       	call   800279 <vcprintf>
  800331:	83 c4 10             	add    $0x10,%esp
  800334:	89 45 f0             	mov    %eax,-0x10(%ebp)
	va_end(ap);

	sys_enable_interrupt();
  800337:	e8 6f 11 00 00       	call   8014ab <sys_enable_interrupt>
	return cnt;
  80033c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  80033f:	c9                   	leave  
  800340:	c3                   	ret    

00800341 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800341:	55                   	push   %ebp
  800342:	89 e5                	mov    %esp,%ebp
  800344:	53                   	push   %ebx
  800345:	83 ec 14             	sub    $0x14,%esp
  800348:	8b 45 10             	mov    0x10(%ebp),%eax
  80034b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80034e:	8b 45 14             	mov    0x14(%ebp),%eax
  800351:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800354:	8b 45 18             	mov    0x18(%ebp),%eax
  800357:	ba 00 00 00 00       	mov    $0x0,%edx
  80035c:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  80035f:	77 55                	ja     8003b6 <printnum+0x75>
  800361:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800364:	72 05                	jb     80036b <printnum+0x2a>
  800366:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800369:	77 4b                	ja     8003b6 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80036b:	8b 45 1c             	mov    0x1c(%ebp),%eax
  80036e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800371:	8b 45 18             	mov    0x18(%ebp),%eax
  800374:	ba 00 00 00 00       	mov    $0x0,%edx
  800379:	52                   	push   %edx
  80037a:	50                   	push   %eax
  80037b:	ff 75 f4             	pushl  -0xc(%ebp)
  80037e:	ff 75 f0             	pushl  -0x10(%ebp)
  800381:	e8 ae 18 00 00       	call   801c34 <__udivdi3>
  800386:	83 c4 10             	add    $0x10,%esp
  800389:	83 ec 04             	sub    $0x4,%esp
  80038c:	ff 75 20             	pushl  0x20(%ebp)
  80038f:	53                   	push   %ebx
  800390:	ff 75 18             	pushl  0x18(%ebp)
  800393:	52                   	push   %edx
  800394:	50                   	push   %eax
  800395:	ff 75 0c             	pushl  0xc(%ebp)
  800398:	ff 75 08             	pushl  0x8(%ebp)
  80039b:	e8 a1 ff ff ff       	call   800341 <printnum>
  8003a0:	83 c4 20             	add    $0x20,%esp
  8003a3:	eb 1a                	jmp    8003bf <printnum+0x7e>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003a5:	83 ec 08             	sub    $0x8,%esp
  8003a8:	ff 75 0c             	pushl  0xc(%ebp)
  8003ab:	ff 75 20             	pushl  0x20(%ebp)
  8003ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b1:	ff d0                	call   *%eax
  8003b3:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003b6:	ff 4d 1c             	decl   0x1c(%ebp)
  8003b9:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  8003bd:	7f e6                	jg     8003a5 <printnum+0x64>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003bf:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8003c2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8003ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8003cd:	53                   	push   %ebx
  8003ce:	51                   	push   %ecx
  8003cf:	52                   	push   %edx
  8003d0:	50                   	push   %eax
  8003d1:	e8 6e 19 00 00       	call   801d44 <__umoddi3>
  8003d6:	83 c4 10             	add    $0x10,%esp
  8003d9:	05 b4 21 80 00       	add    $0x8021b4,%eax
  8003de:	8a 00                	mov    (%eax),%al
  8003e0:	0f be c0             	movsbl %al,%eax
  8003e3:	83 ec 08             	sub    $0x8,%esp
  8003e6:	ff 75 0c             	pushl  0xc(%ebp)
  8003e9:	50                   	push   %eax
  8003ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ed:	ff d0                	call   *%eax
  8003ef:	83 c4 10             	add    $0x10,%esp
}
  8003f2:	90                   	nop
  8003f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003f6:	c9                   	leave  
  8003f7:	c3                   	ret    

008003f8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003f8:	55                   	push   %ebp
  8003f9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003fb:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8003ff:	7e 1c                	jle    80041d <getuint+0x25>
		return va_arg(*ap, unsigned long long);
  800401:	8b 45 08             	mov    0x8(%ebp),%eax
  800404:	8b 00                	mov    (%eax),%eax
  800406:	8d 50 08             	lea    0x8(%eax),%edx
  800409:	8b 45 08             	mov    0x8(%ebp),%eax
  80040c:	89 10                	mov    %edx,(%eax)
  80040e:	8b 45 08             	mov    0x8(%ebp),%eax
  800411:	8b 00                	mov    (%eax),%eax
  800413:	83 e8 08             	sub    $0x8,%eax
  800416:	8b 50 04             	mov    0x4(%eax),%edx
  800419:	8b 00                	mov    (%eax),%eax
  80041b:	eb 40                	jmp    80045d <getuint+0x65>
	else if (lflag)
  80041d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800421:	74 1e                	je     800441 <getuint+0x49>
		return va_arg(*ap, unsigned long);
  800423:	8b 45 08             	mov    0x8(%ebp),%eax
  800426:	8b 00                	mov    (%eax),%eax
  800428:	8d 50 04             	lea    0x4(%eax),%edx
  80042b:	8b 45 08             	mov    0x8(%ebp),%eax
  80042e:	89 10                	mov    %edx,(%eax)
  800430:	8b 45 08             	mov    0x8(%ebp),%eax
  800433:	8b 00                	mov    (%eax),%eax
  800435:	83 e8 04             	sub    $0x4,%eax
  800438:	8b 00                	mov    (%eax),%eax
  80043a:	ba 00 00 00 00       	mov    $0x0,%edx
  80043f:	eb 1c                	jmp    80045d <getuint+0x65>
	else
		return va_arg(*ap, unsigned int);
  800441:	8b 45 08             	mov    0x8(%ebp),%eax
  800444:	8b 00                	mov    (%eax),%eax
  800446:	8d 50 04             	lea    0x4(%eax),%edx
  800449:	8b 45 08             	mov    0x8(%ebp),%eax
  80044c:	89 10                	mov    %edx,(%eax)
  80044e:	8b 45 08             	mov    0x8(%ebp),%eax
  800451:	8b 00                	mov    (%eax),%eax
  800453:	83 e8 04             	sub    $0x4,%eax
  800456:	8b 00                	mov    (%eax),%eax
  800458:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80045d:	5d                   	pop    %ebp
  80045e:	c3                   	ret    

0080045f <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80045f:	55                   	push   %ebp
  800460:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800462:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800466:	7e 1c                	jle    800484 <getint+0x25>
		return va_arg(*ap, long long);
  800468:	8b 45 08             	mov    0x8(%ebp),%eax
  80046b:	8b 00                	mov    (%eax),%eax
  80046d:	8d 50 08             	lea    0x8(%eax),%edx
  800470:	8b 45 08             	mov    0x8(%ebp),%eax
  800473:	89 10                	mov    %edx,(%eax)
  800475:	8b 45 08             	mov    0x8(%ebp),%eax
  800478:	8b 00                	mov    (%eax),%eax
  80047a:	83 e8 08             	sub    $0x8,%eax
  80047d:	8b 50 04             	mov    0x4(%eax),%edx
  800480:	8b 00                	mov    (%eax),%eax
  800482:	eb 38                	jmp    8004bc <getint+0x5d>
	else if (lflag)
  800484:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800488:	74 1a                	je     8004a4 <getint+0x45>
		return va_arg(*ap, long);
  80048a:	8b 45 08             	mov    0x8(%ebp),%eax
  80048d:	8b 00                	mov    (%eax),%eax
  80048f:	8d 50 04             	lea    0x4(%eax),%edx
  800492:	8b 45 08             	mov    0x8(%ebp),%eax
  800495:	89 10                	mov    %edx,(%eax)
  800497:	8b 45 08             	mov    0x8(%ebp),%eax
  80049a:	8b 00                	mov    (%eax),%eax
  80049c:	83 e8 04             	sub    $0x4,%eax
  80049f:	8b 00                	mov    (%eax),%eax
  8004a1:	99                   	cltd   
  8004a2:	eb 18                	jmp    8004bc <getint+0x5d>
	else
		return va_arg(*ap, int);
  8004a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a7:	8b 00                	mov    (%eax),%eax
  8004a9:	8d 50 04             	lea    0x4(%eax),%edx
  8004ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8004af:	89 10                	mov    %edx,(%eax)
  8004b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b4:	8b 00                	mov    (%eax),%eax
  8004b6:	83 e8 04             	sub    $0x4,%eax
  8004b9:	8b 00                	mov    (%eax),%eax
  8004bb:	99                   	cltd   
}
  8004bc:	5d                   	pop    %ebp
  8004bd:	c3                   	ret    

008004be <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004be:	55                   	push   %ebp
  8004bf:	89 e5                	mov    %esp,%ebp
  8004c1:	56                   	push   %esi
  8004c2:	53                   	push   %ebx
  8004c3:	83 ec 20             	sub    $0x20,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004c6:	eb 17                	jmp    8004df <vprintfmt+0x21>
			if (ch == '\0')
  8004c8:	85 db                	test   %ebx,%ebx
  8004ca:	0f 84 af 03 00 00    	je     80087f <vprintfmt+0x3c1>
				return;
			putch(ch, putdat);
  8004d0:	83 ec 08             	sub    $0x8,%esp
  8004d3:	ff 75 0c             	pushl  0xc(%ebp)
  8004d6:	53                   	push   %ebx
  8004d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8004da:	ff d0                	call   *%eax
  8004dc:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004df:	8b 45 10             	mov    0x10(%ebp),%eax
  8004e2:	8d 50 01             	lea    0x1(%eax),%edx
  8004e5:	89 55 10             	mov    %edx,0x10(%ebp)
  8004e8:	8a 00                	mov    (%eax),%al
  8004ea:	0f b6 d8             	movzbl %al,%ebx
  8004ed:	83 fb 25             	cmp    $0x25,%ebx
  8004f0:	75 d6                	jne    8004c8 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  8004f2:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  8004f6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  8004fd:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800504:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  80050b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800512:	8b 45 10             	mov    0x10(%ebp),%eax
  800515:	8d 50 01             	lea    0x1(%eax),%edx
  800518:	89 55 10             	mov    %edx,0x10(%ebp)
  80051b:	8a 00                	mov    (%eax),%al
  80051d:	0f b6 d8             	movzbl %al,%ebx
  800520:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800523:	83 f8 55             	cmp    $0x55,%eax
  800526:	0f 87 2b 03 00 00    	ja     800857 <vprintfmt+0x399>
  80052c:	8b 04 85 d8 21 80 00 	mov    0x8021d8(,%eax,4),%eax
  800533:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800535:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  800539:	eb d7                	jmp    800512 <vprintfmt+0x54>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80053b:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  80053f:	eb d1                	jmp    800512 <vprintfmt+0x54>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800541:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  800548:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80054b:	89 d0                	mov    %edx,%eax
  80054d:	c1 e0 02             	shl    $0x2,%eax
  800550:	01 d0                	add    %edx,%eax
  800552:	01 c0                	add    %eax,%eax
  800554:	01 d8                	add    %ebx,%eax
  800556:	83 e8 30             	sub    $0x30,%eax
  800559:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  80055c:	8b 45 10             	mov    0x10(%ebp),%eax
  80055f:	8a 00                	mov    (%eax),%al
  800561:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  800564:	83 fb 2f             	cmp    $0x2f,%ebx
  800567:	7e 3e                	jle    8005a7 <vprintfmt+0xe9>
  800569:	83 fb 39             	cmp    $0x39,%ebx
  80056c:	7f 39                	jg     8005a7 <vprintfmt+0xe9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80056e:	ff 45 10             	incl   0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800571:	eb d5                	jmp    800548 <vprintfmt+0x8a>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800573:	8b 45 14             	mov    0x14(%ebp),%eax
  800576:	83 c0 04             	add    $0x4,%eax
  800579:	89 45 14             	mov    %eax,0x14(%ebp)
  80057c:	8b 45 14             	mov    0x14(%ebp),%eax
  80057f:	83 e8 04             	sub    $0x4,%eax
  800582:	8b 00                	mov    (%eax),%eax
  800584:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  800587:	eb 1f                	jmp    8005a8 <vprintfmt+0xea>

		case '.':
			if (width < 0)
  800589:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80058d:	79 83                	jns    800512 <vprintfmt+0x54>
				width = 0;
  80058f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  800596:	e9 77 ff ff ff       	jmp    800512 <vprintfmt+0x54>

		case '#':
			altflag = 1;
  80059b:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8005a2:	e9 6b ff ff ff       	jmp    800512 <vprintfmt+0x54>
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
			goto process_precision;
  8005a7:	90                   	nop
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8005a8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005ac:	0f 89 60 ff ff ff    	jns    800512 <vprintfmt+0x54>
				width = precision, precision = -1;
  8005b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005b8:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  8005bf:	e9 4e ff ff ff       	jmp    800512 <vprintfmt+0x54>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005c4:	ff 45 e8             	incl   -0x18(%ebp)
			goto reswitch;
  8005c7:	e9 46 ff ff ff       	jmp    800512 <vprintfmt+0x54>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cf:	83 c0 04             	add    $0x4,%eax
  8005d2:	89 45 14             	mov    %eax,0x14(%ebp)
  8005d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d8:	83 e8 04             	sub    $0x4,%eax
  8005db:	8b 00                	mov    (%eax),%eax
  8005dd:	83 ec 08             	sub    $0x8,%esp
  8005e0:	ff 75 0c             	pushl  0xc(%ebp)
  8005e3:	50                   	push   %eax
  8005e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e7:	ff d0                	call   *%eax
  8005e9:	83 c4 10             	add    $0x10,%esp
			break;
  8005ec:	e9 89 02 00 00       	jmp    80087a <vprintfmt+0x3bc>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f4:	83 c0 04             	add    $0x4,%eax
  8005f7:	89 45 14             	mov    %eax,0x14(%ebp)
  8005fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fd:	83 e8 04             	sub    $0x4,%eax
  800600:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  800602:	85 db                	test   %ebx,%ebx
  800604:	79 02                	jns    800608 <vprintfmt+0x14a>
				err = -err;
  800606:	f7 db                	neg    %ebx
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800608:	83 fb 64             	cmp    $0x64,%ebx
  80060b:	7f 0b                	jg     800618 <vprintfmt+0x15a>
  80060d:	8b 34 9d 20 20 80 00 	mov    0x802020(,%ebx,4),%esi
  800614:	85 f6                	test   %esi,%esi
  800616:	75 19                	jne    800631 <vprintfmt+0x173>
				printfmt(putch, putdat, "error %d", err);
  800618:	53                   	push   %ebx
  800619:	68 c5 21 80 00       	push   $0x8021c5
  80061e:	ff 75 0c             	pushl  0xc(%ebp)
  800621:	ff 75 08             	pushl  0x8(%ebp)
  800624:	e8 5e 02 00 00       	call   800887 <printfmt>
  800629:	83 c4 10             	add    $0x10,%esp
			else
				printfmt(putch, putdat, "%s", p);
			break;
  80062c:	e9 49 02 00 00       	jmp    80087a <vprintfmt+0x3bc>
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800631:	56                   	push   %esi
  800632:	68 ce 21 80 00       	push   $0x8021ce
  800637:	ff 75 0c             	pushl  0xc(%ebp)
  80063a:	ff 75 08             	pushl  0x8(%ebp)
  80063d:	e8 45 02 00 00       	call   800887 <printfmt>
  800642:	83 c4 10             	add    $0x10,%esp
			break;
  800645:	e9 30 02 00 00       	jmp    80087a <vprintfmt+0x3bc>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80064a:	8b 45 14             	mov    0x14(%ebp),%eax
  80064d:	83 c0 04             	add    $0x4,%eax
  800650:	89 45 14             	mov    %eax,0x14(%ebp)
  800653:	8b 45 14             	mov    0x14(%ebp),%eax
  800656:	83 e8 04             	sub    $0x4,%eax
  800659:	8b 30                	mov    (%eax),%esi
  80065b:	85 f6                	test   %esi,%esi
  80065d:	75 05                	jne    800664 <vprintfmt+0x1a6>
				p = "(null)";
  80065f:	be d1 21 80 00       	mov    $0x8021d1,%esi
			if (width > 0 && padc != '-')
  800664:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800668:	7e 6d                	jle    8006d7 <vprintfmt+0x219>
  80066a:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  80066e:	74 67                	je     8006d7 <vprintfmt+0x219>
				for (width -= strnlen(p, precision); width > 0; width--)
  800670:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800673:	83 ec 08             	sub    $0x8,%esp
  800676:	50                   	push   %eax
  800677:	56                   	push   %esi
  800678:	e8 12 05 00 00       	call   800b8f <strnlen>
  80067d:	83 c4 10             	add    $0x10,%esp
  800680:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800683:	eb 16                	jmp    80069b <vprintfmt+0x1dd>
					putch(padc, putdat);
  800685:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800689:	83 ec 08             	sub    $0x8,%esp
  80068c:	ff 75 0c             	pushl  0xc(%ebp)
  80068f:	50                   	push   %eax
  800690:	8b 45 08             	mov    0x8(%ebp),%eax
  800693:	ff d0                	call   *%eax
  800695:	83 c4 10             	add    $0x10,%esp
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800698:	ff 4d e4             	decl   -0x1c(%ebp)
  80069b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80069f:	7f e4                	jg     800685 <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006a1:	eb 34                	jmp    8006d7 <vprintfmt+0x219>
				if (altflag && (ch < ' ' || ch > '~'))
  8006a3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006a7:	74 1c                	je     8006c5 <vprintfmt+0x207>
  8006a9:	83 fb 1f             	cmp    $0x1f,%ebx
  8006ac:	7e 05                	jle    8006b3 <vprintfmt+0x1f5>
  8006ae:	83 fb 7e             	cmp    $0x7e,%ebx
  8006b1:	7e 12                	jle    8006c5 <vprintfmt+0x207>
					putch('?', putdat);
  8006b3:	83 ec 08             	sub    $0x8,%esp
  8006b6:	ff 75 0c             	pushl  0xc(%ebp)
  8006b9:	6a 3f                	push   $0x3f
  8006bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8006be:	ff d0                	call   *%eax
  8006c0:	83 c4 10             	add    $0x10,%esp
  8006c3:	eb 0f                	jmp    8006d4 <vprintfmt+0x216>
				else
					putch(ch, putdat);
  8006c5:	83 ec 08             	sub    $0x8,%esp
  8006c8:	ff 75 0c             	pushl  0xc(%ebp)
  8006cb:	53                   	push   %ebx
  8006cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cf:	ff d0                	call   *%eax
  8006d1:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006d4:	ff 4d e4             	decl   -0x1c(%ebp)
  8006d7:	89 f0                	mov    %esi,%eax
  8006d9:	8d 70 01             	lea    0x1(%eax),%esi
  8006dc:	8a 00                	mov    (%eax),%al
  8006de:	0f be d8             	movsbl %al,%ebx
  8006e1:	85 db                	test   %ebx,%ebx
  8006e3:	74 24                	je     800709 <vprintfmt+0x24b>
  8006e5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006e9:	78 b8                	js     8006a3 <vprintfmt+0x1e5>
  8006eb:	ff 4d e0             	decl   -0x20(%ebp)
  8006ee:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006f2:	79 af                	jns    8006a3 <vprintfmt+0x1e5>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006f4:	eb 13                	jmp    800709 <vprintfmt+0x24b>
				putch(' ', putdat);
  8006f6:	83 ec 08             	sub    $0x8,%esp
  8006f9:	ff 75 0c             	pushl  0xc(%ebp)
  8006fc:	6a 20                	push   $0x20
  8006fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800701:	ff d0                	call   *%eax
  800703:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800706:	ff 4d e4             	decl   -0x1c(%ebp)
  800709:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80070d:	7f e7                	jg     8006f6 <vprintfmt+0x238>
				putch(' ', putdat);
			break;
  80070f:	e9 66 01 00 00       	jmp    80087a <vprintfmt+0x3bc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800714:	83 ec 08             	sub    $0x8,%esp
  800717:	ff 75 e8             	pushl  -0x18(%ebp)
  80071a:	8d 45 14             	lea    0x14(%ebp),%eax
  80071d:	50                   	push   %eax
  80071e:	e8 3c fd ff ff       	call   80045f <getint>
  800723:	83 c4 10             	add    $0x10,%esp
  800726:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800729:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  80072c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80072f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800732:	85 d2                	test   %edx,%edx
  800734:	79 23                	jns    800759 <vprintfmt+0x29b>
				putch('-', putdat);
  800736:	83 ec 08             	sub    $0x8,%esp
  800739:	ff 75 0c             	pushl  0xc(%ebp)
  80073c:	6a 2d                	push   $0x2d
  80073e:	8b 45 08             	mov    0x8(%ebp),%eax
  800741:	ff d0                	call   *%eax
  800743:	83 c4 10             	add    $0x10,%esp
				num = -(long long) num;
  800746:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800749:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80074c:	f7 d8                	neg    %eax
  80074e:	83 d2 00             	adc    $0x0,%edx
  800751:	f7 da                	neg    %edx
  800753:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800756:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800759:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800760:	e9 bc 00 00 00       	jmp    800821 <vprintfmt+0x363>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800765:	83 ec 08             	sub    $0x8,%esp
  800768:	ff 75 e8             	pushl  -0x18(%ebp)
  80076b:	8d 45 14             	lea    0x14(%ebp),%eax
  80076e:	50                   	push   %eax
  80076f:	e8 84 fc ff ff       	call   8003f8 <getuint>
  800774:	83 c4 10             	add    $0x10,%esp
  800777:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80077a:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  80077d:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800784:	e9 98 00 00 00       	jmp    800821 <vprintfmt+0x363>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800789:	83 ec 08             	sub    $0x8,%esp
  80078c:	ff 75 0c             	pushl  0xc(%ebp)
  80078f:	6a 58                	push   $0x58
  800791:	8b 45 08             	mov    0x8(%ebp),%eax
  800794:	ff d0                	call   *%eax
  800796:	83 c4 10             	add    $0x10,%esp
			putch('X', putdat);
  800799:	83 ec 08             	sub    $0x8,%esp
  80079c:	ff 75 0c             	pushl  0xc(%ebp)
  80079f:	6a 58                	push   $0x58
  8007a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a4:	ff d0                	call   *%eax
  8007a6:	83 c4 10             	add    $0x10,%esp
			putch('X', putdat);
  8007a9:	83 ec 08             	sub    $0x8,%esp
  8007ac:	ff 75 0c             	pushl  0xc(%ebp)
  8007af:	6a 58                	push   $0x58
  8007b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b4:	ff d0                	call   *%eax
  8007b6:	83 c4 10             	add    $0x10,%esp
			break;
  8007b9:	e9 bc 00 00 00       	jmp    80087a <vprintfmt+0x3bc>

		// pointer
		case 'p':
			putch('0', putdat);
  8007be:	83 ec 08             	sub    $0x8,%esp
  8007c1:	ff 75 0c             	pushl  0xc(%ebp)
  8007c4:	6a 30                	push   $0x30
  8007c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c9:	ff d0                	call   *%eax
  8007cb:	83 c4 10             	add    $0x10,%esp
			putch('x', putdat);
  8007ce:	83 ec 08             	sub    $0x8,%esp
  8007d1:	ff 75 0c             	pushl  0xc(%ebp)
  8007d4:	6a 78                	push   $0x78
  8007d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d9:	ff d0                	call   *%eax
  8007db:	83 c4 10             	add    $0x10,%esp
			num = (unsigned long long)
				(uint32) va_arg(ap, void *);
  8007de:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e1:	83 c0 04             	add    $0x4,%eax
  8007e4:	89 45 14             	mov    %eax,0x14(%ebp)
  8007e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ea:	83 e8 04             	sub    $0x4,%eax
  8007ed:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007f2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uint32) va_arg(ap, void *);
			base = 16;
  8007f9:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800800:	eb 1f                	jmp    800821 <vprintfmt+0x363>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800802:	83 ec 08             	sub    $0x8,%esp
  800805:	ff 75 e8             	pushl  -0x18(%ebp)
  800808:	8d 45 14             	lea    0x14(%ebp),%eax
  80080b:	50                   	push   %eax
  80080c:	e8 e7 fb ff ff       	call   8003f8 <getuint>
  800811:	83 c4 10             	add    $0x10,%esp
  800814:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800817:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  80081a:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800821:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800825:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800828:	83 ec 04             	sub    $0x4,%esp
  80082b:	52                   	push   %edx
  80082c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80082f:	50                   	push   %eax
  800830:	ff 75 f4             	pushl  -0xc(%ebp)
  800833:	ff 75 f0             	pushl  -0x10(%ebp)
  800836:	ff 75 0c             	pushl  0xc(%ebp)
  800839:	ff 75 08             	pushl  0x8(%ebp)
  80083c:	e8 00 fb ff ff       	call   800341 <printnum>
  800841:	83 c4 20             	add    $0x20,%esp
			break;
  800844:	eb 34                	jmp    80087a <vprintfmt+0x3bc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800846:	83 ec 08             	sub    $0x8,%esp
  800849:	ff 75 0c             	pushl  0xc(%ebp)
  80084c:	53                   	push   %ebx
  80084d:	8b 45 08             	mov    0x8(%ebp),%eax
  800850:	ff d0                	call   *%eax
  800852:	83 c4 10             	add    $0x10,%esp
			break;
  800855:	eb 23                	jmp    80087a <vprintfmt+0x3bc>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800857:	83 ec 08             	sub    $0x8,%esp
  80085a:	ff 75 0c             	pushl  0xc(%ebp)
  80085d:	6a 25                	push   $0x25
  80085f:	8b 45 08             	mov    0x8(%ebp),%eax
  800862:	ff d0                	call   *%eax
  800864:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  800867:	ff 4d 10             	decl   0x10(%ebp)
  80086a:	eb 03                	jmp    80086f <vprintfmt+0x3b1>
  80086c:	ff 4d 10             	decl   0x10(%ebp)
  80086f:	8b 45 10             	mov    0x10(%ebp),%eax
  800872:	48                   	dec    %eax
  800873:	8a 00                	mov    (%eax),%al
  800875:	3c 25                	cmp    $0x25,%al
  800877:	75 f3                	jne    80086c <vprintfmt+0x3ae>
				/* do nothing */;
			break;
  800879:	90                   	nop
		}
	}
  80087a:	e9 47 fc ff ff       	jmp    8004c6 <vprintfmt+0x8>
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
  80087f:	90                   	nop
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800880:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800883:	5b                   	pop    %ebx
  800884:	5e                   	pop    %esi
  800885:	5d                   	pop    %ebp
  800886:	c3                   	ret    

00800887 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80088d:	8d 45 10             	lea    0x10(%ebp),%eax
  800890:	83 c0 04             	add    $0x4,%eax
  800893:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800896:	8b 45 10             	mov    0x10(%ebp),%eax
  800899:	ff 75 f4             	pushl  -0xc(%ebp)
  80089c:	50                   	push   %eax
  80089d:	ff 75 0c             	pushl  0xc(%ebp)
  8008a0:	ff 75 08             	pushl  0x8(%ebp)
  8008a3:	e8 16 fc ff ff       	call   8004be <vprintfmt>
  8008a8:	83 c4 10             	add    $0x10,%esp
	va_end(ap);
}
  8008ab:	90                   	nop
  8008ac:	c9                   	leave  
  8008ad:	c3                   	ret    

008008ae <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8008ae:	55                   	push   %ebp
  8008af:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  8008b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b4:	8b 40 08             	mov    0x8(%eax),%eax
  8008b7:	8d 50 01             	lea    0x1(%eax),%edx
  8008ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008bd:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  8008c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c3:	8b 10                	mov    (%eax),%edx
  8008c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c8:	8b 40 04             	mov    0x4(%eax),%eax
  8008cb:	39 c2                	cmp    %eax,%edx
  8008cd:	73 12                	jae    8008e1 <sprintputch+0x33>
		*b->buf++ = ch;
  8008cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d2:	8b 00                	mov    (%eax),%eax
  8008d4:	8d 48 01             	lea    0x1(%eax),%ecx
  8008d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008da:	89 0a                	mov    %ecx,(%edx)
  8008dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8008df:	88 10                	mov    %dl,(%eax)
}
  8008e1:	90                   	nop
  8008e2:	5d                   	pop    %ebp
  8008e3:	c3                   	ret    

008008e4 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	83 ec 18             	sub    $0x18,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f3:	8d 50 ff             	lea    -0x1(%eax),%edx
  8008f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f9:	01 d0                	add    %edx,%eax
  8008fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8008fe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800905:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800909:	74 06                	je     800911 <vsnprintf+0x2d>
  80090b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80090f:	7f 07                	jg     800918 <vsnprintf+0x34>
		return -E_INVAL;
  800911:	b8 03 00 00 00       	mov    $0x3,%eax
  800916:	eb 20                	jmp    800938 <vsnprintf+0x54>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800918:	ff 75 14             	pushl  0x14(%ebp)
  80091b:	ff 75 10             	pushl  0x10(%ebp)
  80091e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800921:	50                   	push   %eax
  800922:	68 ae 08 80 00       	push   $0x8008ae
  800927:	e8 92 fb ff ff       	call   8004be <vprintfmt>
  80092c:	83 c4 10             	add    $0x10,%esp

	// null terminate the buffer
	*b.buf = '\0';
  80092f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800932:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800935:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800938:	c9                   	leave  
  800939:	c3                   	ret    

0080093a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800940:	8d 45 10             	lea    0x10(%ebp),%eax
  800943:	83 c0 04             	add    $0x4,%eax
  800946:	89 45 f4             	mov    %eax,-0xc(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800949:	8b 45 10             	mov    0x10(%ebp),%eax
  80094c:	ff 75 f4             	pushl  -0xc(%ebp)
  80094f:	50                   	push   %eax
  800950:	ff 75 0c             	pushl  0xc(%ebp)
  800953:	ff 75 08             	pushl  0x8(%ebp)
  800956:	e8 89 ff ff ff       	call   8008e4 <vsnprintf>
  80095b:	83 c4 10             	add    $0x10,%esp
  80095e:	89 45 f0             	mov    %eax,-0x10(%ebp)
	va_end(ap);

	return rc;
  800961:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  800964:	c9                   	leave  
  800965:	c3                   	ret    

00800966 <readline>:
#include <inc/lib.h>

//static char buf[BUFLEN];

void readline(const char *prompt, char* buf)
{
  800966:	55                   	push   %ebp
  800967:	89 e5                	mov    %esp,%ebp
  800969:	83 ec 18             	sub    $0x18,%esp
		int i, c, echoing;

	if (prompt != NULL)
  80096c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800970:	74 13                	je     800985 <readline+0x1f>
		cprintf("%s", prompt);
  800972:	83 ec 08             	sub    $0x8,%esp
  800975:	ff 75 08             	pushl  0x8(%ebp)
  800978:	68 30 23 80 00       	push   $0x802330
  80097d:	e8 62 f9 ff ff       	call   8002e4 <cprintf>
  800982:	83 c4 10             	add    $0x10,%esp

	i = 0;
  800985:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	echoing = iscons(0);
  80098c:	83 ec 0c             	sub    $0xc,%esp
  80098f:	6a 00                	push   $0x0
  800991:	e8 aa 10 00 00       	call   801a40 <iscons>
  800996:	83 c4 10             	add    $0x10,%esp
  800999:	89 45 f0             	mov    %eax,-0x10(%ebp)
	while (1) {
		c = getchar();
  80099c:	e8 51 10 00 00       	call   8019f2 <getchar>
  8009a1:	89 45 ec             	mov    %eax,-0x14(%ebp)
		if (c < 0) {
  8009a4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8009a8:	79 22                	jns    8009cc <readline+0x66>
			if (c != -E_EOF)
  8009aa:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
  8009ae:	0f 84 ad 00 00 00    	je     800a61 <readline+0xfb>
				cprintf("read error: %e\n", c);
  8009b4:	83 ec 08             	sub    $0x8,%esp
  8009b7:	ff 75 ec             	pushl  -0x14(%ebp)
  8009ba:	68 33 23 80 00       	push   $0x802333
  8009bf:	e8 20 f9 ff ff       	call   8002e4 <cprintf>
  8009c4:	83 c4 10             	add    $0x10,%esp
			return;
  8009c7:	e9 95 00 00 00       	jmp    800a61 <readline+0xfb>
		} else if (c >= ' ' && i < BUFLEN-1) {
  8009cc:	83 7d ec 1f          	cmpl   $0x1f,-0x14(%ebp)
  8009d0:	7e 34                	jle    800a06 <readline+0xa0>
  8009d2:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  8009d9:	7f 2b                	jg     800a06 <readline+0xa0>
			if (echoing)
  8009db:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8009df:	74 0e                	je     8009ef <readline+0x89>
				cputchar(c);
  8009e1:	83 ec 0c             	sub    $0xc,%esp
  8009e4:	ff 75 ec             	pushl  -0x14(%ebp)
  8009e7:	e8 be 0f 00 00       	call   8019aa <cputchar>
  8009ec:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  8009ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009f2:	8d 50 01             	lea    0x1(%eax),%edx
  8009f5:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8009f8:	89 c2                	mov    %eax,%edx
  8009fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fd:	01 d0                	add    %edx,%eax
  8009ff:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800a02:	88 10                	mov    %dl,(%eax)
  800a04:	eb 56                	jmp    800a5c <readline+0xf6>
		} else if (c == '\b' && i > 0) {
  800a06:	83 7d ec 08          	cmpl   $0x8,-0x14(%ebp)
  800a0a:	75 1f                	jne    800a2b <readline+0xc5>
  800a0c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  800a10:	7e 19                	jle    800a2b <readline+0xc5>
			if (echoing)
  800a12:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800a16:	74 0e                	je     800a26 <readline+0xc0>
				cputchar(c);
  800a18:	83 ec 0c             	sub    $0xc,%esp
  800a1b:	ff 75 ec             	pushl  -0x14(%ebp)
  800a1e:	e8 87 0f 00 00       	call   8019aa <cputchar>
  800a23:	83 c4 10             	add    $0x10,%esp

			i--;
  800a26:	ff 4d f4             	decl   -0xc(%ebp)
  800a29:	eb 31                	jmp    800a5c <readline+0xf6>
		} else if (c == '\n' || c == '\r') {
  800a2b:	83 7d ec 0a          	cmpl   $0xa,-0x14(%ebp)
  800a2f:	74 0a                	je     800a3b <readline+0xd5>
  800a31:	83 7d ec 0d          	cmpl   $0xd,-0x14(%ebp)
  800a35:	0f 85 61 ff ff ff    	jne    80099c <readline+0x36>
			if (echoing)
  800a3b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800a3f:	74 0e                	je     800a4f <readline+0xe9>
				cputchar(c);
  800a41:	83 ec 0c             	sub    $0xc,%esp
  800a44:	ff 75 ec             	pushl  -0x14(%ebp)
  800a47:	e8 5e 0f 00 00       	call   8019aa <cputchar>
  800a4c:	83 c4 10             	add    $0x10,%esp

			buf[i] = 0;
  800a4f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a52:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a55:	01 d0                	add    %edx,%eax
  800a57:	c6 00 00             	movb   $0x0,(%eax)
			return;
  800a5a:	eb 06                	jmp    800a62 <readline+0xfc>
		}
	}
  800a5c:	e9 3b ff ff ff       	jmp    80099c <readline+0x36>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return;
  800a61:	90                   	nop
			buf[i] = 0;
			return;
		}
	}

}
  800a62:	c9                   	leave  
  800a63:	c3                   	ret    

00800a64 <atomic_readline>:

void atomic_readline(const char *prompt, char* buf)
{
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
  800a67:	83 ec 18             	sub    $0x18,%esp
	sys_disable_interrupt();
  800a6a:	e8 22 0a 00 00       	call   801491 <sys_disable_interrupt>
	int i, c, echoing;

	if (prompt != NULL)
  800a6f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800a73:	74 13                	je     800a88 <atomic_readline+0x24>
		cprintf("%s", prompt);
  800a75:	83 ec 08             	sub    $0x8,%esp
  800a78:	ff 75 08             	pushl  0x8(%ebp)
  800a7b:	68 30 23 80 00       	push   $0x802330
  800a80:	e8 5f f8 ff ff       	call   8002e4 <cprintf>
  800a85:	83 c4 10             	add    $0x10,%esp

	i = 0;
  800a88:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	echoing = iscons(0);
  800a8f:	83 ec 0c             	sub    $0xc,%esp
  800a92:	6a 00                	push   $0x0
  800a94:	e8 a7 0f 00 00       	call   801a40 <iscons>
  800a99:	83 c4 10             	add    $0x10,%esp
  800a9c:	89 45 f0             	mov    %eax,-0x10(%ebp)
	while (1) {
		c = getchar();
  800a9f:	e8 4e 0f 00 00       	call   8019f2 <getchar>
  800aa4:	89 45 ec             	mov    %eax,-0x14(%ebp)
		if (c < 0) {
  800aa7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  800aab:	79 23                	jns    800ad0 <atomic_readline+0x6c>
			if (c != -E_EOF)
  800aad:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
  800ab1:	74 13                	je     800ac6 <atomic_readline+0x62>
				cprintf("read error: %e\n", c);
  800ab3:	83 ec 08             	sub    $0x8,%esp
  800ab6:	ff 75 ec             	pushl  -0x14(%ebp)
  800ab9:	68 33 23 80 00       	push   $0x802333
  800abe:	e8 21 f8 ff ff       	call   8002e4 <cprintf>
  800ac3:	83 c4 10             	add    $0x10,%esp
			sys_enable_interrupt();
  800ac6:	e8 e0 09 00 00       	call   8014ab <sys_enable_interrupt>
			return;
  800acb:	e9 9a 00 00 00       	jmp    800b6a <atomic_readline+0x106>
		} else if (c >= ' ' && i < BUFLEN-1) {
  800ad0:	83 7d ec 1f          	cmpl   $0x1f,-0x14(%ebp)
  800ad4:	7e 34                	jle    800b0a <atomic_readline+0xa6>
  800ad6:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  800add:	7f 2b                	jg     800b0a <atomic_readline+0xa6>
			if (echoing)
  800adf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800ae3:	74 0e                	je     800af3 <atomic_readline+0x8f>
				cputchar(c);
  800ae5:	83 ec 0c             	sub    $0xc,%esp
  800ae8:	ff 75 ec             	pushl  -0x14(%ebp)
  800aeb:	e8 ba 0e 00 00       	call   8019aa <cputchar>
  800af0:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  800af3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800af6:	8d 50 01             	lea    0x1(%eax),%edx
  800af9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800afc:	89 c2                	mov    %eax,%edx
  800afe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b01:	01 d0                	add    %edx,%eax
  800b03:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800b06:	88 10                	mov    %dl,(%eax)
  800b08:	eb 5b                	jmp    800b65 <atomic_readline+0x101>
		} else if (c == '\b' && i > 0) {
  800b0a:	83 7d ec 08          	cmpl   $0x8,-0x14(%ebp)
  800b0e:	75 1f                	jne    800b2f <atomic_readline+0xcb>
  800b10:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  800b14:	7e 19                	jle    800b2f <atomic_readline+0xcb>
			if (echoing)
  800b16:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800b1a:	74 0e                	je     800b2a <atomic_readline+0xc6>
				cputchar(c);
  800b1c:	83 ec 0c             	sub    $0xc,%esp
  800b1f:	ff 75 ec             	pushl  -0x14(%ebp)
  800b22:	e8 83 0e 00 00       	call   8019aa <cputchar>
  800b27:	83 c4 10             	add    $0x10,%esp
			i--;
  800b2a:	ff 4d f4             	decl   -0xc(%ebp)
  800b2d:	eb 36                	jmp    800b65 <atomic_readline+0x101>
		} else if (c == '\n' || c == '\r') {
  800b2f:	83 7d ec 0a          	cmpl   $0xa,-0x14(%ebp)
  800b33:	74 0a                	je     800b3f <atomic_readline+0xdb>
  800b35:	83 7d ec 0d          	cmpl   $0xd,-0x14(%ebp)
  800b39:	0f 85 60 ff ff ff    	jne    800a9f <atomic_readline+0x3b>
			if (echoing)
  800b3f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800b43:	74 0e                	je     800b53 <atomic_readline+0xef>
				cputchar(c);
  800b45:	83 ec 0c             	sub    $0xc,%esp
  800b48:	ff 75 ec             	pushl  -0x14(%ebp)
  800b4b:	e8 5a 0e 00 00       	call   8019aa <cputchar>
  800b50:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
  800b53:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b56:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b59:	01 d0                	add    %edx,%eax
  800b5b:	c6 00 00             	movb   $0x0,(%eax)
			sys_enable_interrupt();
  800b5e:	e8 48 09 00 00       	call   8014ab <sys_enable_interrupt>
			return;
  800b63:	eb 05                	jmp    800b6a <atomic_readline+0x106>
		}
	}
  800b65:	e9 35 ff ff ff       	jmp    800a9f <atomic_readline+0x3b>
}
  800b6a:	c9                   	leave  
  800b6b:	c3                   	ret    

00800b6c <strlen>:

#include <inc/string.h>
#include <inc/assert.h>
int
strlen(const char *s)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800b72:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800b79:	eb 06                	jmp    800b81 <strlen+0x15>
		n++;
  800b7b:	ff 45 fc             	incl   -0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b7e:	ff 45 08             	incl   0x8(%ebp)
  800b81:	8b 45 08             	mov    0x8(%ebp),%eax
  800b84:	8a 00                	mov    (%eax),%al
  800b86:	84 c0                	test   %al,%al
  800b88:	75 f1                	jne    800b7b <strlen+0xf>
		n++;
	return n;
  800b8a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800b8d:	c9                   	leave  
  800b8e:	c3                   	ret    

00800b8f <strnlen>:

int
strnlen(const char *s, uint32 size)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b95:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800b9c:	eb 09                	jmp    800ba7 <strnlen+0x18>
		n++;
  800b9e:	ff 45 fc             	incl   -0x4(%ebp)
int
strnlen(const char *s, uint32 size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ba1:	ff 45 08             	incl   0x8(%ebp)
  800ba4:	ff 4d 0c             	decl   0xc(%ebp)
  800ba7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bab:	74 09                	je     800bb6 <strnlen+0x27>
  800bad:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb0:	8a 00                	mov    (%eax),%al
  800bb2:	84 c0                	test   %al,%al
  800bb4:	75 e8                	jne    800b9e <strnlen+0xf>
		n++;
	return n;
  800bb6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800bb9:	c9                   	leave  
  800bba:	c3                   	ret    

00800bbb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800bc1:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc4:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800bc7:	90                   	nop
  800bc8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcb:	8d 50 01             	lea    0x1(%eax),%edx
  800bce:	89 55 08             	mov    %edx,0x8(%ebp)
  800bd1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bd4:	8d 4a 01             	lea    0x1(%edx),%ecx
  800bd7:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800bda:	8a 12                	mov    (%edx),%dl
  800bdc:	88 10                	mov    %dl,(%eax)
  800bde:	8a 00                	mov    (%eax),%al
  800be0:	84 c0                	test   %al,%al
  800be2:	75 e4                	jne    800bc8 <strcpy+0xd>
		/* do nothing */;
	return ret;
  800be4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800be7:	c9                   	leave  
  800be8:	c3                   	ret    

00800be9 <strncpy>:

char *
strncpy(char *dst, const char *src, uint32 size) {
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	83 ec 10             	sub    $0x10,%esp
	uint32 i;
	char *ret;

	ret = dst;
  800bef:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf2:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800bf5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800bfc:	eb 1f                	jmp    800c1d <strncpy+0x34>
		*dst++ = *src;
  800bfe:	8b 45 08             	mov    0x8(%ebp),%eax
  800c01:	8d 50 01             	lea    0x1(%eax),%edx
  800c04:	89 55 08             	mov    %edx,0x8(%ebp)
  800c07:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c0a:	8a 12                	mov    (%edx),%dl
  800c0c:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800c0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c11:	8a 00                	mov    (%eax),%al
  800c13:	84 c0                	test   %al,%al
  800c15:	74 03                	je     800c1a <strncpy+0x31>
			src++;
  800c17:	ff 45 0c             	incl   0xc(%ebp)
strncpy(char *dst, const char *src, uint32 size) {
	uint32 i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c1a:	ff 45 fc             	incl   -0x4(%ebp)
  800c1d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c20:	3b 45 10             	cmp    0x10(%ebp),%eax
  800c23:	72 d9                	jb     800bfe <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800c25:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800c28:	c9                   	leave  
  800c29:	c3                   	ret    

00800c2a <strlcpy>:

uint32
strlcpy(char *dst, const char *src, uint32 size)
{
  800c2a:	55                   	push   %ebp
  800c2b:	89 e5                	mov    %esp,%ebp
  800c2d:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800c30:	8b 45 08             	mov    0x8(%ebp),%eax
  800c33:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800c36:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c3a:	74 30                	je     800c6c <strlcpy+0x42>
		while (--size > 0 && *src != '\0')
  800c3c:	eb 16                	jmp    800c54 <strlcpy+0x2a>
			*dst++ = *src++;
  800c3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c41:	8d 50 01             	lea    0x1(%eax),%edx
  800c44:	89 55 08             	mov    %edx,0x8(%ebp)
  800c47:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c4a:	8d 4a 01             	lea    0x1(%edx),%ecx
  800c4d:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800c50:	8a 12                	mov    (%edx),%dl
  800c52:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c54:	ff 4d 10             	decl   0x10(%ebp)
  800c57:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c5b:	74 09                	je     800c66 <strlcpy+0x3c>
  800c5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c60:	8a 00                	mov    (%eax),%al
  800c62:	84 c0                	test   %al,%al
  800c64:	75 d8                	jne    800c3e <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800c66:	8b 45 08             	mov    0x8(%ebp),%eax
  800c69:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c72:	29 c2                	sub    %eax,%edx
  800c74:	89 d0                	mov    %edx,%eax
}
  800c76:	c9                   	leave  
  800c77:	c3                   	ret    

00800c78 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c78:	55                   	push   %ebp
  800c79:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800c7b:	eb 06                	jmp    800c83 <strcmp+0xb>
		p++, q++;
  800c7d:	ff 45 08             	incl   0x8(%ebp)
  800c80:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c83:	8b 45 08             	mov    0x8(%ebp),%eax
  800c86:	8a 00                	mov    (%eax),%al
  800c88:	84 c0                	test   %al,%al
  800c8a:	74 0e                	je     800c9a <strcmp+0x22>
  800c8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8f:	8a 10                	mov    (%eax),%dl
  800c91:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c94:	8a 00                	mov    (%eax),%al
  800c96:	38 c2                	cmp    %al,%dl
  800c98:	74 e3                	je     800c7d <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9d:	8a 00                	mov    (%eax),%al
  800c9f:	0f b6 d0             	movzbl %al,%edx
  800ca2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ca5:	8a 00                	mov    (%eax),%al
  800ca7:	0f b6 c0             	movzbl %al,%eax
  800caa:	29 c2                	sub    %eax,%edx
  800cac:	89 d0                	mov    %edx,%eax
}
  800cae:	5d                   	pop    %ebp
  800caf:	c3                   	ret    

00800cb0 <strncmp>:

int
strncmp(const char *p, const char *q, uint32 n)
{
  800cb0:	55                   	push   %ebp
  800cb1:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800cb3:	eb 09                	jmp    800cbe <strncmp+0xe>
		n--, p++, q++;
  800cb5:	ff 4d 10             	decl   0x10(%ebp)
  800cb8:	ff 45 08             	incl   0x8(%ebp)
  800cbb:	ff 45 0c             	incl   0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint32 n)
{
	while (n > 0 && *p && *p == *q)
  800cbe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cc2:	74 17                	je     800cdb <strncmp+0x2b>
  800cc4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc7:	8a 00                	mov    (%eax),%al
  800cc9:	84 c0                	test   %al,%al
  800ccb:	74 0e                	je     800cdb <strncmp+0x2b>
  800ccd:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd0:	8a 10                	mov    (%eax),%dl
  800cd2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cd5:	8a 00                	mov    (%eax),%al
  800cd7:	38 c2                	cmp    %al,%dl
  800cd9:	74 da                	je     800cb5 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800cdb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cdf:	75 07                	jne    800ce8 <strncmp+0x38>
		return 0;
  800ce1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ce6:	eb 14                	jmp    800cfc <strncmp+0x4c>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ce8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ceb:	8a 00                	mov    (%eax),%al
  800ced:	0f b6 d0             	movzbl %al,%edx
  800cf0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cf3:	8a 00                	mov    (%eax),%al
  800cf5:	0f b6 c0             	movzbl %al,%eax
  800cf8:	29 c2                	sub    %eax,%edx
  800cfa:	89 d0                	mov    %edx,%eax
}
  800cfc:	5d                   	pop    %ebp
  800cfd:	c3                   	ret    

00800cfe <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800cfe:	55                   	push   %ebp
  800cff:	89 e5                	mov    %esp,%ebp
  800d01:	83 ec 04             	sub    $0x4,%esp
  800d04:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d07:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800d0a:	eb 12                	jmp    800d1e <strchr+0x20>
		if (*s == c)
  800d0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0f:	8a 00                	mov    (%eax),%al
  800d11:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800d14:	75 05                	jne    800d1b <strchr+0x1d>
			return (char *) s;
  800d16:	8b 45 08             	mov    0x8(%ebp),%eax
  800d19:	eb 11                	jmp    800d2c <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d1b:	ff 45 08             	incl   0x8(%ebp)
  800d1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d21:	8a 00                	mov    (%eax),%al
  800d23:	84 c0                	test   %al,%al
  800d25:	75 e5                	jne    800d0c <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800d27:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d2c:	c9                   	leave  
  800d2d:	c3                   	ret    

00800d2e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d2e:	55                   	push   %ebp
  800d2f:	89 e5                	mov    %esp,%ebp
  800d31:	83 ec 04             	sub    $0x4,%esp
  800d34:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d37:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800d3a:	eb 0d                	jmp    800d49 <strfind+0x1b>
		if (*s == c)
  800d3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3f:	8a 00                	mov    (%eax),%al
  800d41:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800d44:	74 0e                	je     800d54 <strfind+0x26>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d46:	ff 45 08             	incl   0x8(%ebp)
  800d49:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4c:	8a 00                	mov    (%eax),%al
  800d4e:	84 c0                	test   %al,%al
  800d50:	75 ea                	jne    800d3c <strfind+0xe>
  800d52:	eb 01                	jmp    800d55 <strfind+0x27>
		if (*s == c)
			break;
  800d54:	90                   	nop
	return (char *) s;
  800d55:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800d58:	c9                   	leave  
  800d59:	c3                   	ret    

00800d5a <memset>:


void *
memset(void *v, int c, uint32 n)
{
  800d5a:	55                   	push   %ebp
  800d5b:	89 e5                	mov    %esp,%ebp
  800d5d:	83 ec 10             	sub    $0x10,%esp
	char *p;
	int m;

	p = v;
  800d60:	8b 45 08             	mov    0x8(%ebp),%eax
  800d63:	89 45 fc             	mov    %eax,-0x4(%ebp)
	m = n;
  800d66:	8b 45 10             	mov    0x10(%ebp),%eax
  800d69:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (--m >= 0)
  800d6c:	eb 0e                	jmp    800d7c <memset+0x22>
		*p++ = c;
  800d6e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d71:	8d 50 01             	lea    0x1(%eax),%edx
  800d74:	89 55 fc             	mov    %edx,-0x4(%ebp)
  800d77:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d7a:	88 10                	mov    %dl,(%eax)
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800d7c:	ff 4d f8             	decl   -0x8(%ebp)
  800d7f:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
  800d83:	79 e9                	jns    800d6e <memset+0x14>
		*p++ = c;

	return v;
  800d85:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800d88:	c9                   	leave  
  800d89:	c3                   	ret    

00800d8a <memcpy>:

void *
memcpy(void *dst, const void *src, uint32 n)
{
  800d8a:	55                   	push   %ebp
  800d8b:	89 e5                	mov    %esp,%ebp
  800d8d:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800d90:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d93:	89 45 fc             	mov    %eax,-0x4(%ebp)
	d = dst;
  800d96:	8b 45 08             	mov    0x8(%ebp),%eax
  800d99:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (n-- > 0)
  800d9c:	eb 16                	jmp    800db4 <memcpy+0x2a>
		*d++ = *s++;
  800d9e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800da1:	8d 50 01             	lea    0x1(%eax),%edx
  800da4:	89 55 f8             	mov    %edx,-0x8(%ebp)
  800da7:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800daa:	8d 4a 01             	lea    0x1(%edx),%ecx
  800dad:	89 4d fc             	mov    %ecx,-0x4(%ebp)
  800db0:	8a 12                	mov    (%edx),%dl
  800db2:	88 10                	mov    %dl,(%eax)
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
  800db4:	8b 45 10             	mov    0x10(%ebp),%eax
  800db7:	8d 50 ff             	lea    -0x1(%eax),%edx
  800dba:	89 55 10             	mov    %edx,0x10(%ebp)
  800dbd:	85 c0                	test   %eax,%eax
  800dbf:	75 dd                	jne    800d9e <memcpy+0x14>
		*d++ = *s++;

	return dst;
  800dc1:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800dc4:	c9                   	leave  
  800dc5:	c3                   	ret    

00800dc6 <memmove>:

void *
memmove(void *dst, const void *src, uint32 n)
{
  800dc6:	55                   	push   %ebp
  800dc7:	89 e5                	mov    %esp,%ebp
  800dc9:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800dcc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dcf:	89 45 fc             	mov    %eax,-0x4(%ebp)
	d = dst;
  800dd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd5:	89 45 f8             	mov    %eax,-0x8(%ebp)
	if (s < d && s + n > d) {
  800dd8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800ddb:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  800dde:	73 50                	jae    800e30 <memmove+0x6a>
  800de0:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800de3:	8b 45 10             	mov    0x10(%ebp),%eax
  800de6:	01 d0                	add    %edx,%eax
  800de8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  800deb:	76 43                	jbe    800e30 <memmove+0x6a>
		s += n;
  800ded:	8b 45 10             	mov    0x10(%ebp),%eax
  800df0:	01 45 fc             	add    %eax,-0x4(%ebp)
		d += n;
  800df3:	8b 45 10             	mov    0x10(%ebp),%eax
  800df6:	01 45 f8             	add    %eax,-0x8(%ebp)
		while (n-- > 0)
  800df9:	eb 10                	jmp    800e0b <memmove+0x45>
			*--d = *--s;
  800dfb:	ff 4d f8             	decl   -0x8(%ebp)
  800dfe:	ff 4d fc             	decl   -0x4(%ebp)
  800e01:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800e04:	8a 10                	mov    (%eax),%dl
  800e06:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e09:	88 10                	mov    %dl,(%eax)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  800e0b:	8b 45 10             	mov    0x10(%ebp),%eax
  800e0e:	8d 50 ff             	lea    -0x1(%eax),%edx
  800e11:	89 55 10             	mov    %edx,0x10(%ebp)
  800e14:	85 c0                	test   %eax,%eax
  800e16:	75 e3                	jne    800dfb <memmove+0x35>
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e18:	eb 23                	jmp    800e3d <memmove+0x77>
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  800e1a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e1d:	8d 50 01             	lea    0x1(%eax),%edx
  800e20:	89 55 f8             	mov    %edx,-0x8(%ebp)
  800e23:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800e26:	8d 4a 01             	lea    0x1(%edx),%ecx
  800e29:	89 4d fc             	mov    %ecx,-0x4(%ebp)
  800e2c:	8a 12                	mov    (%edx),%dl
  800e2e:	88 10                	mov    %dl,(%eax)
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800e30:	8b 45 10             	mov    0x10(%ebp),%eax
  800e33:	8d 50 ff             	lea    -0x1(%eax),%edx
  800e36:	89 55 10             	mov    %edx,0x10(%ebp)
  800e39:	85 c0                	test   %eax,%eax
  800e3b:	75 dd                	jne    800e1a <memmove+0x54>
			*d++ = *s++;

	return dst;
  800e3d:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800e40:	c9                   	leave  
  800e41:	c3                   	ret    

00800e42 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint32 n)
{
  800e42:	55                   	push   %ebp
  800e43:	89 e5                	mov    %esp,%ebp
  800e45:	83 ec 10             	sub    $0x10,%esp
	const uint8 *s1 = (const uint8 *) v1;
  800e48:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4b:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8 *s2 = (const uint8 *) v2;
  800e4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e51:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800e54:	eb 2a                	jmp    800e80 <memcmp+0x3e>
		if (*s1 != *s2)
  800e56:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800e59:	8a 10                	mov    (%eax),%dl
  800e5b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e5e:	8a 00                	mov    (%eax),%al
  800e60:	38 c2                	cmp    %al,%dl
  800e62:	74 16                	je     800e7a <memcmp+0x38>
			return (int) *s1 - (int) *s2;
  800e64:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800e67:	8a 00                	mov    (%eax),%al
  800e69:	0f b6 d0             	movzbl %al,%edx
  800e6c:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e6f:	8a 00                	mov    (%eax),%al
  800e71:	0f b6 c0             	movzbl %al,%eax
  800e74:	29 c2                	sub    %eax,%edx
  800e76:	89 d0                	mov    %edx,%eax
  800e78:	eb 18                	jmp    800e92 <memcmp+0x50>
		s1++, s2++;
  800e7a:	ff 45 fc             	incl   -0x4(%ebp)
  800e7d:	ff 45 f8             	incl   -0x8(%ebp)
memcmp(const void *v1, const void *v2, uint32 n)
{
	const uint8 *s1 = (const uint8 *) v1;
	const uint8 *s2 = (const uint8 *) v2;

	while (n-- > 0) {
  800e80:	8b 45 10             	mov    0x10(%ebp),%eax
  800e83:	8d 50 ff             	lea    -0x1(%eax),%edx
  800e86:	89 55 10             	mov    %edx,0x10(%ebp)
  800e89:	85 c0                	test   %eax,%eax
  800e8b:	75 c9                	jne    800e56 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e8d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e92:	c9                   	leave  
  800e93:	c3                   	ret    

00800e94 <memfind>:

void *
memfind(const void *s, int c, uint32 n)
{
  800e94:	55                   	push   %ebp
  800e95:	89 e5                	mov    %esp,%ebp
  800e97:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800e9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9d:	8b 45 10             	mov    0x10(%ebp),%eax
  800ea0:	01 d0                	add    %edx,%eax
  800ea2:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800ea5:	eb 15                	jmp    800ebc <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ea7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eaa:	8a 00                	mov    (%eax),%al
  800eac:	0f b6 d0             	movzbl %al,%edx
  800eaf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eb2:	0f b6 c0             	movzbl %al,%eax
  800eb5:	39 c2                	cmp    %eax,%edx
  800eb7:	74 0d                	je     800ec6 <memfind+0x32>

void *
memfind(const void *s, int c, uint32 n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800eb9:	ff 45 08             	incl   0x8(%ebp)
  800ebc:	8b 45 08             	mov    0x8(%ebp),%eax
  800ebf:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800ec2:	72 e3                	jb     800ea7 <memfind+0x13>
  800ec4:	eb 01                	jmp    800ec7 <memfind+0x33>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
  800ec6:	90                   	nop
	return (void *) s;
  800ec7:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800eca:	c9                   	leave  
  800ecb:	c3                   	ret    

00800ecc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ecc:	55                   	push   %ebp
  800ecd:	89 e5                	mov    %esp,%ebp
  800ecf:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800ed2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800ed9:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ee0:	eb 03                	jmp    800ee5 <strtol+0x19>
		s++;
  800ee2:	ff 45 08             	incl   0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ee5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee8:	8a 00                	mov    (%eax),%al
  800eea:	3c 20                	cmp    $0x20,%al
  800eec:	74 f4                	je     800ee2 <strtol+0x16>
  800eee:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef1:	8a 00                	mov    (%eax),%al
  800ef3:	3c 09                	cmp    $0x9,%al
  800ef5:	74 eb                	je     800ee2 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ef7:	8b 45 08             	mov    0x8(%ebp),%eax
  800efa:	8a 00                	mov    (%eax),%al
  800efc:	3c 2b                	cmp    $0x2b,%al
  800efe:	75 05                	jne    800f05 <strtol+0x39>
		s++;
  800f00:	ff 45 08             	incl   0x8(%ebp)
  800f03:	eb 13                	jmp    800f18 <strtol+0x4c>
	else if (*s == '-')
  800f05:	8b 45 08             	mov    0x8(%ebp),%eax
  800f08:	8a 00                	mov    (%eax),%al
  800f0a:	3c 2d                	cmp    $0x2d,%al
  800f0c:	75 0a                	jne    800f18 <strtol+0x4c>
		s++, neg = 1;
  800f0e:	ff 45 08             	incl   0x8(%ebp)
  800f11:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f18:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f1c:	74 06                	je     800f24 <strtol+0x58>
  800f1e:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800f22:	75 20                	jne    800f44 <strtol+0x78>
  800f24:	8b 45 08             	mov    0x8(%ebp),%eax
  800f27:	8a 00                	mov    (%eax),%al
  800f29:	3c 30                	cmp    $0x30,%al
  800f2b:	75 17                	jne    800f44 <strtol+0x78>
  800f2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f30:	40                   	inc    %eax
  800f31:	8a 00                	mov    (%eax),%al
  800f33:	3c 78                	cmp    $0x78,%al
  800f35:	75 0d                	jne    800f44 <strtol+0x78>
		s += 2, base = 16;
  800f37:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800f3b:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800f42:	eb 28                	jmp    800f6c <strtol+0xa0>
	else if (base == 0 && s[0] == '0')
  800f44:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f48:	75 15                	jne    800f5f <strtol+0x93>
  800f4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4d:	8a 00                	mov    (%eax),%al
  800f4f:	3c 30                	cmp    $0x30,%al
  800f51:	75 0c                	jne    800f5f <strtol+0x93>
		s++, base = 8;
  800f53:	ff 45 08             	incl   0x8(%ebp)
  800f56:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800f5d:	eb 0d                	jmp    800f6c <strtol+0xa0>
	else if (base == 0)
  800f5f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f63:	75 07                	jne    800f6c <strtol+0xa0>
		base = 10;
  800f65:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f6f:	8a 00                	mov    (%eax),%al
  800f71:	3c 2f                	cmp    $0x2f,%al
  800f73:	7e 19                	jle    800f8e <strtol+0xc2>
  800f75:	8b 45 08             	mov    0x8(%ebp),%eax
  800f78:	8a 00                	mov    (%eax),%al
  800f7a:	3c 39                	cmp    $0x39,%al
  800f7c:	7f 10                	jg     800f8e <strtol+0xc2>
			dig = *s - '0';
  800f7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f81:	8a 00                	mov    (%eax),%al
  800f83:	0f be c0             	movsbl %al,%eax
  800f86:	83 e8 30             	sub    $0x30,%eax
  800f89:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800f8c:	eb 42                	jmp    800fd0 <strtol+0x104>
		else if (*s >= 'a' && *s <= 'z')
  800f8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f91:	8a 00                	mov    (%eax),%al
  800f93:	3c 60                	cmp    $0x60,%al
  800f95:	7e 19                	jle    800fb0 <strtol+0xe4>
  800f97:	8b 45 08             	mov    0x8(%ebp),%eax
  800f9a:	8a 00                	mov    (%eax),%al
  800f9c:	3c 7a                	cmp    $0x7a,%al
  800f9e:	7f 10                	jg     800fb0 <strtol+0xe4>
			dig = *s - 'a' + 10;
  800fa0:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa3:	8a 00                	mov    (%eax),%al
  800fa5:	0f be c0             	movsbl %al,%eax
  800fa8:	83 e8 57             	sub    $0x57,%eax
  800fab:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800fae:	eb 20                	jmp    800fd0 <strtol+0x104>
		else if (*s >= 'A' && *s <= 'Z')
  800fb0:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb3:	8a 00                	mov    (%eax),%al
  800fb5:	3c 40                	cmp    $0x40,%al
  800fb7:	7e 39                	jle    800ff2 <strtol+0x126>
  800fb9:	8b 45 08             	mov    0x8(%ebp),%eax
  800fbc:	8a 00                	mov    (%eax),%al
  800fbe:	3c 5a                	cmp    $0x5a,%al
  800fc0:	7f 30                	jg     800ff2 <strtol+0x126>
			dig = *s - 'A' + 10;
  800fc2:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc5:	8a 00                	mov    (%eax),%al
  800fc7:	0f be c0             	movsbl %al,%eax
  800fca:	83 e8 37             	sub    $0x37,%eax
  800fcd:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800fd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fd3:	3b 45 10             	cmp    0x10(%ebp),%eax
  800fd6:	7d 19                	jge    800ff1 <strtol+0x125>
			break;
		s++, val = (val * base) + dig;
  800fd8:	ff 45 08             	incl   0x8(%ebp)
  800fdb:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800fde:	0f af 45 10          	imul   0x10(%ebp),%eax
  800fe2:	89 c2                	mov    %eax,%edx
  800fe4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fe7:	01 d0                	add    %edx,%eax
  800fe9:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800fec:	e9 7b ff ff ff       	jmp    800f6c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
			break;
  800ff1:	90                   	nop
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ff2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ff6:	74 08                	je     801000 <strtol+0x134>
		*endptr = (char *) s;
  800ff8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ffb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ffe:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  801000:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  801004:	74 07                	je     80100d <strtol+0x141>
  801006:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801009:	f7 d8                	neg    %eax
  80100b:	eb 03                	jmp    801010 <strtol+0x144>
  80100d:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  801010:	c9                   	leave  
  801011:	c3                   	ret    

00801012 <ltostr>:

void
ltostr(long value, char *str)
{
  801012:	55                   	push   %ebp
  801013:	89 e5                	mov    %esp,%ebp
  801015:	83 ec 20             	sub    $0x20,%esp
	int neg = 0;
  801018:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	int s = 0 ;
  80101f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// plus/minus sign
	if (value < 0)
  801026:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80102a:	79 13                	jns    80103f <ltostr+0x2d>
	{
		neg = 1;
  80102c:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
		str[0] = '-';
  801033:	8b 45 0c             	mov    0xc(%ebp),%eax
  801036:	c6 00 2d             	movb   $0x2d,(%eax)
		value = value * -1 ;
  801039:	f7 5d 08             	negl   0x8(%ebp)
		s++ ;
  80103c:	ff 45 f8             	incl   -0x8(%ebp)
	}
	do
	{
		int mod = value % 10 ;
  80103f:	8b 45 08             	mov    0x8(%ebp),%eax
  801042:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801047:	99                   	cltd   
  801048:	f7 f9                	idiv   %ecx
  80104a:	89 55 ec             	mov    %edx,-0x14(%ebp)
		str[s++] = mod + '0' ;
  80104d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801050:	8d 50 01             	lea    0x1(%eax),%edx
  801053:	89 55 f8             	mov    %edx,-0x8(%ebp)
  801056:	89 c2                	mov    %eax,%edx
  801058:	8b 45 0c             	mov    0xc(%ebp),%eax
  80105b:	01 d0                	add    %edx,%eax
  80105d:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801060:	83 c2 30             	add    $0x30,%edx
  801063:	88 10                	mov    %dl,(%eax)
		value = value / 10 ;
  801065:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801068:	b8 67 66 66 66       	mov    $0x66666667,%eax
  80106d:	f7 e9                	imul   %ecx
  80106f:	c1 fa 02             	sar    $0x2,%edx
  801072:	89 c8                	mov    %ecx,%eax
  801074:	c1 f8 1f             	sar    $0x1f,%eax
  801077:	29 c2                	sub    %eax,%edx
  801079:	89 d0                	mov    %edx,%eax
  80107b:	89 45 08             	mov    %eax,0x8(%ebp)
	} while (value % 10 != 0);
  80107e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801081:	b8 67 66 66 66       	mov    $0x66666667,%eax
  801086:	f7 e9                	imul   %ecx
  801088:	c1 fa 02             	sar    $0x2,%edx
  80108b:	89 c8                	mov    %ecx,%eax
  80108d:	c1 f8 1f             	sar    $0x1f,%eax
  801090:	29 c2                	sub    %eax,%edx
  801092:	89 d0                	mov    %edx,%eax
  801094:	c1 e0 02             	shl    $0x2,%eax
  801097:	01 d0                	add    %edx,%eax
  801099:	01 c0                	add    %eax,%eax
  80109b:	29 c1                	sub    %eax,%ecx
  80109d:	89 ca                	mov    %ecx,%edx
  80109f:	85 d2                	test   %edx,%edx
  8010a1:	75 9c                	jne    80103f <ltostr+0x2d>

	//reverse the string
	int start = 0 ;
  8010a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	int end = s-1 ;
  8010aa:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8010ad:	48                   	dec    %eax
  8010ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (neg)
  8010b1:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  8010b5:	74 3d                	je     8010f4 <ltostr+0xe2>
		start = 1 ;
  8010b7:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	while(start<end)
  8010be:	eb 34                	jmp    8010f4 <ltostr+0xe2>
	{
		char tmp = str[start] ;
  8010c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8010c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010c6:	01 d0                	add    %edx,%eax
  8010c8:	8a 00                	mov    (%eax),%al
  8010ca:	88 45 eb             	mov    %al,-0x15(%ebp)
		str[start] = str[end] ;
  8010cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8010d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010d3:	01 c2                	add    %eax,%edx
  8010d5:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8010d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010db:	01 c8                	add    %ecx,%eax
  8010dd:	8a 00                	mov    (%eax),%al
  8010df:	88 02                	mov    %al,(%edx)
		str[end] = tmp;
  8010e1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010e7:	01 c2                	add    %eax,%edx
  8010e9:	8a 45 eb             	mov    -0x15(%ebp),%al
  8010ec:	88 02                	mov    %al,(%edx)
		start++ ;
  8010ee:	ff 45 f4             	incl   -0xc(%ebp)
		end-- ;
  8010f1:	ff 4d f0             	decl   -0x10(%ebp)
	//reverse the string
	int start = 0 ;
	int end = s-1 ;
	if (neg)
		start = 1 ;
	while(start<end)
  8010f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010f7:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8010fa:	7c c4                	jl     8010c0 <ltostr+0xae>
		str[end] = tmp;
		start++ ;
		end-- ;
	}

	str[s] = 0 ;
  8010fc:	8b 55 f8             	mov    -0x8(%ebp),%edx
  8010ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  801102:	01 d0                	add    %edx,%eax
  801104:	c6 00 00             	movb   $0x0,(%eax)
	// we don't properly detect overflow!

}
  801107:	90                   	nop
  801108:	c9                   	leave  
  801109:	c3                   	ret    

0080110a <strcconcat>:

void
strcconcat(const char *str1, const char *str2, char *final)
{
  80110a:	55                   	push   %ebp
  80110b:	89 e5                	mov    %esp,%ebp
  80110d:	83 ec 10             	sub    $0x10,%esp
	int len1 = strlen(str1);
  801110:	ff 75 08             	pushl  0x8(%ebp)
  801113:	e8 54 fa ff ff       	call   800b6c <strlen>
  801118:	83 c4 04             	add    $0x4,%esp
  80111b:	89 45 f4             	mov    %eax,-0xc(%ebp)
	int len2 = strlen(str2);
  80111e:	ff 75 0c             	pushl  0xc(%ebp)
  801121:	e8 46 fa ff ff       	call   800b6c <strlen>
  801126:	83 c4 04             	add    $0x4,%esp
  801129:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int s = 0 ;
  80112c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	for (s=0 ; s < len1 ; s++)
  801133:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80113a:	eb 17                	jmp    801153 <strcconcat+0x49>
		final[s] = str1[s] ;
  80113c:	8b 55 fc             	mov    -0x4(%ebp),%edx
  80113f:	8b 45 10             	mov    0x10(%ebp),%eax
  801142:	01 c2                	add    %eax,%edx
  801144:	8b 4d fc             	mov    -0x4(%ebp),%ecx
  801147:	8b 45 08             	mov    0x8(%ebp),%eax
  80114a:	01 c8                	add    %ecx,%eax
  80114c:	8a 00                	mov    (%eax),%al
  80114e:	88 02                	mov    %al,(%edx)
strcconcat(const char *str1, const char *str2, char *final)
{
	int len1 = strlen(str1);
	int len2 = strlen(str2);
	int s = 0 ;
	for (s=0 ; s < len1 ; s++)
  801150:	ff 45 fc             	incl   -0x4(%ebp)
  801153:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801156:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  801159:	7c e1                	jl     80113c <strcconcat+0x32>
		final[s] = str1[s] ;

	int i = 0 ;
  80115b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
	for (i=0 ; i < len2 ; i++)
  801162:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  801169:	eb 1f                	jmp    80118a <strcconcat+0x80>
		final[s++] = str2[i] ;
  80116b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80116e:	8d 50 01             	lea    0x1(%eax),%edx
  801171:	89 55 fc             	mov    %edx,-0x4(%ebp)
  801174:	89 c2                	mov    %eax,%edx
  801176:	8b 45 10             	mov    0x10(%ebp),%eax
  801179:	01 c2                	add    %eax,%edx
  80117b:	8b 4d f8             	mov    -0x8(%ebp),%ecx
  80117e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801181:	01 c8                	add    %ecx,%eax
  801183:	8a 00                	mov    (%eax),%al
  801185:	88 02                	mov    %al,(%edx)
	int s = 0 ;
	for (s=0 ; s < len1 ; s++)
		final[s] = str1[s] ;

	int i = 0 ;
	for (i=0 ; i < len2 ; i++)
  801187:	ff 45 f8             	incl   -0x8(%ebp)
  80118a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80118d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  801190:	7c d9                	jl     80116b <strcconcat+0x61>
		final[s++] = str2[i] ;

	final[s] = 0;
  801192:	8b 55 fc             	mov    -0x4(%ebp),%edx
  801195:	8b 45 10             	mov    0x10(%ebp),%eax
  801198:	01 d0                	add    %edx,%eax
  80119a:	c6 00 00             	movb   $0x0,(%eax)
}
  80119d:	90                   	nop
  80119e:	c9                   	leave  
  80119f:	c3                   	ret    

008011a0 <strsplit>:
int strsplit(char *string, char *SPLIT_CHARS, char **argv, int * argc)
{
  8011a0:	55                   	push   %ebp
  8011a1:	89 e5                	mov    %esp,%ebp
	// Parse the command string into splitchars-separated arguments
	*argc = 0;
  8011a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8011a6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	(argv)[*argc] = 0;
  8011ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8011af:	8b 00                	mov    (%eax),%eax
  8011b1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8011b8:	8b 45 10             	mov    0x10(%ebp),%eax
  8011bb:	01 d0                	add    %edx,%eax
  8011bd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	while (1)
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
  8011c3:	eb 0c                	jmp    8011d1 <strsplit+0x31>
			*string++ = 0;
  8011c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c8:	8d 50 01             	lea    0x1(%eax),%edx
  8011cb:	89 55 08             	mov    %edx,0x8(%ebp)
  8011ce:	c6 00 00             	movb   $0x0,(%eax)
	*argc = 0;
	(argv)[*argc] = 0;
	while (1)
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
  8011d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d4:	8a 00                	mov    (%eax),%al
  8011d6:	84 c0                	test   %al,%al
  8011d8:	74 18                	je     8011f2 <strsplit+0x52>
  8011da:	8b 45 08             	mov    0x8(%ebp),%eax
  8011dd:	8a 00                	mov    (%eax),%al
  8011df:	0f be c0             	movsbl %al,%eax
  8011e2:	50                   	push   %eax
  8011e3:	ff 75 0c             	pushl  0xc(%ebp)
  8011e6:	e8 13 fb ff ff       	call   800cfe <strchr>
  8011eb:	83 c4 08             	add    $0x8,%esp
  8011ee:	85 c0                	test   %eax,%eax
  8011f0:	75 d3                	jne    8011c5 <strsplit+0x25>
			*string++ = 0;

		//if the command string is finished, then break the loop
		if (*string == 0)
  8011f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f5:	8a 00                	mov    (%eax),%al
  8011f7:	84 c0                	test   %al,%al
  8011f9:	74 5a                	je     801255 <strsplit+0xb5>
			break;

		//check current number of arguments
		if (*argc == MAX_ARGUMENTS-1)
  8011fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8011fe:	8b 00                	mov    (%eax),%eax
  801200:	83 f8 0f             	cmp    $0xf,%eax
  801203:	75 07                	jne    80120c <strsplit+0x6c>
		{
			return 0;
  801205:	b8 00 00 00 00       	mov    $0x0,%eax
  80120a:	eb 66                	jmp    801272 <strsplit+0xd2>
		}

		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
  80120c:	8b 45 14             	mov    0x14(%ebp),%eax
  80120f:	8b 00                	mov    (%eax),%eax
  801211:	8d 48 01             	lea    0x1(%eax),%ecx
  801214:	8b 55 14             	mov    0x14(%ebp),%edx
  801217:	89 0a                	mov    %ecx,(%edx)
  801219:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801220:	8b 45 10             	mov    0x10(%ebp),%eax
  801223:	01 c2                	add    %eax,%edx
  801225:	8b 45 08             	mov    0x8(%ebp),%eax
  801228:	89 02                	mov    %eax,(%edx)
		while (*string && !strchr(SPLIT_CHARS, *string))
  80122a:	eb 03                	jmp    80122f <strsplit+0x8f>
			string++;
  80122c:	ff 45 08             	incl   0x8(%ebp)
			return 0;
		}

		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
		while (*string && !strchr(SPLIT_CHARS, *string))
  80122f:	8b 45 08             	mov    0x8(%ebp),%eax
  801232:	8a 00                	mov    (%eax),%al
  801234:	84 c0                	test   %al,%al
  801236:	74 8b                	je     8011c3 <strsplit+0x23>
  801238:	8b 45 08             	mov    0x8(%ebp),%eax
  80123b:	8a 00                	mov    (%eax),%al
  80123d:	0f be c0             	movsbl %al,%eax
  801240:	50                   	push   %eax
  801241:	ff 75 0c             	pushl  0xc(%ebp)
  801244:	e8 b5 fa ff ff       	call   800cfe <strchr>
  801249:	83 c4 08             	add    $0x8,%esp
  80124c:	85 c0                	test   %eax,%eax
  80124e:	74 dc                	je     80122c <strsplit+0x8c>
			string++;
	}
  801250:	e9 6e ff ff ff       	jmp    8011c3 <strsplit+0x23>
		while (*string && strchr(SPLIT_CHARS, *string))
			*string++ = 0;

		//if the command string is finished, then break the loop
		if (*string == 0)
			break;
  801255:	90                   	nop
		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
		while (*string && !strchr(SPLIT_CHARS, *string))
			string++;
	}
	(argv)[*argc] = 0;
  801256:	8b 45 14             	mov    0x14(%ebp),%eax
  801259:	8b 00                	mov    (%eax),%eax
  80125b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801262:	8b 45 10             	mov    0x10(%ebp),%eax
  801265:	01 d0                	add    %edx,%eax
  801267:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return 1 ;
  80126d:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801272:	c9                   	leave  
  801273:	c3                   	ret    

00801274 <str2lower>:


/*2024*/
char* str2lower(char *dst, const char *src)
{
  801274:	55                   	push   %ebp
  801275:	89 e5                	mov    %esp,%ebp
  801277:	83 ec 20             	sub    $0x20,%esp
	//TODO: [PROJECT'23.MS1 - #1] [1] PLAY WITH CODE! - str2lower
	//Comment the following line before start coding...
	//panic("process_command is not implemented yet");
	long long size = strlen(src);
  80127a:	ff 75 0c             	pushl  0xc(%ebp)
  80127d:	e8 ea f8 ff ff       	call   800b6c <strlen>
  801282:	83 c4 04             	add    $0x4,%esp
  801285:	99                   	cltd   
  801286:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801289:	89 55 f4             	mov    %edx,-0xc(%ebp)
	for(long long i=0;i<size;i++)
  80128c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  801293:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80129a:	eb 57                	jmp    8012f3 <str2lower+0x7f>
	{
		if(src[i] >=65 && src[i] <=90)
  80129c:	8b 55 f8             	mov    -0x8(%ebp),%edx
  80129f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012a2:	01 d0                	add    %edx,%eax
  8012a4:	8a 00                	mov    (%eax),%al
  8012a6:	3c 40                	cmp    $0x40,%al
  8012a8:	7e 2d                	jle    8012d7 <str2lower+0x63>
  8012aa:	8b 55 f8             	mov    -0x8(%ebp),%edx
  8012ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012b0:	01 d0                	add    %edx,%eax
  8012b2:	8a 00                	mov    (%eax),%al
  8012b4:	3c 5a                	cmp    $0x5a,%al
  8012b6:	7f 1f                	jg     8012d7 <str2lower+0x63>
		{
			char temp = src[i] + 32;
  8012b8:	8b 55 f8             	mov    -0x8(%ebp),%edx
  8012bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012be:	01 d0                	add    %edx,%eax
  8012c0:	8a 00                	mov    (%eax),%al
  8012c2:	83 c0 20             	add    $0x20,%eax
  8012c5:	88 45 ef             	mov    %al,-0x11(%ebp)
			dst[i] = temp;
  8012c8:	8b 55 f8             	mov    -0x8(%ebp),%edx
  8012cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ce:	01 c2                	add    %eax,%edx
  8012d0:	8a 45 ef             	mov    -0x11(%ebp),%al
  8012d3:	88 02                	mov    %al,(%edx)
	//panic("process_command is not implemented yet");
	long long size = strlen(src);
	for(long long i=0;i<size;i++)
	{
		if(src[i] >=65 && src[i] <=90)
		{
  8012d5:	eb 14                	jmp    8012eb <str2lower+0x77>
			char temp = src[i] + 32;
			dst[i] = temp;
		}
		else
		{
			dst[i] = src[i];
  8012d7:	8b 55 f8             	mov    -0x8(%ebp),%edx
  8012da:	8b 45 08             	mov    0x8(%ebp),%eax
  8012dd:	01 c2                	add    %eax,%edx
  8012df:	8b 4d f8             	mov    -0x8(%ebp),%ecx
  8012e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012e5:	01 c8                	add    %ecx,%eax
  8012e7:	8a 00                	mov    (%eax),%al
  8012e9:	88 02                	mov    %al,(%edx)
{
	//TODO: [PROJECT'23.MS1 - #1] [1] PLAY WITH CODE! - str2lower
	//Comment the following line before start coding...
	//panic("process_command is not implemented yet");
	long long size = strlen(src);
	for(long long i=0;i<size;i++)
  8012eb:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  8012ef:	83 55 fc 00          	adcl   $0x0,-0x4(%ebp)
  8012f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8012f6:	8b 55 fc             	mov    -0x4(%ebp),%edx
  8012f9:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8012fc:	7c 9e                	jl     80129c <str2lower+0x28>
  8012fe:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  801301:	7f 05                	jg     801308 <str2lower+0x94>
  801303:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  801306:	72 94                	jb     80129c <str2lower+0x28>
		else
		{
			dst[i] = src[i];
		}
	}
	return dst;
  801308:	8b 45 08             	mov    0x8(%ebp),%eax
}
  80130b:	c9                   	leave  
  80130c:	c3                   	ret    

0080130d <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline uint32
syscall(int num, uint32 a1, uint32 a2, uint32 a3, uint32 a4, uint32 a5)
{
  80130d:	55                   	push   %ebp
  80130e:	89 e5                	mov    %esp,%ebp
  801310:	57                   	push   %edi
  801311:	56                   	push   %esi
  801312:	53                   	push   %ebx
  801313:	83 ec 10             	sub    $0x10,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801316:	8b 45 08             	mov    0x8(%ebp),%eax
  801319:	8b 55 0c             	mov    0xc(%ebp),%edx
  80131c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80131f:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801322:	8b 7d 18             	mov    0x18(%ebp),%edi
  801325:	8b 75 1c             	mov    0x1c(%ebp),%esi
  801328:	cd 30                	int    $0x30
  80132a:	89 45 f0             	mov    %eax,-0x10(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	return ret;
  80132d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  801330:	83 c4 10             	add    $0x10,%esp
  801333:	5b                   	pop    %ebx
  801334:	5e                   	pop    %esi
  801335:	5f                   	pop    %edi
  801336:	5d                   	pop    %ebp
  801337:	c3                   	ret    

00801338 <sys_cputs>:

void
sys_cputs(const char *s, uint32 len, uint8 printProgName)
{
  801338:	55                   	push   %ebp
  801339:	89 e5                	mov    %esp,%ebp
  80133b:	83 ec 04             	sub    $0x4,%esp
  80133e:	8b 45 10             	mov    0x10(%ebp),%eax
  801341:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_cputs, (uint32) s, len, (uint32)printProgName, 0, 0);
  801344:	0f b6 55 fc          	movzbl -0x4(%ebp),%edx
  801348:	8b 45 08             	mov    0x8(%ebp),%eax
  80134b:	6a 00                	push   $0x0
  80134d:	6a 00                	push   $0x0
  80134f:	52                   	push   %edx
  801350:	ff 75 0c             	pushl  0xc(%ebp)
  801353:	50                   	push   %eax
  801354:	6a 00                	push   $0x0
  801356:	e8 b2 ff ff ff       	call   80130d <syscall>
  80135b:	83 c4 18             	add    $0x18,%esp
}
  80135e:	90                   	nop
  80135f:	c9                   	leave  
  801360:	c3                   	ret    

00801361 <sys_cgetc>:

int
sys_cgetc(void)
{
  801361:	55                   	push   %ebp
  801362:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0);
  801364:	6a 00                	push   $0x0
  801366:	6a 00                	push   $0x0
  801368:	6a 00                	push   $0x0
  80136a:	6a 00                	push   $0x0
  80136c:	6a 00                	push   $0x0
  80136e:	6a 01                	push   $0x1
  801370:	e8 98 ff ff ff       	call   80130d <syscall>
  801375:	83 c4 18             	add    $0x18,%esp
}
  801378:	c9                   	leave  
  801379:	c3                   	ret    

0080137a <__sys_allocate_page>:

int __sys_allocate_page(void *va, int perm)
{
  80137a:	55                   	push   %ebp
  80137b:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_allocate_page, (uint32) va, perm, 0 , 0, 0);
  80137d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801380:	8b 45 08             	mov    0x8(%ebp),%eax
  801383:	6a 00                	push   $0x0
  801385:	6a 00                	push   $0x0
  801387:	6a 00                	push   $0x0
  801389:	52                   	push   %edx
  80138a:	50                   	push   %eax
  80138b:	6a 05                	push   $0x5
  80138d:	e8 7b ff ff ff       	call   80130d <syscall>
  801392:	83 c4 18             	add    $0x18,%esp
}
  801395:	c9                   	leave  
  801396:	c3                   	ret    

00801397 <__sys_map_frame>:

int __sys_map_frame(int32 srcenv, void *srcva, int32 dstenv, void *dstva, int perm)
{
  801397:	55                   	push   %ebp
  801398:	89 e5                	mov    %esp,%ebp
  80139a:	56                   	push   %esi
  80139b:	53                   	push   %ebx
	return syscall(SYS_map_frame, srcenv, (uint32) srcva, dstenv, (uint32) dstva, perm);
  80139c:	8b 75 18             	mov    0x18(%ebp),%esi
  80139f:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8013a2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8013a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ab:	56                   	push   %esi
  8013ac:	53                   	push   %ebx
  8013ad:	51                   	push   %ecx
  8013ae:	52                   	push   %edx
  8013af:	50                   	push   %eax
  8013b0:	6a 06                	push   $0x6
  8013b2:	e8 56 ff ff ff       	call   80130d <syscall>
  8013b7:	83 c4 18             	add    $0x18,%esp
}
  8013ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013bd:	5b                   	pop    %ebx
  8013be:	5e                   	pop    %esi
  8013bf:	5d                   	pop    %ebp
  8013c0:	c3                   	ret    

008013c1 <__sys_unmap_frame>:

int __sys_unmap_frame(int32 envid, void *va)
{
  8013c1:	55                   	push   %ebp
  8013c2:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_unmap_frame, envid, (uint32) va, 0, 0, 0);
  8013c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ca:	6a 00                	push   $0x0
  8013cc:	6a 00                	push   $0x0
  8013ce:	6a 00                	push   $0x0
  8013d0:	52                   	push   %edx
  8013d1:	50                   	push   %eax
  8013d2:	6a 07                	push   $0x7
  8013d4:	e8 34 ff ff ff       	call   80130d <syscall>
  8013d9:	83 c4 18             	add    $0x18,%esp
}
  8013dc:	c9                   	leave  
  8013dd:	c3                   	ret    

008013de <sys_calculate_required_frames>:

uint32 sys_calculate_required_frames(uint32 start_virtual_address, uint32 size)
{
  8013de:	55                   	push   %ebp
  8013df:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_req_frames, start_virtual_address, (uint32) size, 0, 0, 0);
  8013e1:	6a 00                	push   $0x0
  8013e3:	6a 00                	push   $0x0
  8013e5:	6a 00                	push   $0x0
  8013e7:	ff 75 0c             	pushl  0xc(%ebp)
  8013ea:	ff 75 08             	pushl  0x8(%ebp)
  8013ed:	6a 08                	push   $0x8
  8013ef:	e8 19 ff ff ff       	call   80130d <syscall>
  8013f4:	83 c4 18             	add    $0x18,%esp
}
  8013f7:	c9                   	leave  
  8013f8:	c3                   	ret    

008013f9 <sys_calculate_free_frames>:

uint32 sys_calculate_free_frames()
{
  8013f9:	55                   	push   %ebp
  8013fa:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_free_frames, 0, 0, 0, 0, 0);
  8013fc:	6a 00                	push   $0x0
  8013fe:	6a 00                	push   $0x0
  801400:	6a 00                	push   $0x0
  801402:	6a 00                	push   $0x0
  801404:	6a 00                	push   $0x0
  801406:	6a 09                	push   $0x9
  801408:	e8 00 ff ff ff       	call   80130d <syscall>
  80140d:	83 c4 18             	add    $0x18,%esp
}
  801410:	c9                   	leave  
  801411:	c3                   	ret    

00801412 <sys_calculate_modified_frames>:
uint32 sys_calculate_modified_frames()
{
  801412:	55                   	push   %ebp
  801413:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_modified_frames, 0, 0, 0, 0, 0);
  801415:	6a 00                	push   $0x0
  801417:	6a 00                	push   $0x0
  801419:	6a 00                	push   $0x0
  80141b:	6a 00                	push   $0x0
  80141d:	6a 00                	push   $0x0
  80141f:	6a 0a                	push   $0xa
  801421:	e8 e7 fe ff ff       	call   80130d <syscall>
  801426:	83 c4 18             	add    $0x18,%esp
}
  801429:	c9                   	leave  
  80142a:	c3                   	ret    

0080142b <sys_calculate_notmod_frames>:

uint32 sys_calculate_notmod_frames()
{
  80142b:	55                   	push   %ebp
  80142c:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_notmod_frames, 0, 0, 0, 0, 0);
  80142e:	6a 00                	push   $0x0
  801430:	6a 00                	push   $0x0
  801432:	6a 00                	push   $0x0
  801434:	6a 00                	push   $0x0
  801436:	6a 00                	push   $0x0
  801438:	6a 0b                	push   $0xb
  80143a:	e8 ce fe ff ff       	call   80130d <syscall>
  80143f:	83 c4 18             	add    $0x18,%esp
}
  801442:	c9                   	leave  
  801443:	c3                   	ret    

00801444 <sys_pf_calculate_allocated_pages>:



int sys_pf_calculate_allocated_pages()
{
  801444:	55                   	push   %ebp
  801445:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_pf_calc_allocated_pages, 0,0,0,0,0);
  801447:	6a 00                	push   $0x0
  801449:	6a 00                	push   $0x0
  80144b:	6a 00                	push   $0x0
  80144d:	6a 00                	push   $0x0
  80144f:	6a 00                	push   $0x0
  801451:	6a 0c                	push   $0xc
  801453:	e8 b5 fe ff ff       	call   80130d <syscall>
  801458:	83 c4 18             	add    $0x18,%esp
}
  80145b:	c9                   	leave  
  80145c:	c3                   	ret    

0080145d <sys_calculate_pages_tobe_removed_ready_exit>:

int sys_calculate_pages_tobe_removed_ready_exit(uint32 WS_or_MEMORY_flag)
{
  80145d:	55                   	push   %ebp
  80145e:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calculate_pages_tobe_removed_ready_exit, WS_or_MEMORY_flag,0,0,0,0);
  801460:	6a 00                	push   $0x0
  801462:	6a 00                	push   $0x0
  801464:	6a 00                	push   $0x0
  801466:	6a 00                	push   $0x0
  801468:	ff 75 08             	pushl  0x8(%ebp)
  80146b:	6a 0d                	push   $0xd
  80146d:	e8 9b fe ff ff       	call   80130d <syscall>
  801472:	83 c4 18             	add    $0x18,%esp
}
  801475:	c9                   	leave  
  801476:	c3                   	ret    

00801477 <sys_scarce_memory>:

void sys_scarce_memory()
{
  801477:	55                   	push   %ebp
  801478:	89 e5                	mov    %esp,%ebp
	syscall(SYS_scarce_memory,0,0,0,0,0);
  80147a:	6a 00                	push   $0x0
  80147c:	6a 00                	push   $0x0
  80147e:	6a 00                	push   $0x0
  801480:	6a 00                	push   $0x0
  801482:	6a 00                	push   $0x0
  801484:	6a 0e                	push   $0xe
  801486:	e8 82 fe ff ff       	call   80130d <syscall>
  80148b:	83 c4 18             	add    $0x18,%esp
}
  80148e:	90                   	nop
  80148f:	c9                   	leave  
  801490:	c3                   	ret    

00801491 <sys_disable_interrupt>:

//NEW !! 2012...
void
sys_disable_interrupt()
{
  801491:	55                   	push   %ebp
  801492:	89 e5                	mov    %esp,%ebp
	syscall(SYS_disableINTR,0, 0, 0, 0, 0);
  801494:	6a 00                	push   $0x0
  801496:	6a 00                	push   $0x0
  801498:	6a 00                	push   $0x0
  80149a:	6a 00                	push   $0x0
  80149c:	6a 00                	push   $0x0
  80149e:	6a 11                	push   $0x11
  8014a0:	e8 68 fe ff ff       	call   80130d <syscall>
  8014a5:	83 c4 18             	add    $0x18,%esp
}
  8014a8:	90                   	nop
  8014a9:	c9                   	leave  
  8014aa:	c3                   	ret    

008014ab <sys_enable_interrupt>:


void
sys_enable_interrupt()
{
  8014ab:	55                   	push   %ebp
  8014ac:	89 e5                	mov    %esp,%ebp
	syscall(SYS_enableINTR,0, 0, 0, 0, 0);
  8014ae:	6a 00                	push   $0x0
  8014b0:	6a 00                	push   $0x0
  8014b2:	6a 00                	push   $0x0
  8014b4:	6a 00                	push   $0x0
  8014b6:	6a 00                	push   $0x0
  8014b8:	6a 12                	push   $0x12
  8014ba:	e8 4e fe ff ff       	call   80130d <syscall>
  8014bf:	83 c4 18             	add    $0x18,%esp
}
  8014c2:	90                   	nop
  8014c3:	c9                   	leave  
  8014c4:	c3                   	ret    

008014c5 <sys_cputc>:


void
sys_cputc(const char c)
{
  8014c5:	55                   	push   %ebp
  8014c6:	89 e5                	mov    %esp,%ebp
  8014c8:	83 ec 04             	sub    $0x4,%esp
  8014cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ce:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_cputc, (uint32) c, 0, 0, 0, 0);
  8014d1:	0f be 45 fc          	movsbl -0x4(%ebp),%eax
  8014d5:	6a 00                	push   $0x0
  8014d7:	6a 00                	push   $0x0
  8014d9:	6a 00                	push   $0x0
  8014db:	6a 00                	push   $0x0
  8014dd:	50                   	push   %eax
  8014de:	6a 13                	push   $0x13
  8014e0:	e8 28 fe ff ff       	call   80130d <syscall>
  8014e5:	83 c4 18             	add    $0x18,%esp
}
  8014e8:	90                   	nop
  8014e9:	c9                   	leave  
  8014ea:	c3                   	ret    

008014eb <sys_clear_ffl>:


//NEW'12: BONUS2 Testing
void
sys_clear_ffl()
{
  8014eb:	55                   	push   %ebp
  8014ec:	89 e5                	mov    %esp,%ebp
	syscall(SYS_clearFFL,0, 0, 0, 0, 0);
  8014ee:	6a 00                	push   $0x0
  8014f0:	6a 00                	push   $0x0
  8014f2:	6a 00                	push   $0x0
  8014f4:	6a 00                	push   $0x0
  8014f6:	6a 00                	push   $0x0
  8014f8:	6a 14                	push   $0x14
  8014fa:	e8 0e fe ff ff       	call   80130d <syscall>
  8014ff:	83 c4 18             	add    $0x18,%esp
}
  801502:	90                   	nop
  801503:	c9                   	leave  
  801504:	c3                   	ret    

00801505 <sys_createSemaphore>:

int
sys_createSemaphore(char* semaphoreName, uint32 initialValue)
{
  801505:	55                   	push   %ebp
  801506:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_create_semaphore,(uint32)semaphoreName, (uint32)initialValue, 0, 0, 0);
  801508:	8b 45 08             	mov    0x8(%ebp),%eax
  80150b:	6a 00                	push   $0x0
  80150d:	6a 00                	push   $0x0
  80150f:	6a 00                	push   $0x0
  801511:	ff 75 0c             	pushl  0xc(%ebp)
  801514:	50                   	push   %eax
  801515:	6a 15                	push   $0x15
  801517:	e8 f1 fd ff ff       	call   80130d <syscall>
  80151c:	83 c4 18             	add    $0x18,%esp
}
  80151f:	c9                   	leave  
  801520:	c3                   	ret    

00801521 <sys_getSemaphoreValue>:

int
sys_getSemaphoreValue(int32 ownerEnvID, char* semaphoreName)
{
  801521:	55                   	push   %ebp
  801522:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_get_semaphore_value,(uint32) ownerEnvID, (uint32)semaphoreName, 0, 0, 0);
  801524:	8b 55 0c             	mov    0xc(%ebp),%edx
  801527:	8b 45 08             	mov    0x8(%ebp),%eax
  80152a:	6a 00                	push   $0x0
  80152c:	6a 00                	push   $0x0
  80152e:	6a 00                	push   $0x0
  801530:	52                   	push   %edx
  801531:	50                   	push   %eax
  801532:	6a 18                	push   $0x18
  801534:	e8 d4 fd ff ff       	call   80130d <syscall>
  801539:	83 c4 18             	add    $0x18,%esp
}
  80153c:	c9                   	leave  
  80153d:	c3                   	ret    

0080153e <sys_waitSemaphore>:

void
sys_waitSemaphore(int32 ownerEnvID, char* semaphoreName)
{
  80153e:	55                   	push   %ebp
  80153f:	89 e5                	mov    %esp,%ebp
	syscall(SYS_wait_semaphore,(uint32) ownerEnvID, (uint32)semaphoreName, 0, 0, 0);
  801541:	8b 55 0c             	mov    0xc(%ebp),%edx
  801544:	8b 45 08             	mov    0x8(%ebp),%eax
  801547:	6a 00                	push   $0x0
  801549:	6a 00                	push   $0x0
  80154b:	6a 00                	push   $0x0
  80154d:	52                   	push   %edx
  80154e:	50                   	push   %eax
  80154f:	6a 16                	push   $0x16
  801551:	e8 b7 fd ff ff       	call   80130d <syscall>
  801556:	83 c4 18             	add    $0x18,%esp
}
  801559:	90                   	nop
  80155a:	c9                   	leave  
  80155b:	c3                   	ret    

0080155c <sys_signalSemaphore>:

void
sys_signalSemaphore(int32 ownerEnvID, char* semaphoreName)
{
  80155c:	55                   	push   %ebp
  80155d:	89 e5                	mov    %esp,%ebp
	syscall(SYS_signal_semaphore,(uint32) ownerEnvID, (uint32)semaphoreName, 0, 0, 0);
  80155f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801562:	8b 45 08             	mov    0x8(%ebp),%eax
  801565:	6a 00                	push   $0x0
  801567:	6a 00                	push   $0x0
  801569:	6a 00                	push   $0x0
  80156b:	52                   	push   %edx
  80156c:	50                   	push   %eax
  80156d:	6a 17                	push   $0x17
  80156f:	e8 99 fd ff ff       	call   80130d <syscall>
  801574:	83 c4 18             	add    $0x18,%esp
}
  801577:	90                   	nop
  801578:	c9                   	leave  
  801579:	c3                   	ret    

0080157a <sys_createSharedObject>:

int
sys_createSharedObject(char* shareName, uint32 size, uint8 isWritable, void* virtual_address)
{
  80157a:	55                   	push   %ebp
  80157b:	89 e5                	mov    %esp,%ebp
  80157d:	83 ec 04             	sub    $0x4,%esp
  801580:	8b 45 10             	mov    0x10(%ebp),%eax
  801583:	88 45 fc             	mov    %al,-0x4(%ebp)
	return syscall(SYS_create_shared_object,(uint32)shareName, (uint32)size, isWritable, (uint32)virtual_address,  0);
  801586:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801589:	0f b6 55 fc          	movzbl -0x4(%ebp),%edx
  80158d:	8b 45 08             	mov    0x8(%ebp),%eax
  801590:	6a 00                	push   $0x0
  801592:	51                   	push   %ecx
  801593:	52                   	push   %edx
  801594:	ff 75 0c             	pushl  0xc(%ebp)
  801597:	50                   	push   %eax
  801598:	6a 19                	push   $0x19
  80159a:	e8 6e fd ff ff       	call   80130d <syscall>
  80159f:	83 c4 18             	add    $0x18,%esp
}
  8015a2:	c9                   	leave  
  8015a3:	c3                   	ret    

008015a4 <sys_getSizeOfSharedObject>:

//2017:
int
sys_getSizeOfSharedObject(int32 ownerID, char* shareName)
{
  8015a4:	55                   	push   %ebp
  8015a5:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_get_size_of_shared_object,(uint32) ownerID, (uint32)shareName, 0, 0, 0);
  8015a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ad:	6a 00                	push   $0x0
  8015af:	6a 00                	push   $0x0
  8015b1:	6a 00                	push   $0x0
  8015b3:	52                   	push   %edx
  8015b4:	50                   	push   %eax
  8015b5:	6a 1a                	push   $0x1a
  8015b7:	e8 51 fd ff ff       	call   80130d <syscall>
  8015bc:	83 c4 18             	add    $0x18,%esp
}
  8015bf:	c9                   	leave  
  8015c0:	c3                   	ret    

008015c1 <sys_getSharedObject>:
//==========

int
sys_getSharedObject(int32 ownerID, char* shareName, void* virtual_address)
{
  8015c1:	55                   	push   %ebp
  8015c2:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_get_shared_object,(uint32) ownerID, (uint32)shareName, (uint32)virtual_address, 0, 0);
  8015c4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8015cd:	6a 00                	push   $0x0
  8015cf:	6a 00                	push   $0x0
  8015d1:	51                   	push   %ecx
  8015d2:	52                   	push   %edx
  8015d3:	50                   	push   %eax
  8015d4:	6a 1b                	push   $0x1b
  8015d6:	e8 32 fd ff ff       	call   80130d <syscall>
  8015db:	83 c4 18             	add    $0x18,%esp
}
  8015de:	c9                   	leave  
  8015df:	c3                   	ret    

008015e0 <sys_freeSharedObject>:

int
sys_freeSharedObject(int32 sharedObjectID, void *startVA)
{
  8015e0:	55                   	push   %ebp
  8015e1:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_free_shared_object,(uint32) sharedObjectID, (uint32) startVA, 0, 0, 0);
  8015e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e9:	6a 00                	push   $0x0
  8015eb:	6a 00                	push   $0x0
  8015ed:	6a 00                	push   $0x0
  8015ef:	52                   	push   %edx
  8015f0:	50                   	push   %eax
  8015f1:	6a 1c                	push   $0x1c
  8015f3:	e8 15 fd ff ff       	call   80130d <syscall>
  8015f8:	83 c4 18             	add    $0x18,%esp
}
  8015fb:	c9                   	leave  
  8015fc:	c3                   	ret    

008015fd <sys_getMaxShares>:

uint32 	sys_getMaxShares()
{
  8015fd:	55                   	push   %ebp
  8015fe:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_get_max_shares,0, 0, 0, 0, 0);
  801600:	6a 00                	push   $0x0
  801602:	6a 00                	push   $0x0
  801604:	6a 00                	push   $0x0
  801606:	6a 00                	push   $0x0
  801608:	6a 00                	push   $0x0
  80160a:	6a 1d                	push   $0x1d
  80160c:	e8 fc fc ff ff       	call   80130d <syscall>
  801611:	83 c4 18             	add    $0x18,%esp
}
  801614:	c9                   	leave  
  801615:	c3                   	ret    

00801616 <sys_create_env>:

int sys_create_env(char* programName, unsigned int page_WS_size,unsigned int LRU_second_list_size,unsigned int percent_WS_pages_to_remove)
{
  801616:	55                   	push   %ebp
  801617:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_create_env,(uint32)programName, (uint32)page_WS_size,(uint32)LRU_second_list_size, (uint32)percent_WS_pages_to_remove, 0);
  801619:	8b 45 08             	mov    0x8(%ebp),%eax
  80161c:	6a 00                	push   $0x0
  80161e:	ff 75 14             	pushl  0x14(%ebp)
  801621:	ff 75 10             	pushl  0x10(%ebp)
  801624:	ff 75 0c             	pushl  0xc(%ebp)
  801627:	50                   	push   %eax
  801628:	6a 1e                	push   $0x1e
  80162a:	e8 de fc ff ff       	call   80130d <syscall>
  80162f:	83 c4 18             	add    $0x18,%esp
}
  801632:	c9                   	leave  
  801633:	c3                   	ret    

00801634 <sys_run_env>:

void
sys_run_env(int32 envId)
{
  801634:	55                   	push   %ebp
  801635:	89 e5                	mov    %esp,%ebp
	syscall(SYS_run_env, (int32)envId, 0, 0, 0, 0);
  801637:	8b 45 08             	mov    0x8(%ebp),%eax
  80163a:	6a 00                	push   $0x0
  80163c:	6a 00                	push   $0x0
  80163e:	6a 00                	push   $0x0
  801640:	6a 00                	push   $0x0
  801642:	50                   	push   %eax
  801643:	6a 1f                	push   $0x1f
  801645:	e8 c3 fc ff ff       	call   80130d <syscall>
  80164a:	83 c4 18             	add    $0x18,%esp
}
  80164d:	90                   	nop
  80164e:	c9                   	leave  
  80164f:	c3                   	ret    

00801650 <sys_destroy_env>:

int sys_destroy_env(int32  envid)
{
  801650:	55                   	push   %ebp
  801651:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_destroy_env, envid, 0, 0, 0, 0);
  801653:	8b 45 08             	mov    0x8(%ebp),%eax
  801656:	6a 00                	push   $0x0
  801658:	6a 00                	push   $0x0
  80165a:	6a 00                	push   $0x0
  80165c:	6a 00                	push   $0x0
  80165e:	50                   	push   %eax
  80165f:	6a 20                	push   $0x20
  801661:	e8 a7 fc ff ff       	call   80130d <syscall>
  801666:	83 c4 18             	add    $0x18,%esp
}
  801669:	c9                   	leave  
  80166a:	c3                   	ret    

0080166b <sys_getenvid>:

int32 sys_getenvid(void)
{
  80166b:	55                   	push   %ebp
  80166c:	89 e5                	mov    %esp,%ebp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0);
  80166e:	6a 00                	push   $0x0
  801670:	6a 00                	push   $0x0
  801672:	6a 00                	push   $0x0
  801674:	6a 00                	push   $0x0
  801676:	6a 00                	push   $0x0
  801678:	6a 02                	push   $0x2
  80167a:	e8 8e fc ff ff       	call   80130d <syscall>
  80167f:	83 c4 18             	add    $0x18,%esp
}
  801682:	c9                   	leave  
  801683:	c3                   	ret    

00801684 <sys_getenvindex>:

//2017
int32 sys_getenvindex(void)
{
  801684:	55                   	push   %ebp
  801685:	89 e5                	mov    %esp,%ebp
	 return syscall(SYS_getenvindex, 0, 0, 0, 0, 0);
  801687:	6a 00                	push   $0x0
  801689:	6a 00                	push   $0x0
  80168b:	6a 00                	push   $0x0
  80168d:	6a 00                	push   $0x0
  80168f:	6a 00                	push   $0x0
  801691:	6a 03                	push   $0x3
  801693:	e8 75 fc ff ff       	call   80130d <syscall>
  801698:	83 c4 18             	add    $0x18,%esp
}
  80169b:	c9                   	leave  
  80169c:	c3                   	ret    

0080169d <sys_getparentenvid>:

int32 sys_getparentenvid(void)
{
  80169d:	55                   	push   %ebp
  80169e:	89 e5                	mov    %esp,%ebp
	 return syscall(SYS_getparentenvid, 0, 0, 0, 0, 0);
  8016a0:	6a 00                	push   $0x0
  8016a2:	6a 00                	push   $0x0
  8016a4:	6a 00                	push   $0x0
  8016a6:	6a 00                	push   $0x0
  8016a8:	6a 00                	push   $0x0
  8016aa:	6a 04                	push   $0x4
  8016ac:	e8 5c fc ff ff       	call   80130d <syscall>
  8016b1:	83 c4 18             	add    $0x18,%esp
}
  8016b4:	c9                   	leave  
  8016b5:	c3                   	ret    

008016b6 <sys_exit_env>:


void sys_exit_env(void)
{
  8016b6:	55                   	push   %ebp
  8016b7:	89 e5                	mov    %esp,%ebp
	syscall(SYS_exit_env, 0, 0, 0, 0, 0);
  8016b9:	6a 00                	push   $0x0
  8016bb:	6a 00                	push   $0x0
  8016bd:	6a 00                	push   $0x0
  8016bf:	6a 00                	push   $0x0
  8016c1:	6a 00                	push   $0x0
  8016c3:	6a 21                	push   $0x21
  8016c5:	e8 43 fc ff ff       	call   80130d <syscall>
  8016ca:	83 c4 18             	add    $0x18,%esp
}
  8016cd:	90                   	nop
  8016ce:	c9                   	leave  
  8016cf:	c3                   	ret    

008016d0 <sys_get_virtual_time>:


struct uint64
sys_get_virtual_time()
{
  8016d0:	55                   	push   %ebp
  8016d1:	89 e5                	mov    %esp,%ebp
  8016d3:	83 ec 10             	sub    $0x10,%esp
	struct uint64 result;
	syscall(SYS_get_virtual_time, (uint32)&(result.low), (uint32)&(result.hi), 0, 0, 0);
  8016d6:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8016d9:	8d 50 04             	lea    0x4(%eax),%edx
  8016dc:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8016df:	6a 00                	push   $0x0
  8016e1:	6a 00                	push   $0x0
  8016e3:	6a 00                	push   $0x0
  8016e5:	52                   	push   %edx
  8016e6:	50                   	push   %eax
  8016e7:	6a 22                	push   $0x22
  8016e9:	e8 1f fc ff ff       	call   80130d <syscall>
  8016ee:	83 c4 18             	add    $0x18,%esp
	return result;
  8016f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016f4:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8016f7:	8b 55 fc             	mov    -0x4(%ebp),%edx
  8016fa:	89 01                	mov    %eax,(%ecx)
  8016fc:	89 51 04             	mov    %edx,0x4(%ecx)
}
  8016ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801702:	c9                   	leave  
  801703:	c2 04 00             	ret    $0x4

00801706 <sys_move_user_mem>:

// 2014
void sys_move_user_mem(uint32 src_virtual_address, uint32 dst_virtual_address, uint32 size)
{
  801706:	55                   	push   %ebp
  801707:	89 e5                	mov    %esp,%ebp
	syscall(SYS_move_user_mem, src_virtual_address, dst_virtual_address, size, 0, 0);
  801709:	6a 00                	push   $0x0
  80170b:	6a 00                	push   $0x0
  80170d:	ff 75 10             	pushl  0x10(%ebp)
  801710:	ff 75 0c             	pushl  0xc(%ebp)
  801713:	ff 75 08             	pushl  0x8(%ebp)
  801716:	6a 10                	push   $0x10
  801718:	e8 f0 fb ff ff       	call   80130d <syscall>
  80171d:	83 c4 18             	add    $0x18,%esp
	return ;
  801720:	90                   	nop
}
  801721:	c9                   	leave  
  801722:	c3                   	ret    

00801723 <sys_rcr2>:
uint32 sys_rcr2()
{
  801723:	55                   	push   %ebp
  801724:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_rcr2, 0, 0, 0, 0, 0);
  801726:	6a 00                	push   $0x0
  801728:	6a 00                	push   $0x0
  80172a:	6a 00                	push   $0x0
  80172c:	6a 00                	push   $0x0
  80172e:	6a 00                	push   $0x0
  801730:	6a 23                	push   $0x23
  801732:	e8 d6 fb ff ff       	call   80130d <syscall>
  801737:	83 c4 18             	add    $0x18,%esp
}
  80173a:	c9                   	leave  
  80173b:	c3                   	ret    

0080173c <sys_bypassPageFault>:
void sys_bypassPageFault(uint8 instrLength)
{
  80173c:	55                   	push   %ebp
  80173d:	89 e5                	mov    %esp,%ebp
  80173f:	83 ec 04             	sub    $0x4,%esp
  801742:	8b 45 08             	mov    0x8(%ebp),%eax
  801745:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_bypassPageFault, instrLength, 0, 0, 0, 0);
  801748:	0f b6 45 fc          	movzbl -0x4(%ebp),%eax
  80174c:	6a 00                	push   $0x0
  80174e:	6a 00                	push   $0x0
  801750:	6a 00                	push   $0x0
  801752:	6a 00                	push   $0x0
  801754:	50                   	push   %eax
  801755:	6a 24                	push   $0x24
  801757:	e8 b1 fb ff ff       	call   80130d <syscall>
  80175c:	83 c4 18             	add    $0x18,%esp
	return ;
  80175f:	90                   	nop
}
  801760:	c9                   	leave  
  801761:	c3                   	ret    

00801762 <rsttst>:
void rsttst()
{
  801762:	55                   	push   %ebp
  801763:	89 e5                	mov    %esp,%ebp
	syscall(SYS_rsttst, 0, 0, 0, 0, 0);
  801765:	6a 00                	push   $0x0
  801767:	6a 00                	push   $0x0
  801769:	6a 00                	push   $0x0
  80176b:	6a 00                	push   $0x0
  80176d:	6a 00                	push   $0x0
  80176f:	6a 26                	push   $0x26
  801771:	e8 97 fb ff ff       	call   80130d <syscall>
  801776:	83 c4 18             	add    $0x18,%esp
	return ;
  801779:	90                   	nop
}
  80177a:	c9                   	leave  
  80177b:	c3                   	ret    

0080177c <tst>:
void tst(uint32 n, uint32 v1, uint32 v2, char c, int inv)
{
  80177c:	55                   	push   %ebp
  80177d:	89 e5                	mov    %esp,%ebp
  80177f:	83 ec 04             	sub    $0x4,%esp
  801782:	8b 45 14             	mov    0x14(%ebp),%eax
  801785:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_testNum, n, v1, v2, c, inv);
  801788:	8b 55 18             	mov    0x18(%ebp),%edx
  80178b:	0f be 45 fc          	movsbl -0x4(%ebp),%eax
  80178f:	52                   	push   %edx
  801790:	50                   	push   %eax
  801791:	ff 75 10             	pushl  0x10(%ebp)
  801794:	ff 75 0c             	pushl  0xc(%ebp)
  801797:	ff 75 08             	pushl  0x8(%ebp)
  80179a:	6a 25                	push   $0x25
  80179c:	e8 6c fb ff ff       	call   80130d <syscall>
  8017a1:	83 c4 18             	add    $0x18,%esp
	return ;
  8017a4:	90                   	nop
}
  8017a5:	c9                   	leave  
  8017a6:	c3                   	ret    

008017a7 <chktst>:
void chktst(uint32 n)
{
  8017a7:	55                   	push   %ebp
  8017a8:	89 e5                	mov    %esp,%ebp
	syscall(SYS_chktst, n, 0, 0, 0, 0);
  8017aa:	6a 00                	push   $0x0
  8017ac:	6a 00                	push   $0x0
  8017ae:	6a 00                	push   $0x0
  8017b0:	6a 00                	push   $0x0
  8017b2:	ff 75 08             	pushl  0x8(%ebp)
  8017b5:	6a 27                	push   $0x27
  8017b7:	e8 51 fb ff ff       	call   80130d <syscall>
  8017bc:	83 c4 18             	add    $0x18,%esp
	return ;
  8017bf:	90                   	nop
}
  8017c0:	c9                   	leave  
  8017c1:	c3                   	ret    

008017c2 <inctst>:

void inctst()
{
  8017c2:	55                   	push   %ebp
  8017c3:	89 e5                	mov    %esp,%ebp
	syscall(SYS_inctst, 0, 0, 0, 0, 0);
  8017c5:	6a 00                	push   $0x0
  8017c7:	6a 00                	push   $0x0
  8017c9:	6a 00                	push   $0x0
  8017cb:	6a 00                	push   $0x0
  8017cd:	6a 00                	push   $0x0
  8017cf:	6a 28                	push   $0x28
  8017d1:	e8 37 fb ff ff       	call   80130d <syscall>
  8017d6:	83 c4 18             	add    $0x18,%esp
	return ;
  8017d9:	90                   	nop
}
  8017da:	c9                   	leave  
  8017db:	c3                   	ret    

008017dc <gettst>:
uint32 gettst()
{
  8017dc:	55                   	push   %ebp
  8017dd:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_gettst, 0, 0, 0, 0, 0);
  8017df:	6a 00                	push   $0x0
  8017e1:	6a 00                	push   $0x0
  8017e3:	6a 00                	push   $0x0
  8017e5:	6a 00                	push   $0x0
  8017e7:	6a 00                	push   $0x0
  8017e9:	6a 29                	push   $0x29
  8017eb:	e8 1d fb ff ff       	call   80130d <syscall>
  8017f0:	83 c4 18             	add    $0x18,%esp
}
  8017f3:	c9                   	leave  
  8017f4:	c3                   	ret    

008017f5 <sys_isUHeapPlacementStrategyFIRSTFIT>:


//2015
uint32 sys_isUHeapPlacementStrategyFIRSTFIT()
{
  8017f5:	55                   	push   %ebp
  8017f6:	89 e5                	mov    %esp,%ebp
  8017f8:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  8017fb:	6a 00                	push   $0x0
  8017fd:	6a 00                	push   $0x0
  8017ff:	6a 00                	push   $0x0
  801801:	6a 00                	push   $0x0
  801803:	6a 00                	push   $0x0
  801805:	6a 2a                	push   $0x2a
  801807:	e8 01 fb ff ff       	call   80130d <syscall>
  80180c:	83 c4 18             	add    $0x18,%esp
  80180f:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_FIRSTFIT)
  801812:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
  801816:	75 07                	jne    80181f <sys_isUHeapPlacementStrategyFIRSTFIT+0x2a>
		return 1;
  801818:	b8 01 00 00 00       	mov    $0x1,%eax
  80181d:	eb 05                	jmp    801824 <sys_isUHeapPlacementStrategyFIRSTFIT+0x2f>
	else
		return 0;
  80181f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801824:	c9                   	leave  
  801825:	c3                   	ret    

00801826 <sys_isUHeapPlacementStrategyBESTFIT>:
uint32 sys_isUHeapPlacementStrategyBESTFIT()
{
  801826:	55                   	push   %ebp
  801827:	89 e5                	mov    %esp,%ebp
  801829:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  80182c:	6a 00                	push   $0x0
  80182e:	6a 00                	push   $0x0
  801830:	6a 00                	push   $0x0
  801832:	6a 00                	push   $0x0
  801834:	6a 00                	push   $0x0
  801836:	6a 2a                	push   $0x2a
  801838:	e8 d0 fa ff ff       	call   80130d <syscall>
  80183d:	83 c4 18             	add    $0x18,%esp
  801840:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_BESTFIT)
  801843:	83 7d fc 02          	cmpl   $0x2,-0x4(%ebp)
  801847:	75 07                	jne    801850 <sys_isUHeapPlacementStrategyBESTFIT+0x2a>
		return 1;
  801849:	b8 01 00 00 00       	mov    $0x1,%eax
  80184e:	eb 05                	jmp    801855 <sys_isUHeapPlacementStrategyBESTFIT+0x2f>
	else
		return 0;
  801850:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801855:	c9                   	leave  
  801856:	c3                   	ret    

00801857 <sys_isUHeapPlacementStrategyNEXTFIT>:
uint32 sys_isUHeapPlacementStrategyNEXTFIT()
{
  801857:	55                   	push   %ebp
  801858:	89 e5                	mov    %esp,%ebp
  80185a:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  80185d:	6a 00                	push   $0x0
  80185f:	6a 00                	push   $0x0
  801861:	6a 00                	push   $0x0
  801863:	6a 00                	push   $0x0
  801865:	6a 00                	push   $0x0
  801867:	6a 2a                	push   $0x2a
  801869:	e8 9f fa ff ff       	call   80130d <syscall>
  80186e:	83 c4 18             	add    $0x18,%esp
  801871:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_NEXTFIT)
  801874:	83 7d fc 03          	cmpl   $0x3,-0x4(%ebp)
  801878:	75 07                	jne    801881 <sys_isUHeapPlacementStrategyNEXTFIT+0x2a>
		return 1;
  80187a:	b8 01 00 00 00       	mov    $0x1,%eax
  80187f:	eb 05                	jmp    801886 <sys_isUHeapPlacementStrategyNEXTFIT+0x2f>
	else
		return 0;
  801881:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801886:	c9                   	leave  
  801887:	c3                   	ret    

00801888 <sys_isUHeapPlacementStrategyWORSTFIT>:
uint32 sys_isUHeapPlacementStrategyWORSTFIT()
{
  801888:	55                   	push   %ebp
  801889:	89 e5                	mov    %esp,%ebp
  80188b:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  80188e:	6a 00                	push   $0x0
  801890:	6a 00                	push   $0x0
  801892:	6a 00                	push   $0x0
  801894:	6a 00                	push   $0x0
  801896:	6a 00                	push   $0x0
  801898:	6a 2a                	push   $0x2a
  80189a:	e8 6e fa ff ff       	call   80130d <syscall>
  80189f:	83 c4 18             	add    $0x18,%esp
  8018a2:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_WORSTFIT)
  8018a5:	83 7d fc 04          	cmpl   $0x4,-0x4(%ebp)
  8018a9:	75 07                	jne    8018b2 <sys_isUHeapPlacementStrategyWORSTFIT+0x2a>
		return 1;
  8018ab:	b8 01 00 00 00       	mov    $0x1,%eax
  8018b0:	eb 05                	jmp    8018b7 <sys_isUHeapPlacementStrategyWORSTFIT+0x2f>
	else
		return 0;
  8018b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018b7:	c9                   	leave  
  8018b8:	c3                   	ret    

008018b9 <sys_set_uheap_strategy>:

void sys_set_uheap_strategy(uint32 heapStrategy)
{
  8018b9:	55                   	push   %ebp
  8018ba:	89 e5                	mov    %esp,%ebp
	syscall(SYS_set_heap_strategy, heapStrategy, 0, 0, 0, 0);
  8018bc:	6a 00                	push   $0x0
  8018be:	6a 00                	push   $0x0
  8018c0:	6a 00                	push   $0x0
  8018c2:	6a 00                	push   $0x0
  8018c4:	ff 75 08             	pushl  0x8(%ebp)
  8018c7:	6a 2b                	push   $0x2b
  8018c9:	e8 3f fa ff ff       	call   80130d <syscall>
  8018ce:	83 c4 18             	add    $0x18,%esp
	return ;
  8018d1:	90                   	nop
}
  8018d2:	c9                   	leave  
  8018d3:	c3                   	ret    

008018d4 <sys_check_LRU_lists>:

//2020
int sys_check_LRU_lists(uint32* active_list_content, uint32* second_list_content, int actual_active_list_size, int actual_second_list_size)
{
  8018d4:	55                   	push   %ebp
  8018d5:	89 e5                	mov    %esp,%ebp
  8018d7:	53                   	push   %ebx
	return syscall(SYS_check_LRU_lists, (uint32)active_list_content, (uint32)second_list_content, (uint32)actual_active_list_size, (uint32)actual_second_list_size, 0);
  8018d8:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8018db:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8018de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e4:	6a 00                	push   $0x0
  8018e6:	53                   	push   %ebx
  8018e7:	51                   	push   %ecx
  8018e8:	52                   	push   %edx
  8018e9:	50                   	push   %eax
  8018ea:	6a 2c                	push   $0x2c
  8018ec:	e8 1c fa ff ff       	call   80130d <syscall>
  8018f1:	83 c4 18             	add    $0x18,%esp
}
  8018f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018f7:	c9                   	leave  
  8018f8:	c3                   	ret    

008018f9 <sys_check_LRU_lists_free>:

int sys_check_LRU_lists_free(uint32* list_content, int list_size)
{
  8018f9:	55                   	push   %ebp
  8018fa:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_check_LRU_lists_free, (uint32)list_content, (uint32)list_size , 0, 0, 0);
  8018fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801902:	6a 00                	push   $0x0
  801904:	6a 00                	push   $0x0
  801906:	6a 00                	push   $0x0
  801908:	52                   	push   %edx
  801909:	50                   	push   %eax
  80190a:	6a 2d                	push   $0x2d
  80190c:	e8 fc f9 ff ff       	call   80130d <syscall>
  801911:	83 c4 18             	add    $0x18,%esp
}
  801914:	c9                   	leave  
  801915:	c3                   	ret    

00801916 <sys_check_WS_list>:

int sys_check_WS_list(uint32* WS_list_content, int actual_WS_list_size, uint32 last_WS_element_content, bool chk_in_order)
{
  801916:	55                   	push   %ebp
  801917:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_check_WS_list, (uint32)WS_list_content, (uint32)actual_WS_list_size , last_WS_element_content, (uint32)chk_in_order, 0);
  801919:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80191c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80191f:	8b 45 08             	mov    0x8(%ebp),%eax
  801922:	6a 00                	push   $0x0
  801924:	51                   	push   %ecx
  801925:	ff 75 10             	pushl  0x10(%ebp)
  801928:	52                   	push   %edx
  801929:	50                   	push   %eax
  80192a:	6a 2e                	push   $0x2e
  80192c:	e8 dc f9 ff ff       	call   80130d <syscall>
  801931:	83 c4 18             	add    $0x18,%esp
}
  801934:	c9                   	leave  
  801935:	c3                   	ret    

00801936 <sys_allocate_chunk>:
void sys_allocate_chunk(uint32 virtual_address, uint32 size, uint32 perms)
{
  801936:	55                   	push   %ebp
  801937:	89 e5                	mov    %esp,%ebp
	syscall(SYS_allocate_chunk_in_mem, virtual_address, size, perms, 0, 0);
  801939:	6a 00                	push   $0x0
  80193b:	6a 00                	push   $0x0
  80193d:	ff 75 10             	pushl  0x10(%ebp)
  801940:	ff 75 0c             	pushl  0xc(%ebp)
  801943:	ff 75 08             	pushl  0x8(%ebp)
  801946:	6a 0f                	push   $0xf
  801948:	e8 c0 f9 ff ff       	call   80130d <syscall>
  80194d:	83 c4 18             	add    $0x18,%esp
	return ;
  801950:	90                   	nop
}
  801951:	c9                   	leave  
  801952:	c3                   	ret    

00801953 <sys_sbrk>:


/*2023*/
//TODO: [PROJECT'23.MS1 - #3] [2] SYSTEM CALLS - Implement these system calls
void* sys_sbrk(int increment)
{
  801953:	55                   	push   %ebp
  801954:	89 e5                	mov    %esp,%ebp
  801956:	83 ec 08             	sub    $0x8,%esp
	//Comment the following line before start coding...
	panic("not implemented yet");
  801959:	83 ec 04             	sub    $0x4,%esp
  80195c:	68 43 23 80 00       	push   $0x802343
  801961:	68 54 01 00 00       	push   $0x154
  801966:	68 57 23 80 00       	push   $0x802357
  80196b:	e8 da 00 00 00       	call   801a4a <_panic>

00801970 <sys_free_user_mem>:
	return NULL;
}

void sys_free_user_mem(uint32 virtual_address, uint32 size)
{
  801970:	55                   	push   %ebp
  801971:	89 e5                	mov    %esp,%ebp
  801973:	83 ec 08             	sub    $0x8,%esp
	//Comment the following line before start coding...
	panic("not implemented yet");
  801976:	83 ec 04             	sub    $0x4,%esp
  801979:	68 43 23 80 00       	push   $0x802343
  80197e:	68 5b 01 00 00       	push   $0x15b
  801983:	68 57 23 80 00       	push   $0x802357
  801988:	e8 bd 00 00 00       	call   801a4a <_panic>

0080198d <sys_allocate_user_mem>:
}

void sys_allocate_user_mem(uint32 virtual_address, uint32 size)
{
  80198d:	55                   	push   %ebp
  80198e:	89 e5                	mov    %esp,%ebp
  801990:	83 ec 08             	sub    $0x8,%esp
	//Comment the following line before start coding...
	panic("not implemented yet");
  801993:	83 ec 04             	sub    $0x4,%esp
  801996:	68 43 23 80 00       	push   $0x802343
  80199b:	68 61 01 00 00       	push   $0x161
  8019a0:	68 57 23 80 00       	push   $0x802357
  8019a5:	e8 a0 00 00 00       	call   801a4a <_panic>

008019aa <cputchar>:
#include <inc/lib.h>


void
cputchar(int ch)
{
  8019aa:	55                   	push   %ebp
  8019ab:	89 e5                	mov    %esp,%ebp
  8019ad:	83 ec 18             	sub    $0x18,%esp
	char c = ch;
  8019b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b3:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	//sys_cputs(&c, 1);

	sys_cputc(c);
  8019b6:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  8019ba:	83 ec 0c             	sub    $0xc,%esp
  8019bd:	50                   	push   %eax
  8019be:	e8 02 fb ff ff       	call   8014c5 <sys_cputc>
  8019c3:	83 c4 10             	add    $0x10,%esp
}
  8019c6:	90                   	nop
  8019c7:	c9                   	leave  
  8019c8:	c3                   	ret    

008019c9 <atomic_cputchar>:


void
atomic_cputchar(int ch)
{
  8019c9:	55                   	push   %ebp
  8019ca:	89 e5                	mov    %esp,%ebp
  8019cc:	83 ec 18             	sub    $0x18,%esp
	sys_disable_interrupt();
  8019cf:	e8 bd fa ff ff       	call   801491 <sys_disable_interrupt>
	char c = ch;
  8019d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	//sys_cputs(&c, 1);

	sys_cputc(c);
  8019da:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  8019de:	83 ec 0c             	sub    $0xc,%esp
  8019e1:	50                   	push   %eax
  8019e2:	e8 de fa ff ff       	call   8014c5 <sys_cputc>
  8019e7:	83 c4 10             	add    $0x10,%esp
	sys_enable_interrupt();
  8019ea:	e8 bc fa ff ff       	call   8014ab <sys_enable_interrupt>
}
  8019ef:	90                   	nop
  8019f0:	c9                   	leave  
  8019f1:	c3                   	ret    

008019f2 <getchar>:

int
getchar(void)
{
  8019f2:	55                   	push   %ebp
  8019f3:	89 e5                	mov    %esp,%ebp
  8019f5:	83 ec 18             	sub    $0x18,%esp

	//return sys_cgetc();
	int c=0;
  8019f8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	while(c == 0)
  8019ff:	eb 08                	jmp    801a09 <getchar+0x17>
	{
		c = sys_cgetc();
  801a01:	e8 5b f9 ff ff       	call   801361 <sys_cgetc>
  801a06:	89 45 f4             	mov    %eax,-0xc(%ebp)
getchar(void)
{

	//return sys_cgetc();
	int c=0;
	while(c == 0)
  801a09:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  801a0d:	74 f2                	je     801a01 <getchar+0xf>
	{
		c = sys_cgetc();
	}
	return c;
  801a0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  801a12:	c9                   	leave  
  801a13:	c3                   	ret    

00801a14 <atomic_getchar>:

int
atomic_getchar(void)
{
  801a14:	55                   	push   %ebp
  801a15:	89 e5                	mov    %esp,%ebp
  801a17:	83 ec 18             	sub    $0x18,%esp
	sys_disable_interrupt();
  801a1a:	e8 72 fa ff ff       	call   801491 <sys_disable_interrupt>
	int c=0;
  801a1f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	while(c == 0)
  801a26:	eb 08                	jmp    801a30 <atomic_getchar+0x1c>
	{
		c = sys_cgetc();
  801a28:	e8 34 f9 ff ff       	call   801361 <sys_cgetc>
  801a2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
int
atomic_getchar(void)
{
	sys_disable_interrupt();
	int c=0;
	while(c == 0)
  801a30:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  801a34:	74 f2                	je     801a28 <atomic_getchar+0x14>
	{
		c = sys_cgetc();
	}
	sys_enable_interrupt();
  801a36:	e8 70 fa ff ff       	call   8014ab <sys_enable_interrupt>
	return c;
  801a3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  801a3e:	c9                   	leave  
  801a3f:	c3                   	ret    

00801a40 <iscons>:

int iscons(int fdnum)
{
  801a40:	55                   	push   %ebp
  801a41:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
  801a43:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801a48:	5d                   	pop    %ebp
  801a49:	c3                   	ret    

00801a4a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes FOS to enter the FOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  801a4a:	55                   	push   %ebp
  801a4b:	89 e5                	mov    %esp,%ebp
  801a4d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	va_start(ap, fmt);
  801a50:	8d 45 10             	lea    0x10(%ebp),%eax
  801a53:	83 c0 04             	add    $0x4,%eax
  801a56:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// Print the panic message
	if (argv0)
  801a59:	a1 18 31 80 00       	mov    0x803118,%eax
  801a5e:	85 c0                	test   %eax,%eax
  801a60:	74 16                	je     801a78 <_panic+0x2e>
		cprintf("%s: ", argv0);
  801a62:	a1 18 31 80 00       	mov    0x803118,%eax
  801a67:	83 ec 08             	sub    $0x8,%esp
  801a6a:	50                   	push   %eax
  801a6b:	68 68 23 80 00       	push   $0x802368
  801a70:	e8 6f e8 ff ff       	call   8002e4 <cprintf>
  801a75:	83 c4 10             	add    $0x10,%esp
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  801a78:	a1 00 30 80 00       	mov    0x803000,%eax
  801a7d:	ff 75 0c             	pushl  0xc(%ebp)
  801a80:	ff 75 08             	pushl  0x8(%ebp)
  801a83:	50                   	push   %eax
  801a84:	68 6d 23 80 00       	push   $0x80236d
  801a89:	e8 56 e8 ff ff       	call   8002e4 <cprintf>
  801a8e:	83 c4 10             	add    $0x10,%esp
	vcprintf(fmt, ap);
  801a91:	8b 45 10             	mov    0x10(%ebp),%eax
  801a94:	83 ec 08             	sub    $0x8,%esp
  801a97:	ff 75 f4             	pushl  -0xc(%ebp)
  801a9a:	50                   	push   %eax
  801a9b:	e8 d9 e7 ff ff       	call   800279 <vcprintf>
  801aa0:	83 c4 10             	add    $0x10,%esp
	vcprintf("\n", NULL);
  801aa3:	83 ec 08             	sub    $0x8,%esp
  801aa6:	6a 00                	push   $0x0
  801aa8:	68 89 23 80 00       	push   $0x802389
  801aad:	e8 c7 e7 ff ff       	call   800279 <vcprintf>
  801ab2:	83 c4 10             	add    $0x10,%esp
	// Cause a breakpoint exception
//	while (1);
//		asm volatile("int3");

	//2013: exit the panic env only
	exit() ;
  801ab5:	e8 48 e7 ff ff       	call   800202 <exit>

	// should not return here
	while (1) ;
  801aba:	eb fe                	jmp    801aba <_panic+0x70>

00801abc <CheckWSArrayWithoutLastIndex>:
}

void CheckWSArrayWithoutLastIndex(uint32 *expectedPages, int arraySize)
{
  801abc:	55                   	push   %ebp
  801abd:	89 e5                	mov    %esp,%ebp
  801abf:	83 ec 28             	sub    $0x28,%esp
	if (arraySize != myEnv->page_WS_max_size)
  801ac2:	a1 20 30 80 00       	mov    0x803020,%eax
  801ac7:	8b 90 7c d5 01 00    	mov    0x1d57c(%eax),%edx
  801acd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ad0:	39 c2                	cmp    %eax,%edx
  801ad2:	74 14                	je     801ae8 <CheckWSArrayWithoutLastIndex+0x2c>
	{
		panic("number of expected pages SHOULD BE EQUAL to max WS size... review your TA!!");
  801ad4:	83 ec 04             	sub    $0x4,%esp
  801ad7:	68 8c 23 80 00       	push   $0x80238c
  801adc:	6a 26                	push   $0x26
  801ade:	68 d8 23 80 00       	push   $0x8023d8
  801ae3:	e8 62 ff ff ff       	call   801a4a <_panic>
	}
	int expectedNumOfEmptyLocs = 0;
  801ae8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	for (int e = 0; e < arraySize; e++) {
  801aef:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801af6:	e9 c5 00 00 00       	jmp    801bc0 <CheckWSArrayWithoutLastIndex+0x104>
		if (expectedPages[e] == 0) {
  801afb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801afe:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801b05:	8b 45 08             	mov    0x8(%ebp),%eax
  801b08:	01 d0                	add    %edx,%eax
  801b0a:	8b 00                	mov    (%eax),%eax
  801b0c:	85 c0                	test   %eax,%eax
  801b0e:	75 08                	jne    801b18 <CheckWSArrayWithoutLastIndex+0x5c>
			expectedNumOfEmptyLocs++;
  801b10:	ff 45 f4             	incl   -0xc(%ebp)
			continue;
  801b13:	e9 a5 00 00 00       	jmp    801bbd <CheckWSArrayWithoutLastIndex+0x101>
		}
		int found = 0;
  801b18:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  801b1f:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  801b26:	eb 69                	jmp    801b91 <CheckWSArrayWithoutLastIndex+0xd5>
			if (myEnv->__uptr_pws[w].empty == 0) {
  801b28:	a1 20 30 80 00       	mov    0x803020,%eax
  801b2d:	8b 88 6c da 01 00    	mov    0x1da6c(%eax),%ecx
  801b33:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801b36:	89 d0                	mov    %edx,%eax
  801b38:	01 c0                	add    %eax,%eax
  801b3a:	01 d0                	add    %edx,%eax
  801b3c:	c1 e0 03             	shl    $0x3,%eax
  801b3f:	01 c8                	add    %ecx,%eax
  801b41:	8a 40 04             	mov    0x4(%eax),%al
  801b44:	84 c0                	test   %al,%al
  801b46:	75 46                	jne    801b8e <CheckWSArrayWithoutLastIndex+0xd2>
				if (ROUNDDOWN(myEnv->__uptr_pws[w].virtual_address, PAGE_SIZE)
  801b48:	a1 20 30 80 00       	mov    0x803020,%eax
  801b4d:	8b 88 6c da 01 00    	mov    0x1da6c(%eax),%ecx
  801b53:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801b56:	89 d0                	mov    %edx,%eax
  801b58:	01 c0                	add    %eax,%eax
  801b5a:	01 d0                	add    %edx,%eax
  801b5c:	c1 e0 03             	shl    $0x3,%eax
  801b5f:	01 c8                	add    %ecx,%eax
  801b61:	8b 00                	mov    (%eax),%eax
  801b63:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801b66:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801b69:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801b6e:	89 c2                	mov    %eax,%edx
						== expectedPages[e]) {
  801b70:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b73:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801b7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7d:	01 c8                	add    %ecx,%eax
  801b7f:	8b 00                	mov    (%eax),%eax
			continue;
		}
		int found = 0;
		for (int w = 0; w < myEnv->page_WS_max_size; w++) {
			if (myEnv->__uptr_pws[w].empty == 0) {
				if (ROUNDDOWN(myEnv->__uptr_pws[w].virtual_address, PAGE_SIZE)
  801b81:	39 c2                	cmp    %eax,%edx
  801b83:	75 09                	jne    801b8e <CheckWSArrayWithoutLastIndex+0xd2>
						== expectedPages[e]) {
					found = 1;
  801b85:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
					break;
  801b8c:	eb 15                	jmp    801ba3 <CheckWSArrayWithoutLastIndex+0xe7>
		if (expectedPages[e] == 0) {
			expectedNumOfEmptyLocs++;
			continue;
		}
		int found = 0;
		for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  801b8e:	ff 45 e8             	incl   -0x18(%ebp)
  801b91:	a1 20 30 80 00       	mov    0x803020,%eax
  801b96:	8b 90 7c d5 01 00    	mov    0x1d57c(%eax),%edx
  801b9c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801b9f:	39 c2                	cmp    %eax,%edx
  801ba1:	77 85                	ja     801b28 <CheckWSArrayWithoutLastIndex+0x6c>
					found = 1;
					break;
				}
			}
		}
		if (!found)
  801ba3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801ba7:	75 14                	jne    801bbd <CheckWSArrayWithoutLastIndex+0x101>
			panic(
  801ba9:	83 ec 04             	sub    $0x4,%esp
  801bac:	68 e4 23 80 00       	push   $0x8023e4
  801bb1:	6a 3a                	push   $0x3a
  801bb3:	68 d8 23 80 00       	push   $0x8023d8
  801bb8:	e8 8d fe ff ff       	call   801a4a <_panic>
	if (arraySize != myEnv->page_WS_max_size)
	{
		panic("number of expected pages SHOULD BE EQUAL to max WS size... review your TA!!");
	}
	int expectedNumOfEmptyLocs = 0;
	for (int e = 0; e < arraySize; e++) {
  801bbd:	ff 45 f0             	incl   -0x10(%ebp)
  801bc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bc3:	3b 45 0c             	cmp    0xc(%ebp),%eax
  801bc6:	0f 8c 2f ff ff ff    	jl     801afb <CheckWSArrayWithoutLastIndex+0x3f>
		}
		if (!found)
			panic(
					"PAGE WS entry checking failed... trace it by printing page WS before & after fault");
	}
	int actualNumOfEmptyLocs = 0;
  801bcc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  801bd3:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  801bda:	eb 26                	jmp    801c02 <CheckWSArrayWithoutLastIndex+0x146>
		if (myEnv->__uptr_pws[w].empty == 1) {
  801bdc:	a1 20 30 80 00       	mov    0x803020,%eax
  801be1:	8b 88 6c da 01 00    	mov    0x1da6c(%eax),%ecx
  801be7:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801bea:	89 d0                	mov    %edx,%eax
  801bec:	01 c0                	add    %eax,%eax
  801bee:	01 d0                	add    %edx,%eax
  801bf0:	c1 e0 03             	shl    $0x3,%eax
  801bf3:	01 c8                	add    %ecx,%eax
  801bf5:	8a 40 04             	mov    0x4(%eax),%al
  801bf8:	3c 01                	cmp    $0x1,%al
  801bfa:	75 03                	jne    801bff <CheckWSArrayWithoutLastIndex+0x143>
			actualNumOfEmptyLocs++;
  801bfc:	ff 45 e4             	incl   -0x1c(%ebp)
		if (!found)
			panic(
					"PAGE WS entry checking failed... trace it by printing page WS before & after fault");
	}
	int actualNumOfEmptyLocs = 0;
	for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  801bff:	ff 45 e0             	incl   -0x20(%ebp)
  801c02:	a1 20 30 80 00       	mov    0x803020,%eax
  801c07:	8b 90 7c d5 01 00    	mov    0x1d57c(%eax),%edx
  801c0d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c10:	39 c2                	cmp    %eax,%edx
  801c12:	77 c8                	ja     801bdc <CheckWSArrayWithoutLastIndex+0x120>
		if (myEnv->__uptr_pws[w].empty == 1) {
			actualNumOfEmptyLocs++;
		}
	}
	if (expectedNumOfEmptyLocs != actualNumOfEmptyLocs)
  801c14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c17:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
  801c1a:	74 14                	je     801c30 <CheckWSArrayWithoutLastIndex+0x174>
		panic(
  801c1c:	83 ec 04             	sub    $0x4,%esp
  801c1f:	68 38 24 80 00       	push   $0x802438
  801c24:	6a 44                	push   $0x44
  801c26:	68 d8 23 80 00       	push   $0x8023d8
  801c2b:	e8 1a fe ff ff       	call   801a4a <_panic>
				"PAGE WS entry checking failed... number of empty locations is not correct");
}
  801c30:	90                   	nop
  801c31:	c9                   	leave  
  801c32:	c3                   	ret    
  801c33:	90                   	nop

00801c34 <__udivdi3>:
  801c34:	55                   	push   %ebp
  801c35:	57                   	push   %edi
  801c36:	56                   	push   %esi
  801c37:	53                   	push   %ebx
  801c38:	83 ec 1c             	sub    $0x1c,%esp
  801c3b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c3f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c47:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c4b:	89 ca                	mov    %ecx,%edx
  801c4d:	89 f8                	mov    %edi,%eax
  801c4f:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801c53:	85 f6                	test   %esi,%esi
  801c55:	75 2d                	jne    801c84 <__udivdi3+0x50>
  801c57:	39 cf                	cmp    %ecx,%edi
  801c59:	77 65                	ja     801cc0 <__udivdi3+0x8c>
  801c5b:	89 fd                	mov    %edi,%ebp
  801c5d:	85 ff                	test   %edi,%edi
  801c5f:	75 0b                	jne    801c6c <__udivdi3+0x38>
  801c61:	b8 01 00 00 00       	mov    $0x1,%eax
  801c66:	31 d2                	xor    %edx,%edx
  801c68:	f7 f7                	div    %edi
  801c6a:	89 c5                	mov    %eax,%ebp
  801c6c:	31 d2                	xor    %edx,%edx
  801c6e:	89 c8                	mov    %ecx,%eax
  801c70:	f7 f5                	div    %ebp
  801c72:	89 c1                	mov    %eax,%ecx
  801c74:	89 d8                	mov    %ebx,%eax
  801c76:	f7 f5                	div    %ebp
  801c78:	89 cf                	mov    %ecx,%edi
  801c7a:	89 fa                	mov    %edi,%edx
  801c7c:	83 c4 1c             	add    $0x1c,%esp
  801c7f:	5b                   	pop    %ebx
  801c80:	5e                   	pop    %esi
  801c81:	5f                   	pop    %edi
  801c82:	5d                   	pop    %ebp
  801c83:	c3                   	ret    
  801c84:	39 ce                	cmp    %ecx,%esi
  801c86:	77 28                	ja     801cb0 <__udivdi3+0x7c>
  801c88:	0f bd fe             	bsr    %esi,%edi
  801c8b:	83 f7 1f             	xor    $0x1f,%edi
  801c8e:	75 40                	jne    801cd0 <__udivdi3+0x9c>
  801c90:	39 ce                	cmp    %ecx,%esi
  801c92:	72 0a                	jb     801c9e <__udivdi3+0x6a>
  801c94:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c98:	0f 87 9e 00 00 00    	ja     801d3c <__udivdi3+0x108>
  801c9e:	b8 01 00 00 00       	mov    $0x1,%eax
  801ca3:	89 fa                	mov    %edi,%edx
  801ca5:	83 c4 1c             	add    $0x1c,%esp
  801ca8:	5b                   	pop    %ebx
  801ca9:	5e                   	pop    %esi
  801caa:	5f                   	pop    %edi
  801cab:	5d                   	pop    %ebp
  801cac:	c3                   	ret    
  801cad:	8d 76 00             	lea    0x0(%esi),%esi
  801cb0:	31 ff                	xor    %edi,%edi
  801cb2:	31 c0                	xor    %eax,%eax
  801cb4:	89 fa                	mov    %edi,%edx
  801cb6:	83 c4 1c             	add    $0x1c,%esp
  801cb9:	5b                   	pop    %ebx
  801cba:	5e                   	pop    %esi
  801cbb:	5f                   	pop    %edi
  801cbc:	5d                   	pop    %ebp
  801cbd:	c3                   	ret    
  801cbe:	66 90                	xchg   %ax,%ax
  801cc0:	89 d8                	mov    %ebx,%eax
  801cc2:	f7 f7                	div    %edi
  801cc4:	31 ff                	xor    %edi,%edi
  801cc6:	89 fa                	mov    %edi,%edx
  801cc8:	83 c4 1c             	add    $0x1c,%esp
  801ccb:	5b                   	pop    %ebx
  801ccc:	5e                   	pop    %esi
  801ccd:	5f                   	pop    %edi
  801cce:	5d                   	pop    %ebp
  801ccf:	c3                   	ret    
  801cd0:	bd 20 00 00 00       	mov    $0x20,%ebp
  801cd5:	89 eb                	mov    %ebp,%ebx
  801cd7:	29 fb                	sub    %edi,%ebx
  801cd9:	89 f9                	mov    %edi,%ecx
  801cdb:	d3 e6                	shl    %cl,%esi
  801cdd:	89 c5                	mov    %eax,%ebp
  801cdf:	88 d9                	mov    %bl,%cl
  801ce1:	d3 ed                	shr    %cl,%ebp
  801ce3:	89 e9                	mov    %ebp,%ecx
  801ce5:	09 f1                	or     %esi,%ecx
  801ce7:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801ceb:	89 f9                	mov    %edi,%ecx
  801ced:	d3 e0                	shl    %cl,%eax
  801cef:	89 c5                	mov    %eax,%ebp
  801cf1:	89 d6                	mov    %edx,%esi
  801cf3:	88 d9                	mov    %bl,%cl
  801cf5:	d3 ee                	shr    %cl,%esi
  801cf7:	89 f9                	mov    %edi,%ecx
  801cf9:	d3 e2                	shl    %cl,%edx
  801cfb:	8b 44 24 08          	mov    0x8(%esp),%eax
  801cff:	88 d9                	mov    %bl,%cl
  801d01:	d3 e8                	shr    %cl,%eax
  801d03:	09 c2                	or     %eax,%edx
  801d05:	89 d0                	mov    %edx,%eax
  801d07:	89 f2                	mov    %esi,%edx
  801d09:	f7 74 24 0c          	divl   0xc(%esp)
  801d0d:	89 d6                	mov    %edx,%esi
  801d0f:	89 c3                	mov    %eax,%ebx
  801d11:	f7 e5                	mul    %ebp
  801d13:	39 d6                	cmp    %edx,%esi
  801d15:	72 19                	jb     801d30 <__udivdi3+0xfc>
  801d17:	74 0b                	je     801d24 <__udivdi3+0xf0>
  801d19:	89 d8                	mov    %ebx,%eax
  801d1b:	31 ff                	xor    %edi,%edi
  801d1d:	e9 58 ff ff ff       	jmp    801c7a <__udivdi3+0x46>
  801d22:	66 90                	xchg   %ax,%ax
  801d24:	8b 54 24 08          	mov    0x8(%esp),%edx
  801d28:	89 f9                	mov    %edi,%ecx
  801d2a:	d3 e2                	shl    %cl,%edx
  801d2c:	39 c2                	cmp    %eax,%edx
  801d2e:	73 e9                	jae    801d19 <__udivdi3+0xe5>
  801d30:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801d33:	31 ff                	xor    %edi,%edi
  801d35:	e9 40 ff ff ff       	jmp    801c7a <__udivdi3+0x46>
  801d3a:	66 90                	xchg   %ax,%ax
  801d3c:	31 c0                	xor    %eax,%eax
  801d3e:	e9 37 ff ff ff       	jmp    801c7a <__udivdi3+0x46>
  801d43:	90                   	nop

00801d44 <__umoddi3>:
  801d44:	55                   	push   %ebp
  801d45:	57                   	push   %edi
  801d46:	56                   	push   %esi
  801d47:	53                   	push   %ebx
  801d48:	83 ec 1c             	sub    $0x1c,%esp
  801d4b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d4f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d57:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801d5b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d5f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d63:	89 f3                	mov    %esi,%ebx
  801d65:	89 fa                	mov    %edi,%edx
  801d67:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801d6b:	89 34 24             	mov    %esi,(%esp)
  801d6e:	85 c0                	test   %eax,%eax
  801d70:	75 1a                	jne    801d8c <__umoddi3+0x48>
  801d72:	39 f7                	cmp    %esi,%edi
  801d74:	0f 86 a2 00 00 00    	jbe    801e1c <__umoddi3+0xd8>
  801d7a:	89 c8                	mov    %ecx,%eax
  801d7c:	89 f2                	mov    %esi,%edx
  801d7e:	f7 f7                	div    %edi
  801d80:	89 d0                	mov    %edx,%eax
  801d82:	31 d2                	xor    %edx,%edx
  801d84:	83 c4 1c             	add    $0x1c,%esp
  801d87:	5b                   	pop    %ebx
  801d88:	5e                   	pop    %esi
  801d89:	5f                   	pop    %edi
  801d8a:	5d                   	pop    %ebp
  801d8b:	c3                   	ret    
  801d8c:	39 f0                	cmp    %esi,%eax
  801d8e:	0f 87 ac 00 00 00    	ja     801e40 <__umoddi3+0xfc>
  801d94:	0f bd e8             	bsr    %eax,%ebp
  801d97:	83 f5 1f             	xor    $0x1f,%ebp
  801d9a:	0f 84 ac 00 00 00    	je     801e4c <__umoddi3+0x108>
  801da0:	bf 20 00 00 00       	mov    $0x20,%edi
  801da5:	29 ef                	sub    %ebp,%edi
  801da7:	89 fe                	mov    %edi,%esi
  801da9:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801dad:	89 e9                	mov    %ebp,%ecx
  801daf:	d3 e0                	shl    %cl,%eax
  801db1:	89 d7                	mov    %edx,%edi
  801db3:	89 f1                	mov    %esi,%ecx
  801db5:	d3 ef                	shr    %cl,%edi
  801db7:	09 c7                	or     %eax,%edi
  801db9:	89 e9                	mov    %ebp,%ecx
  801dbb:	d3 e2                	shl    %cl,%edx
  801dbd:	89 14 24             	mov    %edx,(%esp)
  801dc0:	89 d8                	mov    %ebx,%eax
  801dc2:	d3 e0                	shl    %cl,%eax
  801dc4:	89 c2                	mov    %eax,%edx
  801dc6:	8b 44 24 08          	mov    0x8(%esp),%eax
  801dca:	d3 e0                	shl    %cl,%eax
  801dcc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dd0:	8b 44 24 08          	mov    0x8(%esp),%eax
  801dd4:	89 f1                	mov    %esi,%ecx
  801dd6:	d3 e8                	shr    %cl,%eax
  801dd8:	09 d0                	or     %edx,%eax
  801dda:	d3 eb                	shr    %cl,%ebx
  801ddc:	89 da                	mov    %ebx,%edx
  801dde:	f7 f7                	div    %edi
  801de0:	89 d3                	mov    %edx,%ebx
  801de2:	f7 24 24             	mull   (%esp)
  801de5:	89 c6                	mov    %eax,%esi
  801de7:	89 d1                	mov    %edx,%ecx
  801de9:	39 d3                	cmp    %edx,%ebx
  801deb:	0f 82 87 00 00 00    	jb     801e78 <__umoddi3+0x134>
  801df1:	0f 84 91 00 00 00    	je     801e88 <__umoddi3+0x144>
  801df7:	8b 54 24 04          	mov    0x4(%esp),%edx
  801dfb:	29 f2                	sub    %esi,%edx
  801dfd:	19 cb                	sbb    %ecx,%ebx
  801dff:	89 d8                	mov    %ebx,%eax
  801e01:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  801e05:	d3 e0                	shl    %cl,%eax
  801e07:	89 e9                	mov    %ebp,%ecx
  801e09:	d3 ea                	shr    %cl,%edx
  801e0b:	09 d0                	or     %edx,%eax
  801e0d:	89 e9                	mov    %ebp,%ecx
  801e0f:	d3 eb                	shr    %cl,%ebx
  801e11:	89 da                	mov    %ebx,%edx
  801e13:	83 c4 1c             	add    $0x1c,%esp
  801e16:	5b                   	pop    %ebx
  801e17:	5e                   	pop    %esi
  801e18:	5f                   	pop    %edi
  801e19:	5d                   	pop    %ebp
  801e1a:	c3                   	ret    
  801e1b:	90                   	nop
  801e1c:	89 fd                	mov    %edi,%ebp
  801e1e:	85 ff                	test   %edi,%edi
  801e20:	75 0b                	jne    801e2d <__umoddi3+0xe9>
  801e22:	b8 01 00 00 00       	mov    $0x1,%eax
  801e27:	31 d2                	xor    %edx,%edx
  801e29:	f7 f7                	div    %edi
  801e2b:	89 c5                	mov    %eax,%ebp
  801e2d:	89 f0                	mov    %esi,%eax
  801e2f:	31 d2                	xor    %edx,%edx
  801e31:	f7 f5                	div    %ebp
  801e33:	89 c8                	mov    %ecx,%eax
  801e35:	f7 f5                	div    %ebp
  801e37:	89 d0                	mov    %edx,%eax
  801e39:	e9 44 ff ff ff       	jmp    801d82 <__umoddi3+0x3e>
  801e3e:	66 90                	xchg   %ax,%ax
  801e40:	89 c8                	mov    %ecx,%eax
  801e42:	89 f2                	mov    %esi,%edx
  801e44:	83 c4 1c             	add    $0x1c,%esp
  801e47:	5b                   	pop    %ebx
  801e48:	5e                   	pop    %esi
  801e49:	5f                   	pop    %edi
  801e4a:	5d                   	pop    %ebp
  801e4b:	c3                   	ret    
  801e4c:	3b 04 24             	cmp    (%esp),%eax
  801e4f:	72 06                	jb     801e57 <__umoddi3+0x113>
  801e51:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  801e55:	77 0f                	ja     801e66 <__umoddi3+0x122>
  801e57:	89 f2                	mov    %esi,%edx
  801e59:	29 f9                	sub    %edi,%ecx
  801e5b:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  801e5f:	89 14 24             	mov    %edx,(%esp)
  801e62:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801e66:	8b 44 24 04          	mov    0x4(%esp),%eax
  801e6a:	8b 14 24             	mov    (%esp),%edx
  801e6d:	83 c4 1c             	add    $0x1c,%esp
  801e70:	5b                   	pop    %ebx
  801e71:	5e                   	pop    %esi
  801e72:	5f                   	pop    %edi
  801e73:	5d                   	pop    %ebp
  801e74:	c3                   	ret    
  801e75:	8d 76 00             	lea    0x0(%esi),%esi
  801e78:	2b 04 24             	sub    (%esp),%eax
  801e7b:	19 fa                	sbb    %edi,%edx
  801e7d:	89 d1                	mov    %edx,%ecx
  801e7f:	89 c6                	mov    %eax,%esi
  801e81:	e9 71 ff ff ff       	jmp    801df7 <__umoddi3+0xb3>
  801e86:	66 90                	xchg   %ax,%ax
  801e88:	39 44 24 04          	cmp    %eax,0x4(%esp)
  801e8c:	72 ea                	jb     801e78 <__umoddi3+0x134>
  801e8e:	89 d9                	mov    %ebx,%ecx
  801e90:	e9 62 ff ff ff       	jmp    801df7 <__umoddi3+0xb3>
