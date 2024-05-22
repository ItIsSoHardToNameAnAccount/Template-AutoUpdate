# Auto Update Template
- This template shows how to auto update embedded device from server.
 
## Config Server
**1. Initialize a bare repository in your server**
```bash
mkdir -p ./repos/AutoUpdate.git
cd ./repos/AutoUpdate.git
git init --bare
```

**2. Set Git Hook**
 * Edit post-receive
```bash
sudo vim ./hooks/post-receive
```
 * Enter following lines
```
#!/bin/bash

REPO_DIR=/root/repos/AutoUpdate.git
WORK_TREE=/root/work_tree/AutoUpdate
BUILD_DIR=$WORK_TREE/build/release
DEPLOY_DIR=/root/Deploy/AutoUpdate
LOG_FILE=/root/repos/AutoUpdate.git/hooks/build.log

exec > >(tee -i $LOG_FILE)
exec 2>&1

echo "Starting post-receive hook..."

rm -rf $WORK_TREE
rm -rf $DEPLOY_DIR
mkdir -p $WORK_TREE
mkdir -p $BUILD_DIR
mkdir -p $DEPLOY_DIR

# Copy latest code to build folder
/usr/bin/git --work-tree=$WORK_TREE --git-dir=$REPO_DIR checkout -f yourBranchName

if [ ! -f $WORK_TREE/CMakeLists.txt ]; then
    echo "CMakeLists.txt not found in $WORK_TREE"
    exit 1
fi

cd $BUILD_DIR
cmake -S $WORK_TREE -B $BUILD_DIR -DCMAKE_BUILD_TYPE=Release
cmake --build $BUILD_DIR

# Copy files to depoly folder
rsync -av --delete $BUILD_DIR/ $DEPLOY_DIR/

echo "post-receive hook completed."
```
 * Make sure script is excutable
```
chmod +x ./hooks/post-receive
```

**3. Setup Nginx**
```
sudo vim /etc/nginx/nginx.conf
```
 * Add config in server model
```
location /Deploy/AutoUpdate/ {
        alias /root/Deploy/AutoUpdate/;
        autoindex on;  # 可选项，启用目录列表

        # 设置正确的MIME类型
        default_type application/octet-stream;

        # 防止MIME类型嗅探
        add_header X-Content-Type-Options nosniff;

        # 添加缓存控制
        add_header Cache-Control "no-cache, no-store, must-revalidate";

        # 添加安全头
        add_header X-Frame-Options "SAMEORIGIN";
        add_header X-XSS-Protection "1; mode=block";
}
```
 * Change file onwer
```
sudo chown -R nginx:nginx /root/Deploy
sudo chmod 755 /root
sudo chmod -R 755 /root/Deploy
```
 * Enabel and restart Nginx
```
sudo nginx -t
sudo systemctl restart nginx
```

## Config Local
**1. Add remote**
 * Fork(Optional)
```
repository url = ssh://yourusername@ipAdress/path/to/your/app.git
```
 * Command Line
```
cd /path/to/your/local/repo
git remote add origin user@yourserver:/path/to/your/app.git
git push origin master
```

## Config Embedded Machine
**1. Write auto update script**
```
#!/bin/bash

DEPLOY_URL=http://yourserver/path/to/your/excutable/folder/
LOCAL_PATH=/path/to/local/Folder/
LOCAL_METADATA_PATH=/path/to/local/AutoUpdate.metadata
EXCUTABLE_PATH=$LOCAL_PATH/AutoUpdate

# 获取服务器上文件的最后修改时间
REMOTE_MODIFIED_TIME=$(curl -sI $DEPLOY_URL | grep -i 'Last-Modified' | cut -d' ' -f2-)
REMOTE_MODIFIED_TIMESTAMP=$(date -d "$REMOTE_MODIFIED_TIME" +%s)

# 获取本地文件的最后修改时间
if [ -f $LOCAL_METADATA_PATH ]; then
    LOCAL_MODIFIED_TIME=$(cat $LOCAL_METADATA_PATH)
    LOCAL_MODIFIED_TIMESTAMP=$(date -d "$LOCAL_MODIFIED_TIME" +%s)
else
    LOCAL_MODIFIED_TIMESTAMP=0
fi

# 比较修改时间，如果服务器文件更新，则下载最新文件
if [ $REMOTE_MODIFIED_TIMESTAMP -gt $LOCAL_MODIFIED_TIMESTAMP ]; then
    echo "Downloading latest version..."
    rm -rf $LOCAL_PATH/*
    wget -r -np -nH --cut-dirs=3 -R "index.html*" -P $LOCAL_PATH $DEPLOY_URL
    echo $REMOTE_MODIFIED_TIME > $LOCAL_METADATA_PATH
    chmod +x $EXCUTABLE_PATH
else
    echo "Program is up to date."
fi

# 运行应用程序
$EXCUTABLE_PATH
```
* Make sure script is excutable
```
chmod +x /path/to/your/script
```
