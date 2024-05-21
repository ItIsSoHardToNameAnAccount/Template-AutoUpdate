# Auto Update Template
- This template shows how to auto update embedded device from server.
 
## Config Server
- 1. Initialize a bare repository in your server
```bash
mkdir -p ./repos/AutoUpdate.git
cd ./repos/AutoUpdate.git
git init --bare
```

- 2. Set Git Hook
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

# Copy excutable file to depoly folder
if [ -f $BUILD_DIR/AutoUpdate ]; then
    cp $BUILD_DIR/AutoUpdate $DEPLOY_DIR/
else
    echo "Executable not found"
    exit 1
fi

echo "post-receive hook completed."
```
 * Make sure script is excutable
```
chmod +x ./hooks/post-receive
```

- 3. Add remote
 * Fork(Optional)
repository url = ssh://yourusername@ipAdress/path/to/your/app.git
 * Command Line
```
cd /path/to/your/local/repo
git remote add origin user@yourserver:/path/to/your/app.git
git push origin master
```