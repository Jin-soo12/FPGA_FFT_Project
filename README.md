# 512-Fixed Point FFT H/W Project

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
- [FPGA 검증 요약](#fpga-검증-요약)  
- [Trouble Shooting](#Trouble-Shooting)  
- [결론 및 고찰](#결론-및-고찰)  
---

## 프로젝트 개요
 ### 목표
- 512-point FFT 및 CBFP 알고리즘에 관한 논문을 분석.
- MATLAB 및 SystemVerilog로 구현하여 MATLAB에서의 결과와 SystemVerilog(하드웨어)로 구현한 모듈의 결과가 일치함을 확인.
- Synthesis를 통한 Setup Time 부합 및 Total Area 확인.

 ### 핵심요소
 
 **Radix-2^2 DIF FFT**
 
<img width="525" height="659" alt="image" src="https://github.com/user-attachments/assets/c30e3fef-d714-4749-b636-c0802e6f58d4" />

  - Butterfly 연산(복소수 덧셈/뺄셈)
  - Twiddle factor 곱셈
  - Shift registers / 파이프라인 단계

**CBFP(Convergent Block Floating Point)**

  <img width="1147" height="435" alt="image" src="https://github.com/user-attachments/assets/340f7375-e785-453e-838b-dc0eb5a41d33" />

  - 양자화 노이즈 감소 → SNR(SQNR) 향상
  - CBFP 미적용 구조에 비해 약 16dB 상승

---

## 블록 다이어그램 / 모듈 구조
<p align="center">
  <img width="1757" height="482" alt="image" src="https://github.com/user-attachments/assets/0367728b-6859-474d-8d49-ce1eb3fc3e1f" />
</p>

- 최상위 모듈: `TOP_FFT_FIXED`
- 주요 서브모듈:
  - `module0`, `module1`, `module2` (stage 별 파이프라인 블록)
  - `bfly`, `bfly_v2` (butterfly)
  - `twd_mul`, `twd_mul2` (twiddle 곱셈)
  - shift reg 모듈들
- 데이터 흐름: `input -> shift -> butterfly -> twiddle -> 다음 stage` 형태의 파이프라인 구조.

---

## 타이밍 요약
<p align="center">
<img width="1663" height="318" alt="image" src="https://github.com/user-attachments/assets/7c460a30-d7d0-4e03-9c39-47aa95ec6337" />
</p>

- 전체 지연(latency): **79 clock cycles** (입력 `din_valid` → 출력 `dout_en`) — TOP 레벨 측정값.  
- valid 신호 동기화가 매우 중요함(데이터 유효성 흐름과 타이밍의 정확성 필요).

---

## RTL 시뮬레이션 결과 요약
<p align="center">
<img width="1662" height="377" alt="image" src="https://github.com/user-attachments/assets/610faefb-745f-4121-afb6-a7f36e242c77" />
</p>
<p align="center">
<img width="1662" height="238" alt="image" src="https://github.com/user-attachments/assets/acab1b50-c4ea-4f91-8ca6-dbc32c2cb80d" />
</p>
<p align="center">
  <img width="1688" height="599" alt="image" src="https://github.com/user-attachments/assets/b5049674-e3bb-4d60-b6d7-5672e6bba75b" />
  </p>
  
- 각 모듈별 step/valid 체인 확인:
  - Module0: `din_valid` → `bfly_00_valid` → `twd_00_valid` → `shift_01_valid` → ...
  - Module1 / Module2: 유사한 valid 체인으로 최종 `dout_valid` 발생.
- 테스트 벡터(`cos`, `ran` 등)로 MATLAB 결과(재정렬 포함)와 실수/허수 결과 일치 검증 완료.

---

## 합성(Synthesis) & 구현(Implementation)
- 32CLK Data in / 8CLK Data Blocking의 동작을 하는 Cos Generator로 이번 프로젝트에서 설계한 FFT 모듈의 정상 동작 확인 

### FPGA Block Diagram
<p align="center">
<img width="1660" height="536" alt="image" src="https://github.com/user-attachments/assets/3b09c99a-95c1-440e-b5d4-1da7d06a57ec" />
</p>

### FPGA Cos Gen RTL
<p align="center">
  <img width="1646" height="542" alt="image" src="https://github.com/user-attachments/assets/b43eb973-494c-4d35-8261-761749884b90" />
</p>

### FPGA FFT RTL
<p align="center">
<img width="1701" height="76" alt="image" src="https://github.com/user-attachments/assets/82bc08f6-371c-42bc-94d1-ae75b3d11bce" />
</p>

### Synthesis Result
<p align="center">
<img width="1531" height="387" alt="image" src="https://github.com/user-attachments/assets/fe262774-5336-4fa9-8833-42b591011dbb" />
  </p>

  <p align="center">
<img width="1376" height="488" alt="image" src="https://github.com/user-attachments/assets/bc35554c-5e7c-4b92-9f1b-7ceb6ceb2c4a" />
</p>


- 도구: **Xilinx Vivado**
- 합성 후 리소스:
  - DSP 사용률(주요 병목 자원): 약 **22%** (곱셈 중심 구조)  
- Vivado 구현 후 Setup/Hold 타이밍 만족 확인 완료.

---

## FPGA 검증 요약
- `cos_gen` 유효성: 32CLK 동안 cos 값 유효(주기성 관찰).  
- Vivado 기반 실제 구현에서 타이밍 조건을 만족시키며 정상 동작 확인.

---

## Trouble Shooting
### 문제점
<p align="center">
<img width="1584" height="259" alt="image" src="https://github.com/user-attachments/assets/49fbf90e-dde3-4682-9ac7-6490005d29a0" />
</p>

- Butterfly계산 후 Twiddle 계산에서 항상 1CLK의 쓰레기 값이 출력되는 현상 발생.

### 해결책
<p align="center">
<img width="1566" height="276" alt="image" src="https://github.com/user-attachments/assets/c251422c-4e64-46d2-a700-6bfab5e65574" />
</p>

- 순차 논리인 Betterfly계산과 조합논리인 Twiddle 계산 사이에 1CLK의 Delay를 넣어 순차와 조합 간의 타이밍을 맞춰주어 해결.

---

## 결론 및 고찰
- 512-point FFT RTL 구현 및 FPGA 검증 완료.  
- CBFP 적용을 통해 fixed-point 환경에서의 SQNR 개선을 달성.  
- 파이프라인 설계에서 `valid` 신호와 데이터 흐름의 동기화가 가장 중요함을 확인.  
- 시뮬레이션 단계별 중간값 로그가 문제 추적에 결정적 도움을 줌.
