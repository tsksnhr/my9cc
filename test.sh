#!/bin/bash

assert(){
	expected="$1"
	input="$2"

	./9cc "$input" > tmp.s

	cc -o tmp tmp.s flist.o
	./tmp

	actual="$?"

	if [ "$actual" = "$expected" ]; then
		echo "$input => $actual"
	else
		echo "$input => $expected expected, but got $actual"
		exit 1
	fi
}

tiny_echo(){
	input="$1"

	./9cc "$input" > tmp.s

	echo "$input"

	cc -o tmp tmp.s flist.o
	./tmp

}

# if "return" doesn't exist, segmentaiton fault will occur
tiny_echo "int fib(int num){ if (num <= 2) return 1; else {int a = num-2; int b = num-1; return fib(a) + fib(b);}} int main(){ for (int i = 1; i <= 10; i = i + 1){ int ans = fib(i); showint(ans);} return 0;}"

assert 40 "int func(int a, int b){int c = a + b; return c;} int main(){int x = 10; for (int i = 0; i < 10; i = i + 1) x = x + 1; int y = 20; return func(x, y);}"
assert 10 "int func(int a){ return a;} int main(){int a = 10; return func(a);}"
assert 1 "int func(int num){if (num == 1) return num; else return num + 10;} int main(){return func(1);}"
assert 20 "int func(int num){if (num == 1) return num; else return num + 10;} int main(){return func(10);}"
assert 11 "int func(int num){ return num + 1;} int main(){ int a = 0; while(a <= 10){ a = func(a);} return a;}"

assert 3 "int main(){ int a; a = 3; int *b; b = &a; return *b;}"
assert 4 "int main(){ int x; int *y; y = &x; *y = 3 + 1; return x;}"

assert 2 "int main(){ int *p; p = tiny_alloc(1, 2, 4, 8); showptr(p); int *q; q = p + 1; showptr(q); return *q;}"
assert 4 "int main(){ int *p; p = tiny_alloc(1, 2, 4, 8); showptr(p); int *q; q = p + 2; showptr(q); return *q;}"
assert 8 "int main(){ int *p; p = tiny_alloc(1, 2, 4, 8); showptr(p); int *q; q = p + 3; showptr(q); return *(p + 3);}"

assert 4 "int main(){ int *p; p = tiny_alloc(1, 2, 4, 8); showptr(p); int *q; q = p + 3; q = q - 1; showptr(q); return *q;}"
assert 2 "int main(){ int *p; p = tiny_alloc(1, 2, 4, 8); showptr(p); int *q; q = p + 3; q = q - 2; showptr(q); return *q;}"
assert 1 "int main(){ int *p; p = tiny_alloc(1, 2, 4, 8); showptr(p); int *q; q = p + 3; q = q - 3; showptr(q); return *q;}"
assert 5 "int main(){ int *p; p = tiny_alloc(1, 2, 4, 8); showptr(p); *(p + 1) = 5; return *(p + 1);}"

assert 3 "int main(){ int **p; int *q; int r; q = &r; p = &q; int **s; s = p + 1; showptr(p); showptr(s); r = 3; return **p;}"

assert 3 "int main(){ int **p; int *q; int r; q = &r; p = &q; showptr(r); showptr(q); showptr(p); r = 3; return **p;}"

assert 3 "int main(){int b; b = 3; insert_ten(b); return b;}"
assert 10 "int main(){int b; b = 3; push_ten(&b); return b;}"

assert 10 "int func(int *a){ *a = 10; return 0;} int main(){ a = 3; func(&a); return a;}"
assert 30 "int func(int *a, int *b){ *a = 10; *b = 20; return 0;} int main(){ int a = 3; int b = 4; func(&a, &b); return a + b;}"

assert 4 "int main(){ int a; return sizeof(a);}"
assert 4 "int main(){ int a; return sizeof(a + 3 + 8);}"
assert 4 "int main(){ return sizeof(sizeof(1));}"
assert 8 "int main(){ int *a; return sizeof(a);}"
assert 4 "int main(){ int *a; return sizeof(*a);}"
assert 8 "int main(){ int a; return sizeof(&a);}"
assert 8 "int main(){ int **a; return sizeof(*a);}"
assert 4 "int main(){ int **a; return sizeof(**a);}"
assert 8 "int main(){ int ****a; return sizeof(**a);}"
assert 8 "int main(){ int *a; return sizeof(&a);}"

assert 1 "int main(){ int a[10]; *a = 1; return *a;}"
assert 7 "int main(){ int a[10]; *a = 1; *(a + 1) = 7; int *p = a + 1; showptr(a); showptr(p); return *(a + 1);}"
assert 1 "int main(){ int a[10]; *a = 1; int *p = a; return *p;}"
assert 2 "int main(){ int a[10]; *a = 1; *(a + 1) = 2; int *p = a; return *(p + 1);}"
assert 3 "int main(){ int a[10]; *a = 1; *(a + 1) = 2; int *p; p = a; return *p + *(p + 1);}"

assert 4 "int main(){ int a[10]; return sizeof(*a);}"
assert 40 "int main(){ int a[10]; return sizeof(a);}"

assert 1 "int main(){ int a[10]; *(a + 5) = 7; int *p = &a; return p == &a;}"

assert 5 "int main(){ int a[10]; a[0] = 2; a[1] = 3; return a[0] + a[1];}"
assert 7 "int main(){ int a[10]; for (int i = 0; i < 10; i = i + 1){ a[i] = i;} return a[7];}"

assert 1 "int var; int main(){ var = 1; return var;}"
assert 2 "int gv; int main(){ gv = 1; return gv + 1;}"
assert 3 "int a; int b; int main(){ a = 1;  b = 2; return a + b;}"
assert 1 "int a; int main(){ int *p; p = &a; *p = 1; return *p;}"
assert 5 "int var[10]; int main(){ var[2] = 5; return 5;}"
assert 9 "int var[10]; int main(){ var[1] = 2; var[3] = 7; return var[1] + var[3];}"
assert 4 "int var[10]; int main(){ for (int i = 0; i < 10; i = i + 1) *(var + i) = i; return var[1] + var[3];}"
assert 4 "int var[10]; int main(){ for (int i = 0; i < 10; i = i + 1) *(var + i) = i; return *(var + 1) + *(var + 3);}"
assert 0 "int var[10]; int main(){ for (int i = 0; i < 10; i = i + 1) *(var + i) = i; return *var;}"
assert 2 "int *var; int main(){ int a = 1; var = &a; *var = 2; return *var;}"

assert 1 "int main(){ char a; a = 1; return a;}"
assert 10 "int main(){ char a[10]; for (int i = 0; i < 10; i = i + 1){ a[i] = i;} return a[3] + a[7];}"
assert 6 "char var[10]; int main(){ for (int i = 0; i < 10; i = i + 1) *(var + i) = i; return var[1] + var[5];}"
assert 3 "char var; int main(){ var = 3; return var;}"

echo OK
