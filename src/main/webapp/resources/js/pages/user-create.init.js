// resources/js/pages/user-create.init.js
(function () {
  function ready(fn) {
    if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", fn);
    else fn();
  }

  ready(function () {
    // ===== 컨텍스트/CSRF =====
    const ctx =
      window.APP_CTX ||
      document.querySelector('meta[name="ctx"]')?.content ||
      document.body.getAttribute("data-context-path") || "";

    const CSRF_TOKEN  = document.querySelector('meta[name="_csrf"]')?.content || "";
    const CSRF_HEADER = document.querySelector('meta[name="_csrf_header"]')?.content || "X-CSRF-TOKEN";

    // ===== 엘리먼트 =====
    const $modal = document.getElementById("userCreateModal");
    const $dept  = document.getElementById("deptSelect");
    const $team  = document.getElementById("teamSelect");
    const $name  = document.getElementById("fullName");
    const $rank  = document.getElementById("userRank");
    const $email = document.getElementById("userEmail");
    const $phone = document.getElementById("userPhone");
    const $join  = document.getElementById("userJoinDate");
    const $role  = document.getElementById("role");
    const $sn1   = document.getElementById("userSn1"); // 주민 앞 6 (YYMMDD)
    const $sn2   = document.getElementById("userSn2"); // 주민 뒤 7
    const $btn   = document.getElementById("btnCreateUser");
    const $result= document.getElementById("createResult");

    if (!$modal || !$dept || !$team || !$btn) return;

    // ===== 에러 표시 유틸 =====
    function ensureFeedbackEl(inputEl, idHint) {
      if (idHint) { const t = document.getElementById(idHint); if (t) return t; }
      const sib = inputEl.nextElementSibling;
      if (sib && sib.classList?.contains("invalid-feedback")) return sib;
      const fb = document.createElement("div");
      fb.className = "invalid-feedback";
      inputEl.insertAdjacentElement("afterend", fb);
      return fb;
    }
    function setError(inputEl, msg, idHint) {
      inputEl.classList.add("is-invalid");
      ensureFeedbackEl(inputEl, idHint).textContent = msg || "";
    }
    function clearError(inputEl, idHint) {
      inputEl.classList.remove("is-invalid");
      const box = idHint ? document.getElementById(idHint) : inputEl.nextElementSibling;
      if (box && box.classList?.contains("invalid-feedback")) box.textContent = "";
    }
    function clearAllErrors() {
      [$dept,$team,$name,$rank,$email,$phone,$join,$role,$sn1,$sn2].forEach(el=>el && clearError(el));
    }
    function scrollToFirstError() {
      const first = document.querySelector("#userCreateModal .is-invalid");
      if (first) first.scrollIntoView({ behavior:"smooth", block:"center" });
    }
    [$dept,$team,$name,$rank,$email,$phone,$join,$role,$sn1,$sn2].forEach(el=>{
      el?.addEventListener("input", ()=>clearError(el));
      el?.addEventListener("change", ()=>clearError(el));
    });

    // ===== 부서/팀 캐시 =====
    let DEPT_ROWS = []; // [{deptId,deptName,teamId,teamName}]

    function groupTeamsByDept(rows) {
      const map = new Map();
      rows.forEach(r=>{
        const dId = Number(r.deptId);
        if (!map.has(dId)) map.set(dId, { deptId:dId, deptName:r.deptName, teams:[] });
        if (r.teamId) map.get(dId).teams.push({ teamId:r.teamId, teamName:r.teamName });
      });
      return Array.from(map.values()); // [{deptId,deptName,teams:[...]}]
    }

    function fillDeptSelect() {
      const tree = groupTeamsByDept(DEPT_ROWS);
      $dept.length = 1; // placeholder만 남기고 비움
      tree.forEach(dep=>{
        const opt = document.createElement("option");
        opt.value = dep.deptId;
        opt.textContent = dep.deptName;
        $dept.appendChild(opt);
      });
      window.__DEPT_TREE__ = tree; // 캐시
    }

    function fillTeamByDept(deptId) {
      $team.length = 1;
      $team.disabled = true;
      const tree = window.__DEPT_TREE__ || [];
      const dep = tree.find(d=>Number(d.deptId)===Number(deptId));
      (dep?.teams||[]).forEach(t=>{
        const opt = document.createElement("option");
        opt.value = t.teamId;
        opt.textContent = t.teamName;
        $team.appendChild(opt);
      });
      $team.disabled = false;
    }

    $dept.addEventListener("change", function(){
      clearError($dept, "err-dept");
      fillTeamByDept(parseInt($dept.value||"0",10));
    });

    // ===== 메타 로딩 =====
    let metaLoaded = false;
    function loadDeptTeams() {
      return fetch(ctx + "/api/dept-teams", { credentials:"same-origin" })
        .then(r=>r.ok?r.json():Promise.reject(r.status))
        .then(list=>{
          DEPT_ROWS = Array.isArray(list)? list : [];
          fillDeptSelect();
        });
    }
    function loadRanks() {
      return fetch(ctx + "/api/ranks", { credentials:"same-origin" })
        .then(r=>r.ok?r.json():Promise.reject(r.status))
        .then(list=>{
          // placeholder 제외 삭제
          for (let i=$rank.options.length-1;i>=1;i--) $rank.remove(i);
          (Array.isArray(list)?list:[]).forEach(name=>{
            const opt = document.createElement("option");
            opt.value = name;
            opt.textContent = name;
            $rank.appendChild(opt);
          });
          // 기본값: '사원' 선택(목록에 없으면 직접 추가)
          if (![...$rank.options].some(o=>o.value==="사원")) {
            const opt = document.createElement("option");
            opt.value = "사원"; opt.textContent = "사원";
            $rank.appendChild(opt);
          }
          $rank.value = "사원";
        });
    }

    // ===== 주민번호/전화 입력 처리 & 검증 =====
    const SN1_LEN=6, SN2_LEN=7;
    const digitsOnly = el => el.value = (el.value||"").replace(/\D/g,"");

    // YYMMDD 유효성 체크 (간단: 월/일 범위 체크, 윤년은 20YY로 계산)
    function isValidYYMMDD(yyMMdd) {
      if (!/^\d{6}$/.test(yyMMdd)) return false;
      const yy = parseInt(yyMMdd.slice(0,2),10);
      const mm = parseInt(yyMMdd.slice(2,4),10);
      const dd = parseInt(yyMMdd.slice(4,6),10);
      if (mm < 1 || mm > 12) return false;
      const baseYear = 2000 + yy; // 세기 판정은 뒤 첫자리로 하므로 여기선 단순 체크용
      const lastDay = new Date(baseYear, mm, 0).getDate(); // 해당 월의 말일
      return dd >= 1 && dd <= lastDay;
    }
    // 주민 뒤 첫 자리 유효(1~8)
    function isValidSn2FirstDigit(s) {
      return /^[1-8]$/.test(s);
    }

    $sn1?.addEventListener("input", function(){
      digitsOnly($sn1);
      if ($sn1.value.length>=SN1_LEN) {
        $sn1.value = $sn1.value.slice(0,SN1_LEN);
        $sn2?.focus();
      }
    });
    $sn1?.addEventListener("blur", function(){
      const v = ($sn1.value||"").trim();
      if (!v) { setError($sn1, "주민 앞자리를 입력하세요.", "err-sn1"); return; }
      if (v.length !== SN1_LEN) { setError($sn1, `주민 앞자리는 ${SN1_LEN}자리입니다.`, "err-sn1"); return; }
      if (!isValidYYMMDD(v)) { setError($sn1, "주민 앞자리(YYMMDD)가 올바르지 않습니다.", "err-sn1"); return; }
      clearError($sn1, "err-sn1");
    });

    $sn2?.addEventListener("input", function(){
      digitsOnly($sn2);
      if ($sn2.value.length>SN2_LEN) $sn2.value = $sn2.value.slice(0,SN2_LEN);
    });
    $sn2?.addEventListener("blur", function(){
      const v = ($sn2.value||"").trim();
      if (!v) { setError($sn2, "주민 뒷자리를 입력하세요.", "err-sn2"); return; }
      if (v.length !== SN2_LEN) { setError($sn2, `주민 뒷자리는 ${SN2_LEN}자리입니다.`, "err-sn2"); return; }
      if (!isValidSn2FirstDigit(v[0])) { setError($sn2, "주민 뒷자리 첫 숫자는 1~8 이어야 합니다.", "err-sn2"); return; }
      clearError($sn2, "err-sn2");
    });

    $phone?.addEventListener("input", function(){ digitsOnly($phone); });

    // ===== 모달 오픈 시 초기화 =====
    $modal?.addEventListener("shown.bs.modal", function(){
      clearAllErrors();

      // 오늘 날짜 자동 세팅
      const d=new Date(); const yyyy=d.getFullYear();
      const mm=String(d.getMonth()+1).padStart(2,"0");
      const dd=String(d.getDate()).padStart(2,"0");
      if ($join) $join.value = `${yyyy}-${mm}-${dd}`;

      // 기본값
      if ($role) $role.value = "USER"; // 권한 기본 USER
      if ($rank) $rank.value = "";     // 로딩 후 '사원'으로 세팅됨
      [$name,$email,$phone,$sn1,$sn2].forEach(el=>el && (el.value=""));
      $team.length = 1; $team.disabled = true;

      if (!metaLoaded) {
        Promise.all([loadDeptTeams(), loadRanks()])
          .catch(err=>{
            console.error("메타 로딩 실패", err);
            setError($dept, "초기 데이터를 불러오지 못했습니다.", "err-dept");
          })
          .finally(()=>{ metaLoaded = true; });
      } else {
        if ($rank) $rank.value = "사원";
      }
    });

    // ===== 검증 & 저장 =====
    function validateAll() {
      let ok = true;
      const deptId = parseInt($dept.value||"0",10);
      const teamId = parseInt($team.value||"0",10);
      const name = ($name.value||"").trim();
      const rank = ($rank.value||"").trim();
      const email = ($email.value||"").trim();
      const phone = ($phone.value||"").trim();
      const join = ($join.value||"").trim();
      const role = ($role.value||"").trim();
      const sn1  = ($sn1.value||"").trim();
      const sn2  = ($sn2.value||"").trim();

      if (!deptId) { setError($dept,"부서를 선택하세요.","err-dept"); ok=false; }
      if (!teamId) { setError($team,"팀을 선택하세요.","err-team"); ok=false; }
      if (!name)   { setError($name,"이름을 입력하세요.","err-name"); ok=false; }
      if (!rank)   { setError($rank,"직급을 선택하세요.","err-rank"); ok=false; }
      if (!email)  { setError($email,"이메일을 입력하세요.","err-email"); ok=false; }
      if (!phone)  { setError($phone,"연락처를 입력하세요.","err-phone"); ok=false; }
      if (!join)   { setError($join,"입사일을 입력하세요.","err-join"); ok=false; }
      if (!role)   { setError($role,"권한을 선택하세요.","err-role"); ok=false; }

      const emailRe=/^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      if (email && !emailRe.test(email)) { setError($email,"이메일 형식이 올바르지 않습니다.","err-email"); ok=false; }
      if (phone && (phone.length<9 || phone.length>11)) { setError($phone,"연락처는 9~11자리 숫자만 입력하세요.","err-phone"); ok=false; }

      // 주민번호: 둘 다 필수 + 형식검사
      if (!sn1) { setError($sn1, "주민 앞자리를 입력하세요.", "err-sn1"); ok=false; }
      else if (sn1.length!==SN1_LEN) { setError($sn1,`주민 앞자리는 ${SN1_LEN}자리입니다.`,"err-sn1"); ok=false; }
      else if (!isValidYYMMDD(sn1)) { setError($sn1,"주민 앞자리(YYMMDD)가 올바르지 않습니다.","err-sn1"); ok=false; }

      if (!sn2) { setError($sn2, "주민 뒷자리를 입력하세요.", "err-sn2"); ok=false; }
      else if (sn2.length!==SN2_LEN) { setError($sn2,`주민 뒷자리는 ${SN2_LEN}자리입니다.`,"err-sn2"); ok=false; }
      else if (!isValidSn2FirstDigit(sn2[0])) { setError($sn2, "주민 뒷자리 첫 숫자는 1~8 이어야 합니다.", "err-sn2"); ok=false; }

      if (!ok) scrollToFirstError();
      return ok;
    }

    $btn.addEventListener("click", function(){
      clearAllErrors();
      if (!validateAll()) return;

      const payload = {
        deptId: parseInt($dept.value||"0",10),
        teamId: parseInt($team.value||"0",10),
        fullName: ($name.value||"").trim(),
        userEmail: ($email.value||"").trim(),
        userPhone: ($phone.value||"").trim(),
        userRank: ($rank.value||"").trim(),
        userJoinDate: ($join.value||"").trim(),
        role: ($role.value||"USER").trim(), // 안전하게 USER 기본
        userSn1: ($sn1.value||"").trim(),
        userSn2: ($sn2.value||"").trim()
        // password는 서버에서 자동 생성
      };

      fetch(ctx + "/api/users", {
        method: "POST",
        credentials: "same-origin",
        headers: { "Content-Type":"application/json", [CSRF_HEADER]: CSRF_TOKEN },
        body: JSON.stringify(payload)
      })
      .then(async r=>{
        if (r.ok) return r.json();
        let msg="생성에 실패했습니다.";
        try { const err=await r.json(); if (err?.message) msg=err.message; } catch(_){}
        // 대표적인 서버 오류는 팀 필드 아래에 붙임
        if (/부서에 속하지 않습니다|팀.*존재/i.test(msg)) setError($team,msg,"err-team");
        else setError($name,msg,"err-name");
        scrollToFirstError();
        throw new Error(msg);
      })
      .then(res=>{
        // ===== 성공: 모달 닫고, '완전히 닫힌 후' 확인 Alert 띄우기 =====
        const afterHidden = () => {
          // 리스너 해제
          $modal.removeEventListener("hidden.bs.modal", afterHidden);
          // 혹시 남은 백드롭/바디 상태 정리
          document.querySelectorAll(".modal-backdrop").forEach(el=>el.remove());
          document.body.classList.remove("modal-open");
          document.body.style.removeProperty("padding-right");

          // SweetAlert 확인 → 확인 시 새로고침
          if (window.Swal) {
            Swal.fire({
              title: "직원 등록 완료",
              icon: "success",
              confirmButtonText: "확인",
              confirmButtonColor: "#34c38f"
            }).then(result => {
              if (result.isConfirmed) location.reload();
            });
          } else {
            if (confirm("직원 등록 완료. 새로고침할까요?")) location.reload();
          }
        };

        $modal.addEventListener("hidden.bs.modal", afterHidden, { once:true });

        // Bootstrap 모달 닫기
        if (window.bootstrap?.Modal) {
          const inst = bootstrap.Modal.getInstance($modal) || new bootstrap.Modal($modal);
          inst.hide();
        } else {
          // 수동 폴백: 바로 숨기고 afterHidden 실행
          $modal.classList.remove("show");
          $modal.style.display = "none";
          document.querySelector(".modal-backdrop")?.remove();
          document.body.classList.remove("modal-open");
          afterHidden();
        }
      })
      .catch(err => {
        console.error(err);
        // 실패 알림 (확인 버튼)
        if (window.Swal) {
          Swal.fire({
            title: "등록을 실패했습니다.",
            text: err.message || "서버 오류가 발생했습니다.",
            icon: "error",
            confirmButtonText: "확인",
            confirmButtonColor: "#34c38f"
          });
        } else {
          alert(err.message || "등록 실패");
        }
      });
    });
  });
})();
