#!/bin/bash
set -u
UA='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36'
TS=$(date +%s)
echo "=== runner egress IP ==="
curl -sk --max-time 15 https://ifconfig.me; echo; echo
probe() {
  local name="$1"; shift
  echo "===== $name ====="
  curl -sk --connect-timeout 8 --max-time 25 -H "User-Agent: $UA" "$@" \
    -D "hdr_${name}_${TS}.txt" -o "body_${name}_${TS}.txt" \
    -w "http=%{http_code} size=%{size_download} time=%{time_total} remote=%{remote_ip}\n"
  echo "--- headers ---"; cat "hdr_${name}_${TS}.txt"
  echo "--- body ---"; head -c 900 "body_${name}_${TS}.txt"; echo; echo
  sleep 6
}
W25="--resolve www.aixapp.net:443:198.18.211.25"
A28="--resolve admin.aixapp.net:443:198.18.211.28"
A27="--resolve api.aixapp.net:443:198.18.211.27"
probe r1_api_get     $W25 "https://www.aixapp.net/api/User/check"
probe r2_userinfo_ck $W25 -X POST -H "Content-Type: application/json" -H "Cookie: PHPSESSID=probe123" -d '{}' "https://www.aixapp.net/api/User/info"
probe r3_check_ck    $W25 -X POST -H "Content-Type: application/json" -H "Cookie: PHPSESSID=probe456" -d '{}' "https://www.aixapp.net/api/User/check"
probe r4_root        $W25 "https://www.aixapp.net/"
probe r5_p28         $A28 "https://admin.aixapp.net/"
probe r6_p27         $A27 "https://api.aixapp.net/"
echo "===== ALL DONE ====="
