# 커뮤니티 기능 구현 계획

## 개요
사용자들이 자신의 레시피를 공유하고, 댓글/좋아요/신고 기능을 통해 소통하며,
활발한 활동에 대해 배지를 부여하는 커뮤니티 기능.

---

## 1단계: 데이터베이스 (Supabase Migration)

### 새로운 테이블

#### `community_posts` - 커뮤니티 게시물
| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | UUID (PK) | 게시물 ID |
| user_id | UUID (FK → auth.users) | 작성자 |
| title | TEXT | 제목 |
| description | TEXT | 설명 |
| ingredients | JSONB | 재료 목록 |
| steps | JSONB | 조리 단계 |
| cooking_time | INT | 조리 시간(분) |
| difficulty | TEXT | 난이도 (easy/medium/hard) |
| serving_size | INT | 인분 |
| image_url | TEXT | 레시피 이미지 URL (Supabase Storage) |
| likes_count | INT (default 0) | 좋아요 수 (비정규화) |
| comments_count | INT (default 0) | 댓글 수 (비정규화) |
| is_hidden | BOOL (default false) | 신고로 숨김 처리 여부 |
| created_at | TIMESTAMPTZ | 작성일 |

#### `community_likes` - 좋아요
| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | UUID (PK) | |
| user_id | UUID (FK) | 좋아요 누른 사용자 |
| post_id | UUID (FK → community_posts) | 대상 게시물 |
| created_at | TIMESTAMPTZ | |
- UNIQUE(user_id, post_id) — 중복 좋아요 방지

#### `community_comments` - 댓글
| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | UUID (PK) | |
| user_id | UUID (FK) | 작성자 |
| post_id | UUID (FK → community_posts) | 대상 게시물 |
| content | TEXT | 댓글 내용 |
| created_at | TIMESTAMPTZ | |

#### `community_reports` - 신고
| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | UUID (PK) | |
| reporter_id | UUID (FK) | 신고자 |
| post_id | UUID (FK → community_posts) | 대상 게시물 |
| reason | TEXT | 신고 사유 |
| created_at | TIMESTAMPTZ | |
- UNIQUE(reporter_id, post_id) — 중복 신고 방지

#### `public.users` 확장 컬럼 (커뮤니티용)
> `user_profiles` 테이블은 `public.users`에 통합됨 — 별도 테이블 없음

| 컬럼 | 타입 | 설명 |
|------|------|------|
| display_name | TEXT (default 'Chef') | 닉네임 |
| total_likes_received | INT (default 0) | 총 받은 좋아요 수 |
| total_posts | INT (default 0) | 총 게시물 수 |
| badges | JSONB (default []) | 획득한 배지 목록 |

### RLS 정책
- 모든 인증된 사용자: 게시물/댓글/좋아요 읽기 가능
- 본인만: 자기 게시물/댓글 생성/삭제, 좋아요 토글, 신고 생성
- 신고 3건 이상 → `is_hidden = true` 자동 처리 (DB trigger)

### DB Trigger / Function
- 좋아요 생성/삭제 시 → `community_posts.likes_count` 업데이트 + `public.users.total_likes_received` 업데이트
- 댓글 생성/삭제 시 → `community_posts.comments_count` 업데이트
- 게시물 생성 시 → `public.users.total_posts` 업데이트
- 좋아요 수 기준 배지 자동 부여 (trigger)

---

## 2단계: 배지 시스템

### 배지 종류
| 배지 | 조건 | 아이콘 |
|------|------|--------|
| 🌱 새싹 요리사 | 첫 게시물 작성 | seedling |
| 🔥 인기 요리사 | 총 좋아요 10개 달성 | flame |
| ⭐ 스타 요리사 | 총 좋아요 50개 달성 | star.fill |
| 👑 마스터 셰프 | 총 좋아요 100개 달성 | crown.fill |
| 📝 다작 요리사 | 게시물 10개 작성 | pencil.and.list.clipboard |

---

## 3단계: Swift 모델 (Models/)

### 새로운 파일
- `Models/CommunityPost.swift` — 게시물 모델
- `Models/CommunityComment.swift` — 댓글 모델
- `Models/UserProfile.swift` — 프로필 + 배지 모델 (public.users에서 조회)
- `Models/Badge.swift` — 배지 enum 정의

---

## 4단계: 서비스 레이어 (Services/)

### `Services/CommunityService.swift`
- `fetchPosts(sortBy:)` — 게시물 목록 (최신순/인기순)
- `fetchPost(id:)` — 게시물 상세
- `createPost(...)` — 게시물 작성
- `deletePost(id:)` — 게시물 삭제
- `toggleLike(postId:)` — 좋아요 토글
- `fetchComments(postId:)` — 댓글 목록
- `addComment(postId:, content:)` — 댓글 작성
- `deleteComment(id:)` — 댓글 삭제
- `reportPost(postId:, reason:)` — 신고
- `fetchUserProfile(userId:)` — 프로필 조회 (public.users 테이블)
- `checkIfLiked(postId:)` — 좋아요 여부 확인

---

## 5단계: 뷰 & 뷰모델 (Features/Community/)

### 화면 구성

#### 5-1. 커뮤니티 메인 (`CommunityView.swift`)
- 상단: 정렬 옵션 (최신순 / 인기순)
- 게시물 카드 리스트 (이미지, 제목, 좋아요 수, 댓글 수, 작성자 배지)
- 우하단: 글쓰기 FAB 버튼
- Pull-to-refresh

#### 5-2. 게시물 상세 (`CommunityPostDetailView.swift`)
- 레시피 이미지
- 제목, 설명, 재료, 조리 단계
- 좋아요 버튼 (❤️ 토글)
- 댓글 섹션 (목록 + 입력창)
- 신고 버튼 (... 메뉴)
- 작성자 본인이면 삭제 버튼

#### 5-3. 게시물 작성 (`CommunityCreatePostView.swift`)
- 이미지 선택 (PhotosPicker)
- 제목, 설명 입력
- 재료 동적 추가/삭제
- 조리 단계 동적 추가/삭제
- 난이도, 조리 시간, 인분 선택
- 등록 버튼

#### 5-4. 뷰모델 (`CommunityViewModel.swift`)
- 게시물 목록 관리, 정렬, 페이지네이션
- 좋아요/댓글/신고 액션 처리
- 게시물 작성 로직

---

## 6단계: 네비게이션 수정

### `Core/MainTabView.swift` 수정
현재 3탭 → 4탭으로 변경:
1. **추천** (fork.knife) → RecommendationView
2. **커뮤니티** (bubble.left.and.bubble.right) → CommunityView ← **새로 추가**
3. **저장** (bookmark) → PlaceholderView
4. **설정** (gearshape) → SettingsView

---

## 7단계: 이미지 업로드 (Supabase Storage)

- Supabase Storage에 `community-images` 버킷 생성
- 이미지 리사이징 후 업로드
- public URL 반환하여 `community_posts.image_url`에 저장

---

## 구현 순서 (작업 순서)

1. **DB 마이그레이션 SQL 작성** — 테이블, RLS, 트리거
2. **Swift 모델 생성** — CommunityPost, Comment, UserProfile, Badge
3. **CommunityService 구현** — Supabase CRUD
4. **CommunityViewModel 구현** — 비즈니스 로직
5. **CommunityView (메인 목록)** — 게시물 카드 리스트
6. **CommunityPostDetailView** — 상세 + 댓글 + 좋아요
7. **CommunityCreatePostView** — 게시물 작성 폼
8. **MainTabView 수정** — 커뮤니티 탭 추가
9. **배지 로직 연결** — 프로필에 배지 표시

---

## 파일 구조 (최종)

```
Bapsang/
├── Features/
│   └── Community/
│       ├── CommunityView.swift              # 메인 목록
│       ├── CommunityPostDetailView.swift     # 게시물 상세
│       ├── CommunityCreatePostView.swift     # 게시물 작성
│       ├── CommunityPostCard.swift           # 게시물 카드 컴포넌트
│       └── CommunityViewModel.swift          # 뷰모델
├── Models/
│   ├── CommunityPost.swift
│   ├── CommunityComment.swift
│   ├── UserProfile.swift
│   └── Badge.swift
├── Services/
│   └── CommunityService.swift
└── Core/
    └── MainTabView.swift                     # 탭 추가
```
