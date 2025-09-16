# 🛰️ Broadcast-Groupware

방송국 내부 업무 효율화를 위한 그룹웨어 시스템
캘린더, 예약, 근태, 게시판, 전자결재 등 방송국 업무를 통합 관리합니다.



# 🧩 프로젝트 개요

## 개발 목적

방송국 내부 업무를 웹으로 통합 관리하여 효율화

## 주요 특징

캘린더, 예약, 근태, 게시판, 전자결재 등 필수 업무 통합

역할 기반 기능 분리 (관리자 / 직원)

일정, 예약 중복 방지, 결재 진행 상태 확인 등 업무 편의 기능 제공




# 👥 사용자 역할 및 기능

## 📌 관리자

 회원 관리

 회의실, 편집실, 차량 예약 관리

 캘린더 일정 등록/수정/삭제

 게시판 관리 및 공지사항 등록

## 👨‍💼 직원

 개인 일정 확인 및 관리

 예약 신청 (회의실, 편집실, 차량)

 근태 등록 (출근, 퇴근, 외근)

 게시판 글 작성/수정/삭제

 결재 문서 확인 및 서명 제출



# 🏗️ 기술 스택

| 구분 | 기술 |
|------|------|
| Language | Java 21 |
| Backend | Spring Boot |
| Frontend | JSP, JSTL, EL, jQuery |
| Database | MySQL |
| ORM | JPA / MyBatis |
| Build Tool | Maven |
| Server | Embedded Tomcat |
| API | 공휴일, 날씨, 캘린더, 전자서명|
| 기타 | Lombok 등 |

# 🌐 배포 환경 (현재는 종료됨)

- AWS EC2 (Ubuntu 22.04)
- Spring Boot 프로젝트 WAR 파일을 Docker 컨테이너로 실행
- 별도의 AWS EC2 인스턴스에 설치된 MySQL 서버 연동
- 외부 접속을 위한 8080 포트 개방 (보안 그룹 설정)

※ 현재는 서버 인스턴스를 종료하여 접속은 불가합니다

# 📂 프로젝트 구조
```
broadcast-groupware/
├── src/
│ ├── main/java/com/broadcast/...
│ └── resources/
│ ├── application.properties
│ └── templates/ (Mustache/JSP)
├── pom.xml
└── mvnw / .gitignore / ...
```


# 🗃️ 데이터베이스 설계

사용자(user), 역할(role), 일정(calendar), 예약(reservation), 근태(attendance), 게시판(board), 결재(approval) 등

전자결재 문서 흐름, 결재자 서명 관리, 문서 상태 업데이트 반영

ERD 예시: ![DB](DB.png)



# 🧾 주요 화면

| 화면 | 기능 |
|------|------|
| 🗓 캘린더 | 전체/팀/개인 일정 확인 |
| 🏢 예약 시스템 | 회의실, 편집실, 차량 예약 |
| ⏱ 근태 관리 | 출/퇴/외근 등록 |
| 📝 게시판 | 일반/공지사항 게시글 작성 |
| 🖊 전자결재 | 일반 문서, 방송 편성, 휴가 신청 |

| 메인화면 | 캘린더 | 차량예약 | 근태 |전자결재 |
|--------|--------|----------|----------|----------|
| ![메인화면](메인화면.PNG) | ![캘린더](캘린더.PNG) | ![차량예약](차량예약.PNG) | ![근태](근태.PNG) | ![전자결재](방송문서작성.PNG) |




# 🗺️ 기능 흐름도

관리자/직원 역할별 기능 흐름 및 CRUD 구조
FlowChart: ![흐름도](흐름도.png)

## 🧑‍💻 기여자 정보

- 김성민 / 캘린더, 근태, 마이페이지 구성 / https://github.com/smkim11
- 김예진 / 결재, 방송편성 구성 / https://github.com/Yejin-source
- 장정수 / 예약, 게시판 구성 / https://github.com/coffee-jeong
- 장지영 / 로그인, 채팅, 메인화면 구성 / https://github.com/JANGJI0

---

## 📌 라이선스

본 프로젝트는 수업용 / 포트폴리오 목적의 샘플 프로젝트입니다.  
상업적 사용은 제한됩니다.


