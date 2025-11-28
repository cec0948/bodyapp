---
description: 깃허브에 코드 올리는 방법
---

# GitHub에 코드 올리기

현재 프로젝트는 로컬 Git 저장소에 안전하게 저장되었습니다. 이제 GitHub에 올려서 배포하거나 백업할 수 있습니다.

## 1. GitHub 저장소 만들기
1. [GitHub](https://github.com)에 로그인합니다.
2. 우측 상단의 `+` 버튼을 누르고 **New repository**를 선택합니다.
3. **Repository name**에 `bodyapp` (또는 원하는 이름)을 입력합니다.
4. **Public** (공개) 또는 **Private** (비공개)를 선택합니다.
5. **Create repository** 버튼을 누릅니다.

## 2. 코드 올리기 (Push)
저장소가 만들어지면 화면에 명령어들이 나옵니다. 그 중 **"…or push an existing repository from the command line"** 부분의 명령어를 복사해서 터미널에 입력하면 됩니다.

보통 다음과 같습니다:

```bash
git remote add origin https://github.com/사용자이름/bodyapp.git
git branch -M main
git push -u origin main
```

위 명령어를 터미널에 한 줄씩 입력하거나, 한꺼번에 붙여넣고 엔터를 치면 코드가 GitHub로 올라갑니다!
