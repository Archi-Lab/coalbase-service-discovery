node {
    def changelist = "${env.BUILD_NUMBER}"

    stage('Checkout') {
        checkout scm
    }

    docker.image('maven:3.6.1-jdk-8-alpine').inside {
        writeFile file: 'settings.xml', text: "<settings><localRepository>${pwd()}/.m2</localRepository></settings>"

        try {
            stage('Test') {
                sh 'mvn -B -s settings.xml -DargLine="-Dspring.profiles.active=local" test'
            }
        } finally {
            junit 'target/surefire-reports/*.xml'
        }

        stage('Quality Check') {
            sh 'mvn -B -s settings.xml checkstyle:checkstyle'
            jacoco
            withSonarQubeEnv('SonarQube-Server') {
                sh 'mvn -B -s settings.xml org.sonarsource.scanner.maven:sonar-maven-plugin:3.6.0.1398:sonar'
            }
        }

        stage("Quality Gate") {
            timeout(time: 10, unit: "MINUTES") {
                def qg = waitForQualityGate()

                if (qg.status == "WARN") {
                    currentBuild.result = "UNSTABLE"
                } else {
                    if (qg.status != "OK") {
                        error "Pipeline aborted due to quality gate failure: ${qg.status}"
                    }
                }
            }
        }

        stage('Build Production') {
            withCredentials([usernamePassword(credentialsId: 'archilab-nexus-jenkins', usernameVariable: 'NEXUS_USERNAME', passwordVariable: 'NEXUS_PASSWORD')]) {
                sh "mvn -B -s settings.xml -Ddockerfile.username=\"$NEXUS_USERNAME\" -Ddockerfile.password=\"$NEXUS_PASSWORD\" -Drevision= -Dchangelist=${changelist} -Dmaven.test.skip=true clean deploy"
            }
        }

        stage('Docker build Dev') {
            sh "docker build -f ./Dockerfile-dev -t docker.nexus.archi-lab.io/archilab/coalbase-service-discovery-dev ."

            docker.withRegistry('https://docker.nexus.archi-lab.io', 'archilab-nexus-jenkins') {
                sh "docker push docker.nexus.archi-lab.io/archilab/coalbase-service-discovery-dev"
            }
        }
    }

    stage('Deploy') {
        docker.withServer('tcp://10.10.10.51:2376', 'coalbase-prod-certs') {
            def pom = readMavenPom file: 'pom.xml'
            def image = pom.getArtifactId()
//            def revision = pom.getProperties().getProperty('revision')
//            def tag = "${revision}${changelist}"

            docker.withRegistry('https://docker.nexus.archi-lab.io', 'archilab-nexus-jenkins') {
                sh "env IMAGE=${image} TAG=${changelist} docker stack deploy --with-registry-auth -c src/main/docker/docker-compose.yml -c src/main/docker/docker-compose.prod.yml ${image}"
            }
        }
    }
}
