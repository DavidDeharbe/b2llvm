; ModuleID = 'obj.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64"
target triple = "x86_64-apple-darwin11.4"

%struct.impl1 = type { i32, i32, i8 }
%struct.impl2 = type { i32, %struct.impl1*, %struct.impl1* }

@instance = common global %struct.impl1 zeroinitializer ; <%struct.impl1*> [#uses=0]
@impl1_anonymous = common global %struct.impl1* null ; <%struct.impl1**> [#uses=0]
@impl2_anonymous = common global %struct.impl2* null ; <%struct.impl2**> [#uses=0]

define void @op1(%struct.impl1* %a) nounwind ssp {
entry:
  %a_addr = alloca %struct.impl1*, align 8        ; <%struct.impl1**> [#uses=3]
  %"alloca point" = bitcast i32 0 to i32          ; <i32> [#uses=0]
  store %struct.impl1* %a, %struct.impl1** %a_addr
  %0 = load %struct.impl1** %a_addr, align 8      ; <%struct.impl1*> [#uses=1]
  %1 = getelementptr inbounds %struct.impl1* %0, i32 0, i32 0 ; <i32*> [#uses=1]
  %2 = load i32* %1, align 4                      ; <i32> [#uses=1]
  %3 = add nsw i32 %2, 1                          ; <i32> [#uses=1]
  %4 = load %struct.impl1** %a_addr, align 8      ; <%struct.impl1*> [#uses=1]
  %5 = getelementptr inbounds %struct.impl1* %4, i32 0, i32 0 ; <i32*> [#uses=1]
  store i32 %3, i32* %5, align 4
  br label %return

return:                                           ; preds = %entry
  ret void
}

define void @op2(%struct.impl1* %a, i32* %r) nounwind ssp {
entry:
  %a_addr = alloca %struct.impl1*, align 8        ; <%struct.impl1**> [#uses=2]
  %r_addr = alloca i32*, align 8                  ; <i32**> [#uses=2]
  %"alloca point" = bitcast i32 0 to i32          ; <i32> [#uses=0]
  store %struct.impl1* %a, %struct.impl1** %a_addr
  store i32* %r, i32** %r_addr
  %0 = load %struct.impl1** %a_addr, align 8      ; <%struct.impl1*> [#uses=1]
  %1 = getelementptr inbounds %struct.impl1* %0, i32 0, i32 0 ; <i32*> [#uses=1]
  %2 = load i32* %1, align 4                      ; <i32> [#uses=1]
  %3 = load i32** %r_addr, align 8                ; <i32*> [#uses=1]
  store i32 %2, i32* %3, align 4
  br label %return

return:                                           ; preds = %entry
  ret void
}

define void @op3(%struct.impl2* %a) nounwind ssp {
entry:
  %a_addr = alloca %struct.impl2*, align 8        ; <%struct.impl2**> [#uses=3]
  %"alloca point" = bitcast i32 0 to i32          ; <i32> [#uses=0]
  store %struct.impl2* %a, %struct.impl2** %a_addr
  %0 = load %struct.impl2** %a_addr, align 8      ; <%struct.impl2*> [#uses=1]
  %1 = getelementptr inbounds %struct.impl2* %0, i32 0, i32 1 ; <%struct.impl1**> [#uses=1]
  %2 = load %struct.impl1** %1, align 8           ; <%struct.impl1*> [#uses=1]
  call void @op1(%struct.impl1* %2) nounwind ssp
  %3 = load %struct.impl2** %a_addr, align 8      ; <%struct.impl2*> [#uses=1]
  %4 = getelementptr inbounds %struct.impl2* %3, i32 0, i32 2 ; <%struct.impl1**> [#uses=1]
  %5 = load %struct.impl1** %4, align 8           ; <%struct.impl1*> [#uses=1]
  call void @op1(%struct.impl1* %5) nounwind ssp
  br label %return

return:                                           ; preds = %entry
  ret void
}
