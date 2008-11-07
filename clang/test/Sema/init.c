// RUN: clang %s -verify -fsyntax-only

typedef void (* fp)(void);
void foo(void);
fp a[1] = { foo };

int myArray[5] = {1, 2, 3, 4, 5};
int *myPointer2 = myArray;
int *myPointer = &(myArray[2]);


extern int x;
void *g = &x;
int *h = &x;

int test() {
int a[10];
int b[10] = a; // expected-error {{initialization with "{...}" expected}}
int +; // expected-error {{expected identifier or '('}} expected-error {{declarator requires an identifier}} expected-error {{parse error}}
}


// PR2050
struct cdiff_cmd {
          const char *name;
          unsigned short argc;
          int (*handler)();
};
int cdiff_cmd_open();
struct cdiff_cmd commands[] = {
        {"OPEN", 1, &cdiff_cmd_open }
};

// PR2348
static struct { int z; } s[2];
int *t = &(*s).z;

// PR2349
short *a2(void)
{
  short int b;
  static short *bp = &b; // expected-error {{initializer element is not a compile-time constant}}

  return bp;
}

int pbool(void) {
  typedef const _Bool cbool;
  _Bool pbool1 = (void *) 0;
  cbool pbool2 = &pbool;
  return pbool2;
}


// rdar://5870981
union { float f; unsigned u; } u = { 1.0f };

// rdar://6156694
int f3(int x) { return x; }
typedef void (*vfunc)(void);
void *bar = (vfunc) f3;

// PR2747
struct sym_reg {
        char nc_gpreg;
};
int sym_fw1a_scr[] = {
           ((int)(&((struct sym_reg *)0)->nc_gpreg)) & 0,
           8 * ((int)(&((struct sym_reg *)0)->nc_gpreg))
};

// PR3001
struct s1 s2 = {
    .a = sizeof(struct s3), // expected-error {{invalid application of 'sizeof'}}
    .b = bogus // expected-error {{use of undeclared identifier 'bogus'}}
}

