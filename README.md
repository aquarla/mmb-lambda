# Mastodon Marcov bot for AWS Lambda (mmb-lambda)

## Install MeCab and run bundle install

```
docker build -t mylambda .
docker run -v `pwd`:/var/task -it mylambda
```

## Run the bot locally

```
docker run -v `pwd`:/var/task --env-file .env -it lambci/lambda:ruby2.7 function.handler
```
