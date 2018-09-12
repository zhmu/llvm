; RUN: opt -basicaa -print-alias-sets -S -o - < %s 2>&1 | FileCheck %s

; CHECK: Alias sets for function 'test1':
; CHECK: Alias Set Tracker: 2 alias sets for 2 pointer values.
; CHECK:   AliasSet[0x{{[0-9a-f]+}}, 1] must alias, Mod       Pointers: (i8* %a, 1)
; CHECK-NOT: 1 Unknown instruction
; CHECK:   AliasSet[0x{{[0-9a-f]+}}, 1] must alias, Mod       Pointers: (i8* %b, 1)
define void @test1(i32 %c) {
entry:
  %a = alloca i8, align 1
  %b = alloca i8, align 1
  store i8 1, i8* %a, align 1
  %cond1 = icmp ne i32 %c, 0
  call void @llvm.assume(i1 %cond1)
  store i8 1, i8* %b, align 1
  ret void
}

; CHECK: Alias sets for function 'test2':
; CHECK: Alias Set Tracker: 3 alias sets for 2 pointer values.
; CHECK:   AliasSet[0x{{[0-9a-f]+}}, 1] must alias, Mod       Pointers: (i8* %a, 1)
; CHECK:   AliasSet[0x{{[0-9a-f]+}}, 1] may alias, Ref
; CHECK:     1 Unknown instructions:   call void (i1, ...) @llvm.experimental.guard(i1 %cond1) [ "deopt"() ]
; CHECK:   AliasSet[0x{{[0-9a-f]+}}, 1] must alias, Mod       Pointers: (i8* %b, 1)
define void @test2(i32 %c) {
entry:
  %a = alloca i8, align 1
  %b = alloca i8, align 1
  store i8 1, i8* %a, align 1
  %cond1 = icmp ne i32 %c, 0
  call void (i1, ...) @llvm.experimental.guard(i1 %cond1)["deopt"()]
  store i8 1, i8* %b, align 1
  ret void
}

; CHECK: Alias sets for function 'test3':
; CHECK: Alias Set Tracker: 1 alias sets for 2 pointer values.
; CHECK:   AliasSet[0x{{[0-9a-f]+}}, 3] may alias, Mod/Ref   Pointers: (i8* %a, 1), (i8* %b, 1)
; CHECK:     1 Unknown instructions:   call void (i1, ...) @llvm.experimental.guard(i1 %cond1) [ "deopt"() ]
define void @test3(i32 %c, i8* %a, i8* %b) {
entry:
  store i8 1, i8* %a, align 1
  %cond1 = icmp ne i32 %c, 0
  call void (i1, ...) @llvm.experimental.guard(i1 %cond1)["deopt"()]
  store i8 1, i8* %b, align 1
  ret void
}

; CHECK: Alias sets for function 'test4':
; CHECK: Alias Set Tracker: 2 alias sets for 2 pointer values.
; CHECK:   AliasSet[0x{{[0-9a-f]+}}, 2] may alias, Mod/Ref   Pointers: (i8* %a, 1)
; CHECK:     1 Unknown instructions:   call void (i1, ...) @llvm.experimental.guard(i1 %cond1) [ "deopt"() ]
; CHECK:   AliasSet[0x{{[0-9a-f]+}}, 1] must alias, Mod       Pointers: (i8* %b, 1)
define void @test4(i32 %c, i8* %a) {
entry:
  %b = alloca i8, align 1
  store i8 1, i8* %a, align 1
  %cond1 = icmp ne i32 %c, 0
  call void (i1, ...) @llvm.experimental.guard(i1 %cond1)["deopt"()]
  store i8 1, i8* %b, align 1
  ret void
}

declare void @llvm.assume(i1)
declare void @llvm.experimental.guard(i1, ...)
