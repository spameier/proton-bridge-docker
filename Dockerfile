FROM alpine AS build
RUN ["apk","add","--no-cache","gcc","git","go","libsecret-dev","make","pkgconf"]
RUN ["wget","https://github.com/ProtonMail/proton-bridge/archive/master.tar.gz"]
RUN ["tar","xf","master.tar.gz"]
WORKDIR /proton-bridge-master
RUN ["sed","-i","s/REVISION:=.*/REVISION:=git/","Makefile"]
RUN ["make","clean"]
RUN ["make","build-nogui"]

FROM alpine
LABEL maintainer="spameier"
RUN ["apk","add","dbus","glib","libsecret","pass","socat"]
COPY --from=build /proton-bridge-master/Desktop-Bridge /
ADD entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
