
obj/user/fos_static_data_section:     file format elf32-i386


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
  800031:	e8 1b 00 00 00       	call   800051 <libmain>
1:      jmp 1b
  800036:	eb fe                	jmp    800036 <args_exist+0x5>

00800038 <_main>:

/// Adding array of 20000 integer on user data section
int arr[20000];

void _main(void)
{	
  800038:	55                   	push   %ebp
  800039:	89 e5                	mov    %esp,%ebp
  80003b:	83 ec 08             	sub    $0x8,%esp
	atomic_cprintf("user data section contains 20,000 integer\n");
  80003e:	83 ec 0c             	sub    $0xc,%esp
  800041:	68 80 1b 80 00       	push   $0x801b80
  800046:	e8 4c 02 00 00       	call   800297 <atomic_cprintf>
  80004b:	83 c4 10             	add    $0x10,%esp
	
	return;	
  80004e:	90                   	nop
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    

00800051 <libmain>:
volatile struct Env *myEnv = NULL;
volatile char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800051:	55                   	push   %ebp
  800052:	89 e5                	mov    %esp,%ebp
  800054:	83 ec 18             	sub    $0x18,%esp
	int envIndex = sys_getenvindex();
  800057:	e8 a8 13 00 00       	call   801404 <sys_getenvindex>
  80005c:	89 45 f4             	mov    %eax,-0xc(%ebp)
	myEnv = &(envs[envIndex]);
  80005f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800062:	89 d0                	mov    %edx,%eax
  800064:	01 c0                	add    %eax,%eax
  800066:	01 d0                	add    %edx,%eax
  800068:	01 c0                	add    %eax,%eax
  80006a:	01 d0                	add    %edx,%eax
  80006c:	c1 e0 02             	shl    $0x2,%eax
  80006f:	01 d0                	add    %edx,%eax
  800071:	01 c0                	add    %eax,%eax
  800073:	01 d0                	add    %edx,%eax
  800075:	c1 e0 02             	shl    $0x2,%eax
  800078:	01 d0                	add    %edx,%eax
  80007a:	c1 e0 02             	shl    $0x2,%eax
  80007d:	01 d0                	add    %edx,%eax
  80007f:	c1 e0 02             	shl    $0x2,%eax
  800082:	01 d0                	add    %edx,%eax
  800084:	c1 e0 05             	shl    $0x5,%eax
  800087:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008c:	a3 20 30 80 00       	mov    %eax,0x803020

	//SET THE PROGRAM NAME
	if (myEnv->prog_name[0] != '\0')
  800091:	a1 20 30 80 00       	mov    0x803020,%eax
  800096:	8a 40 5c             	mov    0x5c(%eax),%al
  800099:	84 c0                	test   %al,%al
  80009b:	74 0d                	je     8000aa <libmain+0x59>
		binaryname = myEnv->prog_name;
  80009d:	a1 20 30 80 00       	mov    0x803020,%eax
  8000a2:	83 c0 5c             	add    $0x5c,%eax
  8000a5:	a3 00 30 80 00       	mov    %eax,0x803000

	// set env to point at our env structure in envs[].
	// env = envs;

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000aa:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000ae:	7e 0a                	jle    8000ba <libmain+0x69>
		binaryname = argv[0];
  8000b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000b3:	8b 00                	mov    (%eax),%eax
  8000b5:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	_main(argc, argv);
  8000ba:	83 ec 08             	sub    $0x8,%esp
  8000bd:	ff 75 0c             	pushl  0xc(%ebp)
  8000c0:	ff 75 08             	pushl  0x8(%ebp)
  8000c3:	e8 70 ff ff ff       	call   800038 <_main>
  8000c8:	83 c4 10             	add    $0x10,%esp



	sys_disable_interrupt();
  8000cb:	e8 41 11 00 00       	call   801211 <sys_disable_interrupt>
	cprintf("**************************************\n");
  8000d0:	83 ec 0c             	sub    $0xc,%esp
  8000d3:	68 c4 1b 80 00       	push   $0x801bc4
  8000d8:	e8 8d 01 00 00       	call   80026a <cprintf>
  8000dd:	83 c4 10             	add    $0x10,%esp
	cprintf("Num of PAGE faults = %d, modif = %d\n", myEnv->pageFaultsCounter, myEnv->nModifiedPages);
  8000e0:	a1 20 30 80 00       	mov    0x803020,%eax
  8000e5:	8b 90 84 da 01 00    	mov    0x1da84(%eax),%edx
  8000eb:	a1 20 30 80 00       	mov    0x803020,%eax
  8000f0:	8b 80 74 da 01 00    	mov    0x1da74(%eax),%eax
  8000f6:	83 ec 04             	sub    $0x4,%esp
  8000f9:	52                   	push   %edx
  8000fa:	50                   	push   %eax
  8000fb:	68 ec 1b 80 00       	push   $0x801bec
  800100:	e8 65 01 00 00       	call   80026a <cprintf>
  800105:	83 c4 10             	add    $0x10,%esp
	cprintf("# PAGE IN (from disk) = %d, # PAGE OUT (on disk) = %d, # NEW PAGE ADDED (on disk) = %d\n", myEnv->nPageIn, myEnv->nPageOut,myEnv->nNewPageAdded);
  800108:	a1 20 30 80 00       	mov    0x803020,%eax
  80010d:	8b 88 98 da 01 00    	mov    0x1da98(%eax),%ecx
  800113:	a1 20 30 80 00       	mov    0x803020,%eax
  800118:	8b 90 94 da 01 00    	mov    0x1da94(%eax),%edx
  80011e:	a1 20 30 80 00       	mov    0x803020,%eax
  800123:	8b 80 90 da 01 00    	mov    0x1da90(%eax),%eax
  800129:	51                   	push   %ecx
  80012a:	52                   	push   %edx
  80012b:	50                   	push   %eax
  80012c:	68 14 1c 80 00       	push   $0x801c14
  800131:	e8 34 01 00 00       	call   80026a <cprintf>
  800136:	83 c4 10             	add    $0x10,%esp
	//cprintf("Num of freeing scarce memory = %d, freeing full working set = %d\n", myEnv->freeingScarceMemCounter, myEnv->freeingFullWSCounter);
	cprintf("Num of clocks = %d\n", myEnv->nClocks);
  800139:	a1 20 30 80 00       	mov    0x803020,%eax
  80013e:	8b 80 9c da 01 00    	mov    0x1da9c(%eax),%eax
  800144:	83 ec 08             	sub    $0x8,%esp
  800147:	50                   	push   %eax
  800148:	68 6c 1c 80 00       	push   $0x801c6c
  80014d:	e8 18 01 00 00       	call   80026a <cprintf>
  800152:	83 c4 10             	add    $0x10,%esp
	cprintf("**************************************\n");
  800155:	83 ec 0c             	sub    $0xc,%esp
  800158:	68 c4 1b 80 00       	push   $0x801bc4
  80015d:	e8 08 01 00 00       	call   80026a <cprintf>
  800162:	83 c4 10             	add    $0x10,%esp
	sys_enable_interrupt();
  800165:	e8 c1 10 00 00       	call   80122b <sys_enable_interrupt>

	// exit gracefully
	exit();
  80016a:	e8 19 00 00 00       	call   800188 <exit>
}
  80016f:	90                   	nop
  800170:	c9                   	leave  
  800171:	c3                   	ret    

00800172 <destroy>:

#include <inc/lib.h>

void
destroy(void)
{
  800172:	55                   	push   %ebp
  800173:	89 e5                	mov    %esp,%ebp
  800175:	83 ec 08             	sub    $0x8,%esp
	sys_destroy_env(0);
  800178:	83 ec 0c             	sub    $0xc,%esp
  80017b:	6a 00                	push   $0x0
  80017d:	e8 4e 12 00 00       	call   8013d0 <sys_destroy_env>
  800182:	83 c4 10             	add    $0x10,%esp
}
  800185:	90                   	nop
  800186:	c9                   	leave  
  800187:	c3                   	ret    

00800188 <exit>:

void
exit(void)
{
  800188:	55                   	push   %ebp
  800189:	89 e5                	mov    %esp,%ebp
  80018b:	83 ec 08             	sub    $0x8,%esp
	sys_exit_env();
  80018e:	e8 a3 12 00 00       	call   801436 <sys_exit_env>
}
  800193:	90                   	nop
  800194:	c9                   	leave  
  800195:	c3                   	ret    

00800196 <putch>:
};

//2017:
uint8 printProgName = 0;

static void putch(int ch, struct printbuf *b) {
  800196:	55                   	push   %ebp
  800197:	89 e5                	mov    %esp,%ebp
  800199:	83 ec 08             	sub    $0x8,%esp
	b->buf[b->idx++] = ch;
  80019c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80019f:	8b 00                	mov    (%eax),%eax
  8001a1:	8d 48 01             	lea    0x1(%eax),%ecx
  8001a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001a7:	89 0a                	mov    %ecx,(%edx)
  8001a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ac:	88 d1                	mov    %dl,%cl
  8001ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b1:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256 - 1) {
  8001b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001b8:	8b 00                	mov    (%eax),%eax
  8001ba:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001bf:	75 2c                	jne    8001ed <putch+0x57>
		sys_cputs(b->buf, b->idx, printProgName);
  8001c1:	a0 24 30 80 00       	mov    0x803024,%al
  8001c6:	0f b6 c0             	movzbl %al,%eax
  8001c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001cc:	8b 12                	mov    (%edx),%edx
  8001ce:	89 d1                	mov    %edx,%ecx
  8001d0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d3:	83 c2 08             	add    $0x8,%edx
  8001d6:	83 ec 04             	sub    $0x4,%esp
  8001d9:	50                   	push   %eax
  8001da:	51                   	push   %ecx
  8001db:	52                   	push   %edx
  8001dc:	e8 d7 0e 00 00       	call   8010b8 <sys_cputs>
  8001e1:	83 c4 10             	add    $0x10,%esp
		b->idx = 0;
  8001e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001e7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  8001ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001f0:	8b 40 04             	mov    0x4(%eax),%eax
  8001f3:	8d 50 01             	lea    0x1(%eax),%edx
  8001f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001f9:	89 50 04             	mov    %edx,0x4(%eax)
}
  8001fc:	90                   	nop
  8001fd:	c9                   	leave  
  8001fe:	c3                   	ret    

008001ff <vcprintf>:

int vcprintf(const char *fmt, va_list ap) {
  8001ff:	55                   	push   %ebp
  800200:	89 e5                	mov    %esp,%ebp
  800202:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800208:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80020f:	00 00 00 
	b.cnt = 0;
  800212:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800219:	00 00 00 
	vprintfmt((void*) putch, &b, fmt, ap);
  80021c:	ff 75 0c             	pushl  0xc(%ebp)
  80021f:	ff 75 08             	pushl  0x8(%ebp)
  800222:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800228:	50                   	push   %eax
  800229:	68 96 01 80 00       	push   $0x800196
  80022e:	e8 11 02 00 00       	call   800444 <vprintfmt>
  800233:	83 c4 10             	add    $0x10,%esp
	sys_cputs(b.buf, b.idx, printProgName);
  800236:	a0 24 30 80 00       	mov    0x803024,%al
  80023b:	0f b6 c0             	movzbl %al,%eax
  80023e:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
  800244:	83 ec 04             	sub    $0x4,%esp
  800247:	50                   	push   %eax
  800248:	52                   	push   %edx
  800249:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80024f:	83 c0 08             	add    $0x8,%eax
  800252:	50                   	push   %eax
  800253:	e8 60 0e 00 00       	call   8010b8 <sys_cputs>
  800258:	83 c4 10             	add    $0x10,%esp

	printProgName = 0;
  80025b:	c6 05 24 30 80 00 00 	movb   $0x0,0x803024
	return b.cnt;
  800262:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  800268:	c9                   	leave  
  800269:	c3                   	ret    

0080026a <cprintf>:

int cprintf(const char *fmt, ...) {
  80026a:	55                   	push   %ebp
  80026b:	89 e5                	mov    %esp,%ebp
  80026d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;
	printProgName = 1 ;
  800270:	c6 05 24 30 80 00 01 	movb   $0x1,0x803024
	va_start(ap, fmt);
  800277:	8d 45 0c             	lea    0xc(%ebp),%eax
  80027a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cnt = vcprintf(fmt, ap);
  80027d:	8b 45 08             	mov    0x8(%ebp),%eax
  800280:	83 ec 08             	sub    $0x8,%esp
  800283:	ff 75 f4             	pushl  -0xc(%ebp)
  800286:	50                   	push   %eax
  800287:	e8 73 ff ff ff       	call   8001ff <vcprintf>
  80028c:	83 c4 10             	add    $0x10,%esp
  80028f:	89 45 f0             	mov    %eax,-0x10(%ebp)
	va_end(ap);

	return cnt;
  800292:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  800295:	c9                   	leave  
  800296:	c3                   	ret    

00800297 <atomic_cprintf>:

int atomic_cprintf(const char *fmt, ...) {
  800297:	55                   	push   %ebp
  800298:	89 e5                	mov    %esp,%ebp
  80029a:	83 ec 18             	sub    $0x18,%esp
	sys_disable_interrupt();
  80029d:	e8 6f 0f 00 00       	call   801211 <sys_disable_interrupt>
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002a2:	8d 45 0c             	lea    0xc(%ebp),%eax
  8002a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cnt = vcprintf(fmt, ap);
  8002a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ab:	83 ec 08             	sub    $0x8,%esp
  8002ae:	ff 75 f4             	pushl  -0xc(%ebp)
  8002b1:	50                   	push   %eax
  8002b2:	e8 48 ff ff ff       	call   8001ff <vcprintf>
  8002b7:	83 c4 10             	add    $0x10,%esp
  8002ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
	va_end(ap);

	sys_enable_interrupt();
  8002bd:	e8 69 0f 00 00       	call   80122b <sys_enable_interrupt>
	return cnt;
  8002c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  8002c5:	c9                   	leave  
  8002c6:	c3                   	ret    

008002c7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002c7:	55                   	push   %ebp
  8002c8:	89 e5                	mov    %esp,%ebp
  8002ca:	53                   	push   %ebx
  8002cb:	83 ec 14             	sub    $0x14,%esp
  8002ce:	8b 45 10             	mov    0x10(%ebp),%eax
  8002d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8002d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8002d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002da:	8b 45 18             	mov    0x18(%ebp),%eax
  8002dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e2:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8002e5:	77 55                	ja     80033c <printnum+0x75>
  8002e7:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8002ea:	72 05                	jb     8002f1 <printnum+0x2a>
  8002ec:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8002ef:	77 4b                	ja     80033c <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f1:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8002f4:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002f7:	8b 45 18             	mov    0x18(%ebp),%eax
  8002fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ff:	52                   	push   %edx
  800300:	50                   	push   %eax
  800301:	ff 75 f4             	pushl  -0xc(%ebp)
  800304:	ff 75 f0             	pushl  -0x10(%ebp)
  800307:	e8 08 16 00 00       	call   801914 <__udivdi3>
  80030c:	83 c4 10             	add    $0x10,%esp
  80030f:	83 ec 04             	sub    $0x4,%esp
  800312:	ff 75 20             	pushl  0x20(%ebp)
  800315:	53                   	push   %ebx
  800316:	ff 75 18             	pushl  0x18(%ebp)
  800319:	52                   	push   %edx
  80031a:	50                   	push   %eax
  80031b:	ff 75 0c             	pushl  0xc(%ebp)
  80031e:	ff 75 08             	pushl  0x8(%ebp)
  800321:	e8 a1 ff ff ff       	call   8002c7 <printnum>
  800326:	83 c4 20             	add    $0x20,%esp
  800329:	eb 1a                	jmp    800345 <printnum+0x7e>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80032b:	83 ec 08             	sub    $0x8,%esp
  80032e:	ff 75 0c             	pushl  0xc(%ebp)
  800331:	ff 75 20             	pushl  0x20(%ebp)
  800334:	8b 45 08             	mov    0x8(%ebp),%eax
  800337:	ff d0                	call   *%eax
  800339:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80033c:	ff 4d 1c             	decl   0x1c(%ebp)
  80033f:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800343:	7f e6                	jg     80032b <printnum+0x64>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800345:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800348:	bb 00 00 00 00       	mov    $0x0,%ebx
  80034d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800350:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800353:	53                   	push   %ebx
  800354:	51                   	push   %ecx
  800355:	52                   	push   %edx
  800356:	50                   	push   %eax
  800357:	e8 c8 16 00 00       	call   801a24 <__umoddi3>
  80035c:	83 c4 10             	add    $0x10,%esp
  80035f:	05 94 1e 80 00       	add    $0x801e94,%eax
  800364:	8a 00                	mov    (%eax),%al
  800366:	0f be c0             	movsbl %al,%eax
  800369:	83 ec 08             	sub    $0x8,%esp
  80036c:	ff 75 0c             	pushl  0xc(%ebp)
  80036f:	50                   	push   %eax
  800370:	8b 45 08             	mov    0x8(%ebp),%eax
  800373:	ff d0                	call   *%eax
  800375:	83 c4 10             	add    $0x10,%esp
}
  800378:	90                   	nop
  800379:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80037c:	c9                   	leave  
  80037d:	c3                   	ret    

0080037e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80037e:	55                   	push   %ebp
  80037f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800381:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800385:	7e 1c                	jle    8003a3 <getuint+0x25>
		return va_arg(*ap, unsigned long long);
  800387:	8b 45 08             	mov    0x8(%ebp),%eax
  80038a:	8b 00                	mov    (%eax),%eax
  80038c:	8d 50 08             	lea    0x8(%eax),%edx
  80038f:	8b 45 08             	mov    0x8(%ebp),%eax
  800392:	89 10                	mov    %edx,(%eax)
  800394:	8b 45 08             	mov    0x8(%ebp),%eax
  800397:	8b 00                	mov    (%eax),%eax
  800399:	83 e8 08             	sub    $0x8,%eax
  80039c:	8b 50 04             	mov    0x4(%eax),%edx
  80039f:	8b 00                	mov    (%eax),%eax
  8003a1:	eb 40                	jmp    8003e3 <getuint+0x65>
	else if (lflag)
  8003a3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8003a7:	74 1e                	je     8003c7 <getuint+0x49>
		return va_arg(*ap, unsigned long);
  8003a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ac:	8b 00                	mov    (%eax),%eax
  8003ae:	8d 50 04             	lea    0x4(%eax),%edx
  8003b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b4:	89 10                	mov    %edx,(%eax)
  8003b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b9:	8b 00                	mov    (%eax),%eax
  8003bb:	83 e8 04             	sub    $0x4,%eax
  8003be:	8b 00                	mov    (%eax),%eax
  8003c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8003c5:	eb 1c                	jmp    8003e3 <getuint+0x65>
	else
		return va_arg(*ap, unsigned int);
  8003c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ca:	8b 00                	mov    (%eax),%eax
  8003cc:	8d 50 04             	lea    0x4(%eax),%edx
  8003cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d2:	89 10                	mov    %edx,(%eax)
  8003d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d7:	8b 00                	mov    (%eax),%eax
  8003d9:	83 e8 04             	sub    $0x4,%eax
  8003dc:	8b 00                	mov    (%eax),%eax
  8003de:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003e3:	5d                   	pop    %ebp
  8003e4:	c3                   	ret    

008003e5 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8003e5:	55                   	push   %ebp
  8003e6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003e8:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8003ec:	7e 1c                	jle    80040a <getint+0x25>
		return va_arg(*ap, long long);
  8003ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f1:	8b 00                	mov    (%eax),%eax
  8003f3:	8d 50 08             	lea    0x8(%eax),%edx
  8003f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f9:	89 10                	mov    %edx,(%eax)
  8003fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fe:	8b 00                	mov    (%eax),%eax
  800400:	83 e8 08             	sub    $0x8,%eax
  800403:	8b 50 04             	mov    0x4(%eax),%edx
  800406:	8b 00                	mov    (%eax),%eax
  800408:	eb 38                	jmp    800442 <getint+0x5d>
	else if (lflag)
  80040a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80040e:	74 1a                	je     80042a <getint+0x45>
		return va_arg(*ap, long);
  800410:	8b 45 08             	mov    0x8(%ebp),%eax
  800413:	8b 00                	mov    (%eax),%eax
  800415:	8d 50 04             	lea    0x4(%eax),%edx
  800418:	8b 45 08             	mov    0x8(%ebp),%eax
  80041b:	89 10                	mov    %edx,(%eax)
  80041d:	8b 45 08             	mov    0x8(%ebp),%eax
  800420:	8b 00                	mov    (%eax),%eax
  800422:	83 e8 04             	sub    $0x4,%eax
  800425:	8b 00                	mov    (%eax),%eax
  800427:	99                   	cltd   
  800428:	eb 18                	jmp    800442 <getint+0x5d>
	else
		return va_arg(*ap, int);
  80042a:	8b 45 08             	mov    0x8(%ebp),%eax
  80042d:	8b 00                	mov    (%eax),%eax
  80042f:	8d 50 04             	lea    0x4(%eax),%edx
  800432:	8b 45 08             	mov    0x8(%ebp),%eax
  800435:	89 10                	mov    %edx,(%eax)
  800437:	8b 45 08             	mov    0x8(%ebp),%eax
  80043a:	8b 00                	mov    (%eax),%eax
  80043c:	83 e8 04             	sub    $0x4,%eax
  80043f:	8b 00                	mov    (%eax),%eax
  800441:	99                   	cltd   
}
  800442:	5d                   	pop    %ebp
  800443:	c3                   	ret    

00800444 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800444:	55                   	push   %ebp
  800445:	89 e5                	mov    %esp,%ebp
  800447:	56                   	push   %esi
  800448:	53                   	push   %ebx
  800449:	83 ec 20             	sub    $0x20,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80044c:	eb 17                	jmp    800465 <vprintfmt+0x21>
			if (ch == '\0')
  80044e:	85 db                	test   %ebx,%ebx
  800450:	0f 84 af 03 00 00    	je     800805 <vprintfmt+0x3c1>
				return;
			putch(ch, putdat);
  800456:	83 ec 08             	sub    $0x8,%esp
  800459:	ff 75 0c             	pushl  0xc(%ebp)
  80045c:	53                   	push   %ebx
  80045d:	8b 45 08             	mov    0x8(%ebp),%eax
  800460:	ff d0                	call   *%eax
  800462:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800465:	8b 45 10             	mov    0x10(%ebp),%eax
  800468:	8d 50 01             	lea    0x1(%eax),%edx
  80046b:	89 55 10             	mov    %edx,0x10(%ebp)
  80046e:	8a 00                	mov    (%eax),%al
  800470:	0f b6 d8             	movzbl %al,%ebx
  800473:	83 fb 25             	cmp    $0x25,%ebx
  800476:	75 d6                	jne    80044e <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800478:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  80047c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800483:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80048a:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  800491:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800498:	8b 45 10             	mov    0x10(%ebp),%eax
  80049b:	8d 50 01             	lea    0x1(%eax),%edx
  80049e:	89 55 10             	mov    %edx,0x10(%ebp)
  8004a1:	8a 00                	mov    (%eax),%al
  8004a3:	0f b6 d8             	movzbl %al,%ebx
  8004a6:	8d 43 dd             	lea    -0x23(%ebx),%eax
  8004a9:	83 f8 55             	cmp    $0x55,%eax
  8004ac:	0f 87 2b 03 00 00    	ja     8007dd <vprintfmt+0x399>
  8004b2:	8b 04 85 b8 1e 80 00 	mov    0x801eb8(,%eax,4),%eax
  8004b9:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  8004bb:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  8004bf:	eb d7                	jmp    800498 <vprintfmt+0x54>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004c1:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  8004c5:	eb d1                	jmp    800498 <vprintfmt+0x54>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004c7:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8004ce:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004d1:	89 d0                	mov    %edx,%eax
  8004d3:	c1 e0 02             	shl    $0x2,%eax
  8004d6:	01 d0                	add    %edx,%eax
  8004d8:	01 c0                	add    %eax,%eax
  8004da:	01 d8                	add    %ebx,%eax
  8004dc:	83 e8 30             	sub    $0x30,%eax
  8004df:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8004e2:	8b 45 10             	mov    0x10(%ebp),%eax
  8004e5:	8a 00                	mov    (%eax),%al
  8004e7:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8004ea:	83 fb 2f             	cmp    $0x2f,%ebx
  8004ed:	7e 3e                	jle    80052d <vprintfmt+0xe9>
  8004ef:	83 fb 39             	cmp    $0x39,%ebx
  8004f2:	7f 39                	jg     80052d <vprintfmt+0xe9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004f4:	ff 45 10             	incl   0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004f7:	eb d5                	jmp    8004ce <vprintfmt+0x8a>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fc:	83 c0 04             	add    $0x4,%eax
  8004ff:	89 45 14             	mov    %eax,0x14(%ebp)
  800502:	8b 45 14             	mov    0x14(%ebp),%eax
  800505:	83 e8 04             	sub    $0x4,%eax
  800508:	8b 00                	mov    (%eax),%eax
  80050a:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  80050d:	eb 1f                	jmp    80052e <vprintfmt+0xea>

		case '.':
			if (width < 0)
  80050f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800513:	79 83                	jns    800498 <vprintfmt+0x54>
				width = 0;
  800515:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  80051c:	e9 77 ff ff ff       	jmp    800498 <vprintfmt+0x54>

		case '#':
			altflag = 1;
  800521:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800528:	e9 6b ff ff ff       	jmp    800498 <vprintfmt+0x54>
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
			goto process_precision;
  80052d:	90                   	nop
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80052e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800532:	0f 89 60 ff ff ff    	jns    800498 <vprintfmt+0x54>
				width = precision, precision = -1;
  800538:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80053b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80053e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800545:	e9 4e ff ff ff       	jmp    800498 <vprintfmt+0x54>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80054a:	ff 45 e8             	incl   -0x18(%ebp)
			goto reswitch;
  80054d:	e9 46 ff ff ff       	jmp    800498 <vprintfmt+0x54>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800552:	8b 45 14             	mov    0x14(%ebp),%eax
  800555:	83 c0 04             	add    $0x4,%eax
  800558:	89 45 14             	mov    %eax,0x14(%ebp)
  80055b:	8b 45 14             	mov    0x14(%ebp),%eax
  80055e:	83 e8 04             	sub    $0x4,%eax
  800561:	8b 00                	mov    (%eax),%eax
  800563:	83 ec 08             	sub    $0x8,%esp
  800566:	ff 75 0c             	pushl  0xc(%ebp)
  800569:	50                   	push   %eax
  80056a:	8b 45 08             	mov    0x8(%ebp),%eax
  80056d:	ff d0                	call   *%eax
  80056f:	83 c4 10             	add    $0x10,%esp
			break;
  800572:	e9 89 02 00 00       	jmp    800800 <vprintfmt+0x3bc>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800577:	8b 45 14             	mov    0x14(%ebp),%eax
  80057a:	83 c0 04             	add    $0x4,%eax
  80057d:	89 45 14             	mov    %eax,0x14(%ebp)
  800580:	8b 45 14             	mov    0x14(%ebp),%eax
  800583:	83 e8 04             	sub    $0x4,%eax
  800586:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  800588:	85 db                	test   %ebx,%ebx
  80058a:	79 02                	jns    80058e <vprintfmt+0x14a>
				err = -err;
  80058c:	f7 db                	neg    %ebx
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  80058e:	83 fb 64             	cmp    $0x64,%ebx
  800591:	7f 0b                	jg     80059e <vprintfmt+0x15a>
  800593:	8b 34 9d 00 1d 80 00 	mov    0x801d00(,%ebx,4),%esi
  80059a:	85 f6                	test   %esi,%esi
  80059c:	75 19                	jne    8005b7 <vprintfmt+0x173>
				printfmt(putch, putdat, "error %d", err);
  80059e:	53                   	push   %ebx
  80059f:	68 a5 1e 80 00       	push   $0x801ea5
  8005a4:	ff 75 0c             	pushl  0xc(%ebp)
  8005a7:	ff 75 08             	pushl  0x8(%ebp)
  8005aa:	e8 5e 02 00 00       	call   80080d <printfmt>
  8005af:	83 c4 10             	add    $0x10,%esp
			else
				printfmt(putch, putdat, "%s", p);
			break;
  8005b2:	e9 49 02 00 00       	jmp    800800 <vprintfmt+0x3bc>
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8005b7:	56                   	push   %esi
  8005b8:	68 ae 1e 80 00       	push   $0x801eae
  8005bd:	ff 75 0c             	pushl  0xc(%ebp)
  8005c0:	ff 75 08             	pushl  0x8(%ebp)
  8005c3:	e8 45 02 00 00       	call   80080d <printfmt>
  8005c8:	83 c4 10             	add    $0x10,%esp
			break;
  8005cb:	e9 30 02 00 00       	jmp    800800 <vprintfmt+0x3bc>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d3:	83 c0 04             	add    $0x4,%eax
  8005d6:	89 45 14             	mov    %eax,0x14(%ebp)
  8005d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dc:	83 e8 04             	sub    $0x4,%eax
  8005df:	8b 30                	mov    (%eax),%esi
  8005e1:	85 f6                	test   %esi,%esi
  8005e3:	75 05                	jne    8005ea <vprintfmt+0x1a6>
				p = "(null)";
  8005e5:	be b1 1e 80 00       	mov    $0x801eb1,%esi
			if (width > 0 && padc != '-')
  8005ea:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005ee:	7e 6d                	jle    80065d <vprintfmt+0x219>
  8005f0:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  8005f4:	74 67                	je     80065d <vprintfmt+0x219>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005f9:	83 ec 08             	sub    $0x8,%esp
  8005fc:	50                   	push   %eax
  8005fd:	56                   	push   %esi
  8005fe:	e8 0c 03 00 00       	call   80090f <strnlen>
  800603:	83 c4 10             	add    $0x10,%esp
  800606:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800609:	eb 16                	jmp    800621 <vprintfmt+0x1dd>
					putch(padc, putdat);
  80060b:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  80060f:	83 ec 08             	sub    $0x8,%esp
  800612:	ff 75 0c             	pushl  0xc(%ebp)
  800615:	50                   	push   %eax
  800616:	8b 45 08             	mov    0x8(%ebp),%eax
  800619:	ff d0                	call   *%eax
  80061b:	83 c4 10             	add    $0x10,%esp
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80061e:	ff 4d e4             	decl   -0x1c(%ebp)
  800621:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800625:	7f e4                	jg     80060b <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800627:	eb 34                	jmp    80065d <vprintfmt+0x219>
				if (altflag && (ch < ' ' || ch > '~'))
  800629:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80062d:	74 1c                	je     80064b <vprintfmt+0x207>
  80062f:	83 fb 1f             	cmp    $0x1f,%ebx
  800632:	7e 05                	jle    800639 <vprintfmt+0x1f5>
  800634:	83 fb 7e             	cmp    $0x7e,%ebx
  800637:	7e 12                	jle    80064b <vprintfmt+0x207>
					putch('?', putdat);
  800639:	83 ec 08             	sub    $0x8,%esp
  80063c:	ff 75 0c             	pushl  0xc(%ebp)
  80063f:	6a 3f                	push   $0x3f
  800641:	8b 45 08             	mov    0x8(%ebp),%eax
  800644:	ff d0                	call   *%eax
  800646:	83 c4 10             	add    $0x10,%esp
  800649:	eb 0f                	jmp    80065a <vprintfmt+0x216>
				else
					putch(ch, putdat);
  80064b:	83 ec 08             	sub    $0x8,%esp
  80064e:	ff 75 0c             	pushl  0xc(%ebp)
  800651:	53                   	push   %ebx
  800652:	8b 45 08             	mov    0x8(%ebp),%eax
  800655:	ff d0                	call   *%eax
  800657:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80065a:	ff 4d e4             	decl   -0x1c(%ebp)
  80065d:	89 f0                	mov    %esi,%eax
  80065f:	8d 70 01             	lea    0x1(%eax),%esi
  800662:	8a 00                	mov    (%eax),%al
  800664:	0f be d8             	movsbl %al,%ebx
  800667:	85 db                	test   %ebx,%ebx
  800669:	74 24                	je     80068f <vprintfmt+0x24b>
  80066b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80066f:	78 b8                	js     800629 <vprintfmt+0x1e5>
  800671:	ff 4d e0             	decl   -0x20(%ebp)
  800674:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800678:	79 af                	jns    800629 <vprintfmt+0x1e5>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80067a:	eb 13                	jmp    80068f <vprintfmt+0x24b>
				putch(' ', putdat);
  80067c:	83 ec 08             	sub    $0x8,%esp
  80067f:	ff 75 0c             	pushl  0xc(%ebp)
  800682:	6a 20                	push   $0x20
  800684:	8b 45 08             	mov    0x8(%ebp),%eax
  800687:	ff d0                	call   *%eax
  800689:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80068c:	ff 4d e4             	decl   -0x1c(%ebp)
  80068f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800693:	7f e7                	jg     80067c <vprintfmt+0x238>
				putch(' ', putdat);
			break;
  800695:	e9 66 01 00 00       	jmp    800800 <vprintfmt+0x3bc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80069a:	83 ec 08             	sub    $0x8,%esp
  80069d:	ff 75 e8             	pushl  -0x18(%ebp)
  8006a0:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a3:	50                   	push   %eax
  8006a4:	e8 3c fd ff ff       	call   8003e5 <getint>
  8006a9:	83 c4 10             	add    $0x10,%esp
  8006ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006af:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  8006b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006b8:	85 d2                	test   %edx,%edx
  8006ba:	79 23                	jns    8006df <vprintfmt+0x29b>
				putch('-', putdat);
  8006bc:	83 ec 08             	sub    $0x8,%esp
  8006bf:	ff 75 0c             	pushl  0xc(%ebp)
  8006c2:	6a 2d                	push   $0x2d
  8006c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c7:	ff d0                	call   *%eax
  8006c9:	83 c4 10             	add    $0x10,%esp
				num = -(long long) num;
  8006cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006d2:	f7 d8                	neg    %eax
  8006d4:	83 d2 00             	adc    $0x0,%edx
  8006d7:	f7 da                	neg    %edx
  8006d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006dc:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  8006df:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8006e6:	e9 bc 00 00 00       	jmp    8007a7 <vprintfmt+0x363>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006eb:	83 ec 08             	sub    $0x8,%esp
  8006ee:	ff 75 e8             	pushl  -0x18(%ebp)
  8006f1:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f4:	50                   	push   %eax
  8006f5:	e8 84 fc ff ff       	call   80037e <getuint>
  8006fa:	83 c4 10             	add    $0x10,%esp
  8006fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800700:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800703:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  80070a:	e9 98 00 00 00       	jmp    8007a7 <vprintfmt+0x363>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80070f:	83 ec 08             	sub    $0x8,%esp
  800712:	ff 75 0c             	pushl  0xc(%ebp)
  800715:	6a 58                	push   $0x58
  800717:	8b 45 08             	mov    0x8(%ebp),%eax
  80071a:	ff d0                	call   *%eax
  80071c:	83 c4 10             	add    $0x10,%esp
			putch('X', putdat);
  80071f:	83 ec 08             	sub    $0x8,%esp
  800722:	ff 75 0c             	pushl  0xc(%ebp)
  800725:	6a 58                	push   $0x58
  800727:	8b 45 08             	mov    0x8(%ebp),%eax
  80072a:	ff d0                	call   *%eax
  80072c:	83 c4 10             	add    $0x10,%esp
			putch('X', putdat);
  80072f:	83 ec 08             	sub    $0x8,%esp
  800732:	ff 75 0c             	pushl  0xc(%ebp)
  800735:	6a 58                	push   $0x58
  800737:	8b 45 08             	mov    0x8(%ebp),%eax
  80073a:	ff d0                	call   *%eax
  80073c:	83 c4 10             	add    $0x10,%esp
			break;
  80073f:	e9 bc 00 00 00       	jmp    800800 <vprintfmt+0x3bc>

		// pointer
		case 'p':
			putch('0', putdat);
  800744:	83 ec 08             	sub    $0x8,%esp
  800747:	ff 75 0c             	pushl  0xc(%ebp)
  80074a:	6a 30                	push   $0x30
  80074c:	8b 45 08             	mov    0x8(%ebp),%eax
  80074f:	ff d0                	call   *%eax
  800751:	83 c4 10             	add    $0x10,%esp
			putch('x', putdat);
  800754:	83 ec 08             	sub    $0x8,%esp
  800757:	ff 75 0c             	pushl  0xc(%ebp)
  80075a:	6a 78                	push   $0x78
  80075c:	8b 45 08             	mov    0x8(%ebp),%eax
  80075f:	ff d0                	call   *%eax
  800761:	83 c4 10             	add    $0x10,%esp
			num = (unsigned long long)
				(uint32) va_arg(ap, void *);
  800764:	8b 45 14             	mov    0x14(%ebp),%eax
  800767:	83 c0 04             	add    $0x4,%eax
  80076a:	89 45 14             	mov    %eax,0x14(%ebp)
  80076d:	8b 45 14             	mov    0x14(%ebp),%eax
  800770:	83 e8 04             	sub    $0x4,%eax
  800773:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800775:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800778:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uint32) va_arg(ap, void *);
			base = 16;
  80077f:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800786:	eb 1f                	jmp    8007a7 <vprintfmt+0x363>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800788:	83 ec 08             	sub    $0x8,%esp
  80078b:	ff 75 e8             	pushl  -0x18(%ebp)
  80078e:	8d 45 14             	lea    0x14(%ebp),%eax
  800791:	50                   	push   %eax
  800792:	e8 e7 fb ff ff       	call   80037e <getuint>
  800797:	83 c4 10             	add    $0x10,%esp
  80079a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80079d:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  8007a0:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007a7:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  8007ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ae:	83 ec 04             	sub    $0x4,%esp
  8007b1:	52                   	push   %edx
  8007b2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007b5:	50                   	push   %eax
  8007b6:	ff 75 f4             	pushl  -0xc(%ebp)
  8007b9:	ff 75 f0             	pushl  -0x10(%ebp)
  8007bc:	ff 75 0c             	pushl  0xc(%ebp)
  8007bf:	ff 75 08             	pushl  0x8(%ebp)
  8007c2:	e8 00 fb ff ff       	call   8002c7 <printnum>
  8007c7:	83 c4 20             	add    $0x20,%esp
			break;
  8007ca:	eb 34                	jmp    800800 <vprintfmt+0x3bc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007cc:	83 ec 08             	sub    $0x8,%esp
  8007cf:	ff 75 0c             	pushl  0xc(%ebp)
  8007d2:	53                   	push   %ebx
  8007d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d6:	ff d0                	call   *%eax
  8007d8:	83 c4 10             	add    $0x10,%esp
			break;
  8007db:	eb 23                	jmp    800800 <vprintfmt+0x3bc>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007dd:	83 ec 08             	sub    $0x8,%esp
  8007e0:	ff 75 0c             	pushl  0xc(%ebp)
  8007e3:	6a 25                	push   $0x25
  8007e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e8:	ff d0                	call   *%eax
  8007ea:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007ed:	ff 4d 10             	decl   0x10(%ebp)
  8007f0:	eb 03                	jmp    8007f5 <vprintfmt+0x3b1>
  8007f2:	ff 4d 10             	decl   0x10(%ebp)
  8007f5:	8b 45 10             	mov    0x10(%ebp),%eax
  8007f8:	48                   	dec    %eax
  8007f9:	8a 00                	mov    (%eax),%al
  8007fb:	3c 25                	cmp    $0x25,%al
  8007fd:	75 f3                	jne    8007f2 <vprintfmt+0x3ae>
				/* do nothing */;
			break;
  8007ff:	90                   	nop
		}
	}
  800800:	e9 47 fc ff ff       	jmp    80044c <vprintfmt+0x8>
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
  800805:	90                   	nop
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800806:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800809:	5b                   	pop    %ebx
  80080a:	5e                   	pop    %esi
  80080b:	5d                   	pop    %ebp
  80080c:	c3                   	ret    

0080080d <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80080d:	55                   	push   %ebp
  80080e:	89 e5                	mov    %esp,%ebp
  800810:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800813:	8d 45 10             	lea    0x10(%ebp),%eax
  800816:	83 c0 04             	add    $0x4,%eax
  800819:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  80081c:	8b 45 10             	mov    0x10(%ebp),%eax
  80081f:	ff 75 f4             	pushl  -0xc(%ebp)
  800822:	50                   	push   %eax
  800823:	ff 75 0c             	pushl  0xc(%ebp)
  800826:	ff 75 08             	pushl  0x8(%ebp)
  800829:	e8 16 fc ff ff       	call   800444 <vprintfmt>
  80082e:	83 c4 10             	add    $0x10,%esp
	va_end(ap);
}
  800831:	90                   	nop
  800832:	c9                   	leave  
  800833:	c3                   	ret    

00800834 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800837:	8b 45 0c             	mov    0xc(%ebp),%eax
  80083a:	8b 40 08             	mov    0x8(%eax),%eax
  80083d:	8d 50 01             	lea    0x1(%eax),%edx
  800840:	8b 45 0c             	mov    0xc(%ebp),%eax
  800843:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800846:	8b 45 0c             	mov    0xc(%ebp),%eax
  800849:	8b 10                	mov    (%eax),%edx
  80084b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084e:	8b 40 04             	mov    0x4(%eax),%eax
  800851:	39 c2                	cmp    %eax,%edx
  800853:	73 12                	jae    800867 <sprintputch+0x33>
		*b->buf++ = ch;
  800855:	8b 45 0c             	mov    0xc(%ebp),%eax
  800858:	8b 00                	mov    (%eax),%eax
  80085a:	8d 48 01             	lea    0x1(%eax),%ecx
  80085d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800860:	89 0a                	mov    %ecx,(%edx)
  800862:	8b 55 08             	mov    0x8(%ebp),%edx
  800865:	88 10                	mov    %dl,(%eax)
}
  800867:	90                   	nop
  800868:	5d                   	pop    %ebp
  800869:	c3                   	ret    

0080086a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	83 ec 18             	sub    $0x18,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800870:	8b 45 08             	mov    0x8(%ebp),%eax
  800873:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800876:	8b 45 0c             	mov    0xc(%ebp),%eax
  800879:	8d 50 ff             	lea    -0x1(%eax),%edx
  80087c:	8b 45 08             	mov    0x8(%ebp),%eax
  80087f:	01 d0                	add    %edx,%eax
  800881:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800884:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80088b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80088f:	74 06                	je     800897 <vsnprintf+0x2d>
  800891:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800895:	7f 07                	jg     80089e <vsnprintf+0x34>
		return -E_INVAL;
  800897:	b8 03 00 00 00       	mov    $0x3,%eax
  80089c:	eb 20                	jmp    8008be <vsnprintf+0x54>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80089e:	ff 75 14             	pushl  0x14(%ebp)
  8008a1:	ff 75 10             	pushl  0x10(%ebp)
  8008a4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008a7:	50                   	push   %eax
  8008a8:	68 34 08 80 00       	push   $0x800834
  8008ad:	e8 92 fb ff ff       	call   800444 <vprintfmt>
  8008b2:	83 c4 10             	add    $0x10,%esp

	// null terminate the buffer
	*b.buf = '\0';
  8008b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008b8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8008be:	c9                   	leave  
  8008bf:	c3                   	ret    

008008c0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008c6:	8d 45 10             	lea    0x10(%ebp),%eax
  8008c9:	83 c0 04             	add    $0x4,%eax
  8008cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8008cf:	8b 45 10             	mov    0x10(%ebp),%eax
  8008d2:	ff 75 f4             	pushl  -0xc(%ebp)
  8008d5:	50                   	push   %eax
  8008d6:	ff 75 0c             	pushl  0xc(%ebp)
  8008d9:	ff 75 08             	pushl  0x8(%ebp)
  8008dc:	e8 89 ff ff ff       	call   80086a <vsnprintf>
  8008e1:	83 c4 10             	add    $0x10,%esp
  8008e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
	va_end(ap);

	return rc;
  8008e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  8008ea:	c9                   	leave  
  8008eb:	c3                   	ret    

008008ec <strlen>:

#include <inc/string.h>
#include <inc/assert.h>
int
strlen(const char *s)
{
  8008ec:	55                   	push   %ebp
  8008ed:	89 e5                	mov    %esp,%ebp
  8008ef:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  8008f2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8008f9:	eb 06                	jmp    800901 <strlen+0x15>
		n++;
  8008fb:	ff 45 fc             	incl   -0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008fe:	ff 45 08             	incl   0x8(%ebp)
  800901:	8b 45 08             	mov    0x8(%ebp),%eax
  800904:	8a 00                	mov    (%eax),%al
  800906:	84 c0                	test   %al,%al
  800908:	75 f1                	jne    8008fb <strlen+0xf>
		n++;
	return n;
  80090a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80090d:	c9                   	leave  
  80090e:	c3                   	ret    

0080090f <strnlen>:

int
strnlen(const char *s, uint32 size)
{
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
  800912:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800915:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80091c:	eb 09                	jmp    800927 <strnlen+0x18>
		n++;
  80091e:	ff 45 fc             	incl   -0x4(%ebp)
int
strnlen(const char *s, uint32 size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800921:	ff 45 08             	incl   0x8(%ebp)
  800924:	ff 4d 0c             	decl   0xc(%ebp)
  800927:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80092b:	74 09                	je     800936 <strnlen+0x27>
  80092d:	8b 45 08             	mov    0x8(%ebp),%eax
  800930:	8a 00                	mov    (%eax),%al
  800932:	84 c0                	test   %al,%al
  800934:	75 e8                	jne    80091e <strnlen+0xf>
		n++;
	return n;
  800936:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800939:	c9                   	leave  
  80093a:	c3                   	ret    

0080093b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800941:	8b 45 08             	mov    0x8(%ebp),%eax
  800944:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800947:	90                   	nop
  800948:	8b 45 08             	mov    0x8(%ebp),%eax
  80094b:	8d 50 01             	lea    0x1(%eax),%edx
  80094e:	89 55 08             	mov    %edx,0x8(%ebp)
  800951:	8b 55 0c             	mov    0xc(%ebp),%edx
  800954:	8d 4a 01             	lea    0x1(%edx),%ecx
  800957:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  80095a:	8a 12                	mov    (%edx),%dl
  80095c:	88 10                	mov    %dl,(%eax)
  80095e:	8a 00                	mov    (%eax),%al
  800960:	84 c0                	test   %al,%al
  800962:	75 e4                	jne    800948 <strcpy+0xd>
		/* do nothing */;
	return ret;
  800964:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800967:	c9                   	leave  
  800968:	c3                   	ret    

00800969 <strncpy>:

char *
strncpy(char *dst, const char *src, uint32 size) {
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
  80096c:	83 ec 10             	sub    $0x10,%esp
	uint32 i;
	char *ret;

	ret = dst;
  80096f:	8b 45 08             	mov    0x8(%ebp),%eax
  800972:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800975:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80097c:	eb 1f                	jmp    80099d <strncpy+0x34>
		*dst++ = *src;
  80097e:	8b 45 08             	mov    0x8(%ebp),%eax
  800981:	8d 50 01             	lea    0x1(%eax),%edx
  800984:	89 55 08             	mov    %edx,0x8(%ebp)
  800987:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098a:	8a 12                	mov    (%edx),%dl
  80098c:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  80098e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800991:	8a 00                	mov    (%eax),%al
  800993:	84 c0                	test   %al,%al
  800995:	74 03                	je     80099a <strncpy+0x31>
			src++;
  800997:	ff 45 0c             	incl   0xc(%ebp)
strncpy(char *dst, const char *src, uint32 size) {
	uint32 i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80099a:	ff 45 fc             	incl   -0x4(%ebp)
  80099d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8009a0:	3b 45 10             	cmp    0x10(%ebp),%eax
  8009a3:	72 d9                	jb     80097e <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  8009a5:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  8009a8:	c9                   	leave  
  8009a9:	c3                   	ret    

008009aa <strlcpy>:

uint32
strlcpy(char *dst, const char *src, uint32 size)
{
  8009aa:	55                   	push   %ebp
  8009ab:	89 e5                	mov    %esp,%ebp
  8009ad:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  8009b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b3:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  8009b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009ba:	74 30                	je     8009ec <strlcpy+0x42>
		while (--size > 0 && *src != '\0')
  8009bc:	eb 16                	jmp    8009d4 <strlcpy+0x2a>
			*dst++ = *src++;
  8009be:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c1:	8d 50 01             	lea    0x1(%eax),%edx
  8009c4:	89 55 08             	mov    %edx,0x8(%ebp)
  8009c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ca:	8d 4a 01             	lea    0x1(%edx),%ecx
  8009cd:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  8009d0:	8a 12                	mov    (%edx),%dl
  8009d2:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009d4:	ff 4d 10             	decl   0x10(%ebp)
  8009d7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009db:	74 09                	je     8009e6 <strlcpy+0x3c>
  8009dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e0:	8a 00                	mov    (%eax),%al
  8009e2:	84 c0                	test   %al,%al
  8009e4:	75 d8                	jne    8009be <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  8009e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8009ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8009f2:	29 c2                	sub    %eax,%edx
  8009f4:	89 d0                	mov    %edx,%eax
}
  8009f6:	c9                   	leave  
  8009f7:	c3                   	ret    

008009f8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009f8:	55                   	push   %ebp
  8009f9:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  8009fb:	eb 06                	jmp    800a03 <strcmp+0xb>
		p++, q++;
  8009fd:	ff 45 08             	incl   0x8(%ebp)
  800a00:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a03:	8b 45 08             	mov    0x8(%ebp),%eax
  800a06:	8a 00                	mov    (%eax),%al
  800a08:	84 c0                	test   %al,%al
  800a0a:	74 0e                	je     800a1a <strcmp+0x22>
  800a0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0f:	8a 10                	mov    (%eax),%dl
  800a11:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a14:	8a 00                	mov    (%eax),%al
  800a16:	38 c2                	cmp    %al,%dl
  800a18:	74 e3                	je     8009fd <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1d:	8a 00                	mov    (%eax),%al
  800a1f:	0f b6 d0             	movzbl %al,%edx
  800a22:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a25:	8a 00                	mov    (%eax),%al
  800a27:	0f b6 c0             	movzbl %al,%eax
  800a2a:	29 c2                	sub    %eax,%edx
  800a2c:	89 d0                	mov    %edx,%eax
}
  800a2e:	5d                   	pop    %ebp
  800a2f:	c3                   	ret    

00800a30 <strncmp>:

int
strncmp(const char *p, const char *q, uint32 n)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800a33:	eb 09                	jmp    800a3e <strncmp+0xe>
		n--, p++, q++;
  800a35:	ff 4d 10             	decl   0x10(%ebp)
  800a38:	ff 45 08             	incl   0x8(%ebp)
  800a3b:	ff 45 0c             	incl   0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint32 n)
{
	while (n > 0 && *p && *p == *q)
  800a3e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a42:	74 17                	je     800a5b <strncmp+0x2b>
  800a44:	8b 45 08             	mov    0x8(%ebp),%eax
  800a47:	8a 00                	mov    (%eax),%al
  800a49:	84 c0                	test   %al,%al
  800a4b:	74 0e                	je     800a5b <strncmp+0x2b>
  800a4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a50:	8a 10                	mov    (%eax),%dl
  800a52:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a55:	8a 00                	mov    (%eax),%al
  800a57:	38 c2                	cmp    %al,%dl
  800a59:	74 da                	je     800a35 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800a5b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a5f:	75 07                	jne    800a68 <strncmp+0x38>
		return 0;
  800a61:	b8 00 00 00 00       	mov    $0x0,%eax
  800a66:	eb 14                	jmp    800a7c <strncmp+0x4c>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a68:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6b:	8a 00                	mov    (%eax),%al
  800a6d:	0f b6 d0             	movzbl %al,%edx
  800a70:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a73:	8a 00                	mov    (%eax),%al
  800a75:	0f b6 c0             	movzbl %al,%eax
  800a78:	29 c2                	sub    %eax,%edx
  800a7a:	89 d0                	mov    %edx,%eax
}
  800a7c:	5d                   	pop    %ebp
  800a7d:	c3                   	ret    

00800a7e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	83 ec 04             	sub    $0x4,%esp
  800a84:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a87:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800a8a:	eb 12                	jmp    800a9e <strchr+0x20>
		if (*s == c)
  800a8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8f:	8a 00                	mov    (%eax),%al
  800a91:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800a94:	75 05                	jne    800a9b <strchr+0x1d>
			return (char *) s;
  800a96:	8b 45 08             	mov    0x8(%ebp),%eax
  800a99:	eb 11                	jmp    800aac <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a9b:	ff 45 08             	incl   0x8(%ebp)
  800a9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa1:	8a 00                	mov    (%eax),%al
  800aa3:	84 c0                	test   %al,%al
  800aa5:	75 e5                	jne    800a8c <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800aa7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aac:	c9                   	leave  
  800aad:	c3                   	ret    

00800aae <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800aae:	55                   	push   %ebp
  800aaf:	89 e5                	mov    %esp,%ebp
  800ab1:	83 ec 04             	sub    $0x4,%esp
  800ab4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab7:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800aba:	eb 0d                	jmp    800ac9 <strfind+0x1b>
		if (*s == c)
  800abc:	8b 45 08             	mov    0x8(%ebp),%eax
  800abf:	8a 00                	mov    (%eax),%al
  800ac1:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800ac4:	74 0e                	je     800ad4 <strfind+0x26>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ac6:	ff 45 08             	incl   0x8(%ebp)
  800ac9:	8b 45 08             	mov    0x8(%ebp),%eax
  800acc:	8a 00                	mov    (%eax),%al
  800ace:	84 c0                	test   %al,%al
  800ad0:	75 ea                	jne    800abc <strfind+0xe>
  800ad2:	eb 01                	jmp    800ad5 <strfind+0x27>
		if (*s == c)
			break;
  800ad4:	90                   	nop
	return (char *) s;
  800ad5:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ad8:	c9                   	leave  
  800ad9:	c3                   	ret    

00800ada <memset>:


void *
memset(void *v, int c, uint32 n)
{
  800ada:	55                   	push   %ebp
  800adb:	89 e5                	mov    %esp,%ebp
  800add:	83 ec 10             	sub    $0x10,%esp
	char *p;
	int m;

	p = v;
  800ae0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae3:	89 45 fc             	mov    %eax,-0x4(%ebp)
	m = n;
  800ae6:	8b 45 10             	mov    0x10(%ebp),%eax
  800ae9:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (--m >= 0)
  800aec:	eb 0e                	jmp    800afc <memset+0x22>
		*p++ = c;
  800aee:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800af1:	8d 50 01             	lea    0x1(%eax),%edx
  800af4:	89 55 fc             	mov    %edx,-0x4(%ebp)
  800af7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800afa:	88 10                	mov    %dl,(%eax)
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800afc:	ff 4d f8             	decl   -0x8(%ebp)
  800aff:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
  800b03:	79 e9                	jns    800aee <memset+0x14>
		*p++ = c;

	return v;
  800b05:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b08:	c9                   	leave  
  800b09:	c3                   	ret    

00800b0a <memcpy>:

void *
memcpy(void *dst, const void *src, uint32 n)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800b10:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b13:	89 45 fc             	mov    %eax,-0x4(%ebp)
	d = dst;
  800b16:	8b 45 08             	mov    0x8(%ebp),%eax
  800b19:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (n-- > 0)
  800b1c:	eb 16                	jmp    800b34 <memcpy+0x2a>
		*d++ = *s++;
  800b1e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800b21:	8d 50 01             	lea    0x1(%eax),%edx
  800b24:	89 55 f8             	mov    %edx,-0x8(%ebp)
  800b27:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800b2a:	8d 4a 01             	lea    0x1(%edx),%ecx
  800b2d:	89 4d fc             	mov    %ecx,-0x4(%ebp)
  800b30:	8a 12                	mov    (%edx),%dl
  800b32:	88 10                	mov    %dl,(%eax)
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
  800b34:	8b 45 10             	mov    0x10(%ebp),%eax
  800b37:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b3a:	89 55 10             	mov    %edx,0x10(%ebp)
  800b3d:	85 c0                	test   %eax,%eax
  800b3f:	75 dd                	jne    800b1e <memcpy+0x14>
		*d++ = *s++;

	return dst;
  800b41:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b44:	c9                   	leave  
  800b45:	c3                   	ret    

00800b46 <memmove>:

void *
memmove(void *dst, const void *src, uint32 n)
{
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800b4c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b4f:	89 45 fc             	mov    %eax,-0x4(%ebp)
	d = dst;
  800b52:	8b 45 08             	mov    0x8(%ebp),%eax
  800b55:	89 45 f8             	mov    %eax,-0x8(%ebp)
	if (s < d && s + n > d) {
  800b58:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800b5b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  800b5e:	73 50                	jae    800bb0 <memmove+0x6a>
  800b60:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800b63:	8b 45 10             	mov    0x10(%ebp),%eax
  800b66:	01 d0                	add    %edx,%eax
  800b68:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  800b6b:	76 43                	jbe    800bb0 <memmove+0x6a>
		s += n;
  800b6d:	8b 45 10             	mov    0x10(%ebp),%eax
  800b70:	01 45 fc             	add    %eax,-0x4(%ebp)
		d += n;
  800b73:	8b 45 10             	mov    0x10(%ebp),%eax
  800b76:	01 45 f8             	add    %eax,-0x8(%ebp)
		while (n-- > 0)
  800b79:	eb 10                	jmp    800b8b <memmove+0x45>
			*--d = *--s;
  800b7b:	ff 4d f8             	decl   -0x8(%ebp)
  800b7e:	ff 4d fc             	decl   -0x4(%ebp)
  800b81:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800b84:	8a 10                	mov    (%eax),%dl
  800b86:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800b89:	88 10                	mov    %dl,(%eax)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  800b8b:	8b 45 10             	mov    0x10(%ebp),%eax
  800b8e:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b91:	89 55 10             	mov    %edx,0x10(%ebp)
  800b94:	85 c0                	test   %eax,%eax
  800b96:	75 e3                	jne    800b7b <memmove+0x35>
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b98:	eb 23                	jmp    800bbd <memmove+0x77>
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  800b9a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800b9d:	8d 50 01             	lea    0x1(%eax),%edx
  800ba0:	89 55 f8             	mov    %edx,-0x8(%ebp)
  800ba3:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800ba6:	8d 4a 01             	lea    0x1(%edx),%ecx
  800ba9:	89 4d fc             	mov    %ecx,-0x4(%ebp)
  800bac:	8a 12                	mov    (%edx),%dl
  800bae:	88 10                	mov    %dl,(%eax)
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800bb0:	8b 45 10             	mov    0x10(%ebp),%eax
  800bb3:	8d 50 ff             	lea    -0x1(%eax),%edx
  800bb6:	89 55 10             	mov    %edx,0x10(%ebp)
  800bb9:	85 c0                	test   %eax,%eax
  800bbb:	75 dd                	jne    800b9a <memmove+0x54>
			*d++ = *s++;

	return dst;
  800bbd:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800bc0:	c9                   	leave  
  800bc1:	c3                   	ret    

00800bc2 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint32 n)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	83 ec 10             	sub    $0x10,%esp
	const uint8 *s1 = (const uint8 *) v1;
  800bc8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcb:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8 *s2 = (const uint8 *) v2;
  800bce:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd1:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800bd4:	eb 2a                	jmp    800c00 <memcmp+0x3e>
		if (*s1 != *s2)
  800bd6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bd9:	8a 10                	mov    (%eax),%dl
  800bdb:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800bde:	8a 00                	mov    (%eax),%al
  800be0:	38 c2                	cmp    %al,%dl
  800be2:	74 16                	je     800bfa <memcmp+0x38>
			return (int) *s1 - (int) *s2;
  800be4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800be7:	8a 00                	mov    (%eax),%al
  800be9:	0f b6 d0             	movzbl %al,%edx
  800bec:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800bef:	8a 00                	mov    (%eax),%al
  800bf1:	0f b6 c0             	movzbl %al,%eax
  800bf4:	29 c2                	sub    %eax,%edx
  800bf6:	89 d0                	mov    %edx,%eax
  800bf8:	eb 18                	jmp    800c12 <memcmp+0x50>
		s1++, s2++;
  800bfa:	ff 45 fc             	incl   -0x4(%ebp)
  800bfd:	ff 45 f8             	incl   -0x8(%ebp)
memcmp(const void *v1, const void *v2, uint32 n)
{
	const uint8 *s1 = (const uint8 *) v1;
	const uint8 *s2 = (const uint8 *) v2;

	while (n-- > 0) {
  800c00:	8b 45 10             	mov    0x10(%ebp),%eax
  800c03:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c06:	89 55 10             	mov    %edx,0x10(%ebp)
  800c09:	85 c0                	test   %eax,%eax
  800c0b:	75 c9                	jne    800bd6 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c0d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c12:	c9                   	leave  
  800c13:	c3                   	ret    

00800c14 <memfind>:

void *
memfind(const void *s, int c, uint32 n)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800c1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1d:	8b 45 10             	mov    0x10(%ebp),%eax
  800c20:	01 d0                	add    %edx,%eax
  800c22:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800c25:	eb 15                	jmp    800c3c <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c27:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2a:	8a 00                	mov    (%eax),%al
  800c2c:	0f b6 d0             	movzbl %al,%edx
  800c2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c32:	0f b6 c0             	movzbl %al,%eax
  800c35:	39 c2                	cmp    %eax,%edx
  800c37:	74 0d                	je     800c46 <memfind+0x32>

void *
memfind(const void *s, int c, uint32 n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c39:	ff 45 08             	incl   0x8(%ebp)
  800c3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800c42:	72 e3                	jb     800c27 <memfind+0x13>
  800c44:	eb 01                	jmp    800c47 <memfind+0x33>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
  800c46:	90                   	nop
	return (void *) s;
  800c47:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c4a:	c9                   	leave  
  800c4b:	c3                   	ret    

00800c4c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800c52:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800c59:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c60:	eb 03                	jmp    800c65 <strtol+0x19>
		s++;
  800c62:	ff 45 08             	incl   0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c65:	8b 45 08             	mov    0x8(%ebp),%eax
  800c68:	8a 00                	mov    (%eax),%al
  800c6a:	3c 20                	cmp    $0x20,%al
  800c6c:	74 f4                	je     800c62 <strtol+0x16>
  800c6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c71:	8a 00                	mov    (%eax),%al
  800c73:	3c 09                	cmp    $0x9,%al
  800c75:	74 eb                	je     800c62 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c77:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7a:	8a 00                	mov    (%eax),%al
  800c7c:	3c 2b                	cmp    $0x2b,%al
  800c7e:	75 05                	jne    800c85 <strtol+0x39>
		s++;
  800c80:	ff 45 08             	incl   0x8(%ebp)
  800c83:	eb 13                	jmp    800c98 <strtol+0x4c>
	else if (*s == '-')
  800c85:	8b 45 08             	mov    0x8(%ebp),%eax
  800c88:	8a 00                	mov    (%eax),%al
  800c8a:	3c 2d                	cmp    $0x2d,%al
  800c8c:	75 0a                	jne    800c98 <strtol+0x4c>
		s++, neg = 1;
  800c8e:	ff 45 08             	incl   0x8(%ebp)
  800c91:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c98:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c9c:	74 06                	je     800ca4 <strtol+0x58>
  800c9e:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800ca2:	75 20                	jne    800cc4 <strtol+0x78>
  800ca4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca7:	8a 00                	mov    (%eax),%al
  800ca9:	3c 30                	cmp    $0x30,%al
  800cab:	75 17                	jne    800cc4 <strtol+0x78>
  800cad:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb0:	40                   	inc    %eax
  800cb1:	8a 00                	mov    (%eax),%al
  800cb3:	3c 78                	cmp    $0x78,%al
  800cb5:	75 0d                	jne    800cc4 <strtol+0x78>
		s += 2, base = 16;
  800cb7:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800cbb:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800cc2:	eb 28                	jmp    800cec <strtol+0xa0>
	else if (base == 0 && s[0] == '0')
  800cc4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cc8:	75 15                	jne    800cdf <strtol+0x93>
  800cca:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccd:	8a 00                	mov    (%eax),%al
  800ccf:	3c 30                	cmp    $0x30,%al
  800cd1:	75 0c                	jne    800cdf <strtol+0x93>
		s++, base = 8;
  800cd3:	ff 45 08             	incl   0x8(%ebp)
  800cd6:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800cdd:	eb 0d                	jmp    800cec <strtol+0xa0>
	else if (base == 0)
  800cdf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ce3:	75 07                	jne    800cec <strtol+0xa0>
		base = 10;
  800ce5:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cec:	8b 45 08             	mov    0x8(%ebp),%eax
  800cef:	8a 00                	mov    (%eax),%al
  800cf1:	3c 2f                	cmp    $0x2f,%al
  800cf3:	7e 19                	jle    800d0e <strtol+0xc2>
  800cf5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf8:	8a 00                	mov    (%eax),%al
  800cfa:	3c 39                	cmp    $0x39,%al
  800cfc:	7f 10                	jg     800d0e <strtol+0xc2>
			dig = *s - '0';
  800cfe:	8b 45 08             	mov    0x8(%ebp),%eax
  800d01:	8a 00                	mov    (%eax),%al
  800d03:	0f be c0             	movsbl %al,%eax
  800d06:	83 e8 30             	sub    $0x30,%eax
  800d09:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d0c:	eb 42                	jmp    800d50 <strtol+0x104>
		else if (*s >= 'a' && *s <= 'z')
  800d0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d11:	8a 00                	mov    (%eax),%al
  800d13:	3c 60                	cmp    $0x60,%al
  800d15:	7e 19                	jle    800d30 <strtol+0xe4>
  800d17:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1a:	8a 00                	mov    (%eax),%al
  800d1c:	3c 7a                	cmp    $0x7a,%al
  800d1e:	7f 10                	jg     800d30 <strtol+0xe4>
			dig = *s - 'a' + 10;
  800d20:	8b 45 08             	mov    0x8(%ebp),%eax
  800d23:	8a 00                	mov    (%eax),%al
  800d25:	0f be c0             	movsbl %al,%eax
  800d28:	83 e8 57             	sub    $0x57,%eax
  800d2b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d2e:	eb 20                	jmp    800d50 <strtol+0x104>
		else if (*s >= 'A' && *s <= 'Z')
  800d30:	8b 45 08             	mov    0x8(%ebp),%eax
  800d33:	8a 00                	mov    (%eax),%al
  800d35:	3c 40                	cmp    $0x40,%al
  800d37:	7e 39                	jle    800d72 <strtol+0x126>
  800d39:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3c:	8a 00                	mov    (%eax),%al
  800d3e:	3c 5a                	cmp    $0x5a,%al
  800d40:	7f 30                	jg     800d72 <strtol+0x126>
			dig = *s - 'A' + 10;
  800d42:	8b 45 08             	mov    0x8(%ebp),%eax
  800d45:	8a 00                	mov    (%eax),%al
  800d47:	0f be c0             	movsbl %al,%eax
  800d4a:	83 e8 37             	sub    $0x37,%eax
  800d4d:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800d50:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d53:	3b 45 10             	cmp    0x10(%ebp),%eax
  800d56:	7d 19                	jge    800d71 <strtol+0x125>
			break;
		s++, val = (val * base) + dig;
  800d58:	ff 45 08             	incl   0x8(%ebp)
  800d5b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d5e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d62:	89 c2                	mov    %eax,%edx
  800d64:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d67:	01 d0                	add    %edx,%eax
  800d69:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800d6c:	e9 7b ff ff ff       	jmp    800cec <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
			break;
  800d71:	90                   	nop
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d72:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d76:	74 08                	je     800d80 <strtol+0x134>
		*endptr = (char *) s;
  800d78:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7e:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800d80:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800d84:	74 07                	je     800d8d <strtol+0x141>
  800d86:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d89:	f7 d8                	neg    %eax
  800d8b:	eb 03                	jmp    800d90 <strtol+0x144>
  800d8d:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800d90:	c9                   	leave  
  800d91:	c3                   	ret    

00800d92 <ltostr>:

void
ltostr(long value, char *str)
{
  800d92:	55                   	push   %ebp
  800d93:	89 e5                	mov    %esp,%ebp
  800d95:	83 ec 20             	sub    $0x20,%esp
	int neg = 0;
  800d98:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	int s = 0 ;
  800d9f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// plus/minus sign
	if (value < 0)
  800da6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800daa:	79 13                	jns    800dbf <ltostr+0x2d>
	{
		neg = 1;
  800dac:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
		str[0] = '-';
  800db3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800db6:	c6 00 2d             	movb   $0x2d,(%eax)
		value = value * -1 ;
  800db9:	f7 5d 08             	negl   0x8(%ebp)
		s++ ;
  800dbc:	ff 45 f8             	incl   -0x8(%ebp)
	}
	do
	{
		int mod = value % 10 ;
  800dbf:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc2:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800dc7:	99                   	cltd   
  800dc8:	f7 f9                	idiv   %ecx
  800dca:	89 55 ec             	mov    %edx,-0x14(%ebp)
		str[s++] = mod + '0' ;
  800dcd:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800dd0:	8d 50 01             	lea    0x1(%eax),%edx
  800dd3:	89 55 f8             	mov    %edx,-0x8(%ebp)
  800dd6:	89 c2                	mov    %eax,%edx
  800dd8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ddb:	01 d0                	add    %edx,%eax
  800ddd:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800de0:	83 c2 30             	add    $0x30,%edx
  800de3:	88 10                	mov    %dl,(%eax)
		value = value / 10 ;
  800de5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800de8:	b8 67 66 66 66       	mov    $0x66666667,%eax
  800ded:	f7 e9                	imul   %ecx
  800def:	c1 fa 02             	sar    $0x2,%edx
  800df2:	89 c8                	mov    %ecx,%eax
  800df4:	c1 f8 1f             	sar    $0x1f,%eax
  800df7:	29 c2                	sub    %eax,%edx
  800df9:	89 d0                	mov    %edx,%eax
  800dfb:	89 45 08             	mov    %eax,0x8(%ebp)
	} while (value % 10 != 0);
  800dfe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e01:	b8 67 66 66 66       	mov    $0x66666667,%eax
  800e06:	f7 e9                	imul   %ecx
  800e08:	c1 fa 02             	sar    $0x2,%edx
  800e0b:	89 c8                	mov    %ecx,%eax
  800e0d:	c1 f8 1f             	sar    $0x1f,%eax
  800e10:	29 c2                	sub    %eax,%edx
  800e12:	89 d0                	mov    %edx,%eax
  800e14:	c1 e0 02             	shl    $0x2,%eax
  800e17:	01 d0                	add    %edx,%eax
  800e19:	01 c0                	add    %eax,%eax
  800e1b:	29 c1                	sub    %eax,%ecx
  800e1d:	89 ca                	mov    %ecx,%edx
  800e1f:	85 d2                	test   %edx,%edx
  800e21:	75 9c                	jne    800dbf <ltostr+0x2d>

	//reverse the string
	int start = 0 ;
  800e23:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	int end = s-1 ;
  800e2a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e2d:	48                   	dec    %eax
  800e2e:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (neg)
  800e31:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800e35:	74 3d                	je     800e74 <ltostr+0xe2>
		start = 1 ;
  800e37:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	while(start<end)
  800e3e:	eb 34                	jmp    800e74 <ltostr+0xe2>
	{
		char tmp = str[start] ;
  800e40:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e43:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e46:	01 d0                	add    %edx,%eax
  800e48:	8a 00                	mov    (%eax),%al
  800e4a:	88 45 eb             	mov    %al,-0x15(%ebp)
		str[start] = str[end] ;
  800e4d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e50:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e53:	01 c2                	add    %eax,%edx
  800e55:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  800e58:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e5b:	01 c8                	add    %ecx,%eax
  800e5d:	8a 00                	mov    (%eax),%al
  800e5f:	88 02                	mov    %al,(%edx)
		str[end] = tmp;
  800e61:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e64:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e67:	01 c2                	add    %eax,%edx
  800e69:	8a 45 eb             	mov    -0x15(%ebp),%al
  800e6c:	88 02                	mov    %al,(%edx)
		start++ ;
  800e6e:	ff 45 f4             	incl   -0xc(%ebp)
		end-- ;
  800e71:	ff 4d f0             	decl   -0x10(%ebp)
	//reverse the string
	int start = 0 ;
	int end = s-1 ;
	if (neg)
		start = 1 ;
	while(start<end)
  800e74:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e77:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800e7a:	7c c4                	jl     800e40 <ltostr+0xae>
		str[end] = tmp;
		start++ ;
		end-- ;
	}

	str[s] = 0 ;
  800e7c:	8b 55 f8             	mov    -0x8(%ebp),%edx
  800e7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e82:	01 d0                	add    %edx,%eax
  800e84:	c6 00 00             	movb   $0x0,(%eax)
	// we don't properly detect overflow!

}
  800e87:	90                   	nop
  800e88:	c9                   	leave  
  800e89:	c3                   	ret    

00800e8a <strcconcat>:

void
strcconcat(const char *str1, const char *str2, char *final)
{
  800e8a:	55                   	push   %ebp
  800e8b:	89 e5                	mov    %esp,%ebp
  800e8d:	83 ec 10             	sub    $0x10,%esp
	int len1 = strlen(str1);
  800e90:	ff 75 08             	pushl  0x8(%ebp)
  800e93:	e8 54 fa ff ff       	call   8008ec <strlen>
  800e98:	83 c4 04             	add    $0x4,%esp
  800e9b:	89 45 f4             	mov    %eax,-0xc(%ebp)
	int len2 = strlen(str2);
  800e9e:	ff 75 0c             	pushl  0xc(%ebp)
  800ea1:	e8 46 fa ff ff       	call   8008ec <strlen>
  800ea6:	83 c4 04             	add    $0x4,%esp
  800ea9:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int s = 0 ;
  800eac:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	for (s=0 ; s < len1 ; s++)
  800eb3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800eba:	eb 17                	jmp    800ed3 <strcconcat+0x49>
		final[s] = str1[s] ;
  800ebc:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800ebf:	8b 45 10             	mov    0x10(%ebp),%eax
  800ec2:	01 c2                	add    %eax,%edx
  800ec4:	8b 4d fc             	mov    -0x4(%ebp),%ecx
  800ec7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eca:	01 c8                	add    %ecx,%eax
  800ecc:	8a 00                	mov    (%eax),%al
  800ece:	88 02                	mov    %al,(%edx)
strcconcat(const char *str1, const char *str2, char *final)
{
	int len1 = strlen(str1);
	int len2 = strlen(str2);
	int s = 0 ;
	for (s=0 ; s < len1 ; s++)
  800ed0:	ff 45 fc             	incl   -0x4(%ebp)
  800ed3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800ed6:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  800ed9:	7c e1                	jl     800ebc <strcconcat+0x32>
		final[s] = str1[s] ;

	int i = 0 ;
  800edb:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
	for (i=0 ; i < len2 ; i++)
  800ee2:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  800ee9:	eb 1f                	jmp    800f0a <strcconcat+0x80>
		final[s++] = str2[i] ;
  800eeb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800eee:	8d 50 01             	lea    0x1(%eax),%edx
  800ef1:	89 55 fc             	mov    %edx,-0x4(%ebp)
  800ef4:	89 c2                	mov    %eax,%edx
  800ef6:	8b 45 10             	mov    0x10(%ebp),%eax
  800ef9:	01 c2                	add    %eax,%edx
  800efb:	8b 4d f8             	mov    -0x8(%ebp),%ecx
  800efe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f01:	01 c8                	add    %ecx,%eax
  800f03:	8a 00                	mov    (%eax),%al
  800f05:	88 02                	mov    %al,(%edx)
	int s = 0 ;
	for (s=0 ; s < len1 ; s++)
		final[s] = str1[s] ;

	int i = 0 ;
	for (i=0 ; i < len2 ; i++)
  800f07:	ff 45 f8             	incl   -0x8(%ebp)
  800f0a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800f0d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800f10:	7c d9                	jl     800eeb <strcconcat+0x61>
		final[s++] = str2[i] ;

	final[s] = 0;
  800f12:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800f15:	8b 45 10             	mov    0x10(%ebp),%eax
  800f18:	01 d0                	add    %edx,%eax
  800f1a:	c6 00 00             	movb   $0x0,(%eax)
}
  800f1d:	90                   	nop
  800f1e:	c9                   	leave  
  800f1f:	c3                   	ret    

00800f20 <strsplit>:
int strsplit(char *string, char *SPLIT_CHARS, char **argv, int * argc)
{
  800f20:	55                   	push   %ebp
  800f21:	89 e5                	mov    %esp,%ebp
	// Parse the command string into splitchars-separated arguments
	*argc = 0;
  800f23:	8b 45 14             	mov    0x14(%ebp),%eax
  800f26:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	(argv)[*argc] = 0;
  800f2c:	8b 45 14             	mov    0x14(%ebp),%eax
  800f2f:	8b 00                	mov    (%eax),%eax
  800f31:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800f38:	8b 45 10             	mov    0x10(%ebp),%eax
  800f3b:	01 d0                	add    %edx,%eax
  800f3d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	while (1)
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
  800f43:	eb 0c                	jmp    800f51 <strsplit+0x31>
			*string++ = 0;
  800f45:	8b 45 08             	mov    0x8(%ebp),%eax
  800f48:	8d 50 01             	lea    0x1(%eax),%edx
  800f4b:	89 55 08             	mov    %edx,0x8(%ebp)
  800f4e:	c6 00 00             	movb   $0x0,(%eax)
	*argc = 0;
	(argv)[*argc] = 0;
	while (1)
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
  800f51:	8b 45 08             	mov    0x8(%ebp),%eax
  800f54:	8a 00                	mov    (%eax),%al
  800f56:	84 c0                	test   %al,%al
  800f58:	74 18                	je     800f72 <strsplit+0x52>
  800f5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f5d:	8a 00                	mov    (%eax),%al
  800f5f:	0f be c0             	movsbl %al,%eax
  800f62:	50                   	push   %eax
  800f63:	ff 75 0c             	pushl  0xc(%ebp)
  800f66:	e8 13 fb ff ff       	call   800a7e <strchr>
  800f6b:	83 c4 08             	add    $0x8,%esp
  800f6e:	85 c0                	test   %eax,%eax
  800f70:	75 d3                	jne    800f45 <strsplit+0x25>
			*string++ = 0;

		//if the command string is finished, then break the loop
		if (*string == 0)
  800f72:	8b 45 08             	mov    0x8(%ebp),%eax
  800f75:	8a 00                	mov    (%eax),%al
  800f77:	84 c0                	test   %al,%al
  800f79:	74 5a                	je     800fd5 <strsplit+0xb5>
			break;

		//check current number of arguments
		if (*argc == MAX_ARGUMENTS-1)
  800f7b:	8b 45 14             	mov    0x14(%ebp),%eax
  800f7e:	8b 00                	mov    (%eax),%eax
  800f80:	83 f8 0f             	cmp    $0xf,%eax
  800f83:	75 07                	jne    800f8c <strsplit+0x6c>
		{
			return 0;
  800f85:	b8 00 00 00 00       	mov    $0x0,%eax
  800f8a:	eb 66                	jmp    800ff2 <strsplit+0xd2>
		}

		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
  800f8c:	8b 45 14             	mov    0x14(%ebp),%eax
  800f8f:	8b 00                	mov    (%eax),%eax
  800f91:	8d 48 01             	lea    0x1(%eax),%ecx
  800f94:	8b 55 14             	mov    0x14(%ebp),%edx
  800f97:	89 0a                	mov    %ecx,(%edx)
  800f99:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800fa0:	8b 45 10             	mov    0x10(%ebp),%eax
  800fa3:	01 c2                	add    %eax,%edx
  800fa5:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa8:	89 02                	mov    %eax,(%edx)
		while (*string && !strchr(SPLIT_CHARS, *string))
  800faa:	eb 03                	jmp    800faf <strsplit+0x8f>
			string++;
  800fac:	ff 45 08             	incl   0x8(%ebp)
			return 0;
		}

		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
		while (*string && !strchr(SPLIT_CHARS, *string))
  800faf:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb2:	8a 00                	mov    (%eax),%al
  800fb4:	84 c0                	test   %al,%al
  800fb6:	74 8b                	je     800f43 <strsplit+0x23>
  800fb8:	8b 45 08             	mov    0x8(%ebp),%eax
  800fbb:	8a 00                	mov    (%eax),%al
  800fbd:	0f be c0             	movsbl %al,%eax
  800fc0:	50                   	push   %eax
  800fc1:	ff 75 0c             	pushl  0xc(%ebp)
  800fc4:	e8 b5 fa ff ff       	call   800a7e <strchr>
  800fc9:	83 c4 08             	add    $0x8,%esp
  800fcc:	85 c0                	test   %eax,%eax
  800fce:	74 dc                	je     800fac <strsplit+0x8c>
			string++;
	}
  800fd0:	e9 6e ff ff ff       	jmp    800f43 <strsplit+0x23>
		while (*string && strchr(SPLIT_CHARS, *string))
			*string++ = 0;

		//if the command string is finished, then break the loop
		if (*string == 0)
			break;
  800fd5:	90                   	nop
		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
		while (*string && !strchr(SPLIT_CHARS, *string))
			string++;
	}
	(argv)[*argc] = 0;
  800fd6:	8b 45 14             	mov    0x14(%ebp),%eax
  800fd9:	8b 00                	mov    (%eax),%eax
  800fdb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800fe2:	8b 45 10             	mov    0x10(%ebp),%eax
  800fe5:	01 d0                	add    %edx,%eax
  800fe7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return 1 ;
  800fed:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800ff2:	c9                   	leave  
  800ff3:	c3                   	ret    

00800ff4 <str2lower>:


/*2024*/
char* str2lower(char *dst, const char *src)
{
  800ff4:	55                   	push   %ebp
  800ff5:	89 e5                	mov    %esp,%ebp
  800ff7:	83 ec 20             	sub    $0x20,%esp
	//TODO: [PROJECT'23.MS1 - #1] [1] PLAY WITH CODE! - str2lower
	//Comment the following line before start coding...
	//panic("process_command is not implemented yet");
	long long size = strlen(src);
  800ffa:	ff 75 0c             	pushl  0xc(%ebp)
  800ffd:	e8 ea f8 ff ff       	call   8008ec <strlen>
  801002:	83 c4 04             	add    $0x4,%esp
  801005:	99                   	cltd   
  801006:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801009:	89 55 f4             	mov    %edx,-0xc(%ebp)
	for(long long i=0;i<size;i++)
  80100c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  801013:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80101a:	eb 57                	jmp    801073 <str2lower+0x7f>
	{
		if(src[i] >=65 && src[i] <=90)
  80101c:	8b 55 f8             	mov    -0x8(%ebp),%edx
  80101f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801022:	01 d0                	add    %edx,%eax
  801024:	8a 00                	mov    (%eax),%al
  801026:	3c 40                	cmp    $0x40,%al
  801028:	7e 2d                	jle    801057 <str2lower+0x63>
  80102a:	8b 55 f8             	mov    -0x8(%ebp),%edx
  80102d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801030:	01 d0                	add    %edx,%eax
  801032:	8a 00                	mov    (%eax),%al
  801034:	3c 5a                	cmp    $0x5a,%al
  801036:	7f 1f                	jg     801057 <str2lower+0x63>
		{
			char temp = src[i] + 32;
  801038:	8b 55 f8             	mov    -0x8(%ebp),%edx
  80103b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80103e:	01 d0                	add    %edx,%eax
  801040:	8a 00                	mov    (%eax),%al
  801042:	83 c0 20             	add    $0x20,%eax
  801045:	88 45 ef             	mov    %al,-0x11(%ebp)
			dst[i] = temp;
  801048:	8b 55 f8             	mov    -0x8(%ebp),%edx
  80104b:	8b 45 08             	mov    0x8(%ebp),%eax
  80104e:	01 c2                	add    %eax,%edx
  801050:	8a 45 ef             	mov    -0x11(%ebp),%al
  801053:	88 02                	mov    %al,(%edx)
	//panic("process_command is not implemented yet");
	long long size = strlen(src);
	for(long long i=0;i<size;i++)
	{
		if(src[i] >=65 && src[i] <=90)
		{
  801055:	eb 14                	jmp    80106b <str2lower+0x77>
			char temp = src[i] + 32;
			dst[i] = temp;
		}
		else
		{
			dst[i] = src[i];
  801057:	8b 55 f8             	mov    -0x8(%ebp),%edx
  80105a:	8b 45 08             	mov    0x8(%ebp),%eax
  80105d:	01 c2                	add    %eax,%edx
  80105f:	8b 4d f8             	mov    -0x8(%ebp),%ecx
  801062:	8b 45 0c             	mov    0xc(%ebp),%eax
  801065:	01 c8                	add    %ecx,%eax
  801067:	8a 00                	mov    (%eax),%al
  801069:	88 02                	mov    %al,(%edx)
{
	//TODO: [PROJECT'23.MS1 - #1] [1] PLAY WITH CODE! - str2lower
	//Comment the following line before start coding...
	//panic("process_command is not implemented yet");
	long long size = strlen(src);
	for(long long i=0;i<size;i++)
  80106b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  80106f:	83 55 fc 00          	adcl   $0x0,-0x4(%ebp)
  801073:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801076:	8b 55 fc             	mov    -0x4(%ebp),%edx
  801079:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  80107c:	7c 9e                	jl     80101c <str2lower+0x28>
  80107e:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  801081:	7f 05                	jg     801088 <str2lower+0x94>
  801083:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  801086:	72 94                	jb     80101c <str2lower+0x28>
		else
		{
			dst[i] = src[i];
		}
	}
	return dst;
  801088:	8b 45 08             	mov    0x8(%ebp),%eax
}
  80108b:	c9                   	leave  
  80108c:	c3                   	ret    

0080108d <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline uint32
syscall(int num, uint32 a1, uint32 a2, uint32 a3, uint32 a4, uint32 a5)
{
  80108d:	55                   	push   %ebp
  80108e:	89 e5                	mov    %esp,%ebp
  801090:	57                   	push   %edi
  801091:	56                   	push   %esi
  801092:	53                   	push   %ebx
  801093:	83 ec 10             	sub    $0x10,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801096:	8b 45 08             	mov    0x8(%ebp),%eax
  801099:	8b 55 0c             	mov    0xc(%ebp),%edx
  80109c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80109f:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8010a2:	8b 7d 18             	mov    0x18(%ebp),%edi
  8010a5:	8b 75 1c             	mov    0x1c(%ebp),%esi
  8010a8:	cd 30                	int    $0x30
  8010aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	return ret;
  8010ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  8010b0:	83 c4 10             	add    $0x10,%esp
  8010b3:	5b                   	pop    %ebx
  8010b4:	5e                   	pop    %esi
  8010b5:	5f                   	pop    %edi
  8010b6:	5d                   	pop    %ebp
  8010b7:	c3                   	ret    

008010b8 <sys_cputs>:

void
sys_cputs(const char *s, uint32 len, uint8 printProgName)
{
  8010b8:	55                   	push   %ebp
  8010b9:	89 e5                	mov    %esp,%ebp
  8010bb:	83 ec 04             	sub    $0x4,%esp
  8010be:	8b 45 10             	mov    0x10(%ebp),%eax
  8010c1:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_cputs, (uint32) s, len, (uint32)printProgName, 0, 0);
  8010c4:	0f b6 55 fc          	movzbl -0x4(%ebp),%edx
  8010c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8010cb:	6a 00                	push   $0x0
  8010cd:	6a 00                	push   $0x0
  8010cf:	52                   	push   %edx
  8010d0:	ff 75 0c             	pushl  0xc(%ebp)
  8010d3:	50                   	push   %eax
  8010d4:	6a 00                	push   $0x0
  8010d6:	e8 b2 ff ff ff       	call   80108d <syscall>
  8010db:	83 c4 18             	add    $0x18,%esp
}
  8010de:	90                   	nop
  8010df:	c9                   	leave  
  8010e0:	c3                   	ret    

008010e1 <sys_cgetc>:

int
sys_cgetc(void)
{
  8010e1:	55                   	push   %ebp
  8010e2:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0);
  8010e4:	6a 00                	push   $0x0
  8010e6:	6a 00                	push   $0x0
  8010e8:	6a 00                	push   $0x0
  8010ea:	6a 00                	push   $0x0
  8010ec:	6a 00                	push   $0x0
  8010ee:	6a 01                	push   $0x1
  8010f0:	e8 98 ff ff ff       	call   80108d <syscall>
  8010f5:	83 c4 18             	add    $0x18,%esp
}
  8010f8:	c9                   	leave  
  8010f9:	c3                   	ret    

008010fa <__sys_allocate_page>:

int __sys_allocate_page(void *va, int perm)
{
  8010fa:	55                   	push   %ebp
  8010fb:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_allocate_page, (uint32) va, perm, 0 , 0, 0);
  8010fd:	8b 55 0c             	mov    0xc(%ebp),%edx
  801100:	8b 45 08             	mov    0x8(%ebp),%eax
  801103:	6a 00                	push   $0x0
  801105:	6a 00                	push   $0x0
  801107:	6a 00                	push   $0x0
  801109:	52                   	push   %edx
  80110a:	50                   	push   %eax
  80110b:	6a 05                	push   $0x5
  80110d:	e8 7b ff ff ff       	call   80108d <syscall>
  801112:	83 c4 18             	add    $0x18,%esp
}
  801115:	c9                   	leave  
  801116:	c3                   	ret    

00801117 <__sys_map_frame>:

int __sys_map_frame(int32 srcenv, void *srcva, int32 dstenv, void *dstva, int perm)
{
  801117:	55                   	push   %ebp
  801118:	89 e5                	mov    %esp,%ebp
  80111a:	56                   	push   %esi
  80111b:	53                   	push   %ebx
	return syscall(SYS_map_frame, srcenv, (uint32) srcva, dstenv, (uint32) dstva, perm);
  80111c:	8b 75 18             	mov    0x18(%ebp),%esi
  80111f:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801122:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801125:	8b 55 0c             	mov    0xc(%ebp),%edx
  801128:	8b 45 08             	mov    0x8(%ebp),%eax
  80112b:	56                   	push   %esi
  80112c:	53                   	push   %ebx
  80112d:	51                   	push   %ecx
  80112e:	52                   	push   %edx
  80112f:	50                   	push   %eax
  801130:	6a 06                	push   $0x6
  801132:	e8 56 ff ff ff       	call   80108d <syscall>
  801137:	83 c4 18             	add    $0x18,%esp
}
  80113a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80113d:	5b                   	pop    %ebx
  80113e:	5e                   	pop    %esi
  80113f:	5d                   	pop    %ebp
  801140:	c3                   	ret    

00801141 <__sys_unmap_frame>:

int __sys_unmap_frame(int32 envid, void *va)
{
  801141:	55                   	push   %ebp
  801142:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_unmap_frame, envid, (uint32) va, 0, 0, 0);
  801144:	8b 55 0c             	mov    0xc(%ebp),%edx
  801147:	8b 45 08             	mov    0x8(%ebp),%eax
  80114a:	6a 00                	push   $0x0
  80114c:	6a 00                	push   $0x0
  80114e:	6a 00                	push   $0x0
  801150:	52                   	push   %edx
  801151:	50                   	push   %eax
  801152:	6a 07                	push   $0x7
  801154:	e8 34 ff ff ff       	call   80108d <syscall>
  801159:	83 c4 18             	add    $0x18,%esp
}
  80115c:	c9                   	leave  
  80115d:	c3                   	ret    

0080115e <sys_calculate_required_frames>:

uint32 sys_calculate_required_frames(uint32 start_virtual_address, uint32 size)
{
  80115e:	55                   	push   %ebp
  80115f:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_req_frames, start_virtual_address, (uint32) size, 0, 0, 0);
  801161:	6a 00                	push   $0x0
  801163:	6a 00                	push   $0x0
  801165:	6a 00                	push   $0x0
  801167:	ff 75 0c             	pushl  0xc(%ebp)
  80116a:	ff 75 08             	pushl  0x8(%ebp)
  80116d:	6a 08                	push   $0x8
  80116f:	e8 19 ff ff ff       	call   80108d <syscall>
  801174:	83 c4 18             	add    $0x18,%esp
}
  801177:	c9                   	leave  
  801178:	c3                   	ret    

00801179 <sys_calculate_free_frames>:

uint32 sys_calculate_free_frames()
{
  801179:	55                   	push   %ebp
  80117a:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_free_frames, 0, 0, 0, 0, 0);
  80117c:	6a 00                	push   $0x0
  80117e:	6a 00                	push   $0x0
  801180:	6a 00                	push   $0x0
  801182:	6a 00                	push   $0x0
  801184:	6a 00                	push   $0x0
  801186:	6a 09                	push   $0x9
  801188:	e8 00 ff ff ff       	call   80108d <syscall>
  80118d:	83 c4 18             	add    $0x18,%esp
}
  801190:	c9                   	leave  
  801191:	c3                   	ret    

00801192 <sys_calculate_modified_frames>:
uint32 sys_calculate_modified_frames()
{
  801192:	55                   	push   %ebp
  801193:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_modified_frames, 0, 0, 0, 0, 0);
  801195:	6a 00                	push   $0x0
  801197:	6a 00                	push   $0x0
  801199:	6a 00                	push   $0x0
  80119b:	6a 00                	push   $0x0
  80119d:	6a 00                	push   $0x0
  80119f:	6a 0a                	push   $0xa
  8011a1:	e8 e7 fe ff ff       	call   80108d <syscall>
  8011a6:	83 c4 18             	add    $0x18,%esp
}
  8011a9:	c9                   	leave  
  8011aa:	c3                   	ret    

008011ab <sys_calculate_notmod_frames>:

uint32 sys_calculate_notmod_frames()
{
  8011ab:	55                   	push   %ebp
  8011ac:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_notmod_frames, 0, 0, 0, 0, 0);
  8011ae:	6a 00                	push   $0x0
  8011b0:	6a 00                	push   $0x0
  8011b2:	6a 00                	push   $0x0
  8011b4:	6a 00                	push   $0x0
  8011b6:	6a 00                	push   $0x0
  8011b8:	6a 0b                	push   $0xb
  8011ba:	e8 ce fe ff ff       	call   80108d <syscall>
  8011bf:	83 c4 18             	add    $0x18,%esp
}
  8011c2:	c9                   	leave  
  8011c3:	c3                   	ret    

008011c4 <sys_pf_calculate_allocated_pages>:



int sys_pf_calculate_allocated_pages()
{
  8011c4:	55                   	push   %ebp
  8011c5:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_pf_calc_allocated_pages, 0,0,0,0,0);
  8011c7:	6a 00                	push   $0x0
  8011c9:	6a 00                	push   $0x0
  8011cb:	6a 00                	push   $0x0
  8011cd:	6a 00                	push   $0x0
  8011cf:	6a 00                	push   $0x0
  8011d1:	6a 0c                	push   $0xc
  8011d3:	e8 b5 fe ff ff       	call   80108d <syscall>
  8011d8:	83 c4 18             	add    $0x18,%esp
}
  8011db:	c9                   	leave  
  8011dc:	c3                   	ret    

008011dd <sys_calculate_pages_tobe_removed_ready_exit>:

int sys_calculate_pages_tobe_removed_ready_exit(uint32 WS_or_MEMORY_flag)
{
  8011dd:	55                   	push   %ebp
  8011de:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calculate_pages_tobe_removed_ready_exit, WS_or_MEMORY_flag,0,0,0,0);
  8011e0:	6a 00                	push   $0x0
  8011e2:	6a 00                	push   $0x0
  8011e4:	6a 00                	push   $0x0
  8011e6:	6a 00                	push   $0x0
  8011e8:	ff 75 08             	pushl  0x8(%ebp)
  8011eb:	6a 0d                	push   $0xd
  8011ed:	e8 9b fe ff ff       	call   80108d <syscall>
  8011f2:	83 c4 18             	add    $0x18,%esp
}
  8011f5:	c9                   	leave  
  8011f6:	c3                   	ret    

008011f7 <sys_scarce_memory>:

void sys_scarce_memory()
{
  8011f7:	55                   	push   %ebp
  8011f8:	89 e5                	mov    %esp,%ebp
	syscall(SYS_scarce_memory,0,0,0,0,0);
  8011fa:	6a 00                	push   $0x0
  8011fc:	6a 00                	push   $0x0
  8011fe:	6a 00                	push   $0x0
  801200:	6a 00                	push   $0x0
  801202:	6a 00                	push   $0x0
  801204:	6a 0e                	push   $0xe
  801206:	e8 82 fe ff ff       	call   80108d <syscall>
  80120b:	83 c4 18             	add    $0x18,%esp
}
  80120e:	90                   	nop
  80120f:	c9                   	leave  
  801210:	c3                   	ret    

00801211 <sys_disable_interrupt>:

//NEW !! 2012...
void
sys_disable_interrupt()
{
  801211:	55                   	push   %ebp
  801212:	89 e5                	mov    %esp,%ebp
	syscall(SYS_disableINTR,0, 0, 0, 0, 0);
  801214:	6a 00                	push   $0x0
  801216:	6a 00                	push   $0x0
  801218:	6a 00                	push   $0x0
  80121a:	6a 00                	push   $0x0
  80121c:	6a 00                	push   $0x0
  80121e:	6a 11                	push   $0x11
  801220:	e8 68 fe ff ff       	call   80108d <syscall>
  801225:	83 c4 18             	add    $0x18,%esp
}
  801228:	90                   	nop
  801229:	c9                   	leave  
  80122a:	c3                   	ret    

0080122b <sys_enable_interrupt>:


void
sys_enable_interrupt()
{
  80122b:	55                   	push   %ebp
  80122c:	89 e5                	mov    %esp,%ebp
	syscall(SYS_enableINTR,0, 0, 0, 0, 0);
  80122e:	6a 00                	push   $0x0
  801230:	6a 00                	push   $0x0
  801232:	6a 00                	push   $0x0
  801234:	6a 00                	push   $0x0
  801236:	6a 00                	push   $0x0
  801238:	6a 12                	push   $0x12
  80123a:	e8 4e fe ff ff       	call   80108d <syscall>
  80123f:	83 c4 18             	add    $0x18,%esp
}
  801242:	90                   	nop
  801243:	c9                   	leave  
  801244:	c3                   	ret    

00801245 <sys_cputc>:


void
sys_cputc(const char c)
{
  801245:	55                   	push   %ebp
  801246:	89 e5                	mov    %esp,%ebp
  801248:	83 ec 04             	sub    $0x4,%esp
  80124b:	8b 45 08             	mov    0x8(%ebp),%eax
  80124e:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_cputc, (uint32) c, 0, 0, 0, 0);
  801251:	0f be 45 fc          	movsbl -0x4(%ebp),%eax
  801255:	6a 00                	push   $0x0
  801257:	6a 00                	push   $0x0
  801259:	6a 00                	push   $0x0
  80125b:	6a 00                	push   $0x0
  80125d:	50                   	push   %eax
  80125e:	6a 13                	push   $0x13
  801260:	e8 28 fe ff ff       	call   80108d <syscall>
  801265:	83 c4 18             	add    $0x18,%esp
}
  801268:	90                   	nop
  801269:	c9                   	leave  
  80126a:	c3                   	ret    

0080126b <sys_clear_ffl>:


//NEW'12: BONUS2 Testing
void
sys_clear_ffl()
{
  80126b:	55                   	push   %ebp
  80126c:	89 e5                	mov    %esp,%ebp
	syscall(SYS_clearFFL,0, 0, 0, 0, 0);
  80126e:	6a 00                	push   $0x0
  801270:	6a 00                	push   $0x0
  801272:	6a 00                	push   $0x0
  801274:	6a 00                	push   $0x0
  801276:	6a 00                	push   $0x0
  801278:	6a 14                	push   $0x14
  80127a:	e8 0e fe ff ff       	call   80108d <syscall>
  80127f:	83 c4 18             	add    $0x18,%esp
}
  801282:	90                   	nop
  801283:	c9                   	leave  
  801284:	c3                   	ret    

00801285 <sys_createSemaphore>:

int
sys_createSemaphore(char* semaphoreName, uint32 initialValue)
{
  801285:	55                   	push   %ebp
  801286:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_create_semaphore,(uint32)semaphoreName, (uint32)initialValue, 0, 0, 0);
  801288:	8b 45 08             	mov    0x8(%ebp),%eax
  80128b:	6a 00                	push   $0x0
  80128d:	6a 00                	push   $0x0
  80128f:	6a 00                	push   $0x0
  801291:	ff 75 0c             	pushl  0xc(%ebp)
  801294:	50                   	push   %eax
  801295:	6a 15                	push   $0x15
  801297:	e8 f1 fd ff ff       	call   80108d <syscall>
  80129c:	83 c4 18             	add    $0x18,%esp
}
  80129f:	c9                   	leave  
  8012a0:	c3                   	ret    

008012a1 <sys_getSemaphoreValue>:

int
sys_getSemaphoreValue(int32 ownerEnvID, char* semaphoreName)
{
  8012a1:	55                   	push   %ebp
  8012a2:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_get_semaphore_value,(uint32) ownerEnvID, (uint32)semaphoreName, 0, 0, 0);
  8012a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8012aa:	6a 00                	push   $0x0
  8012ac:	6a 00                	push   $0x0
  8012ae:	6a 00                	push   $0x0
  8012b0:	52                   	push   %edx
  8012b1:	50                   	push   %eax
  8012b2:	6a 18                	push   $0x18
  8012b4:	e8 d4 fd ff ff       	call   80108d <syscall>
  8012b9:	83 c4 18             	add    $0x18,%esp
}
  8012bc:	c9                   	leave  
  8012bd:	c3                   	ret    

008012be <sys_waitSemaphore>:

void
sys_waitSemaphore(int32 ownerEnvID, char* semaphoreName)
{
  8012be:	55                   	push   %ebp
  8012bf:	89 e5                	mov    %esp,%ebp
	syscall(SYS_wait_semaphore,(uint32) ownerEnvID, (uint32)semaphoreName, 0, 0, 0);
  8012c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c7:	6a 00                	push   $0x0
  8012c9:	6a 00                	push   $0x0
  8012cb:	6a 00                	push   $0x0
  8012cd:	52                   	push   %edx
  8012ce:	50                   	push   %eax
  8012cf:	6a 16                	push   $0x16
  8012d1:	e8 b7 fd ff ff       	call   80108d <syscall>
  8012d6:	83 c4 18             	add    $0x18,%esp
}
  8012d9:	90                   	nop
  8012da:	c9                   	leave  
  8012db:	c3                   	ret    

008012dc <sys_signalSemaphore>:

void
sys_signalSemaphore(int32 ownerEnvID, char* semaphoreName)
{
  8012dc:	55                   	push   %ebp
  8012dd:	89 e5                	mov    %esp,%ebp
	syscall(SYS_signal_semaphore,(uint32) ownerEnvID, (uint32)semaphoreName, 0, 0, 0);
  8012df:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8012e5:	6a 00                	push   $0x0
  8012e7:	6a 00                	push   $0x0
  8012e9:	6a 00                	push   $0x0
  8012eb:	52                   	push   %edx
  8012ec:	50                   	push   %eax
  8012ed:	6a 17                	push   $0x17
  8012ef:	e8 99 fd ff ff       	call   80108d <syscall>
  8012f4:	83 c4 18             	add    $0x18,%esp
}
  8012f7:	90                   	nop
  8012f8:	c9                   	leave  
  8012f9:	c3                   	ret    

008012fa <sys_createSharedObject>:

int
sys_createSharedObject(char* shareName, uint32 size, uint8 isWritable, void* virtual_address)
{
  8012fa:	55                   	push   %ebp
  8012fb:	89 e5                	mov    %esp,%ebp
  8012fd:	83 ec 04             	sub    $0x4,%esp
  801300:	8b 45 10             	mov    0x10(%ebp),%eax
  801303:	88 45 fc             	mov    %al,-0x4(%ebp)
	return syscall(SYS_create_shared_object,(uint32)shareName, (uint32)size, isWritable, (uint32)virtual_address,  0);
  801306:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801309:	0f b6 55 fc          	movzbl -0x4(%ebp),%edx
  80130d:	8b 45 08             	mov    0x8(%ebp),%eax
  801310:	6a 00                	push   $0x0
  801312:	51                   	push   %ecx
  801313:	52                   	push   %edx
  801314:	ff 75 0c             	pushl  0xc(%ebp)
  801317:	50                   	push   %eax
  801318:	6a 19                	push   $0x19
  80131a:	e8 6e fd ff ff       	call   80108d <syscall>
  80131f:	83 c4 18             	add    $0x18,%esp
}
  801322:	c9                   	leave  
  801323:	c3                   	ret    

00801324 <sys_getSizeOfSharedObject>:

//2017:
int
sys_getSizeOfSharedObject(int32 ownerID, char* shareName)
{
  801324:	55                   	push   %ebp
  801325:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_get_size_of_shared_object,(uint32) ownerID, (uint32)shareName, 0, 0, 0);
  801327:	8b 55 0c             	mov    0xc(%ebp),%edx
  80132a:	8b 45 08             	mov    0x8(%ebp),%eax
  80132d:	6a 00                	push   $0x0
  80132f:	6a 00                	push   $0x0
  801331:	6a 00                	push   $0x0
  801333:	52                   	push   %edx
  801334:	50                   	push   %eax
  801335:	6a 1a                	push   $0x1a
  801337:	e8 51 fd ff ff       	call   80108d <syscall>
  80133c:	83 c4 18             	add    $0x18,%esp
}
  80133f:	c9                   	leave  
  801340:	c3                   	ret    

00801341 <sys_getSharedObject>:
//==========

int
sys_getSharedObject(int32 ownerID, char* shareName, void* virtual_address)
{
  801341:	55                   	push   %ebp
  801342:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_get_shared_object,(uint32) ownerID, (uint32)shareName, (uint32)virtual_address, 0, 0);
  801344:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801347:	8b 55 0c             	mov    0xc(%ebp),%edx
  80134a:	8b 45 08             	mov    0x8(%ebp),%eax
  80134d:	6a 00                	push   $0x0
  80134f:	6a 00                	push   $0x0
  801351:	51                   	push   %ecx
  801352:	52                   	push   %edx
  801353:	50                   	push   %eax
  801354:	6a 1b                	push   $0x1b
  801356:	e8 32 fd ff ff       	call   80108d <syscall>
  80135b:	83 c4 18             	add    $0x18,%esp
}
  80135e:	c9                   	leave  
  80135f:	c3                   	ret    

00801360 <sys_freeSharedObject>:

int
sys_freeSharedObject(int32 sharedObjectID, void *startVA)
{
  801360:	55                   	push   %ebp
  801361:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_free_shared_object,(uint32) sharedObjectID, (uint32) startVA, 0, 0, 0);
  801363:	8b 55 0c             	mov    0xc(%ebp),%edx
  801366:	8b 45 08             	mov    0x8(%ebp),%eax
  801369:	6a 00                	push   $0x0
  80136b:	6a 00                	push   $0x0
  80136d:	6a 00                	push   $0x0
  80136f:	52                   	push   %edx
  801370:	50                   	push   %eax
  801371:	6a 1c                	push   $0x1c
  801373:	e8 15 fd ff ff       	call   80108d <syscall>
  801378:	83 c4 18             	add    $0x18,%esp
}
  80137b:	c9                   	leave  
  80137c:	c3                   	ret    

0080137d <sys_getMaxShares>:

uint32 	sys_getMaxShares()
{
  80137d:	55                   	push   %ebp
  80137e:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_get_max_shares,0, 0, 0, 0, 0);
  801380:	6a 00                	push   $0x0
  801382:	6a 00                	push   $0x0
  801384:	6a 00                	push   $0x0
  801386:	6a 00                	push   $0x0
  801388:	6a 00                	push   $0x0
  80138a:	6a 1d                	push   $0x1d
  80138c:	e8 fc fc ff ff       	call   80108d <syscall>
  801391:	83 c4 18             	add    $0x18,%esp
}
  801394:	c9                   	leave  
  801395:	c3                   	ret    

00801396 <sys_create_env>:

int sys_create_env(char* programName, unsigned int page_WS_size,unsigned int LRU_second_list_size,unsigned int percent_WS_pages_to_remove)
{
  801396:	55                   	push   %ebp
  801397:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_create_env,(uint32)programName, (uint32)page_WS_size,(uint32)LRU_second_list_size, (uint32)percent_WS_pages_to_remove, 0);
  801399:	8b 45 08             	mov    0x8(%ebp),%eax
  80139c:	6a 00                	push   $0x0
  80139e:	ff 75 14             	pushl  0x14(%ebp)
  8013a1:	ff 75 10             	pushl  0x10(%ebp)
  8013a4:	ff 75 0c             	pushl  0xc(%ebp)
  8013a7:	50                   	push   %eax
  8013a8:	6a 1e                	push   $0x1e
  8013aa:	e8 de fc ff ff       	call   80108d <syscall>
  8013af:	83 c4 18             	add    $0x18,%esp
}
  8013b2:	c9                   	leave  
  8013b3:	c3                   	ret    

008013b4 <sys_run_env>:

void
sys_run_env(int32 envId)
{
  8013b4:	55                   	push   %ebp
  8013b5:	89 e5                	mov    %esp,%ebp
	syscall(SYS_run_env, (int32)envId, 0, 0, 0, 0);
  8013b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ba:	6a 00                	push   $0x0
  8013bc:	6a 00                	push   $0x0
  8013be:	6a 00                	push   $0x0
  8013c0:	6a 00                	push   $0x0
  8013c2:	50                   	push   %eax
  8013c3:	6a 1f                	push   $0x1f
  8013c5:	e8 c3 fc ff ff       	call   80108d <syscall>
  8013ca:	83 c4 18             	add    $0x18,%esp
}
  8013cd:	90                   	nop
  8013ce:	c9                   	leave  
  8013cf:	c3                   	ret    

008013d0 <sys_destroy_env>:

int sys_destroy_env(int32  envid)
{
  8013d0:	55                   	push   %ebp
  8013d1:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_destroy_env, envid, 0, 0, 0, 0);
  8013d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d6:	6a 00                	push   $0x0
  8013d8:	6a 00                	push   $0x0
  8013da:	6a 00                	push   $0x0
  8013dc:	6a 00                	push   $0x0
  8013de:	50                   	push   %eax
  8013df:	6a 20                	push   $0x20
  8013e1:	e8 a7 fc ff ff       	call   80108d <syscall>
  8013e6:	83 c4 18             	add    $0x18,%esp
}
  8013e9:	c9                   	leave  
  8013ea:	c3                   	ret    

008013eb <sys_getenvid>:

int32 sys_getenvid(void)
{
  8013eb:	55                   	push   %ebp
  8013ec:	89 e5                	mov    %esp,%ebp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0);
  8013ee:	6a 00                	push   $0x0
  8013f0:	6a 00                	push   $0x0
  8013f2:	6a 00                	push   $0x0
  8013f4:	6a 00                	push   $0x0
  8013f6:	6a 00                	push   $0x0
  8013f8:	6a 02                	push   $0x2
  8013fa:	e8 8e fc ff ff       	call   80108d <syscall>
  8013ff:	83 c4 18             	add    $0x18,%esp
}
  801402:	c9                   	leave  
  801403:	c3                   	ret    

00801404 <sys_getenvindex>:

//2017
int32 sys_getenvindex(void)
{
  801404:	55                   	push   %ebp
  801405:	89 e5                	mov    %esp,%ebp
	 return syscall(SYS_getenvindex, 0, 0, 0, 0, 0);
  801407:	6a 00                	push   $0x0
  801409:	6a 00                	push   $0x0
  80140b:	6a 00                	push   $0x0
  80140d:	6a 00                	push   $0x0
  80140f:	6a 00                	push   $0x0
  801411:	6a 03                	push   $0x3
  801413:	e8 75 fc ff ff       	call   80108d <syscall>
  801418:	83 c4 18             	add    $0x18,%esp
}
  80141b:	c9                   	leave  
  80141c:	c3                   	ret    

0080141d <sys_getparentenvid>:

int32 sys_getparentenvid(void)
{
  80141d:	55                   	push   %ebp
  80141e:	89 e5                	mov    %esp,%ebp
	 return syscall(SYS_getparentenvid, 0, 0, 0, 0, 0);
  801420:	6a 00                	push   $0x0
  801422:	6a 00                	push   $0x0
  801424:	6a 00                	push   $0x0
  801426:	6a 00                	push   $0x0
  801428:	6a 00                	push   $0x0
  80142a:	6a 04                	push   $0x4
  80142c:	e8 5c fc ff ff       	call   80108d <syscall>
  801431:	83 c4 18             	add    $0x18,%esp
}
  801434:	c9                   	leave  
  801435:	c3                   	ret    

00801436 <sys_exit_env>:


void sys_exit_env(void)
{
  801436:	55                   	push   %ebp
  801437:	89 e5                	mov    %esp,%ebp
	syscall(SYS_exit_env, 0, 0, 0, 0, 0);
  801439:	6a 00                	push   $0x0
  80143b:	6a 00                	push   $0x0
  80143d:	6a 00                	push   $0x0
  80143f:	6a 00                	push   $0x0
  801441:	6a 00                	push   $0x0
  801443:	6a 21                	push   $0x21
  801445:	e8 43 fc ff ff       	call   80108d <syscall>
  80144a:	83 c4 18             	add    $0x18,%esp
}
  80144d:	90                   	nop
  80144e:	c9                   	leave  
  80144f:	c3                   	ret    

00801450 <sys_get_virtual_time>:


struct uint64
sys_get_virtual_time()
{
  801450:	55                   	push   %ebp
  801451:	89 e5                	mov    %esp,%ebp
  801453:	83 ec 10             	sub    $0x10,%esp
	struct uint64 result;
	syscall(SYS_get_virtual_time, (uint32)&(result.low), (uint32)&(result.hi), 0, 0, 0);
  801456:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801459:	8d 50 04             	lea    0x4(%eax),%edx
  80145c:	8d 45 f8             	lea    -0x8(%ebp),%eax
  80145f:	6a 00                	push   $0x0
  801461:	6a 00                	push   $0x0
  801463:	6a 00                	push   $0x0
  801465:	52                   	push   %edx
  801466:	50                   	push   %eax
  801467:	6a 22                	push   $0x22
  801469:	e8 1f fc ff ff       	call   80108d <syscall>
  80146e:	83 c4 18             	add    $0x18,%esp
	return result;
  801471:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801474:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801477:	8b 55 fc             	mov    -0x4(%ebp),%edx
  80147a:	89 01                	mov    %eax,(%ecx)
  80147c:	89 51 04             	mov    %edx,0x4(%ecx)
}
  80147f:	8b 45 08             	mov    0x8(%ebp),%eax
  801482:	c9                   	leave  
  801483:	c2 04 00             	ret    $0x4

00801486 <sys_move_user_mem>:

// 2014
void sys_move_user_mem(uint32 src_virtual_address, uint32 dst_virtual_address, uint32 size)
{
  801486:	55                   	push   %ebp
  801487:	89 e5                	mov    %esp,%ebp
	syscall(SYS_move_user_mem, src_virtual_address, dst_virtual_address, size, 0, 0);
  801489:	6a 00                	push   $0x0
  80148b:	6a 00                	push   $0x0
  80148d:	ff 75 10             	pushl  0x10(%ebp)
  801490:	ff 75 0c             	pushl  0xc(%ebp)
  801493:	ff 75 08             	pushl  0x8(%ebp)
  801496:	6a 10                	push   $0x10
  801498:	e8 f0 fb ff ff       	call   80108d <syscall>
  80149d:	83 c4 18             	add    $0x18,%esp
	return ;
  8014a0:	90                   	nop
}
  8014a1:	c9                   	leave  
  8014a2:	c3                   	ret    

008014a3 <sys_rcr2>:
uint32 sys_rcr2()
{
  8014a3:	55                   	push   %ebp
  8014a4:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_rcr2, 0, 0, 0, 0, 0);
  8014a6:	6a 00                	push   $0x0
  8014a8:	6a 00                	push   $0x0
  8014aa:	6a 00                	push   $0x0
  8014ac:	6a 00                	push   $0x0
  8014ae:	6a 00                	push   $0x0
  8014b0:	6a 23                	push   $0x23
  8014b2:	e8 d6 fb ff ff       	call   80108d <syscall>
  8014b7:	83 c4 18             	add    $0x18,%esp
}
  8014ba:	c9                   	leave  
  8014bb:	c3                   	ret    

008014bc <sys_bypassPageFault>:
void sys_bypassPageFault(uint8 instrLength)
{
  8014bc:	55                   	push   %ebp
  8014bd:	89 e5                	mov    %esp,%ebp
  8014bf:	83 ec 04             	sub    $0x4,%esp
  8014c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c5:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_bypassPageFault, instrLength, 0, 0, 0, 0);
  8014c8:	0f b6 45 fc          	movzbl -0x4(%ebp),%eax
  8014cc:	6a 00                	push   $0x0
  8014ce:	6a 00                	push   $0x0
  8014d0:	6a 00                	push   $0x0
  8014d2:	6a 00                	push   $0x0
  8014d4:	50                   	push   %eax
  8014d5:	6a 24                	push   $0x24
  8014d7:	e8 b1 fb ff ff       	call   80108d <syscall>
  8014dc:	83 c4 18             	add    $0x18,%esp
	return ;
  8014df:	90                   	nop
}
  8014e0:	c9                   	leave  
  8014e1:	c3                   	ret    

008014e2 <rsttst>:
void rsttst()
{
  8014e2:	55                   	push   %ebp
  8014e3:	89 e5                	mov    %esp,%ebp
	syscall(SYS_rsttst, 0, 0, 0, 0, 0);
  8014e5:	6a 00                	push   $0x0
  8014e7:	6a 00                	push   $0x0
  8014e9:	6a 00                	push   $0x0
  8014eb:	6a 00                	push   $0x0
  8014ed:	6a 00                	push   $0x0
  8014ef:	6a 26                	push   $0x26
  8014f1:	e8 97 fb ff ff       	call   80108d <syscall>
  8014f6:	83 c4 18             	add    $0x18,%esp
	return ;
  8014f9:	90                   	nop
}
  8014fa:	c9                   	leave  
  8014fb:	c3                   	ret    

008014fc <tst>:
void tst(uint32 n, uint32 v1, uint32 v2, char c, int inv)
{
  8014fc:	55                   	push   %ebp
  8014fd:	89 e5                	mov    %esp,%ebp
  8014ff:	83 ec 04             	sub    $0x4,%esp
  801502:	8b 45 14             	mov    0x14(%ebp),%eax
  801505:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_testNum, n, v1, v2, c, inv);
  801508:	8b 55 18             	mov    0x18(%ebp),%edx
  80150b:	0f be 45 fc          	movsbl -0x4(%ebp),%eax
  80150f:	52                   	push   %edx
  801510:	50                   	push   %eax
  801511:	ff 75 10             	pushl  0x10(%ebp)
  801514:	ff 75 0c             	pushl  0xc(%ebp)
  801517:	ff 75 08             	pushl  0x8(%ebp)
  80151a:	6a 25                	push   $0x25
  80151c:	e8 6c fb ff ff       	call   80108d <syscall>
  801521:	83 c4 18             	add    $0x18,%esp
	return ;
  801524:	90                   	nop
}
  801525:	c9                   	leave  
  801526:	c3                   	ret    

00801527 <chktst>:
void chktst(uint32 n)
{
  801527:	55                   	push   %ebp
  801528:	89 e5                	mov    %esp,%ebp
	syscall(SYS_chktst, n, 0, 0, 0, 0);
  80152a:	6a 00                	push   $0x0
  80152c:	6a 00                	push   $0x0
  80152e:	6a 00                	push   $0x0
  801530:	6a 00                	push   $0x0
  801532:	ff 75 08             	pushl  0x8(%ebp)
  801535:	6a 27                	push   $0x27
  801537:	e8 51 fb ff ff       	call   80108d <syscall>
  80153c:	83 c4 18             	add    $0x18,%esp
	return ;
  80153f:	90                   	nop
}
  801540:	c9                   	leave  
  801541:	c3                   	ret    

00801542 <inctst>:

void inctst()
{
  801542:	55                   	push   %ebp
  801543:	89 e5                	mov    %esp,%ebp
	syscall(SYS_inctst, 0, 0, 0, 0, 0);
  801545:	6a 00                	push   $0x0
  801547:	6a 00                	push   $0x0
  801549:	6a 00                	push   $0x0
  80154b:	6a 00                	push   $0x0
  80154d:	6a 00                	push   $0x0
  80154f:	6a 28                	push   $0x28
  801551:	e8 37 fb ff ff       	call   80108d <syscall>
  801556:	83 c4 18             	add    $0x18,%esp
	return ;
  801559:	90                   	nop
}
  80155a:	c9                   	leave  
  80155b:	c3                   	ret    

0080155c <gettst>:
uint32 gettst()
{
  80155c:	55                   	push   %ebp
  80155d:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_gettst, 0, 0, 0, 0, 0);
  80155f:	6a 00                	push   $0x0
  801561:	6a 00                	push   $0x0
  801563:	6a 00                	push   $0x0
  801565:	6a 00                	push   $0x0
  801567:	6a 00                	push   $0x0
  801569:	6a 29                	push   $0x29
  80156b:	e8 1d fb ff ff       	call   80108d <syscall>
  801570:	83 c4 18             	add    $0x18,%esp
}
  801573:	c9                   	leave  
  801574:	c3                   	ret    

00801575 <sys_isUHeapPlacementStrategyFIRSTFIT>:


//2015
uint32 sys_isUHeapPlacementStrategyFIRSTFIT()
{
  801575:	55                   	push   %ebp
  801576:	89 e5                	mov    %esp,%ebp
  801578:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  80157b:	6a 00                	push   $0x0
  80157d:	6a 00                	push   $0x0
  80157f:	6a 00                	push   $0x0
  801581:	6a 00                	push   $0x0
  801583:	6a 00                	push   $0x0
  801585:	6a 2a                	push   $0x2a
  801587:	e8 01 fb ff ff       	call   80108d <syscall>
  80158c:	83 c4 18             	add    $0x18,%esp
  80158f:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_FIRSTFIT)
  801592:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
  801596:	75 07                	jne    80159f <sys_isUHeapPlacementStrategyFIRSTFIT+0x2a>
		return 1;
  801598:	b8 01 00 00 00       	mov    $0x1,%eax
  80159d:	eb 05                	jmp    8015a4 <sys_isUHeapPlacementStrategyFIRSTFIT+0x2f>
	else
		return 0;
  80159f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015a4:	c9                   	leave  
  8015a5:	c3                   	ret    

008015a6 <sys_isUHeapPlacementStrategyBESTFIT>:
uint32 sys_isUHeapPlacementStrategyBESTFIT()
{
  8015a6:	55                   	push   %ebp
  8015a7:	89 e5                	mov    %esp,%ebp
  8015a9:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  8015ac:	6a 00                	push   $0x0
  8015ae:	6a 00                	push   $0x0
  8015b0:	6a 00                	push   $0x0
  8015b2:	6a 00                	push   $0x0
  8015b4:	6a 00                	push   $0x0
  8015b6:	6a 2a                	push   $0x2a
  8015b8:	e8 d0 fa ff ff       	call   80108d <syscall>
  8015bd:	83 c4 18             	add    $0x18,%esp
  8015c0:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_BESTFIT)
  8015c3:	83 7d fc 02          	cmpl   $0x2,-0x4(%ebp)
  8015c7:	75 07                	jne    8015d0 <sys_isUHeapPlacementStrategyBESTFIT+0x2a>
		return 1;
  8015c9:	b8 01 00 00 00       	mov    $0x1,%eax
  8015ce:	eb 05                	jmp    8015d5 <sys_isUHeapPlacementStrategyBESTFIT+0x2f>
	else
		return 0;
  8015d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015d5:	c9                   	leave  
  8015d6:	c3                   	ret    

008015d7 <sys_isUHeapPlacementStrategyNEXTFIT>:
uint32 sys_isUHeapPlacementStrategyNEXTFIT()
{
  8015d7:	55                   	push   %ebp
  8015d8:	89 e5                	mov    %esp,%ebp
  8015da:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  8015dd:	6a 00                	push   $0x0
  8015df:	6a 00                	push   $0x0
  8015e1:	6a 00                	push   $0x0
  8015e3:	6a 00                	push   $0x0
  8015e5:	6a 00                	push   $0x0
  8015e7:	6a 2a                	push   $0x2a
  8015e9:	e8 9f fa ff ff       	call   80108d <syscall>
  8015ee:	83 c4 18             	add    $0x18,%esp
  8015f1:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_NEXTFIT)
  8015f4:	83 7d fc 03          	cmpl   $0x3,-0x4(%ebp)
  8015f8:	75 07                	jne    801601 <sys_isUHeapPlacementStrategyNEXTFIT+0x2a>
		return 1;
  8015fa:	b8 01 00 00 00       	mov    $0x1,%eax
  8015ff:	eb 05                	jmp    801606 <sys_isUHeapPlacementStrategyNEXTFIT+0x2f>
	else
		return 0;
  801601:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801606:	c9                   	leave  
  801607:	c3                   	ret    

00801608 <sys_isUHeapPlacementStrategyWORSTFIT>:
uint32 sys_isUHeapPlacementStrategyWORSTFIT()
{
  801608:	55                   	push   %ebp
  801609:	89 e5                	mov    %esp,%ebp
  80160b:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  80160e:	6a 00                	push   $0x0
  801610:	6a 00                	push   $0x0
  801612:	6a 00                	push   $0x0
  801614:	6a 00                	push   $0x0
  801616:	6a 00                	push   $0x0
  801618:	6a 2a                	push   $0x2a
  80161a:	e8 6e fa ff ff       	call   80108d <syscall>
  80161f:	83 c4 18             	add    $0x18,%esp
  801622:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_WORSTFIT)
  801625:	83 7d fc 04          	cmpl   $0x4,-0x4(%ebp)
  801629:	75 07                	jne    801632 <sys_isUHeapPlacementStrategyWORSTFIT+0x2a>
		return 1;
  80162b:	b8 01 00 00 00       	mov    $0x1,%eax
  801630:	eb 05                	jmp    801637 <sys_isUHeapPlacementStrategyWORSTFIT+0x2f>
	else
		return 0;
  801632:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801637:	c9                   	leave  
  801638:	c3                   	ret    

00801639 <sys_set_uheap_strategy>:

void sys_set_uheap_strategy(uint32 heapStrategy)
{
  801639:	55                   	push   %ebp
  80163a:	89 e5                	mov    %esp,%ebp
	syscall(SYS_set_heap_strategy, heapStrategy, 0, 0, 0, 0);
  80163c:	6a 00                	push   $0x0
  80163e:	6a 00                	push   $0x0
  801640:	6a 00                	push   $0x0
  801642:	6a 00                	push   $0x0
  801644:	ff 75 08             	pushl  0x8(%ebp)
  801647:	6a 2b                	push   $0x2b
  801649:	e8 3f fa ff ff       	call   80108d <syscall>
  80164e:	83 c4 18             	add    $0x18,%esp
	return ;
  801651:	90                   	nop
}
  801652:	c9                   	leave  
  801653:	c3                   	ret    

00801654 <sys_check_LRU_lists>:

//2020
int sys_check_LRU_lists(uint32* active_list_content, uint32* second_list_content, int actual_active_list_size, int actual_second_list_size)
{
  801654:	55                   	push   %ebp
  801655:	89 e5                	mov    %esp,%ebp
  801657:	53                   	push   %ebx
	return syscall(SYS_check_LRU_lists, (uint32)active_list_content, (uint32)second_list_content, (uint32)actual_active_list_size, (uint32)actual_second_list_size, 0);
  801658:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80165b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80165e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801661:	8b 45 08             	mov    0x8(%ebp),%eax
  801664:	6a 00                	push   $0x0
  801666:	53                   	push   %ebx
  801667:	51                   	push   %ecx
  801668:	52                   	push   %edx
  801669:	50                   	push   %eax
  80166a:	6a 2c                	push   $0x2c
  80166c:	e8 1c fa ff ff       	call   80108d <syscall>
  801671:	83 c4 18             	add    $0x18,%esp
}
  801674:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801677:	c9                   	leave  
  801678:	c3                   	ret    

00801679 <sys_check_LRU_lists_free>:

int sys_check_LRU_lists_free(uint32* list_content, int list_size)
{
  801679:	55                   	push   %ebp
  80167a:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_check_LRU_lists_free, (uint32)list_content, (uint32)list_size , 0, 0, 0);
  80167c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80167f:	8b 45 08             	mov    0x8(%ebp),%eax
  801682:	6a 00                	push   $0x0
  801684:	6a 00                	push   $0x0
  801686:	6a 00                	push   $0x0
  801688:	52                   	push   %edx
  801689:	50                   	push   %eax
  80168a:	6a 2d                	push   $0x2d
  80168c:	e8 fc f9 ff ff       	call   80108d <syscall>
  801691:	83 c4 18             	add    $0x18,%esp
}
  801694:	c9                   	leave  
  801695:	c3                   	ret    

00801696 <sys_check_WS_list>:

int sys_check_WS_list(uint32* WS_list_content, int actual_WS_list_size, uint32 last_WS_element_content, bool chk_in_order)
{
  801696:	55                   	push   %ebp
  801697:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_check_WS_list, (uint32)WS_list_content, (uint32)actual_WS_list_size , last_WS_element_content, (uint32)chk_in_order, 0);
  801699:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80169c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80169f:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a2:	6a 00                	push   $0x0
  8016a4:	51                   	push   %ecx
  8016a5:	ff 75 10             	pushl  0x10(%ebp)
  8016a8:	52                   	push   %edx
  8016a9:	50                   	push   %eax
  8016aa:	6a 2e                	push   $0x2e
  8016ac:	e8 dc f9 ff ff       	call   80108d <syscall>
  8016b1:	83 c4 18             	add    $0x18,%esp
}
  8016b4:	c9                   	leave  
  8016b5:	c3                   	ret    

008016b6 <sys_allocate_chunk>:
void sys_allocate_chunk(uint32 virtual_address, uint32 size, uint32 perms)
{
  8016b6:	55                   	push   %ebp
  8016b7:	89 e5                	mov    %esp,%ebp
	syscall(SYS_allocate_chunk_in_mem, virtual_address, size, perms, 0, 0);
  8016b9:	6a 00                	push   $0x0
  8016bb:	6a 00                	push   $0x0
  8016bd:	ff 75 10             	pushl  0x10(%ebp)
  8016c0:	ff 75 0c             	pushl  0xc(%ebp)
  8016c3:	ff 75 08             	pushl  0x8(%ebp)
  8016c6:	6a 0f                	push   $0xf
  8016c8:	e8 c0 f9 ff ff       	call   80108d <syscall>
  8016cd:	83 c4 18             	add    $0x18,%esp
	return ;
  8016d0:	90                   	nop
}
  8016d1:	c9                   	leave  
  8016d2:	c3                   	ret    

008016d3 <sys_sbrk>:


/*2023*/
//TODO: [PROJECT'23.MS1 - #3] [2] SYSTEM CALLS - Implement these system calls
void* sys_sbrk(int increment)
{
  8016d3:	55                   	push   %ebp
  8016d4:	89 e5                	mov    %esp,%ebp
  8016d6:	83 ec 08             	sub    $0x8,%esp
	//Comment the following line before start coding...
	panic("not implemented yet");
  8016d9:	83 ec 04             	sub    $0x4,%esp
  8016dc:	68 10 20 80 00       	push   $0x802010
  8016e1:	68 54 01 00 00       	push   $0x154
  8016e6:	68 24 20 80 00       	push   $0x802024
  8016eb:	e8 3a 00 00 00       	call   80172a <_panic>

008016f0 <sys_free_user_mem>:
	return NULL;
}

void sys_free_user_mem(uint32 virtual_address, uint32 size)
{
  8016f0:	55                   	push   %ebp
  8016f1:	89 e5                	mov    %esp,%ebp
  8016f3:	83 ec 08             	sub    $0x8,%esp
	//Comment the following line before start coding...
	panic("not implemented yet");
  8016f6:	83 ec 04             	sub    $0x4,%esp
  8016f9:	68 10 20 80 00       	push   $0x802010
  8016fe:	68 5b 01 00 00       	push   $0x15b
  801703:	68 24 20 80 00       	push   $0x802024
  801708:	e8 1d 00 00 00       	call   80172a <_panic>

0080170d <sys_allocate_user_mem>:
}

void sys_allocate_user_mem(uint32 virtual_address, uint32 size)
{
  80170d:	55                   	push   %ebp
  80170e:	89 e5                	mov    %esp,%ebp
  801710:	83 ec 08             	sub    $0x8,%esp
	//Comment the following line before start coding...
	panic("not implemented yet");
  801713:	83 ec 04             	sub    $0x4,%esp
  801716:	68 10 20 80 00       	push   $0x802010
  80171b:	68 61 01 00 00       	push   $0x161
  801720:	68 24 20 80 00       	push   $0x802024
  801725:	e8 00 00 00 00       	call   80172a <_panic>

0080172a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes FOS to enter the FOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  80172a:	55                   	push   %ebp
  80172b:	89 e5                	mov    %esp,%ebp
  80172d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	va_start(ap, fmt);
  801730:	8d 45 10             	lea    0x10(%ebp),%eax
  801733:	83 c0 04             	add    $0x4,%eax
  801736:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// Print the panic message
	if (argv0)
  801739:	a1 98 69 81 00       	mov    0x816998,%eax
  80173e:	85 c0                	test   %eax,%eax
  801740:	74 16                	je     801758 <_panic+0x2e>
		cprintf("%s: ", argv0);
  801742:	a1 98 69 81 00       	mov    0x816998,%eax
  801747:	83 ec 08             	sub    $0x8,%esp
  80174a:	50                   	push   %eax
  80174b:	68 34 20 80 00       	push   $0x802034
  801750:	e8 15 eb ff ff       	call   80026a <cprintf>
  801755:	83 c4 10             	add    $0x10,%esp
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  801758:	a1 00 30 80 00       	mov    0x803000,%eax
  80175d:	ff 75 0c             	pushl  0xc(%ebp)
  801760:	ff 75 08             	pushl  0x8(%ebp)
  801763:	50                   	push   %eax
  801764:	68 39 20 80 00       	push   $0x802039
  801769:	e8 fc ea ff ff       	call   80026a <cprintf>
  80176e:	83 c4 10             	add    $0x10,%esp
	vcprintf(fmt, ap);
  801771:	8b 45 10             	mov    0x10(%ebp),%eax
  801774:	83 ec 08             	sub    $0x8,%esp
  801777:	ff 75 f4             	pushl  -0xc(%ebp)
  80177a:	50                   	push   %eax
  80177b:	e8 7f ea ff ff       	call   8001ff <vcprintf>
  801780:	83 c4 10             	add    $0x10,%esp
	vcprintf("\n", NULL);
  801783:	83 ec 08             	sub    $0x8,%esp
  801786:	6a 00                	push   $0x0
  801788:	68 55 20 80 00       	push   $0x802055
  80178d:	e8 6d ea ff ff       	call   8001ff <vcprintf>
  801792:	83 c4 10             	add    $0x10,%esp
	// Cause a breakpoint exception
//	while (1);
//		asm volatile("int3");

	//2013: exit the panic env only
	exit() ;
  801795:	e8 ee e9 ff ff       	call   800188 <exit>

	// should not return here
	while (1) ;
  80179a:	eb fe                	jmp    80179a <_panic+0x70>

0080179c <CheckWSArrayWithoutLastIndex>:
}

void CheckWSArrayWithoutLastIndex(uint32 *expectedPages, int arraySize)
{
  80179c:	55                   	push   %ebp
  80179d:	89 e5                	mov    %esp,%ebp
  80179f:	83 ec 28             	sub    $0x28,%esp
	if (arraySize != myEnv->page_WS_max_size)
  8017a2:	a1 20 30 80 00       	mov    0x803020,%eax
  8017a7:	8b 90 7c d5 01 00    	mov    0x1d57c(%eax),%edx
  8017ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017b0:	39 c2                	cmp    %eax,%edx
  8017b2:	74 14                	je     8017c8 <CheckWSArrayWithoutLastIndex+0x2c>
	{
		panic("number of expected pages SHOULD BE EQUAL to max WS size... review your TA!!");
  8017b4:	83 ec 04             	sub    $0x4,%esp
  8017b7:	68 58 20 80 00       	push   $0x802058
  8017bc:	6a 26                	push   $0x26
  8017be:	68 a4 20 80 00       	push   $0x8020a4
  8017c3:	e8 62 ff ff ff       	call   80172a <_panic>
	}
	int expectedNumOfEmptyLocs = 0;
  8017c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	for (int e = 0; e < arraySize; e++) {
  8017cf:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8017d6:	e9 c5 00 00 00       	jmp    8018a0 <CheckWSArrayWithoutLastIndex+0x104>
		if (expectedPages[e] == 0) {
  8017db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017de:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8017e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e8:	01 d0                	add    %edx,%eax
  8017ea:	8b 00                	mov    (%eax),%eax
  8017ec:	85 c0                	test   %eax,%eax
  8017ee:	75 08                	jne    8017f8 <CheckWSArrayWithoutLastIndex+0x5c>
			expectedNumOfEmptyLocs++;
  8017f0:	ff 45 f4             	incl   -0xc(%ebp)
			continue;
  8017f3:	e9 a5 00 00 00       	jmp    80189d <CheckWSArrayWithoutLastIndex+0x101>
		}
		int found = 0;
  8017f8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  8017ff:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  801806:	eb 69                	jmp    801871 <CheckWSArrayWithoutLastIndex+0xd5>
			if (myEnv->__uptr_pws[w].empty == 0) {
  801808:	a1 20 30 80 00       	mov    0x803020,%eax
  80180d:	8b 88 6c da 01 00    	mov    0x1da6c(%eax),%ecx
  801813:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801816:	89 d0                	mov    %edx,%eax
  801818:	01 c0                	add    %eax,%eax
  80181a:	01 d0                	add    %edx,%eax
  80181c:	c1 e0 03             	shl    $0x3,%eax
  80181f:	01 c8                	add    %ecx,%eax
  801821:	8a 40 04             	mov    0x4(%eax),%al
  801824:	84 c0                	test   %al,%al
  801826:	75 46                	jne    80186e <CheckWSArrayWithoutLastIndex+0xd2>
				if (ROUNDDOWN(myEnv->__uptr_pws[w].virtual_address, PAGE_SIZE)
  801828:	a1 20 30 80 00       	mov    0x803020,%eax
  80182d:	8b 88 6c da 01 00    	mov    0x1da6c(%eax),%ecx
  801833:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801836:	89 d0                	mov    %edx,%eax
  801838:	01 c0                	add    %eax,%eax
  80183a:	01 d0                	add    %edx,%eax
  80183c:	c1 e0 03             	shl    $0x3,%eax
  80183f:	01 c8                	add    %ecx,%eax
  801841:	8b 00                	mov    (%eax),%eax
  801843:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801846:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801849:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80184e:	89 c2                	mov    %eax,%edx
						== expectedPages[e]) {
  801850:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801853:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  80185a:	8b 45 08             	mov    0x8(%ebp),%eax
  80185d:	01 c8                	add    %ecx,%eax
  80185f:	8b 00                	mov    (%eax),%eax
			continue;
		}
		int found = 0;
		for (int w = 0; w < myEnv->page_WS_max_size; w++) {
			if (myEnv->__uptr_pws[w].empty == 0) {
				if (ROUNDDOWN(myEnv->__uptr_pws[w].virtual_address, PAGE_SIZE)
  801861:	39 c2                	cmp    %eax,%edx
  801863:	75 09                	jne    80186e <CheckWSArrayWithoutLastIndex+0xd2>
						== expectedPages[e]) {
					found = 1;
  801865:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
					break;
  80186c:	eb 15                	jmp    801883 <CheckWSArrayWithoutLastIndex+0xe7>
		if (expectedPages[e] == 0) {
			expectedNumOfEmptyLocs++;
			continue;
		}
		int found = 0;
		for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  80186e:	ff 45 e8             	incl   -0x18(%ebp)
  801871:	a1 20 30 80 00       	mov    0x803020,%eax
  801876:	8b 90 7c d5 01 00    	mov    0x1d57c(%eax),%edx
  80187c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80187f:	39 c2                	cmp    %eax,%edx
  801881:	77 85                	ja     801808 <CheckWSArrayWithoutLastIndex+0x6c>
					found = 1;
					break;
				}
			}
		}
		if (!found)
  801883:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801887:	75 14                	jne    80189d <CheckWSArrayWithoutLastIndex+0x101>
			panic(
  801889:	83 ec 04             	sub    $0x4,%esp
  80188c:	68 b0 20 80 00       	push   $0x8020b0
  801891:	6a 3a                	push   $0x3a
  801893:	68 a4 20 80 00       	push   $0x8020a4
  801898:	e8 8d fe ff ff       	call   80172a <_panic>
	if (arraySize != myEnv->page_WS_max_size)
	{
		panic("number of expected pages SHOULD BE EQUAL to max WS size... review your TA!!");
	}
	int expectedNumOfEmptyLocs = 0;
	for (int e = 0; e < arraySize; e++) {
  80189d:	ff 45 f0             	incl   -0x10(%ebp)
  8018a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018a3:	3b 45 0c             	cmp    0xc(%ebp),%eax
  8018a6:	0f 8c 2f ff ff ff    	jl     8017db <CheckWSArrayWithoutLastIndex+0x3f>
		}
		if (!found)
			panic(
					"PAGE WS entry checking failed... trace it by printing page WS before & after fault");
	}
	int actualNumOfEmptyLocs = 0;
  8018ac:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  8018b3:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8018ba:	eb 26                	jmp    8018e2 <CheckWSArrayWithoutLastIndex+0x146>
		if (myEnv->__uptr_pws[w].empty == 1) {
  8018bc:	a1 20 30 80 00       	mov    0x803020,%eax
  8018c1:	8b 88 6c da 01 00    	mov    0x1da6c(%eax),%ecx
  8018c7:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8018ca:	89 d0                	mov    %edx,%eax
  8018cc:	01 c0                	add    %eax,%eax
  8018ce:	01 d0                	add    %edx,%eax
  8018d0:	c1 e0 03             	shl    $0x3,%eax
  8018d3:	01 c8                	add    %ecx,%eax
  8018d5:	8a 40 04             	mov    0x4(%eax),%al
  8018d8:	3c 01                	cmp    $0x1,%al
  8018da:	75 03                	jne    8018df <CheckWSArrayWithoutLastIndex+0x143>
			actualNumOfEmptyLocs++;
  8018dc:	ff 45 e4             	incl   -0x1c(%ebp)
		if (!found)
			panic(
					"PAGE WS entry checking failed... trace it by printing page WS before & after fault");
	}
	int actualNumOfEmptyLocs = 0;
	for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  8018df:	ff 45 e0             	incl   -0x20(%ebp)
  8018e2:	a1 20 30 80 00       	mov    0x803020,%eax
  8018e7:	8b 90 7c d5 01 00    	mov    0x1d57c(%eax),%edx
  8018ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018f0:	39 c2                	cmp    %eax,%edx
  8018f2:	77 c8                	ja     8018bc <CheckWSArrayWithoutLastIndex+0x120>
		if (myEnv->__uptr_pws[w].empty == 1) {
			actualNumOfEmptyLocs++;
		}
	}
	if (expectedNumOfEmptyLocs != actualNumOfEmptyLocs)
  8018f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018f7:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
  8018fa:	74 14                	je     801910 <CheckWSArrayWithoutLastIndex+0x174>
		panic(
  8018fc:	83 ec 04             	sub    $0x4,%esp
  8018ff:	68 04 21 80 00       	push   $0x802104
  801904:	6a 44                	push   $0x44
  801906:	68 a4 20 80 00       	push   $0x8020a4
  80190b:	e8 1a fe ff ff       	call   80172a <_panic>
				"PAGE WS entry checking failed... number of empty locations is not correct");
}
  801910:	90                   	nop
  801911:	c9                   	leave  
  801912:	c3                   	ret    
  801913:	90                   	nop

00801914 <__udivdi3>:
  801914:	55                   	push   %ebp
  801915:	57                   	push   %edi
  801916:	56                   	push   %esi
  801917:	53                   	push   %ebx
  801918:	83 ec 1c             	sub    $0x1c,%esp
  80191b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80191f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801923:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801927:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80192b:	89 ca                	mov    %ecx,%edx
  80192d:	89 f8                	mov    %edi,%eax
  80192f:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801933:	85 f6                	test   %esi,%esi
  801935:	75 2d                	jne    801964 <__udivdi3+0x50>
  801937:	39 cf                	cmp    %ecx,%edi
  801939:	77 65                	ja     8019a0 <__udivdi3+0x8c>
  80193b:	89 fd                	mov    %edi,%ebp
  80193d:	85 ff                	test   %edi,%edi
  80193f:	75 0b                	jne    80194c <__udivdi3+0x38>
  801941:	b8 01 00 00 00       	mov    $0x1,%eax
  801946:	31 d2                	xor    %edx,%edx
  801948:	f7 f7                	div    %edi
  80194a:	89 c5                	mov    %eax,%ebp
  80194c:	31 d2                	xor    %edx,%edx
  80194e:	89 c8                	mov    %ecx,%eax
  801950:	f7 f5                	div    %ebp
  801952:	89 c1                	mov    %eax,%ecx
  801954:	89 d8                	mov    %ebx,%eax
  801956:	f7 f5                	div    %ebp
  801958:	89 cf                	mov    %ecx,%edi
  80195a:	89 fa                	mov    %edi,%edx
  80195c:	83 c4 1c             	add    $0x1c,%esp
  80195f:	5b                   	pop    %ebx
  801960:	5e                   	pop    %esi
  801961:	5f                   	pop    %edi
  801962:	5d                   	pop    %ebp
  801963:	c3                   	ret    
  801964:	39 ce                	cmp    %ecx,%esi
  801966:	77 28                	ja     801990 <__udivdi3+0x7c>
  801968:	0f bd fe             	bsr    %esi,%edi
  80196b:	83 f7 1f             	xor    $0x1f,%edi
  80196e:	75 40                	jne    8019b0 <__udivdi3+0x9c>
  801970:	39 ce                	cmp    %ecx,%esi
  801972:	72 0a                	jb     80197e <__udivdi3+0x6a>
  801974:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801978:	0f 87 9e 00 00 00    	ja     801a1c <__udivdi3+0x108>
  80197e:	b8 01 00 00 00       	mov    $0x1,%eax
  801983:	89 fa                	mov    %edi,%edx
  801985:	83 c4 1c             	add    $0x1c,%esp
  801988:	5b                   	pop    %ebx
  801989:	5e                   	pop    %esi
  80198a:	5f                   	pop    %edi
  80198b:	5d                   	pop    %ebp
  80198c:	c3                   	ret    
  80198d:	8d 76 00             	lea    0x0(%esi),%esi
  801990:	31 ff                	xor    %edi,%edi
  801992:	31 c0                	xor    %eax,%eax
  801994:	89 fa                	mov    %edi,%edx
  801996:	83 c4 1c             	add    $0x1c,%esp
  801999:	5b                   	pop    %ebx
  80199a:	5e                   	pop    %esi
  80199b:	5f                   	pop    %edi
  80199c:	5d                   	pop    %ebp
  80199d:	c3                   	ret    
  80199e:	66 90                	xchg   %ax,%ax
  8019a0:	89 d8                	mov    %ebx,%eax
  8019a2:	f7 f7                	div    %edi
  8019a4:	31 ff                	xor    %edi,%edi
  8019a6:	89 fa                	mov    %edi,%edx
  8019a8:	83 c4 1c             	add    $0x1c,%esp
  8019ab:	5b                   	pop    %ebx
  8019ac:	5e                   	pop    %esi
  8019ad:	5f                   	pop    %edi
  8019ae:	5d                   	pop    %ebp
  8019af:	c3                   	ret    
  8019b0:	bd 20 00 00 00       	mov    $0x20,%ebp
  8019b5:	89 eb                	mov    %ebp,%ebx
  8019b7:	29 fb                	sub    %edi,%ebx
  8019b9:	89 f9                	mov    %edi,%ecx
  8019bb:	d3 e6                	shl    %cl,%esi
  8019bd:	89 c5                	mov    %eax,%ebp
  8019bf:	88 d9                	mov    %bl,%cl
  8019c1:	d3 ed                	shr    %cl,%ebp
  8019c3:	89 e9                	mov    %ebp,%ecx
  8019c5:	09 f1                	or     %esi,%ecx
  8019c7:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8019cb:	89 f9                	mov    %edi,%ecx
  8019cd:	d3 e0                	shl    %cl,%eax
  8019cf:	89 c5                	mov    %eax,%ebp
  8019d1:	89 d6                	mov    %edx,%esi
  8019d3:	88 d9                	mov    %bl,%cl
  8019d5:	d3 ee                	shr    %cl,%esi
  8019d7:	89 f9                	mov    %edi,%ecx
  8019d9:	d3 e2                	shl    %cl,%edx
  8019db:	8b 44 24 08          	mov    0x8(%esp),%eax
  8019df:	88 d9                	mov    %bl,%cl
  8019e1:	d3 e8                	shr    %cl,%eax
  8019e3:	09 c2                	or     %eax,%edx
  8019e5:	89 d0                	mov    %edx,%eax
  8019e7:	89 f2                	mov    %esi,%edx
  8019e9:	f7 74 24 0c          	divl   0xc(%esp)
  8019ed:	89 d6                	mov    %edx,%esi
  8019ef:	89 c3                	mov    %eax,%ebx
  8019f1:	f7 e5                	mul    %ebp
  8019f3:	39 d6                	cmp    %edx,%esi
  8019f5:	72 19                	jb     801a10 <__udivdi3+0xfc>
  8019f7:	74 0b                	je     801a04 <__udivdi3+0xf0>
  8019f9:	89 d8                	mov    %ebx,%eax
  8019fb:	31 ff                	xor    %edi,%edi
  8019fd:	e9 58 ff ff ff       	jmp    80195a <__udivdi3+0x46>
  801a02:	66 90                	xchg   %ax,%ax
  801a04:	8b 54 24 08          	mov    0x8(%esp),%edx
  801a08:	89 f9                	mov    %edi,%ecx
  801a0a:	d3 e2                	shl    %cl,%edx
  801a0c:	39 c2                	cmp    %eax,%edx
  801a0e:	73 e9                	jae    8019f9 <__udivdi3+0xe5>
  801a10:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801a13:	31 ff                	xor    %edi,%edi
  801a15:	e9 40 ff ff ff       	jmp    80195a <__udivdi3+0x46>
  801a1a:	66 90                	xchg   %ax,%ax
  801a1c:	31 c0                	xor    %eax,%eax
  801a1e:	e9 37 ff ff ff       	jmp    80195a <__udivdi3+0x46>
  801a23:	90                   	nop

00801a24 <__umoddi3>:
  801a24:	55                   	push   %ebp
  801a25:	57                   	push   %edi
  801a26:	56                   	push   %esi
  801a27:	53                   	push   %ebx
  801a28:	83 ec 1c             	sub    $0x1c,%esp
  801a2b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801a2f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801a33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801a37:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801a3b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a3f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801a43:	89 f3                	mov    %esi,%ebx
  801a45:	89 fa                	mov    %edi,%edx
  801a47:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801a4b:	89 34 24             	mov    %esi,(%esp)
  801a4e:	85 c0                	test   %eax,%eax
  801a50:	75 1a                	jne    801a6c <__umoddi3+0x48>
  801a52:	39 f7                	cmp    %esi,%edi
  801a54:	0f 86 a2 00 00 00    	jbe    801afc <__umoddi3+0xd8>
  801a5a:	89 c8                	mov    %ecx,%eax
  801a5c:	89 f2                	mov    %esi,%edx
  801a5e:	f7 f7                	div    %edi
  801a60:	89 d0                	mov    %edx,%eax
  801a62:	31 d2                	xor    %edx,%edx
  801a64:	83 c4 1c             	add    $0x1c,%esp
  801a67:	5b                   	pop    %ebx
  801a68:	5e                   	pop    %esi
  801a69:	5f                   	pop    %edi
  801a6a:	5d                   	pop    %ebp
  801a6b:	c3                   	ret    
  801a6c:	39 f0                	cmp    %esi,%eax
  801a6e:	0f 87 ac 00 00 00    	ja     801b20 <__umoddi3+0xfc>
  801a74:	0f bd e8             	bsr    %eax,%ebp
  801a77:	83 f5 1f             	xor    $0x1f,%ebp
  801a7a:	0f 84 ac 00 00 00    	je     801b2c <__umoddi3+0x108>
  801a80:	bf 20 00 00 00       	mov    $0x20,%edi
  801a85:	29 ef                	sub    %ebp,%edi
  801a87:	89 fe                	mov    %edi,%esi
  801a89:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801a8d:	89 e9                	mov    %ebp,%ecx
  801a8f:	d3 e0                	shl    %cl,%eax
  801a91:	89 d7                	mov    %edx,%edi
  801a93:	89 f1                	mov    %esi,%ecx
  801a95:	d3 ef                	shr    %cl,%edi
  801a97:	09 c7                	or     %eax,%edi
  801a99:	89 e9                	mov    %ebp,%ecx
  801a9b:	d3 e2                	shl    %cl,%edx
  801a9d:	89 14 24             	mov    %edx,(%esp)
  801aa0:	89 d8                	mov    %ebx,%eax
  801aa2:	d3 e0                	shl    %cl,%eax
  801aa4:	89 c2                	mov    %eax,%edx
  801aa6:	8b 44 24 08          	mov    0x8(%esp),%eax
  801aaa:	d3 e0                	shl    %cl,%eax
  801aac:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ab0:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ab4:	89 f1                	mov    %esi,%ecx
  801ab6:	d3 e8                	shr    %cl,%eax
  801ab8:	09 d0                	or     %edx,%eax
  801aba:	d3 eb                	shr    %cl,%ebx
  801abc:	89 da                	mov    %ebx,%edx
  801abe:	f7 f7                	div    %edi
  801ac0:	89 d3                	mov    %edx,%ebx
  801ac2:	f7 24 24             	mull   (%esp)
  801ac5:	89 c6                	mov    %eax,%esi
  801ac7:	89 d1                	mov    %edx,%ecx
  801ac9:	39 d3                	cmp    %edx,%ebx
  801acb:	0f 82 87 00 00 00    	jb     801b58 <__umoddi3+0x134>
  801ad1:	0f 84 91 00 00 00    	je     801b68 <__umoddi3+0x144>
  801ad7:	8b 54 24 04          	mov    0x4(%esp),%edx
  801adb:	29 f2                	sub    %esi,%edx
  801add:	19 cb                	sbb    %ecx,%ebx
  801adf:	89 d8                	mov    %ebx,%eax
  801ae1:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  801ae5:	d3 e0                	shl    %cl,%eax
  801ae7:	89 e9                	mov    %ebp,%ecx
  801ae9:	d3 ea                	shr    %cl,%edx
  801aeb:	09 d0                	or     %edx,%eax
  801aed:	89 e9                	mov    %ebp,%ecx
  801aef:	d3 eb                	shr    %cl,%ebx
  801af1:	89 da                	mov    %ebx,%edx
  801af3:	83 c4 1c             	add    $0x1c,%esp
  801af6:	5b                   	pop    %ebx
  801af7:	5e                   	pop    %esi
  801af8:	5f                   	pop    %edi
  801af9:	5d                   	pop    %ebp
  801afa:	c3                   	ret    
  801afb:	90                   	nop
  801afc:	89 fd                	mov    %edi,%ebp
  801afe:	85 ff                	test   %edi,%edi
  801b00:	75 0b                	jne    801b0d <__umoddi3+0xe9>
  801b02:	b8 01 00 00 00       	mov    $0x1,%eax
  801b07:	31 d2                	xor    %edx,%edx
  801b09:	f7 f7                	div    %edi
  801b0b:	89 c5                	mov    %eax,%ebp
  801b0d:	89 f0                	mov    %esi,%eax
  801b0f:	31 d2                	xor    %edx,%edx
  801b11:	f7 f5                	div    %ebp
  801b13:	89 c8                	mov    %ecx,%eax
  801b15:	f7 f5                	div    %ebp
  801b17:	89 d0                	mov    %edx,%eax
  801b19:	e9 44 ff ff ff       	jmp    801a62 <__umoddi3+0x3e>
  801b1e:	66 90                	xchg   %ax,%ax
  801b20:	89 c8                	mov    %ecx,%eax
  801b22:	89 f2                	mov    %esi,%edx
  801b24:	83 c4 1c             	add    $0x1c,%esp
  801b27:	5b                   	pop    %ebx
  801b28:	5e                   	pop    %esi
  801b29:	5f                   	pop    %edi
  801b2a:	5d                   	pop    %ebp
  801b2b:	c3                   	ret    
  801b2c:	3b 04 24             	cmp    (%esp),%eax
  801b2f:	72 06                	jb     801b37 <__umoddi3+0x113>
  801b31:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  801b35:	77 0f                	ja     801b46 <__umoddi3+0x122>
  801b37:	89 f2                	mov    %esi,%edx
  801b39:	29 f9                	sub    %edi,%ecx
  801b3b:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  801b3f:	89 14 24             	mov    %edx,(%esp)
  801b42:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801b46:	8b 44 24 04          	mov    0x4(%esp),%eax
  801b4a:	8b 14 24             	mov    (%esp),%edx
  801b4d:	83 c4 1c             	add    $0x1c,%esp
  801b50:	5b                   	pop    %ebx
  801b51:	5e                   	pop    %esi
  801b52:	5f                   	pop    %edi
  801b53:	5d                   	pop    %ebp
  801b54:	c3                   	ret    
  801b55:	8d 76 00             	lea    0x0(%esi),%esi
  801b58:	2b 04 24             	sub    (%esp),%eax
  801b5b:	19 fa                	sbb    %edi,%edx
  801b5d:	89 d1                	mov    %edx,%ecx
  801b5f:	89 c6                	mov    %eax,%esi
  801b61:	e9 71 ff ff ff       	jmp    801ad7 <__umoddi3+0xb3>
  801b66:	66 90                	xchg   %ax,%ax
  801b68:	39 44 24 04          	cmp    %eax,0x4(%esp)
  801b6c:	72 ea                	jb     801b58 <__umoddi3+0x134>
  801b6e:	89 d9                	mov    %ebx,%ecx
  801b70:	e9 62 ff ff ff       	jmp    801ad7 <__umoddi3+0xb3>
