# 🏕️ 오지캠핑 for iOS
> 오지캠핑 서비스를 네이티브+웹뷰를 활용한 하이브리드 iOS 오지캠핑 앱입니다.

<br/>

## 🌲 목차
- 개발자 
- 프로젝트 기간
- 앱스토어 배포 링크
- 프로젝트 구조 패턴
- 사용 기술
- 구현 화면
- 디렉토리 구조
- 핵심 구현사항
- 트러블 슈팅
<br/>

## 👨🏻‍💻 개발자

| <a href="https://github.com/comdori-wj"> <img src="https://avatars.githubusercontent.com/u/22284092?v=4" width="200" height="200"></a> |
| --------- |
|[@Comdori(하원지)](https://github.com/comdori-wj)|


<br/>

## 📆 프로젝트 기간
> 2024.11.04 ~ 2024.12.12 (6주)

<br/>

## 📆 유지보수 기간
> 2024.12.12 ~ 2025.03.28

<br/>

## 📱 앱스토어 배포
### 애플 앱스토어 '오지캠핑' 검색 후 다운로드 또는 하단 배지 클릭

<a href="https://apps.apple.com/kr/app/id6738459543" style="display: inline-block; overflow: hidden; border-radius: 13px; width: 250px; height: 83px;"><img src="https://tools.applemediaservices.com/api/badges/download-on-the-app-store/black/ko-kr?size=250x83&amp;releaseDate=1693008000" alt="Download on the App Store" style="border-radius: 13px; width: 250px; height: 83px;"></a>

|앱스토어|
|:---:|
<img width="300" alt="앱스토어 오지캠핑 다운로드 페이지" src="https://github.com/user-attachments/assets/88d2536f-2fda-422f-b522-301d68a85a57">|


<br/>

## 🧬 프로젝트 구조 패턴
- 디자인패턴 : `MVVM`

<br/>

## 🛠️ 사용 기술
- UIKit
- WebKit
- CoreLocation
- URLSession
- Storyboard + Codebase

<br/>


## 📸 구현 화면

|홈화면|거리순 화면|업데이트순 화면|
|:---:|:---:|:---:|
<img width="300" alt="홈화면" src="https://github.com/user-attachments/assets/1609043d-d2e9-4ec8-befa-37e870e97370">|<img width="300" alt="거리순 화면" src="https://github.com/user-attachments/assets/d96431e3-2af2-4ce6-b9e0-2a639bbd33d3">|<img width="300" alt="업데이트순 화면" src="https://github.com/user-attachments/assets/a3e3918d-52b0-4270-8013-fad3ca3e3e6b">
|현위치 지도 화면|로그인 화면|마이페이지 화면|
<img width="300" alt="현위치 지도 화면" src="https://github.com/user-attachments/assets/06398512-1631-4af9-a962-70f5a0964f46">|<img width="300" alt="로그인 화면" src="https://github.com/user-attachments/assets/0bb8aecd-6499-4db2-8321-e0dc49613be8">|<img width="300" alt="마이페이지 화면" src="https://github.com/user-attachments/assets/6f523754-5f7d-4f59-bee6-a2d65041e8d2">|
|아이디 찾기 화면|비밀번호 찾기 화면|회원가입-약관동의 화면|
|<img width="300" alt=" 아이디찾기 화면" src="https://github.com/user-attachments/assets/1e05f9e3-49e6-468c-8e76-a59816268f2c">|<img width="300" alt=" 비밀번호 찾기 화면" src="https://github.com/user-attachments/assets/e245af90-787f-4650-9add-de828e48531f">|<img width="300" alt="이용동의 약관 화면" src="https://github.com/user-attachments/assets/ca3176aa-8245-4712-b510-1e0d6b7e30d1">
|서비스 이용약관 화면|회원가입 화면|
<img width="300" alt=" 서비스 이용약관 화면" src="https://github.com/user-attachments/assets/a4f7a9de-4309-45ec-bc6e-e7a0cbd901e0">|<img width="300" alt=" 회원가입 화면" src="https://github.com/user-attachments/assets/4eea3739-5394-47cd-832e-c42aca690b53">

<br/> 

## 🗂️ 디렉토리 구조 

```
.
├── 5GCAMP
│   ├── Resources
│   │   ├── 5GCAMP.entitlements
│   │   ├── AppDelegate.swift
│   │   ├── Assets.xcassets
│   │   │   ├── 5GCAMPIcon.imageset
│   │   │   ├── 5GCAMPLogo.imageset
│   │   │   ├── 5GHomeIcon.imageset
│   │   │   ├── AccentColor.colorset
│   │   │   ├── AppIcon.appiconset
│   │   │   ├── ArrowUpDocumentFillIcon.imageset
│   │   │   ├── CheckOffIcon.imageset
│   │   │   ├── CheckOnIcon.imageset
│   │   │   ├── FindIdIcon.imageset
│   │   │   ├── FindPasswordIcon.imageset
│   │   │   ├── JoinIcon.imageset
│   │   │   ├── Map.imageset
│   │   │   ├── Navigation.imageset
│   │   │   ├── NextBlackIcon.imageset
│   │   │   └── Profile.imageset
│   │   ├── Image
│   │   │   └── Splash.png
│   │   ├── Info.plist
│   │   ├── SceneDelegate.swift
│   │   └── StoryBoards
│   │       ├── Base.lproj
│   │       │   └── LaunchScreen.storyboard
│   │       ├── CampingListDistance.storyboard
│   │       ├── CampingListRecentUpdate.storyboard
│   │       ├── FindAccount.storyboard
│   │       ├── Home.storyboard
│   │       ├── Join.storyboard
│   │       ├── JoinTermsOfUse.storyboard
│   │       ├── Login.storyboard
│   │       ├── Map.storyboard
│   │       ├── MyPage.storyboard
│   │       ├── TabBar.storyboard
│   │       └── ko.lproj
│   │           └── LaunchScreen.strings
│   └── Sources
│       ├── Network
│       │   ├── NetworkManager.swift
│       │   └── URLManager.swift
│       ├── Presentation
│       │   ├── CampingListDistance
│       │   │   ├── CampingListDistanceViewController.swift
│       │   │   └── CampingListDistanceViewModel.swift
│       │   ├── CampingListRecentUpdate
│       │   │   ├── CampingListRecentUpdateViewController.swift
│       │   │   └── CampingListRecentUpdateViewModel.swift
│       │   ├── Common
│       │   │   ├── LocationConfigurable.swift
│       │   │   └── WebViewConfigurable.swift
│       │   ├── FindAccount
│       │   │   ├── FindAccountViewModel.swift
│       │   │   ├── FindIdViewController.swift
│       │   │   └── FindPasswordViewController.swift
│       │   ├── Home
│       │   │   ├── HomeViewController.swift
│       │   │   └── HomeViewModel.swift
│       │   ├── Join
│       │   │   ├── JoinViewController.swift
│       │   │   ├── JoinViewModel.swift
│       │   │   ├── TermsOfUse
│       │   │   │   ├── LocationBasedServiceConsentViewController.swift
│       │   │   │   ├── MarketingConsentViewController.swift
│       │   │   │   ├── PrivacyPolicyViewController.swift
│       │   │   │   ├── TermsOfServiceViewController.swift
│       │   │   │   └── ThirdPartySharingViewController.swift
│       │   │   ├── TermsOfUseModel.swift
│       │   │   ├── TermsOfUseViewController.swift
│       │   │   └── TermsOfUseViewControllerDelegates.swift
│       │   ├── Login
│       │   │   ├── LoginModel.swift
│       │   │   ├── LoginViewController.swift
│       │   │   └── LoginViewModel.swift
│       │   ├── Map
│       │   │   ├── MapViewController.swift
│       │   │   └── MapViewModel.swift
│       │   ├── MyPage
│       │   │   ├── MyPageViewController.swift
│       │   │   └── MyPageViewModel.swift
│       │   └── TabBar
│       │       ├── TabBarController.swift
│       │       └── TabBarProtocol.swift
│       └── Utilities
│           ├── Observable.swift
│           └── UITextField+Extension.swift
├── 5GCAMP.xcodeproj
└── README.md
```

<br/>

## 🌟 핵심 구현사항

### 홈화면
- 모든 화면은 WKWebView(웹뷰)를 활용하여 구성함.
- 앱 첫 실행 시 오지캠핑 모바일 웹이 메인화면으로 기본 구성
- 탭바의 홈 탭을 선택할 때 메인화면으로 돌아가는 새로고침(재귀) 구성

### 거리순 화면
- 현재 내 위치를 확인하여 `오름차순`으로 가장 가까운 캠핑장을 목록 리스트로 표현

### 업데이트순 화면
- 현재 내 위치를 확인하여 최근 업데이트된 캠핑장을 `오름차순`으로 목록 리스트로 표현

### 지도 화면
- `Kakao Maps API`를 활용하여 현재 위치를 기준으로 지도상에 표시하여 오지/노지/유료캠핑장등을 표시함
- 다른 화면을 표시할 때는 탭 바의 이름이 `지도`로 표시되나, 지도 화면으로 이동하면 `현위치`로 변경되어 현 위치 탭을 누를시 현재 위치를 새로고침하여 다른 캠핑장을 확인할 수 있음.]

### 마이페이지 화면
- 로그인/로그아웃 세션 상태를 모든 화면에 `동기화`하여 웹뷰에서도 로그인/로그아웃 상태가 유지될 수 있도록 구성함.

### 로그인 화면
- `네이티브`로 구성된 로그인 화면을 통해 로그인 상태를 판단 후 웹뷰를 통해 마이페이지에 접근할 수 있음.
- 로그인(아이디, 비밀번호)는 `Password AutoFill` 기능을 활용하여 정보를 저장하여 `생체인증` 후 바로 사용 할 수 있기에 사용자가 편리하게 로그인할 수 있음.

### 아이디 찾기, 비밀번호 찾기 화면
- `네이티브`로 구성된 계정 찾기 화면을 통해 아이디와 비밀번호를 찾을 수 있음.

### 회원가입-약관동의 화면
- `네이티브`로 구성된 약관 동의 화면은 필수의 사항을 동의해야만 회원가입을 진행할 수 있음.
- 모든 약관은 서버에서 직접 불러 올 수 있도록 설계하여, 약관 제목이 변경되지 않는 이상 앱 업데이트를 따로 하지 않아도 바로 적용되게 설계함.
- 텍스트만 있는 경우는 `텍스트뷰` 표가 있는 경우는 `웹뷰`를 사용하여 약관이 표시되는 데 문제가 없도록 표현함.

### 회원가입 화면
- `네이티브`로 구성된 회원가입 화면은 모든 텍스트필드를 채워야만 회원가입을 완료할 수 있음.
- `아이디`, `이메일`의 경우는 입력 후 회원가입 버튼을 누를 시 중복 확인 후 중복이 아닐 시만 회원가입이 정상적으로 진행되도록 구성.

<br/>

## 🚀 트러블 슈팅

#### 1. 위치권한 메시지 관련 리젝
Guideline 5.1.1 - Legal - Privacy - Data Collection and Storage
- **사유**
    - 위치 권한을 사용하는 데 왜 사용을 하는지 사용자에게 고지하지 않아 심사가 거절된 사례

- **문제 해결**
    - 위치 권한 사용 시 왜 사용을 하는지 사용자에게 안내함으로써 해당 이슈를 해결

<br>

#### 2. 앱 사용 중 사용자의 예외 처리를 하지 않아 앱이 강제로 종료되는 현상 리젝
Guideline 2.1 - Performance
- **사유**
    - 게시판과 프로필 사진 페이지에서 `사진 또는 비디오 찍기`를 할 때 `비디오` 선택 시 앱이 강제 종료되는 현상으로 인해 사용자가 놀랄 수 있으므로 심사가 거절된 사례 

- **문제 해결**
    - 사진 첨부시 `사진 찍기` 만 가능하도록 수정 
    - 수정 전 코드
    ```
    <input size="80" type="file" name="upfile[]" id="pic<?php echo $i?>" val="<?php echo $i?>" value="" class='fr upFile uploadForm'/> 
    ```
    - 수정 후 코드 → accept="image/*" 추가
    ```
    <input size="80" type="file" accept="image/*" name="upfile[]" id="pic<?=$i?>" val="<?php echo $i?>" value="" class='fr upFile uploadForm'/>
    ```

<br>

#### 3. 앱이 너무 간단해서 리젝
Guideline 4.2 - Design - Minimum Functionality
- **사유**
    - 모든 화면이 웹뷰로만 이루어져 있는 앱은 모바일웹(앱)으로 충분하므로, 너무 간단하여 심사가 거절된 사례

- **문제 해결**
    - 네이티브로 된 로그인 화면 기능을 추가하여 앱 내의 기능을 보강하여 해당 이슈를 해결함.

<br>

#### 4. 자유게시판과 같은 기능이 있는 경우 게시글 제재와 사용자 차단 기능이 없어서 리젝
Guideline 1.2 - Safety - User-Generated Content
- **사유**
    - 자유게시판이 있는 경우 사용자를 보호할 수 있는 장치가 구비되어야 하는데 준비가 되어 있지 않아 심사가 거절된 사례

- **문제 해결**
    - 사용자 약관(EULA)을 수정하여 회원가입 시 서비스 이용약관에 필수로 동의해야지만 게시판에 글을 작성할 수 있도록 개선
    - 게시글 내 신고 및 회원 차단 버튼을 터치하여 사용자가 신고 및 차단 할 수 있는 기능을 추가하여 사용자 보호 장치를 마련.
    - 신고 및 차단 팝업창에서 해당 이유 선택과 사용자가 직접 신고 기능을 추가하여 문제를 해결.
    - 관리자는 신고된 게시글과 차단하려는 회원을 24시간 이내 검토한다는 메시지를 추가하여 문제를 해결.

|이용약관 수정|게시글 신고 및 차단 버튼|
|:---:|:---:|
<img width="300" alt="이용약관 수정" src="https://github.com/user-attachments/assets/c29d1724-f22a-4d28-b651-cec34572ff2e">|<img width="300" alt="게시글 신고 및 차단 기능" src="https://github.com/user-attachments/assets/783de56a-4c38-4cd2-9571-c68d32b9ae19">
|신고 및 차단 팝업창 및 경고|신고 내용 24시간 이내 관리자 검토 메시지|
<img width="300" alt="신고 및 차단 팝업창 및 경고" src="https://github.com/user-attachments/assets/61ff8e81-e337-4301-816b-d6090a927ec1">|<img width="300" alt="신고 내용 24시간 이내 관리자 검토 메시지" src="https://github.com/user-attachments/assets/72f3361a-36c4-4272-bf61-e2d7615bd1c1">


