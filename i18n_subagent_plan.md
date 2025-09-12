# Flitz i18n 리팩토링 계획

## 🚨 현재 문제 상황

- **Text("한국어")** 형태로 하드코딩된 텍스트가 코드베이스 전반에 산재
- **NSLocalizedString("한국어")** 일부는 한국어 키로 되어 있음  
- **xcstrings 파일**에는 구조화된 키(ui.*, fzapi.*)와 한국어 키가 뒤섞여 있음
- 총 1000+ 라인의 xcstrings 파일에 약 500+ 개의 키가 정리되지 않은 상태

## 🎯 전체 전략 (4단계)

### 1단계: 현황 완전 파악
**목표**: 모든 하드코딩된 텍스트의 위치와 내용을 파악

**작업 내용**:
- 모든 소스 파일에서 `Text("한국어")`, `NSLocalizedString("한국어")` 패턴 추출
- 디렉토리별로 텍스트들 분류 및 카테고리 정리
- 기존 xcstrings의 키 구조 분석

**예상 결과물**:
```
ui/screen/auth/: 25개 텍스트 (로그인, 회원가입, 비밀번호 찾기)
ui/screen/messaging/: 15개 텍스트 (채팅, 대화 목록)
ui/view/safety/: 30개 텍스트 (신고, 차단, 안전 기능)
ui/: 10개 텍스트 (탭바, 공통 UI)
```

### 2단계: 키 네이밍 규칙 수립
**목표**: 일관성 있는 키 네이밍 컨벤션 확립

**네이밍 규칙**:
```
{scope}.{section}.{key}

scope:
- ui: 사용자 인터페이스 관련
- api: API 에러/응답 관련
- core: 핵심 비즈니스 로직 관련

section 예시:
- ui.tab.* : 탭바 관련
- ui.auth.* : 인증 관련
- ui.messaging.* : 메시징 관련
- ui.safety.* : 신고/안전 관련
- ui.mypage.* : 마이페이지 관련
- ui.settings.* : 설정 관련
```

**키 네이밍 예시**:
```
ui.tab.wave → "웨이브"
ui.tab.message → "메시지"
ui.tab.store → "스토어"
ui.tab.profile → "프로필"

ui.auth.signin.title → "로그인"
ui.auth.signin.failure → "로그인 실패"
ui.auth.signup.title → "회원가입"

ui.safety.report.harassment → "다른 사용자를 괴롭히거나, 공격적인 내용을 담고 있어요"
ui.safety.report.sexual_content → "음란물이나 성적 수치심을 주는 내용을 담고 있어요"
```

### 3단계: 분할정복 실행
**목표**: Task 에이전트를 활용한 병렬 처리로 효율적 리팩토링

**디렉토리별 에이전트 할당**:

1. **AuthAgent**: `ui/screen/auth/` 담당
   - 로그인, 회원가입, 비밀번호 관련 텍스트 처리
   - 예상 키: ui.auth.*

2. **MessagingAgent**: `ui/screen/messaging/`, `ui/view/messaging/` 담당  
   - 채팅, 대화목록 관련 텍스트 처리
   - 예상 키: ui.messaging.*

3. **SafetyAgent**: `ui/view/safety/` 담당
   - 신고, 차단, 사용자 보호 관련 텍스트 처리
   - 예상 키: ui.safety.*

4. **UIAgent**: `ui/` (루트), `ui/view/` (공통) 담당
   - 탭바, 공통 UI 요소 텍스트 처리
   - 예상 키: ui.tab.*, ui.common.*

5. **MypageAgent**: `ui/screen/mypage/`, `ui/screen/settings/` 담당
   - 마이페이지, 설정 관련 텍스트 처리
   - 예상 키: ui.mypage.*, ui.settings.*

**각 에이전트의 작업 프로세스**:
1. 할당된 디렉토리의 모든 Swift 파일 스캔
2. 하드코딩된 한국어 텍스트 식별
3. 네이밍 규칙에 따라 새로운 키 생성
4. 코드에서 하드코딩된 텍스트를 NSLocalizedString 호출로 대체
5. 새로운 키-값 쌍 목록 반환

### 4단계: xcstrings 파일 대대적 정리
**목표**: 일관성 있는 최종 xcstrings 파일 완성

**작업 내용**:
1. 3단계에서 각 에이전트가 생성한 키-값 쌍들을 xcstrings에 일괄 추가
2. 기존 한국어 키들을 새로운 구조화된 키로 매핑
3. 중복되거나 사용하지 않는 키들 제거
4. 알파벳순으로 키 정렬

**정리 후 예상 구조**:
```json
{
  "sourceLanguage": "ko",
  "strings": {
    "core.country.kr": { ... },
    "core.country.other": { ... },
    "ui.auth.signin.title": {
      "comment": "로그인",
      "localizations": {
        "ko": {
          "stringUnit": {
            "state": "translated",
            "value": "로그인"
          }
        }
      }
    },
    "ui.tab.wave": { ... },
    "ui.tab.message": { ... }
  }
}
```

## 📋 실행 체크리스트

### Phase 1: 준비
- [ ] 전체 소스코드 하드코딩 텍스트 패턴 완전 파악
- [ ] 키 네이밍 컨벤션 최종 확정
- [ ] 디렉토리별 작업 범위 명확히 정의

### Phase 2: 병렬 리팩토링  
- [ ] AuthAgent 실행 (ui/screen/auth/)
- [ ] MessagingAgent 실행 (ui/screen/messaging/, ui/view/messaging/)
- [ ] SafetyAgent 실행 (ui/view/safety/)
- [ ] UIAgent 실행 (ui/ 루트, ui/view/ 공통)
- [ ] MypageAgent 실행 (ui/screen/mypage/, ui/screen/settings/)

### Phase 3: 통합 및 정리
- [ ] 모든 에이전트 결과물 통합
- [ ] xcstrings 파일 대대적 정리
- [ ] 중복 키 제거 및 정렬

### Phase 4: 검증
- [ ] 빌드 테스트 (컴파일 에러 확인)
- [ ] 기능 테스트 (텍스트가 올바르게 표시되는지)
- [ ] 누락된 텍스트 없는지 최종 점검

## ⚠️ 주의사항

1. **백업**: 작업 전 현재 상태 git commit
2. **점진적 접근**: 한 번에 모든 걸 바꾸지 말고 단계별로 검증
3. **컨텍스트 윈도우**: Task 에이전트를 적극 활용해 메모리 효율성 확보
4. **일관성**: 네이밍 컨벤션을 철저히 준수
5. **테스트**: 각 단계마다 빌드 테스트로 검증

## 🎯 기대 효과

- 🗂️ **체계적인 i18n 관리**: 모든 텍스트가 구조화된 키로 관리
- 🔍 **유지보수성 향상**: 텍스트 수정 시 xcstrings 파일만 수정하면 됨  
- 🌏 **다국어 준비**: 향후 영어/일본어 지원 시 쉽게 확장 가능
- 📱 **개발 효율성**: 하드코딩된 텍스트 찾기 위해 코드 뒤지지 않아도 됨

---

*이 문서는 Flitz i18n 리팩토링 작업의 마스터 플랜입니다. 각 단계별로 체크리스트를 업데이트하며 진행해주세요.*