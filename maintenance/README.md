# 同步上游与维护个人规则

- `origin`：自己的仓库 `wzasg/rule_script`。
- `upstream`：原作者仓库 `blackmatrix7/ios_rule_script`，分支为 `master`。
- 自己的 `master` 同时保存原项目内容与个人提交。

## 日常修改

个人规则继续维护在以下文件，现有订阅地址无需更改：

- `rule/Clash/Custom/Custom.list`
- `rule/Clash/VPN/Sub.list`

这两个文件在本次同步时不存在于上游，暂时无需移动。新增个人规则优先放在这两个目录，减少修改原作者维护的文件。它们仍由 Git 正常跟踪；未来若上游新增同名文件，需要正常处理合并冲突。

## 同步原作者更新

先提交自己的修改，保持工作区干净，然后在仓库根目录执行：

```bash
bash maintenance/sync-upstream.sh
```

需要使用本机代理时，可仅为本次命令指定代理：

```bash
https_proxy=http://127.0.0.1:6152 bash maintenance/sync-upstream.sh
```

该方式不会修改 Git 的全局代理设置。脚本使用 HTTP/1.1、减少协商轮次，并为上游打包预留等待时间。

脚本会确认分支和远程地址，拉取上游，创建 `backup/before-upstream-sync-*` 备份分支，再通过普通 merge 合并。它不会自动推送。

出现冲突时，Git 会停下。根据需要同时保留上游更新与个人规则，逐个编辑冲突文件，然后：

```bash
git add <已解决的文件>
git commit
```

取消尚未完成的合并：

```bash
git merge --abort
```

合并成功后，检查个人规则，并用实际客户端验证使用中的配置，再推送：

```bash
git push origin master
```

不要使用 `reset --hard upstream/master` 或强制推送来同步，这会丢弃个人提交。也不要用整批“保留我方版本”处理冲突，否则可能漏掉上游修复。Git 能识别文本冲突，但无法保证无冲突的配置合并在功能上一定正确。

## Linux 更新的衔接

推荐顺序：原作者更新 → 本地合并和验证 → 推送自己的 origin/master → Linux 更新自己的仓库。

Linux 不应直接同步原作者仓库。推送后通过 SSH 自动更新，需要另外配置 GitHub Actions、服务器 SSH 访问与服务器上的仓库路径；本文件不代表这部分已经部署完成。
