; ModuleID = 'scaffold.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.7.4"

@.str = private unnamed_addr constant [4 x i8] c"%i\0A\00", align 1

define void @expired(i8* %Pbool) nounwind uwtable ssp {
  %1 = alloca i8*, align 8
  store i8* %Pbool, i8** %1, align 8
  %2 = load i8** %1, align 8
  store i8 1, i8* %2
  ret void
}

define i32 @main() nounwind uwtable ssp {
  %1 = alloca i32, align 4
  %c1 = alloca i8, align 1
  %nl = alloca i8, align 1
  %e = alloca i8, align 1
  store i32 0, i32* %1
  br label %2

; <label>:2                                       ; preds = %0, %15
  %3 = call i32 @getchar()
  %4 = trunc i32 %3 to i8
  store i8 %4, i8* %c1, align 1
  %5 = call i32 @getchar()
  %6 = trunc i32 %5 to i8
  store i8 %6, i8* %nl, align 1
  %7 = load i8* %c1, align 1
  %8 = sext i8 %7 to i32
  switch i32 %8, label %15 [
    i32 113, label %9
    i32 101, label %10
  ]

; <label>:9                                       ; preds = %2
  ret i32 0

; <label>:10                                      ; preds = %2
  call void @expired(i8* %e)
  %11 = load i8* %e, align 1
  %12 = trunc i8 %11 to i1
  %13 = zext i1 %12 to i32
  %14 = call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([4 x i8]* @.str, i32 0, i32 0), i32 %13)
  br label %15

; <label>:15                                      ; preds = %10, %2
  br label %2
}

declare i32 @getchar()

declare i32 @printf(i8*, ...)
