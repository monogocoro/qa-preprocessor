FROM centos:latest
MAINTAINER Ryohei Tanaka <tanaka@monogocoro.co.jp>

RUN yum install -y tar wget

RUN wget "https://s3-ap-northeast-1.amazonaws.com/ai-backend/libraries/enju-2.4.2-centos5-x86_64.tar.gz" --no-check-certificate -O enju.tar.gz
RUN tar -xzf enju.tar.gz

EXPOSE 80
# Execute
CMD cd enju-2.4.2; ./enju -genia -cgi 80
