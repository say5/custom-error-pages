#Build container
FROM golang:1.14 as builder

ENV APP_USER app
ENV APP_HOME /go/src/app

RUN groupadd $APP_USER && useradd -m -g $APP_USER -l $APP_USER
RUN mkdir -p $APP_HOME && chown -R $APP_USER:$APP_USER $APP_HOME

WORKDIR $APP_HOME
USER $APP_USER
COPY . .

RUN go get -d -v
RUN go build -o custom-error-pages

#App docker image
FROM debian:buster

ENV APP_USER app

RUN groupadd $APP_USER && useradd -m -g $APP_USER -l $APP_USER

COPY --chown=0:0 --from=builder /go/src/app/custom-error-pages /
COPY www /www
COPY etc /etc

EXPOSE 8080
USER $APP_USER

CMD ["/custom-error-pages"]
