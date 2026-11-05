#!/usr/bin/env bash
# 在当前 master 分支合并上游，保留个人提交；不推送、不强制覆盖。
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd -- "$repo_dir"

if [[ "$(git branch --show-current)" != master ]]; then
  echo '请先切换到 master 分支。' >&2
  exit 1
fi
if [[ -n "$(git status --porcelain)" ]]; then
  echo '工作区有未提交的改动，请先提交或暂存后再同步。' >&2
  exit 1
fi
expected_url='https://github.com/blackmatrix7/ios_rule_script.git'
if [[ "$(git config --get remote.upstream.url)" != "$expected_url" ]]; then
  echo "upstream 地址与预期不符，应为：$expected_url" >&2
  exit 1
fi

export GIT_TERMINAL_PROMPT=0
git -c http.version=HTTP/1.1 -c http.lowSpeedLimit=1 -c http.lowSpeedTime=180 -c fetch.negotiationAlgorithm=skipping fetch --no-tags upstream refs/heads/master:refs/remotes/upstream/master
backup="backup/before-upstream-sync-$(date +%Y%m%d-%H%M%S)-$$"
git branch "$backup"
echo "已创建备份分支：$backup"

if ! git merge --no-edit upstream/master; then
  echo '上游合并未完成，请查看 git status。' >&2
  echo '若存在冲突：编辑冲突文件，git add 对应文件，然后 git commit。' >&2
  echo '若需取消尚未完成的合并：git merge --abort。' >&2
  exit 1
fi

echo '本地同步完成。请检查规则；确认后执行 git push origin master。'
