#!/bin/bash

#export NVM_NODEJS_ORG_MIRROR=https://npmmirror.com/mirrors/node
#nvm install --lts
#npm config set registry https://registry.npmmirror.com
#npm i -g npm
#npm i -g pnpm

# 获取当前目录并打印
# CURRENT_DIR=$(pwd)
CURRENT_DIR=/root/sites/demo.phpmall.net
cd $CURRENT_DIR
echo "Current directory is $CURRENT_DIR"
git pull

# 切换到项目目录并执行相关命令
processProject()
{
    local project_dir="$1"
    echo "Switching to directory: $project_dir"
    cd "$project_dir" || { echo "Failed to switch to directory: $project_dir"; exit 1; }

    # 更新依赖
    # pnpm upgrade
    # 安装依赖
    pnpm i
    # 构建项目
    case "$project_dir" in
        *mobile*)
            pnpm run build:h5
            ;;
        *console*)
            pnpm run build-only
            ;;
        *)
            pnpm run build
            ;;
    esac

    echo "Done processing $project_dir"
}

# 处理各个项目目录
# processProject "${CURRENT_DIR}/../phpmall-console"
# processProject "${CURRENT_DIR}/../phpmall-mobile"
processProject "${CURRENT_DIR}"

# 部署前端文件
# rm -rf ${CURRENT_DIR}/public/assets
# rm -rf ${CURRENT_DIR}/public/index.html
# mv ${CURRENT_DIR}/../phpmall-console/dist/* ${CURRENT_DIR}/public/

# rm -rf ${CURRENT_DIR}/public/mobile
# mv ${CURRENT_DIR}/../phpmall-mobile/dist/build/h5 ${CURRENT_DIR}/public/mobile

# 返回初始目录
cd $CURRENT_DIR

# 构建容器
docker build -t phpmall-demo:latest .
docker stop phpmall-demo
sleep 1s
# 启动容器
docker rm phpmall-demo
docker run -d --restart=always --name phpmall-demo -p 8001:8000 --network 1panel-network phpmall-demo:latest

# docker image prune -a -f
docker rmi -f  `docker images | grep '<none>' | awk '{print $3}'`

echo "Done."
# read -p "Press Enter to continue..."

#BackendBuild()
#{
#    cd $cur_dir/phpmall-server
#    composer u --no-dev -oW
#    php artisan optimize
#    php artisan migrate:fresh --force
#    php artisan db:seed --force
#    supervisorctl reload
#}

#FrontendBuild()
#{
#    cd $cur_dir/phpmall-$1
#    bun install
#    bun run build-only
#    rm -rf $cur_dir/phpmall-server/public/$1
#    mv $cur_dir/phpmall-$1/dist $cur_dir/phpmall-server/public/$1
#    # ossutil rm -rf oss://phpmall-demo/assets # --endpoint=oss-cn-hongkong.aliyuncs.com
#    # ossutil cp -rf dist/ oss://phpmall-demo/
#}

#MobileBuild()
#{
#    cd $cur_dir/mobile
#    bun install
#    bun run build:h5 # --base=/mobile/
#    rm -rf $cur_dir/phpmall-server/public/mobile
#    mv dist/build/h5 $cur_dir/phpmall-server/public/mobile
#    # ossutil rm -rf oss://phpmall-demo/mobile
#    # ossutil cp -rf dist/build/h5 oss://phpmall-demo/mobile
#}

#DocsBuild()
#{
#    cd $cur_dir
#    # ossutil rm -rf oss://phpmall-demo/docs
#    # ossutil cp -rf docs/ oss://phpmall-demo/docs
#}
