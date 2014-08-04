; ModuleID = 'exttype.cpp'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.7.4"

%class.t1 = type opaque

@c1 = external global %class.t1

define i32 @_Z8t2_of_t1R2t1P2e1(%class.t1* %v, i32* %p1) uwtable ssp {
  %1 = alloca i32, align 4
  %2 = alloca %class.t1*, align 8
  %3 = alloca i32*, align 8
  store %class.t1* %v, %class.t1** %2, align 8
  store i32* %p1, i32** %3, align 8
  %4 = load i32** %3, align 8
  store i32 0, i32* %4
  %5 = load %class.t1** %2, align 8
  %6 = call zeroext i1 @_ZeqR2t1S0_(%class.t1* %5, %class.t1* @c1)
  br i1 %6, label %7, label %8

; <label>:7                                       ; preds = %0
  store i32 0, i32* %1
  br label %9

; <label>:8                                       ; preds = %0
  store i32 1, i32* %1
  br label %9

; <label>:9                                       ; preds = %8, %7
  %10 = load i32* %1
  ret i32 %10
}

declare zeroext i1 @_ZeqR2t1S0_(%class.t1*, %class.t1*)
