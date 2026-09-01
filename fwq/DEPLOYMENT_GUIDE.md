# SnowIsland 游戏系统 - Docker 部署指南

> 本文档详细描述如何使用 Docker 和 Docker Compose 在云服务器上部署 SnowIsland 前后端分离项目。
> 参考教程：Docker部署SpringBoot+Vue项目

---

## 目录

1. [部署概述](#1-部署概述)
2. [环境要求](#2-环境要求)
3. [项目结构](#3-项目结构)
4. [服务器准备](#4-服务器准备)
5. [本地打包](#5-本地打包)
6. [文件上传](#6-文件上传)
7. [配置说明](#7-配置说明)
8. [服务部署](#8-服务部署)
9. [服务验证](#9-服务验证)
10. [常见问题](#10-常见问题)
11. [运维命令](#11-运维命令)
12. [域名与SSL配置](#12-域名与ssl配置)

---

## 1. 部署概述

### 1.1 部署方式

本项目采用 **Docker + Docker Compose + Nginx** 的方式进行部署，实现前后端分离架构。

- **后端**：Spring Boot + MySQL + Redis
- **前端**：Vue + Nginx
- **编排工具**：Docker Compose
- **网络模式**：自定义 Docker 桥接网络

### 1.2 核心概念

#### 数据卷（Volume）
数据卷实现宿主机文件与容器内文件的同步，确保数据持久化：
- MySQL 数据持久化
- 配置文件外部挂载
- 日志文件持久化

#### 端口映射（Port Mapping）
端口映射实现容器端口的外部访问：
- `80` → Nginx 前端服务
- `8080` → Spring Boot 后端 API
- `3306` → MySQL 数据库（建议仅内网访问）

#### Docker 网络
所有服务加入同一个自定义网络，容器间可通过服务名直接通信：
- 后端连接 MySQL 时使用 `mysql:3306`
- Nginx 代理后端时使用 `backend:8080`

---

## 2. 环境要求

### 2.1 服务器环境要求

| 组件 | 版本要求 | 推荐配置 |
|------|----------|----------|
| 操作系统 | CentOS 7+ / Ubuntu 20+ / Debian 11+ | Ubuntu 20.04 LTS |
| CPU | 2 核以上 | 4 核 |
| 内存 | 2GB 以上 | 4GB |
| 硬盘 | 20GB 以上 | 40GB SSD |
| Docker | 20.10+ | 最新稳定版 |
| Docker Compose | 2.0+ | 最新稳定版 |

### 2.2 本地开发环境

| 组件 | 版本要求 | 说明 |
|------|----------|------|
| JDK | 17+ | 后端编译 |
| Maven | 3.6+ | 后端打包 |
| Node.js | 16+ | 前端构建 |
| npm | 8+ | 前端包管理 |
| Git | 最新版 | 版本控制 |

### 2.3 验证 Docker 环境

```bash
# 检查 Docker 版本
docker --version
# 预期输出: Docker version 20.10.x, build xxxxx

# 检查 Docker Compose 版本
docker compose version
# 预期输出: Docker Compose version v2.x.x

# 检查 Docker 服务状态
systemctl status docker
```

---

## 3. 项目结构

### 3.1 部署文件清单

```
fwq/                                    # 部署配置根目录
├── config/                             # 配置文件目录
│   ├── application.yml                 # 后端基础配置
│   ├── application-online.yml          # 后端线上配置
│   ├── mysql.cnf                       # MySQL 配置
│   ├── init.sql                        # 数据库初始化脚本入口（已废弃，使用 snowisland.sql）
│   └── schema.sql                      # 数据库表结构参考
├── backend/                            # 后端相关
│   ├── Dockerfile                      # 后端 Docker 镜像构建文件
│   └── snowisland.jar                  # ❗ 后端 JAR 包（本地打包后复制到此）
├── frontend/                           # 前端相关
│   ├── Dockerfile                      # 前端 Docker 镜像构建文件
│   ├── nginx.conf                      # Nginx 配置文件
│   └── dist/                           # ❗ 前端构建产物（本地打包后复制到此）
│       ├── index.html
│       ├── assets/
│       ├── place/
│       ├── 登录页面.png
│       └── 交互页面背景.png
├── docker-compose.yml                  # Docker Compose 编排文件
├── snowisland.sql                      # ❗ 完整数据库初始化脚本（包含表结构和数据）
├── .gitignore                          # Git 忽略文件
└── DEPLOYMENT_GUIDE.md                 # 本部署文档
```

### 3.2 服务器目录规划

```bash
# 在服务器上创建部署目录
mkdir -p /opt/snowisland
mkdir -p /opt/snowisland/config
mkdir -p /opt/snowisland/logs
mkdir -p /opt/snowisland/backend
mkdir -p /opt/snowisland/frontend
```

部署完成后目录结构：

```
/opt/snowisland/
├── docker-compose.yml
├── snowisland.sql                      # 数据库初始化脚本
├── config/
│   ├── application.yml
│   ├── application-online.yml
│   ├── mysql.cnf
│   └── init.sql
├── backend/
│   ├── Dockerfile
│   └── snowisland.jar                  # 后端 JAR 包
├── frontend/
│   ├── Dockerfile
│   ├── nginx.conf
│   └── dist/                           # 前端构建产物
└── logs/                               # 日志目录
```

---

## 4. 服务器准备

### 4.1 Docker 安装（CentOS 示例）

如果服务器 Docker 版本较低，建议重装最新版：

```bash
# 1. 安装依赖
sudo yum install -y yum-utils

# 2. 卸载旧版本（如有）
sudo yum remove docker-ce docker-ce-cli containerd.io
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd

# 3. 添加 Docker 官方源
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# 4. 安装 Docker
sudo yum install docker-ce docker-ce-cli containerd.io

# 5. 启动 Docker 并设置开机自启
sudo systemctl start docker
sudo systemctl enable docker.service

# 6. 验证安装
docker --version
```

### 4.2 Docker Compose 安装

```bash
# 下载 Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# 赋予执行权限
sudo chmod +x /usr/local/bin/docker-compose

# 验证安装
docker-compose --version
```

### 4.3 创建 Docker 网络

```bash
# 创建自定义网络
docker network create snowisland

# 验证网络创建
docker network ls | grep snowisland
```

### 4.4 防火墙设置

```bash
# Ubuntu/Debian (ufw)
sudo ufw allow 22/tcp     # SSH
sudo ufw allow 80/tcp     # HTTP 前端
sudo ufw allow 443/tcp    # HTTPS
sudo ufw allow 8080/tcp   # 后端 API（可选，建议仅内网）
sudo ufw enable

# CentOS/RHEL (firewalld)
sudo firewall-cmd --permanent --add-port=22/tcp
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --permanent --add-port=443/tcp
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --reload
```

> **注意**：MySQL 端口 3306 不建议对外开放，仅在 Docker 内部网络访问即可。

---

## 5. 本地打包

### 5.1 前端打包

**步骤 1：进入前端项目目录**

```bash
cd f:\java\SnowIsland
```

**步骤 2：安装依赖**

```bash
npm install
```

**步骤 3：执行打包**

```bash
npm run build
```

**预期输出**：
```
vite v6.x.x building for production...
transforming...
✓ N modules transformed.
dist/index.html
dist/assets/index-xxxxxx.js
dist/assets/index-xxxxxx.css
...
built in x.xxs
```

**产物位置**：`f:\java\SnowIsland\dist\`

### 5.2 后端打包

**步骤 1：进入后端项目目录**

```bash
cd f:\java\SnowIsland
```

**步骤 2：执行 Maven 打包**

```bash
mvn clean package -DskipTests
```

**预期输出**：
```
[INFO] Building jar: F:\java\SnowIsland\target\snowisland-0.0.1-SNAPSHOT.jar
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: XX s
```

**产物位置**：`f:\java\SnowIsland\target\snowisland-0.0.1-SNAPSHOT.jar`

### 5.3 打包验证

```bash
# Windows PowerShell
# 验证前端产物
Test-Path f:\java\SnowIsland\dist\index.html

# 验证后端产物
Test-Path f:\java\SnowIsland\target\snowisland-0.0.1-SNAPSHOT.jar
```

---

## 6. 文件上传

### 6.1 使用 Xshell + Xftp（推荐）

1. **下载工具**
   - Xshell：`https://xpstart-test.oss-cn-chengdu.aliyuncs.com/soft/xshell/Xshell-7.0.0109p%281%29.exe`
   - Xftp：`https://xpstart-test.oss-cn-chengdu.aliyuncs.com/soft/xshell/Xftp-7.0.0107p%281%29.exe`

2. **连接服务器**
   - 打开 Xshell，新建连接
   - 协议：SSH
   - 主机：服务器 IP 地址
   - 端口：22
   - 用户名：root
   - 密码：服务器 root 密码

3. **上传文件**
   - 使用快捷键 `Alt + P` 打开 Xftp
   - 将 `fwq` 整个目录上传到 `/opt/snowisland/`
   - 将后端 JAR 包上传到项目对应位置

### 6.2 使用 SCP 命令

```bash
# 上传部署配置目录
scp -r f:\java\SnowIsland\fwq\* root@<服务器IP>:/opt/snowisland/

# 上传后端 JAR 包
scp f:\java\SnowIsland\target\snowisland-0.0.1-SNAPSHOT.jar root@<服务器IP>:/opt/snowisland/
```

---

## 7. 配置说明

### 7.1 数据库配置

**数据库信息**：
- 数据库名：`snowisland`
- 用户名：`root`
- 密码：`695390489`
- 端口：`3306`
- 服务名（Docker网络内）：`mysql`

### 7.2 环境变量配置

在 `/opt/snowisland/` 目录下创建 `.env` 文件：

```bash
cd /opt/snowisland
cat > .env << 'EOF'
# ============================================
# MySQL 配置
# ============================================
MYSQL_ROOT_PASSWORD=695390489
DB_USER=root
DB_PASSWORD=695390489
DB_NAME=snowisland
DB_HOST=mysql
DB_PORT=3306

# ============================================
# AI 配置（可选；密钥放 gitignored 的 .env，不要写进仓库）
# 复制 .env.example 为 .env 后填入
# ============================================
AI_API_KEY=

# ============================================
# Spring 配置
# ============================================
SPRING_PROFILES_ACTIVE=online
EOF
```

### 7.3 application.yml 配置说明

```yaml
# 基础配置文件，所有环境共用
server:
  port: 8080

spring:
  application:
    name: snowisland

  datasource:
    # Docker 网络内使用服务名 mysql 连接
    url: jdbc:mysql://mysql:3306/snowisland?useUnicode=true&characterEncoding=UTF-8&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Shanghai
    username: root
    password: ${DB_PASSWORD:695390489}
    driver-class-name: com.mysql.cj.jdbc.Driver
```

### 7.4 application-online.yml 配置说明

```yaml
# 线上环境配置，会覆盖基础配置
spring:
  profiles:
    active: online

  datasource:
    username: ${DB_USER:root}
    password: ${DB_PASSWORD:695390489}

# 线上日志级别更严格
logging:
  level:
    root: WARN
    com.example.snowisland: INFO
```

### 7.5 docker-compose.yml 服务说明

| 服务 | 镜像 | 端口 | 说明 |
|------|------|------|------|
| mysql | mysql:8 | 3306 | MySQL 数据库 |
| backend | 自定义构建 | 8080 | Spring Boot 后端 |
| frontend | 自定义构建 | 80 | Nginx 前端 |

---

## 8. 服务部署

### 8.1 部署前检查

```bash
cd /opt/snowisland

# 检查目录结构
ls -la

# 检查 .env 文件是否存在
cat .env

# 检查 Docker 网络
docker network ls | grep snowisland
```

### 8.2 启动 MySQL 数据库

```bash
cd /opt/snowisland

# 启动 MySQL 容器（首次启动会自动初始化数据库）
docker compose up -d mysql

# 查看启动日志
docker logs -f snowisland-mysql

# 等待 MySQL 就绪（看到 "ready for connections" 表示启动完成）
# 预期输出: [Server] /usr/sbin/mysqld: ready for connections.
```

### 8.3 验证数据库初始化

```bash
# 进入 MySQL 容器
docker exec -it snowisland-mysql mysql -uroot -p695390489

# 在 MySQL 中查看数据库
SHOW DATABASES;

# 查看表
USE snowisland;
SHOW TABLES;

# 退出
EXIT;
```

### 8.4 启动后端服务

```bash
cd /opt/snowisland

# 构建并启动后端
docker compose up -d --build backend

# 查看后端启动日志
docker logs -f snowisland-backend

# 等待启动完成（看到 "Started SnowIslandApplication" 表示启动成功）
# 预期输出: Started SnowIslandApplication in XX seconds
```

### 8.5 启动前端服务

```bash
cd /opt/snowisland

# 构建并启动前端
docker compose up -d --build frontend

# 查看前端启动日志
docker logs -f snowisland-frontend
```

### 8.6 一键启动所有服务

```bash
cd /opt/snowisland

# 构建并启动所有服务
docker compose up -d --build

# 查看服务状态
docker compose ps
```

### 8.7 服务启动顺序

| 顺序 | 服务 | 启动命令 | 预计等待时间 |
|------|------|----------|--------------|
| 1 | MySQL | `docker compose up -d mysql` | 30-60 秒 |
| 2 | 后端 | `docker compose up -d backend` | 60-90 秒 |
| 3 | 前端 | `docker compose up -d frontend` | 10-20 秒 |

---

## 9. 服务验证

### 9.1 检查容器状态

```bash
cd /opt/snowisland

# 查看所有容器状态
docker compose ps

# 预期输出:
# NAME                STATUS          PORTS
# snowisland-mysql    Up (healthy)    0.0.0.0:3306->3306/tcp
# snowisland-backend  Up (healthy)    0.0.0.0:8080->8080/tcp
# snowisland-frontend Up              0.0.0.0:80->80/tcp
```

### 9.2 健康检查

```bash
# 后端健康检查
curl http://localhost:8080/actuator/health

# 预期输出: {"status":"UP"}

# 通过 Nginx 代理检查
curl http://localhost/actuator/health
```

### 9.3 前端验证

```bash
# 检查前端响应
curl -I http://localhost

# 预期输出:
# HTTP/1.1 200 OK
# Server: nginx/x.x.x
# Content-Type: text/html
```

### 9.4 API 代理验证

```bash
# 通过 Nginx 代理访问后端 API
curl http://localhost/api/actuator/health

# 或直接访问后端
curl http://localhost:8080/actuator/health
```

### 9.5 浏览器验证

在浏览器中访问以下地址：

| 服务 | 访问地址 | 预期结果 |
|------|----------|----------|
| 前端首页 | `http://<服务器IP>` | 显示 SnowIsland 游戏界面 |
| 后端健康检查 | `http://<服务器IP>:8080/actuator/health` | 返回 `{"status":"UP"}` |
| API 接口 | `http://<服务器IP>/api/...` | 返回 JSON 数据 |

---

## 10. 常见问题

### 10.1 MySQL 连接失败

**错误信息**：
```
Communications link failure
The last packet sent successfully to the server was 0 milliseconds ago.
```

**解决方案**：

```bash
# 1. 检查 MySQL 容器是否运行
docker ps | grep mysql

# 2. 查看 MySQL 日志
docker logs snowisland-mysql

# 3. 检查网络连接（在后端容器内 ping mysql）
docker exec -it snowisland-backend ping mysql

# 4. 检查数据库是否存在
docker exec -it snowisland-mysql mysql -uroot -p695390489 -e "SHOW DATABASES;"

# 5. 重启 MySQL
docker restart snowisland-mysql
```

### 10.2 后端启动失败

**错误信息**：
```
Unable to acquire JDBC Connection
```

**解决方案**：

```bash
# 1. 确认 MySQL 已就绪
docker logs snowisland-mysql | grep "ready for connections"

# 2. 检查数据库配置
docker exec -it snowisland-backend env | grep DB_

# 3. 查看后端详细日志
docker logs snowisland-backend --tail=100

# 4. 重启后端服务
docker compose restart backend
```

### 10.3 前端 502 Bad Gateway

**错误信息**：
```
502 Bad Gateway
```

**解决方案**：

```bash
# 1. 检查后端是否运行
docker ps | grep backend

# 2. 查看 Nginx 日志
docker logs snowisland-frontend

# 3. 检查 Nginx 配置中的后端地址
# 确认 nginx.conf 中 proxy_pass 指向 backend:8080

# 4. 测试前端容器内是否能访问后端
docker exec -it snowisland-frontend wget -qO- http://backend:8080/actuator/health

# 5. 重启前端
docker restart snowisland-frontend
```

### 10.4 端口占用

**错误信息**：
```
Bind for 0.0.0.0:8080 failed: port is already allocated
```

**解决方案**：

```bash
# Linux: 查找占用端口的进程
netstat -tlnp | grep 8080
# 或
lsof -i :8080

# Windows: 查找占用端口的进程
netstat -ano | findstr :8080

# 停止占用进程，或修改 docker-compose.yml 中的端口映射
```

### 10.5 磁盘空间不足

**错误信息**：
```
no space left on device
```

**解决方案**：

```bash
# 清理未使用的 Docker 资源（谨慎操作）
docker system prune -a

# 仅清理未使用的镜像
docker image prune -a

# 清理未使用的数据卷（谨慎操作，会删除数据）
docker volume prune

# 清理日志文件
truncate -s 0 /var/lib/docker/containers/*/*-json.log

# 查看磁盘使用情况
df -h
docker system df
```

### 10.6 Docker 网络不存在

**错误信息**：
```
network snowisland declared as external, but could not be found
```

**解决方案**：

```bash
# 创建网络
docker network create snowisland

# 验证网络
docker network ls | grep snowisland
```

### 10.7 前端刷新 404

**问题描述**：Vue Router History 模式下，刷新页面出现 404。

**解决方案**：
Nginx 配置中已包含 `try_files $uri $uri/ /index.html;`，确保配置正确：

```nginx
location / {
    try_files $uri $uri/ /index.html;
}
```

---

## 11. 运维命令

### 11.1 服务管理

```bash
cd /opt/snowisland

# 启动所有服务
docker compose up -d

# 停止所有服务
docker compose down

# 重启所有服务
docker compose restart

# 查看服务状态
docker compose ps

# 查看服务日志
docker compose logs -f
docker compose logs -f backend          # 只看后端
docker compose logs -f --tail=100 mysql  # 只看最近 100 行
```

### 11.2 日志管理

```bash
# 查看后端应用日志
docker exec -it snowisland-backend tail -f /var/log/snowisland/application.log

# 查看 Nginx 访问日志
docker exec -it snowisland-frontend tail -f /var/log/nginx/access.log

# 查看 Nginx 错误日志
docker exec -it snowisland-frontend tail -f /var/log/nginx/error.log

# 导出日志到本地
docker cp snowisland-backend:/var/log/snowisland/application.log ./backend.log
```

### 11.3 数据库管理

```bash
# 进入 MySQL 客户端
docker exec -it snowisland-mysql mysql -uroot -p695390489

# 备份数据库
docker exec snowisland-mysql mysqldump -uroot -p695390489 snowisland > backup_$(date +%Y%m%d).sql

# 恢复数据库
docker exec -i snowisland-mysql mysql -uroot -p695390489 snowisland < backup_20260101.sql

# 查看数据库大小
docker exec -it snowisland-mysql mysql -uroot -p695390489 -e "
SELECT table_schema AS 'Database',
ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)'
FROM information_schema.TABLES
WHERE table_schema = 'snowisland';
"
```

### 11.4 更新部署

```bash
cd /opt/snowisland

# 1. 本地重新打包
# 前端: npm run build
# 后端: mvn clean package -DskipTests

# 2. 上传新版本到服务器（参考 6. 文件上传）

# 3. 重新构建镜像
docker compose build --no-cache backend
docker compose build --no-cache frontend

# 4. 重启服务
docker compose up -d --build

# 5. 验证服务
docker compose ps
```

### 11.5 紧急恢复

```bash
cd /opt/snowisland

# 强制重启所有容器
docker compose kill
docker compose up -d

# 完全重置（删除所有数据，谨慎使用！）
docker compose down -v
docker system prune -a --volumes
docker compose up -d --build
```

---

## 12. 域名与 SSL 配置

### 12.1 域名解析

1. 购买域名（阿里云/腾讯云等）
2. 配置 DNS 解析，将域名指向服务器 IP
3. 等待解析生效（通常几分钟到几小时）

### 12.2 免费 SSL 证书（阿里云）

阿里云每年提供 20 次免费 SSL 证书：

1. 登录阿里云控制台
2. 搜索「数字证书管理服务」
3. 点击「免费证书」→「立即购买」
4. 填写域名信息，提交申请
5. 完成域名验证（DNS 验证或文件验证）
6. 等待证书签发（通常 1-5 分钟）
7. 下载证书（选择 Nginx 格式）

### 12.3 配置 HTTPS

1. **上传证书文件**

```bash
# 创建证书目录
mkdir -p /opt/snowisland/cert

# 上传证书文件到该目录
# - xxx.pem (证书文件)
# - xxx.key (私钥文件)
```

2. **修改 docker-compose.yml**

在 frontend 服务的 volumes 中添加证书挂载：

```yaml
volumes:
  - ./config/nginx.conf:/etc/nginx/conf.d/default.conf:ro
  - ./cert:/usr/share/nginx/https:ro
```

3. **修改 Nginx 配置**

在 `nginx.conf` 中添加 HTTPS server 配置：

```nginx
server {
    listen 443 ssl;
    server_name your-domain.com;

    ssl_certificate /usr/share/nginx/https/your-domain.pem;
    ssl_certificate_key /usr/share/nginx/https/your-domain.key;

    ssl_session_cache shared:SSL:1m;
    ssl_session_timeout 5m;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    location / {
        root /usr/share/nginx/html;
        index index.html;
        try_files $uri $uri/ /index.html;
    }

    location /api {
        proxy_pass http://backend:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

4. **HTTP 强制跳转 HTTPS**

在 HTTP server 中添加重定向：

```nginx
server {
    listen 80;
    server_name your-domain.com;
    return 301 https://$host$request_uri;
}
```

5. **更新端口映射**

在 `docker-compose.yml` 的 frontend 服务中添加 443 端口：

```yaml
ports:
  - "80:80"
  - "443:443"
```

6. **重启前端服务**

```bash
docker compose up -d frontend
```

---

## 附录 A：Docker Compose 服务架构图

```
┌─────────────────────────────────────────────────────────────┐
│                      服务器 (公网 IP)                        │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │           snowisland (bridge network)                │    │
│  │                                                      │    │
│  │  ┌─────────────┐    ┌─────────────┐                  │    │
│  │  │   MySQL     │◄──►│   Backend   │                  │    │
│  │  │  (3306)     │    │  (8080)     │                  │    │
│  │  └─────────────┘    └──────┬──────┘                  │    │
│  │                             │                         │    │
│  │  ┌─────────────┐            │                         │    │
│  │  │  Frontend   │◄───────────┘                         │    │
│  │  │  (Nginx)    │                                      │    │
│  │  └──────┬──────┘                                      │    │
│  └─────────┼─────────────────────────────────────────────┘    │
│            │                                                  │
└────────────┼──────────────────────────────────────────────────┘
             │
        ┌────┴────┐
        │ 外部访问 │
        │ Port:80 │
        │ Port:443│
        │ Port:8080│
        └─────────┘
```

## 附录 B：环境变量清单

| 变量名 | 说明 | 默认值 |
|--------|------|--------|
| `MYSQL_ROOT_PASSWORD` | MySQL root 密码 | `695390489` |
| `DB_USER` | 数据库用户名 | `root` |
| `DB_PASSWORD` | 数据库密码 | `695390489` |
| `DB_NAME` | 数据库名 | `snowisland` |
| `DB_HOST` | 数据库主机 | `mysql` |
| `DB_PORT` | 数据库端口 | `3306` |
| `AI_API_KEY` | DeepSeek API Key（写入 gitignored `.env`，勿提交） | 空 |
| `SPRING_PROFILES_ACTIVE` | Spring 环境 | `online` |

## 附录 C：端口清单

| 端口 | 服务 | 说明 | 是否对外开放 |
|------|------|------|-------------|
| 22 | SSH | 远程连接 | 是 |
| 80 | Nginx | HTTP 前端 | 是 |
| 443 | Nginx | HTTPS 前端 | 可选 |
| 8080 | Spring Boot | 后端 API | 可选 |
| 3306 | MySQL | 数据库 | 否（仅内网） |

---

## 文档版本

| 版本 | 日期 | 修改内容 |
|------|------|----------|
| 3.0 | 2026-06-26 | 完善打包流程，添加部署前检查清单，更新文件上传清单，添加完整验证流程，修复背景图片路径问题 |
| 2.0 | 2026-06-26 | 重写部署文档，完善数据库配置，增加 Docker 网络、SSL 配置、常见问题等 |
| 1.0 | 2026-06-25 | 初始版本 |

---

## 附录 D：完整部署包说明

### D.1 打包产物清单

每次更新部署包时，应包含以下文件：

| 文件/目录 | 来源 | 说明 |
|-----------|------|------|
| `docker-compose.yml` | `fwq/docker-compose.yml` | Docker Compose 编排文件 |
| `snowisland.sql` | `fwq/snowisland.sql` | 数据库初始化脚本（完整） |
| `config/` | `fwq/config/` | 后端和 MySQL 配置文件 |
| `backend/Dockerfile` | `fwq/backend/Dockerfile` | 后端构建配置 |
| `backend/snowisland.jar` | `target/SnowIsland-0.0.1-SNAPSHOT.jar` | 后端可执行 JAR |
| `frontend/Dockerfile` | `fwq/frontend/Dockerfile` | 前端构建配置 |
| `frontend/nginx.conf` | `fwq/frontend/nginx.conf` | Nginx 配置 |
| `frontend/dist/` | `dist/` | 前端打包产物 |

### D.2 打包命令

```bash
# 前端打包（在项目根目录）
cd f:\java\SnowIsland
npm run build

# 后端打包（在项目根目录）
mvn clean package -DskipTests

# 将打包产物复制到部署目录
Copy-Item target/SnowIsland-0.0.1-SNAPSHOT.jar fwq/backend/snowisland.jar -Force
Remove-Item fwq/frontend/dist -Recurse -Force -ErrorAction SilentlyContinue
Copy-Item dist fwq/frontend/dist -Recurse -Force
```

### D.3 更新部署流程

```bash
# 在服务器上执行

# 1. 停止服务
cd /opt/snowisland
docker compose down

# 2. 上传新的部署包（覆盖旧文件）

# 3. 重新构建并启动
docker compose up -d --build

# 4. 验证服务
docker compose ps
curl http://localhost/api/actuator/health
```
