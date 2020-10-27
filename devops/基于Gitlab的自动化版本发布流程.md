#基于Gitlab的自动化版本发布流程

## 1. Gitlab Flow说明

在代码分支策略中，比较流行的有github-flow和git-flow。其中，git-flow适用于开源软件的开发协作模式，软件会在不同时间发布不同的release版本，并且发布的功能特性及其时间点完全由开发者决定。git-flow流程管理非常复杂，其使用场景也不适合互联网企业的业务模式。而github-flow规则定义的过于简单，过多的自由没法对开发规范加以管控。

Gitlab Flow只在前两者者的基础上进行优化，并总结出来的更适合互联网及信息服务企业的一种代码分支管理模型。主要特点如下：
* master分支记录所有测试通过的代码
* 为线上的环境分别创建一个对应的分支，每次上线从master分支合并到对应的”环境分支”
* 不同环境如果存在功能特性的差异，通过cherry-pick方式从master选取代码合并
* 单向数据流，所有的提交先到开发分支，再到master分支，然后再到“环境分支”

![](https://docs.gitlab.com/ee/university/training/gitlab_flow/production_branch.png)

Gitlab Flow更多详情可以参考：https://docs.gitlab.com/ee/university/training/gitlab_flow.html#what-is-the-gitlab-flow

目前雅观的分支模型和Gitlab Flow类似，不同的地方在于分支的名称不同。雅观的preview分支对应Gitlab Flow的master分支，雅观的master分支对应Gitlab分支的“环境分支”。这样做的初衷是为了让开发者更容易理解，后续如果大家对Git协作流程都特别熟悉了，可以完全采用Gitlab Flow。

雅观使用的CI/CD只在preview分支上进行，代码审核通过后被合并到preview，自动触发编译并部署到预发环境，生产环境的部署需要手动触发才会执行，下面是雅观的部署流程图解：
![](http://192.168.2.4:8181/uploads/202010/akeeta-server-info/attach_1641817b2f469c1b.png)


## 2. 配置CICD环境
### 2.1 安装gitlab-runner程序
选择空闲的机器安装gitlab-runner程序，gitlab-runner复杂调度并运行CICD脚本，需要的内存根据实际情况适当预留。

gitlab-runner安装教程参考：
https://docs.gitlab.com/runner/install/linux-manually.html#using-binary-file

### 2.1 注册runner
安装完成后，需要向gitlab实例注册runner，一个gitlab-runner服务下可以注册多个runner，默认情况下，同一时刻只运行一个runner，想要并行运行多个runner可修改/etc/gitlab-runner/config.toml里面的concurrent的值，修改完后5分钟后自动生效。

目前雅观使用到的runner注册方法：  
1. 打开gitlab，进入对应的项目，选择settings- > CI/CD- > runners，记录里面的url和token。
![](http://192.168.2.4:8181/uploads/202010/akeeta-server-info/attach_1641859a21be097f.png)
2. 在gitlab-runner所在机器以root用户运行如下命令：
```shell script
root@argrace-server-2:~# gitlab-runner register
Runtime platform                                    arch=amd64 os=linux pid=28069 revision=a998cacd version=13.2.2
Running in system-mode.

Please enter the gitlab-ci coordinator URL (e.g. https://gitlab.com/):
http://192.168.2.3/                #这里填写第一步记录的url
Please enter the gitlab-ci token for this runner:
sUsdvLn66bh8cYp3zzur               #这里填写第一步记录的token
Please enter the gitlab-ci description for this runner:
[argrace-server-2]: test_runner    #取个名字用于区分runner
Please enter the gitlab-ci tags for this runner (comma separated):
demo,testrunner                    # tags用于CI/CD任务选择对应的runner
Registering runner... succeeded                     runner=sUsdvLn6
Please enter the executor: docker+machine, docker-ssh+machine, docker, docker-ssh, shell, ssh, custom, parallels, virtualbox, kubernetes:
ssh                                # 目前使用ssh模式够用了
Please enter the SSH server address (e.g. my.server.com):
192.168.2.4                        #  CI/CD脚本运行的服务器地址
Please enter the SSH server port (e.g. 22):
                                   # 空表示默认端口
Please enter the SSH user (e.g. root):
admin                              #  CI/CD脚本运行的用户
Please enter the SSH password (e.g. docker.io):
******                             #  CI/CD脚本运行的用户密码
Please enter path to SSH identity file (e.g. /home/user/.ssh/id_rsa):
/home/gitlab-runner/.ssh/id_rsa    #ssh免密登录的私钥
Runner registered successfully. Feel free to start it, but if it's running already the config should be automatically reloaded!
```
运行`gitlab-runner --help`可显示详细的帮助，包括查询和删除runner。

## 3. 上线操作说明
代码上线先由开发者在Gitlab上提交Merge Request（简称MR），指派给系统的主备岗。由主备岗完成对代码的review，确定无误之后点解"Merge"完成代码合并到preview分支，并自动触发pipeline，待pipeline的部署预发成功完成后，可以选择手动触发并部署到生产环境。

### 3.1 版本提交申请
参考 [版本自动化发布说明](http://192.168.2.4:8181/docs/akeeta-server-info/akeeta-gw-api-doc-51597749648) 的“代码提交流程”
### 3.2 代码复核
创建好Merge Request后在Merge Request页面可以查看代码的变更详情。
![](http://192.168.2.4:8181/uploads/202010/akeeta-server-info/attach_1641b91d091fbff2.png)

点击每行的行号，可以对当前行的代码添加评论。添加的评论会在Discussion里面展示。
![](http://192.168.2.4:8181/uploads/202010/akeeta-server-info/attach_1641b967711ee5cd.png)

### 3.3 部署上线
每个MR都会自动触发一个pipeline，一个pipeline由多个stage组成，每个stage由多个task组成。目前雅观系统普遍配置为4个stage：分别是build，test，preview，deploy。每个stage包含的task以及task的具体操作全部定义在代码仓库根目录的.gitlab-ci.yml文件中。
![](http://192.168.2.4:8181/uploads/202010/akeeta-server-info/attach_1641b9fe34995cb8.png)
最后一个Stage为deploy，其中包含了deploy1和deploy2两个task，这两个task都需要手动触发才会执行。

通过下面的when字段指定为手动触发的任务
```yaml
deploy_prd1:
  stage: deploy
  tags:
    - deploy
  dependencies:
    - build_prod
  only:
    - preview
    - /^cherry-pick-.*$/
  when: manual
  script:
    - 'which ssh-agent || ( apt-get update -y && apt-get install openssh-client -y )'
    - eval $(ssh-agent -s)
    - echo "$CI_SSH_PRIVATE_KEY" | tr -d '\r' | ssh-add - > /dev/null
    - md5sum target/yaguanapi-0.0.1-SNAPSHOT.war
    - scp target/yaguanapi-0.0.1-SNAPSHOT.war admin@139.224.112.200:~/tomcat/webapps.backup/ROOT.war
    - ssh admin@139.224.112.200 "cd ~/bin && ./deploy_ci_yaguanapi.sh "
    - kill -9 $SSH_AGENT_PID

```
.gitlab-ci.yml配置文件的详细说明参考：https://docs.gitlab.com/ee/ci/yaml/README.html

在手动触发了生产环境部署任务后，如果部署成功并检查功能正常运行，建议将preview分支的代码合并到master分支，用于确保master分支和生产环境对应。

如果存在某个环境部署失败，只需要找到上一次的pipeline，点击“retry”重复执行其任务，既可以完成版本的回退。目前gitlab配置保留了一周内的artifact，所以可以回顾到一周内的任意版本。

### 3.5 查看线上的代码

如果在每次成功部署上生产之后，都能确保合并到master分支，可以通过查看master分支来分析线上代码。但合并到master的操作往往会滞后或遗忘一段时间，下面给出一种办法来查看生产环境所对应的版本的代码：
1. 打开gitlab，进入项目的CI/CD->pipelines
2. 找到最近一次部署成功的记录。
![](http://192.168.2.4:8181/uploads/202010/akeeta-server-info/attach_1641cc4db55b58ab.png)
3. 点击其对应的commitId
4. 进入提交详情页之后，点击右上角的“Browser files”,即可进入代码查看详情页面
![](http://192.168.2.4:8181/uploads/202010/akeeta-server-info/attach_1641cc5e37a78bbe.png)
5. 在代码查看页面，可以点击“Find file” 可以搜索文件。
![](http://192.168.2.4:8181/uploads/202010/akeeta-server-info/attach_1641cc7ffde3e0f5.png)


### 2.4 分环境部署
正常的MR，如果申请者没有明确标注，则允许随时部署到正式环境。
如果存在将某一个功能只部署到预发布环境，暂时不能部署到生产。需要遵循一下操作步骤。
1. 主备岗在确认Merge之前，需要确保之前所有在预发的功能全部部署到了生产环境，并且preview分支代码全部合并到了master分支。
2. 点击Merge，将此MR合并到preview分支，不可以触发生产的部署任务。
3. 对于后续的MRs，采用相同的办法部署到preview，但不能触发当前pipeline的生产环境的部署任务，而是采用下面第4步的cherry-pick操作。
4. 对于需要部署到生产的MR，在MR页面，点击cherry-pick按钮，然后在弹出框中选择master分支，勾选创建“new merge request”复选框。
![](http://192.168.2.4:8181/uploads/202010/akeeta-server-info/attach_1641d714b604004e.png)
5. 第4步操作会生成分支cherry-pick-******，并创建它到master分支的新MR。在新的MR中，手动触发对生产环境的部署任务。如果新分支存在合并冲突，或者编译错误，需要通知相关开发人员处理。处理完后，在最后的提交所对应的pipeline上完成对生产环境的部署。
6. 在第5步生产环境部署成功之后， **必须** 点击”Merge“将第5步产生的MR合并到master分支。
7. 之后的其他MR参考第3-6步完成。

### 2.5 AWS海外部署
海外部署采用了容器运行，并且使用了jar包部署，较少了每次发布包的大小，提高了部署效率。
详细情况参考：http://192.168.2.4:8181/docs/argrace_oem/akeeta-gw-api-doc-261602229427
海外部署由于存在访问被墙掉的可能性，所以部署脚本执行过程采用了国内服务器隧道代理来实现的，详细实现可以参考.gitlab-ci.yml文件中的deploy_global()函数。
```shell script
function deploy_global() {  ssh admin@139.224.112.200 "ssh -i .ssh/global_rsa admin@$1 \"cd akeeta-core && sh deploy_by_ci.sh ${CI_COMMIT_SHA:0:8}\" "; }
```
