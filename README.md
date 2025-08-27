# FFT Fixed Project

---

## 요약
512-point FFT를 SystemVerilog로 RTL 구현하고 CBFP(Convergent Block Floating Point)를 적용하여 fixed-point 환경에서 성능(quantization, SQNR)을 개선한 후 Vivado로 합성·시뮬레이션·FPGA 검증을 수행한 프로젝트입니다.

---

## 목차
- [프로젝트 개요](#프로젝트-개요)  
- [블록 다이어그램 / 모듈 구조](#블록-다이어그램--모듈-구조)  
- [타이밍 요약](#타이밍-요약)  
- [RTL 시뮬레이션 결과 요약](#rtl-시뮬레이션-결과-요약)  
- [합성(Synthesis) & 구현(Implementation)](#합성synthesis--구현implementation)  
- [Gate Simulation & Trouble Shooting](#gate-simulation--trouble-shooting)  
- [FPGA 검증 요약](#fpga-검증-요약)  
- [결론 및 고찰](#결론-및-고찰)  
---

## 프로젝트 개요
- **목표**: 512-point FFT를 SystemVerilog로 구현하고 CBFP를 적용하여 fixed 환경에서 비트 성장(bit growth)을 제어하고 SQNR 향상을 검증.  
- **핵심요소**
  - Butterfly 연산(복소수 덧셈/뺄셈)
  - Twiddle factor 곱셈
  - Shift registers / 파이프라인 단계
  - CBFP 적용으로 블록 단위 공통지수 사용 → 양자화 손실 감소 및 효율적 연산
- **주요 결과**: CBFP 적용으로 SQNR이 유의미하게 향상(슬라이드 기반 비교 결과 기준). :contentReference[oaicite:0]{index=0}

---

## 블록 다이어그램 / 모듈 구조
- 최상위 모듈: `TOP_FFT_FIXED`
- 주요 서브모듈:
  - `module0`, `module1`, `module2` (stage 별 파이프라인 블록)
  - `bfly`, `bfly_v2` (butterfly)
  - `twd_mul`, `twd_mul2` (twiddle 곱셈)
  - shift reg 모듈들
- 데이터 흐름: `input -> shift -> butterfly -> twiddle -> 다음 stage` 형태의 파이프라인 구조.

---

## 타이밍 요약
- 전체 지연(latency): **79 clock cycles** (입력 `din_valid` → 출력 `dout_en`) — TOP 레벨 측정값.  
- valid 신호 동기화가 매우 중요함(데이터 유효성 흐름과 타이밍의 정확성 필요).

---

## RTL 시뮬레이션 결과 요약
- 각 모듈별 step/valid 체인 확인:
  - Module0: `din_valid` → `bfly_00_valid` → `twd_00_valid` → `shift_01_valid` → ...
  - Module1 / Module2: 유사한 valid 체인으로 최종 `dout_valid` 발생.
- 테스트 벡터(`cos`, `ran` 등)로 MATLAB 결과(재정렬 포함)와 실수/허수 결과 일치 검증 완료. :contentReference[oaicite:1]{index=1}

---

## 합성(Synthesis) & 구현(Implementation)
- 도구: **Xilinx Vivado** (슬라이드 기준)
- 합성 후 리소스:
  - DSP 사용률(주요 병목 자원): 약 **22%** (곱셈 중심 구조)  
- Vivado 구현 후 Setup/Hold 타이밍 만족 확인. :contentReference[oaicite:2]{index=2}

---

## Gate Simulation & Trouble Shooting
### 주요 이슈
1. `Unconnected` 신호 다수 발견 → 데이터 손실/예상치 못한 동작.  
2. 파형 중 `glitch` 발생 → 임시/조합 논리 문제.  
3. 합성으로 인한 `latch` 생성 → 의도치 않은 상태 보유.  
4. Setup Time 관련 문제 관찰.

### 시도한 해결책
- 초기값(initialization) 추가로 Unconnected 감소.  
- 조합/순차 논리를 분리하여 glitch 완화 시도.  
- `if`문에 `else` 추가로 latch 생성 방지.  
- 최종적으로 Butterfly(순차)와 Twiddle(조합) 사이에 **1CLK delay** 삽입하여 쓰레기 값(garbage output)을 제거하고 안정화. :contentReference[oaicite:3]{index=3}

---

## FPGA 검증 요약
- `cos_gen` 유효성: 32CLK 동안 cos 값 유효(주기성 관찰).  
- RTL 시뮬레이션 중 일부 tail 데이터(약 16개)가 소실되는 현상 관찰 → 디버깅 후 개선.  
- Vivado 기반 실제 구현에서 타이밍 조건을 만족시키며 정상 동작 확인. :contentReference[oaicite:4]{index=4}

---

## 결론 및 고찰
- 512-point FFT RTL 구현 및 FPGA 검증 완료.  
- CBFP 적용을 통해 fixed-point 환경에서의 SQNR 개선을 달성.  
- 파이프라인 설계에서 `valid` 신호와 데이터 흐름의 동기화가 가장 중요함을 확인.  
- 시뮬레이션 단계별 중간값 로그가 문제 추적에 결정적 도움을 줌.

---

## 리포지토리 구조 (권장)
