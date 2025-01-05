pipeline {
    agent any
    environment {
        // 환경 변수 설정
        DOCKER_TAG = "latest"
        MAIN_PLAYBOOK = "main_deploy.yaml"
        PROV_PLAYBOOK = "main_provisioning.yaml"
        INVENTORY_FILE = "inventory.ini"
        SEARCH_PLAYBOOK = "deploy.yaml"
    }
    stages {
        stage('Checkout') {
            steps {
                // GitHub에서 코드 체크아웃
                git url: 'https://github.com/active-webmaker/bigdata.git', branch: 'main'
            }
        }
        stage('Detect Provisioning File and Inventory File Changes') {
            steps {
                script {
                    // 최신 변경 사항 가져오기
                    sh "git fetch origin main"

                    // Dockerfile의 변경 사항 확인
                    def provFileChanged = sh(script: "git diff --name-only FETCH_HEAD | grep provisioning || true", returnStatus: true) == 0
                    def inventoryFileChanged = sh(script: "git diff --name-only FETCH_HEAD | grep ${env.INVENTORY_FILE} || true", returnStatus: true) == 0
                    
                    // 변경 사항 여부를 로깅
                    echo "Provisioning File changed: ${provFileChanged}"
                    echo "Inventory File changed: ${inventoryFileChanged}"

                    // 변경 사항 여부를 확인
                    if (provFileChanged || inventoryFileChanged) {
                        ansiblePlaybook(
                            playbook: "${env.PROV_PLAYBOOK}",
                            inventory: "${env.INVENTORY_FILE}"
                        )
                    }
                }
            }
        }
        stage('Detect DockerFile Changes') {
            steps {
                script {
                    // Dockerfile의 변경 사항 확인
                    def dockerFileChanged = sh(script: "git diff --name-only FETCH_HEAD | grep Dockerfile || true", returnStatus: true) == 0
                    
                    // 변경 사항 여부를 로깅
                    echo "Dockerfile changed: ${dockerFileChanged}"
                    
                    // 변수에 변경 사항을 저장
                    env.DOCKERFILE_CHANGED = dockerFileChanged ? 'true' : 'false'
                }
            }
        }
        stage('Detect Ansible Changes') {
            steps {
                script {
                    // Ansible Playbook의 변경 사항 확인
                    def ansiblePlaybookChanged = sh(script: "git diff --name-only FETCH_HEAD | grep ${env.SEARCH_PLAYBOOK} || true", returnStatus: true) == 0
                    
                    // 변경 사항 여부를 로깅
                    echo "Ansible Playbook changed: ${ansiblePlaybookChanged}"
                    
                    // 변수에 변경 사항을 저장
                    env.ANSIBLE_PLAYBOOK_CHANGED = ansiblePlaybookChanged ? 'true' : 'false'
                }
            }
        }
        stage('Build Docker Image and Run Ansible Playbook') {
            when {
                // Dockerfile 또는 Ansible Playbook의 변경 사항이 있을 시 아래 스텝 진행
                expression { env.DOCKERFILE_CHANGED == 'true' || env.ANSIBLE_PLAYBOOK_CHANGED == 'true' }
            }
            steps {
                // 도커 이미지 빌드 및 앤서블 플레이북 배포
                script {
                    // 변경사항이 있는 도커파일만 빌드
                    try {
                        def DOCKER_FOLDERS = ["Nginx", "MySQL", "Flask", "Airflow", "BigTop"]
                        def changedFiles = sh(script: "git diff --name-only FETCH_HEAD", returnStdout: true).split('\n')
                        for (folder in DOCKER_FOLDERS) {
                            if (changedFiles.any { it.contains("${folder}/Dockerfile") }) {
                                // 빌드하려는 도커파일을 로깅
                                echo "Dockfile Build try: ${folder}"
                                sh "docker build -t ${folder}:${DOCKER_TAG} -f ${folder}/Dockerfile ${folder}"
                            }
                        }
                    } catch (Exception e) {
                        error "Docker image ${folder} build failed: ${e.getMessage()}"
                    }
                    // 앤서블 플레이북 배포
                    try {
                        withCredentials([
                            string(credentialsId: 'mysql_root_password', variable: 'MYSQL_PW'), 
                            string(credentialsId: 'replication_password', variable: 'REPL_PW')
                        ]) {
                            ansiblePlaybook(
                                playbook: "${env.MAIN_PLAYBOOK}",
                                inventory: "${env.INVENTORY_FILE}",
                                extraVars: [
                                    mysql_root_password: "$MYSQL_PW",
                                    replication_password: "$REPL_PW"
                                ]
                            )
                        }
                    } catch (Exception e) {
                        error "Ansible deployment failed: ${e.getMessage()}"
                    }
                }
            }
        }
    }
    post {
        always {
            // 항상 빌드 로그 보존
            sh "echo 'Build logs' > build.log"
            archiveArtifacts artifacts: 'build.log', allowEmptyArchive: true
        }
        success {
            // 성공 시 메시지 출력
            echo "Build and deployment successful!"
        }
        failure {
            // 실패 시 메시지 출력
            echo "Build or deployment failed!"
        }
    }
}