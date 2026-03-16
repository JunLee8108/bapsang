# 로그인 후 추천 페이지 구현 계획

## 현재 상태
- 로그인(Apple/Google) ✅ 완료
- RootView → 인증 시 MainTabView로 라우팅 ✅ 완료
- MainTabView의 "추천" 탭 → PlaceholderView (임시) ⏳ 교체 필요

## 구현 목표
로그인 후 첫 화면인 **추천 페이지(RecommendationView)** 를 만든다.
사용자가 식재료를 선택하면 AI가 한식 1인분 레시피를 추천하는 흐름의 시작점.

---

## 구현 단계

### Step 1: RecommendationView 생성
**파일**: `Bapsang/Features/Recommendation/RecommendationView.swift`

- 환영 인사 섹션 (사용자 이름 또는 "오늘 뭐 먹지?")
- 오늘의 추천 카테고리 카드 (예: 국/찌개, 볶음, 밥류, 면류 등)
- "식재료 선택하러 가기" CTA 버튼
- 최근 본 레시피 섹션 (빈 상태 UI 포함)
- 디자인: 기존 LoginView의 오렌지 그라데이션 톤 유지

### Step 2: RecommendationViewModel 생성
**파일**: `Bapsang/Features/Recommendation/RecommendationViewModel.swift`

- `@Observable` 클래스
- 추천 카테고리 데이터
- 인사말 생성 (시간대별: 아침/점심/저녁)
- 향후 Supabase에서 최근 레시피 로드 준비

### Step 3: 카테고리 모델 생성
**파일**: `Bapsang/Models/RecipeCategory.swift`

- `RecipeCategory` struct (id, name, icon, description)
- 기본 한식 카테고리 데이터 (국/찌개, 볶음, 밥, 면, 반찬, 일품요리)

### Step 4: 재사용 컴포넌트 생성
**파일**: `Bapsang/Components/CategoryCard.swift`

- 카테고리 카드 UI 컴포넌트
- 아이콘 + 이름 + 간단 설명
- 탭 시 식재료 선택 화면으로 이동 준비 (Phase 2)

### Step 5: MainTabView 업데이트
**파일**: `Bapsang/Core/MainTabView.swift`

- 첫 번째 탭의 PlaceholderView → RecommendationView로 교체
- NavigationStack 유지

### Step 6: EmptyStateView 컴포넌트 생성
**파일**: `Bapsang/Components/EmptyStateView.swift`

- 저장된 레시피나 최근 기록이 없을 때 표시할 빈 상태 뷰
- 아이콘 + 메시지 + 선택적 액션 버튼

---

## 파일 변경 요약

| 작업 | 파일 | 유형 |
|------|------|------|
| 생성 | `Features/Recommendation/RecommendationView.swift` | 새 파일 |
| 생성 | `Features/Recommendation/RecommendationViewModel.swift` | 새 파일 |
| 생성 | `Models/RecipeCategory.swift` | 새 파일 |
| 생성 | `Components/CategoryCard.swift` | 새 파일 |
| 생성 | `Components/EmptyStateView.swift` | 새 파일 |
| 수정 | `Core/MainTabView.swift` | PlaceholderView → RecommendationView |

---

## UI 와이어프레임 (ASCII)

```
┌─────────────────────────────┐
│  NavigationBar: "오늘 뭐 먹지?"  │
├─────────────────────────────┤
│                             │
│  🌙 좋은 저녁이에요!           │
│  오늘은 뭘 만들어 볼까요?       │
│                             │
├─────────────────────────────┤
│  오늘의 추천 카테고리           │
│                             │
│  ┌──────┐ ┌──────┐         │
│  │ 🍲   │ │ 🥘   │         │
│  │국/찌개│ │ 볶음  │         │
│  └──────┘ └──────┘         │
│  ┌──────┐ ┌──────┐         │
│  │ 🍚   │ │ 🍜   │         │
│  │ 밥류  │ │ 면류  │         │
│  └──────┘ └──────┘         │
│  ┌──────┐ ┌──────┐         │
│  │ 🥗   │ │ 🍳   │         │
│  │ 반찬  │ │일품요리│         │
│  └──────┘ └──────┘         │
│                             │
├─────────────────────────────┤
│  ┌─────────────────────┐    │
│  │ 🥕 식재료 선택하기    │    │
│  │   (CTA 버튼)         │    │
│  └─────────────────────┘    │
│                             │
├─────────────────────────────┤
│  최근 본 레시피              │
│  ┌─────────────────────┐    │
│  │  📭 아직 본 레시피가   │    │
│  │     없어요            │    │
│  └─────────────────────┘    │
│                             │
├─────────────────────────────┤
│ [🍽 추천] [📖 저장] [⚙ 설정] │
└─────────────────────────────┘
```

## 디자인 원칙
- 기존 앱의 오렌지 그라데이션 + `.ultraThinMaterial` 스타일 유지
- `@Observable` 패턴 사용 (iOS 17+)
- 한국어 UI 텍스트
- 애니메이션: 카드 등장 시 stagger 효과
