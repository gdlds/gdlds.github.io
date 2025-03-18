#!/usr/bin/env sh

# 当发生错误时终止脚本
set -e

# 构建
npm run build

# 进入构建输出目录
cd dist

# 如果你要部署到自定义域名
# echo 'www.example.com' > CNAME

git init
git add -A
git commit -m '部署Flappy Bird游戏'

# 如果你要部署到 https://<USERNAME>.github.io
git push -f https://github.com/gdlds/gdlds.github.io.git master:gh-pages

cd - 