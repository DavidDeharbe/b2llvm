; ModuleID = 'pg8.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64"
target triple = "x86_64-apple-darwin10.8"

%0 = type { %struct.anon*, %struct.anon* }
%struct.anon = type { float, float }

define void @dx(%struct.anon* %m, float %d) nounwind ssp {
entry:
  %m_addr = alloca %struct.anon*, align 8         ; <%struct.anon**> [#uses=3]
  %d_addr = alloca float, align 4                 ; <float*> [#uses=2]
  %"alloca point" = bitcast i32 0 to i32          ; <i32> [#uses=0]
  store %struct.anon* %m, %struct.anon** %m_addr
  store float %d, float* %d_addr
  %0 = load %struct.anon** %m_addr, align 8       ; <%struct.anon*> [#uses=1]
  %1 = getelementptr inbounds %struct.anon* %0, i32 0, i32 0 ; <float*> [#uses=1]
  %2 = load float* %1, align 4                    ; <float> [#uses=1]
  %3 = load float* %d_addr, align 4               ; <float> [#uses=1]
  %4 = fadd float %2, %3                          ; <float> [#uses=1]
  %5 = load %struct.anon** %m_addr, align 8       ; <%struct.anon*> [#uses=1]
  %6 = getelementptr inbounds %struct.anon* %5, i32 0, i32 0 ; <float*> [#uses=1]
  store float %4, float* %6, align 4
  br label %return

return:                                           ; preds = %entry
  ret void
}

define void @segment_dx(%0* %s, float %d) nounwind ssp {
entry:
  %s_addr = alloca %0*, align 8                   ; <%0**> [#uses=3]
  %d_addr = alloca float, align 4                 ; <float*> [#uses=3]
  %"alloca point" = bitcast i32 0 to i32          ; <i32> [#uses=0]
  store %0* %s, %0** %s_addr
  store float %d, float* %d_addr
  %0 = load %0** %s_addr, align 8                 ; <%0*> [#uses=1]
  %1 = getelementptr inbounds %0* %0, i32 0, i32 0 ; <%struct.anon**> [#uses=1]
  %2 = load %struct.anon** %1, align 8            ; <%struct.anon*> [#uses=1]
  %3 = load float* %d_addr, align 4               ; <float> [#uses=1]
  call void @dx(%struct.anon* %2, float %3) nounwind ssp
  %4 = load %0** %s_addr, align 8                 ; <%0*> [#uses=1]
  %5 = getelementptr inbounds %0* %4, i32 0, i32 1 ; <%struct.anon**> [#uses=1]
  %6 = load %struct.anon** %5, align 8            ; <%struct.anon*> [#uses=1]
  %7 = load float* %d_addr, align 4               ; <float> [#uses=1]
  call void @dx(%struct.anon* %6, float %7) nounwind ssp
  br label %return

return:                                           ; preds = %entry
  ret void
}
