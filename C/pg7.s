; ModuleID = 'pg7.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.7.4"

define void @acc(i32* %a, i32 %v) nounwind uwtable ssp {
  %1 = alloca i32*, align 8
  %2 = alloca i32, align 4
  store i32* %a, i32** %1, align 8
  store i32 %v, i32* %2, align 4
  %3 = load i32** %1, align 8
  %4 = load i32* %3
  %5 = load i32* %2, align 4
  %6 = add nsw i32 %4, %5
  %7 = load i32** %1, align 8
  store i32 %6, i32* %7
  ret void
}

define void @test() nounwind uwtable ssp {
  %a = alloca i32, align 4 	; int a;
  %b = alloca [2 x i32], align 4 ; int b;
  store i32 42, i32* %a, align 4 ; a = 42;
  %1 = getelementptr inbounds [2 x i32]* %b, i32 0, i64 0 ; b[0] = 2;
  store i32 2, i32* %1, align 4
  %2 = getelementptr inbounds [2 x i32]* %b, i32 0, i64 1 ; b[1] = 3;
  store i32 3, i32* %2, align 4
  %3 = getelementptr inbounds [2 x i32]* %b, i32 0, i64 0 ; acc(&a, b[0]);
  %4 = load i32* %3, align 4
  call void @acc(i32* %a, i32 %4)
  %5 = getelementptr inbounds [2 x i32]* %b, i32 0, i64 1 ; acc(&b[1], &b[0]);
  %6 = getelementptr inbounds [2 x i32]* %b, i32 0, i64 0
  %7 = load i32* %6, align 4
  call void @acc(i32* %5, i32 %7)
  ret void
}
